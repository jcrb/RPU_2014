# détections des jours anormaux

# ==============================
#
#     seuil
#
# ==============================
#' @description
#' @param vx vecteur integer (nb de RPU par jour)
#' @param sd nombre d'écart-type
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
  a <- cbind(rpru, dp)
  # on en fait un dataframe
  b <- as.data.frame(a)
  # on ajoute une colonne rapport DP/RPU
  b$dp.code <- b$dp / b$rpru
  
  return(b)
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
  xts <- as.xts(b, order.by = as.Date(rownames(b)))
  plot(xts$dp.code, ylab = "taux codage", main = main, ylim = c(0,1))
}