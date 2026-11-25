# =====================================================================
# run_all.R — relance l'intégralité du projet, dans l'ordre
# Usage : ouvrir IMDb-analyse.Rproj puis source("run_all.R")
# =====================================================================

library(here)

# 1. Charger les fonctions réutilisables
#for (f in list.files(here("src", "fonctions"), pattern = "\\.R$", full.names = TRUE)) {
#  source(f)
#}

# 2. Exécuter les étapes numérotées (01_, 02_, …) dans l'ordre

library(here)

source(here("src", "01_import.R"))

source(here("src", "02_exploration.R"), echo = TRUE)  # echo = TRUE : affiche les résultats

source(here("src", "03_nettoyage.R"))

source(here("src", "04_analyse.R"), echo = TRUE)
