# CHANGELOG — Sprint 1 (Cadrage et gouvernance)

**Sprint** : 1
**Période** : [05/05/2026 → 07/05/2026]
**Statut** : Terminé
**Livrable** : Fondations de gouvernance IA et cadrage du projet


---

## Vue d'ensemble

Le Sprint 1 a posé les **fondations de gouvernance** du projet VeilleGRC-Agent. L'objectif n'était **pas** de produire du code mais de **construire le cadre** qui rendra le projet :

- **Auditable** (traçabilité ISO 42001)
- **Conforme** (RGPD, AI Act, ISO 27001)
- **Soutenable** (politique d'usage IA, périmètre maîtrisé)
- **Démontrable** (documentation niveau audit)

Cette discipline initiale est ce qui distingue un POC IA "bricolé" d'un POC IA **professionnel et défendable**.

---

## Bilan en fin de Sprint 1

| Catégorie | Livrable |
|---|---|
| Cadrage métier | Fiche de cadrage cas d'usage |
| Sources de veille | Liste de référence (ANSSI, CNIL, CERT-FR + autres) |
| Architecture IA | ADR-001 (choix d'intégration des modèles) |
| Gouvernance IA | POL-IA-001 (politique d'usage) |
| Conformité RGPD | AIPD VeilleGRC (analyse d'impact) |
| Conformité ISO 42001 | Registre des systèmes IA |
| Opérations | Registre des dérogations + Runbook |

---

## Livrables détaillés

### 01 — Cadrage métier

#### `docs/01-cadrage/01_fiche_cadrage_cas_usage.md`
Document de cadrage du cas d'usage fictif (cabinet **Hedgewood Conseil**, 12 consultants GRC). Contient :
- Description du besoin métier
- Périmètre fonctionnel (in / out of scope)
- Profils utilisateurs cibles
- Volumétrie attendue
- Indicateurs de succès du POC

#### `docs/01-cadrage/02_liste_sources_reference.md`
Liste des sources institutionnelles surveillées :
- ANSSI (actualités, doctrine)
- CNIL (sanctions, doctrine)
- CERT-FR (avis de sécurité)
- Critères de sélection : francophones, institutionnelles, accessibles via flux RSS

#### `docs/01-cadrage/03_ADR-001_choix_integration_IA.md`
Architecture Decision Record : justification du **mode d'intégration** des modèles IA.

Choix retenu : **API directe Anthropic + orchestration n8n auto-hébergée**.
Alternatives écartées :
- Claude Managed Agents (rejeté : trop d'autonomie, contradiction avec POL-IA-001 §6)
- LangChain Python pur (rejeté : pas de visualisation pour l'auditeur)
- Plateformes SaaS clé-en-main (rejeté : souveraineté des données)

---

### 02 — Gouvernance

#### `docs/02-gouvernance/01_politique_usage_IA.md` — POL-IA-001
**Politique d'usage de l'intelligence artificielle**, document fondateur définissant les règles d'engagement avec les modèles IA :

- §1 : Périmètre d'application
- §2 : Principes directeurs (souveraineté, transparence, supervision humaine)
- §3 : Modèles autorisés et critères de sélection
- §4 : Données admises en input (sources publiques uniquement, pas de données personnelles)
- §5 : Traitement des outputs (auditabilité, validation)
- §6 : **Validation humaine systématique pour actions à impact externe**
- §7 : Gestion des incidents IA
- §8 : Périodicité de revue (annuelle minimum)

Cette politique est référencée dans la quasi-totalité des décisions techniques ultérieures.

---

### 03 — Conformité

#### `docs/03-conformite/01_AIPD_VeilleGRC.md`
**Analyse d'Impact sur la Protection des Données (AIPD)** au sens RGPD art. 35.

Conclusion : le système ne traite **pas de données personnelles au sens RGPD** dans son fonctionnement nominal (sources institutionnelles publiques uniquement). Une AIPD est néanmoins produite par **prudence** et pour **démonstration de maîtrise** :
- Description du traitement
- Évaluation de la nécessité et proportionnalité
- Évaluation des risques (très faibles)
- Mesures envisagées

Mesures notables identifiées :
- **MIA-01** : Logs d'audit de tous les appels IA
- **MIA-02** : Pondération objective et auditable
- **MIA-03** : Sources institutionnelles uniquement
- **MIA-04** : Pas d'envoi automatique sans validation humaine

#### `docs/03-conformite/02_registre_systemes_IA.md`
**Registre des systèmes IA** au sens ISO/IEC 42001:2023 §7.5.

Contient pour chaque composant IA du système :
- Identifiant unique
- Description du système
- Modèle utilisé (versionné)
- Inputs et outputs attendus
- Cas d'usage métier
- Niveau de criticité
- Mesures de mitigation

À l'issue du Sprint 3, ce registre liste 2 systèmes IA en production : le classifieur (Haiku 4.5) et le synthétiseur (Sonnet 4.6).

---

### 04 — Opérations

#### `docs/04-operations/01_registre_derogations.md`
**Registre des dérogations** au sens ISO 27001 A.5.37.

Documente les écarts assumés par rapport aux bonnes pratiques, avec :
- Identifiant DEROG-XXX
- Description de l'écart
- Justification métier
- Mesures compensatoires
- Date d'échéance pour résolution


#### `docs/04-operations/02_runbook_exploitation.md` — RUN-VEILLEGRC-001
**Runbook d'exploitation** : procédures opérationnelles pour les 4 fonctions principales :

- §1 : Démarrage / arrêt du système
- §2 : Sauvegardes et restauration
- §3 : Gestion des incidents (modèles d'alerte)
- §4 : Procédures de mise à jour
- §5 : Indicateurs (KRI) et seuils d'alerte
- §6 : Contacts et escalade

---

## Décisions techniques (DÉC) — Sprint 1


### Cadrage
- **DÉC-001** : Choix du cas d'usage (cabinet de conseil GRC fictif)
- **DÉC-002** : Périmètre des sources surveillées (FR institutionnelles)
- **DÉC-003** : Choix du nom de code (VeilleGRC-Agent)

### Architecture
- **DÉC-004** : Mode d'intégration IA = API directe + n8n auto-hébergé (cf. ADR-001)
- **DÉC-005** : Choix de la stack technique (Docker Compose, PostgreSQL 16, n8n)
- **DÉC-006** : Hébergement souverain en VM auto-hébergée (vs cloud)
- **DÉC-007** : Choix du fournisseur IA (Anthropic) + raisonnement multi-modèles

### Gouvernance et conformité
- **DÉC-008** : Approche "audit-ready by design" (la conformité ISO 42001 est intégrée dès le départ, pas ajoutée a posteriori)
- **DÉC-009** : Production d'une AIPD malgré l'absence de données personnelles (prudence + démonstration)
- **DÉC-010** : Tenue d'un registre des systèmes IA dès le Sprint 1
- **DÉC-011** : Validation humaine systématique pour outputs à impact externe (POL-IA-001 §6)

### Opérations
- **DÉC-012** : Tenue d'un registre des dérogations (ISO 27001 A.5.37)
- **DÉC-013** : Production d'un runbook d'exploitation
- **DÉC-014** : Indicateurs de performance et de risque (KPI/KRI) définis dès le cadrage
- **DÉC-015** : Périodicité de revue annuelle minimum pour POL-IA-001

---

## Pièges identifiés (PIÈGE)


- **PIÈGE-001** : [Exemple] Confusion entre AIPD (RGPD art.35) et registre des traitements (RGPD art.30)
- **PIÈGE-002** : [Exemple] Documenter un ADR sans alternatives sérieuses : un ADR sans alternative discutée n'est pas un ADR
- **PIÈGE-003** : [Exemple] Sous-estimer le poids documentaire du Sprint 1 (la rédaction prend autant de temps que la conception)
- **PIÈGE-004** : [À compléter selon ton expérience]

---

## Conformité démontrée Sprint 1

| Référentiel | Démonstration |
|---|---|
| ISO 27001 §4.3 | Périmètre de l'ISMS défini dans le cadrage |
| ISO 27001 A.5.37 | Procédures opérationnelles dans le runbook |
| ISO 42001 §4.3 | Périmètre du système d'IA défini |
| ISO 42001 §6.1 | Identification des risques liés à l'IA dans l'AIPD |
| ISO 42001 §7.5 | Registre des systèmes IA et POL-IA-001 versionnés |
| ISO 42001 §8.1 | Planification opérationnelle dans le runbook |
| RGPD art.5 | Principes documentés dans POL-IA-001 |
| RGPD art.35 | AIPD produite |
| AI Act art.50 | Transparence "généré par IA" prévue dès la conception |

---

## Prochain sprint

**Sprint 2** — Pipeline d'ingestion automatisé
- Workflow `01_Ingestion_RSS` (n8n)
- Schéma de base PostgreSQL initial (sources, articles)
- Tests de robustesse sur les 3 sources institutionnelles
- Déduplication et normalisation des articles
