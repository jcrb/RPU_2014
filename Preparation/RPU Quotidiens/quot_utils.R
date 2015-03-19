# Ensemble de fonctions pour intégrer automatiquement les RPU

# source("Preparation/RPU Quotidiens/quot_utils.R")


# Liste des fonctions
#' - rpu_jour
#' - finess2hop
#' - parse_rpu
#' - rpu2factor
#' - analyse_rpu_jour
#' - jour_consolide
#' - lire_archive
#' - assemble
#' - normalise
#' 
#' - rpu2xts
#' - plot.xts2
#' - jours.manquants
#' - normalise.caracteres
#' - completude.item
#' - cim10
#' - choose.path
#' - create.col.territoire

#=======================================
#
# rpu_jour
#
#=======================================
#'
#' Transforme un fichier .sql en un dataframe. Le jour le plus ancien est stocké sous forme de fichier .csv
#' Le fichier sql contient les 7 derniers jours. Seul le dernier est considéré comme consolidé.
#' 
#' @usage a <- rpu_jour("2014-03-07")
#' @param date.jour date du fichier .sql (ex. 2014-03-07)
#' @return un fichier .csv corespondant à J-7 (2014-03-01)
#' 
rpu_jour <- function(date.jour){
  dx <- parse_rpu(date.jour)
  dx$FINESS <- as.factor(finess2hop(dx$FINESS))
  dx <- rpu2factor(dx)
  analyse_rpu_jour(dx)
  dday <- jour_consolide(dx)
  return(dx)
}

#=======================================
#
# finess2hop
#
#=======================================
#'
#' Transformation du code Finess et nom court d'hôpital
#' 
#'@name finess2hop
#'@title 2014-03-01
#'@author JcB
#'@param a un vecteur correspondant à la colonne FINESS du dataframe
#'@usage dx$FINESS <- as.factor(finess2hop(dx$FINESS))
#'@return tidy dataframe
#'
finess2hop <- function(a){
  # a<-dx$FINESS
  a[a=="670000397"]<-"Sel"
  a[a=="680000684"]<-"Col"
  a[a=="670016237"]<-"Odi"
  a[a=="670780204"]<-"Odi" # Finess juridique
  a[a=="670000272"]<-"Wis"
  a[a=="680000700"]<-"Geb"
  a[a=="670780055"]<-"Hus"
  a[a=="670000025"]<-"Hus" # NHC maj le 17/10/2014
  a[a=="670783273"]<-"Hus" # HTP maj le 17/10/2014
  a[a=="680000197"]<-"3Fr"
  a[a=="680020096"]<-"3Fr" # maj le 30/5/2014 680020096
  a[a=="680000627"]<-"Mul"
  a[a=="670000157"]<-"Hag"
  a[a=="680000320"]<-"Dia" # DFO
  a[a=="680000395"]<-"Alk"
  a[a=="670000165"]<-"Sav"
  a[a=="680000494"]<-"Ros" # DRO
  a[a=="670780162"]<-"Dts" # DST
  a[a=="670780212"]<-"Ane"
  a[a=="680000601"]<-"Tan" # THA
  return(a)
}

#=======================================
#
# parse_rpu
#
#=======================================
#' Utilise le fichier du jour au format SQL, l'injecte dans une base de données puis transforme le résultat en dataframe
#' Le dataframe contient tous les RPU de la veille plus ceux des 7 derniers jours (j-1 à j-7)
#' Préalable: disposer d'une base de donnée MySql avec une table appelée "archives".
#' Cette base doit être référencée dans le fichier .my.conf
#' 
#'@name parse_rpu
#'@title 2014-03-01
#'@author JcB
#'@param data date.jour nom du fichier. Pour une utilisation courante il s'agit de la date du jour au format ISO
#'@usage d <- parse_rpu("2015-01-08")
#'       t <- tapply(as.Date(d$ENTREE), list(d$FINESS, as.Date(d$ENTREE)), length)
#'       t(t)
#'@return dx une tidy dataframe
#'
parse_rpu <- function(date.jour){
  library("RMySQL")
  file <- paste0("rpu_", date.jour, "_dump.sql")
  wd <- getwd()
  setwd("~/Documents/Resural/Stat Resural/Archives_Sagec/dataQ")
  if(!file.exists(file)){
    x <- paste("Le fichier",file,"n'existe pas dans le répertoire",getwd(), sep=" ")
    stop(x)
  }
  system(paste0("mysql -u root -pmarion archives < ", file))
  con<-dbConnect(MySQL(),group = "archives")
  rs<-dbSendQuery(con,paste("SELECT * FROM RPU__ ",sep=""))
  dx<-fetch(rs,n=-1,encoding = "UTF-8")
  dbDisconnect(con)
  con <- NULL
  dx<-dx[,-16]
  dx$FINESS <- as.factor(finess2hop(dx$FINESS))
  
  dx$AGE<-floor(as.numeric(as.Date(dx$ENTREE)-as.Date(dx$NAISSANCE))/365)
  dx$AGE[dx$AGE > 120]<-NA
  dx$AGE[dx$AGE < 0]<-NA
  
  setwd(wd)
  return(dx)
}

