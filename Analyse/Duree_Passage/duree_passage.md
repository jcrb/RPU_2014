# Durées de passage
JcB  
22/10/2015  

La durée de passage est définie comme la différence entre l'heure d'entrée et de sortie du patient de la structure d'urgence.

- l'exhaustivité de l'heure d'entrée est de 100% pour tous les ED.
- l'exhaustivité de l'heure de sortie est variable. L'heure de sortie n'est pas calculable lors d'une sortie atypique: ORIENTATION = fugue, PSA, SCAM.
- Pour calculer une durée de passage il faut disposer pour un même RPU de la date d'entée et de sortie
- les durées de passage négatives ou supérieures à 72 heures sont rejetées.
- Le dataframe minimal doit comporter les colonnes ENTREE et SORTIE. Il peut être compléter par d'autres colonnes en fonction des besoins (notamment MODE_SORTIE)


```
## Loading required package: zoo
## 
## Attaching package: 'zoo'
## 
## The following objects are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
## 
## Loading required package: xtable
## Loading required package: openintro
## Please visit openintro.org for free statistics materials
## 
## Attaching package: 'openintro'
## 
## The following object is masked from 'package:datasets':
## 
##     cars
## 
## Loading required package: plotrix
```

Fonctions utiles:

- horaire: extrait le groupe horaire d'une date


Temps de passage
------------------------


```r
pas <- dx[, c("ENTREE", "SORTIE", "MODE_SORTIE", "ORIENTATION", "AGE")]

# on ne conserve que les couples complets
pas2 <- pas[complete.cases(pas[, c("ENTREE", "SORTIE")]),]
e <- ymd_hms(pas2$ENTREE)
s <- ymd_hms(pas2$SORTIE)
pas2$duree <- as.numeric(difftime(s, e, units = "mins"))

# on ne garde que les passages dont la durées > 0 et < ou = 72 heures
pas3 <- pas2[pas2$duree > 0 & pas2$duree < 3 * 24 * 60 + 1,]
pas3$MODE_SORTIE[pas3$MODE_SORTIE == 6] <- "Mutation"
pas3$MODE_SORTIE[pas3$MODE_SORTIE == 7] <- "Transfert"
pas3$MODE_SORTIE[pas3$MODE_SORTIE == 8] <- "Domicile"

# mode de sortie
n.sortie.rens <- sum(!is.na(pas3$MODE_SORTIE))
ms <- summary(as.factor(pas3$MODE_SORTIE))

n.hosp <- ms["Mutation"] + ms["Transfert"]
n.dom <- ms["Domicile"]
```

- nombre de RPU: 395387
- nombre de PRU où la durée de passage est calculable: 352495
- nombre de PRU où la durée de passage est conforme: 347788

- durée de passage moyenne: 180.9183181
- durée de passage médiane: 118

- nombre de sorties conformes renseignées: 267961
- nombre de retour à domicile: 205721
- nombre d'hospitalisation: 62239
- taux d'hospitalisation: 0.2322689

Temps de passage de moins de 4 heures
----------------------------------------


```r
pas4 <- pas3[pas3$duree < 4 * 60 + 1,]
ms4 <- summary(as.factor(pas4$MODE_SORTIE))

n.sortie4.rens <- sum(!is.na(pas4$MODE_SORTIE))

n.hosp4 <- ms4["Mutation"] + ms4["Transfert"]
n.dom4 <- ms4["Domicile"]
```

- nombre de sorties en moins de 4 heures renseignées: 204436
- nombre de retour à domicile en moins de 4 h: 170206
- nombre d'hospitalisation en moins de 4 h: 34229
- taux d'hospitalisation en moins de 4 h: 0.1674314

Temps de passage par jour
--------------------------

### moyenne du temps de passage par jour

```r
my.day <- tapply(pas3$duree, yday(as.Date(pas3$ENTREE)), mean)
xts.my.day <- xts(my.day, order.by = unique(as.Date(pas3$ENTREE)))

summary(xts.my.day)
```

```
##      Index              xts.my.day   
##  Min.   :2015-01-01   Min.   :130.6  
##  1st Qu.:2015-03-13   1st Qu.:161.6  
##  Median :2015-05-23   Median :176.0  
##  Mean   :2015-05-23   Mean   :180.8  
##  3rd Qu.:2015-08-02   3rd Qu.:201.7  
##  Max.   :2015-10-12   Max.   :241.0
```

```r
plot(xts.my.day, ylab = "durée moyenne de passage (mn)", main = "Durée moyenne de passage par jour")
```

![](duree_passage_files/figure-html/unnamed-chunk-3-1.png) 

### moyenne du temps de passage si age > 74 ans

