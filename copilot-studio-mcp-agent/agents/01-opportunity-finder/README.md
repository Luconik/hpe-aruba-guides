# HPE France Opportunity Finder

Assistant Copilot Studio destiné à produire une vue factuelle des opportunités utiles aux Sales Engineers.

## Objectif

Croiser un référentiel de couverture et un système d’opportunités afin de présenter un dashboard lisible : pipeline, opportunités ouvertes, comptes concernés et qualité des données.

## Architecture fonctionnelle

- Référentiel de couverture SE.
- Outil de requête sur le système d’opportunités.
- Mapping d’ownership validé avant la recherche.
- Réponse structurée avec limites et erreurs explicites.

## Garde-fous

- Ne pas générer de recommandation stratégique par défaut.
- Ne pas inventer de montant, de date ou de mapping.
- Signaler les données absentes ou les erreurs de source.
- Utiliser des données synthétiques dans toute démonstration publique.

## Démonstration

- [Réponse dans Teams](../../captures/opportunity-finder/09-teams-demo.png)
- [Vue Tools](../../captures/opportunity-finder/03-tools-overview.png)
- [Configuration/publication](../../captures/opportunity-finder/05-publication.png)

## Documentation complémentaire

- [Fiche publique](PUBLIC.md)
- [Fiche de travail](INTERNAL.md)
- [Captures de l’agent](../../captures/opportunity-finder/)

> Les détails CRM, les noms de connexions, les champs internes et les données commerciales restent hors de cette page publique.
