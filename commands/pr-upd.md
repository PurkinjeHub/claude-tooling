---
name: pr-upd
description: Met à jour un PR existant avec les nouveaux commits de la branche courante
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *)
---

# /pr-upd — Mettre à jour un PR existant

## Étapes

1. Identifier la branche courante, détecter la branche parente et vérifier qu'elle existe sur le remote :
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
   git ls-remote --exit-code origin ${PARENT}
   ```
   Si la branche parente n'existe plus → afficher et arrêter :
   ```
   🛑 La branche parente '${PARENT}' n'existe plus sur le remote.
      Assurez-vous de rebaser votre branche sur un parent existant avant de relancer /pr-upd.
   ```
   Vérifier qu'un PR existe :
   ```
   gh pr view --json number,url,body
   ```
   Si aucun PR : avertir et arrêter.

2. Identifier les commits non encore poussés (entre `origin/${CURRENT}` et `HEAD`, excluant merges) :
   ```
   git log origin/${CURRENT}..HEAD --no-merges --format="%s"
   ```
   Si aucun commit nouveau : le signaler et demander si on veut quand même mettre à jour.

3. Merger la branche parente dans la branche courante :
   ```
   git fetch origin
   git merge origin/${PARENT}
   ```
   Si conflits : les afficher clairement et aider à les résoudre avant de continuer.

4. Générer des bullets propres pour les **nouveaux commits seulement** :
   - Reformuler si le message est flou ou trop technique
   - Garder court — une ligne par commit
   - Format : `- [description claire de ce qui a changé]`

5. Récupérer la description actuelle du PR (`gh pr view --json body`).

6. Construire l'aperçu de la mise à jour :
   ```
   Branche  : [branche courante]
   PR #[num] : [url]
   
   Nouveaux bullets à ajouter :
   [bullets générés]
   
   Description finale (aperçu) :
   [description actuelle + nouveaux bullets]
   ```

7. **Demander confirmation** avant de procéder.

8. Si confirmé :
   ```
   git push
   gh pr edit --body "[description actuelle + nouveaux bullets]"
   ```

9. Confirmer : PR mis à jour, URL affichée.

---
*Commande créée par le setup flux Git/PR — 2026-06-04*
