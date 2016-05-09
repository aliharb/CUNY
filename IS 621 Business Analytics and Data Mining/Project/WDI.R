library(WDI)
library(reshape2)


data <- WDI(country = "ZW", indicator = "NY.GNS.ICTR.GN.ZS",
    start = 2005, end = 2011, extra = FALSE, cache = NULL)
datalist <- WDIcache()

frame <- WDIsearch(string = "ODA", field = "name", short = TRUE, cache = NULL)
frame <- WDIsearch(string = "Enrol", field = "name", short = TRUE, cache = NULL)
frame <- WDIsearch(string = "tuberculosis", field = "name", short = TRUE, cache = NULL)
frame <- WDIsearch(string = "literacy", field = "name", short = TRUE, cache = NULL)
frame <- WDIsearch(string = "Mortality", field = "name", short = TRUE, cache = NULL)
frame <- WDIsearch(string = "GDP", field = "name", short = TRUE, cache = NULL)

wb <- WDI(country="all", indicator=c("SE.XPD.TOTL.GB.ZS", "GC.DOD.TOTL.GD.ZS",
                                     "BN.CAB.XOKA.GD.ZS", "SP.POP.DPND", "AG.LND.TOTL.K2",
                                     "NY.GDP.MKTP.CD", "NY.GDP.MKTP.PP.CD",
                                     "NY.GDP.MKTP.KD", "NY.GDP.PCAP.CD", "SP.POP.TOTL",
                                     "IT.PRT.NEWS.P3", "IT.RAD.SETS", "NE.IMP.GNFS.ZS",
                                     "NE.EXP.GNFS.ZS", "NE.TRD.GNFS.ZS",
                                     "BX.KLT.DINV.WD.GD.ZS", "BN.KLT.PRVT.GD.ZS",
                                     "NE.CON.GOVT.ZS", "SL.IND.EMPL.ZS", "NV.IND.TOTL.ZS",
                                     "NY.GDP.MKTP.KD.ZG", "NY.GDP.PCAP.KD"),
          start=1960,
          end=2012,
          extra=TRUE)

wb <- WDI(country="all", indicator=c("SE.PRE.NENR","DT.ODA.ALLD.PC.ZS", "DT.ODA.ODAT.PC.ZS",
                                     "SH.TBS.INCD", "SE.ADT.LITR.ZS", "SP.DYN.LE00.IN"),
          start=2005, end=2015, extra=TRUE)

wb <- filter(wb, income == 'Low income') %>%
  filter(!is.na(income)) #%>%
  #filter(!(country %in% c('Somalia', 'Mozambique', 'Liberia', 'Afghanistan')))

wbcastMORT <- dcast(country ~ year, data=wb, value.var='SP.DYN.LE00.IN')

wbcastTUB <- dcast(country ~ year, data=wb, value.var='SH.TBS.INCD')

wbcastLIT <- dcast(country ~ year, data=wb, value.var='SE.ADT.LITR.ZS')

wbcastODA <- dcast(country ~ year, data=wb, value.var = 'DT.ODA.ODAT.PC.ZS')

wbcastODA <- wbcastODA[!is.na(wbcastODA[,'2005']),]

wbcastODA$country <- factor(wbcastODA$country)

countrylist <- levels(wbcastODA$country)

countrylist <- countrylist[!(countrylist %in% c('Somalia', 'Mozambique', 'Liberia',
                                                'Afghanistan'))]

wb <- wb %>%
  filter(country %in% countrylist)

wbmodel <- wb %>%
  filter(year %in% 2005:2014) %>%
  dplyr::select(country, year, DT.ODA.ODAT.PC.ZS, SH.TBS.INCD)

wbcastENROL <- dcast(country ~ year, data=wb, value.var='SE.PRE.NENR') %>%
  filter(country %in% countrylist)

for(i in 2:12){
  wbcastENROL[,i] <- ifelse(is.na(wbcastENROL[,i]),0,1)
}
wbcastENROLTF <- wbcastENROL


##################

library(faraway)
library(dplyr)
library(ggplot2)
library(lme4)

psid <- psid

xyplot(income ~ year | person, psid, type="1", subset=(person < 21),strip=FALSE)

psid1 <- filter(psid, person < 21)

ggplot(psid1, aes(x=year, y=income)) + geom_line() + facet_wrap(~ person, scales = 'free')

ggplot(psid, aes(x=year, y=log(income+100), group = person)) + 
  facet_wrap(~ sex, scales = 'free') + geom_line()

slopes <- numeric(85);intercepts <- numeric(85)

i <- 1

for(i in 1:85){
  lmod <- lm(log(income) ~ I(year-78),subset=(person==i), psid)
  intercepts[i] <- coef(lmod)[1]
  slopes[i] <- coef(lmod)[2]
}

slopes

ggplot(data.frame(slopes=slopes, intercepts = intercepts), 
       aes(x=intercepts, y=slopes)) + geom_point()

psid$cyear <- psid$year-78
mmod <- lmer(log(income) ~ cyear*sex+age+educ+(cyear|person),psid)
summary(mmod)

#################

pulp <- pulp
lmod <- aov(bright ~ operator, pulp)
summary(lmod)

# Anova verification

mu <- 20
a1 <- 5
a2 <- -3
a3 <- 1

sample(1:10, 12, replace=TRUE)

########################

library(pscl)

presidentialElections <- presidentialElections

library(foreign)

fatality <- read.dta(file="fatality.dta")
