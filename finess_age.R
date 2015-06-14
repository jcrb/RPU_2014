finess.age <- function(dx, age = -1){
  tapply(as.Date(d15.p$ENTREE[d15.p$AGE > age]), d15.p$FINESS[d15.p$AGE > age], length)
}