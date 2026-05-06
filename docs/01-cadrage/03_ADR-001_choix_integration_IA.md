# Note de décision architecturale — Approche d'intégration IA

**Référence :** ADR-001 (Architecture Decision Record n°1)
**Date :** 2026-05-05
**Auteur :** Mounir [Nom] — Responsable veille
**Statut :** Décidée
**Validation :** À soumettre au Comité IA

---

## Contexte

Anthropic a publié récemment plusieurs offres pour la construction d'agents IA, en particulier au printemps 2026 :

1. **API Messages standard** (existant) — appels HTTP simples à l'API Claude
2. **Claude Agent SDK** (avril 2026, renommage du Claude Code SDK) — SDK auto-hébergé pour construire des agents autonomes avec boucle d'exécution, gestion d'outils, sous-agents, sessions
3. **Claude Managed Agents** (avril 2026) — service hébergé sur le Claude Platform avec sandboxing, mémoire, audit, sessions longues, tarification supplémentaire de 0,08 $/heure de session

Le Sprint 3 du projet VeilleGRC-Agent prévoit d'intégrer Claude pour la classification et la synthèse des articles. Il convient de choisir l'approche d'intégration la plus adaptée au cas d'usage et aux contraintes de gouvernance.

## Options évaluées

### Option A — API Messages standard

Appels HTTP REST simples depuis n8n vers l'API Claude. Chaque appel est indépendant. Pas de boucle d'agent autonome. Le pipeline n8n joue le rôle d'orchestrateur.

**Avantages**
- Architecture simple et compréhensible (1 nœud HTTP = 1 appel)
- Souveraineté maximale : seul le contenu nécessaire est envoyé à l'API
- Coût maîtrisé : tarification au token uniquement, prévisibilité élevée (~3-5 €/mois)
- Auditabilité : chaque appel est tracé en base (prompt, réponse, tokens, coût)
- Maintenable par un nouvel arrivant sans formation spécifique
- Cohérent avec le pipeline n8n déjà déployé
- Compatible avec les principes documentés (POL-IA-001, AIPD)

**Inconvénients**
- Pas de boucle d'agent autonome (mais non requis pour ce cas d'usage)
- Pas de mémoire cross-session intégrée (à implémenter via PostgreSQL si besoin)

### Option B — Claude Agent SDK auto-hébergé

SDK Python qui s'installe sur la VM. Lance une boucle d'agent qui peut utiliser des outils (lecture fichier, exécution commande, navigation web, sous-agents) en autonomie. Approprié pour des tâches d'exploration ouvertes.

**Avantages**
- Boucle d'agent native avec gestion d'outils et sous-agents
- Sessions persistantes
- Forte capacité d'exploration et d'autonomie

**Inconvénients**
- Architecture surdimensionnée pour un pipeline déterministe (ingestion → classification → synthèse)
- Contradiction avec le principe de validation humaine systématique sur les actions à impact (POL-IA-001 §6)
- Complexité opérationnelle élevée : sandboxing, gestion mémoire, OOM possibles
- Auditabilité réduite : la boucle d'agent prend des décisions d'orchestration que l'on ne maîtrise plus
- Apprentissage technique supplémentaire pour l'équipe
- Surcoût en ressources (RAM/CPU) sur la VM

### Option C — Claude Managed Agents (hébergé Anthropic)

Service entièrement géré sur le Claude Platform. Anthropic fournit l'infrastructure d'exécution, le sandboxing, la mémoire, l'audit.

**Avantages**
- Pas d'infrastructure à gérer
- Mémoire filesystem persistante
- Audit logs natifs côté Anthropic

