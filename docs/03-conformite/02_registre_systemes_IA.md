# Registre des systèmes d'Intelligence Artificielle

**Référence :** REG-IA-001
**Version :** 1.0
**Date de mise à jour :** 2026
**Propriétaire du registre :** Comité IA — Hedgewood Conseil
**Tenue à jour par :** Responsable veille (Mounir [Nom])
**Périodicité de revue :** Trimestrielle (Comité IA) + à chaque évolution
**Diffusion :** Direction, RSSI, DPO, auditeurs internes/externes

---

## Préambule

Le présent registre constitue **l'inventaire central de tous les systèmes d'intelligence artificielle** déployés ou utilisés au sein de Hedgewood Conseil. Il répond aux exigences de :

- **ISO/IEC 42001:2023** — clause 7.5 (informations documentées) et 8.1 (planification opérationnelle)
- **AI Act** — articles 16, 26 et 49 (obligations de documentation pour les opérateurs de systèmes IA)
- **RGPD** — articulation avec le registre des activités de traitement (article 30)
- **ISO/IEC 27001:2022** — inventaire des actifs informationnels (clause A.5.9)

Tout système d'IA mis en service au sein du cabinet **doit être inscrit à ce registre avant déploiement**. L'absence d'inscription rend l'usage du système non autorisé.

---

## Index des systèmes IA inscrits

| ID | Nom du système | Statut | Risque AI Act | Propriétaire | Date d'inscription |
|---|---|---|---|---|---|
| SYS-IA-001 | VeilleGRC-Agent | En conception | Limité | Mounir [Nom] | 2026 |

