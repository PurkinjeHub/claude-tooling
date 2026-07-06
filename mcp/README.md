# mcp/

Serveurs MCP partagés par l'équipe.

## Deux façons d'ajouter un serveur ici

**Un sous-dossier avec son propre code** (comme `leomed-mcp/`) — quand le serveur est un vrai petit projet (dépendances, script, config personnelle par personne). Chaque sous-dossier gère son propre `.gitignore` pour ses fichiers de config personnels ; Git respecte les `.gitignore` imbriqués sans conflit avec celui de la racine.

**Un simple `.mcp.json`** — pour un serveur distant (HTTP) sans code à maintenir, juste une définition à partager. Dans ce cas :
```json
{
  "mcpServers": {
    "nom-serveur": {
      "type": "http",
      "url": "https://...",
      "headers": { "Authorization": "Bearer ${NOM_TOKEN}" }
    }
  }
}
```
**Jamais de secret en dur dans ce fichier** — toujours `${VAR}` avec la valeur réelle dans l'environnement de chaque personne. Si un jeton finit par erreur dans un fichier commité, le révoquer immédiatement (le retirer du fichier ne suffit pas, l'historique Git le garde).

## Portée : uniquement ce qui est global

Un serveur qui n'a de sens que pour un projet donné et qui se configure au **scope projet** (`.mcp.json` à la racine de ce projet) devrait vivre dans le repo de ce projet, pas ici. `leomed-mcp/` est ici parce qu'il est enregistré au **scope utilisateur** — disponible partout, peu importe le dossier ouvert — même si son rôle est de piloter spécifiquement les apps LeoMed.

## Serveurs actuels

| Dossier | Rôle | Scope d'enregistrement |
|---|---|---|
| `leomed-mcp/` | Démarre/arrête/surveille les 3 apps LeoMed en local (hub, api, webapp) | Utilisateur (`-s user`) |
