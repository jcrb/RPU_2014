RPU 2013 - Préparation des fichiers
========================================================

Ce document décrit la préparation des données RPU depuis la ptransmission du fichier brut jusqu'à la production d'un fichier directement exploitable par R.
Mise à jour:

```r
date()
```

```
## [1] "Wed Feb 12 12:20:05 2014"
```


Nomenclature
------------
- *raw* désigne les données brutes
- *tidy* désigne les données nettoyées
- la lettre *d* désigne les données. La lettre d peut être suivie de deux ou quatre chiffres désignant le mois. Par ex. *d01* désigne les données du mois de janvier et *d0506* les données des mois de mai et juin.
- la base de donnée mysql contenant les données du mois s'appelle *rpu* et la table contenant les RPU s'appelle *RPU__* (deux soulignés).
- les données nettoyées sont sauvegardées sous deux formats
  - rpu2013_05.txt (rpu+année_mois.txt)
  - rpu2013d06.Rda (rpu+année+d+mois.Rda)

#### Liste des fichiers
- le dossier **Fichiers source** contient les fichiers archivés de 2013
  - dossier *Text* contient la table *rpu__* du mois en format text
  - dossier *Dump* contient des dump originaux de la base de donnée (source e-santé)
  - les fichiers *.Rda* contiennent les tables *rpu__* du mois en format binaire
    - le fichier *rpu2013d1.rda* recense les mois 01 à 04 de 2013
    - les fichiers *rpu2013dmm.rda* recensent les mois *mm* de 2013 (de 05 à 12)
  - le **fichier courant** est *rpu2013d01mm.Rda* ou *mm* est le mois courant.
  
Origine des données
-------------------
Les données sont constituées par les RPU produits par les servives d'urgence. Les RPU sont transmis quotidiennement selon le schéma défini par l' INVS (version 2006) au serveur régional Sagec. Ces données sont gérées par Alsace e-santé (AeS) qui transmets les informations à l'INVS et à Résural. Pour Resural, AeS adresse tous les 5 du mois courant un dump de la table RPU__ du mois précédant, sous la forme d'un fichier .sql.  
Ce fichier .sql est accessible uniquement sur le réseau interne des HUS via un accès sécurisé au serveur HUS (**TODO** décrire la procédure).  
Le fichier est récupéré sur ce serveur par Résural.

Transfert des données brutes vers PhpMyAdmin
--------------------------------------------
Le fichier récupéré est ensuite importé dans une base de données MySql. La base est crée sur le poste *mint* via *PhpMyAdmin* sous le nom de *rpu*. Par défaut, le fichier récupéré est stocké dans le dossier racine de l'utilisateur, *Dossier personnel/Resural_mai_juin_2013*. Il contient les données pour les mois de:
- mai: rpu_2013_05_dump.sql (22.7 Mo)
- juin: rpu_2013_06_dump.sql (23.7 Mo)
Pour les transférer, on utilise la procédure standard en ligne de commande, commençant par le mois de mai:

cd ~/Documents/Resural/'Stat Resural'/'Fichiers source'/Dump/RPU2013_09

```{}
jcb@mint1:~$ mysql -u root -pmarion rpu < rpu_2014-01_dump.sql
```
Création d'un fichier .my.cfg
-----------------------------
Le fichier caché *.my.cfg* (Dossier personnel) contient les identifiants de connexion à la base de données nécéssaires pour R:
```{}
[rpu] 
user = root 
host = localhost 
database = rpu 
password = marion 
```
On peut lister son contenu: jcb@XPS:~$ cat $HOME/.my.cnf


Lecture du fichier dans RStudio
-------------------------------

### étape 1

Cette étape permet de récupérer les données à partir de la table *rpu__* de la base de données *rpu*. A l'issue, un fichier de travail *rpu2013_05.txt* esr créé. Si ce fichier a déjà été créé, passer directement à l'étape 4.

Chargement des library nécessaires:

```r
library("RMySQL")
```

```
## Loading required package: DBI
```

Création d'un connecteur:

```r
con <- dbConnect(MySQL(), group = "rpu")
# con <- dbConnect(MySQL(),user='root', password='marion',dbname='rpu',
# host='localhost')
```