*(le registre s'enrichira de toutes les solutions IA introduites — outils SaaS, copilotes, agents internes, etc.)*

---

## Fiche détaillée — SYS-IA-001 : VeilleGRC-Agent

### 1. Identification du système

| Champ | Valeur |
|---|---|
| Identifiant | SYS-IA-001 |
| Nom | VeilleGRC-Agent |
| Version | 0.1 (en conception) |
| Statut | En conception (passage en production prévu fin Sprint 4) |
| Date de mise en service | À définir |
| Date prévue de revue | Annuelle + à chaque release majeure |
| Date prévue de décommissionnement | Non défini (système pérenne) |

### 2. Description fonctionnelle

| Champ | Valeur |
|---|---|
| Finalité | Industrialiser la veille réglementaire et cyber du cabinet |
| Description | Système d'agents IA orchestrés ingérant des sources publiques, produisant un digest hebdomadaire et des alertes critiques après validation humaine |
| Périmètre métier | Activité support — équipe consulting GRC |
| Utilisateurs cibles | Consultants, responsable veille, direction (~12 personnes) |
| Document de référence | Fiche cadrage (`01-cadrage/01_fiche_cadrage_cas_usage.md`) |

### 3. Classification AI Act

| Champ | Valeur |
|---|---|
| Niveau de risque | **Risque limité** |
| Justification | Système d'aide à la décision pour professionnels, non listé Annexe III, supervision humaine systématique, pas de décision automatisée affectant les personnes |
| Obligations applicables | Transparence (art. 50), information des utilisateurs, conservation des logs |
| Système IA à usage général (GPAI) | Non — utilise un GPAI (Claude) en aval mais n'en est pas un |
| Marquage CE / certification | Non requis (risque limité) |

### 4. Composants techniques

| Composant | Type | Fournisseur | Localisation | Version |
|---|---|---|---|---|
| Modèle Claude Sonnet 4.6 | LLM (synthèse fine) | Anthropic | États-Unis (API) | claude-sonnet-4-6 |
| Modèle Claude Haiku 4.5 | LLM (classification, tri) | Anthropic | États-Unis (API) | claude-haiku-4-5 |
| Orchestrateur n8n | Workflow engine | n8n.io (open source) | Auto-hébergé (VM Linux locale) | À fixer en Sprint 2 |
| Base de données PostgreSQL | Stockage articles + métadonnées | PostgreSQL Global Dev. Group (open source) | Auto-hébergé | 16+ |
| Service SMTP | Diffusion email | À définir | UE souhaité | À définir |

### 5. Données

| Champ | Valeur |
|---|---|
| Données d'entraînement | Aucune — pas d'entraînement, usage de modèles pré-entraînés tiers |
| Données d'entrée du système | Articles publics ingérés via RSS/scraping ; aucune donnée personnelle envoyée à l'API IA |
| Données de sortie | Synthèses, classifications, scores de criticité — production interne |
| Données personnelles traitées | Annuaire interne destinataires (nom, email pro) — non transmis à l'API IA |
| Sensibilité | Interne ; pas de données sensibles |
| AIPD réalisée | Oui — `03-conformite/01_AIPD_VeilleGRC.md` (allégée) |
| Lien registre des traitements RGPD | À créer dans le RAT au lancement |

### 6. Gouvernance et responsabilités

| Rôle | Nom / Fonction |
|---|---|
| Propriétaire métier | Direction du cabinet |
| Propriétaire technique | Mounir [Nom] — Responsable veille |
| Responsable de conformité | DPO du cabinet |
| Référent sécurité | RSSI |
| Comité de pilotage | Comité IA (trimestriel) |

### 7. Cycle de vie

| Étape | Statut | Date | Validation |
|---|---|---|---|
| Cadrage | ✅ Réalisé | 2026 | Auteur |
| Évaluation des risques | ✅ Réalisé | 2026 | À valider Comité IA |
| AIPD | ✅ Draft | 2026 | À valider DPO |
| Conception | 🟡 En cours | Sprint 2 | — |
| Développement | ⏳ À venir | Sprint 2-3 | — |
| Tests (fonctionnels, sécurité, robustesse) | ⏳ À venir | Sprint 3 | — |
| Mise en production | ⏳ À venir | Sprint 4 | Comité IA |
| Exploitation | — | — | — |
| Revue annuelle | — | — | — |
| Décommissionnement | — | — | — |

### 8. Risques et mesures de contrôle

| Risque | Niveau résiduel | Mesure principale | Référence |
|---|---|---|---|
| Hallucination | Faible | Validation humaine + citation systématique | AIPD §3.2, MIA-02 |
| Prompt injection via contenu externe | Faible | Sanitization, séparation contexte/instructions | Politique IA §9.3 |
| Indisponibilité API Claude | Faible | Mode dégradé, file d'attente | Plan de continuité |
| Dépassement budget | Très faible | Plafond mensuel API, alertes | MIA-04 |
| Fuite de données personnelles | Très faible | Pas de DCP envoyée à l'API | Architecture |
| Biais de couverture des sources | Faible | Revue mensuelle de couverture, indicateur dédié | KPI dédié |

### 9. Mesures de transparence (AI Act art. 50)

| Mesure | Statut |
|---|---|
| Mention « contenu généré par IA » sur les digests | ✅ Spécifié |
| Information des collaborateurs sur l'usage d'IA | À faire avant production |
| Identification du modèle utilisé en cas de demande | Fournie sur sollicitation |
| Documentation accessible à l'audit | Présent registre + AIPD + politique |

### 10. Supervision humaine

| Élément | Modalité |
|---|---|
| Validation avant action externe | Le digest est validé par le Responsable veille avant envoi |
| Supervision continue | Dashboard métriques consulté hebdomadairement |
| Possibilité d'arrêt d'urgence | Oui — kill switch sur l'orchestrateur n8n |
| Possibilité de neutraliser une décision IA | Oui — édition manuelle du digest avant envoi |
| Procédure de reprise manuelle | Documentée en Sprint 4 |

### 11. Robustesse, fiabilité et performance

| Indicateur | Cible | Méthode de mesure |
|---|---|---|
| Disponibilité du système | 95 % en heures ouvrées | Supervision n8n + monitoring |
| Taux de validation digest sans modification | > 80 % à 3 mois | Métrique workflow |
| Taux d'hallucination détecté | < 5 % par sondage | Sondage manuel mensuel sur 10 % des items |
| Latence ingestion → digest | < 24h | Métrique workflow |
| Coût mensuel API | < 30 € | Console facturation Anthropic |

### 12. Sécurité

| Mesure | Statut |
|---|---|
| Authentification forte sur l'orchestrateur | À implémenter Sprint 2 |
| Chiffrement TLS des flux | Standard |
| Chiffrement au repos PostgreSQL | À implémenter Sprint 2 |
| Cloisonnement réseau (VM dédiée) | ✅ Conception |
| Sauvegardes quotidiennes testées | À implémenter Sprint 4 |
| Tests de prompt injection | À planifier Sprint 3 |
| Gestion des secrets (clés API) | Variables d'environnement chiffrées (à mettre en place Sprint 2) |
| Mises à jour régulières des composants | Procédure à formaliser |

### 13. Sous-traitants et chaîne de fournisseurs

| Sous-traitant | Service | Évaluation sécurité | DPA / Contrat | Localisation données |
|---|---|---|---|---|
| Anthropic | API LLM (Claude) | À réaliser | Conditions Anthropic + DPA | États-Unis (CCT requises) |
| n8n.io | Orchestrateur (auto-hébergé) | N/A — code open source | Licence Sustainable Use | Local (VM cabinet) |
| PostgreSQL | Base de données (auto-hébergé) | N/A — open source | PostgreSQL License | Local (VM cabinet) |
| [À définir SMTP] | Routage email | À réaliser | DPA à signer | UE souhaité |

### 14. Journalisation et auditabilité

| Élément journalisé | Conservation | Localisation |
|---|---|---|
| Appels API (modèle, tokens, coût, timestamp) | 12 mois | PostgreSQL local |
| Workflows exécutés (n8n) | 12 mois | PostgreSQL local |
| Validations humaines (qui, quand, modifications) | 12 mois | PostgreSQL local |
| Incidents | 5 ans | Journal incidents IA |
| Accès administrateurs | 12 mois | Logs système |

### 15. Plan d'incidents et de continuité

| Élément | Statut |
|---|---|
| Procédure de gestion d'incident IA | À formaliser Sprint 4 |
| Plan de continuité (mode dégradé) | À formaliser Sprint 4 |
| Plan de réversibilité (sortie d'Anthropic) | À formaliser — alternative possible : modèle local ou autre fournisseur |
| Test de restauration sauvegarde | Trimestriel à partir de la mise en production |

### 16. Conformité réglementaire

| Référentiel | Articles applicables | Statut |
|---|---|---|
| AI Act | Art. 50 (transparence), considérants risque limité | ✅ Conforme par conception |
| RGPD | Art. 6 (intérêt légitime), 13/14 (information), 30 (registre), 32 (sécurité), 35 (AIPD) | ✅ AIPD réalisée |
| ISO 42001 | Clauses 6 (planification), 7 (support), 8 (opérationnel), 9 (évaluation) | 🟡 Démarche initiée |
| ISO 27001 | A.5.9 (inventaire actifs), A.8.16 (surveillance), A.8.28 (codage sécurisé) | 🟡 En cours |

### 17. Documentation associée

| Document | Référence | Localisation |
|---|---|---|
| Fiche de cadrage | DOC-CADR-001 | `docs/01-cadrage/01_fiche_cadrage_cas_usage.md` |
| Politique d'usage IA | POL-IA-001 | `docs/02-gouvernance/01_politique_usage_IA.md` |
| AIPD | AIPD-001 | `docs/03-conformite/01_AIPD_VeilleGRC.md` |
| Procédure d'exploitation | À créer Sprint 2 | `docs/04-operations/` |
| Plan d'incident IA | À créer Sprint 4 | `docs/04-operations/` |
| Tests de robustesse | À créer Sprint 3 | `docs/04-operations/` |

### 18. Revue et historique

| Date | Auteur | Évolution | Validation |
|---|---|---|---|
| 2026 | Mounir [Nom] | Création initiale | À valider Comité IA |

---

## Annexe — Critères d'inscription au registre

Tout système est inscrit au registre s'il répond à au moins un des critères suivants :

- Utilise un modèle d'IA pour automatiser une tâche métier
- Génère du contenu à destination interne ou externe
- Prend ou aide à prendre une décision
- Est intégré dans un processus du cabinet (même secondaire)
- Est mis à disposition des collaborateurs (même en mode test)

Les outils suivants entrent dans le registre dès leur usage récurrent : copilotes de code, assistants de rédaction, outils de veille IA, traducteurs IA professionnels, outils de transcription, générateurs d'images, etc.

---

## Annexe — Procédure d'inscription d'un nouveau système

1. Le porteur d'un projet IA remplit une fiche cadrage et la transmet au Comité IA
2. Le Comité IA évalue la classification AI Act et les risques
3. Si données personnelles : le DPO réalise ou supervise l'AIPD
4. Le RSSI valide les mesures de sécurité
5. Inscription au registre avec ID dédié (SYS-IA-XXX)
6. Mise en production conditionnée à la validation finale du Comité IA
7. Inscription au registre des activités de traitement (RGPD) si applicable
8. Communication aux utilisateurs

---

*Document interne — Hedgewood Conseil. Diffusion contrôlée.*
