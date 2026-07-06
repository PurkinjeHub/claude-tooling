---
name: pr-complete
description: Finalise un PR approuvé — squash merge, suppression des branches, billet Linear en In QA
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *)
---

# /pr-complete — Finaliser un PR après approbation

## Étapes

1. Identifier la branche courante (`git branch --show-current`) et en extraire l'ID du billet. Détecter la branche parente :
   ```
   CURRENT=$(git branch --show-current)
   PARENT=$(git log --simplify-by-decoration --pretty=format:'%D' HEAD \
     | grep -v "^$" \
     | awk 'NR==2' \
     | tr ',' '\n' | sed 's/^ *//' \
     | grep -v "HEAD" | sed 's/origin\///' \
     | grep -v "^${CURRENT}$" \
     | head -1)
   PARENT=${PARENT:-main}
   ```
   Vérifier que la branche parente existe encore sur le remote :
   ```
   git ls-remote --exit-code origin ${PARENT}
   ```
   Si elle n'existe plus → afficher et arrêter :
   ```
   🛑 La branche parente '${PARENT}' n'existe plus sur le remote.
      Assurez-vous de rebaser votre branche sur un parent existant avant de relancer /pr-complete.
   ```

2. Vérifier qu'un PR existe et est approuvé :
   ```
   gh pr view --json number,url,reviewDecision,state,baseRefName
   ```
   - Si aucun PR : avertir et arrêter.
   - Si le PR n'est pas approuvé : afficher l'état et demander si on veut quand même continuer.

3. Afficher un résumé et **demander confirmation** :
   ```
   PR #[num] : [titre]
   État     : [reviewDecision]
   Cible    : [branche courante] → ${PARENT}
   Action   : squash merge + suppression de la branche distante et locale

   Confirmer ? (oui/non)
   ```

4. Si confirmé :
   ```
   gh pr merge --squash --delete-branch
   ```

5. Retourner sur la branche parente et puller :
   ```
   git checkout ${PARENT}
   git pull origin ${PARENT}
   ```

6. Supprimer la branche locale si elle existe encore :
   ```
   git branch -d [branche]
   ```
   (utiliser `-D` si nécessaire, en avertissant)

7. Confirmer : branche supprimée, on est sur `${PARENT}` à jour.

8. Passer le billet Linear en **In QA** :
   ```
   mcp__claude_ai_Linear__save_issue(id: "[id]", state: "In QA")
   ```

---
*Commande créée par le setup flux Git/PR — 2026-06-04*