#=======================================
#
# rpu2factor
#
#=======================================
#'
#' Transforme toutes les données qui doivent l'être en facteurs
#'@name rpu2factor
#'@title 2014-03-01
#'@author JcB
#'@param dx data frame à nettoyer
#'@usage dx <- rpu2factor(dx)
#'@return dx une tidy dataframe
#'
rpu2factor <- function(dx){
  dx$CODE_POSTAL<-as.factor(dx$CODE_POSTAL)
  dx$COMMUNE<-as.factor(dx$COMMUNE)
  dx$SEXE<-as.factor(dx$SEXE)
  dx$TRANSPORT<-as.factor(dx$TRANSPORT)
  dx$TRANSPORT_PEC<-as.factor(dx$TRANSPORT_PEC)
  dx$GRAVITE<-as.factor(dx$GRAVITE)
  dx$ORIENTATION<-as.factor(dx$ORIENTATION)
  dx$MODE_ENTREE<-factor(dx$MODE_ENTREE,levels=c(6,7,8),labels=c('Mutation','Transfert','Domicile'))
  dx$PROVENANCE<-factor(dx$PROVENANCE,levels=c(1,2,3,4,5,8),labels=c('MCO','SSR','SLD','PSY','PEA','PEO'))
  dx$MODE_SORTIE<-factor(dx$MODE_SORTIE,levels=c(6,7,8,4),labels=c('Mutation','Transfert','Domicile','Décès'))
  dx$DESTINATION<-factor(dx$DESTINATION,levels=c(1,2,3,4,6,7),labels=c('MCO','SSR','SLD','PSY','HAD','HMS'))
  dx$EXTRACT <- as.Date(dx$EXTRACT)
  return(dx)
}

#=======================================
#
# analyse_rpu_jour
#
#=======================================
#'
#' Analyse le dataframe correspondant à un fichier transmis. Permet de vérifier la cohérence de certaines données. 
#' dx est le dataframe correspondant au fichier transmis.
#' @usage analyse_rpu_jour(parse_rpu("2015-01-08")) 

analyse_rpu_jour <- function(dx){
  print(paste("Nombre de RPU: ",nrow(dx)))
  print(paste("Date de début: ",min(as.Date(dx$ENTREE))))
  print(paste("Date de fin: ",max(as.Date(dx$ENTREE))))
  print(paste("Nombre d'établissements: ", nlevels(dx$FINESS)))
  print(summary(dx$FINESS))
}

#=======================================
#
# jour_consolide
#
#=======================================
#'
#' Extrait le jour normalement consolidé. DX est le dataframe correspondant aux 7 derniers jours précédant l'envoi du fichier.
#' Le jour 7 est le plus ancien et les données correspondant à cejour ne seront plus modifiées et sont prètes à être archivées.
#' Cette fonction extrait les données correspondant à ce jour.
#' Le fichier du jour est stocké dans le dossier archivesCsv.
#' 
jour_consolide <- function(dx){
  jour <- as.Date(min(dx$ENTREE)) # jour à sauvegarder
  dday <- dx[as.Date(dx$ENTREE) == jour,]
  # ménage
  # dday<- gsub("\\e9", "é", dday, fixed=TRUE)
  wd <- getwd()
  setwd("~/Documents/Resural/Stat Resural/Archives_Sagec/dataQ/archivesCsv")
  # fichier du jour: 
  file <- paste0(jour,".csv")
  write.table(dday, file, sep=',', quote=TRUE, na="NA", row.names=FALSE,col.names=TRUE, qmethod = "double")
  print(paste("fichier créé:", file, getwd()))
  # fichier général: write.table(dday, "RPU2014.csv", sep=',', quote=TRUE, na="NA", append = TRUE, row.names=FALSE,col.names=TRUE)
  setwd(wd)
  return(dday)
}

