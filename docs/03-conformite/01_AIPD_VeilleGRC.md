# Analyse d'Impact relative à la Protection des Données (AIPD)

**Référence :** AIPD-VeilleGRC-001
**Version :** 1.0
**Date :** 2026
**Système concerné :** VeilleGRC-Agent — Système de veille réglementaire et cyber automatisée
**Responsable de traitement :** Hedgewood Conseil (cabinet de conseil GRC)
**Auteur :** Mounir [Nom] — Responsable veille
**Avis DPO :** [À recueillir]
**Statut :** Draft v1

---

## Préambule — Justification de la démarche

L'article 35 du RGPD impose une AIPD pour les traitements **« susceptibles d'engendrer un risque élevé pour les droits et libertés des personnes physiques »**. La liste de la CNIL des traitements soumis à AIPD obligatoire ne couvre pas formellement le présent traitement, qui ne porte que sur des données personnelles internes à finalité de communication professionnelle (envoi d'un digest aux consultants).

**Cependant**, le cabinet a fait le choix de réaliser une **AIPD volontaire allégée** pour les raisons suivantes :
- Démarche de conformité ISO 42001 et de gouvernance IA proactive
- Exercice de mise en pratique du Privacy by Design
- Recours à un sous-traitant IA (Anthropic) avec transfert de données hors UE potentiel
- Préparation au passage à un service de veille managée pour les clients (où l'AIPD sera obligatoire)

L'AIPD est conduite selon la **méthodologie CNIL** en quatre temps : description du traitement, évaluation de la nécessité et de la proportionnalité, étude des risques pour les personnes concernées, validation.

---

## Partie 1 — Description du traitement

### 1.1 Finalités

**Finalité principale** : Diffuser à chaque consultant du cabinet un digest hebdomadaire de veille réglementaire et cybersécurité, ainsi que des alertes ponctuelles en cas d'évolution critique.

**Finalités secondaires** :
- Mesurer l'usage et la satisfaction (statistiques d'ouverture, feedbacks)
- Suivre les indicateurs de performance et de risque du système IA
- Capitaliser un historique consultable des publications

### 1.2 Nature du traitement

| Élément | Description |
|---|---|
| Type d'opération | Collecte (annuaire interne), stockage, consultation, transmission par email, archivage |
| Caractère automatisé | Oui (envoi automatisé après validation humaine), pas de décision automatisée affectant les personnes |
| Échelle | ~12 destinataires (consultants du cabinet) — petite échelle |
| Fréquence | Hebdomadaire + alertes ponctuelles |
| Durée du traitement | Tant que le système est en service |

### 1.3 Données traitées

| Catégorie | Données précises | Source | Justification |
|---|---|---|---|
| Identification destinataire | Nom, prénom, email professionnel | Annuaire interne | Diffusion du digest |
| Données d'usage | Date d'envoi, ouverture (si tracking), feedback | Système | Mesure d'efficacité, amélioration |
| Données techniques | Logs techniques (id session, timestamps) | Système | Sécurité, audit |

**Ne sont pas traités** : données sensibles, données de mineurs, données de localisation, données biométriques, données de santé, données financières.

### 1.4 Personnes concernées

- Salariés et collaborateurs de Hedgewood Conseil destinataires du digest (~12 personnes)
- Information préalable lors de l'embauche et à la mise en service du système

### 1.5 Cycle de vie des données

```
[Annuaire RH interne]
        │
        ▼
[Système VeilleGRC-Agent (PostgreSQL local)]
        │
        ▼
[Envoi email via SMTP (en interne ou prestataire UE)]
        │
        ▼
[Conservation logs 12 mois → suppression automatique]
[Conservation données destinataires : durée du contrat de travail + révocation à la sortie]
```

### 1.6 Acteurs et responsabilités

| Acteur | Rôle RGPD | Responsabilité |
|---|---|---|
| Hedgewood Conseil | Responsable de traitement | Décide finalités et moyens |
| Anthropic (API Claude) | Sous-traitant | Traite le contenu des articles publics et requêtes système |
| Hébergeur d'envoi email | Sous-traitant | Routage des emails |
| DPO du cabinet | Conseil et contrôle | Avis sur AIPD, point de contact CNIL |

**Important** : les emails et identités des destinataires **ne sont pas transmis** au sous-traitant IA Anthropic. Seuls les contenus publics (articles de veille) et instructions système sont envoyés à l'API. La séparation des données est un choix de conception explicite.

### 1.7 Référentiels et obligations applicables

- RGPD (UE 2016/679)
- Loi Informatique et Libertés modifiée
- AI Act (UE 2024/1689) — risque limité applicable
- Recommandations CNIL « IA et RGPD »
- Référentiel CNIL « Sécurité des données personnelles »

---

## Partie 2 — Évaluation de la nécessité et de la proportionnalité

### 2.1 Bases légales (article 6 RGPD)

**Base retenue** : **Intérêt légitime** (art. 6.1.f)

**Test de mise en balance (Legitimate Interest Assessment)** :

| Critère | Analyse |
|---|---|
| Légitimité de l'intérêt | Améliorer l'efficacité du cabinet et la qualité du service rendu — légitime |
| Nécessité | Pas d'alternative moins intrusive permettant une diffusion ciblée individualisée |
| Mise en balance | Impact très limité sur les personnes (email pro, communication métier attendue), équilibre favorable |
| Attentes raisonnables | Les consultants attendent ce type de communication interne |

**Conclusion** : intérêt légitime valablement mobilisé, complété par l'information transparente des personnes.

### 2.2 Proportionnalité et minimisation

| Principe | Application dans le projet |
|---|---|
| Minimisation des données | Seuls nom, prénom, email pro sont traités. Pas de profilage, pas d'enrichissement |
| Exactitude | Synchronisation avec l'annuaire RH, mise à jour à chaque mouvement |
| Limitation de la conservation | 12 mois pour les logs ; à la sortie pour les destinataires |
| Limitation de la finalité | Pas de réutilisation à des fins commerciales ou tierces |

### 2.3 Droits des personnes concernées

| Droit | Modalité d'exercice |
|---|---|
| Information (art. 13/14) | Mention au livret d'accueil + information lors du lancement du système |
| Accès (art. 15) | Demande au DPO via dpo@hedgewood.fr |
| Rectification (art. 16) | Auto-service via portail RH ou demande au DPO |
| Effacement (art. 17) | Possible à la sortie ; pendant l'emploi : motif légitime requis |
| Limitation (art. 18) | Sur demande motivée |
| Opposition (art. 21) | Recevable, déclenche un examen au cas par cas. Peut conduire à la désinscription du digest |
| Décision automatisée (art. 22) | Non applicable — pas de décision automatisée affectant les personnes |
| Portabilité (art. 20) | Non applicable (pas de base légale contrat ou consentement) |

### 2.4 Transferts hors UE

Le sous-traitant Anthropic est susceptible de traiter des données hors UE.

**Mesures encadrant ce transfert** :
- Aucune donnée personnelle de destinataire transmise à l'API Claude (séparation logique)
- Conditions contractuelles type Anthropic / DPA en vigueur à vérifier
- Configuration option « Zero Data Retention » lorsque disponible
- Documentation des flux dans le registre des activités de traitement

**Décision** : si le DPA Anthropic comporte des clauses contractuelles types et un engagement de non-conservation, le transfert est encadré. Sinon, un complément de mesures (chiffrement supplémentaire, hébergement européen) doit être étudié.

---

## Partie 3 — Étude des risques pour les personnes

Méthodologie : pour chaque événement redouté, on évalue **gravité (G)** et **vraisemblance (V)** sur une échelle de 1 (négligeable) à 4 (maximale), avant et après mesures.

### 3.1 Accès illégitime aux données

| Source de risque | Menace | Impact pour les personnes | G initial | V initial | Mesures | G résiduel | V résiduel |
|---|---|---|---|---|---|---|---|
| Acteur externe malveillant | Compromission du serveur n8n / PostgreSQL | Divulgation d'emails internes (impact faible) | 2 | 3 | Chiffrement au repos, accès restreint, MAJ régulières, MFA admin | 2 | 1 |
| Collaborateur | Accès non autorisé aux logs | Lecture d'historique | 2 | 2 | Cloisonnement des accès, journalisation des accès admins | 2 | 1 |
| Sous-traitant IA | Réutilisation des données par fournisseur | N/A car pas de DCP envoyée | 1 | 1 | Pas de DCP envoyée à l'API, ZDR | 1 | 1 |

### 3.2 Modification non désirée des données

| Source de risque | Menace | Impact pour les personnes | G initial | V initial | Mesures | G résiduel | V résiduel |
|---|---|---|---|---|---|---|---|
| Bug logiciel | Erreur d'envoi à de mauvais destinataires | Divulgation interne (très limitée) | 2 | 2 | Tests, validation humaine avant envoi, environnement de pré-prod | 2 | 1 |
| Hallucination IA | Synthèse contenant un nom incorrect | Atteinte à la réputation potentielle | 3 | 2 | Validation humaine systématique, citation des sources, sondage qualité | 2 | 1 |

### 3.3 Disparition des données

| Source de risque | Menace | Impact pour les personnes | G initial | V initial | Mesures | G résiduel | V résiduel |
|---|---|---|---|---|---|---|---|
| Panne / sinistre | Perte de la base | Aucun impact sur les personnes (données non critiques pour elles) | 1 | 2 | Sauvegardes régulières, restauration testée | 1 | 1 |

### 3.4 Synthèse des risques résiduels

Tous les risques résiduels sont évalués **G ≤ 2** et **V ≤ 1** — niveau **acceptable**.

L'AIPD ne révèle pas de risque élevé pour les droits et libertés des personnes. Le traitement peut être mis en œuvre sous réserve du respect des mesures listées.

---

## Partie 4 — Plan d'action et mesures

### 4.1 Mesures techniques

| ID | Mesure | Échéance | Responsable | Statut |
|---|---|---|---|---|
| MT-01 | Chiffrement TLS 1.2+ pour tous les flux | Sprint 2 | Responsable veille | À faire |
| MT-02 | Chiffrement au repos PostgreSQL | Sprint 2 | Responsable veille | À faire |
| MT-03 | Authentification forte sur n8n (compte admin) | Sprint 2 | Responsable veille | À faire |
| MT-04 | Sauvegarde quotidienne, test de restauration mensuel | Sprint 4 | Responsable veille | À faire |
| MT-05 | Sanitization des entrées issues du web (anti-injection) | Sprint 3 | Responsable veille | À faire |
| MT-06 | Activation Zero Data Retention sur API Claude si éligible | Sprint 2 | Responsable veille | À faire |
| MT-07 | Logs horodatés, intègres, conservés 12 mois | Sprint 2 | Responsable veille | À faire |

### 4.2 Mesures organisationnelles

| ID | Mesure | Échéance | Responsable | Statut |
|---|---|---|---|---|
| MO-01 | Validation humaine du digest avant envoi | Permanent | Responsable veille | Inscrit dans le workflow |
| MO-02 | Information des consultants à la mise en service | Avant Sprint 4 | Direction | À faire |
| MO-03 | Mise à jour du registre des activités de traitement | Avant Sprint 4 | DPO | À faire |
| MO-04 | Procédure d'incident IA documentée | Sprint 4 | Responsable veille | À faire |
| MO-05 | Revue annuelle de l'AIPD | Annuelle | DPO + Responsable veille | Récurrent |
| MO-06 | Vérification du DPA Anthropic et des CCT | Sprint 1 | DPO | À faire |

### 4.3 Mesures spécifiques IA

| ID | Mesure | Échéance | Responsable | Statut |
|---|---|---|---|---|
| MIA-01 | Mention « contenu généré par IA, validé par humain » sur chaque digest | Permanent | Responsable veille | À implémenter |
| MIA-02 | Citation systématique des sources dans les synthèses | Permanent | Responsable veille | À implémenter |
| MIA-03 | Sondage qualité mensuel (10 % des items) | Mensuel | Comité IA | À mettre en place |
| MIA-04 | Plafonnement budget API mensuel | Sprint 2 | Responsable veille | À configurer |

---

## Partie 5 — Validation

### 5.1 Avis du DPO

À recueillir avant mise en production. Champs à compléter :

- Avis : Favorable / Favorable avec réserves / Défavorable
- Réserves éventuelles :
- Date :
- Nom et signature du DPO :

### 5.2 Décision du responsable de traitement

À compléter avant mise en production.

- Décision : Mise en production autorisée / Reportée / Refusée
- Conditions :
- Date :
- Nom et signature :

### 5.3 Consultation des personnes concernées

Le cas échéant, recueil de l'avis des consultants prévu lors de la communication interne de lancement.

### 5.4 Information de la CNIL

Compte tenu du niveau de risque résiduel acceptable, **aucune consultation préalable de la CNIL n'est requise** au sens de l'article 36 du RGPD.

---

## Annexes

### Annexe 1 — Cartographie des flux de données

```
[Annuaire RH] ──► [Système VeilleGRC-Agent] ──► [Email destinataires]
                          │
                          ├──► [API Claude] (contenus publics uniquement)
                          │
                          └──► [Logs locaux 12 mois]
```

### Annexe 2 — Liste des sous-traitants

| Sous-traitant | Service | Données traitées | Localisation | Encadrement |
|---|---|---|---|---|
| Anthropic | API Claude | Contenus d'articles publics + prompts | États-Unis | DPA + CCT à vérifier, ZDR si éligible |
| [Hébergeur SMTP à définir] | Routage email | Emails destinataires + contenu digest | UE souhaité | DPA |

### Annexe 3 — Suivi des révisions

| Version | Date | Auteur | Évolution |
|---|---|---|---|
| 1.0 | 2026 | Mounir [Nom] | Création initiale |

---

*Document interne — Hedgewood Conseil. Diffusion contrôlée — DPO, RSSI, Direction, Responsable veille.*
