#### fonctions_graphiques.R ####
# Fonctions de graphiques réutilisables (reprises de l'ancien script)
# Chargées par run_all.R avant les étapes numérotées

library(tidyverse)
library(here)

# Afficher un graphique et l'enregistrer dans data/output/figures
sauver <- function(graphique, nom_fichier, largeur = 8, hauteur = 5) {
  dossier <- here("data", "output", "figures")
  dir.create(dossier, recursive = TRUE, showWarnings = FALSE)
  print(graphique)
  ggsave(file.path(dossier, nom_fichier), graphique,
         width = largeur, height = hauteur, dpi = 150)
}

# Nuage de points Votes / Rate avec droite de régression et corrélation
graphique_correlation <- function(donnees, titre) {
  r <- cor(donnees$Votes, donnees$Rate)
  ggplot(donnees, aes(x = Votes, y = Rate)) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE, color = "red") +
    annotate("text", x = max(donnees$Votes), y = min(donnees$Rate),
             label = paste("Corrélation =", round(r, 2)),
             hjust = 1, vjust = 0, size = 4, fontface = "bold") +
    labs(x = "Votes", y = "Notes", title = titre) +
    theme_classic(base_size = 12) +
    theme(plot.title = element_text(hjust = 0.5))
}

# Histogramme + densité d'une variable
graphique_distribution <- function(donnees, variable, titre) {
  ggplot(donnees, aes(x = .data[[variable]])) +
    geom_histogram(aes(y = after_stat(density)), binwidth = 1, fill = "skyblue", color = "black") +
    geom_density(alpha = 0.5, fill = "orange", color = "black") +
    labs(title = titre, x = variable, y = "Densité") +
    theme_classic() +
    theme(plot.title = element_text(hjust = 0.5))
}

# Boxplot d'une variable par groupe (ex. Rate par Type)
graphique_boxplot <- function(donnees, x, y, titre) {
  ggplot(donnees, aes(x = .data[[x]], y = .data[[y]], fill = .data[[x]])) +
    geom_boxplot() +
    labs(x = x, y = y, title = titre) +
    theme_classic() +
    theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
}