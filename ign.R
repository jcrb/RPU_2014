# source IGN
# geodesie.ign.fr/index.php?page=algorithmes

e = 0.08199188998 # première exentricité de l'éllipsoïde
phi = 0.87266462600 # latitude en radian
epsilon = 1e-11 # tolérance de convergence

#============================================================
#
# ALG0001: calcul de la latitude isométrique
#
#============================================================
#'@usage phi = 0.87266462600; lat.isometrique(phi, e) # 1.005527

lat.isometrique <- function(phi, e){
  L = log((tan(pi/4 + phi/2)) * ((1 - e * sin(phi)) / (1 + e * sin(phi)))^(e/2))
  return(L)
}

#===================================================================
#
# ALG0002: calcul de la latitude à partir de la latitude isométrique
#
#====================================================================
# L <- 1.00552653648
# lat.iso2lat(L, e) = 0.8726646
 
lat.iso2lat <- function(L, e, epsilon = 1e-11 ){
  phi <- 2 * atan(exp(L)) - pi/2
  c <- ((1 + e * sin(phi))/(1 - e * sin(phi)))^(e/2)
  phi2 <- 2 * atan(c * exp(L)) - pi/2
  while(abs(phi2 - phi) > epsilon){
    phi = phi2
    c <- ((1 + e * sin(phi))/(1 - e * sin(phi)))^(e/2)
    phi2 <- 2 * atan(c * exp(L)) - pi/2
  }
  return(phi)
}

#============================================================
#
# ALG0003: Coordonnées géographiques en Lambert
#
#============================================================
#'@ param L latitude isométrique sur l'éllipsoïde
#'@param lamda longitude par rapport au méridien d'origine
#'@param phi latitude
#'@param n exposant de la projection
#'@param c constante de la projection en mètres
#'@param e première exentricité de l'éllipsoïde
#'@param lamdac longitude de l'origine par rapport au méridien d'origine (radians)
#'@param Xs, Ys coordonnées en projection du pôle en mètres
#'@usage e <- 0.0824832568; phi <- 0.8726646; lamda <- 0.1455121;
#'       geo2lamb(phi, lamda, e)
#'       # [1] 1029705.1  272723.9

geo2lamb <- function(phi, lamda, e){
  # constante
  n <- 0.760405966
  c <- 11603796.9767
  lamdac <- 0.04079234433
  Xs <- 600000.0000
  Ys <- 5657616.6740
  
  L <- lat.isometrique(phi, e)
  x <- Xs + c * exp(-n * L) * sin(n * (lamda - lamdac))
  y <- Ys - c * exp(-n * L) * cos(n * (lamda - lamdac))
  sortie <- c(x,y)
  return(sortie)
}

#============================================================
#
# ALG0004: Coordonnées Lambert en géographiques
#
#============================================================
#' Transformation de coordoonées en projection conique conforme de Lambert
#' en coordoonées géographiques
#' Paramètres en entrée:
#' @param X,Y les coordonnées LAMBERT du point en mètres
#' @param n exposant de la projection
#' @param c constante de la projection en mètres
#' @param e première exentricité de l'éllipsoïde
#' @param lamdac longitude de l'origine par rapport au méridien d'origine (radians)
#' @param Xs, Ys coordonnées en projection du pôle en mètres
#' @param epsilon = 1e-11 # tolérance de convergence
#' Paramètres de sortie:
#' lamda longitude par rapport au méridien d'origine
#' phi latitude
#' UTILISE ALGO0002 (latitude isométrique) et ALGO0019, ALGO054 pour n,c,lamdac,Xs,Ys
#' @usage X <- 1029705.083; Y <- 272723.849
#'        Lambert2geo(X,Y)
#'        [1] 0.1455121 0.8726646

Lambert2geo <- function(X, Y){
  # constantes
  n <- 0.760405966
  c <- 11603796.9767
  Xs <- 600000.0
  Ys <- 5657616.674
  lamdac <- 0.04079234433
  e <- 0.0824832568
  # calcul
  R <- sqrt((X - Xs)^2 + (Y - Ys)^2)
  g <- atan((X - Xs)/(Ys - Y))
  lamda <- lamdac + g / n
  L <- -1/n * log(abs(R/c))
  phi <- lat.iso2lat(L, e)
  sortie <- c(lamda, phi)
  return(sortie)
}

