if (require("mstate")) { 

data("ebmt4")
ebmt <- ebmt4
head(ebmt)
ebmt$match <- factor(ebmt$match, levels=c("no gender mismatch", "gender mismatch"))
ebmt$proph <- factor(ebmt$proph, levels=c("no", "yes"))
ebmt$agecl <-factor(ebmt$agecl, levels=c("<=20","20-40",">40"))
tmat <- transMat(x = list( c(2, 3, 5, 6), c(4, 5, 6), c(4, 5, 6), c(5,6),c(), c()),
               names = c("Tx","Rec","AE","Rec+AE","Rel","Death"))
msebmt <- msprep(data=ebmt,trans=tmat, time=c(NA,"rec","ae","recae","rel","srv"),
            status=c(NA,"rec.s","ae.s","recae.s","rel.s","srv.s"),
            keep=c("match","proph","year","agecl"))
msebmt[msebmt$id==1, c(1:8, 10:12)]
events(msebmt)
covs <- c("match","proph","year","agecl")
msebmt <- expand.covs(msebmt, covs, longnames=FALSE)
msebmt[msebmt$id==1,-c(9,10,12:48,61:84)]
msebmt[, c("Tstart", "Tstop", "time")] <- msebmt[, c("Tstart", "Tstop", "time")]/365.25
c0 <- coxph(Surv(Tstart,Tstop,status)~strata(trans), data=msebmt, method="breslow")
msf0 <- msfit(object=c0, vartype="greenwood", trans=tmat)
str(msf0)
# msf0$Haz contains cumulative hazard at each time for each transition
# 6204 obs = 12 trans * 517 times
# msf0$varHaz:  40326 obs = 517 times * (1+2+...+12)= 517*(0.5*12*13)
# one block of 517 for each r,s transition: r>=s from 1 to 12.
v <- msf0$varHaz
table(v$trans1,v$trans2)


### Exponential works ok.  fine as a test case then
### but 35 sec to fit, these are too slow for test cases
msebmt$trans <- factor(msebmt$trans)
e0 <- flexsurvreg(Surv(Tstart,Tstop,status)~trans, data=msebmt, dist="exp")
e1 <- flexsurvreg(Surv(Tstart,Tstop,status)~trans + factor(match) + factor(agecl), data=msebmt, dist="exp")

msfit.flexsurvreg(e0, t=c(1,10,50,100), tvar="trans", trans=tmat)

}
