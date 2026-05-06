# Registre des dérogations de sécurité

**Référence :** REG-DEROG-001
**Version :** 1.0
**Date d'ouverture :** 2026
**Propriétaire :** Responsable veille (Mounir [Nom])
**Validation :** RSSI
**Périodicité de revue :** Trimestrielle (ou à fermeture d'une dérogation)

---

## Préambule

Le présent registre liste l'ensemble des **dérogations volontaires aux exigences de sécurité par défaut** de la plateforme. Chaque dérogation est documentée, justifiée, assortie de mesures compensatoires, et soumise à une **date d'échéance**.

Une dérogation n'est pas un manquement : c'est un **risque assumé, tracé et planifié** pour résolution. C'est une exigence ISO 27001 (clause 8.3 — traitement des risques) et une bonne pratique ISO 42001.

Toute dérogation expirée doit être renouvelée formellement ou refermée par mise en conformité.

---

## Index des dérogations

| ID | Sujet | Système | Statut | Échéance |
|---|---|---|---|---|
| DEROG-001 | Cookies non sécurisés sur n8n | SYS-IA-001 | Ouverte | Fin Sprint 4 |

---

## Fiche détaillée — DEROG-001

### Identification

| Champ | Valeur |
|---|---|
| Identifiant | DEROG-001 |
| Date d'ouverture | 2026 |
| Demandeur | Mounir [Nom] |
| Validation | À recueillir auprès du RSSI |
| Statut | Ouverte |
| Date d'échéance | Fin Sprint 4 (mise en place HTTPS) |

### Description de la dérogation

**Exigence dérogée :** la configuration par défaut de n8n impose des cookies sécurisés (flag `Secure`) qui ne fonctionnent qu'en HTTPS.

**Configuration appliquée en dérogation :** `N8N_SECURE_COOKIE=false` — les cookies de session ne portent pas le flag `Secure`, ce qui permet l'accès via HTTP en attendant la mise en place de TLS.

### Justification

- Le système est en **phase de POC** (Sprints 2 à 3), exposé uniquement sur le réseau local (`192.168.1.0/24`)
- La mise en place de HTTPS (certificat, reverse proxy) est planifiée au **Sprint 4**, sur le périmètre industrialisation
- Le coût/délai de mise en place HTTPS dès le Sprint 2 ralentirait le projet sans bénéfice de sécurité substantiel sur un réseau local de confiance

### Évaluation du risque

| Élément | Valeur |
|---|---|
| Risque concerné | Vol de cookies de session en cas d'écoute du trafic local |
| Vraisemblance | Faible — réseau domestique de confiance, accès SSH limité, UFW restrictif (port 5678 ouvert uniquement sur 192.168.1.0/24) |
| Gravité | Modérée — le compte est protégé par mot de passe fort, l'attaquant doit déjà être sur le réseau local |
| Niveau de risque résiduel | **Acceptable** sur la durée du Sprint, **inacceptable** en production |

### Mesures compensatoires en place

- Pare-feu UFW restrictif : port 5678 accessible uniquement depuis `192.168.1.0/24`
- Mots de passe forts (générés via `openssl rand -base64 32`)
- HTTP Basic Auth activé en couche supplémentaire avant l'application n8n
- Réseau Wi-Fi domestique avec WPA2/WPA3
- Aucune donnée à caractère personnel manipulée par n8n pendant la phase POC
- Aucune donnée client réelle pendant la phase POC

### Plan de retour à la conformité

| Étape | Échéance | Responsable | Statut |
|---|---|---|---|
| Mise en place d'un reverse proxy (Caddy ou Traefik) | Sprint 4 | Mounir | À faire |
| Génération d'un certificat TLS (Let's Encrypt si exposition future, sinon auto-signé interne) | Sprint 4 | Mounir | À faire |
| Réactivation `N8N_SECURE_COOKIE=true` et `N8N_PROTOCOL=https` | Sprint 4 | Mounir | À faire |
| Tests fonctionnels post-bascule | Sprint 4 | Mounir | À faire |
| Fermeture formelle de DEROG-001 | Sprint 4 | RSSI | À faire |

### Historique

| Date | Événement | Auteur |
|---|---|---|
| 2026 | Création de la dérogation | Mounir [Nom] |

---

## Procédure d'ouverture d'une dérogation

1. Identification du besoin de dérogation par le porteur du système
2. Documentation de la justification, du risque et des mesures compensatoires
3. Validation par le RSSI (ou Comité IA pour les sujets IA)
4. Inscription au présent registre avec date d'échéance
5. Information du Comité IA lors de la revue trimestrielle

## Procédure de revue trimestrielle

À chaque revue, pour chaque dérogation ouverte :

- Toujours justifiée ?
- Mesures compensatoires toujours en place ?
- Plan de retour à la conformité tient-il son échéance ?
- Faut-il renouveler, prolonger, ou fermer ?

Toute dérogation **dépassant son échéance sans renouvellement formel** est considérée comme un **incident de conformité** à traiter.

---

*Document interne — Hedgewood Conseil. Diffusion contrôlée.*
