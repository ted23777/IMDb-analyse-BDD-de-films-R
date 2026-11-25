# Choix et cheminement du projet

Ce document retrace les décisions prises pendant la refonte du projet, **dans l'ordre où elles ont été prises**, avec leur raison. Il complète `journal.md` (le « quoi ») en expliquant le « pourquoi ».

---

## 1. Point de départ : la version d'exercice

La première version (`v0-exercice`) tenait en un seul script de 380 lignes. Une revue de code a fait ressortir :

| Problème | Conséquence |
|---|---|
| `as.numeric()` appliqué sans contrôle | des milliers de valeurs devenaient `NA` sans aucun message |
| La colonne `Rate_2` était générée sans centrer-réduire `Rate` | le test apparié détectait une différence créée artificiellement |
| `t.test(..., paired = TRUE)` en formule | erreur depuis R 4.4 |
| Des fonctions définies mais jamais appelées, et le même graphique recopié 3 fois | erreurs de copier-coller (un titre « séries » sur un graphique de films) |
| Des questions d'exercice (« autant de films que de séries ? ») | aucune décision métier éclairée |

**Choix : repartir de zéro** en suivant une méthode de projet, plutôt que de corriger le script ligne par ligne. L'ancienne version est conservée sous le tag `v0-exercice`.

---

## 2. Méthode suivie

Ordre retenu, inspiré de CRISP-DM :

1. Problématique métier et KPI
2. Environnement de travail
3. Compréhension des données (exploration)
4. Nettoyage
5. Analyse
6. Restitution et documentation

**Deux ajustements par rapport à l'idée de départ :**
- l'environnement est mis en place **avant** le nettoyage, puisqu'on nettoie avec du code ;
- une étape d'**exploration** est ajoutée avant le nettoyage : on ne nettoie pas ce qu'on n'a pas encore regardé.

La documentation s'écrit au fil de l'eau (`journal.md`, ce fichier), puis est finalisée dans le README.

---

## 3. Problématique métier

**Commanditaire fictif :** l'équipe acquisition d'une plateforme de streaming.
**Décision à éclairer :** quels contenus privilégier pour maximiser la satisfaction des abonnés ?

| # | Question | KPI |
|---|---|---|
| Q1 | Films ou séries : lesquels sont les mieux notés ? | note médiane, taux d'excellence (Rate ≥ 8) |
| Q2 | Quels genres performent le mieux ? | note médiane et volume par genre |
| Q3 | La popularité va-t-elle avec la qualité ? | corrélation de Spearman votes / note |
| Q4 | Les contenus récents sont-ils mieux notés ? | note médiane par décennie |
| Q5 | Existe-t-il une durée idéale ? | note par tranche de durée |

**Règle fixée avant l'analyse :** les questions, les KPI et les seuils sont écrits et commités **avant** de voir les résultats, pour éviter de choisir les questions qui « donnent quelque chose ». La problématique détaillée sera rédigée dans le README.

---

## 4. Structure du dépôt

