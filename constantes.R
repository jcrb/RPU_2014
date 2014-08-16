# constantes

mois_f <- c("Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre")
mois_c <- c("Jan","Fév","Mar","Avr","Mai","Jui","Jul","Aou","Sep","Oct","Nov","Déc")
trimestre_f <- c("trim.1","trim.2","trim.3","trim.4")
semaine_f <- c("Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi","Dimanche")

# entrées par secteur sanitaire (voir Territoire_Sante.Rmd)
# -----------------------------
#   On creé une colonne supplémentaire *secteur* qui indique à quel secteur sanitaire correspond le RPU:
#   ```{r secteur_rpu,echo=FALSE}
# d1$secteur[d1$FINESS %in% c("Wis","Hag","Sav")]<-1
# d1$secteur[d1$FINESS %in% c("Hus","Odi")]<-2
# d1$secteur[d1$FINESS %in% c("Sel","Col","Geb")]<-3
# d1$secteur[d1$FINESS %in% c("Mul","Alk","3Fr","Dia")]<-4

