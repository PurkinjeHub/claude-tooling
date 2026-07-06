"""
LeoMed Dev Environment MCP Server
==================================

Expose des outils pour piloter l'environnement de dev LeoMed
(leomed-hub, leomed-api, leomed-webapp) depuis une conversation Claude.
"""

import os
import tomllib
from mcp.server.fastmcp import FastMCP
import subprocess
import socket
from pathlib import Path
from typing import Literal

# =============================================================================
# CONFIGURATION
# =============================================================================
# Les chemins/ports/commandes de chaque app viennent d'un fichier config.toml
# (voir config.example.toml). Aucune donnée propre à une machine ne vit dans
# ce fichier — chacun a sa propre copie de config.toml, non commitée.
#
# Emplacement du fichier de config, dans l'ordre de priorité :
#   1. Variable d'environnement LEOMED_MCP_CONFIG (chemin absolu)
#   2. ~/.leomed-mcp/config.toml
# =============================================================================

CONFIG_ENV_VAR = "LEOMED_MCP_CONFIG"
DEFAULT_CONFIG_PATH = Path.home() / ".leomed-mcp" / "config.toml"


def _load_config() -> dict:
    config_path = Path(os.environ.get(CONFIG_ENV_VAR, DEFAULT_CONFIG_PATH)).expanduser()

    if not config_path.exists():
        raise FileNotFoundError(
            f"Fichier de config introuvable: {config_path}\n"
            f"Copie config.example.toml vers {DEFAULT_CONFIG_PATH} "
            f"(ou pointe la variable d'environnement {CONFIG_ENV_VAR} vers ton propre "
            f"fichier) et ajuste les chemins pour ton environnement."
        )

    with config_path.open("rb") as f:
        return tomllib.load(f)


_raw_config = _load_config()

APPS = {
    name: {
        "path": Path(cfg["path"]).expanduser(),
        "port": cfg["port"],
        "type": cfg["type"],
        "start_cmd": cfg["start_cmd"],
    }
    for name, cfg in _raw_config["apps"].items()
}

LOG_DIR = Path(_raw_config.get("log_dir", str(Path.home() / ".leomed-mcp" / "logs"))).expanduser()
LOG_DIR.mkdir(parents=True, exist_ok=True)

# =============================================================================

mcp = FastMCP("LeoMed Dev Env")

AppName = Literal["hub", "api", "webapp"]


