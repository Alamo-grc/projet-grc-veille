# CHANGELOG — Sprint 4 (Maturité & sécurité)

**Sprint** : 4
**Période** : 2026-08-29 → [en cours]
**Statut** : En cours
**Livrable global** : Industrialisation (HTTPS, backups, monitoring), enrichissement contenu, sécurité IA avancée, passage repo public

---

## Vue d'ensemble

Le Sprint 4 vise la **maturité opérationnelle** du système VeilleGRC-Agent, à la suite du Sprint 3 qui a livré le pipeline IA complet. Sur la base d'un système fonctionnel end-to-end, ce sprint construit :

- **Mini-Sprint 4.1** : Industrialisation (HTTPS, backups automatiques, notifications d'erreur)
- **Mini-Sprint 4.2** : Enrichissement (fetch contenu complet RSS, amélioration design digest)
- **Mini-Sprint 4.3** : Sécurité IA avancée (tests prompt injection, audit final, passage public)

À l'issue du Sprint 4, le système sera **production-ready** et le repo GitHub pourra être passé en public.

---

## Bilan intermédiaire (en cours)

| Mini-sprint | Statut | Livrable |
|---|---|---|
| **4.1.A** | ✅ Terminé | HTTPS via Caddy (DEROG-001 clôturée) |
| **4.1.B** | ✅ Terminé | Sauvegardes hebdomadaires (test manuel OK, cron corrigé, DEROG-004 documentée) |
| **4.1.C** | ⏳ À venir | Notifications d'erreur workflows n8n |
| **4.2.A** | ⏳ À venir | Fetch contenu complet articles RSS |
| **4.2.B** | ⏳ À venir | Design digest amélioré |
| **4.3.A** | ⏳ À venir | Tests prompt injection |
| **4.3.B** | ⏳ À venir | Audit final repo (secrets, PII) |
| **4.3.C** | ⏳ À venir | Passage repo GitHub en public |

---

## Sprint 4.1.A — HTTPS via Caddy ✅

**Date** : 2026-08-29
**Objectif** : Chiffrer les échanges avec n8n en TLS, isoler n8n du LAN direct, clôturer DEROG-001.

### Décisions techniques (DÉC)

- **DÉC-043** : Choix Caddy comme reverse proxy (justif : TLS auto, config simple, HTTP/3 natif)
- **DÉC-044** : Certificat auto-signé en POC (justif : VM LAN privée, pas de cas public)
- **DÉC-045** : n8n n'expose plus le port 5678 directement (`expose` au lieu de `ports`)
- **DÉC-046** : Nom d'hôte local `veillegrc.local` (résilient aux changements DHCP)
- **DÉC-047** : Clôture officielle DEROG-001 (absence HTTPS)

### Configuration technique

**Caddyfile** : `tls internal`, reverse_proxy n8n:5678, headers sécurité modernes (HSTS 1 an, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, suppression Server: Caddy).

**docker-compose.yml modifié** : ajout service caddy (ports 80/443), retrait mapping 5678 n8n, variables `N8N_PROTOCOL=https`, `WEBHOOK_URL=https://veillegrc.local/`, `N8N_EDITOR_BASE_URL=https://veillegrc.local/`, `N8N_PROXY_HOPS=1`.

### Pièges identifiés (PIÈGE)

- **PIÈGE-018** : Heredoc bash interrompu par Ctrl+C
- **PIÈGE-019** : Résolution DNS non partagée Windows/VM

### Observations métier

- **OBSERVATION-CADDY-01** : Cache HSTS Chrome tenace post-installation certif
- **OBSERVATION-INFRA-01** : IP DHCP VM change entre redémarrages

### Hygiène projet

- **HYGIÈNE-CRYPTO-01** : Masquage systématique du contenu cryptographique

### Conformité démontrée

| Référentiel | Démonstration |
|---|---|
| ISO 27001 A.5.15 | Principe de moindre privilège (n8n non exposé) |
| ISO 27001 A.8.20 | Sécurisation des réseaux (isolation Docker) |
| ISO 27001 A.8.23 | Filtrage des communications (reverse proxy) |
| ISO 27001 A.8.24 | Cryptographie standardisée (TLS 1.3, HTTP/3) |
| NIST CSF PR.DS-2 | Données en transit chiffrées |

### Livrables produits

- `infra/docker/docker-compose.yml` (modifié)
- `infra/docker/Caddyfile` (nouveau, ~2,5 Ko)
- Fichier `hosts` Windows mis à jour
- Certificat racine Caddy installé dans "Autorités racines" Windows

### Durée effective

~1h30 (avec résolution conflits Git + récupération credentials après pause de 4 mois)

---

## Sprint 4.1.B — Sauvegardes automatiques ✅

**Date** : 2026-09-04
**Objectif** : Automatiser les sauvegardes hebdomadaires PostgreSQL + n8n-data + caddy-data, avec dépôt sur partage VirtualBox vers Windows hôte.

### Décisions techniques (DÉC)

- **DÉC-048** : Sauvegardes hebdomadaires + rétention 30 jours (décision contextualisée)
  Choix : hebdo dimanche 03h00 + 30 jours (4 points de restauration).
  Justification métier :
  - Statut projet : POC personnel, non-production
  - Disponibilité VM : intermittente (souvent éteinte)
  - Volume d'activité : bas (~5-10 articles/jour)
  - Contraintes ressources : Master SSI 2026-2027 en cours
  Perte maximale acceptée : jusqu'à 7 jours entre 2 sauvegardes.
  Roadmap : POC hebdo → Pilote client quotidien → Production quotidien + 90j + offsite.
  → Documenté dans DEROG-004 (à créer au registre des dérogations)

- **DÉC-049** : Formats et stratégie backup
  - Format : tar.gz (portable, meilleur ratio compression/vitesse)
  - Auto-heal Docker : script démarre containers arrêtés avant dump
  - PostgreSQL : `pg_dump --clean --if-exists --no-owner` (cohérent sans arrêt de service)
  - n8n-data et caddy-data : copie à froid via tar
  - Metadata généré : versions, tailles, état containers

- **DÉC-050** : Planification cron backup (à finaliser)
  Ligne cron root :
  ```
  0 3 * * 0 /opt/veillegrc/scripts/backup-veillegrc.sh >> /opt/veillegrc/logs/cron-backup.log 2>&1
  ```
  Justification : dimanche 03h creux d'activité, cron root nécessaire (sudo tar sur n8n-data).

### Configuration technique

**Partage VirtualBox configuré** :
- Nom : `veillegrc-backups`
- Chemin Windows : `C:\Projets\GRC-Veille\backups`
- Point de montage VM : `/mnt/backups`
- Options : automatique, permanent, non lecture seule
- Modules vboxsf installés (`virtualbox-guest-utils`), user mounir dans groupe vboxsf

**Script backup** : `/opt/veillegrc/scripts/backup-veillegrc.sh` (9511 octets, exécutable)
- Setup strict + trap cleanup EXIT
- Vérification prérequis + auto-heal Docker
- pg_dump + tar n8n-data + container alpine pour caddy-data
- Metadata complet + rotation `find -mtime +30`
- Log complet dans `/opt/veillegrc/logs/`

**Test manuel réussi (2026-09-04 18:37)** :
- Auto-heal détecté 3 containers arrêtés → démarrage OK
- pg_dump : 180 Ko
- n8n-data : 16 Ko
- caddy-data : 4 Ko
- Archive finale : **52 Ko** dans `/mnt/backups/veillegrc-backup-20260904-1837.tar.gz`
- Fichier visible côté Windows
- Contenu validé via `tar -tzvf` : 4 fichiers OK
- Metadata auditable (dates, versions PG 16.13 / n8n 2.18.6, tailles)

### Pièges identifiés (PIÈGE)

- **PIÈGE-020** : Caractère parasite en fin de ligne cron
  Symptôme : `2>&1x` au lieu de `2>&1` (x parasite).
  Impact : redirection stderr échoue, cron silencieusement défectueux.
  Prévention : relire ligne cron avant Ctrl+O, faire `sudo crontab -l` après Ctrl+X.

### Observations infra

- **INFO-INFRA-01** : Propriété des fichiers dans partage VirtualBox
  Files owner `root:vboxsf` par défaut (normal, non anomalie).
  User mounir accède via appartenance au groupe vboxsf.

### Conformité démontrée

| Référentiel | Démonstration |
|---|---|
| ISO 27001 A.5.30 | Préparation continuité (backup + rotation formalisés) |
| ISO 27001 A.8.13 | Sauvegardes (procédure documentée, testée, tracée) |
| ISO 42001 §6.1 | Analyse de risque documentée (DÉC-048, DEROG-004) |
| RGPD art.32 | Disponibilité appropriée au niveau de service actuel |

### Livrables produits

- `/opt/veillegrc/scripts/backup-veillegrc.sh` (nouveau, exécutable)
- Configuration partage VirtualBox `veillegrc-backups`
- Modules vboxsf installés
- Test réussi archive 52 Ko

### Clôture Sprint 4.1.B (2026-09-05)

- **Cron corrigé** : `2>&1x` → `2>&1` via `sudo crontab -e`, vérifié avec `sudo crontab -l`
- **DEROG-004 documentée** dans `docs/04-operations/01_registre_derogations.md`
- **Commit + push** du dossier `scripts/` et de ce CHANGELOG

### Durée effective

~2h15 (partage VirtualBox + script backup + test manuel + correction cron)

---

## Sprint 4.1.C — Notifications d'erreur n8n (⏳ à venir)

[À documenter au fur et à mesure]

---

## Sprint 4.2.A — Fetch contenu complet RSS (⏳ à venir)

[À documenter au fur et à mesure]

---

## Sprint 4.2.B — Design digest amélioré (⏳ à venir)

[À documenter au fur et à mesure]

---

## Sprint 4.3.A — Tests prompt injection (⏳ à venir)

[À documenter au fur et à mesure]

---

## Sprint 4.3.B — Audit final repo (⏳ à venir)

[À documenter au fur et à mesure]

---

## Sprint 4.3.C — Passage repo GitHub en public (⏳ à venir)

[À documenter au fur et à mesure]

---

## Bilan final Sprint 4 (à compléter en fin de sprint)

À compléter à la fin de tous les mini-sprints avec :
- Bilan économique cumulé
- Métriques de production
- Prochain sprint envisagé
