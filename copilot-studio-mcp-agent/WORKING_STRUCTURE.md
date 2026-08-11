# Copilot Studio agents — structure de travail

> Document de travail. Les captures présentes à la racine ont été caviardées par l'auteur et peuvent servir aux fiches publiques. L'archive Claude et le PDF sont conservés uniquement comme références.

## Objectif

Documenter une famille d'agents Copilot Studio pour un usage Channel SE Aruba/HPE, puis produire une version publiable après revue humaine et anonymisation.

## Arborescence cible

```text
copilot-studio-agents/
├── README.md
├── agents/
│   ├── 01-opportunity-finder/
│   │   ├── INTERNAL.md
│   │   ├── PUBLIC.md
│   │   └── captures.md
│   ├── 02-presales-knowledge-advisor/
│   ├── 03-partner-customer-reference-guide/
│   ├── 04-juniper-mist-assistant/
│   └── 05-aruba-network-assistant/
├── docs/
│   ├── architecture.md
│   ├── anonymization.md
│   ├── capture-inventory.md
│   └── publishing-checklist.md
├── assets/
│   ├── original/       # non publiable, à conserver hors repo public
│   └── public/         # copies nettoyées uniquement
├── examples/
│   └── synthetic-data/
└── .gitignore
```

## Règle de publication

- Les fiches `INTERNAL.md` restent dans un espace privé.
- Les fiches `PUBLIC.md` ne contiennent que des noms fonctionnels, une architecture générique et des exemples synthétiques.
- Les captures originales restent hors du repository public.
- Aucun prompt complet, nom de tenant, nom de connexion, e-mail, client, compte, opportunité, identifiant ou métrique interne ne doit être publié sans validation explicite.

## État actuel

| Agent | Captures identifiées | Fiche source Claude | Fiche interne | Version publique |
|---|---:|---:|---|---|
| Opportunity Finder | Oui | Oui, exemple de structure | À compléter | À rédiger |
| Presales Knowledge Advisor | Oui | Référencé dans le README Claude | À compléter | À rédiger |
| Partner & Customer Reference Guide | Oui | Référencé dans le README Claude + PDF | À compléter | À rédiger |
| Juniper Mist Assistant | Architecture connue, connectivité Copilot Studio non validée | Référencé dans le README Claude | Blocage MCP à documenter/retester | Draft expérimental |
| Aruba Network Assistant | Oui | Référencé dans le README Claude | À compléter | À rédiger |

## Choix de repository

Le choix recommandé à ce stade est un repository documentaire central. Un repository par agent pourra être extrait plus tard si un agent devient un produit autonome, avec son propre cycle de vie, ses assets et ses contributeurs.
