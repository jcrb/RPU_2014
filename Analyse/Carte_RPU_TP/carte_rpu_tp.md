# Cate des RPU produits par territoire de santé
JcB  
03/11/2015  
Objectif: dessiner une carte de l'Alsace avec une représentation du nombre de RPU produits par chacun des douze territoires de proximié. Les RPU sont représentés par des cercles dont la superficie est proportionnelle au nombre de RPU.

Source: R et espace pp 189

Réalisation: il faut disposer:

- d'un fond cartographique de l'Alsace: ctss
- de la position des 12 villes correspondant au 12 territoires de proximité: ts
- d'une liste du nombre de RPU par territoire de proximité




![](carte_rpu_tp_files/figure-html/carte-1.png) 

La surface des cercles est proportionnelle au nombre de RPU. Il manque des informations sur deux territoires: Schirmeck et Thann. En 2014, le nombre de RPU de la zone Strasbourg est fortement sous estimé.

<table border=1>
<caption align="bottom"> RPU produits en 2015 par zone de proximité </caption>
<tr> <th> NOM </th> <th> rpu </th>  </tr>
  <tr> <td> WISSEMBOURG </td> <td align="right"> 11 375 </td> </tr>
  <tr> <td> SELESTAT </td> <td align="right"> 25 067 </td> </tr>
  <tr> <td> HAGUENAU </td> <td align="right"> 39 194 </td> </tr>
  <tr> <td> SAVERNE </td> <td align="right"> 25 090 </td> </tr>
  <tr> <td> SCHIRMECK </td> <td align="right">  </td> </tr>
  <tr> <td> STRASBOURG </td> <td align="right"> 140 952 </td> </tr>
  <tr> <td> SAINT-LOUIS </td> <td align="right"> 14 764 </td> </tr>
  <tr> <td> THANN </td> <td align="right">  </td> </tr>
  <tr> <td> ALTKIRCH </td> <td align="right"> 14 469 </td> </tr>
  <tr> <td> COLMAR </td> <td align="right"> 57 491 </td> </tr>
  <tr> <td> MULHOUSE </td> <td align="right"> 84 229 </td> </tr>
  <tr> <td> GUEBWILLER </td> <td align="right"> 13 631 </td> </tr>
   </table>

