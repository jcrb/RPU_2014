# Temps de passage
JcB  
11/02/2015  

Temps de passage est la durée entre l'heure d'entrée et l'heure de sortie.


```
## [1] "2014-01-01"
```

```
## [1] "2014-12-31"
```

Données générales
-----------------

```r
# e <- ymd_hms(d14$ENTREE) # vecteur des entrées
# s <- ymd_hms(d14$SORTIE) # vecteur des sorties
# d <- as.numeric((s-e)/60) # vecteur des durées de passage en minutes
# alternative: d <- difftime(s, e, unit = "mins") voir ?difftime pour plus de détails.

sdp <- summary(d)
sdp
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
## -3959.0    55.0   108.0   155.2   200.0 87930.0   42384
```

```r
inf <- d[d < 0 & !is.na(d)] # dp négatives
zero <- d[d == 0 & !is.na(d)] # dp nulles
na <- d[is.na(d)] # les NA

sup1 <- d[d > 1*24*60 & !is.na(d)] # dp > 1 jour
sup2 <- d[d > 2*24*60 & !is.na(d)] 
sup3 <- d[d > 3*24*60 & !is.na(d)]
sup4 <- d[d > 4*24*60 & !is.na(d)]
sup5 <- d[d > 5*24*60 & !is.na(d)]
sup6 <- d[d > 6*24*60 & !is.na(d)] # dp > 6 jour
sup6/(24*60) # 3 dossiers > 6 jours
```

```
## [1]  6.309722 61.057639 61.060417 30.745139
```

```r
# nb de durée de passage incomplète par établisement
dp.na <- d14$FINESS[is.na(d14$DPAS)]
sdp.na <- summary(na)
nfiness <- summary(d14$FINESS) # nb de rpu par établissement
round(sdp.na * 100 / nfiness, 2) # % de durée de passage in complète
```

```
## Warning in sdp.na * 100/nfiness: la taille d'un objet plus long n'est pas
## multiple de la taille d'un objet plus court
```

```
##    3Fr    Alk    Ane    Col    Dia    Dts    Geb    Hag    Hus    Mul 
##     NA     NA     NA    NaN     NA     NA 264.50     NA     NA     NA 
##    Odi    Ros    Sav    Sel    Wis 
##    NaN     NA     NA 147.02     NA
```

```r
# présentation en tableau
t <- rbind(sdp.na, nfiness, round(sdp.na * 100 / nfiness, 2))
```

```
## Warning in sdp.na * 100/nfiness: la taille d'un objet plus long n'est pas
## multiple de la taille d'un objet plus court
```

```
## Warning in rbind(sdp.na, nfiness, round(sdp.na * 100/nfiness, 2)): number
## of columns of result is not a multiple of vector length (arg 1)
```

```r
rownames(t) <- c("RPUa", "RPUt", "%")
t
```

```
##        3Fr   Alk  Ane   Col   Dia  Dts     Geb   Hag   Hus   Mul   Odi
## RPUa    NA    NA   NA   NaN    NA   NA 42384.0    NA    NA    NA   NaN
## RPUt 16134 12660 7418 67378 29410 3910 16024.0 39938 61793 59471 24956
## %       NA    NA   NA   NaN    NA   NA   264.5    NA    NA    NA   NaN
##       Ros   Sav      Sel   Wis
## RPUa   NA    NA 42384.00    NA
## RPUt 7210 29445 28828.00 12158
## %      NA    NA   147.02    NA
```

Choix de l'établissement
------------------------



RPU utilisés (reco FEDORU)
--------------------------

On ne garde que les RPU avec une durée de passage exploitable et qui soit positive et inférieure ou égale à 48 heures.




- nombre de RPU exploitable: 372 067
- nombre de RPU totaux: 416 733

Durée moyenne de passage
-------------------------

![](temps_passage_files/figure-html/paddage_moyenne-1.png) ![](temps_passage_files/figure-html/paddage_moyenne-2.png) 
- moyenne durée de passage: 154.9188157 minutes
- médiane durée de passage: 109 minutes

Durée moyenne de passage et MODE_SORTIE
---------------------------------------

- nombre de RPU: 372067
- moyenne durée de passage en cas de retour à domicile: 145.8773466 minutes.
- moyenne durée de passage en cas d'hospitalisation: 187.5583825 minutes.

- médiane durée de passage en cas de retour à domicile: 104 minutes.
- médiane durée de passage en cas d'hospitalisation: 148 minutes.

Analyse des durées de passage > 6 heures
----------------------------------------

