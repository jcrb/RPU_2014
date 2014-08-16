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