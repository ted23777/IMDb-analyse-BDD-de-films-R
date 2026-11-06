# Analyse statistique des films et séries IMDb avec R

Projet d'analyse exploratoire et inférentielle d'un jeu de données IMDb (films et séries) réalisé en R. Il couvre tout le cycle d'une analyse : préparation des données, traitement des valeurs extrêmes, corrélation, tests de comparaison (paramétriques et non paramétriques), tailles d'effet et visualisation avec `ggplot2`.

## Objectifs

- Identifier les films et séries les mieux notés, avant et après filtrage des titres peu votés
- Étudier la relation entre le nombre de votes et la note
- Comparer la répartition films / séries (test du Chi²)
- Comparer les notes des films et des séries (Mann-Whitney U)
- Comparer deux évaluations d'un même public (test t apparié et Wilcoxon signé), sur données simulées

## Données

Le script attend un dataframe nommé `IMDb` déjà chargé dans l'environnement R (par exemple via `read.csv()` ou l'import RStudio). Il est copié dans `df` pour ne pas modifier la base originale.

Variables utilisées :

| Variable | Description |
|---|---|
| `Type` | Catégorie du titre : `Film` ou `Series` |
| `Date` | Année de sortie |
| `Rate` | Note moyenne IMDb |
| `Votes` | Nombre de votes (en centaines de milliers) |
| `Duration` | Durée |
| `Episodes` | Nombre d'épisodes (séries) |

## Prérequis

R (version 4.x recommandée) et les packages suivants :

```r
install.packages(c("tidyverse", "psych", "car", "rstatix", "emmeans", "lme4", "MuMIn"))
```

| Package | Usage dans le projet |
|---|---|
| `tidyverse` | Manipulation des données (`dplyr`, `tidyr`) et graphiques (`ggplot2`) |
| `psych` | Statistiques descriptives (`describe`, `describeBy`) |
| `car` | Test d'homogénéité des variances (`leveneTest`) |
| `rstatix` | Tests et tailles d'effet (`wilcox_test`, `wilcox_effsize`, `cohens_d`) |
| `emmeans`, `lme4`, `MuMIn` | Chargés pour des extensions (post hoc, modèles mixtes), non utilisés dans la version actuelle |

## Déroulé de l'analyse

### 1. Préparation des données
- Exploration (`describe`, `summary`, `lapply(df, class)`)
- Conversion de `Date`, `Rate`, `Votes`, `Duration`, `Episodes` en numérique
- Suppression des lignes avec valeurs manquantes sur `Date`, `Rate` ou `Votes`

### 2. Films : meilleure note et relation votes / note
- Classement des films par note décroissante
- Corrélation de Pearson entre `Votes` et `Rate`, nuage de points avec droite de régression
- Filtrage des films sous le 10e percentile de votes, pour écarter les notes peu représentatives (une alternative par moyenne ± 3 écarts-types est fournie en commentaire)

### 3. Séries : même démarche
- Classement, filtrage au 10e percentile, corrélation et graphique

### 4. Répartition films / séries
- Fusion des deux jeux filtrés (`df2`)
- Test du Chi² d'ajustement sur la variable `Type`
- Diagramme en barres

### 5. Comparaison des notes films vs séries
- Vérification des conditions du test t : normalité (Shapiro-Wilk + histogrammes) et homogénéité des variances (Levene)
- Conditions non respectées : test de Mann-Whitney U à la place, avec taille d'effet
- Boxplot comparatif

### 6. Comparaison de deux évaluations appariées (données simulées)
- Création d'une variable `Rate_2` corrélée à 0,6 avec `Rate` (graine fixée : `set.seed(123)`), renommage de `Rate` en `Rate_1`
- Passage au format long (`df3`)
- Test t pour échantillons appariés, d de Cohen, moyennes par condition
- Graphique : points individuels, moyennes et barres d'écart-type
- Équivalent non paramétrique : test des rangs signés de Wilcoxon, taille d'effet et boxplot

## Principaux résultats

| Question | Résultat |
|---|---|
| Film le mieux noté (données brutes) | *Toma* (2021) |
| Film le mieux noté (après filtrage au 10e percentile) | *12 Angry Men* (1957) |
| Série la mieux notée (données brutes) | *Aspirants* (2004) |
| Seuil du 10e percentile de votes | 13,10 (films) ; 3,29 (séries) |

Le changement de classement après filtrage illustre l'intérêt d'écarter les titres très peu votés : une note élevée obtenue sur quelques votes n'est pas comparable à une note stable sur un large public.

## Utilisation

1. Ouvrir le script dans RStudio
2. Importer le jeu de données sous le nom `IMDb`
3. Installer les packages si nécessaire (lignes commentées en tête de script)
4. Exécuter le script section par section (`#### n. ... ####`) pour suivre l'analyse et visualiser chaque graphique

## Compétences mobilisées

Nettoyage et typage de données, traitement des valeurs extrêmes, statistiques descriptives, corrélation, vérification des conditions d'application, tests paramétriques et non paramétriques (Chi², Mann-Whitney, t apparié, Wilcoxon signé), tailles d'effet, restructuration de données (format large vers long), visualisation avec `ggplot2`.