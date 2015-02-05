##============================
#
#   complet
#
#=============================
#'@description crée un dataframe du pourcentage de complétion des items du RPU par les hôpitaux
#'@name
#'@param hop vecteur contenant le noms des hôpitaux
#'@param d07 dataframe contenant les RPU à analyser
#'@return un dataframe
#'@example: analyse du fichier pour le mois de juillet 2014
#' 
#' a <- unique(d07$FINESS) # vecteur des noms d'hôpitaux
#' q <- complet(a,d07)

complet <- function(hop, d07){
  j = 0;
  for(i in hop){
    x <- h(d07[d07$FINESS==i,]); 
    x <- (1-x)*100; 
    j = j+1
    if(j == 1)
      t = x
    else
      t = rbind(t,x)
  }
  t <- data.frame(t)
  row.names(t) <- hop
  return(t)
}


##============================
#
#   sort.data.frame
#
#=============================
#'@description trie un dataframe
#'@author Mark van der Loo
#'@source http://www.markvanderloo.eu/yaRb/2014/08/15/sort-data-frame/
#'@example sort(q, by="DP")
#'@example sort(iris, by="Sepal.Length")
#'@example sort(iris, by=c("Species","Sepal.Length"))
#'@example sort(iris, by=1:2)
#'@example sort(iris, by="Sepal.Length",decreasing=TRUE)
#'
sort.data.frame <- function(x, decreasing=FALSE, by=1, ... ){
  f <- function(...) order(...,decreasing=decreasing)
  i <- do.call(f,x[by])
  x[i,,drop=FALSE]
}

##============================
#
#   mode.sortie
#
#=============================
#'@description crée un dataframe contenant le total de passages, d'hospitalisation, de mutation, de transferts par jour
#'@author JcB
#'@param dx dataframe contenant au minimum les colonnes ENTREE, MODE_SORTIE
#'@return dataframe contenant une colonne date, passage.jour, hospit.jour, mutations.jour, transfert.jour, taux.hosp
#'@details hospitalisation = mutation + transfert
#'@details taux hospitalisation = hospitalisation / passages
#'@usage dd <- mode.sortie(d14)
#'
mode.sortie <- function(dx){
  passages.jour <- tapply(as.Date(dx$ENTREE), as.Date(dx$ENTREE), length)
  mut <- dx[dx$MODE_SORTIE == "Mutation", "ENTREE"]
  mutations.jour <- tapply(as.Date(mut),  as.Date(mut), length)
  trans <- dx[dx$MODE_SORTIE == "Transfert", "ENTREE"]
  transfert.jour <- tapply(as.Date(trans),  as.Date(trans), length)
  hospit.jour <- mutations.jour + transfert.jour
  date <- unique(sort(as.Date(dx$ENTREE)))
  taux.hosp <- round(hospit.jour * 100 / passages.jour, 2)
  sortie <- data.frame(date, passages.jour, hospit.jour, mutations.jour, transfert.jour, taux.hosp)
}


# en cours: y a t'il plus d'hospitalisation en 2015 qu'en 2014 ?

# tableau mensuel provisoire = jours consolidés + 6 derniers jours
sel <- d01.p[d01.p$FINESS == "Sel",]
# période équivalente en 2014
sel14 <- d14[d14$FINESS == "Sel" & month(as.Date(d14$ENTREE)) == 1,]
# on isole les hospitalisations de sélestat
t.sel15 <- tapply(sel[sel$MODE_SORTIE=="Mutation", "MODE_SORTIE"], as.Date(sel$ENTREE[sel$MODE_SORTIE=="Mutation"]), length)
t.sel14 <- tapply(sel14[sel14$MODE_SORTIE=="Mutation", "MODE_SORTIE"], as.Date(sel14$ENTREE[sel14$MODE_SORTIE=="Mutation"]), length)
bilan <- cbind(t.sel15, t.sel14, t.sel15 - t.sel14)
barplot(bilan[,3], las=2, main = "Hospitalisation Sélestat 2015-2014", ifelse(bilan[,3] > 0, col="green", col="blue"))
# somme des 3 colonnes
apply(bilan, 2, sum)


# d1 <- d01.p[d01.p$FINESS == "Sel", c("ENTREE", "MODE_SORTIE")]
# d2 <- d14[d14$FINESS == "Sel" & as.Date(d14$ENTREE) < "2014-02-01" , c("ENTREE", "MODE_SORTIE")]
# a <- mutation(d1, d2)

# idem avec Colmar
# d1 <- d01.p[d01.p$FINESS == "Col", c("ENTREE", "MODE_SORTIE")]
# d2 <- d14[d14$FINESS == "Col" & as.Date(d14$ENTREE) < "2014-02-01" , c("ENTREE", "MODE_SORTIE")]
# a <- mutation(d1, d2)
# barplot(a[,3], las=2, main = "Hospitalisation Colmar 2015-2014")
# apply(a, 2, sum)


# fonction pour essayer de créer automatiquement d1 et d2
col.date <- function(d){
  d1 <- d[d$FINESS == "Sel", c("ENTREE", "MODE_SORTIE")]
}

mutation <- function(d1, d2){
  t.d1 <- tapply(d1[d1$MODE_SORTIE=="Mutation", "MODE_SORTIE"], as.Date(d1$ENTREE[d1$MODE_SORTIE=="Mutation"]), length)
  t.d2 <- tapply(d2[d2$MODE_SORTIE=="Mutation", "MODE_SORTIE"], as.Date(d2$ENTREE[d2$MODE_SORTIE=="Mutation"]), length)
  bilan <- cbind(t.d1, t.d2, t.d1 - t.d2)
  return(bilan)
}

a <- mutation(d1, d2)
barplot(a[,3], las=2, main = "Hospitalisation Sélestat 2015-2014")
apply(a, 2, sum)