**Inconvénients**
- **Souveraineté dégradée** : toute la session (contexte, mémoire, exécution) tourne sur l'infrastructure Anthropic, hors UE potentiellement
- **RGPD** : ajoute un transfert de données plus large que les seuls contenus d'articles (mémoire d'agent, contexte de session, fichiers générés). Contradiction avec l'AIPD qui prévoit que seul le contenu public d'articles est transmis
- **Coût multiplié** : 0,08 $/heure de session active s'ajoutant aux tokens. Pour un usage continu, multiplie le coût par 3 à 5
- Dépendance accrue au fournisseur (réversibilité plus complexe)
- Hors périmètre du choix d'auto-hébergement initial documenté (RUN-VEILLEGRC-001)

## Critères de décision

| Critère | Pondération | Option A | Option B | Option C |
|---|---|---|---|---|
| Adéquation cas d'usage (pipeline déterministe) | Forte | ✅ Très bonne | ⚠️ Surdimensionné | ⚠️ Surdimensionné |
| Souveraineté et conformité RGPD | Forte | ✅ Maximale | ✅ Bonne | ❌ Dégradée |
| Cohérence avec POL-IA-001 (human-in-the-loop) | Forte | ✅ | ⚠️ | ⚠️ |
| Coût maîtrisé pour le POC | Forte | ✅ ~5 €/mois | ✅ tokens only | ❌ +session-hours |
| Auditabilité en base | Forte | ✅ | ⚠️ | ⚠️ |
| Maintenabilité par un junior | Moyenne | ✅ | ❌ | ⚠️ |
| Cohérence avec architecture n8n existante | Moyenne | ✅ | ⚠️ | ⚠️ |
| Réversibilité / portabilité | Moyenne | ✅ | ⚠️ | ❌ |

## Décision

**Option A retenue : API Messages standard**

L'API Messages, appelée depuis le pipeline n8n via des nœuds HTTP Request, est l'approche la plus alignée avec :
- Le caractère déterministe du pipeline de veille (chaque article suit un parcours fixe : ingestion → classification → synthèse → digest)
- Le principe de supervision humaine systématique documenté dans la politique IA
- L'objectif de souveraineté et de minimisation des données transmises hors UE
- Le budget cible
- La cohérence architecturale avec le socle déjà déployé (Sprint 2)

## Conséquences

### Positives
- Architecture simple, prévisible, auditable
- Cohérence avec les livrables de gouvernance déjà produits
- Permet de capitaliser sur l'investissement n8n du Sprint 2
- Facilite l'onboarding d'un futur collaborateur

### À surveiller
- Pas de mémoire cross-session : si un besoin émerge (apprentissage progressif des préférences éditoriales, par exemple), il devra être implémenté manuellement via PostgreSQL
- Pas de boucle d'agent autonome : pour des tâches futures qui nécessiteraient une exploration ouverte (ex : recherche d'informations complémentaires sur le web pour enrichir un article), une revue de l'architecture sera nécessaire

## Réévaluation

Cette décision sera réévaluée si l'un des éléments suivants se produit :
- Émergence d'un cas d'usage nécessitant une exploration autonome multi-tours
- Apparition d'une offre Claude Managed Agents avec hébergement européen et garanties RGPD renforcées
- Évolution réglementaire imposant des contraintes nouvelles sur l'auto-hébergement

Revue prévue : annuelle, ou à chaque évolution majeure de l'offre Anthropic.

## Références

- AIPD-VeilleGRC-001 (analyse d'impact)
- POL-IA-001 (politique d'usage IA), §6 et §7
- REG-IA-001 (registre des systèmes IA)
- RUN-VEILLEGRC-001 (runbook d'exploitation)
- Documentation Anthropic Agent SDK : https://platform.claude.com/docs/en/agent-sdk
- Documentation Anthropic Managed Agents : https://www.anthropic.com/news/managed-agents

## Historique

| Version | Date | Auteur | Évolution |
|---|---|---|---|
| 1.0 | 2026-05-05 | Mounir [Nom] | Décision initiale |

---

*Architecture Decision Record (ADR) — modèle inspiré de Michael Nygard (2011). Document interne — Hedgewood Conseil.*