Si échec:
con <- dbConnect(MySQL(),user="root", password="marion",dbname="rpu", host="localhost")  
ref: http://digitheadslabnotebook.blogspot.fr/2011/08/mysql-and-r.html


Liste des tables de la base *rpu*

```r
dbListTables(con)
```

```
## [1] "RPU__"
```

Liste des champs de la table *rpu__*

```r
dbListFields(con, "RPU__")
```

```
##  [1] "id"            "CODE_POSTAL"   "COMMUNE"       "DESTINATION"  
##  [5] "DP"            "ENTREE"        "EXTRACT"       "FINESS"       
##  [9] "GRAVITE"       "MODE_ENTREE"   "MODE_SORTIE"   "MOTIF"        
## [13] "NAISSANCE"     "ORIENTATION"   "PROVENANCE"    "RAW"          
## [17] "SEXE"          "SORTIE"        "TRANSPORT"     "TRANSPORT_PEC"
```

Lecture des enregistrements de la table compris entre le 1er mai et le 31 mai 2013 (cette étape peu être longue):

```r
ac <- 2014  # annee courante
mc <- 1  # mois courant

ac2 <- ac

ms <- mc + 1
if (ms > 12) {
    ms <- 1
    ac2 <- ac + 1
}

mp <- mc - 1
if (mp < 1) {
    mp <- 1
}
# conversion en chaines de caracteres
if (ms < 10) {
    ms <- paste("0", ms, sep = "")
} else ms <- as.character(ms)

if (mc < 10) {
    mc <- paste("0", mc, sep = "")
} else mc <- as.character(mc)

if (mp < 10) {
    mp <- paste("0", mp, sep = "")
} else mp <- as.character(mp)

ac <- as.character(ac)

date1 <- paste(ac, "-", mc, "-01", sep = "")
date2 <- paste(ac2, "-", ms, "-01", sep = "")

# rs<-dbSendQuery(con,'SELECT * FROM RPU__ WHERE ENTREE BETWEEN '2013-09-01'
# AND '2013-10-01' ')
rs <- dbSendQuery(con, paste("SELECT * FROM RPU__ WHERE ENTREE BETWEEN '", date1, 
    "' AND '", date2, "' ", sep = ""))

dx <- fetch(rs, n = -1, encoding = "UTF-8")
max(dx$ENTREE)
```

```
## [1] "2014-01-31 23:55:00"
```

```r
min(dx$ENTREE)
```

```
## [1] "2014-01-01 00:02:00"
```

Pour la mois de juin on répète les mêmes étapes:
- jcb@mint1:~$ mysql -u root -pmarion rpu < Resural_mai_juin_2013/rpu_2013_06_dump.sql
- rs<-dbSendQuery(con,"SELECT * FROM RPU__ WHERE ENTREE BETWEEN '2013-06-01' AND '2013-06-31' ")
- d06<-fetch(rs,n=-1,encoding = "UTF-8")
Les deux fichiers peuvent être combinés en un seul avec la commande *rbind*:
```{}
d0506<-rbind(d05,d06)
min(d0506$ENTREE)
[1] "2013-05-01 00:00:00"
max(d0506$ENTREE)
[1] "2013-06-30 23:53:00"
```

etape 2: nettoyage des données
------------------------------
Suppression de la colonne 16, intitulée RAW. Cette colonne a été rajoutée par mr Nold pour stocker le RPU tel que fournit par le SAU:

```r
dx <- dx[, -16]
```

On ramène le nombre de variable à 19.

création de FINESS unique pour un établissement par transformation du finess juridique en finess geographique

```r
a <- dx$FINESS
a[a == "670000397"] <- "Sel"
a[a == "680000684"] <- "Col"
a[a == "670016237"] <- "Odi"
a[a == "670000272"] <- "Wis"
a[a == "680000700"] <- "Geb"
a[a == "670780055"] <- "Hus"
a[a == "680000197"] <- "3Fr"
a[a == "680000627"] <- "Mul"
a[a == "670000157"] <- "Hag"
a[a == "680000320"] <- "Dia"
a[a == "680000395"] <- "Alk"
a[a == "670000165"] <- "Sav"
unique(a)
```