#=======================================
#
# lire_archive
#
#=======================================
#'
#'Lit une archive au format .csv et renvoie le dataframe correspondant
#'@param jour au format ISO
#'@usage dx <- lire_archive("2014-02-15")
#'
lire_archive <- function(jour){
  file <- paste0(jour, ".csv")
  wd <- getwd()
  path = "~/Documents/Resural/Stat Resural/Archives_Sagec/dataQ/archivesCsv"
  a <- read.table(paste(path,file,sep="/"), header=TRUE, sep=",")
  a <- normalise(a)
  setwd(wd)
  return(a)
}

#sauvegarde de l'archive au format Rda'
#dx <- lire_archive("rpu2014")
#save(dx, file="rpu2014d02.Rda")

#=======================================
#
# assemble
#
#=======================================
#'
#' assemble les fichiers .csv contenus dans un dossier pour créer un dataframe
#' @source: https://gist.github.com/danielmarcelino
#' @param comment si TRUE imprime des commentaires sur les fichiers traités (défaut=FALSE)
#' @return un dataframe correspondant aux jours présents. Le dataframe est sauvegardé dans un fichier .csv appelé rpu2014.data
#' @usage dx <- assemble(comment=TRUE)
#' 
assemble <- function(comment=FALSE){
  path <- "/home/jcb/Documents/Resural/Stat Resural/Archives_Sagec/dataQ/archivesCsv"
  out.file<-NULL
  file.names <- dir(path, pattern =".csv")
  for(i in 1:length(file.names)){
       file <- read.table(paste(path, file.names[i], sep="/"),header=TRUE, sep=",", stringsAsFactors=FALSE)
       out.file <- rbind(out.file, file)
   }
  file <- paste(path,"rpu2014.data",sep="/")
  write.table(out.file, file = file, sep=",", row.names = FALSE, qmethod = "double")
  if(comment==TRUE){
    dx <- normalise(dx)
    analyse_rpu_jour(dx)
    print(paste("fichier créé:", file))
  }
  return(out.file)
}

#=======================================
#
# normalise
#
#=======================================
#'
#' Normalise les item du RPU
#' 
normalise <- function(dx){
  dx$DP <- as.character(dx$DP)
  dx$ENTREE <- as.character(dx$ENTREE)
  dx$EXTRACT <- as.character(dx$EXTRACT)
  dx$MOTIF <- as.character(dx$MOTIF)
  dx$NAISSANCE <- as.character(dx$NAISSANCE)
  dx$SORTIE <- as.character(dx$SORTIE)
  dx$AGE <- as.numeric(dx$AGE)
  dx$id <- as.character(dx$id)
  dx$CODE_POSTAL <- as.factor(dx$CODE_POSTAL)
  dx$FINESS <- as.factor(dx$FINESS)
  return(dx)
}

#=======================================
#
# rpu2xts
#
#=======================================
#'A partir du fichier habituel des RPU retourne un objet xts ayant autant de
#'colonnes qu'il y a de SU dans d plus 2 colonnes supplémentaires:
#'- date de type 'Date' qui sert d'index à xts
#'- total nombre total de RPU par jour
#'
#'@param d données RPU
#'@usage ts <- rpu2xts(d0106p); plot(ts$total);lines(rollapply(ts$total, 7, mean), col="red")
#'
rpu2xts <- function(d){
  library(xts)
  t <- table(as.Date(d$ENTREE), d$FINESS)
  date <- rownames(t)
  a <- as.data.frame.matrix(t)
  a <- cbind(a, date)
  a$date <- as.Date(a$date)
  a$total <- rowSums(a[,1:14])
  ts <- xts(a, order.by = a$date)
  ts
}


