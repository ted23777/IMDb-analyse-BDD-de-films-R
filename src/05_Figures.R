#### 05_figures.R ####
# Rôle    : illustrer la réponse à chaque question métier (une figure par question)
# Entrées : data/processed/03_propre.rds + tables de data/output/tables/ (produites par 04_analyse.R)
# Sorties : data/output/figures/05_q1_... à 05_q5_... (.png)

library(tidyverse)
library(here)
source(here("src", "fonctions", "fonctions_graphiques.R"))

df <- readRDS(here("data", "processed", "03_propre.rds"))
dossier_tables <- here("data", "output", "tables")

# Les figures Q2, Q4 et Q5 relisent les tables de 04_analyse.R :
# les chiffres des graphiques sont donc exactement ceux de l'analyse.
q2 <- read_csv(file.path(dossier_tables, "04_q2_genres.csv"), show_col_types = FALSE)
q4 <- read_csv(file.path(dossier_tables, "04_q4_decennies_films.csv"), show_col_types = FALSE)
q5 <- read_csv(file.path(dossier_tables, "04_q5_duree_films.csv"), show_col_types = FALSE)

couleurs_type <- c(Film = "#E8A33D", Series = "#2E75B6")


#### Q1. Films ou séries ####
g1 <- graphique_boxplot(df, "Type", "Rate", "Q1 — Les séries sont mieux notées que les films") +
  scale_fill_manual(values = couleurs_type) +
  labs(y = "Note IMDb")
sauver(g1, "05_q1_films_vs_series.png", largeur = 6, hauteur = 5)


#### Q2. Genres ####
# Astuce : on colle le Type au nom du genre pour trier les barres À L'INTÉRIEUR de chaque panneau,
# puis on retire ce suffixe à l'affichage.
g2 <- q2 %>%
  mutate(genre_trie = reorder(paste(Genre, Type, sep = "___"), note_mediane)) %>%
  ggplot(aes(x = note_mediane, y = genre_trie, fill = Type)) +
  geom_col() +
  geom_text(aes(label = note_mediane), hjust = -0.15, size = 3) +
  facet_wrap(~ Type, scales = "free_y") +
  scale_y_discrete(labels = function(x) sub("___.*", "", x)) +
  scale_fill_manual(values = couleurs_type) +
  coord_cartesian(xlim = c(5, 9)) +
  labs(x = "Note médiane", y = NULL,
       title = "Q2 — Note médiane par genre",
       caption = "Genres d'au moins 30 titres. Un titre multi-genres compte dans chacun de ses genres.") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
sauver(g2, "05_q2_genres.png", largeur = 10, hauteur = 7)


#### Q3. Popularité et qualité ####
g3_films  <- graphique_correlation(filter(df, Type == "Film"),   "Q3 — Votes et notes : films")
g3_series <- graphique_correlation(filter(df, Type == "Series"), "Q3 — Votes et notes : séries")
sauver(g3_films,  "05_q3_votes_notes_films.png")
sauver(g3_series, "05_q3_votes_notes_series.png")


#### Q4. Évolution par décennie (films) ####
g4 <- ggplot(q4, aes(x = decennie, y = note_mediane)) +
  geom_line(color = "grey50") +
  geom_point(aes(size = n), color = couleurs_type[["Film"]]) +
  scale_x_continuous(breaks = q4$decennie) +
  scale_size_area(name = "Nombre de films", max_size = 10) +
  labs(x = "Décennie de sortie", y = "Note médiane",
       title = "Q4 — Note médiane des films par décennie",
       caption = "Attention : biais du survivant. Pour les décennies anciennes, IMDb contient surtout les classiques.") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))
sauver(g4, "05_q4_decennies_films.png", largeur = 9, hauteur = 5)


#### Q5. Durée (films) ####
g5 <- q5 %>%
  mutate(tranche_duree = factor(tranche_duree, levels = c("< 1h30", "1h30-2h", "2h-2h30", "> 2h30"))) %>%
  ggplot(aes(x = tranche_duree, y = taux_excellence)) +
  geom_col(fill = couleurs_type[["Film"]], width = 0.6) +
  geom_text(aes(label = paste0(taux_excellence, " %\n(n = ", n, ")")), vjust = -0.3, size = 3.5) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(x = "Durée du film", y = "% de films notés 8 ou plus",
       title = "Q5 — Taux d'excellence selon la durée des films",
       caption = "Lien probablement dû au genre : les films longs sont souvent des drames, biopics, films de guerre.") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))
sauver(g5, "05_q5_duree_films.png", largeur = 7, hauteur = 5)
