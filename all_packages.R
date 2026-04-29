# script: packages.R
# Description: Gestion centralisée de tous les packages du projet

# Liste complète et ordonnée des packages
pkgs <- c(
  # --- Manipulation & Visualisation ---
  "tidyverse", "readxl", "ggplot2", "tidyr", "dplyr", "purrr", "readr",
  "lattice", "kableExtra", "xtable", "ggfortify", "stargazer", "gtsummary",
  
  # --- Économétrie & Séries Temporelles (VAR) ---
  "urca", "vars", "mFilter", "tseries", "forecast", "TSstudio", "numDeriv",
  
  # --- Corrélation & Visualisation 3D ---
  "corrplot", "plot3D", "heatmaply", "ggcorrplot",
  
  # --- Analyse par Ondelettes (Wavelets) ---
  "wavelets", "waveslim", "WaveletComp", "zoo"
)

# Fonction d'installation intelligente
install_if_missing <- function(p) {
  if (!require(p, character.only = TRUE)) {
    message(paste("Installation du package :", p))
    install.packages(p, dependencies = TRUE)
    library(p, character.only = TRUE)
  }
}

# Chargement
invisible(lapply(pkgs, install_if_missing))
set.seed(100)
message("---------------------------------------------------------")
message("Tous les modules (VAR, Wavelets, Viz) sont prêts !")
message("---------------------------------------------------------")