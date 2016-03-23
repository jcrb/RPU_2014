# demande Schiber

load(d14)
# réorganiser les FINESS par territoires de santé
dx$FINESS <- factor(dx$FINESS, levels = c('Wis','Hag','Sav','Hus','Ane','Odi','Dts','Sel','Col','Geb','Mul', 'Alk','Dia','Ros','3Fr'))

#' calcule le tableau croisé caractère x age
#'@author
#'@description
#'@example
#'@family RPU
#'@param dx dataframe des RPU
#'@param age.max age égal ou supérieur à
#'@param comp sens de la comparaison ('egal','supegal',infegal','sup','inf')
#'@param col colonne de tri. Par défaut FINESS (territoire de santé, code postal,...)
age.finess <- function(dx, age_max = 75, comp = "egal", col = "FINESS"){
    # vecteur des 75 ans et plus
    if(comp == 'egal'){
        a75 <- dx[dx$AGE == age.max, col]}
    elseif(comp == 'supegal'){
        a75 <- dx[dx$AGE >= age.max, col]}
          
    # a75 <- dx[dx$AGE >= age.max, col]
    a75 <- table(factor(a75))
    
    # vecteur de l'ensemble des ages par FINESS
    tot <- table(factor(dx$FINESS))
    
    # table de synthèse
    # Table de synthèse et calcul du %
    synthese <- cbind(tot, a75, round(a75 * 100 / tot, 2))
    colnames(synthese) <- c("Total", "75+", "% 75+")
    return(synthese) # matrix de 3 colonnes
}


Temps de passages
===================

Calculer la moyenne et la médiane du temps de passage

passages <- dx[, c("ENTREE", "SORTIE", "FINESS", "AGE")] # dataframe entrées-sorties
passages <- passages[complete.cases(passages),] # on ne conserve que les couples complets
n.passages <- nrow(passages)
library(lubridate)
e <- ymd_hms(passages$ENTREE) # vecteur des entrées
s <- ymd_hms(passages$SORTIE)
d <- as.numeric((s-e)/60) # vecteur des durées de passage en minutes
# on ne garde que les durées > 0 et < ou = 48 heures
d <- d[d > 0 & d < 2 * 24 * 60 + 1]
passages$d <- as.numeric((s-e)/60)
mean.tot <- round(tapply(passages$d, passages$FINESS, mean), 0)
median.tot <- tapply(passages$d, passages$FINESS, median)

# pour les 75 ans
a75 <- passages[passages$AGE > 74, ]
mean.75 <- round(tapply(a75$d, a75$FINESS, mean), 0)
median.75 <- tapply(a75$d, a75$FINESS, median)
n.75 <- tapply(a75$d, a75$FINESS, length)

t <- rbind(mean.tot, mean.75, median.tot, median.75)
t

# moyenne régionale
mean(mean.tot)
mean(mean.75)

boxplot
-------
coul <- c(5,5,5,2,2,2,2,3,3,3,4,4,4,4,4)
boxplot(d ~ FINESS, data = passages, outline = FALSE, las = 2, col = coul, main = "Durée de passage (tous ages confondus)")
boxplot(d ~ FINESS, data = a75, outline = FALSE, las = 2, col = coul, main = "Durée de passage (75 ans et plus)")

boxplot(d ~ FINESS, data = a75, outline = FALSE, las = 2, col = coul, main = "", boxwex = 0.25, at = 1:15 - 0.2)
boxplot(d ~ FINESS, data = passages, outline = FALSE, las = 2, col = coul, main = "Durée de passage (Comparaisons tous ~ 75 ans)", add = TRUE, boxwex = 0.25, at = 1:15 + 0.2)

# correlation

plot(mean.75 ~ n.75, ylab = "Durée de passage (mn)", xlab = "Nombre de passages", main = "Relation durée de passage et nombre de passages\n (patients de 75 ans et plus)", col = coul, pch = 16)
# on refait le calcul sans les HUS
plot(mean.75[-4] ~ n.75[-4], ylab = "Durée de passage (mn)", xlab = "Nombre de passages", main = "Relation durée de passage et nombre de passages", col = coul, pch = 16)
m <- lm(mean.75[-4] ~ n.75[-4])
s <- summary(m)
s
s$r.squared
abline(m)
text(7000, 250, paste0("R2 = ", round(s$r.squared, 2)))
text(7000, 225, paste0("p  = ", round(anova(m)$'Pr(>F)'[1], 4)))

Remarques

- HUS les durée de passage ne sont fiables que deouis novembre 2014. La médiane n'est pas calculable
- calculer la corrélation durée de passage - nombre de passages
- corrélation nombre de passages et nombre de lits MCO
- La présence des SOS Mains n'a pas de sens dans la mesure où on s'intéresse uniquement
à la main alors que pour les SU polyvalents la prise en charge d'une personne agée est globale
donc très longue.

