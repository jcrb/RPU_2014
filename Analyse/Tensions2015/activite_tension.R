# dessine le graphe des RPU créés entre 2013 et 2015. 
# La difficulté est de superposer les 3 années sur e même graphique.
# Principe on crée un dataframe avec les 3 années auquel on rajoute une colonne de date
# qui servira à créer l'axe des X.

# rpu.jour est un dataframe ayant cette structure:
#
  ##   X2013 X2014 X2015       date
  ## 1   931   972  1304 2015-01-01
  ## 2   849  1055  1332 2015-01-02
  ## 3   722  1038  1182 2015-01-03
  ## 4   749   982  1197 2015-01-04
  ## 5   760   918  1325 2015-01-05
  ## 6   741  1000  1241 2015-01-06

graphe.activite <- function(rpu.jour, main = NULL){
  # graphique
  # calcul du nb de RPU minimal et maximal pour ylim
  y1 <- min(apply(rpu.jour[1:3], 2, min))
  y2 <- max(apply(rpu.jour[1:3], 2, max))
  
  # titre principal
  titre = "Activité comparée des SU Alsace (moyennes lissées)"
  if(!is.null(main))
    titre <- paste(titre, main, sep = "\n")

  # on utilise plot pour tracer 2013 (xaxt = "n" empêche de tracer l'axe des x), puis lines pour 2014 et 2015
  plot(rollmean(rpu.jour$X2013, 7, fill=NA)  ~ rpu.jour$date, type = "l", xaxt = "n", 
       ylim=c(y1, y2), col = "green", ylab = "nombre de RPU", xlab = "jours", 
       main = titre, lwd = 3)
  
  # la partie délicate est l'axe des x qui est dessiné à part avec axis. 
  #On redéfinit l'abcisse des points à tracer en créant une séquence de dates 
  # espacées de 7 jours. Chaque date correspondra à une abcisse
  at <- seq(as.Date(min(rpu.jour$date)), as.Date(max(rpu.jour$date)), 7)
  # axis(1, x, format(x, "%b %d"), cex.axis = .7, las = 2)
  
  # finalement on dessine l'axe des x (1), en mettant une graduation (at) selon le vecteur précédamment définit et qui s'affichera sous forme jour + mois (format)
  axis(1, at, format(at, "%b %d"), las = 2, cex.axis = 0.7)
  
  lines(rollmean(rpu.jour$X2014, 7, fill=NA)  ~ rpu.jour$date, col = "blue", lwd = 3)
  lines(rollmean(rpu.jour$X2015, 7, fill=NA)  ~ rpu.jour$date, col = "red", lwd = 3)
  
  legend("bottomright", legend = c("2013","2014","2015"), col = c("green","blue","red"), lty = 1, lwd = 2, bty = "n", cex = 0.8 )
  
  abline(v = at, col='grey', lwd=0.5)
  abline(h = c(800,1000,1200,1400), col='grey', lwd=0.5) # comment faire pour ajuster sur y ?
  
  copyright()
}

# fabrique un dataframe type rpu.jour pour être utilisé par graphe.activite
# dx dataframe formé par un rbind des 3 années
create.dxt <- function(dx){
  # on se limite aux 4 premier mois de l'année (pas de données pour décembre 2012)
  dxt1 <- dx[as.Date(dx$ENTREE) >= "2013-01-01" & as.Date(dx$ENTREE) < "2013-04-15",]
  dxt2 <- dx[as.Date(dx$ENTREE) >= "2014-01-01" & as.Date(dx$ENTREE) < "2014-04-15",]
  dxt3 <- dx[as.Date(dx$ENTREE) >= "2015-01-01" & as.Date(dx$ENTREE) < "2015-04-15",]
  # on forme un grand dataframe
  # dt = RPU des 4 premiers mois des années 2013 à 2015
  dt <- rbind(dxt1,dxt2,dxt3)
  
  # pour chaque jour de la période (jours transformés en n° du jour de l'année), 
  #on calcule le nombre de RPU. On obtient une matrice de 3 lignes (1 par année) 
  # et 98 jours.
  rpu.jour <- tapply(as.Date(dt$ENTREE), list(yday(as.Date(dt$ENTREE)), year(as.Date(dt$ENTREE))), length)
  
  # La matrice est transformée en dataframe
  rpu.jour <- data.frame(rpu.jour)
  
  # auquel on ajoute une colonne de dates.On choisit arbitrairement 2015 pour les dates
  x <- seq(as.Date("2015-01-01"), as.Date("2015-04-14"), 1)
  rpu.jour$date <- x
  return(rpu.jour)
}

# idem que graphe.activite mais les données sont transformées en rollmean d'emblée
# ce qui permet de alcule des valeurs plus étroites pour ylim
graphe.activite2 <- function(prop, main = NULL){
  # transformr le dataframe prop en moyenne lissée sur 7 jours
  # les 7 premiers jours sont remplacés par NA
  roll.prop <- data.frame(apply(prop[1:3], 2, 
              function(x){rollmean(x, 7, fill = NA, align = "right")}))

  # calcul du min et du max du dataframe pour ylim
  y1 <- min(apply(roll.prop, 2, min, na.rm = TRUE))
  y2 <- max(apply(roll.prop, 2, max, na.rm = TRUE))
  
  # ajout de la colonne date
  roll.prop$date <- prop$date
  
  # titre
  titre = "Activité comparée des SU Alsace (moyennes lissées)"
  if(!is.null(main))
    titre <- paste(titre, main, sep = "\n")
  
  # plot
  plot(roll.prop$X2013 ~ roll.prop$date, type = "l", xaxt = "n", ylim = c(y1, y2), col = "green", ylab = "nombre de RPU", xlab = "jours", main = titre, lwd = 3)
  
  lines(roll.prop$X2014 ~ rpu.jour$date, col = "blue", lwd = 3)
  lines(roll.prop$X2015 ~ rpu.jour$date, col = "red", lwd = 3)
    
  at <- seq(as.Date(min(roll.prop$date)), as.Date(max(roll.prop$date)), 7)
  axis(1, at, format(at, "%b %d"), las = 2, cex.axis = 0.7)
  
  legend("bottomright", legend = c("2013","2014","2015"), col = c("green","blue","red"), lty = 1, lwd = 2, bty = "n", cex = 0.8 )
  
  abline(v = at, col='grey', lwd=0.5)
  abline(h = pretty(y1:y2), col='grey', lwd=0.5) # comment faire pour ajuster sur y ?
  
  copyright()

}