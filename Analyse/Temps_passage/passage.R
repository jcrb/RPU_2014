#   duree.passage
#   aligne.sur.calendrier
#   copyrigth
#   CUSUM - C2
#   duree.utile
#   temps.passage

#===========================================================================
#
#   duree.passage
#
#===========================================================================
#'
#'@description Calcule l'intervalle de temps entre 2 valeurs (durée de passage)
#'@name
#'@author jcb
#'@date 11/02/2015
#'@param e vecteur des entrées
#'@param s vecteur des sorties
#'@param unit unité de temps dans laquelles sont exprimées les différences.
#'       par défaut c'est la minute. Valeurs possibles: unit = "auto", "secs",
#'       "mins", "hours","days", "weeks"
#'@details nécessite lubridate. les vecteurs e et s doivent être égaux.
#'@usage d <- as.numeric(duree.passage(d14$ENTREE, d14$SORTIE))

duree.passage <- function(e, s, unit = "mins"){
  e <- ymd_hms(e) # vecteur des entrées
  s <- ymd_hms(s) # vecteur des sorties
  d <- difftime(s, e, units = unit) # voir ?difftime pour plus de détails.
  return(d)
}

#===========================================================================
#
#   aligne.sur.calendrier
#
#===========================================================================
#'
#'@description soit un vecteur x de dates non consécutives. Cette fonction insère
#'             les jours manquants de façon à former un vecteur de dates continu.
#'@param date1 date de début au format Date ou ISO
#'@param x vecteur de nd de RPU/jour => rownames = date de chaque jour
#'@usage  x <- seq("2015-01-10", "2015-01-20", 1)
#'        aligne.sur.calendrier("2015-01-01", "2015-01-31", x)
#'        sum(is.na(b)) # nb de jours sur la période sans passage > 6 heures
#'        mean(is.na(b)) # idem en %

aligne.sur.calendrier <- function(date1, date2, x){
  # creéer un calendrier
  calendrier <- seq(from = as.Date(date1), to = as.Date(date2), by = 1)
  a <- as.data.frame(calendrier)
  
  # transforme p6h.jour en dataframe pour merger ATTENTION: ne pas mettre as.data.frame
  # x <- dx[p14$DPAS > 6*60, "ENTREE"]
  z <- data.frame(x, as.Date(names(x)))
  names(z) <- c("rpu", "date")
  
  # merging
  b <- merge(a, z, by.y = "date", by.x = "calendrier", all.x = TRUE)
  
  return(b)
}

#===========================================================================
#
# copyrigth
#
#===========================================================================
#'@title copyrigth
#'@author JcB
#'@description Place un copyright Resural sur un graphique. 
#'Par défaut la phrase est inscrite verticalement sur le bord droit de l'image
#'@param an (str) année du copyright (par défaut 2013)
#'@param side coté de l'écriture (défaut = 4)
#'@param line distance par rapport au bord. Défaut=-1, immédiatement à l'intérieur du cadre
#'@param titre
#'@param cex taille du texte (défaut 0.8)
#'@return "© 2012 Resural"
#'@usage copyright()
#'
copyright <- function(an ="2013-2015",side=4,line=-1,cex=0.8, titre = "Resural"){
  titre<-paste("©", an, titre, sep=" ")
  mtext(titre,side=side,line=line,cex=cex)
}

#===========================================================================
#
# CUSUM - C2
#
#===========================================================================
# méthode C2
#'@param v2 vecteur de valeurs
#'@param k coef.de sensibilité k = delta/2. Delta = déréglage que l'on veut détecter. 
#'@param seuil seuil au delà duquel il y a dépassement. Ne sert pas ici
#'@return valeur du cusum
cusum.c2 <- function(v2, k=0.5, seuil = 2){
  pas <- 7
  # moyene mobile sur 7 jours alignée à droite, cad que la moy.mobile à J7 = mean(J1:J7)
  rmean <- rollmean(v2, pas, align = "right")
  # ecart-type mobile corrspondant:
  sd7 <- rollapply(v2, pas, sd, align = "right")
  # centrage et réduction
  c2 <- (v2[pas:length(v2)] - rmean)/sd7
  
  d <- array()
  d[1:pas] <- 0
  
  for(i in 2:length(c2)-1){
    d[i+pas] = max(0, c2[i] - k + d[i+pas-1])} # on ne garde que les valeurs positives
  
  return(d)
}

#===========================================================================
#
# Duree de passage utiles
#
#===========================================================================
# 
duree.utile <- function(dx, h){
    # on ne garde que les duréesde passage exploitables
    dpas.heure <- dpas.heure[!is.na(dpas.heure$DPAS) & dpas.heure$DPAS > 0 & dpas.heure$DPAS <= 2*24*60, ]
    dpas.heure$DATE <- substr(dpas.heure$ENTREE, 1, 10) # date entrée AAAA-MM-DD
    dpas.heure$HEURE.E <- hour(dpas.heure$ENTREE) # heure entrée (heures entières)
    return(dpas.heure)
}

#===========================================================================
#
# temps de passage
#
#===========================================================================
# Crée un dataframe ne contenant que les durées de passage comprises entre
# 0 et 48 heures, avec:
#   
# - FINESS
# - date
# - heure d'entrée
# - durée de passage (mn)
# - motif
# - DP
# - Age
#'@param dx un dataframe de type RPU 
#'@details utilise la fonction duree.passage
#'@return un vecteur de durée de passage

temps.passage <- function(dx){
  # dx dataframe RPU. On ajpoute une colonne DPAS (durée de passage)
  dx$DPAS <- as.numeric(duree.passage(dx$ENTREE, dx$SORTIE))
  #
  dpas.heure <- dx[, c("FINESS","ENTREE","DPAS","MOTIF","DP","AGE")]
  # on ne garde que les duréesde passage exploitables
  dpas.heure <- dpas.heure[!is.na(dpas.heure$DPAS) & dpas.heure$DPAS > 0 & dpas.heure$DPAS <= 2*24*60, ]
  dpas.heure$DATE <- substr(dpas.heure$ENTREE, 1, 10) # date entrée AAAA-MM-DD
  dpas.heure$HEURE.E <- hour(dpas.heure$ENTREE) # heure entrée (heures entières)
  return(dpas.heure)
}