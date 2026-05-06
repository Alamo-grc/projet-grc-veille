# 🛡️ VeilleGRC-Agent

> **Système d'agents IA pour la veille réglementaire et cybersécurité — POC GRC**

Pipeline automatisé d'ingestion, classification et synthèse de la veille **gouvernance, risque et conformité** (CNIL, ANSSI, CERT-FR), construit avec une approche de **gouvernance IA conforme ISO 42001** et **principes RGPD/AI Act**.

[![Statut](https://img.shields.io/badge/statut-POC-blue)]()
[![Sprints](https://img.shields.io/badge/sprints-1--3-green)]()
[![Modèle IA](https://img.shields.io/badge/modèle-Claude%20Haiku%204.5-purple)]()
[![Conformité](https://img.shields.io/badge/conformité-ISO%2042001%20%7C%20ISO%2027001%20%7C%20RGPD-orange)]()

---

## 🎯 Contexte et objectifs

Ce projet simule la mise en œuvre, dans un cabinet de conseil GRC fictif (**Hedgewood Conseil**, 12 consultants), d'un système d'agents IA pour **industrialiser la veille réglementaire et cyber** :

- **Usage interne** : alimenter les consultants en informations qualifiées et hiérarchisées
- **Usage commercial** : digest hebdomadaire vendu en service à valeur ajoutée

**Différenciateur** : la conception **intègre dès l'origine** les exigences de gouvernance IA (ISO 42001), de protection des données (RGPD, AIPD) et de cybersécurité (ISO 27001), démontrant qu'un système IA peut être conçu **audit-ready** sans surcoût significatif.

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│  VM Ubuntu 24.04 — IP 192.168.1.18 (auto-hébergée, souveraine)  │
│                                                                   │
│   ┌────────────────────────┐    ┌─────────────────────────┐     │
│   │  n8n (orchestrateur)   │◄──►│  PostgreSQL 16          │     │
│   │  Workflows :           │    │  Tables :               │     │
│   │  ├─ 01_Ingestion_RSS   │    │  ├─ sources             │     │
│   │  ├─ 02_Classification  │    │  ├─ articles            │     │
│   │  └─ 03_Synthese (WIP)  │    │  ├─ classifications     │     │
│   └───────────┬────────────┘    │  ├─ syntheses           │     │
│               │                  │  ├─ digests             │     │
│               ▼                  │  └─ incidents_ia        │     │
│   ┌────────────────────────┐    └─────────────────────────┘     │
│   │  API Anthropic Claude  │                                     │
│   │  ├─ Haiku 4.5 (classif)│                                     │
│   │  └─ Sonnet 4.6 (synth) │                                     │
│   └────────────────────────┘                                     │
└──────────────────────────────────────────────────────────────────┘

Sources surveillées :
  • CERT-FR (avis de sécurité)    → 40 articles ingérés
  • ANSSI (actualités, doctrine)  → 20 articles ingérés
  • CNIL (sanctions, doctrine)    → 10 articles ingérés
                                    ─────────────────────
                                  → 70 articles classifiés
```

---

## 📊 État du projet

| Sprint | Description | Statut |
|---|---|---|
| **Sprint 1** | Gouvernance et documentation cadre | ✅ Complété |
| **Sprint 2** | Pipeline d'ingestion RSS automatisé | ✅ Complété, en production |
| **Sprint 3.1** | Agent classifieur (Claude Haiku 4.5) | ✅ Complété, en production |
| **Sprint 3.2** | Agent synthétiseur (Claude Sonnet 4.6) | 🚧 En conception |
| **Sprint 3.3** | Digest hebdomadaire avec validation humaine | 📋 Planifié |
| **Sprint 4** | Industrialisation (HTTPS, monitoring, sauvegardes) | 📋 Planifié |

### Métriques actuelles

- **70 articles** ingérés et classifiés automatiquement
- **8 thématiques** GRC actives sur les 12 du référentiel
- **Coût d'exploitation** : ~0,001 €/article classifié
- **Disponibilité du pipeline** : 95%+ (depuis activation Sprint 2)

---

## 📚 Documentation

### 📁 Cadrage (`docs/01-cadrage/`)
- [Fiche de cadrage du cas d'usage](docs/01-cadrage/01_fiche_cadrage_cas_usage.md) — DOC-CADR-001
- [Liste de référence des sources](docs/01-cadrage/02_liste_sources_reference.md) — REF-SOURCES-001
- [ADR-001 : choix d'intégration IA](docs/01-cadrage/03_ADR-001_choix_integration_IA.md) — analyse comparative API Messages vs Agent SDK vs Managed Agents

### 📁 Gouvernance (`docs/02-gouvernance/`)
- [Politique d'usage de l'IA](docs/02-gouvernance/01_politique_usage_IA.md) — POL-IA-001 — **7 principes IA digne de confiance**

### 📁 Conformité (`docs/03-conformite/`)
- [AIPD — Analyse d'impact](docs/03-conformite/01_AIPD_VeilleGRC.md) — AIPD-VeilleGRC-001
- [Registre des systèmes IA](docs/03-conformite/02_registre_systemes_IA.md) — REG-IA-001 — **18 sections, conforme ISO 42001**

### 📁 Opérations (`docs/04-operations/`)
- [Registre des dérogations](docs/04-operations/01_registre_derogations.md) — REG-DEROG-001
- [Runbook d'exploitation](docs/04-operations/02_runbook_exploitation.md) — RUN-VEILLEGRC-001

### 📁 Prompts (`prompts/`)
- [Prompt système — Classifieur v1.1](prompts/01_classifieur_v1.1.md) — PROMPT-CLASS-001 — **versionné comme un artefact de configuration**

### 📁 Workflows (`workflows/n8n/`)
- [01_Ingestion_RSS.json](workflows/n8n/01_Ingestion_RSS.json) — pipeline d'ingestion 8 nœuds

### 📁 Changelogs (`docs/`)
- [CHANGELOG Sprint 2](docs/CHANGELOG-sprint-2.md) — décisions, pièges, apprentissages
- [CHANGELOG Sprint 3](docs/CHANGELOG-sprint-3.md) — décisions, pièges, apprentissages

---

## 🛡️ Conformité et gouvernance

Ce projet a été conçu en intégrant **dès le début** les exigences des référentiels suivants :

### ISO/IEC 42001:2023 — Management des systèmes IA
- ✅ Politique IA documentée (POL-IA-001)
- ✅ Registre des systèmes IA (REG-IA-001)
- ✅ Versioning des prompts comme artefacts de configuration (clause 7.5)
- ✅ Validation des outputs IA avant déploiement (clause 8.4)
- ✅ Procédures opérationnelles documentées (clause 8.1)

### ISO/IEC 27001:2022 — SMSI
- ✅ Procédures d'exploitation documentées (A.5.37)
- ✅ Gestion des informations d'authentification (A.5.17)
- ✅ Cloisonnement des comptes applicatifs vs administration (A.5.15)
- ✅ Inventaire et gestion des dérogations (REG-DEROG-001)

### RGPD
- ✅ AIPD réalisée (méthodologie CNIL, intérêt légitime documenté)
- ✅ Aucune donnée à caractère personnel transmise à l'API IA
- ✅ Minimisation des données (seuls les contenus publics sont traités)

### AI Act (Règlement UE 2024/1689)
- ✅ Système classé en **risque limité**
- ✅ Transparence assurée (mention "généré par IA" sur les digests)
- ✅ Supervision humaine systématique (POL-IA-001 §6)

---

## 💡 Compétences démontrées

Ce projet illustre une approche **end-to-end** combinant :

### Gouvernance & Conformité
- Rédaction de politique IA, AIPD, runbook, ADR
- Application des référentiels ISO 27001, ISO 42001, RGPD, AI Act
- Traçabilité des décisions (24+ décisions formalisées)
- Capitalisation des pièges techniques (réflexe d'amélioration continue)

### Architecture technique
- Conception d'architecture auto-hébergée et souveraine
- Déploiement Docker Compose (n8n + PostgreSQL)
- Schéma relationnel optimisé pour la veille
- Versioning des configurations (Git, prompts comme code)

### Prompt engineering
- Conception de prompts structurés avec référentiels fermés
- Validation pré-production sur panel de référence
- Gestion d'erreurs et cas limites (`classification_error`)
- Forçage de format JSON via prefill assistant

### DevSecOps
- Cloisonnement des credentials (compte applicatif vs admin)
- Audit de secrets avant publication GitHub
- Variables d'environnement vs secrets en dur
- `.gitignore` rigoureux

### Pilotage
- Tableaux de bord SQL (KPI, KRI, coûts)
- Suivi budgétaire des appels IA
- Démarche par sprints avec livrables traçables

---

## 🚀 Démarrage rapide (pour reproduire l'environnement)

⚠️ **Ce projet est un POC pédagogique**. La reproduction nécessite :

### Prérequis
- VM Linux (Ubuntu 24.04 recommandé)
- Docker et Docker Compose
- Compte Anthropic API avec crédit (~5 € suffisent pour reproduire)
- 16 Go de RAM, 50 Go de disque

### Étapes
1. Cloner ce repo sur la VM
2. Créer le fichier `.env` à partir d'un modèle (à venir)
3. `docker compose up -d` pour lancer la stack
4. Importer les workflows n8n depuis `workflows/n8n/`
5. Configurer le credential Anthropic API dans n8n
6. Activer les workflows

📖 **Voir le runbook complet** : [docs/04-operations/02_runbook_exploitation.md](docs/04-operations/02_runbook_exploitation.md)

---

## 🗺️ Roadmap

### Sprint 3 — Suite (en cours)
- [ ] Agent synthétiseur avec Claude Sonnet 4.6
- [ ] Validation panel pour le synthétiseur
- [ ] Digest hebdomadaire avec pondération criticité × fiabilité
- [ ] Validation humaine avant envoi (human-in-the-loop)

### Sprint 4 — Industrialisation
- [ ] Reverse proxy HTTPS (Traefik) — clôture DEROG-001
- [ ] Notifications d'erreur (Slack/email)
- [ ] Sauvegardes automatiques quotidiennes
- [ ] Monitoring des sources (alerte si pas d'ingestion 7+ jours)
- [ ] Tests de prompt injection

### Évolutions envisagées
- Élargissement des sources (EDPB, ENISA, autorités MENA)
- Multi-langue (anglais, arabe pour différenciation marché MENA)
- Interface de validation humaine dédiée
- Export vers outils bureautiques (Word, Excel)

---

## 📝 Licence

Ce projet est actuellement en mode **privé**. Une licence sera définie lors du passage en mode public.

---

## 👤 Auteur

**Mounir [Nom]** — Consultant en transition vers la GRC freelance
- Spécialisations : ISO 27001, ISO 42001, RGPD, AI Act
- Cibles géographiques : France, Suisse, MENA
- LinkedIn : [À compléter]

---

## 🙏 Remerciements

- **Anthropic** pour l'API Claude (Haiku 4.5, Sonnet 4.6)
- **n8n** pour l'orchestrateur workflow open-source
- **CNIL, ANSSI, CERT-FR** pour la qualité de leurs publications utilisées comme sources de référence

---

*Dernière mise à jour : 2026-05-06*