```
##  [1] "Sav" "Sel" "Dia" "Geb" "Mul" "Col" "Hus" "Odi" "3Fr" "Hag" "Wis"
## [12] "Alk"
```

```r
dx$FINESS <- as.factor(a)
rm(a)
```

Transformation en facteur:

```r
dx$CODE_POSTAL <- as.factor(dx$CODE_POSTAL)
dx$COMMUNE <- as.factor(dx$COMMUNE)
dx$SEXE <- as.factor(dx$SEXE)
dx$TRANSPORT <- as.factor(dx$TRANSPORT)
dx$TRANSPORT_PEC <- as.factor(dx$TRANSPORT_PEC)
dx$GRAVITE <- as.factor(dx$GRAVITE)
dx$ORIENTATION <- as.factor(dx$ORIENTATION)
dx$MODE_ENTREE <- factor(dx$MODE_ENTREE, levels = c(0, 6, 7, 8), labels = c("NA", 
    "Mutation", "Transfert", "Domicile"))
dx$PROVENANCE <- factor(dx$PROVENANCE, levels = c(0, 1, 2, 3, 4, 5, 8), labels = c("NA", 
    "MCO", "SSR", "SLD", "PSY", "PEA", "PEO"))
dx$MODE_SORTIE <- factor(dx$MODE_SORTIE, levels = c(0, 6, 7, 8, 4), labels = c("NA", 
    "Mutation", "Transfert", "Domicile", "Décès"))
dx$DESTINATION <- factor(dx$DESTINATION, levels = c(0, 1, 2, 3, 4, 6, 7), labels = c("NA", 
    "MCO", "SSR", "SLD", "PSY", "HAD", "HMS"))
```

Création d'une variable AGE:

```r
dx$AGE <- floor(as.numeric(as.Date(dx$ENTREE) - as.Date(dx$NAISSANCE))/365)
summary(dx$AGE)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##     0.0    16.0    37.0    39.9    63.0   105.0
```

Correction des ages supérieurs à 120 ans (3 cas) ou inférieur à 0 (2 cas)

```r
dx$AGE[dx$AGE > 120] <- NA
dx$AGE[dx$AGE < 0] <- NA
```

etape 3: sauvegarde des données nettoyées
-----------------------------------------

```r
# write.table(dx,'rpu2013_07.txt',sep=',',quote=TRUE,na='NA')
mois_courant_file <- paste("rpu", ac, "d", mc, ".Rda", sep = "")
save(dx, file = mois_courant_file)
```


etape 4: chargement des données sauvegardées
--------------------------------------------

```r
# load(mois_courant_file)
```

Résumé des tidy datas
---------------------

```r
str(dx)
```

