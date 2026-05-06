# Liste de référence des sources de veille

**Référence :** REF-SOURCES-001
**Version :** 1.0
**Date :** 2026
**Propriétaire :** Responsable veille (Mounir [Nom])
**Validation :** Comité IA
**Périodicité de revue :** Trimestrielle ou à toute évolution réglementaire majeure
**Lien avec :** Fiche de cadrage SYS-IA-001

---

## 1. Objet

Ce document liste l'ensemble des sources publiques surveillées par le système VeilleGRC-Agent. Il sert de :

- **Référentiel de configuration** pour l'orchestrateur n8n (URLs, fréquences d'ingestion)
- **Justification** de la couverture de veille auprès des clients et auditeurs
- **Outil de pilotage** pour mesurer les angles morts et l'évolution du périmètre

Toute modification (ajout, retrait, changement de criticité) fait l'objet d'une décision documentée du Comité IA.

## 2. Critères de sélection des sources

Une source est retenue si elle remplit **au moins trois** des critères suivants :

- Émanation d'une autorité officielle (régulateur, agence, ministère)
- Publication régulière (a minima mensuelle) sur les thématiques cibles
- Source primaire (pas de simple agrégateur)
- Notoriété dans la communauté GRC/cyber/data
- Disponibilité d'un flux RSS/Atom ou d'un format facilement ingérable
- Contenu en français ou en anglais

## 3. Critères de fiabilité

Chaque source est notée sur 5 niveaux :

| Niveau | Libellé | Description |
|---|---|---|
| ⭐⭐⭐⭐⭐ | Référence absolue | Autorité officielle française ou européenne, publication primaire |
| ⭐⭐⭐⭐ | Très fiable | Autorité internationale reconnue, organisme de standardisation |
| ⭐⭐⭐ | Fiable | Presse spécialisée reconnue, éditeur établi |
| ⭐⭐ | À recouper | Source intéressante mais nécessitant validation croisée |
| ⭐ | À surveiller | Pertinence à confirmer, période de probation |

## 4. Critères de criticité du contenu

Le scoring de criticité (faible / moyenne / élevée / critique) est appliqué **au niveau de chaque article**, pas de la source. Cf. document `03-conformite/03_taxonomie_criticite.md` (à produire Sprint 3).

---

## 5. Sources réglementaires françaises

### 5.1 Régulateurs et autorités

| ID | Nom | URL principale | RSS | Fiabilité | Thématiques |
|---|---|---|---|---|---|
| FR-CNIL-01 | CNIL — Actualités | https://www.cnil.fr | https://www.cnil.fr/fr/flux | ⭐⭐⭐⭐⭐ | RGPD, IA, données personnelles |
| FR-CNIL-02 | CNIL — Délibérations et sanctions | https://www.cnil.fr/fr/sanctions-prononcees-par-la-cnil | (à vérifier) | ⭐⭐⭐⭐⭐ | Sanctions, jurisprudence CNIL |
| FR-ANSSI-01 | ANSSI — Actualités | https://cyber.gouv.fr | https://cyber.gouv.fr/actualites/feed | ⭐⭐⭐⭐⭐ | Cybersécurité, certification, NIS2 |
| FR-CERT-01 | CERT-FR — Avis et alertes | https://www.cert.ssi.gouv.fr | https://www.cert.ssi.gouv.fr/avis/feed/ | ⭐⭐⭐⭐⭐ | Vulnérabilités, CVE, incidents |
| FR-CERT-02 | CERT-FR — Alertes urgentes | https://www.cert.ssi.gouv.fr/alerte/ | https://www.cert.ssi.gouv.fr/alerte/feed/ | ⭐⭐⭐⭐⭐ | Alertes critiques (priorité maximale) |
| FR-AMF-01 | AMF — Actualités | https://www.amf-france.org | (à vérifier) | ⭐⭐⭐⭐ | DORA, finance |
| FR-ACPR-01 | ACPR — Publications | https://acpr.banque-france.fr | (à vérifier) | ⭐⭐⭐⭐ | DORA, conformité bancaire |

