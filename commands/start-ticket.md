---
name: start-ticket
description: Démarre le travail sur un billet Linear — crée la branche, passe le billet en In Progress, résume les tâches
argument-hint: [id-billet]
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *)
---

# /start-ticket — Démarrer le travail sur un billet Linear

**Argument requis :** `$ARGUMENTS` = identifiant du billet Linear (ex: `LOG-40`)

## Étapes

1. Vérifier qu'il n'y a aucun changement non commités (`git status`). Si oui, avertir et arrêter.

2. Détecter la branche courante et la mettre à jour :
   ```
   CURRENT_BRANCH=$(git branch --show-current)
   git pull origin ${CURRENT_BRANCH} || echo "⚠️ Impossible de pull origin/${CURRENT_BRANCH} (pas de remote?) — on continue depuis l'état local."
   ```

3. Obtenir le nom d'utilisateur GitHub et créer la branche :
   ```
   GH_USER=$(gh api user --jq .login)
   git checkout -b ${GH_USER}/[id]
   ```

4. Lire le billet Linear via l'outil MCP Linear (`mcp__claude_ai_Linear__get_issue` avec l'ID fourni).
   - Garder le titre du billet en mémoire pour `/pr-new`
   - Afficher un résumé clair de ce qu'il y a à faire : objectif, critères d'acceptation, contexte

5. Passer le billet Linear en **In Progress** :
   ```
   mcp__claude_ai_Linear__save_issue(id: "[id]", state: "In Progress")
   ```

6. Vérifier que le statut a bien été mis à jour via `mcp__claude_ai_Linear__get_issue` :
   - Si `status == "In Progress"` → continuer normalement
   - Sinon → afficher : ⚠️ Le statut n'a pas pu être mis à jour automatiquement. Faire le changement manuellement dans Linear : **In Progress**

7. Afficher confirmation : branche créée, titre du billet, statut mis à jour (ou avertissement), résumé des tâches.

   Si `CURRENT_BRANCH` ≠ `main`, afficher également :
   ```
   📌 Vous venez de créer une branche enfant depuis '${CURRENT_BRANCH}'.

      Gardez en tête que si vous complétez la branche parente avant ses
      branches enfant, GitHub fermera automatiquement tous leurs PRs ouverts.

      Règle d'or pour les branches empilées :
        → Toujours merger les branches enfant EN PREMIER,
          puis remonter vers la branche parente.
   ```

---
*Commande créée par le setup flux Git/PR — 2026-06-04*