#=======================================
#
# plot.xts2
#
#=======================================
# La méthode plot.xts comprte un bug qui empêche l'affichage de courbes en couleur. Cette version corrige le bug.
#'@author Roman Luštrik (http://stackoverflow.com/users/322912/roman-lu%c5%a1trik)
#'@source http://stackoverflow.com/questions/9017070/set-the-color-in-plot-xts
#'
plot.xts2 <- function (x, y = NULL, type = "l", auto.grid = TRUE, major.ticks = "auto", 
                       minor.ticks = TRUE, major.format = TRUE, bar.col = "grey", 
                       candle.col = "white", ann = TRUE, axes = TRUE, col = "black", ...) 
{
  series.title <- deparse(substitute(x))
  ep <- axTicksByTime(x, major.ticks, format = major.format)
  otype <- type
  if (xts:::is.OHLC(x) && type %in% c("candles", "bars")) {
    x <- x[, xts:::has.OHLC(x, TRUE)]
    xycoords <- list(x = .index(x), y = seq(min(x), max(x), 
                                            length.out = NROW(x)))
    type <- "n"
  }
  else {
    if (NCOL(x) > 1) 
      warning("only the univariate series will be plotted")
    if (is.null(y)) 
      xycoords <- xy.coords(.index(x), x[, 1])
  }
  plot(xycoords$x, xycoords$y, type = type, axes = FALSE, ann = FALSE, 
       col = col, ...)
  if (auto.grid) {
    abline(v = xycoords$x[ep], col = "grey", lty = 4)
    grid(NA, NULL)
  }
  if (xts:::is.OHLC(x) && otype == "candles") 
    plot.ohlc.candles(x, bar.col = bar.col, candle.col = candle.col, 
                      ...)
  dots <- list(...)
  if (axes) {
    if (minor.ticks) 
      axis(1, at = xycoords$x, labels = FALSE, col = "#BBBBBB", 
           ...)
    axis(1, at = xycoords$x[ep], labels = names(ep), las = 1, 
         lwd = 1, mgp = c(3, 2, 0), ...)
    axis(2, ...)
  }
  box()
  if (!"main" %in% names(dots)) 
    title(main = series.title)
  do.call("title", list(...))
  assign(".plot.xts", recordPlot(), .GlobalEnv)
}

#=======================================
#
# jours.manquants()
#
#=======================================
# retourne la liste des jours manquants dans la période comprise entre deux dates
#'@author JcB
#'@date 2014-12-06
#'@param date1 (string) date de début de l'intervalle
#'@param date2 (string) fin de l'intervalle
#'@param data (vector of string) vecteur de date à tester
#'@return vecteur de date
#'@usage  date1 <- "2014-01-01"
#'        date2 <- "2014-01-31"
#'        data <- seq(as.Date(date1), as.Date(date2), 1)
#'        data <- data[-c(1,10)]
#'        jours.manquants(date1, date2, data)
#'        
#'        [1] "2014-01-01" "2014-01-10"

jours.manquants <- function(date1, date2, data){
  calendar <- seq(as.Date(date1), as.Date(date2), 1) # calendrier de référence
  a <- unique(as.Date(data)) # date à terter
  b <- match(calendar, a) # attention à l'ordre des items. Le calendrier de référence tjjrs en premier
  ok <- complete.cases(b) # vecteur de booleen
  sum(!ok) # nombre de jours manquants
  return(calendar[!ok]) # liste des jours manquants
}

#=======================================
#
# normalise.caracteres()
#
#=======================================
#' transforme les symboles exotiques et caractères ASCII normaux
#' @author jcb
#' @date 2014-12-10
#' @param dpr un vecteur de character
#' @return un vecteur corrigé
#' 
normalise.caracteres <- function(dpr){
  # correction des caractères bloquants
  dpr<-gsub("\xe8","è",as.character(dpr),fixed=FALSE)
  dpr<-gsub("\xe9","é",as.character(dpr),fixed=FALSE)
  dpr<-gsub("\xe0","à",as.character(dpr),fixed=FALSE)
  dpr<-gsub("\xeb","ë",as.character(dpr),fixed=FALSE)
  dpr<-gsub("\xef","ï",as.character(dpr),fixed=FALSE)
  dpr<-gsub("\xe2","â",as.character(dpr),fixed=FALSE)
  dpr<-gsub("\xfb","û",as.character(dpr),fixed=FALSE)
  dpr<-gsub("\xf4","ô",as.character(dpr),fixed=FALSE)
  dpr<-gsub("\xb0","ê",as.character(dpr),fixed=FALSE) # ?
  dpr<-gsub("\xc9","é",as.character(dpr),fixed=FALSE)
  dpr<-gsub("\xea","ê",as.character(dpr),fixed=FALSE)
  dpr<-gsub("\xe7","ç",as.character(dpr),fixed=FALSE)
  
  # autres symboles
  dpr<-gsub(".","",as.character(dpr),fixed=TRUE)
  dpr<-gsub("+","",as.character(dpr),fixed=TRUE)
  return(dpr)
}

