Préparation des fichiers pour Dygraph
=====================================

__Dygraph__ (DG) est une bibliothèque Javascript permettant d'afficher des courbes dynamiques. DG affiche des données de séries temporelles à partir d'une matrice dont la prmière colonne est obligatoirement une colonne __date__ au format ISO. Chaque colonne qui suit sera affichée individuellement.  
 Deux tables sont préparées pour _Resural_:
 - __hop_2014.csv__ nombre de passages par jour pour l'ensemble des SU d'Alsace et nombre d'hospitalisations.
 - __SU_2014.csv__ nombre de passages par jour et par SU + total, moyenne et nb hospitalisation => fichier complet pour __Dygraph__.

Circuit rapide
--------------

NB: write.csv insère "" comme nom de la première colonne qui correspond aux dates.

```r
k <- table(as.Date(dx$ENTREE), factor(dx$FINESS))
```

```
## Error: objet 'dx' introuvable
```

```r
total <- apply(k,1,sum)
```

```
## Error: objet 'k' introuvable
```

```r
hop <- cbind(k, total)
```

```
## Error: objet 'k' introuvable
```

```r
mean <- apply(k,1,mean)
```

```
## Error: objet 'k' introuvable
```

```r
hop <- cbind(hop, mean)
```

```
## Error: objet 'hop' introuvable
```

```r
# hospitalisations:
a <- dx[dx$MODE_SORTIE == "Mutation" | dx$MODE_SORTIE == "Transfert", 'ENTREE']
```

```
## Error: objet 'dx' introuvable
```

```r
hosp <- tapply(a, as.factor(yday(a)), length)
```

```
## Error: impossible de trouver la fonction "yday"
```

```r
hop <- cbind(hop, hosp)
```

```
## Error: objet 'hop' introuvable
```

```r
write.csv(hop, file="SU_2014.csv")
```

```
## Error: objet 'hop' introuvable
```

```r
date <- rownames(k)
```

```
## Error: objet 'k' introuvable
```

```r
hop2 <- cbind(date, total)
```

```
## Error: objet 'total' introuvable
```

```r
write.csv(hop2, file="hop_2014.csv", row.names=F)
```

```
## Error: objet 'hop2' introuvable
```

 
Création du fichier _hop_2014.csv_
-----------------------------------

1. on décupère le fichier général de l'ensemble des RPU provisoires (__dx__) ou consolidés (__d1__). Les dates utilisées sont dans la colonne __dx$ENTREE__. La transformation as.Date(dx$ENTREE) permet de ne conserver que la date du jour et d'éliminer la partie horaire.  

2. on crée la _table _ __k__ en croisant les colonnes __dx$ENTREE__ et __dx$FINESS__ 
```{}
k <- table(as.Date(dx$ENTREE), dx$FINESS)

           3Fr Alk Col Dia Geb Hag Hus Mul Odi Sav Sel Wis   Dts Ros
  2014-01-01  46   0 177  76  44  99  90 130  73  97 101  39 0   0   0
  2014-01-02  34  31 181  77  33 101 134 189  71  83  84  37 0   0   0
  2014-01-03  36  38 199  82  34  86 117 187  61  93  75  30 0   0   0
  2014-01-04  38  17 169  92  31  89  95 177  71  84  87  32 0   0   0
  2014-01-05  42   1 164  75  38  85  79 183  76  64  76  35 0   0   0
  2014-01-06  40  11 160  90  51  87 128 179  77  78  76  23 0   0   0
```
3. on fait la somme de chaque ligne dans le vecteur __total__ avec la méthode _apply_: total <- apply(k,1,sum). Puis on "colle" ce vecteur à la table _k_ sous forme d'une colonne supplémentaire:
```{}
total <- apply(k,1,sum)
hop <- cbind(k, total)
head(hop)

           3Fr Alk Col Dia Geb Hag Hus Mul Odi Sav Sel Wis   Dts Ros total
2014-01-01  46   0 177  76  44  99  90 130  73  97 101  39 0   0   0   972
2014-01-02  34  31 181  77  33 101 134 189  71  83  84  37 0   0   0  1055
2014-01-03  36  38 199  82  34  86 117 187  61  93  75  30 0   0   0  1038
2014-01-04  38  17 169  92  31  89  95 177  71  84  87  32 0   0   0   982
2014-01-05  42   1 164  75  38  85  79 183  76  64  76  35 0   0   0   918
2014-01-06  40  11 160  90  51  87 128 179  77  78  76  23 0   0   0  1000
```
4. De la même manière on calcule la __moyenne__ (_mean_) et l'écart-type (_sd_):

