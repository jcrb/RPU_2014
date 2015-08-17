# Recommandations RPU
jcb  
14 août 2015  


```
## Loading required package: zoo
## 
## Attaching package: 'zoo'
## 
## The following objects are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
```


Jours manquants
===============

On appelle _jours manquants_, les jours où le nombre de RPU est inférieur à un seuil _S_. En supposant que la distribution des RPU est normale, le seuil peut être fixé à 2 ou 3 écart-type (sd) en dessous de la moyenne du nombre de RPU quotidien.

Par exemple pour le CH Sélestat on obtient:

- $\mu = 79.22$
- $\sigma = 31.4549267$

et graphiquement (moyenne en trait plein, écart-type en pointillés):

![](recoRPU_files/figure-html/graph_sel1-1.png) 

Cependant ces résultats sont faussés par les jours manquants qui "tirent" vers le bas la moyenne et augmentent l'écart-type. On refait le même calcul mais en supprimant les jours où le nombre de RPU est inférieur à la moyenne moins 2 sd:



- $\mu = 90.02$
- $\sigma = 13.0710975$

![](recoRPU_files/figure-html/sel2_graphe-1.png) 

A partir des données corrigées on peut fixer le seuil à partir ququel le nombre de RPU peut être considéré comme suspect à :

$S = \mu - 3\sigma$

$S = 51$




soit: 26 jours.

Tableau des seuils par établissement
------------------------------------

La routine _seuil_ établit la liste des seuils par établissement (la routine modifie légèrement l'algoritme précédent pour étiter des seuils négatifs lorsque les effectifs sont faibles ou les valeurs manquantes trop nombreuses):

Un nombre quotidien de RPU inférieur à ce seuil est considéré comme anormal jusqu'à preuve du contraire:

```
[1] "Wis = 15"
[1] "Hag = 84"
[1] "Sav = 51"
[1] "Hus = 228"
[1] "HTP = 151"
[1] "NHC = 51"
[1] "Odi = 41"
[1] "Ane = 18"
[1] "Dts = 10"
[1] "Sel = 51"
[1] "Col = 128"
[1] "Geb = 19"
[1] "Mul = 112"
[1] "3Fr = 26"
[1] "Dia = 54"
[1] "Ros = 7"
```



![](recoRPU_files/figure-html/liste_graphique-1.png) ![](recoRPU_files/figure-html/liste_graphique-2.png) ![](recoRPU_files/figure-html/liste_graphique-3.png) ![](recoRPU_files/figure-html/liste_graphique-4.png) ![](recoRPU_files/figure-html/liste_graphique-5.png) ![](recoRPU_files/figure-html/liste_graphique-6.png) ![](recoRPU_files/figure-html/liste_graphique-7.png) ![](recoRPU_files/figure-html/liste_graphique-8.png) ![](recoRPU_files/figure-html/liste_graphique-9.png) ![](recoRPU_files/figure-html/liste_graphique-10.png) ![](recoRPU_files/figure-html/liste_graphique-11.png) ![](recoRPU_files/figure-html/liste_graphique-12.png) ![](recoRPU_files/figure-html/liste_graphique-13.png) ![](recoRPU_files/figure-html/liste_graphique-14.png) ![](recoRPU_files/figure-html/liste_graphique-15.png) ![](recoRPU_files/figure-html/liste_graphique-16.png) 

Variabilité du codage
=====================

On forme le rapport quotidien du nombre de RPU codés sur le nombre total de RPU transmis.

Variabilité acceptable: différence interquartile ?

![](recoRPU_files/figure-html/code-1.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.2692  0.8404  0.9060  0.8777  0.9565  1.0000 
```

![](recoRPU_files/figure-html/code-2.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.4581  0.7351  0.7782  0.7737  0.8242  0.9096 
```

![](recoRPU_files/figure-html/code-3.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
0.00000 0.05407 0.13480 0.16870 0.28350 0.54550 
```

![](recoRPU_files/figure-html/code-4.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.3233  0.4876  0.5351  0.5340  0.5825  0.7211 
```

![](recoRPU_files/figure-html/code-5.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.4515  0.5743  0.6295  0.6221  0.6736  0.7706 
```

![](recoRPU_files/figure-html/code-6.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.2368  0.3905  0.4390  0.4494  0.5000  0.8471 
```

![](recoRPU_files/figure-html/code-7.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.0000  0.2817  0.4571  0.4564  0.6513  1.0000 
```

![](recoRPU_files/figure-html/code-8.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
      0       0       0       0       0       0 
```

![](recoRPU_files/figure-html/code-9.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.0000  0.7391  0.8571  0.8102  0.9310  1.0000 
```

![](recoRPU_files/figure-html/code-10.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.0000  0.9145  0.9481  0.8983  0.9684  1.0000 
```

![](recoRPU_files/figure-html/code-11.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.7659  0.8590  0.8777  0.8758  0.8972  0.9683 
```

![](recoRPU_files/figure-html/code-12.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.7708  0.9838  1.0000  0.9895  1.0000  1.0000 
```

![](recoRPU_files/figure-html/code-13.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.6481  0.7417  0.7793  0.7840  0.8177  0.9677 
```

![](recoRPU_files/figure-html/code-14.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
0.08333 0.47990 0.58820 0.58710 0.66830 1.00000 
```

![](recoRPU_files/figure-html/code-15.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.0000  0.2608  0.4452  0.4074  0.5565  0.8649 
```

![](recoRPU_files/figure-html/code-16.png) 

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
0.00000 0.01923 0.06155 0.07006 0.11110 0.33330 
```

