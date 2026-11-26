#### 04_analyse.R ####
# Rôle    : répondre aux 5 questions métier
# Entrée  : data/processed/03_propre.rds
# Sorties : data/output/tables/04_q1 à 04_q5 (.csv)
#
# KPI utilisés partout :
#   - note médiane      : median(Rate)       (moins sensible aux extrêmes que la moyenne)
#   - taux d'excellence : % de titres avec Rate >= 8
#   - volume            : nombre de titres (n)

library(tidyverse)
library(rstatix)
library(here)
library(coin)

df <- readRDS(here("data", "processed", "03_propre.rds"))

dossier_tables <- here("data", "output", "tables")
dir.create(dossier_tables, recursive = TRUE, showWarnings = FALSE)

seuil_excellence <- 8   # une note >= 8 est considérée comme excellente

# Petite fonction pour calculer les 3 KPI sur n'importe quel regroupement
calculer_kpi <- function(donnees) {
  donnees %>%
    summarise(n               = n(),
              note_mediane    = median(Rate),
              note_moyenne    = round(mean(Rate), 2),
              taux_excellence = round(100 * mean(Rate >= seuil_excellence), 1))
}


#### Q1. Films ou séries : lesquels sont les mieux notés ? ####
q1 <- df %>% group_by(Type) %>% calculer_kpi()
q1
write_csv(q1, file.path(dossier_tables, "04_q1_films_vs_series.csv"))

# Test de Welch : compare les moyennes sans supposer des variances égales
# (avec plusieurs milliers de titres, il reste fiable même si les notes ne sont pas « normales »)
t.test(Rate ~ Type, data = df)

# Test de Mann-Whitney : compare les distributions (version non paramétrique)
wilcox.test(Rate ~ Type, data = df)

# Taille d'effet : la différence est-elle grande ou anecdotique ?
cohens_d(df, Rate ~ Type)          # < 0.2 négligeable, 0.5 moyen, > 0.8 grand
wilcox_effsize(df, Rate ~ Type)    # < 0.1 négligeable, 0.3 moyen, > 0.5 grand


#### Q2. Quels genres sont les mieux notés ? ####
# Un titre peut avoir plusieurs genres ("Crime, Drama") : on crée une ligne par genre.
# Un titre « Crime, Drama » compte donc une fois dans Crime ET une fois dans Drama.
df_genres <- df %>%
  separate_longer_delim(Genre, delim = ",") %>%
  mutate(Genre = str_trim(Genre))

min_titres_genre <- 30  # en dessous, la médiane d'un genre n'est pas fiable

q2 <- df_genres %>%
  group_by(Type, Genre) %>%
  calculer_kpi() %>%
  filter(n >= min_titres_genre) %>%
  arrange(Type, desc(note_mediane))
print(q2, n = Inf)
write_csv(q2, file.path(dossier_tables, "04_q2_genres.csv"))


#### Q3. La popularité (votes) va-t-elle avec la qualité (note) ? ####
# Corrélation de Spearman : basée sur les rangs, adaptée aux votes très asymétriques
# (quelques titres ont des millions de votes, la plupart quelques milliers)
q3 <- df %>%
  group_by(Type) %>%
  summarise(n          = n(),
            rho        = round(cor(Votes, Rate, method = "spearman"), 2),
            p_value    = cor.test(Votes, Rate, method = "spearman", exact = FALSE)$p.value)
q3
write_csv(q3, file.path(dossier_tables, "04_q3_votes_notes.csv"))
# Lecture de rho : 0 = aucun lien, 0.3 = lien faible, 0.5 = moyen, > 0.7 = fort


#### Q4. Les films récents sont-ils mieux ou moins bien notés ? (FILMS UNIQUEMENT) ####
# Date n'est pas fiable pour les séries (voir docs/journal.md)
q4 <- df %>%
  filter(Type == "Film") %>%
  mutate(decennie = floor(Date / 10) * 10) %>%
  group_by(decennie) %>%
  calculer_kpi()
print(q4, n = Inf)
write_csv(q4, file.path(dossier_tables, "04_q4_decennies_films.csv"))

# Tendance globale : corrélation entre l'année et la note
films <- filter(df, Type == "Film")
cor.test(films$Date, films$Rate, method = "spearman", exact = FALSE)


#### Q5. Existe-t-il une durée « idéale » ? (FILMS UNIQUEMENT) ####
# Pour les séries, Duration est la durée d'un épisode : on ne la compare pas aux films
q5 <- df %>%
  filter(Type == "Film", !is.na(Duration)) %>%
  mutate(tranche_duree = cut(Duration,
                             breaks = c(0, 90, 120, 150, Inf),
                             labels = c("< 1h30", "1h30-2h", "2h-2h30", "> 2h30"))) %>%
  group_by(tranche_duree) %>%
  calculer_kpi()
q5
write_csv(q5, file.path(dossier_tables, "04_q5_duree_films.csv"))

# Test global : les notes diffèrent-elles selon la tranche de durée ?
films_duree <- df %>%
  filter(Type == "Film", !is.na(Duration)) %>%
  mutate(tranche_duree = cut(Duration, breaks = c(0, 90, 120, 150, Inf)))
kruskal.test(Rate ~ tranche_duree, data = films_duree)

message(" Analyse terminée : tables dans data/output/tables/")