```{}
mean <- apply(k,1,mean)
sd <- apply(k,1,sd)
hop.moy <- cbind(hop, mean, sd)
head(hop.moy)

           3Fr Alk Col Dia Geb Hag Hus Mul Odi Sav Sel Wis   Dts Ros total     mean       sd
2014-01-01  46   0 177  76  44  99  90 130  73  97 101  39 0   0   0   972 64.80000 53.07165
2014-01-02  34  31 181  77  33 101 134 189  71  83  84  37 0   0   0  1055 70.33333 60.90234
2014-01-03  36  38 199  82  34  86 117 187  61  93  75  30 0   0   0  1038 69.20000 61.72543
2014-01-04  38  17 169  92  31  89  95 177  71  84  87  32 0   0   0   982 65.46667 56.31273
2014-01-05  42   1 164  75  38  85  79 183  76  64  76  35 0   0   0   918 61.20000 55.66250
2014-01-06  40  11 160  90  51  87 128 179  77  78  76  23 0   0   0  1000 66.66667 57.11350
```
5. transformation en objet de type __xts__

Many xts-sepcific methods have been written to better handle the unique aspects of xts. These include, ‘"["’, merge, cbind, rbind, c, Ops, lag, diff, coredata, head and tail. Additionally there are xts specific methods for converting amongst R's different time-series classes.

Subsetting via "[" methods offers the ability to specify dates by range, if they are enclosed in quotes. The style borrows from python by creating ranges with a double colon “"::"” or “"/"” operator. Each side of the operator may be left blank, which would then default to the beginning and end of the data, respectively. To specify a subset of times, it is only required that the time specified be in standard ISO format, with some form of separation between the elements. The time must be ‘left-filled’, that is to specify a full year one needs only to provide the year, a month would require the full year and the integer of the month requested - e.g. '1999-01'. This format would extend all the way down to seconds - e.g. '1999-01-01 08:35:23'. Leading zeros are not necessary. See the examples for more detail.
```{}
xts <- as.xts(hop.moy, descr ="Fréquentation des SU")
head(xts)

Un jour donné: xts["2014-01-01"]  
une plage: xts["2014-01-01/2014-01-03"] ou xts["2014-01-01::2014-01-03"]  
toutes les données: xts["/"]  
toutes les données depuis mars: xts['2014-03/']  
Toutes les données entre mars et juin: xts['2014-03/2014-06']  
toutes les données depuis mars jusqu'à la fin de l'année: xts['2014-03/2014'] 
toutes les données jusque 2014 inclu: xts['/2014'] 
```

#### Plotting

L'objet _xts_ ne peut dessiner que des séries temporelles univariées, en pratique une seule colonne à la fois. Si on passe toute la matrice à la fonction __plot__ seule la dernière colonne est prise en compte et un message d'avis est affiché (In plot.xts(xts) : only the univariate series will be plotted).

```{}
plot(xts[,'mean'], main="Fréquentation moyenne des SU", ylab="Nombre de passages")
```

On fabrique l'objet __cus__ de type xps, qui ne conserve que les colonnes _total_, _mean_ et _sd_:
```{}
cus <- xts[,c('total','mean','sd')]
head(cus)
           total     mean       sd
2014-01-01   972 64.80000 53.07165
2014-01-02  1055 70.33333 60.90234
2014-01-03  1038 69.20000 61.72543
2014-01-04   982 65.46667 56.31273
2014-01-05   918 61.20000 55.66250
2014-01-06  1000 66.66667 57.11350

La classe _xts_ hérite de la classe _zoo_. A ce titre, elle possède plusieurs fonctions mobiles:

moy.mobile <- rollmean(cus$total,7)
colnames(moy.mobile) <- "moy.mob"
sd.mobile <- rollapply(cus$total, 7, sd)
colnames(sd.mobile) <- "sd.mob"
cus <- cbind(cus, moy.mobile, sd.mobile)

plot(cus$total)
lines(moy.mobile, col="red", lty=2)
lines(moy.mobile+sd.mobile, col="red")
lines(moy.mobile-sd.mobile, col="red")
legend("topleft", legend=c("moyenne mobile","écart-type"), col=c("red","red"), lty=c(2,1))
```
On refait la même manip mais en ajoutant les hospitalisations = somme mutation + transferts:

```r
d <- read.table("data2.csv", header=TRUE, sep=",")
```

```
## Warning: impossible d'ouvrir le fichier 'data2.csv' : Aucun fichier ou
## dossier de ce type
```

```
## Error: impossible d'ouvrir la connexion
```

```r
hosp <- dx[dx$MODE_SORTIE == "Mutation" | dx$MODE_SORTIE == "Transfert", 6] # 6 est la colonne ENTREE
```

```
## Error: objet 'dx' introuvable
```

```r
b <- tapply(hosp, as.factor(yday(hosp)), length)
```

```
## Error: impossible de trouver la fonction "yday"
```

```r
t<-cbind(as.character(nn),a,b)
```

```
## Error: objet 'nn' introuvable
```

```r
colnames(t)<-c("date","passages","hospitalisations")
```

```
## Error: attempt to set 'colnames' on an object with less than two
## dimensions
```

```r
d <- rbind(d,t)
```

```
## Error: objet 'd' introuvable
```

```r
write.table(d, file="data2.csv", sep=",", row.names = FALSE, quote = FALSE)
```

```
## Error: objet 'd' introuvable
```
