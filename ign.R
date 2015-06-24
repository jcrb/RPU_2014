# source IGN
# geodesie.ign.fr/index.php?page=algorithmes

e = 0.08199188998 # première exentricité de l'éllipsoïde
phi = 0.87266462600 # latitude en radian
epsilon = 1e-11 # tolérance de convergence

# ALG0001: calcul de la latitude isométrique
#'@usage phi = 0.87266462600; lat.isometrique(phi, e) # 1.005527

lat.isometrique <- function(phi, e){
  L = log((tan(pi/4 + phi/2)) * ((1 - e * sin(phi)) / (1 + e * sin(phi)))^(e/2))
  return(L)
}

# ALG0002: calcul de la latitude à partir de la latitude isométrique
# L <- 1.00552653648
# lat.iso2lat(L, e) = 0.8726646
 
lat.iso2lat <- function(L, e){
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

# ALG0003: Coordonnées géographiques en Lambert
#'@ param L latitude isométrique sur l'éllipsoïde
#'@param lamda longitude par rapport au méridien d'origine
#'@param phi latitude
#'@param n exposant de la projection
#'@param c constante de la projection en mètres
#'@param e première exentricité de l'éllipsoïde
#'@param lamdac longitude de l'origine par rapport au méridien d'origine (radians)
#'@param Xs, Ys coordonnées en projection du pôle en mètres

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
  a <- c(x,y)
  return(a)
}