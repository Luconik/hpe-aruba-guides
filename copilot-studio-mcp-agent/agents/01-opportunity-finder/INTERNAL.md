# HPE France Opportunity Finder — fiche de travail

> Fiche interne de référence issue de l'analyse Claude et des captures. Les noms et connexions réels doivent être remplacés avant toute publication.

## Objectif

Assistant de génération de dashboards factuels à partir de données commerciales et de couverture SE. La version publique devra décrire ce cas d'usage de manière générique, sans exposer de CRM, de liste SharePoint, de champ interne ou de donnée réelle.

## Architecture observée

- Knowledge documentaire : aucune selon la fiche source.
- Sources/outils : CRM et référentiel de couverture ; les noms réels sont à remplacer par `[CRM_CONNECTION]`, `[KNOWLEDGE_SITE]` et `[COVERAGE_LIST]`.
- Recherche web : indiquée comme activée dans la fiche source ; à confirmer dans les captures.
## Captures associées

- [10.59.02 — vue générale/instructions](../../captures/opportunity-finder/01-overview-instructions.png)
- [10.59.59 — détail de l’agent](../../captures/opportunity-finder/02-agent-details.png)
- [11.00.23 — onglet Tools](../../captures/opportunity-finder/03-tools-overview.png)
- [11.00.47 — détail des outils](../../captures/opportunity-finder/04-tool-details.png)
- [11.01.37 — configuration/publication](../../captures/opportunity-finder/05-publication.png)
- [11.02.13 — canaux/publication](../../captures/opportunity-finder/06-publication-channels.png)
- [11.02.36 — distribution](../../captures/opportunity-finder/07-distribution.png)
- [11.03.01 — partage](../../captures/opportunity-finder/08-sharing.png)

## Démonstration Teams

- [11.15.37 — réponse de HPE France Opportunity Finder](../../captures/opportunity-finder/09-teams-demo.png)

Cette capture est caviardée et associée à cet agent.

## Garde-fous fonctionnels à documenter publiquement

- privilégier les données factuelles ;
- ne pas inventer de valeurs manquantes ;
- distinguer les données de couverture des données d'opportunité ;
- signaler les erreurs de source ;
- présenter les limites et la qualité des données.

## Éléments internes à conserver uniquement en privé

- prompt complet ;
- noms de personnes et adresse e-mail ;
- noms de connexions ;
- noms de listes/sites ;
- champs CRM personnalisés ;
- données commerciales et métriques d'usage.

## À confirmer à partir des captures

- date et statut exacts ;
- canaux effectivement publiés ;
- détail des outils et flow ;
- comportement de la réponse Teams ;
- capture publique retenue.
