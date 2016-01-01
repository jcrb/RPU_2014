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
  <tr> <td> WISSEMBOURG </td> <td align="right"> 12 905 </td> </tr>
  <tr> <td> SELESTAT </td> <td align="right"> 29 107 </td> </tr>
  <tr> <td> HAGUENAU </td> <td align="right"> 45 048 </td> </tr>
  <tr> <td> SAVERNE </td> <td align="right"> 28 920 </td> </tr>
  <tr> <td> SCHIRMECK </td> <td align="right">  </td> </tr>
  <tr> <td> STRASBOURG </td> <td align="right"> 163 079 </td> </tr>
  <tr> <td> SAINT-LOUIS </td> <td align="right"> 16 875 </td> </tr>
  <tr> <td> THANN </td> <td align="right">  </td> </tr>
  <tr> <td> ALTKIRCH </td> <td align="right"> 16 470 </td> </tr>
  <tr> <td> COLMAR </td> <td align="right"> 66 456 </td> </tr>
  <tr> <td> MULHOUSE </td> <td align="right"> 97 638 </td> </tr>
  <tr> <td> GUEBWILLER </td> <td align="right"> 15 566 </td> </tr>
   </table>

