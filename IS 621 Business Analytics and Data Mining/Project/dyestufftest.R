library(lme4)


Dyestuff <- Dyestuff

fm1 <- lmer(Yield ~ 1 + (1 | Batch), Dyestuff)
summary(fm1)
fm1ML <- lmer(Yield ~ 1 + (1|Batch), Dyestuff, REML = FALSE)


ranef(fm1)