```r
pas3.75 <- pas3[pas3$AGE > 74,]
pas3.75 <- pas3.75[!is.na(as.Date(pas3.75$ENTREE)),]
my.day <- tapply(pas3.75$duree, yday(as.Date(pas3.75$ENTREE)), mean)
xts.my.day <- xts(my.day, order.by = unique(as.Date(pas3.75$ENTREE)))

summary(xts.my.day)
```

```
##      Index              xts.my.day   
##  Min.   :2015-01-01   Min.   :202.0  
##  1st Qu.:2015-03-13   1st Qu.:248.2  
##  Median :2015-05-23   Median :266.6  
##  Mean   :2015-05-23   Mean   :266.4  
##  3rd Qu.:2015-08-02   3rd Qu.:282.3  
##  Max.   :2015-10-12   Max.   :359.8
```

```r
par(mar = c(2, 4, 4, 5))
plot(xts.my.day, ylab = "durée moyenne de passage (mn)", main = "Durée moyenne de passage par jour\n pour les patients de 75 ans et plus", lty = 3)
# moyenne mobile
lines(rollmean(x = xts.my.day, k = 7), col = "red", lwd = 2)

# second graphique
par.original <- par(no.readonly=TRUE)
par(new = TRUE)
nb.pas.jour <- tapply(as.Date(pas3.75$ENTREE), yday(as.Date(pas3.75$ENTREE)), length)
min <- min(nb.pas.jour)
max <- max(nb.pas.jour)
xts.my.pas.day <- xts(nb.pas.jour, order.by = unique(as.Date(pas3.75$ENTREE)))
plot(rollmean(x = xts.my.pas.day, k = 7), axes = F, ylim = c(min, max),  col = "blue", main="", lwd = 2, auto.grid = FALSE)
axis(4,                  # axe vertical à droite
     ylim = c(min, max), # limites de l'axe
     col = "blue",       # couleur de l'axe
     col.ticks = "blue", # couleur des marques de graduation
     col.axis = "blue" ) # couleur de la légende des graduations
mtext("Nombre de passages > 74 ans/jour", side=4, line=3, col = "blue") # nom, position, couleur de lalégende de l'axe
```

![](duree_passage_files/figure-html/unnamed-chunk-4-1.png) 

```r
par(par.original)
```


### médiane du temps de passage par jour

```r
md.day <- tapply(pas3$duree, yday(as.Date(pas3$ENTREE)), median)
xts.md.day <- xts(md.day, order.by = unique(as.Date(pas3$ENTREE)))
plot(xts.md.day, ylab = "durée médiane de passage (mn)", main = "Durée médiane de passage par jour")
```

![](duree_passage_files/figure-html/unnamed-chunk-5-1.png) 

### nombre de passages en moins de 4h par jour

On forme le rapport nb de passages de moins de 4 heures sur le nb total de passages. En peériode de tension, ce rapport diminue.

```r
n.pas4.day <- tapply(as.Date(pas4$ENTREE), yday(as.Date(pas4$ENTREE)), length)
n.pas.day <- tapply(as.Date(pas3$ENTREE), yday(as.Date(pas3$ENTREE)), length)
p.pas <- n.pas4.day / n.pas.day
xts.pas4.day <- xts(p.pas, order.by = unique(as.Date(pas3$ENTREE)))
plot(xts.pas4.day, ylab = "nombre de passages", main = "Nombre de passages de moins de 4h par jour")
```

![](duree_passage_files/figure-html/unnamed-chunk-6-1.png) 

### temps de passage si hospitalisation, par jour

```r
pas5 <- pas3[pas$MODE_SORTIE %in% c("Mutation", "Transfert"),]
pas5 <- pas5[!is.na(as.Date(pas5$ENTREE)),]
summary(pas5$duree)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##       1      62     119     183     223    4320
```

```r
my5.day <- tapply(pas5$duree, yday(as.Date(pas5$ENTREE)), mean)

xts.my5.day <- xts(my5.day, order.by = unique(as.Date(pas5$ENTREE)))
plot(xts.my5.day, main = "Durée moyenne de passage aux urgences avant hosptalisation")
```

![](duree_passage_files/figure-html/unnamed-chunk-7-1.png) 


Heures de sorties non renseignées par ES
----------------------------------------


```r
p.na.es <- round(tapply(dx$SORTIE, dx$FINESS, p.isna) * 100, 2)
a <- sort(p.na.es)
kable(t(a))
```



 Dia   Ros   Ccm    Geb    HTP   Col    Wis    Sel    Ane    NHC   Hsr     Hag     Sav     Odi     Dts   Emr     Mul     3Fr     Alk
----  ----  ----  -----  -----  ----  -----  -----  -----  -----  ----  ------  ------  ------  ------  ----  ------  ------  ------
   0     0     0   1.14   2.02   2.9   4.36   5.51   8.01   9.21   9.6   11.74   11.86   13.81   17.75    18   19.33   33.48   70.73