### 5.2 Sources gouvernementales et législatives

| ID | Nom | URL | RSS | Fiabilité | Thématiques |
|---|---|---|---|---|---|
| FR-LEG-01 | Légifrance — Journal officiel | https://www.legifrance.gouv.fr | (recherche thématique) | ⭐⭐⭐⭐⭐ | Lois, décrets, arrêtés |
| FR-GOV-01 | Numerique.gouv.fr | https://www.numerique.gouv.fr | (à vérifier) | ⭐⭐⭐⭐ | Politique numérique, IA souveraine |

### 5.3 Presse et communauté française spécialisée

| ID | Nom | URL | RSS | Fiabilité | Thématiques |
|---|---|---|---|---|---|
| FR-PRESSE-01 | LeMagIT (sécurité) | https://www.lemagit.fr | https://www.lemagit.fr/rss/Toute-l-actualite.xml | ⭐⭐⭐ | Cyber, IT entreprise |
| FR-PRESSE-02 | Next | https://next.ink | https://next.ink/feed/ | ⭐⭐⭐ | Numérique, libertés, RGPD |
| FR-PRESSE-03 | Cyberguerre / Numerama Cyber | https://www.numerama.com/cyberguerre/ | (à vérifier) | ⭐⭐⭐ | Cyber grand public |
| FR-PRESSE-04 | Le Monde Informatique | https://www.lemondeinformatique.fr | https://www.lemondeinformatique.fr/flux-rss-du-monde-informatique-9.html | ⭐⭐⭐ | IT, sécurité |
| FR-PRESSE-05 | ZDNet France | https://www.zdnet.fr | https://www.zdnet.fr/feeds/rss/ | ⭐⭐⭐ | IT, sécurité |

---

## 6. Sources européennes

### 6.1 Institutions et régulateurs UE

| ID | Nom | URL | RSS | Fiabilité | Thématiques |
|---|---|---|---|---|---|
| EU-EUR-LEX-01 | EUR-Lex — Journal officiel UE | https://eur-lex.europa.eu | (alertes thématiques) | ⭐⭐⭐⭐⭐ | Législation UE (RGPD, AI Act, NIS2, DORA) |
| EU-COM-01 | Commission européenne — Numérique | https://digital-strategy.ec.europa.eu | (newsletters) | ⭐⭐⭐⭐⭐ | AI Act, Data Act, stratégie numérique |
| EU-EDPB-01 | EDPB — Comité européen protection données | https://www.edpb.europa.eu | https://www.edpb.europa.eu/news/news_en?f%5B0%5D=oe_news_type%3Ahttp%3A//publications.europa.eu/resource/authority/resource-type/PUB_GEN | ⭐⭐⭐⭐⭐ | RGPD, lignes directrices, transferts |
| EU-EDPS-01 | EDPS — Contrôleur européen | https://www.edps.europa.eu | (à vérifier) | ⭐⭐⭐⭐ | Protection données institutions UE |
| EU-ENISA-01 | ENISA — Agence cyber UE | https://www.enisa.europa.eu | https://www.enisa.europa.eu/news/enisa-news/RSS | ⭐⭐⭐⭐⭐ | Cyber, NIS2, certification |
| EU-CSIRT-01 | CSIRTs Network | https://csirtsnetwork.eu | (à vérifier) | ⭐⭐⭐⭐ | Coordination CSIRT |

### 6.2 Organismes de normalisation et conformité

| ID | Nom | URL | RSS | Fiabilité | Thématiques |
|---|---|---|---|---|---|
| EU-AIB-01 | AI Office (European Commission) | https://digital-strategy.ec.europa.eu/en/policies/ai-office | (à vérifier) | ⭐⭐⭐⭐⭐ | AI Act, GPAI, codes de bonne pratique |
| INT-ISO-01 | ISO — News | https://www.iso.org/news.html | (à vérifier) | ⭐⭐⭐⭐ | Normes ISO 27xxx, 42001, 31000 |
| INT-IEC-01 | IEC | https://www.iec.ch | (à vérifier) | ⭐⭐⭐⭐ | Normes IEC, cyber industriel |

