# Ensemble de fonctions pour intégrer automatiquement les RPU

# Liste des fonctions
#' - rpu_jour
#' - finess2hop
#' - parse_rpu
#' - rpu2factor
#' - analyse_rpu_jour
#' - jour_consolide
#' - lire_archive
#' - assemble

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
  a[a=="670000272"]<-"Wis"
  a[a=="680000700"]<-"Geb"
  a[a=="670780055"]<-"Hus"
  a[a=="680000197"]<-"3Fr"
  a[a=="680020096"]<-"3Fr" # maj le 30/5/2014 680020096
  a[a=="680000627"]<-"Mul"
  a[a=="670000157"]<-"Hag"
  a[a=="680000320"]<-"Dia"
  a[a=="680000395"]<-"Alk"
  a[a=="670000165"]<-"Sav"
  a[a=="680000494"]<-"Ros"
  a[a=="670780162"]<-"Dts"
  a[a=="670780212"]<-"Ane"
  a[a=="680000601"]<-"Tan"
  return(a)
}

#=======================================
#
# parse_rpu
#
#=======================================
#'
#' Préalable: disposer d'une base de donnée MySql avec une table appelée "archives".
#' Cette base doit être référencée dans le fichier .my.conf
#' 
#'@name parse_rpu
#'@title 2014-03-01
#'@author JcB
#'@param data date.jour nom du fichier. Pour une utilisation courante il s'agit de la date du jour au format ISO
#'@usage 
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
#' 
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