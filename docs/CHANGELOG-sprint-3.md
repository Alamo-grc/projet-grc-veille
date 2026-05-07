# CHANGELOG — Sprint 3 (Pipeline IA complet)

**Sprint** : 3
**Période** : 2026-04-XX → 2026-05-07
**Statut** : Terminé
**Livrable** : Pipeline IA de bout en bout (Ingestion → Classification → Synthèse → Digest)

---

## Vue d'ensemble

Le Sprint 3 a livré le pipeline IA complet du système VeilleGRC-Agent. Trois sous-livrables ont été produits successivement :

- **Partie 1** — Classification automatique des articles ingérés (Claude Haiku 4.5)
- **Partie 2** — Synthèse rédactionnelle des articles à criticité élevée/critique (Claude Sonnet 4.6)
- **Partie 3** — Digest hebdomadaire avec architecture multi-temporelle (semaine + mois)

À l'issue du Sprint 3, le système tourne en mode automatique chaque jour ouvré (08h00 → 08h30 → 09h00) et génère un digest hebdomadaire chaque lundi à 06h00.

---

## Bilan production en fin de Sprint 3

| Métrique | Valeur |
|---|---|
| Articles ingérés (depuis 3 sources) | 70 |
| Articles classifiés (Haiku 4.5) | 70 (100%) |
| Articles synthétisés (Sonnet 4.6) | 22 (100% des candidats `elevee + score≥0.70`) |
| Citations vérifiées automatiquement | 33 / 34 (97%) |
| Premier digest généré | Semaine 19 / 2026 (12 entrées) |
| Coût classification cumulé | 0,0696 € |
| Coût synthèse cumulé | 0,1543 € |
| **Coût total Sprint 3** | **0,2239 €** |
| Plafond mensuel atteint | 2,2% (10 € disponibles) |

---

## Sprint 3 partie 1 — Classification

### Décisions techniques (DÉC)

- **DÉC-016** : Choix Claude Haiku 4.5 pour la classification (rapport coût/qualité optimal)
- **DÉC-017** : Schéma `classifications` séparé de `articles` (1 article → N classifications possibles)
- **DÉC-018** : Stockage du `claude_message_id` pour audit ISO 42001
- **DÉC-019** : Prompt PROMPT-CLASSIF-001 v1.1 (révision après tests)
- **DÉC-020** : Politique de batching n8n (1 article / 1000ms anti-rate-limit)
- **DÉC-021** : Promotion en production après validation panel

### Pièges identifiés

- **PIÈGE-005** : Variabilité du modèle entre runs (cas limite documenté pour DÉC-016)
- **PIÈGE-006** : n8n Code node — `$input.item.json` vs `$input.all()`
- **PIÈGE-007** : PostgreSQL — Cast JSONB nécessite `::jsonb`

### Bilan partie 1

70 articles classifiés, distribution finale :
- 22 elevee
- 27 moyenne
- 21 faible

---

## Sprint 3 partie 2 — Synthèse

### Décisions techniques (DÉC)

- **DÉC-026 (révisée)** : Politique de citations hybride
  Initialement "100% obligatoire" lors de la conception, révisée vers : OBLIGATOIRE pour faits spécifiques (chiffre, date, montant, nom propre, référence légale, citation directe), OPTIONNEL pour phrases de mise en contexte, REFORMULATION si le fait n'est pas citable. Cette révision réduit le taux d'hallucination tout en préservant la fluidité rédactionnelle.

- **DÉC-027** : Séparation prompt système / script d'exécution
  Le prompt est stocké dans un fichier `.txt` dédié, chargé à l'exécution via `cat`. Évite les pièges d'échappement bash et permet de versionner le prompt indépendamment du code.

- **DÉC-028** : Stratégie multi-modèles, pas de dépendance fonctionnelle spécifique
  Aucune fonctionnalité non standard à un modèle ne doit être utilisée comme dépendance forte. Le prefill assistant fonctionne sur Haiku mais pas sur Sonnet 4.6 (cf. PIÈGE-012). Approche adoptée : prompt système robuste qui force le format + nettoyage applicatif post-réponse.

- **DÉC-029** : Outil de normalisation Unicode dans les scripts shell
  Python3 plutôt que sed pour les transformations Unicode (apostrophes typographiques U+2019, espaces non-breaking U+00A0, entités HTML). Évite les pièges d'échappement bash sur les caractères multi-byte.

- **DÉC-030** : Validation du synthétiseur PROMPT-SYNTH-001 v1.0 (panel test)
  Panel : 4 articles diversifiés (CERT-FR Thunderbird, CERT-FR MISP, ANSSI NIS 2, CNIL CEPD). Résultats : 4/4 conformes (3 synthèses produites, 1 refus propre approprié), 5/5 citations vérifiées, 0 hallucination détectée.

