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
| **4.1.C** | ✅ Terminé | Notifications d'erreur workflows n8n (DB + email via Brevo) |
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

## Sprint 4.1.C — Notifications d'erreur n8n ✅

**Date** : 2026-09-05
**Objectif** : Détecter et notifier automatiquement toute panne technique sur les 4 workflows de production, journaliser l'incident en base, clôturer POL-IA-001 §11 (procédure incident) côté détection technique.

### Accès infrastructure (préalable)

- **DÉC-051** : Mise en place d'un accès SSH par clé dédiée (`id_ed25519_veillegrc`, sans passphrase) depuis le poste Windows vers la VM, en remplacement de l'authentification par mot de passe interactive. Alias `veillegrc` ajouté dans `~/.ssh/config` avec l'IP à jour (192.168.1.26, DHCP avait changé depuis README).
  Justification : permet un pilotage non-interactif de la VM (Claude Code) sans jamais faire transiter le mot de passe du compte `mounir` dans une session de chat.
- **DÉC-052** : `sudo` sans mot de passe (`/etc/sudoers.d/mounir-nopasswd`) accordé à `mounir` sur la VM, cohérent avec son appartenance déjà existante au groupe `sudo`.
  Risque accepté : accès complet root depuis toute session authentifiée par la clé SSH dédiée — jugé acceptable pour une VM de POC sur LAN privé.

### Architecture retenue

Nouveau workflow **`05_Notifications_Erreur`** (Error Trigger natif n8n), configuré comme *Error Workflow* des 4 workflows de production (01 à 04) :

```
Error Trigger → Formater incident (Code) ──┬──→ Logger incident_ia (Postgres INSERT)
                                            └──→ Notifier via Brevo (HTTP Request)
```

