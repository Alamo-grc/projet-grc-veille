#!/usr/bin/env bash
# ==========================================================================
# backup-veillegrc.sh
# Script de sauvegarde hebdomadaire pour VeilleGRC-Agent
# Sprint 4.1.B - Reference : DEC-048, DEC-049
# ==========================================================================
#
# Ce script :
# 1. Verifie que les containers tournent (auto-heal si arret)
# 2. Dump PostgreSQL (base veillegrc) via pg_dump
# 3. Archive n8n-data (workflows, credentials, historique)
# 4. Archive caddy-data (certificats TLS)
# 5. Regroupe tout dans un tar.gz date
# 6. Depose l'archive dans /mnt/backups (dossier partage Windows)
# 7. Supprime les backups de plus de 30 jours (retention)
# 8. Journalise toutes les etapes
#
# Retention : 30 jours (DEC-048)
# Frequence : hebdomadaire, dimanche 03:00 (via cron)
# ==========================================================================

set -euo pipefail  # Strict mode : abort on error, undefined var, pipe fail

# --- Configuration ---
DOCKER_DIR="/opt/veillegrc/docker"
BACKUP_DIR="/mnt/backups"
LOG_DIR="/opt/veillegrc/logs"
LOG_FILE="${LOG_DIR}/backup-$(date +%Y%m%d-%H%M).log"
RETENTION_DAYS=30

# Nom du fichier archive
DATE_STAMP=$(date +%Y%m%d-%H%M)
ARCHIVE_NAME="veillegrc-backup-${DATE_STAMP}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

# Repertoire temporaire pour la construction du backup
TMP_DIR=$(mktemp -d /tmp/veillegrc-backup-XXXXXX)

# --- Fonction de log ---
log() {
    local message="[$(date +'%Y-%m-%d %H:%M:%S')] $*"
    echo "${message}" | tee -a "${LOG_FILE}"
}

# --- Fonction de nettoyage (executee meme en cas d'erreur) ---
cleanup() {
    local exit_code=$?
    if [ -d "${TMP_DIR}" ]; then
        rm -rf "${TMP_DIR}"
        log "Nettoyage repertoire temporaire : ${TMP_DIR}"
    fi
    if [ ${exit_code} -ne 0 ]; then
        log "ERREUR : script termine avec code ${exit_code}"
    fi
    exit ${exit_code}
}
trap cleanup EXIT INT TERM

# --- Preparation des repertoires ---
mkdir -p "${LOG_DIR}"
mkdir -p "${BACKUP_DIR}"

log "=============================================="
log "DEMARRAGE BACKUP VEILLEGRC"
log "=============================================="
log "Date          : $(date)"
log "Archive cible : ${ARCHIVE_PATH}"
log "Retention     : ${RETENTION_DAYS} jours"
log "Temp dir      : ${TMP_DIR}"

# --- Verification prerequis ---
log "Verification prerequis..."

if [ ! -d "${BACKUP_DIR}" ]; then
    log "ERREUR : dossier de backup introuvable : ${BACKUP_DIR}"
    log "Verifier que le partage VirtualBox est bien monte."
    exit 1
fi

# Test ecriture dans le dossier de backup
if ! touch "${BACKUP_DIR}/.write-test" 2>/dev/null; then
    log "ERREUR : impossible d'ecrire dans ${BACKUP_DIR}"
    log "Verifier les droits (groupe vboxsf) et le montage."
    exit 1
fi
rm -f "${BACKUP_DIR}/.write-test"
log "OK : dossier de backup accessible en ecriture"

# Verifier presence docker compose
if ! command -v docker &>/dev/null; then
    log "ERREUR : commande docker introuvable"
    exit 1
fi

# --- Auto-heal des containers ---
log "----------------------------------------------"
log "AUTO-HEAL : verification etat des containers"
log "----------------------------------------------"

cd "${DOCKER_DIR}"

CONTAINERS_EXPECTED=("veillegrc-postgres" "veillegrc-n8n" "veillegrc-caddy")
CONTAINERS_TO_START=0

for container in "${CONTAINERS_EXPECTED[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        log "OK : ${container} est en cours d'execution"
    else
        log "ATTENTION : ${container} n'est pas actif - demarrage requis"
        CONTAINERS_TO_START=1
    fi
done

if [ ${CONTAINERS_TO_START} -eq 1 ]; then
    log "Demarrage de la stack Docker..."
    docker compose up -d
    log "Attente 20s pour laisser les containers demarrer et devenir healthy..."
    sleep 20

    # Verification post-demarrage
    for container in "${CONTAINERS_EXPECTED[@]}"; do
        if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
            log "ERREUR : ${container} n'a pas demarre correctement"
            exit 1
        fi
    done
    log "OK : tous les containers ont demarre"
fi

# --- Dump PostgreSQL ---
log "----------------------------------------------"
log "DUMP POSTGRESQL"
log "----------------------------------------------"

PG_DUMP_FILE="${TMP_DIR}/postgres-dump.sql"

log "Execution pg_dump sur la base veillegrc..."
if docker exec veillegrc-postgres pg_dump \
    -U veille_app \
    -d veillegrc \
    --clean \
    --if-exists \
    --no-owner \
    --no-privileges \
    > "${PG_DUMP_FILE}"; then
    PG_SIZE=$(du -h "${PG_DUMP_FILE}" | cut -f1)
    log "OK : dump PostgreSQL cree (${PG_SIZE})"
else
    log "ERREUR : echec du pg_dump"
    exit 1
fi

# --- Archive n8n-data ---
log "----------------------------------------------"
log "ARCHIVE N8N-DATA"
log "----------------------------------------------"

N8N_DATA_DIR="${DOCKER_DIR}/n8n-data"
N8N_ARCHIVE="${TMP_DIR}/n8n-data.tar.gz"