- **DÉC-031** : Synthétiseur PROMPT-SYNTH-001 v1.0 PROMU EN PRODUCTION
  Décision basée sur les métriques de validation. Critères respectés : JSON parseable 100%, citations vérifiées 100%, refus géré 1/1, coût marginal aligné.

- **DÉC-032** : Évolution du schéma table `syntheses`
  Ajout de 8 colonnes pour stocker les outputs IA : `tldr`, `citations` (JSONB), `confiance`, `synthese_impossible`, `raison_impossible`, `claude_message_id`, `citations_verifiees`, `citations_a_verifier`. Ajout de 2 indexes : `idx_syntheses_impossible`, `idx_syntheses_valide`. Modification : `contenu_synthese` passé en nullable.

- **DÉC-033** : Settings de robustesse systématiques sur les nœuds n8n
  Activation par défaut de "Always Output Data" + "Continue On Fail" sur tous les nœuds critiques. Évite l'arrêt brutal du workflow et empêche la cascade d'échec si un seul article pose problème.

- **DÉC-034** : Validation applicative des outputs synthétiseur
  Le nœud "3. Parse + Validate + Verify" implémente : parsing défensif (try/catch), validation structurelle (champs requis), normalisation Unicode, vérification des citations contre le texte source, compteurs anti-hallucination.

- **DÉC-035** : Approche backfill manuel avant publication
  Avant publication automatique du workflow, exécution manuelle de 4 lots de 5 articles pour traiter les 22 articles candidats. Permet une validation qualité sur l'intégralité du corpus existant avant industrialisation.

- **DÉC-036** : Bilan de production Sprint 3 partie 2 (22/22 synthétisés)
  Couverture 100% des articles candidats. Aucune synthèse_impossible. 33 citations vérifiées sur 34. Coût total 0,1543 €.

- **DÉC-037** : Périmètre étendu de vérification des citations
  Modification du nœud "Parse + Validate + Verify" : vérification désormais sur `contenu + titre + url` (concaténés) au lieu de `contenu` seul. Réduit les faux positifs sur les références extraites des métadonnées (numéros d'avis CERT-FR présents dans l'URL).

### Pièges identifiés

- **PIÈGE-008** : Notepad réouvre les onglets précédents au lancement
  Risque d'exposition de secrets pendant un partage d'écran. Mitigation : fermeture explicite des onglets sensibles + suppression des fichiers `.txt` après import dans KeePass.

- **PIÈGE-009** : KeePass single point of failure
  Toute la sécurité du projet repose sur un fichier `.kdbx`. Importance critique de la sauvegarde (multi-emplacements + chiffrement supplémentaire).

- **PIÈGE-010** : Confusion shell bash vs psql
  Dans psql, les commandes bash sont rejetées comme du SQL. Repère systématique : prompt `mounir@host:~$` vs `veillegrc=>`. Sortir avec `\q` avant de coller un script bash.

