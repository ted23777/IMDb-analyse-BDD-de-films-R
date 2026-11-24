

#### fonctions_nettoyage.R ####
# Fonctions de nettoyage réutilisables
# Chargées par run_all.R avant les étapes numérotées

# Convertir une colonne en nombre ET dire combien de valeurs ont été perdues
# (as.numeric() transforme en NA tout ce qui n'est pas un nombre, sans prévenir)
convertir_en_nombre <- function(df, colonne) {
  na_avant <- sum(is.na(df[[colonne]]))
  df[[colonne]] <- suppressWarnings(as.numeric(df[[colonne]]))
  na_apres <- sum(is.na(df[[colonne]]))
  message(colonne, " : ", na_apres - na_avant, " valeur(s) devenue(s) NA lors de la conversion")
  df
}

# Afficher combien de lignes une étape de nettoyage a supprimées
compter_lignes <- function(avant, apres, etape) {
  message(etape, " : ", nrow(avant) - nrow(apres), " ligne(s) supprimée(s), ",
          nrow(apres), " restante(s)")
}