Pourcentage de non réponse par jour et par FINESS
-------------------------------------------------


```r
p.na.es.day <- tapply(dx$SORTIE, list(yday(as.Date(dx$ENTREE)), dx$FINESS), p.isna)

# transformation en time serie avec xts
x <- xts(p.na.es.day, order.by = unique(as.Date(dx$ENTREE)))
x <- x[, -9] # supprime la colonne Hus qui est vide
for(i in 1:ncol(x)){
  plot(x[,i], main = names(x)[i], ylab = "% de non réponses")
}
```

![](duree_passage_files/figure-html/unnamed-chunk-9-1.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-2.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-3.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-4.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-5.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-6.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-7.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-8.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-9.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-10.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-11.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-12.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-13.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-14.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-15.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-16.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-17.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-18.png) ![](duree_passage_files/figure-html/unnamed-chunk-9-19.png) 

```r
for(i in 1:ncol(x)){
  s <- apply(x[,i], MARGIN = 2, summary)
  print(s)
}
```

```
##            3Fr
## Min.    0.0000
## 1st Qu. 0.2432
## Median  0.3409
## Mean    0.3341
## 3rd Qu. 0.4348
## Max.    0.9167
##            Alk
## Min.    0.0000
## 1st Qu. 0.6346
## Median  0.7273
## Mean    0.7041
## 3rd Qu. 0.8163
## Max.    1.0000
##             Ane
## Min.    0.00000
## 1st Qu. 0.00000
## Median  0.02083
## Mean    0.07995
## 3rd Qu. 0.15490
## Max.    0.35420
## NA's    1.00000
##              Col
## Min.    0.000000
## 1st Qu. 0.000000
## Median  0.009412
## Mean    0.029500
## 3rd Qu. 0.056910
## Max.    0.171600
## NA's    1.000000
##         Dia
## Min.      0
## 1st Qu.   0
## Median    0
## Mean      0
## 3rd Qu.   0
## Max.      0
##             Dts
## Min.    0.00000
## 1st Qu. 0.08571
## Median  0.16220
## Mean    0.18110
## 3rd Qu. 0.25000
## Max.    1.00000
##             Geb
## Min.    0.00000
## 1st Qu. 0.00000
## Median  0.00000
## Mean    0.01120
## 3rd Qu. 0.01923
## Max.    0.22920
##             Hag
## Min.    0.01626
## 1st Qu. 0.07519
## Median  0.10770
## Mean    0.11660
## 3rd Qu. 0.15250
## Max.    0.28470
##             Mul
## Min.     0.0000
## 1st Qu.  0.1358
## Median   0.1719
## Mean     0.1856
## 3rd Qu.  0.2158
## Max.     0.8828
## NA's    46.0000
##             Odi
## Min.    0.00000
## 1st Qu. 0.08772
## Median  0.12880
## Mean    0.13580
## 3rd Qu. 0.16930
## Max.    0.66670
## NA's    1.00000
##         Ros
## Min.      0
## 1st Qu.   0
## Median    0
## Mean      0
## 3rd Qu.   0
## Max.      0
##             Sav
## Min.    0.00000
## 1st Qu. 0.06818
## Median  0.11590
## Mean    0.11660
## 3rd Qu. 0.16470
## Max.    0.30340
##              Sel
## Min.     0.00000
## 1st Qu.  0.02319
## Median   0.04348
## Mean     0.08939
## 3rd Qu.  0.07507
## Max.     1.00000
## NA's    13.00000
##             Wis
## Min.    0.00000
## 1st Qu. 0.00000
## Median  0.03226
## Mean    0.04416
## 3rd Qu. 0.06522
## Max.    0.21950
##              HTP
## Min.    0.000000
## 1st Qu. 0.009569
## Median  0.018940
## Mean    0.020260
## 3rd Qu. 0.028690
## Max.    0.070180
##             NHC
## Min.    0.00000
## 1st Qu. 0.05000
## Median  0.08333
## Mean    0.09427
## 3rd Qu. 0.13160
## Max.    0.45310
##              Emr
## Min.      0.0000
## 1st Qu.   0.1543
## Median    0.1826
## Mean      0.1787
## 3rd Qu.   0.2077
## Max.      0.3072
## NA's    222.0000
##               Hsr
## Min.      0.00000
## 1st Qu.   0.05469
## Median    0.08990
## Mean      0.09732
## 3rd Qu.   0.12910
## Max.      0.22220
## NA's    243.00000
##         Ccm
## Min.      0
## 1st Qu.   0
## Median    0
## Mean      0
## 3rd Qu.   0
## Max.      0
## NA's    278
```