- **Formater incident** : extrait `workflow.name`, `execution.lastNodeExecuted`, `execution.error.message` du payload natif de l'Error Trigger et les met en forme.
- **Logger incident_ia** : réutilise la table `incidents_ia` existante (créée en Sprint 3, prévue pour le journal d'incidents IA de POL-IA-001 §11) avec `type_incident='defaillance_technique'`, `detecte_par='n8n_error_workflow_automatique'`, `statut='open'`.
- **Notifier via Brevo** : appel HTTPS à l'API transactionnelle Brevo (`api.brevo.com/v3/smtp/email`), credential `HTTP Header Auth` (header `api-key`).

### Décisions techniques (DÉC)

- **DÉC-053** : Canal de notification email choisi = **API HTTP Brevo**, et non SMTP direct.
  Cause : le SMTP sortant (ports 587 *et* 465, IPv4 *et* IPv6) est bloqué de façon silencieuse entre la VM et Gmail — probablement un filtrage anti-spam de la box/FAI (diagnostiqué par comparaison : le même handshake TLS réussit depuis l'hôte Windows, échoue systématiquement depuis la VM). Basculer sur une API HTTPS (port 443 standard) contourne ce blocage sans toucher à la configuration réseau du domicile.
- **DÉC-054** : Réutilisation de la table `incidents_ia` existante plutôt que création d'une table dédiée aux pannes techniques — cohérent avec l'esprit "journal des incidents IA unifié" de POL-IA-001 §11.
- **DÉC-055** : Ajout explicite de `"onError": "stopWorkflow"` sur les nœuds critiques dépourvus de ce réglage dans les 4 workflows de production :
  - `01_Ingestion_RSS` → *Get sources actives* (lecture initiale)
  - `02_Classification_articles` → *1. Get articles non classifiés* (lecture initiale) et *4. Insert classification* (écriture finale)
  - `03_Synthese_articles` → *1. Get articles à synthétiser* (lecture initiale) et *4. Insert synthèse* (écriture finale)
  - `04_Digest_hebdo` → *Execute a SQL query* (écriture finale)
  Justification : voir PIÈGE-023 ci-dessous — sans ce réglage explicite, ces nœuds échouaient silencieusement sans jamais déclencher d'alerte. Les nœuds intrinsèquement tolérants (fetch RSS par flux, appels API Claude, upserts `ON CONFLICT`) restent en `continueRegularOutput` pour ne pas bloquer tout un lot pour un item isolé.

### Pièges identifiés (PIÈGE)

- **PIÈGE-021** : SMTP sortant bloqué silencieusement par la box/FAI, y compris en IPv6, alors que le handshake TCP réussit (`nc` reporte le port "open"). Le blocage n'apparaît qu'au niveau de la négociation TLS applicative (timeout total, aucune donnée échangée). Diagnostiqué en comparant avec un test identique réussi depuis le poste Windows hôte (même réseau, chemin différent). Voir DÉC-053.
- **PIÈGE-022** : `n8n import:workflow` désactive systématiquement le workflow importé ("Remember to activate later"), et `n8n publish:workflow` ne prend effet qu'après un redémarrage complet du conteneur n8n (`docker restart`). Prévoir ce cycle (import → publish → restart) à chaque modification de workflow en ligne de commande.
- **PIÈGE-023** : Un nœud PostgreSQL n8n **sans** `onError` explicite n'arrête PAS le workflow en cas d'erreur SQL réelle (ex : table inexistante) — il capture l'erreur et la restitue comme sortie JSON normale (`executionStatus: "success"`, erreur de niveau "warning" dans les données). Comportement contre-intuitif découvert en testant volontairement une panne sur `04_Digest_hebdo` : l'exécution était rapportée "réussie" malgré l'échec réel de la requête. Résolu via DÉC-055.
- **PIÈGE-024** : Dans le nœud HTTP Request, le champ "JSON Body" en mode expression nécessite la syntaxe complète `={{ <expression JS> }}` — un simple préfixe `=<expression>` (sans les doubles accolades) est traité comme du **texte littéral**, pas comme une expression à évaluer, ce qui produit une erreur "not valid JSON" ou envoie des `{{ }}` non résolus tels quels (voir OBSERVATION-005).
- **PIÈGE-025** : L'Error Workflow configuré sur un workflow ne se déclenche **jamais** pour une exécution manuelle ("Execute workflow" dans l'éditeur) — uniquement pour les exécutions automatiques réelles (schedule, webhook, trigger). Le test de bout en bout du circuit d'alerte a donc été fait en exécutant directement `05_Notifications_Erreur` (avec un Manual Trigger temporaire), plutôt qu'en cascade depuis un workflow de production.

### Observations (OBSERVATION)

- **OBSERVATION-005** : Brevo réécrit silencieusement l'adresse d'expéditeur technique vers un domaine générique (`*.brevosend.com`) lorsque le domaine de l'expéditeur déclaré (ici `gmail.com`, un domaine "Freemail") ne peut pas être authentifié DKIM/DMARC par un tiers relais. Le dashboard Brevo signale ce cas ("Le domaine Freemail n'est pas recommandé"). Sans incidence bloquante pour ce POC (delivery confirmée après correction du template), mais à surveiller : pour une exploitation réelle, un domaine propre avec DKIM/DMARC configurés serait recommandé.

### Test réalisé

Test de bout en bout en 2 temps (voir PIÈGE-025) :
1. Provocation d'une vraie erreur SQL sur `04_Digest_hebdo` (table cible temporairement renommée) → confirmation que l'exécution passe bien en statut `error` une fois `onError: stopWorkflow` appliqué (DÉC-055).
2. Exécution directe de `05_Notifications_Erreur` (Manual Trigger temporaire → Formater incident) → vérifications :
   - Ligne insérée dans `incidents_ia` (id=1, `type_incident=defaillance_technique`, `statut=open`)
   - Email reçu sur l'adresse du responsable veille via Brevo (`Envoyé` → `Délivré` confirmé dans le dashboard Brevo Temps réel)

Nettoyage post-test : requête SQL originale restaurée sur `04_Digest_hebdo`, Manual Trigger temporaire retiré de `05_Notifications_Erreur`, tous les workflows republiés et actifs.

### Conformité démontrée

| Référentiel | Démonstration |
|---|---|
| POL-IA-001 §11 | Détection et journalisation automatique des incidents techniques (étape 1 de la procédure) |
| ISO 27001 A.5.24 | Planification de la gestion des incidents de sécurité (détection outillée) |
| ISO 27001 A.5.26 | Réponse aux incidents (alerte immédiate au responsable du système) |
| ISO 42001 §8.1 | Procédures opérationnelles documentées pour les défaillances du système IA |

### Livrables produits

- `workflows/n8n/05_Notifications_Erreur.json` (nouveau workflow — adresse email remplacée par un placeholder `responsable-veille@exemple.com` dans le repo public ; l'instance n8n déployée utilise la vraie adresse, configurée directement en base, pas via Git)
- `workflows/n8n/01_Ingestion_RSS.json`, `02_Classification_articles.json`, `03_Synthese_articles.json`, `04_Digest_hebdo.json` (mis à jour : `settings.errorWorkflow` + `onError` explicite sur nœuds critiques)
- Compte Brevo configuré (expéditeur vérifié, clé API)
- Accès SSH par clé + sudo sans mot de passe sur la VM (outillage, hors périmètre applicatif)

### Durée effective

~2h30 (diagnostic réseau SMTP, itérations sur le format JSON Body, découverte et correction du comportement onError par défaut)

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
