# DP
JcB  
01/10/2014  

Analyse des diagnostics principaux
=================================

Pour l'analyse, le fichier doit s'appeler dx. Ainsi pour 2014 on mettra dans le préambule dx <- d14.


```
## Loading required package: foreign
## Loading required package: survival
## Loading required package: MASS
## Loading required package: nnet
## 
## Attaching package: 'epitools'
## 
## The following object is masked from 'package:survival':
## 
##     ratetable
## 
## Loading required package: zoo
## 
## Attaching package: 'zoo'
## 
## The following objects are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
```




Combien de sorte de DP sont crées par jour ?
============================================

ex. avec Sélestat: on crée un objet de type liste formé d'autant de listes qu'il y a de jours (1 liste par jour). Chaque liste est formée par les codes CIM10 du jour, lesquels ont regroupés par type grace à la méthode table. Au final on obtient pour chaque jour la liste des codes CIM et pour chaque code, le nombre de dossiiers correspondants. Par la fonction _length_ on compte le nombre de diagnostics uniques. L'ensemble est résumé par la fonction _summary_.


```
[1] 65
```

```

 B432  C719  D649  H650  H660  H813  I269  J040  J159  J181  J188  J209 
    1     1     1     1     1     1     1     1     1     2     1     2 
 J302  J451  J961  K528  K580  K590  K625  L022  L024  L028  L500  M139 
    1     1     1     1     1     1     1     1     1     1     1     1 
 M544 M5459  N188   N23  N300  N390  R040  R074  R100   R33  R509   R51 
    1     1     1     1     1     2     1     4     1     1     1     1 
R53+1  R600  S011  S015  S018 S0600  S223  S300 S3200 S4220  S430  S460 
    1     1     1     1     3     2     1     1     1     1     1     1 
 S520 S5250  S602  S610  S611 S6260 S6261  S800  S801 S8240  S901  S934 
    1     1     1     2     1     1     1     2     1     1     2     6 
 S936  T173  T435  Z020  Z711 
    1     1     1     1     1 
```

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
<<<<<<< HEAD
   0.00   57.50   63.00   60.84   69.00   92.00 
=======
   0.00   58.00   63.00   61.28   69.00   92.00 
>>>>>>> aaaf4ac3a9cc884c25992704813ee9fe6e094573
```

![](dp_files/figure-html/diag_par_jour-1.png) 


Bronchiolites
=============


```r
bron<-dpr[substr(dpr$DP,1,3)=="J21" & dpr$AGE < 10 ,] # on limite aux moins de 10 ans
n.bron <- nrow(bron) # nombre de bronchiolites
# age des bronchioloites en mois
age.bron <- (as.Date(bron$ENTREE) - as.Date(bron$NAISSANCE))/30

n2 <- length(age.bron[age.bron < 25]) # nb de 24 mois (2 ans)
round(n2 * 100 / n.bron, 2) # % de 2 ans et moins
```

```
<<<<<<< HEAD
## [1] 96.92
=======
## [1] 96.86
>>>>>>> aaaf4ac3a9cc884c25992704813ee9fe6e094573
```

```r
titre <- paste0("Bronchiolites", " - ", anc)

m<-month(bron$ENTREE,label=T)
barplot(table(m),main = titre, xlab="Mois", ylab = "nombre de RPU")
```

![](dp_files/figure-html/bronchiolites-1.png) 

```r
# nombre de bronchiolites par semaine
s<-week(bron$ENTREE)
n.bronchio.par.semaine <- table(s)
barplot(table(s),main = titre, xlab = "Semaines", ylab = "nombre de RPU", las = 2, cex.names = 0.8)
```

![](dp_files/figure-html/bronchiolites-2.png) 

```r
# ages des enfants en mois
age.bron <- (as.Date(bron$ENTREE) - as.Date(bron$NAISSANCE))/30
s.age.bron <- summary(as.numeric(age.bron)) # résumé
ceiling(as.numeric(s.age.bron["Min."] * 30)) # age min en jours
```

```
## [1] 7
```

```r
# sexe
summary(bron$SEXE)
```

```
##    F    M         I 
<<<<<<< HEAD
##  668 1117    0    1
=======
##  655 1094    0    1
>>>>>>> aaaf4ac3a9cc884c25992704813ee9fe6e094573
```

```r
# age de tous les RPU en jours
age.jours <- as.numeric(as.Date(dx$ENTREE) - as.Date(dx$NAISSANCE))