---

## 7. Sources internationales (anglophones)

### 7.1 Autorités et agences

| ID | Nom | URL | RSS | Fiabilité | Thématiques |
|---|---|---|---|---|---|
| US-NIST-01 | NIST — Cybersecurity | https://www.nist.gov/cybersecurity | https://www.nist.gov/news-events/cybersecurity/rss.xml | ⭐⭐⭐⭐⭐ | Frameworks (CSF, AI RMF), bonnes pratiques |
| US-CISA-01 | CISA — Alerts | https://www.cisa.gov | https://www.cisa.gov/cybersecurity-advisories/all.xml | ⭐⭐⭐⭐⭐ | Alertes cyber globales, CVE majeures |
| INT-MITRE-01 | MITRE ATT&CK Updates | https://attack.mitre.org | (à vérifier) | ⭐⭐⭐⭐ | TTPs adversaires, threat intelligence |
| UK-ICO-01 | ICO — UK | https://ico.org.uk | https://ico.org.uk/about-the-ico/media-centre/rss/ | ⭐⭐⭐⭐ | Protection données UK (référence post-Brexit) |
| UK-NCSC-01 | NCSC — UK | https://www.ncsc.gov.uk | https://www.ncsc.gov.uk/api/1/services/v1/all-rss-feed.xml | ⭐⭐⭐⭐ | Cyber UK |

### 7.2 Threat intelligence et CVE

| ID | Nom | URL | RSS | Fiabilité | Thématiques |
|---|---|---|---|---|---|
| INT-NVD-01 | NIST NVD — CVE | https://nvd.nist.gov | https://nvd.nist.gov/feeds/xml/cve/misc/nvd-rss-analyzed.xml | ⭐⭐⭐⭐⭐ | CVE, scoring CVSS |
| INT-THN-01 | The Hacker News | https://thehackernews.com | https://feeds.feedburner.com/TheHackersNews | ⭐⭐⭐ | Actualité cyber globale |
| INT-BLEEPING-01 | BleepingComputer | https://www.bleepingcomputer.com | https://www.bleepingcomputer.com/feed/ | ⭐⭐⭐ | Cyber, ransomware, incidents |
| INT-KREBS-01 | Krebs on Security | https://krebsonsecurity.com | https://krebsonsecurity.com/feed/ | ⭐⭐⭐⭐ | Investigation cyber |
| INT-SCHNEIER-01 | Schneier on Security | https://www.schneier.com | https://www.schneier.com/feed/atom/ | ⭐⭐⭐⭐ | Analyse cyber, cryptographie |

### 7.3 IA et gouvernance

| ID | Nom | URL | RSS | Fiabilité | Thématiques |
|---|---|---|---|---|---|
| INT-OECD-01 | OECD AI Policy Observatory | https://oecd.ai | (à vérifier) | ⭐⭐⭐⭐ | Politique IA internationale |
| INT-PARTNERSHIPAI-01 | Partnership on AI | https://partnershiponai.org | (à vérifier) | ⭐⭐⭐ | Bonnes pratiques IA |
| INT-FUTURE-01 | Future of Life Institute | https://futureoflife.org | (à vérifier) | ⭐⭐⭐ | IA, risques systémiques |

---

## 8. Sources MENA (zone Maghreb / Moyen-Orient — différenciation Mounir)

| ID | Nom | URL | RSS | Fiabilité | Thématiques |
|---|---|---|---|---|---|
| MA-CNDP-01 | CNDP Maroc | https://www.cndp.ma | (à vérifier) | ⭐⭐⭐⭐ | Loi 09-08, protection données Maroc |
| MA-DGSSI-01 | DGSSI Maroc | https://www.dgssi.gov.ma | (à vérifier) | ⭐⭐⭐⭐ | Cybersécurité Maroc |
| TN-INPDP-01 | INPDP Tunisie | https://www.inpdp.nat.tn | (à vérifier) | ⭐⭐⭐ | Protection données Tunisie |
| AE-DESC-01 | Dubai Electronic Security Center | https://www.desc.gov.ae | (à vérifier) | ⭐⭐⭐ | Cyber EAU |

