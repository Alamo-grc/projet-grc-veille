# Politique d'usage de l'Intelligence Artificielle

**Référence :** POL-IA-001
**Version :** 1.0
**Date d'entrée en vigueur :** 2026
**Propriétaire :** Direction de Hedgewood Conseil
**Validation :** Direction, RSSI, DPO
**Périodicité de revue :** Annuelle ou à toute évolution réglementaire majeure
**Diffusion :** Tous collaborateurs, sous-traitants intervenant pour le compte du cabinet

---

## 1. Objet et champ d'application

### 1.1 Objet
La présente politique définit les règles, principes et responsabilités encadrant l'usage de systèmes d'intelligence artificielle (ci-après « IA ») au sein de Hedgewood Conseil. Elle vise à garantir un usage de l'IA éthique, sûr, conforme aux réglementations applicables, et aligné avec les valeurs et engagements du cabinet envers ses clients.

### 1.2 Champ d'application
Cette politique s'applique :
- À l'ensemble des collaborateurs, stagiaires, alternants et sous-traitants du cabinet
- À tous les systèmes d'IA développés en interne, intégrés depuis des fournisseurs tiers, ou utilisés en mode SaaS
- À tous les usages professionnels de l'IA, y compris les outils dits « grand public » (ChatGPT, Gemini, Claude, Copilot, etc.)

### 1.3 Référentiels applicables
- Règlement (UE) 2024/1689 dit « AI Act »
- Règlement (UE) 2016/679 dit « RGPD »
- Norme ISO/IEC 42001:2023 — Systèmes de management de l'IA
- Norme ISO/IEC 27001:2022 — Sécurité de l'information
- Recommandations CNIL sur l'IA et le RGPD
- Lignes directrices de la Commission européenne sur l'IA digne de confiance

## 2. Principes directeurs

Hedgewood Conseil s'engage à utiliser l'IA selon les sept principes de l'IA digne de confiance :

1. **Action humaine et contrôle humain** — l'humain reste décideur final sur les actions à impact externe
2. **Robustesse technique et sécurité** — les systèmes IA sont testés, surveillés, sécurisés
3. **Respect de la vie privée et gouvernance des données** — minimisation, finalité, sécurité
4. **Transparence** — les utilisateurs et destinataires sont informés des usages d'IA
5. **Diversité, non-discrimination et équité** — vigilance sur les biais
6. **Bien-être sociétal et environnemental** — usage proportionné, sobriété numérique
7. **Responsabilité et redevabilité** — chaque système IA a un propriétaire identifié

## 3. Gouvernance et responsabilités

| Rôle | Responsabilités |
|---|---|
| Direction | Sponsor, valide la politique et les arbitrages stratégiques |
| Comité IA (RSSI, DPO, Responsable veille, Direction) | Valide les nouveaux cas d'usage, suit le registre, traite les incidents |
| Responsable d'un système IA | Désigné pour chaque système, garant du cycle de vie et de la conformité |
| Utilisateurs | Respectent la présente politique, signalent les incidents, suivent les formations |
| DPO | Avis sur les traitements de données, supervise les AIPD |
| RSSI | Supervise la sécurité technique, gère les incidents de sécurité IA |

Le **Comité IA** se réunit a minima trimestriellement pour passer en revue : nouveaux cas d'usage, incidents, évolutions réglementaires, indicateurs.

## 4. Cycle de vie d'un système d'IA

Tout système d'IA mis en service au sein du cabinet suit obligatoirement les étapes suivantes :

1. **Cadrage** — fiche de cas d'usage, classification AI Act, identification des données
2. **Évaluation des risques** — analyse de risques, AIPD si données personnelles, validation Comité IA
3. **Conception et développement** — application des principes Privacy & Security by Design
4. **Tests** — fonctionnels, de robustesse, de sécurité (prompt injection, biais, hallucinations)
5. **Mise en production** — inscription au registre des systèmes IA, formation des utilisateurs
6. **Exploitation** — supervision continue, journalisation, gestion d'incidents
7. **Revue périodique** — annuelle a minima, ou à tout changement significatif
8. **Décommissionnement** — retrait du registre, archivage ou destruction des données

