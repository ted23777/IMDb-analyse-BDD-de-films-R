#### 03_nettoyage.R ####
# Rôle   : produire une table propre, prête pour l'analyse
# Entrée : data/processed/01_brut.rds
# Sortie : data/processed/03_propre.rds
# Chaque règle appliquée ici doit être notée dans docs/journal.md

library(tidyverse)
library(here)
source(here("src", "fonctions", "fonctions_nettoyages.R"))  # charge compter_lignes(), convertir_en_nombre()

df <- readRDS(here("data", "processed", "01_brut.rds"))

#### Paramètres (à valider après lecture de l'exploration) ####
seuil_votes <- 1000   # nombre minimal de votes pour qu'une note soit fiable

#### 1. Supprimer les doublons ####
df_avant <- df
df <- distinct(df)
compter_lignes(df_avant, df, "Doublons")

#### 2. Convertir les colonnes numériques ####

df$Votes <- gsub(",", "", df$Votes) # Votes est écrit avec des séparateurs de milliers ("1,234") : on retire les virgules d'abord
df <- convertir_en_nombre(df, "Date")
df <- convertir_en_nombre(df, "Rate")
df <- convertir_en_nombre(df, "Votes")
df <- convertir_en_nombre(df, "Duration")
df <- convertir_en_nombre(df, "Episodes")

#### 3. Supprimer les lignes sans Date, Rate ou Votes ####
df_avant <- df
df <- drop_na(df, Date, Rate, Votes)
compter_lignes(df_avant, df, "Valeurs manquantes (Date, Rate, Votes)")

#### 4. Garder uniquement les films et les séries ####
df_avant <- df
df <- filter(df, Type %in% c("Film", "Series"))
compter_lignes(df_avant, df, "Type Film / Series")

#### 5. Écarter les titres avec trop peu de votes ####
df_avant <- df
df <- filter(df, Votes >= seuil_votes)
compter_lignes(df_avant, df, paste("Seuil de", seuil_votes, "votes"))

#### 6. Sauvegarder la table propre ####
saveRDS(df, here("data", "processed", "03_propre.rds"))
message("Table propre : ", nrow(df), " lignes")