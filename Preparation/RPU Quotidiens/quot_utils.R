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
#' - normaliserpu.jour.2014 <- rpu.par.jour(d14)

#' 
#' - rpu2xts
#' - plot.xts2
#' - jours.manquants
#' - normalise.caracteres
#' - completude.item
#' - cim10
#' - choose.path
#' - create.col.territoire
#' - add.territoire
#' - finess2territoires
#' - rpu.par.jour

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
#' @param echo si TRUE (default) imprime un commentaire (ajouté le 12-12-2015)
#' @return un fichier .csv corespondant à J-7 (2014-03-01)
#' 
rpu_jour <- function(date.jour, echo = TRUE){
  dx <- parse_rpu(date.jour)
  dx$FINESS <- as.factor(finess2hop(dx$FINESS))
  dx <- rpu2factor(dx)
  if(echo == TRUE)
    analyse_rpu_jour(dx)
  dday <- jour_consolide(dx)
  return(dx)
}

#=======================================
#
# sql2df
#
#=======================================
#' @author JCB 2015-08-28
#' @description transforme un fichier RPU au format sql en un dataframe
#' @param filename_sql nom du fichier sql. Doit se trouver dans le répertoire dataQ
#' @param resural si TRUE, le DF est transcodé au format Resural (noms de facteurs explicites)
#'        si FALSE, les données initiales ne sont pas modifiées
#' @usage file <- "SteAnne2015/rpu_2015_670780212.dump.sql"
#'        dx <- sql2df(file)
#'        write.csv(dx, file = '../Archives_Sagec/dataQ/SteAnne2015/Ane_2015_01_01-2015_08_22.csv')
#' 