- p6h: liste des RPU dont la durée de passage est supérieure à 6 heures
- p6h.jour: total journalier des RPU dont la durée de passage est supérieure à 6 heures (vecteur de 365 jpours). Il peut y avoir des jours vides, soit parce que le jour n'a pas été renseigné, soit parce qu'aucun passage n'a dépassé 6 heures.


```r
# RPU avec durée de passage > 6h. 
p6h <- p14[p14$DPAS > 6*60, c("ENTREE", "FINESS")]
p6h.jour <- tapply(as.Date(p6h$ENTREE), as.Date(p6h$ENTREE), length) # RPU de plus de 6 heures par jour

# PB: ILPEUT Y AVOIR DES JOURS SANS PASSAGE  > 6 HEURES (EX. SELESTAT) => FAIRE UN MERGING AVEC UN CALENDRIER.
# OK: AJUSTER LE CALENDRIER 0 LA TAILLE DE D14

p6h.jour <- aligne.sur.calendrier(min(d14$ENTREE), max(d14$ENTREE), p6h.jour)

summary(p6h.jour) # résumé passage de plus de 6 heures"
```

```
##    calendrier              rpu        
##  Min.   :2014-01-01   Min.   : 31.00  
##  1st Qu.:2014-04-02   1st Qu.: 59.00  
##  Median :2014-07-02   Median : 75.00  
##  Mean   :2014-07-02   Mean   : 79.92  
##  3rd Qu.:2014-10-01   3rd Qu.: 95.00  
##  Max.   :2014-12-31   Max.   :195.00
```

```r
sum(is.na(p6h.jour)) # nb de jours sur la période sans passage > 6 heures
```

```
## [1] 0
```

```r
mean(is.na(p6h.jour)) # idem en %
```

```
## [1] 0
```

Aspect graphique
----------------

![](temps_passage_files/figure-html/passage_graphe-1.png) ![](temps_passage_files/figure-html/passage_graphe-2.png) ![](temps_passage_files/figure-html/passage_graphe-3.png) ![](temps_passage_files/figure-html/passage_graphe-4.png) ![](temps_passage_files/figure-html/passage_graphe-5.png) ![](temps_passage_files/figure-html/passage_graphe-6.png) 

Passages des plus de 75 ans
===========================

Patients agés de 75 ans ou plus.

```r
pop75 <- p14[p14$AGE > 74,]

summary(pop75$DPAS)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
##     1.0    79.0   187.0   218.5   310.0  2880.0       4
```

```r
pop75.jour <- tapply(as.Date(pop75$ENTREE), as.Date(pop75$ENTREE), length)
pop75.jour <- aligne.sur.calendrier(min(as.Date(pop75$ENTREE),na.rm=TRUE), max(as.Date(pop75$ENTREE),na.rm=TRUE), pop75.jour)

# plot(xts(pop75.jour, order.by = as.Date(rownames(pop75.jour))), minor.ticks = FALSE, ylab = "Nombre de passage (mn)", main = "Evolution du nombre de passage par jour pour les 75 ans et plus")

plot(xts(pop75.jour$rpu, order.by = as.Date(pop75.jour$calendrier)), minor.ticks = FALSE, ylab = "Nombre de passage (mn)", main = "Evolution du nombre de passage par jour pour les 75 ans et plus")

lines(rollmean(xts(pop75.jour$rpu, order.by = as.Date(pop75.jour$calendrier)), k = 7), col = "red", lwd = 2)
copyright()
```

![](temps_passage_files/figure-html/unnamed-chunk-3-1.png) 
Proportion des 75 ans par rapport à tous les RPU
--------------------------------------------------


```r
pop.tot <- tapply(as.Date(p14$ENTREE), as.Date(p14$ENTREE), length)
pop.tot <- aligne.sur.calendrier(min(as.Date(pop75$ENTREE),na.rm=TRUE), max(as.Date(pop75$ENTREE),na.rm=TRUE), pop.tot)
r <- pop75.jour$rpu * 100 / pop.tot$rpu
summary(r)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   7.089  12.000  13.460  13.400  14.780  20.790
```

```r
plot(xts(r, order.by = as.Date(rownames(r))), minor.ticks = FALSE, ylab = "% de 75 ans", main = "Proportion de 75 ans et plus parmis des RPU")
lines(rollmean(xts(r, order.by = as.Date(rownames(r))), k = 7), col = "blue", lwd = 2)
```

![](temps_passage_files/figure-html/unnamed-chunk-4-1.png) 

Taux hospitalisation
====================

Pour les plus de 75 ans
-----------------------