# age de tous les rpu en mois
age.en.mois <- as.numeric(as.Date(dx$ENTREE) - as.Date(dx$NAISSANCE))/30

# nb de rpu de moins de 24 mois
ped2.age <- age.en.mois[age.en.mois > 0 & age.en.mois < 24.1]
summary(ped2.age)
```

```
##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
<<<<<<< HEAD
##  0.03333  4.56700 10.70000 10.91000 16.80000 24.07000
=======
##  0.03333  4.55800 10.67000 10.90000 16.77000 24.07000
>>>>>>> aaaf4ac3a9cc884c25992704813ee9fe6e094573
```

```r
# il faut calculer le nombre de rpu de moins de 2 ans par semaine, puis voir ce que les bronchiolites représentent en %

a <- data.frame(dx$ENTREE, age.en.mois)
a <- a[a$age.en.mois > 0 & a$age.en.mois < 24.1,]
colnames(a) <- c("ENTREE", "AGE.MOIS")


# nombre de passages des moins de 2 ans par semaine
# NB: semaine 41 = nouveau flux des HUS
n.rpu.inf2ans.par.semaine <- tapply(as.Date(a$ENTREE), week(as.Date(a$ENTREE)), length)
barplot(n.rpu.inf2ans.par.semaine, main = "Passages des moins de 2 ans", ylab = "nombre de RPU", xlab = "semaines")
```

![](dp_files/figure-html/bronchiolites-3.png) 

```r
# Pourcentage de bronchiolites par rapport au nombre total de passages d'enfants de moins de 24 mois
a <- round(n.bronchio.par.semaine * 100 / n.rpu.inf2ans.par.semaine, 2)
barplot(a, xlab = "semaines", ylab = "% de bronchiolites", main = "Pourcentage de bronchiolites par rapport au nombre total de passages\n d'enfants de moins de 24 mois")
```

![](dp_files/figure-html/bronchiolites-4.png) 

```r
# sous forme de courbe type InVS
plot(a, type="l", xlab = "semaines", ylab = "% de bronchiolites", main = "Proportion de bronchiolites parmi le total de passages\n chez les enfants de moins de 24 mois")
```

![](dp_files/figure-html/bronchiolites-5.png) 

Syndrome grippal
================

__ATENTION__: les gaphiques de ce paragraphe ne sont exact que __dpr__ ne concerne que 2014. La transformation en mois supprime la notion d'année => si plusieurs années, la transformation en mois entraïne la somme des valeurs du mois: par ex. mois 1 correspond à la somme janvier 2014 et janvier 2015.

![](dp_files/figure-html/grippe-1.png) 

Répartition par age
--------------------
![](dp_files/figure-html/grippe_age-1.png) ![](dp_files/figure-html/grippe_age-2.png) 

Gravité
-------

```
## 
##  1  2  3  4  5  D  P    
##  1 17 33  1  0  0  0  0
```


Comparaison 2014 - 2015
-----------------------
Utilise __tapply__ avec une liste de deux factors, l'année et le mois. On obtient une matrice de 2 lignes (2014 et 2015) et 12 colonnes pour chacun des mois. On peut construire un graphe avec 2 barres par mois (beside).

![](dp_files/figure-html/grippe2-1.png) ![](dp_files/figure-html/grippe2-2.png) ![](dp_files/figure-html/grippe2-3.png) ![](dp_files/figure-html/grippe2-4.png) ![](dp_files/figure-html/grippe2-5.png) 

Allergies respiratoires
=======================

- rhinite allergique: J30
- asthme: J45