sql2df <- function(filename_sql, resural = TRUE){
  d <- parse_rpu("", filename = filename_sql)
  if(resural == TRUE)
    d <- rpu2factor(d)
  analyse_rpu_jour(d) # quelques commentaires

  return(d)
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
  a[a=="670017755"]<-"Sel" # GHSO depuis le 5/1/2016
  a[a=="680000684"]<-"Col"
  a[a=="670016237"]<-"Odi"
  a[a=="670780204"]<-"Odi" # Finess juridique
  a[a=="670000272"]<-"Wis"
  a[a=="680000700"]<-"Geb"
  a[a=="670780055"]<-"Hus"
  a[a=="670000025"]<-"NHC" # NHC maj le 17/10/2014
  a[a=="670783273"]<-"HTP" # HTP maj le 17/10/2014
  a[a=="680000197"]<-"3Fr"
  a[a=="680020096"]<-"3Fr" # maj le 30/5/2014 680020096

  a[a=="680000627"]<-"Hsr" # correspond au Hasenrain 14/08/2015. Avant cette date = Mul
  # a[a=="680000627"]<-"Har" # correspond au Hasenrain
  a[a=="670000157"]<-"Hag"
  a[a=="680000320"]<-"Dia" # DFO
  a[a=="680000395"]<-"Alk"
  a[a=="670000165"]<-"Sav"
  a[a=="680000494"]<-"Ros" # DRO
  a[a=="670780162"]<-"Dts" # DST
  a[a=="670780212"]<-"Ane"
  a[a=="680000601"]<-"Tan" # THA
  a[a=="670009109"]<-"Ccm" # CCOM Ilkirch 2015-10-12
  a[a=="680004546"]<-"Emr" # Emile muller  2015-04-23

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
#' La fonction crée la colonne AGE à partir de la date de naissance er de la date d'entrée. Les ages < 0 ou > 120
#' sont transfprmés en NA.
#' 
#'@name parse_rpu
#'@title 2014-03-01
#'@author JcB
#'@param data date.jour nom du fichier. Pour une utilisation courante il s'agit de la date du jour au format ISO
#'@param filename nom du fichier sql à parser. A utiliser si le fichier sql est différent de rpu_AAAA-MM-JJ_dump.sql
#'        permet de parser des fichiers de rattrappage.
#'@usage d <- parse_rpu("2015-01-08")
#'       t <- tapply(as.Date(d$ENTREE), list(d$FINESS, as.Date(d$ENTREE)), length)
#'       t(t)
#'       
#'       file <- "SteAnne2015/rpu_2015_670780212.dump.sql"
#'       d <- parse_rpu("", file)

#'@return dx une tidy dataframe
#'
parse_rpu <- function(date.jour, filename = NULL){
  library("RMySQL")
  if(!is.null(filename))
    file <- filename
  else file <- paste0("rpu_", date.jour, "_dump.sql")
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
# parse_da
#
#=======================================
#
#' @title parse un fichier diag_associe.sql
#' @description parse un fichier diag_associe.sql et retoune un dataframe à 2 colonnes: identifiant dossier
#' et code CIM10. Il peut y avoir plusieurs codes pour un même identifiant.
#' @param date.jour date du jour au format Date (AAAA-MM-JJ)
#' @param file optionel. Nom du fichier s'il est différent de rpu_diag_asso_AAAA-MM-JJ_dump.sql
#' @usage parse_da(date.jour, filename = NULL)
#' @details le fichier à parser doit obligatoirement se trouver dans le dossier ~/Documents/Resural/Stat Resural/Archives_Sagec/dataDA
#' Une base de données MySql du nom de 'archives' doit exister de même q'un fichier de connexion '.my.cnf' dans le dossier personnel.
#' 
#' @return un dataframe
#' @examples parse_da("2015-05-07")

parse_da <- function(date.jour, filename = NULL){
  library("RMySQL")
  if(!is.null(filename))
    file <- filename
  else file <- paste0("rpu_diag_asso_", date.jour, "_dump.sql")
  wd <- getwd()
  setwd("~/Documents/Resural/Stat Resural/Archives_Sagec/dataDA")
  
  if(!file.exists(file)){
    x <- paste("Le fichier",file,"n'existe pas dans le répertoire",getwd(), sep=" ")
    stop(x)
  }
  # charge le fichier dans la base de  données "archives". Si la table existe, elle est automatiquement effacée.
  # si la table n'existe pas, elle est créée automatiquement
  system(paste0("mysql -u root -pmarion archives < ", file))
  
  # Transfert de la table vers un dataframe
  con<-dbConnect(MySQL(),group = "archives") # connexion à la base "archives"
  rs<-dbSendQuery(con,paste("SELECT * FROM RPU_DIAG_ASSO__ ",sep=""))
  dx<-fetch(rs,n=-1,encoding = "UTF-8") # dataframe
  # fermeture de la connexion
  dbDisconnect(con)
  con <- NULL
  # restauration et retour
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
#' @title Transforme RPU eb XTS
#' @description A partir du fichier habituel des RPU retourne un objet xts ayant autant de
#'colonnes qu'il y a de SU dans d plus 2 colonnes supplémentaires:
#'- date de type 'Date' qui sert d'index à xts
#'- total nombre total de RPU par jour
#' @usage rpu2xts(dx)
#' @param dx un datafrale de type RPU comportant au moins une colonne ENTREE
#' @return un dataframe avec une colonne 'total'
#' @example ts <- rpu2xts(d0106p); plot(ts$total);lines(rollapply(ts$total, 7, mean), col="red")
#' @export
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
#' @title plot.xts en couleur
#' @description La méthode plot.xts comprte un bug qui empêche l'affichage de courbes en couleur. Cette version corrige le bug.
#' @usage plot.xts2(x, y = NULL, type = "l", auto.grid = TRUE, major.ticks = "auto", minor.ticks = TRUE, major.format = TRUE, 
#' bar.col = "grey", candle.col = "white", ann = TRUE, axes = TRUE, col = "black", ...) 
#' @author Roman Luštrik (http://stackoverflow.com/users/322912/roman-lu%c5%a1trik)
#' @source http://stackoverflow.com/questions/9017070/set-the-color-in-plot-xts
#' @export
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

# Application de la formule: nombre de jours manquants par FINESS dans un dataframe 
# de type RPU:
# tapply(d15$ENTREE, d15$FINESS, F=function(x){length(jours.manquants("2015-01-01", "2015-04-02", x))})
#
# 3Fr Alk Ane Col Dia Dts Geb Hag Hus Mul Odi Ros Sav Sel Wis 
# 0   0  25   1   0   0   0   0   0   1   1   0   0   4   0
#
# tapply(d15$ENTREE, d15$FINESS, F=function(x){jours.manquants(
#   "2015-01-01", "2015-04-02", x)})
# Retourne une liste de dates par Finess correspondant aux jours manquants


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
#' @title A partir d'un vecteur de dates, calcule le nombre de RPU par jour
#' @usage rpu.par.jour(d, roll = 7)
#' @param d vecteur de dates compatible avec le format Date
#' @param roll: nb de jours pour la moyenne lissée. Défaut = 7
#' @include xts, lubridate
#' @return un dataframe de 4 colonnes: date calendaire, nb de RPU du jour, le n° du jour de l'année (1 à 365), la moyennne lissée
#' @todo RAJOUTER LES SOMMES   CUMuLEES
#' @examples p2013 <- rpu.par.jour(j2013$ENTREE)
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

#=======================================
#
# add.territoire
#
#=======================================
#' @title Crée une colonne TERRITOIRE
#' @description Ajoute une colonne TERRITOIRE à un dataframe qui contient une colonne FINESS
#' @usage add.territoire(dx)
#' @param dx un dataframe ayant une colonne FINESS renseignée
#' @return un dataframe 
#' @export
#'
add.territoire <- function(dx){
  dx$TERRITOIRE[dx$FINESS %in% c("Wis","Sav","Hag")] <- "T1"
  dx$TERRITOIRE[dx$FINESS %in% c("Hus","Odi","Ane","Dts")] <- "T2"
  dx$TERRITOIRE[dx$FINESS %in% c("Sel","Col","Geb")] <- "T3"
  dx$TERRITOIRE[dx$FINESS %in% c("Mul","3Fr","Alk","Ros","Dia")] <- "T4"
  return(dx)
}

#=======================================
#
# finess2territoires
#
#=======================================
#' @title réorganiser les FINESS par territoires de santé
#' @usage finess2territoires(finess)
#' @examples dx$FINESS <- finess2territoires(dx)
#' @export
#'
finess2territoires <- function(finess){
  finess <- factor(finess, levels = c('Wis','Hag','Sav','Hus','Ane','Odi','Dts','Sel','Col','Geb','Mul', 'Alk','Dia','Ros','3Fr'))
  return(finess)
}

#=======================================
#
# rpu.par.jour
#
#=======================================
#' @title Nombre de RPU par jour et par FINESS
#' @description retourne une table contenant le nombre de RPU par jour et par FINESS
#' @usage rpu.par.jour(dx)
#' @param dx un dataframe de type rpu ayant un minimum 2 colonnes ENTREE et FINESS
#' @examples rpu.par.jour(d04)
#' @export
#'
#           3Fr Alk Ane Col Dia Dts Geb Hag Hus Mul Odi Ros Sav Sel Wis
# 2015-01-01  48  51   0 190  59  29  52 129 306 220  15   9  83  85  28
# 2015-01-02  45  52   0 210 102  27  43 118 292 200  10  28  94  81  30
# 2015-01-03  31  43   0 203  85  30  64 135 325   0   2  13 106 103  42
rpu.par.jour <- function(dx){
  return(table(as.Date(dx$ENTREE), dx$FINESS))
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
#'@usage copyright(an ="2013-2015",side=4,line=-1,cex=0.8, titre = "Resural")
#'@param an (str) année du copyright (par défaut 2013)
#'@param side coté de l'écriture (défaut = 4)
#'@param line distance par rapport au bord. Défaut=-1, immédiatement à l'intérieur du cadre
#'@param titre
#'@param cex taille du texte (défaut 0.8)
#'@return "© 2012 Resural"
#'@export
#'
copyright <- function(an ="2013-2015",side=4,line=-1,cex=0.8, titre = "Resural"){
  titre<-paste("©", an, titre, sep=" ")
  mtext(titre,side=side,line=line,cex=cex)
}

#===========================================================================
#
# Nombre de RPU par mois
#
#===========================================================================
#' @title Nombre de RPU par mois
#' @description Calcule le nombre de RPU par mois entre deux dates sous forme brute
#' ou corrigée en mois constants de 30 jours.
#' @usage rpu.par.mois(dx, standard = FALSE)
#' @param dx dataframe (au minimum la colonne ENTREE)
#' @param standard (boolean) si true retourne par mois corrigés de 30j sinon le nombre brut de RPU
#' @return un vecteur nommé: nom du mois, nb de RPU
#' @examples tc1 <- rpu.par.mois(d15, FALSE)
#' tc2 <- rpu.par.mois(d15, TRUE)
#' a <- rbind(tc1, tc2)
#' par(mar=c(5.1, 4.1, 8.1, 2), xpd=TRUE)
#' barplot(a, beside = TRUE, cex.names = 0.8)
#' legend("topleft", inset = c(0, -0.1), legend = c("Brut","Standardisé"), bty = "n", col = c("black","gray80"), pch = 15)
#' 
#' barplot(tc, main = "Nombre de RPU par mois standards de 30 jours", col = "cornflowerblue")
#' 
#' @export
#' 
rpu.par.mois <- function(dx, standard = FALSE){
  t <- tapply(as.Date(dx$ENTREE), months(as.Date(dx$ENTREE)), length)
  # remet les mois par ordre chronologique
  t <- t[c("janvier","février","mars", "avril","mai","juin","juillet", "août", "septembre", "octobre", "novembre", "décembre")]
  if(standard == TRUE){
    # nb de jours dans le mois (la séquence doit inclure le mois suivant. 
    # SOURCE: https://stat.ethz.ch/pipermail/r-help/2007-August/138116.html)
    min <- year(min(as.Date(dx$ENTREE)))
    max <- min + 1
    d1 <- paste0(min, "-01-01")
    d2 <- paste0(max, "-01-01")
    n.j <- as.integer(diff(seq(as.Date(d1), as.Date(d2), by = "month")))
    # nb de RPU par mois constant de 30 jours
    t <- t * 30 / n.j
  }
  return(t)
}



#===========================================================================
#
# Nombre de RPU par semaine 
#
#===========================================================================
#' @title Calcule le nombre de RPU par mois
#' @description Calcule le nombre de RPU par mois de tous les ES présents dans le dataframe
#' @usage week.rpu(dx)
#' @param dx un dataframe de type RPU. Doit comporter au moins une colonne ENTREE
#' @details Nécessite Lubridate. dx peut regroupper tous les ES ou ne converner qu'un ES Particulier.
#' @return un vecteur du nombre de RPU par mois
#' @examples 
#' s <- week.rpu(dx)
#' tot <- sum(s) # nombre total de RPU
#' p = s/tot # % de RPU par semaine
#' summary(p)
#' 
#' @export
#' 
week.rpu <- function(dx){
  s <- tapply(as.Date(dx$ENTREE), week(as.Date(dx$ENTREE)), length)
  return(s)
}

#===========================================================================
#
# Variation du nombre de RPU par semaines
#
#===========================================================================
#' @title Variation du nombre de RPU par semaine
#' @description 
#' @usage week.variations(vx, last = FALSE)
#' @param vx vecteur du nombre de RPU pr semaine (voir week.rpu)
#' @param last boolean Si TRUE, on élimine la dernière semaine qui est souvent incomplète. FALSE par défaut.
#' @details 
#' @return un vecteur d'entiers positifs ou négatifs
#' @examples d3 <- week.rpu(dx[dx$FINESS == "3Fr",])
#' v <- week.variations(d3)
#' @export
#' 
week.variations <- function(vx, last = FALSE){
  # calcul de la différence d'une semaine à 'autre
  x <- diff(vx)
  # x compte une unité de moins que vx. Le 1er chiffre de d3 correspond à la semaine 2
  # ajout de 0 en tête du vecteur pour remplacer la première semaine
  x <- c(0, x)
  # pour supprimer la denière semaine qui est souvent incomplète (option)
  if(last == TRUE)
    x <-x[-length(x)]
  return(x)
}

#===========================================================================
#
# Représentation graphique des variations hebdomadaires
#
#===========================================================================
#' @title Variation du nombre de RPU par semaine
#' @description 
#' @usage barplot.week.variations()
#' @param x vecteur du nombre de RPU pr semaine (voir week.rpu)
#' @param coltitre bool, si TRUE la valeur de la barre est inscrite au dessus ou en dessous
#' @param colmoins couleur des barres négatives. Red par défaut
#' @param colplus couleur des barres positives. Blue par défaut
#' @param xlab nom pour l'axe des X. 'Semaines' par défaut
#' @param cex.names échelle pour le titre des barres (n° de la semaine). 0.8 par défaut
#' @param cex.col échelle pour les valeurs des colonnes. Utile que si coltitre = TRUE. Défaut 0.8
#' @param dx écart entre le sommet de la barre et l'affichage de sa valeur. Utile que si coltitre = TRUE. Défaut 3.
#' @param ... autres paramètres pour boxplot
#' @details 
#' @return le vecteur des abcisses des colonnes
#' @examples v <- week.variations(dx[dx$FINESS == "3Fr",])
#' barplot.week.variations(v[-length(v)], las = 2, main = "test", ylim = c(min(v[-length(v)])-10, max(v[-length(v)])+10), 
#' ylab = "Variations hebdomadaires")
#' 
#' ###
#' v <- week.variations(week.rpu(dx[dx$FINESS == "Col",]))
#' barplot.week.variations(v[-length(v)], las = 2, main = "CH Colmar - 2015", 
#' ylim = c(min(v[-length(v)])-10, max(v[-length(v)])+10), ylab = "Variations hebdomadaires", dx = 5)
#' 
#' @export
barplot.week.variations <- function(x, coltitre = TRUE, colmoins = "red", colplus = "blue", xlab = "Semaines", 
                                    cex.names = 0.8, cex.col =  0.8, dx = 3, ...){
  # barplot sauf la dernière semaine qui est souvent incomplète
  b <- barplot(x, col = ifelse(x > 0, colplus, colmoins), names.arg = 1:length(x), cex.names = cex.names,  xlab = xlab, ...)
  if(coltitre == TRUE)
    text(b, ifelse(x > 0, x + dx,  x - dx), x, cex = cex.col)
}


#  en pourcentages: diff(x)/x
# a <- x[-1] # on enlève le 0 initial
# b <- d3[1:(length(d3)-2)] # ou -1 si on a pas supprimé la dernière semaine pour x
# p <- round(a*100/b, 2)
# p

#===========================================================================
#
# Analyse une journée glissante
#
#===========================================================================
#' @title Analyse une journée glissante
#' @description Récupère les données d'un même jour pour un FINESS donné au cours des n jours qui suivent sa production
#' @usage
#' @param date date du jour à analyser
#' @param finess pour quel établissement ?
#' @param save dossier de sauvegarde. Ce dossier doit exister
#' @details les jours glissants doivent exister
#' @return un dataframe des RPU glissants
#' 

jour_glissant <- function(date, finess, n = 6, save = NULL){
  
  s <- seq(as.Date(date), as.Date(date) + n, 1)
  for(i in 1:length(s)){
    d <- rpu_jour(s[i])
    d <- d[d[, "FINESS"] == finess & as.Date(d$ENTREE) == date,]
    if(!is.null(save))
      write.csv(d, file = paste0(save, "/", date, ".csv")) else print(d)
  }

}