```r
source(paste0(path, "new_functions.R")) # f0nctopn mode.sotie()
ms <- mode.sortie(pop75) # plantage car les tableaux sont de taille inégale => rajouter aligne.sur.calendrier
head(ms)
```

```
##                  date passages.jour.rpu hospit.jour mutations.jour.rpu
## 2014-01-01 2014-01-01                99          57                 52
## 2014-01-02 2014-01-02               183         111                103
## 2014-01-03 2014-01-03               181         110                103
## 2014-01-04 2014-01-04               153          86                 83
## 2014-01-05 2014-01-05                97          54                 50
## 2014-01-06 2014-01-06               142          85                 83
##            transfert.jour.rpu taux.hosp
## 2014-01-01                  5     57.58
## 2014-01-02                  8     60.66
## 2014-01-03                  7     60.77
## 2014-01-04                  3     56.21
## 2014-01-05                  4     55.67
## 2014-01-06                  2     59.86
```

```r
hosp.xts <- xts(ms, order.by = as.Date(ms$date))
plot(hosp.xts$taux.hosp, minor.ticks = FALSE, ylab = "Taux d'hospitalisaton pour les 75 ans", main = "Taux d'hospitalisation")
```

![](temps_passage_files/figure-html/unnamed-chunk-5-1.png) 

Question complémentaire (Schiber)
=================================


```r
# on ajoute une colonne pour les territoires
d14 <- add.territoire(d14)

# RPU > 74 ans
d14.pop75 <- d14[d14$AGE > 74,]

# nb de RPU > 74 ans par finess
rpu.finess.75ans <- tapply(as.Date(d14.pop75$ENTREE), d14.pop75$FINESS, length)
#  nb de RPU > 74 ans par territoire
rpu.territoire.75 <- tapply(as.Date(d14.pop75$ENTREE), d14.pop75$TERRITOIRE, length)
# nb de RPU par territoires
rpu.territoire <- tapply(as.Date(d14$ENTREE), d14$TERRITOIRE, length)
# nb de RPU par Finess
rpu.finess <- tapply(as.Date(d14$ENTREE), d14$FINESS, length)
# % de Rpu > 74 ans par finess
round(rpu.finess.75ans * 100/ rpu.finess, 2)
```

```
##   3Fr   Alk   Ane   Col   Dia   Dts   Geb   Hag   Hus   Mul   Odi   Ros 
## 11.09 14.80  9.37 12.66 14.07  3.91 10.66 17.26 19.97 12.58  5.17  5.02 
##   Sav   Sel   Wis 
## 13.71 13.48 17.26
```

```r
# % de Rpu > 74 ans par territoire
round(rpu.territoire.75 * 100/ rpu.territoire, 2)
```

```
##    T1    T2    T3    T4 
## 15.98 14.76 12.58 12.53
```

Durée de passage en fonction de l'heure d'arrivée
-------------------------------------------------
L'heure d'arrivée a t'elle une influence sur la durée de passage ? Les sommes cumulées des durée de passage sont elles un indicateur, notamment les périodes de tension ?

On forme un dataframe avec:

- date
- heure d'entrée
- durée de passage
- motif
- DP
- Age

Rappel: si on commence ici il faut:
library(lubridate)
source("Analyse/Temps_passage/passage.R")
load("~/Documents/Resural/Stat Resural/RPU_2014/rpu2014d0112_c2.Rda") # d14 (2014)
load("~/Documents/Resural/Stat Resural/RPU_2014/rpu2015d0112_provisoire.Rda") # d15 (2015)

# pour 2014
d14$DPAS <- as.numeric(duree.passage(d14$ENTREE, d14$SORTIE))
dpas2014 <- temps.passage(d14) # nouvelle fonction
# durée de passage moyenne en fonction de l'heure d'entrée
a <- tapply(dpas2014$DPAS, dpas2014$HEURE.E, mean)
plot(a, type = "l", xlim = c(0,25), ylab = "Durée de passage", xlab = "Heure d'entrée", main = "Temps de passage moyen en fonction de l'heure d'entrée", lwd = 3, col="blue")
boxplot(dpas2014$DPAS ~ dpas2014$HEURE.E, outline = FALSE, ylab = "Durée de passage (minutes)", xlab = "Heure d'entrée",main = "Temps de passage en fonction de l'heure d'entrée")

# pour 2015