*Cette catégorie est un atout différenciateur compte tenu des compétences linguistiques en arabe. Elle pourra justifier une offre dédiée pour des clients ciblant la zone MENA.*

---

## 9. Mapping sources / thématiques

| Thématique | Sources principales |
|---|---|
| RGPD | FR-CNIL-01/02, EU-EDPB-01, EU-EDPS-01, UK-ICO-01 |
| AI Act / IA gouvernance | EU-COM-01, EU-AIB-01, FR-CNIL-01, INT-OECD-01 |
| NIS2 | EU-ENISA-01, FR-ANSSI-01, EU-COM-01 |
| DORA | FR-AMF-01, FR-ACPR-01, EU-COM-01 |
| ISO 27xxx / 42001 | INT-ISO-01, INT-IEC-01 |
| CVE / vulnérabilités | FR-CERT-01/02, US-CISA-01, INT-NVD-01 |
| Threat intelligence | INT-MITRE-01, INT-BLEEPING-01, INT-KREBS-01 |
| Cyber stratégique | INT-SCHNEIER-01, FR-ANSSI-01, US-NIST-01 |
| MENA | MA-CNDP-01, MA-DGSSI-01, TN-INPDP-01 |

---

## 10. Sources écartées (et pourquoi)

| Source | Motif d'écart |
|---|---|
| Réseaux sociaux (X, LinkedIn) | Bruit, non vérifiable, hors périmètre v1 |
| Forums (Reddit, HackerNews) | Bruit, qualité variable, hors périmètre v1 |
| Blogs personnels non vérifiés | Fiabilité insuffisante |
| Médias généralistes | Non spécialisés, redondance avec presse spécialisée |
| Sources payantes / réservées | Hors périmètre v1 (à étudier en v2 selon ROI) |

---

## 11. Évolution du périmètre

### 11.1 Procédure d'ajout d'une source

1. Proposition documentée (qui, pourquoi, fiabilité estimée, thématique)
2. Période de probation de 4 semaines (notation ⭐ « à surveiller »)
3. Évaluation : pertinence, taux de doublons, qualité éditoriale
4. Validation Comité IA et inscription définitive (avec niveau de fiabilité ajusté)

### 11.2 Procédure de retrait

1. Détection d'un signal (faible volume, qualité dégradée, source devenue hors sujet)
2. Notification au Comité IA
3. Mise en archive — la source reste documentée mais l'ingestion est désactivée

### 11.3 Indicateur de couverture

Indicateur de pilotage à suivre :
- Nombre de sources actives par catégorie
- Nombre de publications ingérées par source / mois
- Taux d'items « gardés » après filtrage qualité (cible > 60 %)
- Identification des angles morts (thématiques sous-couvertes)

---

## 12. Notes de mise en œuvre technique (préparation Sprint 2)

| Point | Précisions |
|---|---|
| RSS à valider techniquement | Les URLs RSS notées « à vérifier » seront testées en début de Sprint 2 |
| Sources sans RSS | Web scraping respectueux (robots.txt, User-Agent identifié, limitation de fréquence) ou newsletter email avec parsing |
| Fréquence d'ingestion | Toutes les heures pour CERT-FR alertes (priorité) ; toutes les 4h pour les autres ; quotidienne pour Légifrance/EUR-Lex |
| Gestion des erreurs | Retry exponentiel + alerte si une source ne répond plus pendant 48h |
| Conformité éthique scraping | Respect robots.txt obligatoire, mention du bot dans User-Agent, pas de contournement |

---

## 13. Historique

| Version | Date | Auteur | Évolution |
|---|---|---|---|
| 1.0 | 2026 | Mounir [Nom] | Création initiale |

---

*Document interne — Hedgewood Conseil. Diffusion contrôlée.*
