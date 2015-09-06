# détections des jours anormaux

# ==============================
#
#     seuil
#
# ==============================
#' @description calcule le seuil à partir duquel le nombre de RPU remonté est anormalement bas
#' @param vx vecteur integer (nb de RPU par jour)
#' @param sd nombre d'écart-type souhaités, par défaut 3 (moyenne moins 3 sd)
#' @return un nombre
#' @usage seuil(rpu$Sel) # 50.80671 (source: rpu.jour_31-07-2015.csv)
#' 

seuil <- function(vx, sd_souhaite = 3){
  # moyenne et sd théoriques
  a <- as.integer(vx)
  s <- summary(a[a > 0]) # on ne garde que les valeurs non nulles pour ne pasavoir de seuil négatif
  sd <- sd(a)
  # motenne corrigée
  # On retire de a les ours où le nb de RPU est plus petit que le nombre moyen de RPU - 2 sd:
  b <- a[a > s["Mean"]-sd*2]
  # on recalcule les paramètres de centralité et de dispersion:
  s.b <- summary(b)
  sd.b <- sd(b)
  # seuil
  seuil <- s.b["Mean"] - sd_souhaite * sd.b
  # si le seuil est négatif, on réduit sd de 1 unité
  if(seuil < 0) seuil = s.b["Mean"] - (sd_souhaite-1) * sd.b
  return(as.numeric(seuil))
  
}

# ==============================
#
#     seuil.graphe
#
# ==============================
#' @description dessine la courbe du Nb de RPU par jour et le seuil à partir duquel
#'              ce nombre est anormal
#'@param xts un vecteur de type xts
#'@param seuil
#'@hop  char le nom de l'établissement concerné
#'@usage seuil.graphe(xts$Sel, seuil(xts$Sel))
#' 
seuil.graphe <- function(xts, seuil = NULL, hop = NULL){
  if(!is.null(hop))
    main = paste(hop, " - Nombre de RPU par jour")
  else
    main = "Nombre de RPU par jour en 2015"
  
  plot(xts, ylim = c(0, max(as.integer(xts), na.rm = TRUE)),
       las = 2, cex.axis = 0.6, main = main,
       major.ticks= "weeks")
  if(!is.null(seuil)){
    abline(h = seuil, col = "blue", lty = 2)
  }
}

# ==============================
#
#     graphe.rpu.seuil
#
# ==============================
#
#' @description tracé de la courbe. Wraper pour la fonction seuil.graphe. Permet de tracer la courbe
#'              de façon générique et de chooisir plus finement la date de début et de fin du tracé
#' @details utilise seui.graphe de reco.R
#' @param xts un dataframe de type xts
#' @param colonne nom ou n° de la colonne de xts à tracer
#' @param titre titre du graphique
#' @param debut n° de la pemière ligne. Par défaut = 1. Permet de ne tracer que des portions de graphe
#'              Le n° correspond au n° du jour de l'année
#' @param fin n° du dernier jour à tracer
#' @usage graphe.rpu.seuil(rpu.xts, "Sel", "CH Sélestat" )`
#' @usage graphe.rpu.seuil(rpu.xts, 2, colnames(rpu.xts)[2] )
#' @usage graphe.rpu.seuil(rpu.xts, "Sel", "CH Sélestat", debut = 1, fin = 59 )

graphe.rpu.seuil <- function(xts, colonne, titre = "", debut = NULL, fin =NULL){
    if(is.null(debut))
        debut = 1
    if(is.null(fin))
        fin = length(xts[,colonne])
    seuil.graphe(xts[debut:fin, colonne], seuil(xts[debut:fin, colonne]), titre)
    legend("bottomleft", legend = "seuil d'alerte", col = "blue", lty = 2, bty = "n", cex = 0.8)
}

# ==============================
#
#     taux.codage.dp
#
# ==============================
#' @description à partir d'un dataframe RPU comportant au moins 2 colonnes (ENTREE et DP)
#'              retourne un datafrme avec 3 colonnes: rpu, dp et dp.code = taux de codage
#'  
taux.codage.dp <- function(dx){
  dx$ENTREE <- as.Date(dx$ENTREE)
  # nb de RPU par jour
  rpru <- tapply(dx$ENTREE, dx$ENTREE, length)
  # nb de DP par jour
  dp <- tapply(dx$DP[!is.na(dx$DP)], dx$ENTREE[!is.na(dx$DP)], length)
  
  # on lie les 2
  # a <- cbind(rpru, dp)
  
  # transforme les vecteurs en matrice à 2 colonnes date + valeur
  r <- as.data.frame(named.vector2matrix(rpru), stringsAsFactors = FALSE)
  d <- as.data.frame(named.vector2matrix(dp), stringsAsFactors = FALSE)
  # il faut renommer les noms des nouvelles colonnes. Il est important que la première
  # colonne s'appelle 'date'
  colnames(d) <- c("date", "vy")
  colnames(r) <- c("date", "vx")
  
  # les 2 matrices sont mergées sur la colonne date. La matrice des RPU, r, fixe
  # le nombre de jours attendus
  a <- merge(r,d, all.x = TRUE)
  # a$date <- as.character(a$date)
  a$vx <- as.numeric(a$vx)
  a$vy <- as.numeric(a$vy)
  # on remplace NA de vy par 0
  a$vy <- ifelse(is.na(a$vy), 0, a$vy)

  # on en fait un dataframe
  # b <- as.data.frame(a, stringsAsFactors = FALSE)
  # on ajoute une colonne rapport DP/RPU
  a$taux <- a$vy / a$vx
  
  return(a)
}

# ==============================
#
#     plot.taux.codage.dp
#
# ==============================
#' @description
#' @param b un dataframe retourné par taux.codage.dp
#' 
plot.taux.codage.dp <- function(b, hop = NULL){
  # graphe
  if(! is.null(hop))
    main = paste(hop, " - Variabilité du Taux de codage des DP")
  else
    main ="Variabilité du Taux de codage des DP"
  
  xts <- as.xts(b, order.by = as.Date(b$date))
  plot(xts$taux, ylab = "taux codage", main = main, ylim = c(0,1))
}

# ==============================
#
#     named.vector2matrix
#
# ==============================
#' @description transforme un vecteur nommé en matrice à 2 colonnes
#' 
named.vector2matrix <- function(vx){
  m <- cbind(names(vx), vx)
  colnames(m)[1] <- "name"
  return(m)
}