```
##        0        1        2        3        4        5        6        7 
## 200.5799 187.1566 193.2850 201.1650 209.6375 208.7492 202.1397 176.0302 
##        8        9       10       11       12       13       14       15 
## 148.7852 152.9192 159.5309 165.7557 167.6780 162.7129 151.1152 149.5504 
##       16       17       18       19       20       21       22       23 
## 146.0409 144.6830 144.5115 139.4657 135.1092 140.2599 123.3579 124.7641
```

![](temps_passage_files/figure-html/heure_passage-1.png) ![](temps_passage_files/figure-html/heure_passage-2.png) 

Etude du cumul des temps de passage
-----------------------------------
On étudie la somme cumulée des durées de passage par heure d'entrée.

![](temps_passage_files/figure-html/cumul-here-1.png) 
Le temps cumulé le plus long s'observe à 10 heures du matin. On isole le groupe 10 heures du matin pour voir comment il évolue au cours de l'année.


```
## [1] 365
```

![](temps_passage_files/figure-html/x10-1.png) 

CUSUM des sommes
----------------
Remarque: ne pas confondre CUSUM et cumsum = somme cumulative des éléments d'un vecteur.

On utilise __x.sum__ qui est un vecteur constitué par la somme quotidienne des durées de passage des patients arrivés entre 10h et 10h59. Pour 2014, n = 365 jours.

A partir de ce vecteur on calcule la moyenne mobile et l'écart-type mobile sur 7 jours (pas = 7).

```
## [1] 365
```
Avec ces éléments, on peut calculer le vecteur centré et réduit des temps de passage cumulés

```r
ec7 <- (x.sum[7:365] - rmean) /sd7

# ec7 <- x.sum
# max(as.Date(h10$ENTREE))
# min(as.Date(h10$ENTREE))
# length(x.sum)
# length(sd7)
# length(rmean)

plot(ec7, type="l", main = "Courbe centrée-réduite des temps d'attente cumulés")
```

![](temps_passage_files/figure-html/roll_centre_reduit-1.png) 

```r
# source: passages.R
c2 <- cusum.c2(ec7)

barplot(c2, ylab = "CUSUM - C2", xlab = "Jours", main = "")
abline(h = 2, lty = 2, col = "red")
```

![](temps_passage_files/figure-html/roll_centre_reduit-2.png) 
Le vecteur __ec7__ ne commence que le 7 janvier et ne comporte que 358 jours au lieu de 365. On note également que les fluctuations se font entre 2SD, ce qui en fait un indicateur peu sensible.

Référence sur le CUSUM:

- [Détection malformations congénitales et application avec R](http://math.univ-bpclermont.fr/biblio/rapport/sante/2010/M2_Beye_10.pdf)
- [Surveillance sanitaire à partir de donnees des services d'urgence :  modélisation de séries temporelles et analyse automatique](http://dumas.ccsd.cnrs.fr/dumas-00516268/document) + programmes R.
- [aussi](http://jess2014.emse.fr/pdf/W4-1-Sarazin-Sentinelles.pdf)


On forme la somme cumulée (CUSUM) en sommant les valeurs successives du vecteur ec7:

Variation durées de passage par mois
====================================
![](temps_passage_files/figure-html/passage_mois-1.png) 

```
## Call:
##    aov(formula = DPAS ~ mois, data = dpas.heure)
## 
## Terms:
##                        mois   Residuals
## Sum of Squares       358652 10954538176
## Deg. of Freedom           1      372065
## 
## Residual standard error: 171.5883
## Estimated effects may be unbalanced
```

```
##                 Df    Sum Sq Mean Sq F value   Pr(>F)    
## mois             1 3.587e+05  358652   12.18 0.000483 ***
## Residuals   372065 1.095e+10   29443                     
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

```
## 
## Call:
## lm(formula = DPAS ~ mois, data = dpas.heure)
## 
## Coefficients:
## (Intercept)         mois  
##    152.9952       0.2834
```

```
## 
## Call:
## lm(formula = DPAS ~ mois, data = dpas.heure)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -155.40  -99.70  -46.11   46.15 2726.44 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 152.99520    0.61879  247.25  < 2e-16 ***
## mois          0.28337    0.08119    3.49 0.000483 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 171.6 on 372065 degrees of freedom
## Multiple R-squared:  3.274e-05,	Adjusted R-squared:  3.005e-05 
## F-statistic: 12.18 on 1 and 372065 DF,  p-value: 0.0004827
```

```
## Analysis of Variance Table
## 
## Response: DPAS
##               Df     Sum Sq Mean Sq F value    Pr(>F)    
## mois           1 3.5865e+05  358652  12.181 0.0004827 ***
## Residuals 372065 1.0955e+10   29443                      
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