- **PIÈGE-011** : Apostrophes dans des prompts shell entre simples-quotes
  L'échappement `'\''` est complexe et fragile. Une seule erreur casse silencieusement l'intégralité du script. Solution : stocker les prompts dans des fichiers externes.

- **PIÈGE-012** : Prefill assistant non supporté par Sonnet 4.6
  Erreur retournée : "This model does not support assistant message prefill". Différence avec Haiku 4.5 qui le supporte. Implication : pattern "prefill `{` pour forcer JSON" doit être remplacé par renforcement du prompt + nettoyage applicatif.

### Incidents IA (suivi ISO 42001 §10.2)

- **INCIDENT-IA-001** — Faux positif d'hallucination — RÉSOLU
  Date : 2026-05-06. Article #48 (CNIL — AIPD CEPD). Symptôme : 2 citations marquées comme absentes du texte source par le script de vérification. Investigation : faux positif causé par apostrophes typographiques (U+2019 vs U+0027) et entités HTML mal décodées (`&amp;nbsp;`). Cause racine : comparaison textuelle stricte ne tenant pas compte des variations Unicode. Action corrective : normalisation systématique du texte avant comparaison via Python3 (DÉC-029). Conformité ISO 42001 §10.2 (amélioration continue).

- **INCIDENT-IA-002** — Citation extraite de l'URL non du contenu — RÉSOLU
  Date : 2026-05-06. Article #6 (CERT-FR Linux Ubuntu). Symptôme : citation `CERTFR-2026-AVI-0495` flaggée à vérifier. Investigation : la référence n'est pas dans le contenu textuel mais bien présente dans l'URL passée à l'IA en métadonnée du prompt. Cause racine : périmètre de vérification trop restreint (contenu seul). Action corrective : extension du périmètre à `contenu + titre + url` (DÉC-037). Conformité ISO 42001 §10.2.

### Observations métier

- **OBSERVATION-001** : Concentration des sources sur les classifications "elevee"
  100% des 22 articles candidats à la synthèse viennent du CERT-FR (avis de sécurité). Les sources institutionnelles ANSSI/CNIL produisent peu de criticité élevée + score ≥ 0.70. Conséquence : le digest est majoritairement cyber. À surveiller pour éventuel rééquilibrage Sprint 4.

- **OBSERVATION-002** : Limite des flux RSS CNIL/ANSSI (résumés courts)
  Les flux RSS publient majoritairement des résumés de 100-300 caractères, pas le contenu intégral. Conséquence : les articles institutionnels génèrent souvent des refus du synthétiseur (`synthese_impossible`). Mitigation possible Sprint 4 : enrichir l'ingestion en fetchant la page complète via web scraping.

- **OBSERVATION-003** : Calibration de la confiance Sonnet sur CERT-FR
  Sonnet attribue une confiance ~0.55-0.62 sur les avis CERT-FR standards (palier "basique"). Sonnet identifie correctement que ces avis sont peu détaillés (pas de CVE explicite, pas de CVSS, description générique). Si on enrichit l'ingestion en Sprint 4, la confiance devrait monter à 0.70-0.85.

- **OBSERVATION-004** : Variabilité rédactionnelle du synthétiseur (temperature 0.2)
  Un même article peut produire des synthèses légèrement différentes entre deux runs (nombre de citations, formulation). Comportement cohérent avec le choix `temperature=0.2` documenté. Implication GRC : toute évaluation qualité doit être faite sur des échantillons multiples, pas sur un seul run.

---

## Sprint 3 partie 3 — Digest hebdomadaire

### Décisions techniques (DÉC)

- **DÉC-038** : Mode "génération automatique + dépôt fichier" pour le digest
  Décision après challenge GRC interne : le workflow génère automatiquement le digest chaque lundi 06h00, le stocke en base ET sur filesystem, MAIS n'envoie aucun email automatiquement. L'envoi effectif est à la charge de l'humain. Conformité POL-IA-001 §6 (validation humaine systématique pour actions à impact externe), ISO 42001 §9.2 (supervision humaine effective), cohérence avec ADR-001 (rejet des Managed Agents).

- **DÉC-039** : Formule de pondération du digest hebdomadaire
  Score = (poids_criticité × poids_fiabilité × poids_récence) × confiance.
  Poids criticité : critique=100, elevee=50, moyenne=20, faible=5.
  Poids fiabilité : ANSSI/CNIL/CERT-FR = 1.0, autres = 0.6.
  Poids récence : <1j=1.0, 1-3j=0.8, 4-7j=0.5, 8-14j=0.3, >14j=0.2.
  Conforme ISO 42001 §6.2 (critères de sélection algorithmique transparents).

- **DÉC-040** : Stratégie de stockage du digest HTML
  Le HTML est stocké en base (champ `contenu` de la table `digests`). Un script externe extrait à la demande le HTML sur filesystem pour relecture humaine. Évite la modification du compose Docker pour le POC. Auditabilité native (timestamp en base), atomicité préservée.

- **DÉC-041 (révisée)** : Critère temporel du digest = `date_publication`
  Décision maintenue après challenge interne. Plutôt que de bricoler le filtre vers `date_synthese` pour gonfler artificiellement le POC, on conserve le critère métier juste (`date_publication`) qui produit la bonne sémantique en régime permanent. Posture senior assumée : un POC qui démontre la rigueur > un POC artificiellement rempli.

- **DÉC-042** : Architecture digest multi-temporelle (semaine + mois)
  Suggestion utilisateur en challenge à la conception initiale. Le digest est composé de 2 sections : "Actualités de la semaine" (filtre 7j) + "Récap du mois — Top par sévérité" (filtre 8-30j, anti-doublon avec section 1). Garantit que le digest n'est jamais structurellement vide même en creux d'activité éditoriale. Reflète les patterns des newsletters cyber pro (CERT-FR, ANSSI).

### Pièges identifiés

- **PIÈGE-013** : ORDER BY après UNION en PostgreSQL
  PostgreSQL refuse les expressions dans ORDER BY après UNION/INTERSECT/EXCEPT. Seuls les noms de colonnes du SELECT final sont autorisés. Workaround : créer une colonne explicite `ordre_section` (1 ou 2) dans chaque CTE, puis trier sur cette colonne.

- **PIÈGE-014** : Copier-coller tronqué dans n8n Code Node
  n8n peut tronquer silencieusement le code JavaScript collé sur les codes longs (>200 lignes). Symptôme : "Unexpected end of input" lors de l'Execute step. Mitigation : effacer entièrement avant de recoller, ou utiliser des fichiers externes versionnés Git pour les codes longs.

- **PIÈGE-015** : Execute step ré-exécute la chaîne amont en n8n
  Cliquer sur "Execute step" sur un nœud N ré-exécute aussi les nœuds 1 à N-1. Conséquence : un INSERT placé en milieu de chaîne sera exécuté plusieurs fois pendant le développement. Mitigation : `WHERE NOT EXISTS` ou `ON CONFLICT DO NOTHING` dans les INSERT, ou désactiver provisoirement les nœuds INSERT pendant les tests aval.

---

## Hygiène projet (Git, sécurité)

- **DÉC-022** : Stratégie de publication GitHub
  Phase 1 : repo privé `Alamo-grc/projet-grc-veille`. Phase 2 (post-audit complet) : passage en public pour démonstration portfolio.

- **DÉC-023** : Hygiène de l'identité Git en amont
  Email Git configuré sur l'adresse no-reply GitHub (`281512237+Alamo-grc@users.noreply.github.com`) pour éviter d'exposer l'email personnel dans les commits publics.

- **DÉC-024** : Authentification Git via Personal Access Token (PAT)
  PAT scope minimal (`repo`), stocké dans le Credential Manager Windows + KeePass.

- **DÉC-025** : Mise en place de KeePass
  Centralisation des secrets du projet (Claude API, n8n password, PostgreSQL credentials, Git PAT). Conforme ISO 27001 A.5.17 (gestion des informations d'authentification).

---

## Itérations identifiées (à traiter Sprint 4 ou ultérieur)

- **ITÉRATION-DESIGN-01** : Enrichissement visuel du digest HTML
  Style éditorial, hiérarchie visuelle, sommaire cliquable, branding Hedgewood. Priorité faible.

- **ITÉRATION-CONTENU-01** : Fetch du contenu complet pour articles RSS courts (cf. OBSERVATION-002)
  Web scraping ciblé sur les pages CNIL/ANSSI/CERT-FR pour récupérer le contenu intégral. Bénéfice attendu : montée du score de confiance Sonnet de 0.55-0.62 vers 0.70-0.85.

- **ITÉRATION-INFRA-01** : HTTPS via reverse proxy (clôture DEROG-001)
  Mise en place Caddy ou Traefik devant n8n pour TLS automatique.

- **ITÉRATION-OPS-01** : Notifications d'erreur Slack/email
  Workflow de monitoring n8n pour alerter en cas d'échec d'un workflow planifié.

- **ITÉRATION-OPS-02** : Sauvegardes automatiques quotidiennes
  Dump PostgreSQL + sauvegarde n8n-data, rétention 7 jours minimum.

---

## Conformité démontrée Sprint 3

| Référentiel | Démonstration |
|---|---|
| ISO 27001 A.5.17 | Gestion des secrets via KeePass |
| ISO 27001 A.5.37 | Procédures opérationnelles documentées (workflows + runbook) |
| ISO 42001 §6.2 | Critères de sélection algorithmique transparents et auditables |
| ISO 42001 §7.5 | Traçabilité des artefacts IA (claude_message_id, tokens, coûts) |
| ISO 42001 §8.1 | Prompts versionnés comme artefacts de configuration |
| ISO 42001 §8.4 | Validation des outputs IA opérationnelle (97%) |
| ISO 42001 §9.2 | Supervision humaine effective (digest non auto-envoyé) |
| ISO 42001 §10.2 | Gestion des incidents IA (2 incidents résolus avec amélioration continue) |
| RGPD art.5 | Sources institutionnelles uniquement, pas de données personnelles dans le pipeline |
| AI Act art.50 | Mention "généré par IA" dans le digest (transparence) |

---

## Livrables produits

### Code et configurations
- `prompts/02_synthetiseur_v1.0.md` (prompt système versionné)
- `workflows/n8n/02_Classification_articles.json` (export workflow)
- `workflows/n8n/03_Synthese_articles.json` (export workflow)
- `workflows/n8n/04_Digest_hebdo.json` (export workflow)

### Schéma de base
- Table `classifications` (créée Sprint 3.1)
- Table `syntheses` étendue (DÉC-032 : +8 colonnes, +2 indexes)
- Table `digests` étendue (+6 colonnes pour mode "génération auto + dépôt")

### Documentation
- `docs/CHANGELOG-sprint-3.md` (ce fichier)
- README.md mis à jour (statut Sprint 3 ✅)

### Production
- 70 articles ingérés
- 70 articles classifiés
- 22 articles synthétisés
- 1 digest hebdomadaire généré (S19/2026)

---

## Prochain sprint

**Sprint 4** — Renforcement et maturité
- Enrichissement RSS (fetch contenu complet)
- HTTPS via reverse proxy
- Notifications d'erreur
- Sauvegardes automatiques
- Tests prompt injection
- Préparation passage du repo en public
