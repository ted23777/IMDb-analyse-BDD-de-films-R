# =====================================================================
# 01_import.R
# Rôle   : lire le fichier brut et le sauvegarder tel quel
# Entrée : data/raw/imdb.csv
# Sortie : data/processed/01_brut.rds

library(tidyverse)
library(here)

# Lire le fichier brut
IMDb <- read.csv(here("data", "raw", "imdb.csv"), stringsAsFactors = FALSE)


# Sauvegarder une copie pour les étapes suivantes (le CSV d'origine n'est jamais modifié)
dir.create(here("data", "processed"), showWarnings = FALSE)
saveRDS(IMDb, here("data", "processed", "01_brut.rds"))