def _is_port_open(port: int) -> bool:
    """True si quelque chose écoute sur localhost:port."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(0.5)
        return s.connect_ex(("127.0.0.1", port)) == 0


# -----------------------------------------------------------------------------
# Tools
# -----------------------------------------------------------------------------


@mcp.tool()
def status_all() -> str:
    """État de toutes les apps LeoMed et services dépendants (MySQL, Redis).

    À appeler en début de session ou quand quelque chose semble bizarre.
    """
    lines = ["=== LeoMed Dev Environment ==="]

    lines.append("\nApplications:")
    for name, cfg in APPS.items():
        status = "UP  " if _is_port_open(cfg["port"]) else "DOWN"
        lines.append(f"  {name:8} {status}  port {cfg['port']:<5}  ({cfg['type']})")

    lines.append("\nServices:")
    mysql_ok = _is_port_open(3306)
    redis_ok = _is_port_open(6379)
    lines.append(f"  MySQL    {'UP  ' if mysql_ok else 'DOWN'}  port 3306")
    lines.append(f"  Redis    {'UP  ' if redis_ok else 'DOWN'}  port 6379")

    return "\n".join(lines)


@mcp.tool()
def start_app(name: AppName) -> str:
    """Démarre une app LeoMed en arrière-plan.

    Les logs sont écrits dans ~/.leomed-mcp/logs/{name}.log.
    Utilise tail_logs(name) ensuite si tu veux voir ce qui se passe.

    Args:
        name: hub, api, ou webapp
    """
    if name not in APPS:
        return f"App inconnue: {name}. Disponibles: {list(APPS.keys())}"

    cfg = APPS[name]

    if _is_port_open(cfg["port"]):
        return f"{name} semble déjà tourner sur le port {cfg['port']}. Rien à faire."

    if not cfg["path"].exists():
        return f"Erreur: chemin introuvable {cfg['path']}. Vérifie ton config.toml."

    log_path = LOG_DIR / f"{name}.log"
    log_file = open(log_path, "a")

    process = subprocess.Popen(
        cfg["start_cmd"],
        cwd=str(cfg["path"]),
        stdout=log_file,
        stderr=subprocess.STDOUT,
        start_new_session=True,
    )

    return (
        f"{name} démarré (PID {process.pid}, port {cfg['port']}).\n"
        f"Logs: {log_path}\n"
        f"Attends quelques secondes puis appelle status_all() ou tail_logs('{name}')."
    )


@mcp.tool()
def stop_app(name: AppName) -> str:
    """Arrête une app LeoMed en tuant le(s) processus qui écoute(nt) sur son port.

    Args:
        name: hub, api, ou webapp
    """
    if name not in APPS:
        return f"App inconnue: {name}"

    port = APPS[name]["port"]

    try:
        result = subprocess.run(
            ["lsof", "-ti", f":{port}"],
            capture_output=True,
            text=True,
        )
        pids = [p for p in result.stdout.strip().split("\n") if p]

        if not pids:
            return f"Aucun processus n'écoute sur le port {port}. Rien à arrêter."

        for pid in pids:
            subprocess.run(["kill", "-TERM", pid])

        return f"{name} arrêté (PID(s): {', '.join(pids)})."
    except FileNotFoundError:
        return "Erreur: 'lsof' n'est pas installé. Installe-le avec: sudo apt install lsof"
    except Exception as e:
        return f"Erreur lors de l'arrêt de {name}: {e}"


@mcp.tool()
def tail_logs(name: AppName, lines: int = 50) -> str:
    """Lit les dernières lignes du log d'une app démarrée via ce MCP.

    Args:
        name: hub, api, ou webapp
        lines: nombre de lignes à retourner (défaut 50, max conseillé 500)
    """
    if name not in APPS:
        return f"App inconnue: {name}"

    log_path = LOG_DIR / f"{name}.log"

    if not log_path.exists():
        return (
            f"Aucun log à {log_path}. "
            f"L'app a-t-elle été démarrée via start_app('{name}')?"
        )

    try:
        result = subprocess.run(
            ["tail", "-n", str(lines), str(log_path)],
            capture_output=True,
            text=True,
        )
        return result.stdout or "(log vide)"
    except Exception as e:
        return f"Erreur lecture log: {e}"


@mcp.tool()
def clean_orphan_pids() -> str:
    """Nettoie les fichiers PID Rails orphelins et libère le port 4200 si bloqué.

    Reproduit la logique de ton .bat launcher. À appeler après un crash sale
    ou si une app refuse de redémarrer.
    """
    results = []

    # Rails PID files
    for name in ["hub", "api"]:
        pid_file = APPS[name]["path"] / "tmp" / "pids" / "server.pid"
        if pid_file.exists():
            try:
                pid_file.unlink()
                results.append(f"Supprimé: {pid_file}")
            except Exception as e:
                results.append(f"Erreur sur {pid_file}: {e}")

    # Port 4200 (Angular)
    try:
        result = subprocess.run(
            ["lsof", "-ti", ":4200"],
            capture_output=True,
            text=True,
        )
        pids = [p for p in result.stdout.strip().split("\n") if p]
        for pid in pids:
            subprocess.run(["kill", "-9", pid])
            results.append(f"Tué processus orphelin sur 4200 (PID {pid})")
    except FileNotFoundError:
        results.append("lsof non installé — port 4200 non vérifié.")
    except Exception as e:
        results.append(f"Erreur port 4200: {e}")

    return "\n".join(results) if results else "Rien à nettoyer, environnement propre."


@mcp.tool()
def restart_app(name: AppName) -> str:
    """Arrête puis redémarre une app. Pratique après un changement de config.

    Args:
        name: hub, api, ou webapp
    """
    stop_result = stop_app(name)
    # Petit délai pour laisser le port se libérer
    import time
    time.sleep(2)
    start_result = start_app(name)
    return f"[STOP]\n{stop_result}\n\n[START]\n{start_result}"


# -----------------------------------------------------------------------------

if __name__ == "__main__":
    mcp.run()
