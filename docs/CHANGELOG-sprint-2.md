# CHANGELOG — Sprint 2 (Ingestion RSS automatisée)

**Sprint** : 2
**Période** : [06/05/2026]
**Statut** : Terminé
**Livrable** : Pipeline d'ingestion RSS automatisée avec stockage et déduplication


---

## Vue d'ensemble

Le Sprint 2 a livré le **socle d'ingestion** du système VeilleGRC-Agent. Sur la base des fondations de gouvernance posées au Sprint 1, ce sprint a construit la première brique opérationnelle :

- Schéma PostgreSQL initial (sources + articles)
- Workflow d'ingestion automatisée (n8n) sur les 3 sources institutionnelles
- Déduplication des articles
- Mécanismes de robustesse face aux changements d'URL des sources

À l'issue du Sprint 2, le système ingère automatiquement les nouveautés RSS chaque jour à 08h00 et stocke les articles en base avec leurs métadonnées normalisées.

---

## Bilan en fin de Sprint 2

| Métrique | Valeur |
|---|---|
| Sources surveillées | 3 (ANSSI, CNIL, CERT-FR) |
| Articles ingérés (état initial) | 70 |
| Workflow déployé | `01_Ingestion_RSS` (publié) |
| Tables PostgreSQL créées | `sources`, `articles` (+ index) |
| Fréquence d'ingestion | Quotidienne 08h00 |
| Incidents sources résolus | 2 (changements d'URL ANSSI + CNIL) |

---

## Livrables détaillés

### Schéma de base

#### Table `sources`
Catalogue des sources surveillées avec leur configuration :
- `id`, `code` (ex: FR-CERT-01), `nom`
- `url_rss` (URL du flux RSS)
- `fiabilite` (étoiles 1-5)
- `actif` (booléen)
- `date_creation`, `date_derniere_ingestion`

À l'issue du Sprint 2, 3 lignes :
- `FR-CERT-01` : CERT-FR — Avis et alertes
- `FR-ANSSI-01` : ANSSI — Actualités
- `FR-CNIL-01` : CNIL — Actualités

#### Table `articles`
Stockage des articles ingérés :
- `id`, `source_id` (FK), `external_id` (clé de déduplication)
- `titre`, `url`, `contenu`
- `date_publication`, `date_ingestion`
- `statut` (ingested, classified, etc.)

Index notables :
- `idx_articles_source` (FK)
- `idx_articles_external_id` (déduplication)
- `idx_articles_date_publication` (filtre temporel)

---

### Workflow `01_Ingestion_RSS`

Premier workflow opérationnel du système. Architecture typique :

```
[Schedule Trigger - Daily 08h00]
        ↓
[Get sources actives]            (Postgres)
        ↓
[RSS Read - per source]          (n8n RSS node)
        ↓
[Normalisation des champs]       (Code JS)
        ↓
[Déduplication via external_id]  (filtre + WHERE NOT EXISTS)
        ↓
[Insert articles]                (Postgres)
```

Settings appliqués sur chaque nœud :
- `Always Output Data` : ON
- `Continue On Fail` : ON

---

## Décisions techniques (DÉC) — Sprint 2


### Architecture de données
- **DÉC-016** : Schéma `sources` séparé de `articles` (1 source → N articles, normalisation)
- **DÉC-017** : Clé de déduplication = `external_id` (URL ou ID natif du flux RSS) plutôt que hash du contenu
- **DÉC-018** : Stockage du contenu RSS brut tel quel (pas de transformation lors de l'ingestion)
- **DÉC-019** : Type `text` pour le contenu (pas de limite de taille a priori)

### Politique d'ingestion
- **DÉC-020** : Fréquence d'ingestion quotidienne (08h00)
  Justification : équilibre entre fraîcheur de la veille et charge sur les sources.
- **DÉC-021** : Statut initial `ingested` à la création (workflow ultérieur reclassera)
- **DÉC-022** : Pas de fallback vers d'autres formats si RSS échoue (Sprint 4 : ajout web scraping)

### Robustesse
- **DÉC-023** : Tolérance aux erreurs : si UNE source échoue, les autres continuent (Continue On Fail)
- **DÉC-024** : Toute mise à jour d'URL d'une source nécessite validation du Responsable veille
  Justification : éviter qu'une source malveillante ne soit ajoutée par erreur ou compromission.

### Gouvernance
- **DÉC-025** : Conservation des logs n8n pour audit (cf. POL-IA-001, runbook §5)

---

## Pièges identifiés (PIÈGE)


- **PIÈGE-001** : Format `external_id` non standard entre sources
  Certaines sources fournissent un `<guid>` cohérent dans le RSS, d'autres l'omettent. Mitigation : fallback sur l'URL si `<guid>` absent.

- **PIÈGE-002** : Encodage HTML dans le contenu RSS
  Les flux contiennent des entités HTML mal échappées (`&amp;nbsp;`, `&amp;amp;`). Conservation du brut côté ingestion, normalisation reportée au Sprint 3.

- **PIÈGE-003** : Dates de publication au format hétérogène entre sources
  RFC 822, ISO 8601, et variantes. Mitigation : parsing tolérant lors du normalisation.

- **PIÈGE-004** : URLs RSS instables sur le long terme
  Les éditeurs réorganisent leurs sites sans rétrocompatibilité (cf. INCIDENT-INGEST-001 et 002).

---

## Incidents et résolutions

### INCIDENT-INGEST-001 — Mise à jour source FR-CNIL-01
**Date** : 2026-05-05
**Symptôme** : RSS Read node retourne status code 404
**Cause** : la CNIL a réorganisé ses URLs RSS sur le nouveau site
**Avant** : `https://www.cnil.fr/fr/flux`
**Après** : `https://cnil.fr/fr/rss.xml`
**Détecté par** : monitoring nœud RSS Read (404)
**Action corrective** : mise à jour de la ligne `sources` correspondante en base
**Validation** : Responsable veille (cf. DÉC-024)
**Statut** : RÉSOLU

### INCIDENT-INGEST-002 — Mise à jour source FR-ANSSI-01
**Date** : 2026-05-05
**Symptôme** : HTTP Request node retourne status code 404 + page HTML d'erreur
**Cause** : convention d'URL différente sur le nouveau domaine cyber.gouv.fr
**Avant** : `https://cyber.gouv.fr/actualites/feed`
**Après** : `https://cyber.gouv.fr/actualites/rss/`
**Détecté par** : monitoring nœud HTTP Request (404 + analyse contenu)
**Action corrective** : mise à jour de la ligne `sources` correspondante en base
**Validation** : Responsable veille (cf. DÉC-024)
**Statut** : RÉSOLU

> Ces deux incidents ont validé la pertinence du **mécanisme de validation Responsable veille** (DÉC-024) avant toute modification de source.

---

## Observations métier


- **OBSERVATION-001** : Les flux RSS institutionnels FR sont peu détaillés (résumés courts). Cette observation sera confirmée et documentée plus précisément au Sprint 3 (cf. OBSERVATION-002 du Sprint 3).

- **OBSERVATION-002** : La fragilité des URLs RSS sur le long terme justifie un **monitoring actif** (alerte sur 404 répété). À traiter en Sprint 4.

---

## Conformité démontrée Sprint 2

| Référentiel | Démonstration |
|---|---|
| ISO 27001 A.5.10 | Classification de l'information (sources publiques uniquement) |
| ISO 27001 A.5.37 | Procédures opérationnelles d'ingestion documentées |
| ISO 42001 §7.5 | Sources versionnées en base avec horodatage |
| ISO 42001 §8.1 | Planification opérationnelle (workflow déployé) |
| RGPD art.5 | Sources institutionnelles publiques uniquement |
| RGPD art.30 | Registre des activités de traitement (sources tracées en base) |

---

## Livrables produits

### Code et configurations
- `workflows/n8n/01_Ingestion_RSS.json` (export workflow)

### Schéma de base
- Table `sources` (3 lignes initiales)
- Table `articles` (70 lignes à l'issue du Sprint)
- Indexes de performance et déduplication

### Documentation
- `docs/CHANGELOG-sprint-2.md` (ce fichier)
- Mise à jour du runbook pour la procédure d'ajout/modification de source

### Production
- Workflow `01_Ingestion_RSS` en production (publié)
- 70 articles ingérés depuis 3 sources
- 2 incidents sources résolus avec validation humaine

---

## Prochain sprint

**Sprint 3** — Pipeline IA complet
- Sprint 3.1 : Classification automatique (Haiku 4.5)
- Sprint 3.2 : Synthèse rédactionnelle (Sonnet 4.6)
- Sprint 3.3 : Digest hebdomadaire avec validation humaine