Aucun système IA ne peut être mis en production sans validation explicite du Comité IA.

## 5. Usages autorisés

Les usages suivants sont **autorisés** sous réserve du respect des règles spécifiques de la présente politique :

- Aide à la rédaction de documents internes (notes, comptes-rendus, supports)
- Synthèse, traduction et reformulation de documents publics ou internes non sensibles
- Recherche et veille sur sources publiques
- Aide au code, scripts d'automatisation, infrastructure
- Analyse de données non sensibles ou anonymisées
- Génération de visuels et illustrations à usage interne
- Exploration et prototypage d'idées

## 6. Usages strictement interdits

Les usages suivants sont **formellement interdits**, sans exception :

- Soumettre à un système IA grand public (ChatGPT, Gemini grand public, etc.) des données client, données personnelles, données stratégiques ou tout document confidentiel
- Soumettre à un système IA des secrets techniques (mots de passe, clés API, certificats)
- Utiliser l'IA pour produire un livrable client sans relecture humaine et mention de l'usage de l'IA
- Utiliser l'IA pour évaluer, profiler ou prendre une décision automatisée affectant une personne (recrutement, accès, scoring) sans validation préalable du Comité IA et conformité explicite à l'article 22 du RGPD
- Utiliser l'IA pour produire des contenus susceptibles de tromper (deepfakes, fausses signatures, usurpation)
- Contourner les mesures de sécurité ou les filtres d'un système IA
- Reproduire ou faire reproduire par l'IA du contenu protégé par droit d'auteur sans autorisation

Tout manquement engage la responsabilité disciplinaire du collaborateur.

## 7. Règles spécifiques de manipulation des données

### 7.1 Données strictement interdites en entrée d'un système IA externe non maîtrisé
- Données à caractère personnel (sauf consentement et base légale documentée)
- Données de santé, données sensibles au sens RGPD
- Données client soumises à confidentialité contractuelle
- Secrets d'authentification, secrets cryptographiques
- Code source propriétaire client
- Documents marqués « Confidentiel » ou « Restreint »

### 7.2 Hiérarchie d'usage
Quand une tâche peut être réalisée par IA, l'ordre de préférence est :

1. **Modèle auto-hébergé ou en environnement contrôlé** (offre Enterprise avec engagement contractuel)
2. **API d'un fournisseur avec clause de non-entraînement et engagement de conservation limitée** (par exemple offres avec « Zero Data Retention »)
3. **Service SaaS professionnel avec contrat adapté**
4. **Service grand public** — uniquement pour des données publiques ou totalement anonymisées

## 8. Transparence et information

### 8.1 Vis-à-vis des clients
- Toute prestation impliquant l'usage d'IA est mentionnée dans la proposition commerciale
- Tout livrable produit avec assistance d'IA porte la mention de l'usage de l'IA
- Les clients sont informés des sous-traitants IA mobilisés (registre fournisseurs)

### 8.2 Vis-à-vis des collaborateurs
- Information lors de l'introduction de tout nouvel outil IA dans les processus
- Formation initiale et continue sur l'usage de l'IA
- Information sur les modalités de supervision et de journalisation

### 8.3 Vis-à-vis des destinataires de communications IA-générées
- Tout email, alerte, digest généré ou assisté par IA porte une mention explicite
- Identification claire de la source : « Synthèse générée automatiquement, validée par [nom] »

## 9. Sécurité

### 9.1 Sécurité des accès
- Authentification forte sur les outils IA professionnels
- Comptes nominatifs, pas de comptes partagés
- Révocation immédiate à la sortie d'un collaborateur

### 9.2 Sécurité des données
- Chiffrement en transit (TLS 1.2 minimum)
- Chiffrement au repos pour les données stockées
- Cloisonnement des environnements (production / test / développement)
- Sauvegardes régulières et testées