#=======================================
#
# completude.item
#
#=======================================
#' calcule le % de réponses à un item
#' @author jcb
#' @date 2015-01-02
#' @param data un vecteur 
#' @param precision nombre de chiffre après la virgule
#' @return pourcentage de data remplis (<> NA)
#' @usage completude.iten(d2$DESTINATION)
#' 
completude.item <- function(data, precision = 2){
  round(mean(!is.na(data)) * 100, precision)
}

#=======================================
#
# cim10
#
#=======================================
#' retourne le vecteur des codes CIM10 du vecteur d
#' et qui sont compris entre a et b (inclus)
#' 
#' @usage cim10(dx$DP, "S60", "S69")
#' 
cim10 <- function(d, a, b){
  ncar <- nchar(a)
  x <- d[substr(d, 1, ncar) >= a & substr(d, 1, ncar) <= b & !is.na(d)]

}


#=======================================
#
# choose.path
#
#=======================================
#' choisit le path en fonction de l'ordinateur
#' deux machines sont reconnues: mac et xps
#' @usage path <- choose.path()
#' TODO: généraliser la fonction
#' 
choose.path <- function(){
  
  if(as.character(Sys.info()["nodename"]) == "MacBook-Air-de-JCB.local")
    path = "~/Documents/Stat Resural/RPU_2014" else 
  if(as.character(Sys.info()["nodename"]) == "XPS")
    path = "~/Documents/Resural/Stat Resural/RPU_2014"
}

#=======================================
#
# create.col.territoire
#
#=======================================
#' ajoute une colonne TERRITOIRE à un dataframe de RPU
#' @param dx dataframe. Doit comprter au moins une colonne appelée FINESS
#' @usage a <- create.col.territoire(j2015)
#'        tapply(as.Date(a$ENTREE), a$TERRITOIRE, length)
#' 
create.col.territoire <- function(dx){
  dx$TERRITOIRE[dx$FINESS %in% c("Wis","Sav","Hag")] <- "T1"
  dx$TERRITOIRE[dx$FINESS %in% c("Hus","Odi","Ane","Dts")] <- "T2"
  dx$TERRITOIRE[dx$FINESS %in% c("Sel","Col","Geb")] <- "T3"
  dx$TERRITOIRE[dx$FINESS %in% c("Mul","3Fr","Alk","Ros","Dia","Tan")] <- "T4"
  return(dx)
}


#=======================================
#
# rpu.par.jour
#
#=======================================
#' A partir d'un vecteur de dates, calcule le nombre de RPU par jour
#' @param d vecteur de dates compatible avec le format Date
#' @param roll: nb de jours pour la moyenne lissée. Défaut = 7
#' @include xts, lubridate
#' @return un dataframe de 4 colonnes: date calendaire, nb de RPU du joir, le n° du jour de l'année (1 à 365), la moyennne lissée
#' @todo RAJOUTER LES SOMMES   CUMuLEES
#' @usage p2013 <- rpu.par.jour(j2013$ENTREE)
#'        plot(p2013$V2, type="l") # les RPU
#'        lines(p2013$V3, p2013$V4) # moyenne mobile

rpu.par.jour <- function(d, roll = 7){
  # janvier 2013
  t <- tapply(as.Date(d), as.Date(d), length)
  df <- as.data.frame(cbind(names(t), as.numeric(t)), stringsAsFactors = FALSE)
  df$V1 <- as.Date(df$V1) # col. date
  df$V2 <- as.numeric(df$V2) # nb de RPU
  df$V3 <- yday(df$V1) # date du jour en n° du jour dans l'année
  df$V4 <- rollmean(df$V2, 7, fill = NA) # moyenne mobile sur 7 jours. rollmean crée un vecteur plus petit. Pour obtenir un vecteur de la même longueur, on remplace les valeurs manquantes par NA
  df$V5 <- df$V2 - df$V4 # pour CUSUM
  return(df)
}