#============================================================
#
# ALG0021: Calcul de la grande normale
#
#============================================================
#' Paramètres en entrée
#' @param phi latitude
#' @param a demi-grand axe de l'ellipsoïde
#' @param e première exentricité de l'éllipsoïde
#' @references http://geodesie.ign.fr/contenu/fichiers/ellipsoide_geodesique.pdf
#' @references Clarke 1880 IGN NTF a = 6 378 249,2 m
#' @references International Hayford 1909 ED 50 a = 6 378 388,0 m
#' @references WGS84 WGS84 a = 6 378 137,0 m

grande.normale <- function(phi, a = 6378388, e = 0.08199189){
  n <- a / sqrt(1 - e * e * sin(phi) * sin(phi))
  return(n)
}

#============================================================
#
# ALG0000: Calcul de l'applatissement
#
#============================================================
#'@param a demi grand axe de l'éllipsoïde
#'@param b demi petit axe de l'éllipsoïde
#'@return applatissement
#'@references https://fr.wikipedia.org/wiki/WGS_84
#'@references http://geodesie.ign.fr/contenu/fichiers/Modeles_ellipsoides_France.pdf
#'

applatissement <- function(a, b){
  return(sqrt((a - b)/a))
}

demi.petit.axe <- function(applatissement, a){
  return(a - applatissement * a)
}
#============================================================
#
# ALG0000: Calcul de la première exentricité
#
#============================================================
#'@param a demi grand axe de l'éllipsoïde
#'@param b demi petit axe de l'éllipsoïde
#'@return première excentricité
#'@references https://fr.wikipedia.org/wiki/WGS_84
#'@references http://geodesie.ign.fr/contenu/fichiers/Modeles_ellipsoides_France.pdf
first.ex <- function(a, b){
  e1 <- sqrt((a*a - b*b) / (a*a))
  return(e1)
}

#============================================================
#
# ALG0000: Calcul de la deuxième exentricité
#
#============================================================
#'@param a demi grand axe de léllipsoïde
#'@param b demi petit axe de l'éllipsoïde
#'@return deuxième excentricité
#'@references https://fr.wikipedia.org/wiki/WGS_84
first.ex <- function(a, b){
  e2 <- sqrt((a*a - b*b) / b*b)
  return(e2)
}

#============================================================
#
# ALG0019: Paramètres de projection LAMBERT tangent
#
#============================================================
#' Paramètres de prpjection pour projection Lambert conique conforme
#' dans le cas tangent avec ou sans facteur d'échelle
#' Paramètres d'entrée:
#' @param a demi-grand axe de l'éllipsoïde
#' @param e première exentricité
#' @param lamda0 longitude d'origine par rapport au méridien origine
#' @param phi0 latitude origine
#' @param k0 facteur d'échelle à l'origine
#' @param X0, Y0 coordonnées en projection du point origine
#' Paramètres de sortie
#' @return e première exentricité de l'ellipsoïde
#' @return lamdac longitude origine par rapport au mérifien origine
#' @return n exposant de laprojection
#' @return c constante de projection
#' @return Xs, Ys coordonnées do pôle en projection
#' Utilise: ALG0001 et ALG0021
#' @usage p <- param.lamb.tang(6378388, 0.081991890, 0.181128088, 0.977384381, 1, 0,0)

param.lamb.tang <- function(a, e, lamda0, phi0, k0, X0, Y0){
  lamdac <- lamda0
  n <- sin(phi0)
  c <- k0 * grande.normale(phi0, a, e) * 1/tan(phi0) * exp(n * lat.isometrique(phi0, e))
  Xs <- X0
  Ys <- Y0 + k0 * grande.normale(phi0, a, e) * 1/tan(phi0)
  sortie <- rep(0, 6)
  sortie <- c(e, n, c, lamdac, Xs, Ys)
  names(sortie) <- c("e","n","c","lamdac","Xs","Ys")
  return(sortie)
}