# LeoMed Dev Env MCP

Serveur MCP pour piloter l'environnement de dev LeoMed (hub, api, webapp) depuis une conversation Claude.

## ⚠️ Si tu as déjà ce serveur enregistré sous l'ancien nom `leomed-wsl`

Ce serveur vivait avant dans `~/mcp-servers/leomed`, enregistré sous le nom `leomed-wsl`. Depuis qu'il fait partie de ce repo, mets à jour l'enregistrement une fois :

```bash
claude mcp remove leomed-wsl
claude mcp add leomed -s user -- uv --directory [chemin]/claude-tooling/mcp/leomed-mcp run server.py
```

(Remplace `[chemin]` par le dossier où tu as cloné le repo.) Ta config personnelle (`~/.leomed-mcp/config.toml`) n'est pas affectée — elle reste où elle est, indépendamment de l'emplacement de `server.py`.

## Outils exposés

| Outil | Description |
|---|---|
| `status_all()` | État des 3 apps + MySQL + Redis |
| `start_app(name)` | Démarre une app en arrière-plan |
| `stop_app(name)` | Arrête une app |
| `restart_app(name)` | Stop + start |
| `tail_logs(name, lines)` | Dernières lignes de log |
| `clean_orphan_pids()` | Nettoie PID files Rails + port 4200 |

Où `name` ∈ `{"hub", "api", "webapp"}`.

## Installation (dans WSL)

Ce dossier fait partie du repo `claude-tooling` — voir le `README.md` à la racine du repo pour le cloner. Une fois cloné (ex. dans `[chemin]/claude-tooling`) :

```bash
# 1. Installer uv si pas déjà fait
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Installer les dépendances
cd [chemin]/claude-tooling/mcp/leomed-mcp
uv sync

# 3. Vérifier que lsof est dispo
which lsof || sudo apt install lsof
```

## Configuration

Chaque personne a sa propre config, non commitée dans le repo.

```bash
mkdir -p ~/.leomed-mcp
cp config.example.toml ~/.leomed-mcp/config.toml
```

Édite `~/.leomed-mcp/config.toml` : ajuste `path` de chaque app pour qu'il pointe vers
tes vrais dossiers WSL, et le `start_cmd` du webapp selon ton `package.json` si besoin.

Le serveur cherche la config dans cet ordre :
1. Variable d'environnement `LEOMED_MCP_CONFIG` (chemin absolu vers un fichier `.toml`)
2. `~/.leomed-mcp/config.toml`

Si tu préfères garder ta config ailleurs (ex. dans un dotfiles repo), pointe
`LEOMED_MCP_CONFIG` dessus plutôt que d'utiliser l'emplacement par défaut.

## Tester avec le MCP Inspector

Avant de brancher Claude, valide que le serveur fonctionne :

```bash
cd [chemin]/claude-tooling/mcp/leomed-mcp
npx @modelcontextprotocol/inspector uv run server.py
```

Ça ouvre une UI web. Tu peux y voir tes 6 outils et les appeler manuellement.

## Brancher Claude Desktop (Windows)

Édite `%APPDATA%\Claude\claude_desktop_config.json` :

```json
{
  "mcpServers": {
    "leomed": {
      "command": "wsl.exe",
      "args": [
        "-d", "Ubuntu",
        "--",
        "/home/[ton-user-linux]/.local/bin/uv",
        "--directory",
        "/home/[ton-user-linux]/[chemin]/claude-tooling/mcp/leomed-mcp",
        "run",
        "server.py"
      ]
    }
  }
}
```

Remplace `Ubuntu` par le nom exact de ta distro WSL (`wsl -l` pour le voir) et
`[ton-user-linux]` par ton username Linux. Redémarre Claude Desktop.

## Brancher Claude Code (dans VS Code, lancé en WSL)

```bash
claude mcp add leomed -- uv --directory [chemin]/claude-tooling/mcp/leomed-mcp run server.py
```

## Brancher Claude Code (depuis Windows, WSL en sous-processus)

```bash
claude mcp add leomed -s user -- wsl.exe -- /home/[ton-user-linux]/.local/bin/uv --directory /home/[ton-user-linux]/[chemin]/claude-tooling/mcp/leomed-mcp run server.py
```

Puis dans Claude Code :
```
/mcp
```
…pour vérifier qu'il est listé et "connected".

## Exemple d'utilisation

Une fois branché, tu peux simplement écrire en chat :

> *« Démarre mes apps LeoMed »* → Claude appelle `status_all()`, voit ce qui manque, appelle `start_app()` pour chaque.
>
> *« Le webapp répond plus »* → Claude check `status_all()`, regarde `tail_logs("webapp", 100)`, propose un diagnostic.
>
> *« Nettoie et redémarre tout »* → `clean_orphan_pids()` puis `start_app` pour chaque app.

## Prochaines étapes possibles

- Ajouter un outil `run_migration(app)` pour `rails db:migrate`
- Ajouter `recent_errors(app, since)` qui grep ERROR/FATAL dans les logs
- Ajouter `check_db_connection()` qui fait un vrai `SELECT 1` sur MySQL
