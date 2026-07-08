---
name: pr-new
description: Crée un PR à partir de la branche courante et l'envoie en révision
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *), Read(.claude/pr-config.json)
---

# /pr-new — Créer et envoyer un PR en révision

## Étapes

1. Identifier la branche courante (`git branch --show-current`) et en extraire l'ID du billet (dernier segment après `/`). Détecter la branche parente :
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
      Assurez-vous de rebaser votre branche sur un parent existant avant de relancer /pr-new.
   ```

2. Identifier les commits depuis la branche parente (excluant les merges) :
   ```
   git log origin/${PARENT}..HEAD --no-merges --format="%s"
   ```

3. Merger la branche parente dans la branche courante :
   ```
   git fetch origin
   git merge origin/${PARENT}
   ```
   Si conflits : les afficher clairement et aider à les résoudre avant de continuer.

4. Lire le billet Linear (`mcp__claude_ai_Linear__get_issue`) pour obtenir le titre. Si le billet n'est pas disponible, utiliser le dernier titre mémorisé ou demander à l'utilisatrice.

5. Générer des bullets propres pour chaque commit :
   - Reformuler si le message est flou ou trop technique
   - Garder court — une ligne par commit, pas de roman
   - Format : `- [description claire de ce qui a changé]`

6. Lire `.claude/pr-config.json` à la racine du repo pour obtenir les reviewers par défaut.

7. Construire l'aperçu du PR :
   ```
   Titre    : [[id]] [titre du billet Linear]
   Branche  : [branche courante] → [branche parente]
   Assignee : @me
   Reviewers: [liste depuis pr-config.json]
   
   Description :
   [bullets générés]
   ```

8. **Demander confirmation** avant de procéder. Proposer de modifier le titre si désiré.

9. Si confirmé :
   ```
   git push -u origin HEAD
   gh pr create \
     --title "[[id]] [titre]" \
     --body "[description bullets]" \
     --assignee "@me" \
     --reviewer "[reviewers]" \
     --base ${PARENT}
   ```

10. Afficher l'URL du PR créé.

11. Passer le billet Linear en **In Code Review** :
    ```
    mcp__claude_ai_Linear__save_issue(id: "[id]", state: "In Code Review")
    ```

---
*Commande créée par le setup flux Git/PR — 2026-06-04*