```
## 'data.frame':	29237 obs. of  20 variables:
##  $ id           : chr  "ab87de0d-a76f-44d7-abaf-731bb2e37f28" "cedb2b35-9512-47e5-a882-271893fe2f22" "e2ab503f-f3ef-4359-9371-79cf22faf3f7" "6abfd47a-c3d8-4420-a3f4-c5c0a4616527" ...
##  $ CODE_POSTAL  : Factor w/ 569 levels "00000","00537",..: 254 255 295 245 336 284 284 262 115 284 ...
##  $ COMMUNE      : Factor w/ 1560 levels "01135 KIEV","04 618 ALMERIA",..: 283 1492 1199 601 1317 92 1236 1234 109 1236 ...
##  $ DESTINATION  : Factor w/ 7 levels "NA","MCO","SSR",..: NA NA NA NA NA NA NA NA NA NA ...
##  $ DP           : chr  NA NA NA "S610" ...
##  $ ENTREE       : chr  "2014-01-01 00:46:00" "2014-01-01 00:56:00" "2014-01-01 00:41:00" "2014-01-01 00:28:00" ...
##  $ EXTRACT      : chr  "2014-01-01 01:00:02" "2014-01-01 01:00:02" "2014-01-01 01:00:02" "2014-01-01 03:07:00" ...
##  $ FINESS       : Factor w/ 12 levels "3Fr","Alk","Col",..: 10 10 10 11 11 11 11 11 11 11 ...
##  $ GRAVITE      : Factor w/ 7 levels "1","2","3","4",..: NA NA NA 2 1 2 1 1 1 NA ...
##  $ MODE_ENTREE  : Factor w/ 4 levels "NA","Mutation",..: 4 4 4 4 4 4 4 4 4 4 ...
##  $ MODE_SORTIE  : Factor w/ 5 levels "NA","Mutation",..: NA NA NA 4 4 4 4 4 4 4 ...
##  $ MOTIF        : chr  NA "F100" "R030" "TRAUMATO10" ...
##  $ NAISSANCE    : chr  "1997-07-20 00:00:00" "1965-04-24 00:00:00" "1942-05-26 00:00:00" "1995-08-13 00:00:00" ...
##  $ ORIENTATION  : Factor w/ 13 levels "CHIR","FUGUE",..: NA NA NA NA NA NA NA NA NA NA ...
##  $ PROVENANCE   : Factor w/ 7 levels "NA","MCO","SSR",..: NA NA NA 6 6 6 6 6 6 6 ...
##  $ SEXE         : Factor w/ 2 levels "F","M": 2 2 2 2 1 2 2 2 2 2 ...
##  $ SORTIE       : chr  NA NA NA "2014-01-01 01:54:00" ...
##  $ TRANSPORT    : Factor w/ 6 levels "AMBU","FO","HELI",..: NA NA NA 4 1 4 4 4 4 6 ...
##  $ TRANSPORT_PEC: Factor w/ 3 levels "AUCUN","MED",..: NA NA NA 1 3 1 1 1 1 2 ...
##  $ AGE          : num  16 48 71 18 2 18 44 53 67 20 ...
```

```r
summary(dx)
```

```
##       id             CODE_POSTAL           COMMUNE       DESTINATION   
##  Length:29237       68000  : 1926   MULHOUSE   : 3419   MCO    : 6711  
##  Class :character   68200  : 1822   STRASBOURG : 2180   PSY    :  102  
##  Mode  :character   68100  : 1603   COLMAR     : 1926   SSR    :    7  
##                     67100  :  800   HAGUENAU   :  650   SLD    :    4  
##                     67000  :  749   SELESTAT   :  476   HAD    :    1  
##                     67500  :  742   SAINT LOUIS:  471   (Other):    1  
##                     (Other):21595   (Other)    :20115   NA's   :22411  
##       DP               ENTREE            EXTRACT              FINESS    
##  Length:29237       Length:29237       Length:29237       Col    :5384  
##  Class :character   Class :character   Class :character   Mul    :5162  
##  Mode  :character   Mode  :character   Mode  :character   Hus    :3383  
##                                                           Hag    :2943  
##                                                           Sav    :2505  
##                                                           Dia    :2463  
##                                                           (Other):7397  
##     GRAVITE         MODE_ENTREE       MODE_SORTIE       MOTIF          
##  2      :16362   NA       :    0   NA       :    0   Length:29237      
##  3      : 3585   Mutation :  231   Mutation : 6406   Class :character  
##  1      : 3528   Transfert:  298   Transfert:  427   Mode  :character  
##  4      :  309   Domicile :26760   Domicile :18310                     
##  P      :  121   NA's     : 1948   Décès    :    0                     
##  (Other):   97                     NA's     : 4094                     
##  NA's   : 5235                                                         
##   NAISSANCE          ORIENTATION      PROVENANCE    SEXE     
##  Length:29237       UHCD   : 2890   PEA    :14306   F:14272  
##  Class :character   MED    : 1833   PEO    : 2453   M:14965  
##  Mode  :character   CHIR   :  720   MCO    :  696            
##                     PSA    :  256   PSY    :    5            
##                     SI     :  143   SSR    :    3            
##                     (Other):  423   (Other):    1            
##                     NA's   :22972   NA's   :11773            
##     SORTIE          TRANSPORT     TRANSPORT_PEC        AGE       
##  Length:29237       AMBU : 3714   AUCUN  :19796   Min.   :  0.0  
##  Class :character   FO   :  139   MED    :  514   1st Qu.: 16.0  
##  Mode  :character   HELI :   14   PARAMED:  644   Median : 37.0  
##                     PERSO:15319   NA's   : 8283   Mean   : 39.9  
##                     SMUR :  207                   3rd Qu.: 63.0  
##                     VSAB : 2228                   Max.   :105.0  
##                     NA's : 7616
```