if [ -d "${N8N_DATA_DIR}" ]; then
    log "Compression de ${N8N_DATA_DIR}..."
    # Utilisation de sudo car certains fichiers n8n appartiennent a node (UID 1000 dans container)
    sudo tar -czf "${N8N_ARCHIVE}" -C "${DOCKER_DIR}" n8n-data 2>&1 | tee -a "${LOG_FILE}" || true

    if [ -f "${N8N_ARCHIVE}" ]; then
        N8N_SIZE=$(du -h "${N8N_ARCHIVE}" | cut -f1)
        log "OK : archive n8n-data creee (${N8N_SIZE})"
    else
        log "ERREUR : archive n8n-data non creee"
        exit 1
    fi
else
    log "ATTENTION : ${N8N_DATA_DIR} introuvable - archive vide"
    touch "${N8N_ARCHIVE}"
fi

# --- Archive caddy-data (volume Docker) ---
log "----------------------------------------------"
log "ARCHIVE CADDY-DATA (volume Docker)"
log "----------------------------------------------"

CADDY_ARCHIVE="${TMP_DIR}/caddy-data.tar.gz"

# Caddy-data est un volume Docker nomme, pas un dossier direct
# On utilise un container temporaire pour l'archiver
log "Extraction du volume Docker veillegrc-caddy-data..."
if docker run --rm \
    -v veillegrc-caddy-data:/data:ro \
    -v "${TMP_DIR}:/backup" \
    alpine \
    tar -czf /backup/caddy-data.tar.gz -C /data . 2>&1 | tee -a "${LOG_FILE}"; then

    if [ -f "${CADDY_ARCHIVE}" ]; then
        CADDY_SIZE=$(du -h "${CADDY_ARCHIVE}" | cut -f1)
        log "OK : archive caddy-data creee (${CADDY_SIZE})"
    else
        log "ATTENTION : archive caddy-data non creee (volume peut-etre vide)"
        touch "${CADDY_ARCHIVE}"
    fi
else
    log "ATTENTION : echec extraction caddy-data (non bloquant)"
    touch "${CADDY_ARCHIVE}"
fi

# --- Metadata du backup ---
log "----------------------------------------------"
log "CREATION FICHIER METADATA"
log "----------------------------------------------"

METADATA_FILE="${TMP_DIR}/backup-metadata.txt"

cat > "${METADATA_FILE}" << METAEOF
==========================================
VeilleGRC Backup Metadata
==========================================
Date backup     : $(date '+%Y-%m-%d %H:%M:%S %Z')
Hostname        : $(hostname)
Version script  : 1.0 (Sprint 4.1.B)

Contenu de l'archive :
- postgres-dump.sql   : dump PostgreSQL (base veillegrc)
- n8n-data.tar.gz     : donnees n8n (workflows, credentials)
- caddy-data.tar.gz   : donnees Caddy (certificats TLS)
- backup-metadata.txt : ce fichier

Etat containers au moment du backup :
$(docker compose ps 2>&1)

Version PostgreSQL :
$(docker exec veillegrc-postgres postgres --version 2>&1)

Version n8n :
$(docker exec veillegrc-n8n n8n --version 2>&1)

Taille des fichiers avant compression finale :
- postgres-dump.sql : $(du -h "${PG_DUMP_FILE}" 2>/dev/null | cut -f1)
- n8n-data.tar.gz   : $(du -h "${N8N_ARCHIVE}" 2>/dev/null | cut -f1)
- caddy-data.tar.gz : $(du -h "${CADDY_ARCHIVE}" 2>/dev/null | cut -f1)
==========================================
METAEOF

log "OK : metadata cree"

# --- Assemblage final ---
log "----------------------------------------------"
log "ASSEMBLAGE ARCHIVE FINALE"
log "----------------------------------------------"

log "Creation de ${ARCHIVE_NAME}..."
if tar -czf "${ARCHIVE_PATH}" -C "${TMP_DIR}" . 2>&1 | tee -a "${LOG_FILE}"; then
    FINAL_SIZE=$(du -h "${ARCHIVE_PATH}" | cut -f1)
    log "OK : archive finale creee - ${FINAL_SIZE}"
else
    log "ERREUR : echec creation archive finale"
    exit 1
fi

# --- Rotation (suppression des vieux backups) ---
log "----------------------------------------------"
log "ROTATION (retention ${RETENTION_DAYS} jours)"
log "----------------------------------------------"

DELETED_COUNT=0
while IFS= read -r old_backup; do
    if [ -n "${old_backup}" ]; then
        log "Suppression : $(basename "${old_backup}")"
        rm -f "${old_backup}"
        DELETED_COUNT=$((DELETED_COUNT + 1))
    fi
done < <(find "${BACKUP_DIR}" -maxdepth 1 -name "veillegrc-backup-*.tar.gz" -type f -mtime +${RETENTION_DAYS} 2>/dev/null || true)

if [ ${DELETED_COUNT} -eq 0 ]; then
    log "Aucun backup a supprimer (tous < ${RETENTION_DAYS} jours)"
else
    log "OK : ${DELETED_COUNT} ancien(s) backup(s) supprime(s)"
fi

# --- Bilan ---
log "----------------------------------------------"
log "BACKUPS PRESENTS DANS ${BACKUP_DIR}"
log "----------------------------------------------"
ls -lh "${BACKUP_DIR}"/veillegrc-backup-*.tar.gz 2>/dev/null | tee -a "${LOG_FILE}" || log "(aucun backup)"

log "=============================================="
log "BACKUP TERMINE AVEC SUCCES"
log "=============================================="
log "Archive : ${ARCHIVE_PATH}"
log "Log     : ${LOG_FILE}"

exit 0