| Choix | Raison |
|---|---|
| Projet RStudio + `here()` | aucun chemin absolu, donc le projet tourne sur n'importe quelle machine |
| `renv` | figer les versions des packages : l'erreur `t.test` de la v0 venait d'un changement de version de R |
| `data/raw/` en lecture seule | le fichier d'origine n'est jamais modifié ; tout le reste est régénérable |
| `data/processed/` et `data/output/` ignorés par Git | ce sont des fichiers générés : `run_all.R` les recrée |
| `src/fonctions/` séparé des étapes `src/01_…05_` | les fonctions sont les outils, les étapes sont la recette ; plus de copier-coller |
| `src/fonctions/` plutôt que `R/` à la racine | le projet est une analyse, pas un package ; tout le code est regroupé sous `src/`, comme dans les projets Python |
| Scripts numérotés + `run_all.R` | l'ordre d'exécution se lit dans les noms ; une seule commande relance tout |
| Chaque script charge ses propres fonctions | un script peut tourner seul (l'erreur `could not find function "compter_lignes"` a motivé ce choix) |
| Noms en minuscules, sans espace | les espaces cassent les commandes, et les majuscules posent problème sous Linux |
| Une branche par étape, partie de `main` | historique lisible ; commits au format `type(portée): message` |

**Choix de simplicité :** une première version de l'exploration, très générique, a été jugée trop spécifique. Elle a été réécrite avec les fonctions de base (`str`, `summary`, `describe`, `table`…). Les cas particuliers sont traités au moment où ils apparaissent.

---

## 5. Ce que l'exploration a révélé

Fichier brut : **6 178 lignes, 14 colonnes**, 4 446 films et 1 732 séries, de 1922 à 2023.

| Constat | Preuve dans la console | Conséquence |
|---|---|---|
| `Rate`, `Votes`, `Duration` et `Episodes` sont lus comme du **texte** | `lapply(df, class)` renvoie `"character"` | une conversion est nécessaire au nettoyage |
| `Votes` utilise une virgule comme séparateur de milliers | `"107,163"` | `as.numeric()` le transforme en `NA` |
| `Episodes` vaut `"-"` pour les films | `head(df)` | `NA` attendu pour tous les films |
| `colSums(is.na(df))` vaut 0 partout | les vides sont écrits en texte (`"No Rate"`, `"None"`, `"-"`) | les manquants sont **cachés** : ils n'apparaissent qu'à la conversion |
| 1 150 lignes en double | `sum(duplicated(df))` | doublons à supprimer |
| Les colonnes de contenu (`Nudity`…) contiennent aussi `"No Rate"` | 5 modalités par colonne | à traiter seulement si on s'en sert |

---

## 6. Décisions de nettoyage

| Étape | Effet | Raison |
|---|---|---|
| Suppression des doublons stricts (`distinct`) | −1 150 lignes | lignes identiques sur les 14 colonnes, donc aucune information perdue |
| Retrait des virgules dans `Votes` | 4 816 → 153 NA | **sans cette correction, la table propre était vide** : 96 % des votes étaient perdus, c'est-à-dire tous les titres de plus de 1 000 votes |
| Conversion contrôlée (`convertir_en_nombre`) | affiche le nombre de NA créés | rendre visible ce que la v0 perdait en silence |
| Suppression des titres sans `Date`, `Rate` ou `Votes` | −153 lignes | titres jamais notés (« No Rate »), inexploitables |
| Seuil de 1 000 votes | −212 lignes | une note donnée par une poignée de votants n'est pas fiable ; remplace le filtre au 10e percentile de la v0, qui dépendait des données |
| `Duration` : 248 NA conservés | 0 ligne retirée | ça ne gêne que Q5 ; filtré seulement dans cette question |
| `Episodes` : 3 586 NA conservés | 0 ligne retirée | vérifié : 100 % des films sans épisodes, 100 % des séries avec |

**Résultat : 6 178 → 4 663 titres (75 %)**, dont 3 328 films et 1 335 séries.

### Le cas des « doublons » restants

Trois titres apparaissent deux fois avec le même nom, la même année et le même type : *Dynasty* (2015), *Ghosts* (2021) et *Twin Peaks* (2017).

**Analyse :** les deux lignes de chaque paire diffèrent par le genre, la durée, le nombre d'épisodes et la classification. Par exemple, *Dynasty* a 220 épisodes sur une ligne (le format de la série des années 1980) et 108 sur l'autre ; *Twin Peaks* a 30 épisodes (la série de 1990) et 18 (la suite de 2017).

**Décision :** ce sont des séries **différentes qui portent le même nom**. Les 6 lignes sont conservées.

**Deux conséquences :**
- `Name + Date + Type` n'est pas une clé unique, donc un identifiant `id` est ajouté ;
- pour les séries, **`Date` n'est pas l'année de lancement** (la *Dynasty* des années 1980 est datée de 2015). La question **Q4 est limitée aux films**.

---

## 7. Choix méthodologiques de l'analyse

| Choix | Raison |
|---|---|
| Médiane plutôt que moyenne | elle est moins sensible aux notes extrêmes |
| Test de Welch plutôt que « Shapiro ⇒ non paramétrique » | avec plusieurs milliers de titres, le t-test est robuste ; Welch ne suppose pas des variances égales ; Shapiro est inutilisable au-delà de 5 000 valeurs et trop sensible avec un grand échantillon |
| Taille d'effet systématique (d de Cohen, r) | avec 4 663 titres, presque tout est « significatif » ; la taille d'effet dit si la différence compte vraiment |
| Spearman plutôt que Pearson (Q3) | les votes sont très asymétriques ; Spearman travaille sur les rangs |
| Une ligne par genre (Q2) | un titre « Crime, Drama » compte dans les deux genres |
| Au moins 30 titres par genre (Q2) | en dessous, la médiane d'un genre n'est pas fiable |
| Q2 descriptive, sans un test par genre | éviter les faux positifs dus aux comparaisons multiples |
| Q4 et Q5 limitées aux films | `Date` n'est pas fiable pour les séries ; leur `Duration` est la durée d'un épisode |
| Seuils fixés à l'avance (excellence ≥ 8, tranches de durée) | ne pas ajuster les paramètres après avoir vu les résultats |

### Analyses abandonnées

| Analyse de la v0 | Raison de l'abandon |
|---|---|
| Chi² « autant de films que de séries ? » | ne répond à aucune question métier ; la répartition reste un simple chiffre descriptif |
| `Rate_2` simulé et tests appariés | une donnée inventée n'a pas sa place dans une analyse métier |
| Packages `lme4`, `MuMIn`, `emmeans` | jamais utilisés |

---

## 8. Limites connues

- Le fichier est un **extrait** d'IMDb, pas sa totalité : les conclusions valent pour cet échantillon de 4 663 titres.
- Une note IMDb mesure **l'enthousiasme des votants**, qui se sélectionnent eux-mêmes, et non une qualité objective.
- Pour les séries, la signification exacte de `Date` reste inconnue.