Fusion avec la base annuelle
-----------------------------
*d0110* est la base annuelle provisoire
base_annuelle_courante = rpuAAAAd01MM.Rda où AAAA est l'année courante et MM le mois précédant le mois courant. Ex. si on saisit le mois d'octobre 2013, la base courante est celle qui va du 1er janvier au 30 septembre 2013 => AAAA = 2013 et MM = 09.

Les données de la base annuelle courante sont stockées dans la variable **d1**; (avant octobre 2013 les données sont stockées sous le nom de variable d01xx où xx coresspod au mois courant.)

les données du mois courant sont stockées et restituées dans la variable **dx**


```r
base_annuelle_courante <- paste("d01", mp, sep = "")
bac <- paste("rpu", ac, base_annuelle_courante, ".Rda", sep = "")
load(bac)
```

```
## Warning: impossible d'ouvrir le fichier compressé 'rpu2014d0101.Rda',
## cause probable : 'Aucun fichier ou dossier de ce type'
```

```
## Error: impossible d'ouvrir la connexion
```

```r

# new_data <- rbind(d0109,dx)
new_data <- rbind(d1, dx)
```

```
## Error: objet 'd1' introuvable
```

```r
d1 <- new_data
```

```
## Error: objet 'new_data' introuvable
```

```r


nb_name <- paste("rpu", ac, "d01", mc, ".Rda", sep = "")
save(d1, file = nb_name)
```

```
## Error: objet 'd1' introuvable
```


SUITE: voir RPU_2013_Preparation.Rmd

Vérification de la complétude des données
=========================================

**METTRE EN COPIE MR NOLD ET MME BROUSTAL**

Nombre de passages
------------------
Tableau croisé des Finess et du nombre de passages quotidiens:

```r
d <- table(as.Date(dx$ENTREE), dx$FINESS)
head(d)
```

```
##             
##              3Fr Alk Col Dia Geb Hag Hus Mul Odi Sav Sel Wis
##   2014-01-01  46   0 177  76  44  99  90 130  73  97 101  39
##   2014-01-02  34  31 181  77  33 101 134 189  71  83  84  37
##   2014-01-03  36  38 199  82  34  86 117 187  61  93  75  30
##   2014-01-04  38  17 169  92  31  89  95 177  71  84  87  32
##   2014-01-05  42   1 164  75  38  85  79 183  76  64  76  35
##   2014-01-06  40  11 160  90  51  87 128 179  77  78  76  23
```

```r
plot(t(d))
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13.png) 

```r

d2 <- addmargins(d, c(2, 2), FUN = list(Somme = sum, Moyenne = mean))
```

```
## Margins computed over dimensions
## in the following order:
## 1: 
## 2:
```

```r
write.table(d2, file = "data.csv", sep = ",", row.names = TRUE, quote = FALSE)
```

           3Fr Alk Col Dia Geb Hag Hus Mul Odi Sel Wis
  2013-05-01  49   8 155  70  40 102 103 132  73  85  29
  2013-05-02  43  41 180  85  52 104 120 123  72  89  32
  2013-05-03  36  29 176  64  43  85 116 141  71  82  27
  2013-05-04  47  11 184  92  42 104  87 151  74  93  34
  2013-05-05  52  10 190  89  50  91 102 185  93  99  31
  2013-05-06  50  46 209  97  40  99 138 174  73  98  36
  
Lignes où le nombre de données est inférieur à 20:

```r
df <- data.frame(d)
a <- df[df$Freq < 20, ]
```

Dernier fichier sauvegardé
==========================
octobre 2013:  
----------
write.table(d06,"rpu2013_06.txt",sep=',',quote=TRUE,na="NA")
save(d06,file="rpu2013d06.Rda")

RPU du 1er janvier 2013 au 30 juin 2013:
----------------------------------------
d0106<-rbind(d1,d05,d06)
save(d0106,file="rpu2013d0106.Rda")
rm(d0106)

Résumé de la mise à jour
========================



