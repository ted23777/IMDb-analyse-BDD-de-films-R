# =====================================================================
#### 02_exploration.R ####
# Rôle   : découvrir le jeu de données, sans rien modifier
# Entrée : data/processed/01_brut.rds
# Ce script ne modifie AUCUNE donnée.
# =====================================================================

library(tidyverse)
library(psych)
library(here)

df <- readRDS(here("data", "processed", "01_brut.rds"))

#### 1. Aperçu général ####
dim(df)          # nombre de lignes et de colonnes
names(df)        # noms des colonnes
head(df)         # premières lignes
str(df)          # structure : type de chaque colonne

#### 2. Type de chaque colonne ####
lapply(df, class)

#### 3. Statistiques descriptives ####
summary(df)
describe(df)

#### 4. Valeurs manquantes par colonne ####
colSums(is.na(df))

#### 5. Répartition des films et des séries ####
table(df$Type)

#### 6. Doublons ####
sum(duplicated(df))