### 9.3 Sécurité des modèles et prompts
- Sanitization systématique des entrées issues de sources externes
- Séparation claire entre instructions système et contenu utilisateur
- Tests réguliers de prompt injection
- Surveillance des sorties (détection de comportements anormaux)

### 9.4 Gestion des fournisseurs IA
- Évaluation de sécurité avant intégration (Due Diligence)
- Clauses contractuelles : confidentialité, non-entraînement, localisation des données, audit
- Plan de réversibilité documenté

## 10. Journalisation et traçabilité

Tout système IA mis en production journalise a minima :
- Date, heure, identifiant utilisateur
- Système IA et version utilisée
- Type d'action effectuée
- Données d'entrée (ou empreinte si volumineuses)
- Données de sortie (ou empreinte)
- Coût de l'appel (si applicable)
- Anomalies détectées

Les journaux sont conservés **12 mois minimum**, accessibles aux fonctions d'audit, et protégés en intégrité.

## 11. Gestion des incidents

### 11.1 Types d'incidents IA
- Hallucination ayant produit une information erronée diffusée
- Fuite de données via un système IA
- Comportement anormal d'un système IA (dérive, biais avéré)
- Compromission d'un compte ou d'une clé API IA
- Violation de la présente politique

### 11.2 Procédure
1. Détection et signalement immédiat au RSSI et au responsable du système
2. Qualification (gravité, impact, criticité)
3. Confinement et mesures conservatoires
4. Investigation et analyse de cause racine
5. Remédiation et plan d'action
6. Notification aux parties concernées (CNIL si DCP, clients si impactés)
7. Retour d'expérience documenté, mise à jour des procédures

Tout incident est consigné dans le **journal des incidents IA**.

## 12. Formation et sensibilisation

- Formation obligatoire à la prise de poste
- Sensibilisation annuelle à jour des évolutions réglementaires et menaces
- Module spécifique pour les responsables de systèmes IA
- Communication régulière sur les bonnes pratiques

## 13. Conformité et contrôle

- Audit interne annuel du dispositif IA
- Revue trimestrielle par le Comité IA
- Indicateurs de conformité suivis au tableau de bord
- Capacité de répondre à un audit externe (CNIL, ANSSI, autorité AI Act) sous 30 jours

## 14. Sanctions

Le non-respect de la présente politique peut donner lieu à :
- Avertissement
- Retrait des accès aux outils IA
- Sanctions disciplinaires conformément au règlement intérieur
- Engagement de responsabilité civile ou pénale en cas de manquement grave

## 15. Évolution de la politique

La présente politique fait l'objet d'une revue **a minima annuelle**, et d'une mise à jour à chaque :
- Évolution réglementaire significative (AI Act, RGPD, normes)
- Incident majeur révélant une lacune
- Changement organisationnel ou technologique majeur

---

## Annexe A — Glossaire

| Terme | Définition |
|---|---|
| IA | Système conçu pour fonctionner avec un certain niveau d'autonomie et capable de générer des sorties (prédictions, contenus, recommandations, décisions) à partir de données d'entrée |
| AIPD | Analyse d'impact relative à la protection des données |
| Hallucination | Production par un modèle d'une information factuellement fausse présentée comme vraie |
| Prompt injection | Attaque consistant à injecter des instructions malveillantes dans le contenu fourni à un modèle IA |
| Système IA à risque élevé | Système listé en Annexe III de l'AI Act, soumis à obligations renforcées |
| ZDR (Zero Data Retention) | Engagement contractuel d'un fournisseur de ne pas conserver les données d'entrée |

## Annexe B — Validation

| Rôle | Nom | Date | Signature |
|---|---|---|---|
| Auteur | Mounir [Nom] — Responsable veille | | |
| Validation RSSI | [À compléter] | | |
| Validation DPO | [À compléter] | | |
| Approbation Direction | [À compléter] | | |

---

*Document interne — Hedgewood Conseil. Diffusion contrôlée.*
