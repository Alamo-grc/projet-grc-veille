# CHANGELOG — Sprint 2 (Ingestion RSS automatisée)

**Sprint** : 2
**Période** : 2026-05-04 → 2026-05-05
**Statut** : Terminé
**Livrable** : Pipeline d'ingestion RSS automatisée avec déduplication SHA-256, normalisation et insertion atomique

---

## Vue d'ensemble

Le Sprint 2 a livré le **socle d'ingestion** du système VeilleGRC-Agent. Sur la base des fondations de gouvernance posées au Sprint 1, ce sprint a construit la première brique opérationnelle :

- Schéma PostgreSQL initial (`sources` + `articles`)
- Workflow d'ingestion automatisée (n8n) sur les 3 sources institutionnelles
- Déduplication par hash SHA-256 (cryptographique standard)
- Normalisation et validation des données entrantes
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
| Fréquence d'ingestion | Quotidienne 08h00 (POC) |
| Module crypto autorisé | `NODE_FUNCTION_ALLOW_BUILTIN=crypto` |
| Incidents sources résolus | 2 (changements d'URL ANSSI + CNIL) |

---

## Livrables détaillés

### Schéma de base

#### Table `sources`
Catalogue des sources surveillées avec leur configuration (code, nom, URL RSS, fiabilité, statut actif, dates).

À l'issue du Sprint 2, 3 lignes :
- `FR-CERT-01` : CERT-FR — Avis et alertes
- `FR-ANSSI-01` : ANSSI — Actualités
- `FR-CNIL-01` : CNIL — Actualités

#### Table `articles`
Stockage des articles ingérés avec déduplication par hash SHA-256, statut workflow, et FK vers la source.

Indexes notables : FK source, hash de déduplication, date de publication.

---

### Workflow `01_Ingestion_RSS`

Pipeline en 6 nœuds (convention de nommage DÉC-009) :

```
[Schedule Trigger - Daily 08h00]
        ↓
[1. Get sources actives]              (Postgres)
        ↓
[2. HTTP Request - per source]        (HTTP Request avec User-Agent custom)
        ↓
[3. XML to JSON]                      (XML node)
        ↓
[4. Split Out items]                  (Split Out)
        ↓
[5. Normalize + Hash SHA-256]         (Code JS, module crypto)
        ↓
[6. Insert article (ON CONFLICT)]     (Postgres, déduplication atomique)
```

Settings appliqués : `Always Output Data` ON, `Continue On Fail` ON.

---

## Décisions techniques (DÉC) — Sprint 2

### Architecture du flux

- **DÉC-001** : Fréquence d'ingestion RSS
  - Phase POC : Schedule = quotidien à 08h00
  - Phase production cible : Schedule différencié par criticité de source (CERT-FR alertes : 1h ; sources standards : 4h ; sources stables : 24h)
  - Justification : adéquation entre fraîcheur attendue et sobriété des ressources.
  - Référence : REF-SOURCES-001 §12

- **DÉC-002** : Choix HTTP Request vs RSS Read natif
  Date : 2026-05-05
  Décision : utiliser HTTP Request + parsing XML manuel au lieu du nœud RSS Read natif n8n.
  Justification :
  - Permet la personnalisation User-Agent (politesse réseau, identifiabilité)
  - Permet retry et timeout configurables (résilience)
  - Compatible avec sources protégées par WAF/Cloudflare
  - Meilleure traçabilité en cas d'erreur
  Trade-off : nœud supplémentaire pour parser le XML.

- **DÉC-003** : Choix du User-Agent du bot
  Format : `"Mozilla/5.0 (compatible; <NomDuBot>/<Version>; +<URL contact>)"`
  Justification : conforme aux conventions web (RFC 7231 + Robots Exclusion Protocol). Permet aux administrateurs des sources de :
  - Identifier le bot dans leurs logs
  - Contacter en cas de problème (URL fournie)
  - Adapter `robots.txt` si besoin
  Avantage GRC : éthique, traçable, conforme aux bonnes pratiques de scraping.

### Qualité et déduplication

- **DÉC-004** : Choix du SHA-256 pour le hash de déduplication
  - SHA-256 : hash cryptographique standard, pas de collision pratique
  - Inclus dans Node.js natif (pas de dépendance externe)
  - Compatible avec une éventuelle exigence de réversibilité d'audit
  - Conforme **ISO 27002 §10.1** (cryptographie standardisée)

- **DÉC-005** : Validation des données entrantes
  - Rejet des items sans titre ou sans URL : qualité minimale
  - Troncature de la description à 5000 caractères : protection contre flux mal formés
  - Try/catch implicite via validation `Date` : robustesse face aux dates exotiques
  - Conforme principe **ISO 42001 §7.4** (qualité des données d'entrée)

- **DÉC-006** : Mapping de source par titre de canal
  - Approche pragmatique pour POC
  - Limite identifiée : si une source renomme son flux, le mapping casse silencieusement (cf. PIÈGE-004)
  - Évolution prévue Sprint 4 : récupération des sources depuis la base à chaque exécution, matching sur l'URL exacte du flux

### Sécurité et configuration

- **DÉC-007** : Activation du module `crypto` dans les nœuds Code n8n
  Date : 2026-05-05
  Contexte : n8n bloque par défaut tous les modules Node.js builtin dans les nœuds Code, par mesure de sécurité (principe de moindre privilège).
  Décision : ajout de la variable d'environnement `NODE_FUNCTION_ALLOW_BUILTIN=crypto` qui autorise UNIQUEMENT le module crypto.
  Justification :
  - Besoin technique : calcul de hash SHA-256 pour déduplication articles
  - Conformité **ISO 27002 §10.1** : usage de cryptographie standardisée
  - Surface d'attaque limitée : crypto seul, pas `fs`/`child_process`/etc.
  - Alternative envisagée : hash maison en JS pur → écartée car non cryptographique et non auditable
  Risque résiduel : faible. Le module crypto ne donne accès qu'à des primitives cryptographiques. Pas de lecture fichier, exécution commande, ou accès réseau.
  Validation : RSSI / Comité IA
  Référence : POL-IA-001 §9.3 (Sécurité des modèles et prompts)

- **DÉC-008** : Choix de l'inlining vs paramètres préparés (SQL)
  Phase POC : inlining direct des valeurs dans la requête INSERT, avec échappement des apostrophes via `.replace()`.
  Limite identifiée : protection minimale contre injection SQL.
  Acceptable car :
  - Les sources sont des autorités officielles (CNIL, ANSSI, CERT-FR) → faible probabilité de contenu malveillant
  - Pas d'exposition externe (intranet, données publiques)
  - Phase POC : priorité à l'apprentissage du flux
  Évolution prévue Sprint 4 : passage aux paramètres préparés natifs PostgreSQL (prepared statements) via la fonctionnalité Query Parameters de n8n.
  Conformité : inscrit au registre des dérogations (DEROG-003).

### Hygiène projet et conventions

- **DÉC-009** : Convention de nommage des nœuds n8n
  Format : `"<numéro>. <verbe d'action> <objet> [(<précision technique>)]"`
  Exemples : `"1. Get sources actives"`, `"5. Normalize + Hash SHA-256"`, `"6. Insert article (ON CONFLICT)"`
  Bénéfices :
  - Lisibilité : ordre d'exécution explicite
  - Auditabilité : un auditeur comprend le pipeline en 30 secondes
  - Onboarding : nouveau collaborateur comprend immédiatement
  - Documentation vivante : pas besoin d'un doc séparé pour décrire le flux
  Référence : bonne pratique générale issue de l'écosystème workflow / BPMN.

- **DÉC-010** : Tolérance aux erreurs cross-source
  Si UNE source échoue (404, timeout, format inattendu), les autres continuent à être traitées (`Continue On Fail` ON sur tous les nœuds critiques).
  Justification : un seul incident source ne doit pas casser le run quotidien.

- **DÉC-011** : Production Checklist n8n (à la première publication)
  À la publication, n8n propose 3 actions standard :
  - **Error notifications** : reportée Sprint 4 (cohérent avec POL-IA-001 §11 procédure d'incident)
  - **Time tracking** : non activé (gadget marketing, sans valeur opérationnelle)
  - **MCP access** : non activé (hors périmètre du cas d'usage)
  Décision : ignorer pour le POC. Réactiver les error notifications au Sprint 4 lors de l'industrialisation.

---

## Pièges identifiés (PIÈGE)

- **PIÈGE-001** : Mode Expression dans n8n
  Symptôme : URL préfixée par `=` dans le rendu, erreur "URL is not valid".
  Cause : double préfixe `=` (le marqueur d'expression + `=` dans la valeur).
  Solution : taper l'expression sans `=` au début, juste `{{ $json.champ }}`.

- **PIÈGE-002** : Nœud XML to JSON et accès aux champs
  Le nœud XML remplace le champ source (ici `'data'`) par la structure parsée. Donc on accède aux données par `rss.channel.item` et NON `data.rss.channel.item`.
  Bonne pratique : toujours regarder le panneau INPUT pour voir la vraie structure avant de référencer un champ.

- **PIÈGE-003** : Split Out de n8n et notation pointée
  Comportement observé : après Split Out sur `"rss.channel.item"`, n8n crée un champ littéral nommé `"rss.channel.item"` (avec les points) dans l'objet de sortie, au lieu d'une structure imbriquée.
  Conséquence : pour y accéder en JavaScript, il faut utiliser la notation crochet : `item['rss.channel.item']`, et NON `item.rss.channel.item`.
  Vérification systématique : toujours faire un script de diagnostic (`Object.keys` + `typeof`) pour observer la vraie structure avant d'écrire le code de transformation.

- **PIÈGE-004** : Mapping de source par titre de canal
  Le titre du `<channel>` RSS n'est pas toujours le nom de l'organisme.
  Exemple ANSSI : `channel.title = "Les actualités"`, pas `"ANSSI"`.
  Conséquence : le mapping basé sur le titre échoue silencieusement (0 article inséré, pas d'erreur visible — bug particulièrement insidieux).
  Solution v1 : élargir les patterns de matching (URL, autres champs).
  Solution v2 (Sprint 4) : récupérer les sources depuis la base à chaque exécution et matcher sur l'URL exacte du flux.

- **PIÈGE-005** : n8n et les nœuds en aval d'un INSERT avec ON CONFLICT
  Quand un nœud Postgres utilise `ON CONFLICT DO NOTHING` avec `RETURNING`, les items en conflit ne renvoient rien.
  Conséquence : le nœud aval reçoit un nombre d'items différent du nombre d'items en entrée. En cas d'absence d'item, `Always Output Data` peut faire passer un item "vide" qui pollue les expressions `{{ $json.xxx }}` (elles deviennent `undefined` sans erreur visible).
  Solution :
  - Soit utiliser "Execute Once" pour les nœuds qui ne dépendent pas de l'item courant (cas du UPDATE global)
  - Soit valider explicitement le contenu de l'item avant d'exécuter (par exemple dans un IF qui filtre)
  Pédagogie : un workflow qui "marche" (vert) ne fait pas forcément ce qu'on croit. Toujours vérifier le résultat réel en base, pas juste le statut n8n.

- **PIÈGE-006** : Absence de notion de temps dans les LLM
  Les modèles n'ont pas de "maintenant". Ils ne savent pas combien de temps s'est écoulé entre deux requêtes. Pour la veille (où la fraîcheur de l'info compte), il faut systématiquement injecter la date courante dans le prompt.
  Implémentation : passer `{{ $now.format('YYYY-MM-DD') }}` en variable dans le system prompt des agents Sprint 3.

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
**Validation** : Responsable veille
**Statut** : RÉSOLU

### INCIDENT-INGEST-002 — Mise à jour source FR-ANSSI-01
**Date** : 2026-05-05
**Symptôme** : HTTP Request node retourne status code 404 + page HTML d'erreur
**Cause** : convention d'URL différente sur le nouveau domaine cyber.gouv.fr
**Avant** : `https://cyber.gouv.fr/actualites/feed`
**Après** : `https://cyber.gouv.fr/actualites/rss/`
**Détecté par** : monitoring nœud HTTP Request (404 + analyse contenu)
**Action corrective** : mise à jour de la ligne `sources` correspondante en base
**Validation** : Responsable veille
**Statut** : RÉSOLU

> Ces deux incidents ont validé la pertinence du **mécanisme de validation Responsable veille** avant toute modification de source, et ont motivé l'évolution v2 envisagée (DÉC-006) consistant à matcher les sources par URL exacte plutôt que par titre de canal.

---

## Conformité démontrée Sprint 2

| Référentiel | Démonstration |
|---|---|
| ISO 27001 A.5.10 | Classification de l'information (sources publiques uniquement) |
| ISO 27001 A.5.37 | Procédures opérationnelles d'ingestion documentées |
| ISO 27002 §10.1 | Usage de cryptographie standardisée (SHA-256, DÉC-004 + DÉC-007) |
| ISO 42001 §7.4 | Qualité des données d'entrée (validation, troncature, DÉC-005) |
| ISO 42001 §7.5 | Sources versionnées en base avec horodatage |
| ISO 42001 §8.1 | Planification opérationnelle (workflow déployé) |
| RGPD art.5 | Sources institutionnelles publiques uniquement |
| RGPD art.30 | Registre des activités de traitement (sources tracées en base) |
| Bonnes pratiques web | User-Agent identifiable conforme RFC 7231 + Robots Exclusion Protocol (DÉC-003) |

---

## Livrables produits

### Code et configurations
- `workflows/n8n/01_Ingestion_RSS.json` (export workflow)
- `infra/docker/docker-compose.yml` (variable `NODE_FUNCTION_ALLOW_BUILTIN=crypto`)

### Schéma de base
- Table `sources` (3 lignes initiales)
- Table `articles` (70 lignes à l'issue du Sprint)
- Indexes de performance et déduplication

### Documentation
- `docs/CHANGELOG-sprint-2.md` (ce fichier)
- Mise à jour du registre des dérogations (DEROG-003 : inlining SQL en POC)

### Production
- Workflow `01_Ingestion_RSS` en production (publié)
- 70 articles ingérés depuis 3 sources institutionnelles
- 2 incidents sources détectés et résolus avec validation humaine

---

## Itérations identifiées (à traiter Sprint 4 ou ultérieur)

- **ITÉRATION-INGEST-01** : Différenciation des fréquences d'ingestion par criticité de source (cf. DÉC-001 phase production)
- **ITÉRATION-INGEST-02** : Mapping des sources par URL exacte plutôt que par titre de canal (cf. DÉC-006, PIÈGE-004)
- **ITÉRATION-INGEST-03** : Passage aux paramètres préparés PostgreSQL (cf. DÉC-008, DEROG-003)
- **ITÉRATION-INGEST-04** : Activation des error notifications n8n (cf. DÉC-011, POL-IA-001 §11)
- **ITÉRATION-INGEST-05** : Monitoring actif sur les codes 404 répétés (cf. INCIDENT-INGEST-001 et 002)

---

## Prochain sprint

**Sprint 3** — Pipeline IA complet
- Sprint 3.1 : Classification automatique (Haiku 4.5)
- Sprint 3.2 : Synthèse rédactionnelle (Sonnet 4.6)
- Sprint 3.3 : Digest hebdomadaire avec architecture multi-temporelle
