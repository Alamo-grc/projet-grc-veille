# Fiche de cadrage — Cas d'usage IA

**Projet :** Système de veille réglementaire et cybersécurité automatisée
**Nom de code :** VeilleGRC-Agent
**Version :** 1.0
**Date :** 2026
**Auteur :** Mounir [Nom], Consultant GRC
**Organisation :** Hedgewood Conseil (cabinet de conseil GRC, scénario d'illustration)
**Statut :** Draft v1 — à valider

---

## 1. Contexte et enjeu

Hedgewood Conseil est un cabinet de conseil en Gouvernance, Risque et Conformité (12 consultants, Paris) accompagnant des PME et ETI françaises sur les domaines cybersécurité, RGPD, ISO 27001, NIS2, AI Act et DORA. La veille réglementaire et cyber est aujourd'hui réalisée manuellement par chaque consultant, ce qui présente plusieurs limites :

- Temps consultant non facturable consacré à la veille (~3h/semaine/consultant, soit ~36h/semaine au total)
- Couverture inégale des sources et risque d'angle mort sur des publications critiques
- Difficulté à produire des livrables de veille standardisés et capitalisables
- Absence d'un dispositif d'alerte rapide pour les évolutions critiques

Le cabinet souhaite industrialiser sa fonction veille via un système d'agents IA, avec deux objectifs : (1) usage interne pour les consultants ; (2) à terme, proposition d'un service de veille managée aux clients.

## 2. Objectifs

### Objectifs métier
- Réduire de 70 % le temps consultant consacré à la veille brute
- Garantir une couverture exhaustive des sources réglementaires françaises et européennes pertinentes
- Produire un digest hebdomadaire structuré et un système d'alertes temps réel pour les sujets critiques
- Constituer une base de connaissances capitalisable (historique des publications, synthèses, tendances)

### Objectifs techniques
- Mettre en place un système semi-autonome d'agents IA orchestrés
- Garantir la traçabilité de chaque action et décision de l'IA
- Maintenir un coût d'exploitation maîtrisé (cible : < 30 €/mois en API)
- Permettre une supervision humaine effective (validation avant diffusion)

## 3. Périmètre fonctionnel

### Inclus
- Ingestion automatisée de sources publiques (RSS, pages web publiques, API ouvertes)
- Classification thématique (RGPD, cyber, AI Act, NIS2, DORA, ISO 27xxx, etc.)
- Détection de doublons et regroupement de sources sur un même sujet
- Scoring de criticité (faible / moyenne / élevée / critique)
- Synthèse multi-sources avec citation systématique des sources
- Génération d'un digest hebdomadaire (format email + archive)
- Alertes temps réel pour les items de criticité élevée ou critique
- Dashboard de supervision et de pilotage
- Validation humaine du digest avant diffusion (mode semi-autonome)

### Exclus (hors périmètre v1)
- Veille sur sources fermées ou payantes
- Analyse prédictive ou recommandations stratégiques personnalisées
- Diffusion automatique aux clients finaux sans relecture consultant
- Traduction multilingue automatisée (français uniquement en v1)
- Veille sur réseaux sociaux et forums

## 4. Utilisateurs et rôles

| Rôle | Description | Droits |
|------|-------------|--------|
| Consultant GRC | Utilisateur principal, reçoit les digests et alertes | Lecture, annotation, feedback |
| Responsable veille (Mounir) | Pilote du système, valide les digests | Lecture/écriture, validation, configuration |
| Direction du cabinet | Sponsor, suit les indicateurs | Lecture du dashboard |
| DPO du cabinet | Supervise la conformité du système IA | Lecture des journaux, audit |

## 5. Cartographie des données

| Type de donnée | Source | Sensibilité | Base légale (si DCP) |
|---|---|---|---|
| Articles, publications réglementaires | Sources publiques (CNIL, ANSSI, ENISA, EUR-Lex, CERT-FR, NIST, presse spécialisée) | Publique | N/A |
| Synthèses générées par l'IA | Production interne | Interne | N/A |
| Adresses email des destinataires (consultants) | Annuaire interne | Données personnelles professionnelles | Intérêt légitime |
| Logs d'utilisation et feedbacks | Production interne | Interne | Intérêt légitime |

**Note :** Le système ne traite pas de données personnelles sensibles. Les seules données personnelles concernent les destinataires internes du digest.

## 6. Décisions prises par l'IA vs par l'humain

| Décision | IA seule | IA + validation humaine | Humain seul |
|---|---|---|---|
| Sélection des sources à ingérer | | | ✅ |
| Classification thématique d'un article | ✅ | | |
| Détection de doublons | ✅ | | |
| Scoring de criticité | ✅ | | |
| Génération de la synthèse | ✅ | | |
| Diffusion du digest aux destinataires | | ✅ | |
| Émission d'une alerte critique | | ✅ | |
| Modification du périmètre des sources | | | ✅ |
| Réponse à un client externe | | | ✅ |

**Principe directeur :** toute action ayant un impact externe (envoi de communication, alerte) requiert une validation humaine en v1. L'autonomie complète n'est envisagée qu'après une période d'observation d'au moins 3 mois et sur indicateurs de fiabilité validés.

## 7. Classification AI Act (Règlement UE 2024/1689)

**Niveau de risque évalué : Risque limité**

Justification :
- Le système n'est pas listé en Annexe III (risque élevé)
- Il n'effectue pas de notation sociale, de reconnaissance biométrique, ni de décision affectant l'accès à l'emploi, au crédit, à l'éducation ou aux services essentiels
- Il s'agit d'un outil d'aide à la décision pour des professionnels, sans effet juridique direct sur des personnes
- L'output est systématiquement supervisé par un humain avant diffusion

**Obligations applicables :**
- Transparence : indiquer clairement que les synthèses sont générées par IA
- Information des utilisateurs (consultants) sur l'usage de l'IA
- Conservation des logs et journaux d'activité
- Bonnes pratiques de la Charte volontaire AI Act recommandées

## 8. Architecture cible (vue haut niveau)

```
[Sources web / RSS]
        │
        ▼
[Ingestion n8n] ──► [Stockage PostgreSQL]
        │
        ▼
[Agent classifieur (Claude Haiku)] ──► [Classification + scoring]
        │
        ▼
[Agent synthétiseur (Claude Sonnet)] ──► [Synthèse + citations]
        │
        ▼
[Validation humaine] ──► [Diffusion email / Dashboard]
        │
        ▼
[Logs + métriques] ──► [Dashboard de supervision]
```

## 9. Risques identifiés (synthèse — détail dans le registre des risques)

| ID | Risque | Impact | Probabilité | Traitement |
|---|---|---|---|---|
| R1 | Hallucination de l'IA (information inventée) | Élevé | Moyenne | Citation obligatoire des sources, validation humaine |
| R2 | Source non fiable ingérée | Moyen | Faible | Liste blanche de sources, scoring de fiabilité |
| R3 | Indisponibilité de l'API Claude | Moyen | Faible | Mode dégradé, file d'attente, fallback |
| R4 | Dépassement budget API | Faible | Moyenne | Plafond mensuel, alertes, modèle économique par tâche |
| R5 | Fuite de données dans les prompts | Faible | Faible | Pas de DCP dans les prompts, ZDR si disponible |
| R6 | Biais de couverture (angle mort) | Moyen | Moyenne | Revue mensuelle des sources, indicateur de couverture |
| R7 | Prompt injection via contenu externe | Moyen | Moyenne | Sanitization, séparation contexte/instructions |
| R8 | Non-respect du droit d'auteur sur les synthèses | Moyen | Moyenne | Synthèse + citation source, jamais reproduction verbatim |

## 10. Indicateurs de pilotage (KPI / KRI)

**Performance**
- Nombre d'articles ingérés / semaine
- Nombre de doublons détectés / semaine
- Taux de validation humaine du digest sans modification (cible > 80 % à 3 mois)
- Temps moyen entre ingestion et diffusion
- Coût moyen par digest

**Risque**
- Taux d'hallucination détectée (par sondage manuel sur 10 % des items)
- Nombre d'incidents IA / mois
- Taux de disponibilité du système
- Couverture sources (vs liste de référence)

## 11. Planning et jalons

| Sprint | Durée | Livrables | Livrable gouvernance |
|---|---|---|---|
| S1 — Cadrage | 1 sem | Fiche cadrage, AIPD, politique IA, registre | Documentation complète Sprint 1 |
| S2 — Socle technique | 2 sem | n8n + PostgreSQL + ingestion RSS | Procédure d'exploitation |
| S3 — Agents IA | 2 sem | Classifieur + synthétiseur + alertes | Tests de robustesse, journal d'incidents |
| S4 — Supervision | 1 sem | Dashboard, métriques, revue | Dossier d'audit complet |

## 12. Validation

| Rôle | Nom | Date | Signature |
|---|---|---|---|
| Auteur (Responsable veille) | Mounir | | |
| Sponsor (Direction) | [À compléter] | | |
| DPO | [À compléter] | | |
| RSSI | [À compléter] | | |

---

*Ce document est le document fondateur du projet. Toute modification de périmètre majeur fait l'objet d'une revue et d'une nouvelle version.*
