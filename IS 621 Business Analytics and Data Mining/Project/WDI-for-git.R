library(WDI)
library(reshape2)
library(ggplot2)
library(ggthemes)
library(psychometric)
library(plm)
library(lme4)

wb <- WDI(country="all", indicator=c("DT.ODA.ODAT.PC.ZS","SH.TBS.INCD","SE.ADT.LITR.ZS",
                                     "SP.DYN.LE00.IN", "NY.GDP.PCAP.KD.ZG"),
          start=2005, end=2015, extra=TRUE)
wb <- filter(wb, income == 'Low income')

wbcastODA <- dcast(country ~ year, data=wb, value.var = 'DT.ODA.ODAT.PC.ZS')

wbcastODA <- wbcastODA[!is.na(wbcastODA[,'2005']),]

wbcastODA$country <- factor(wbcastODA$country)

countrylist <- levels(wbcastODA$country)

wbcastTUB <- dcast(country ~ year, data=wb, value.var='SH.TBS.INCD')

wb <- wb %>%
  filter(country %in% countrylist)

wbmodel <- wb %>%
  filter(year %in% 2005:2014) %>%
  dplyr::select(country, year, DT.ODA.ODAT.PC.ZS, SH.TBS.INCD, SE.ADT.LITR.ZS,
                SP.DYN.LE00.IN, NY.GDP.PCAP.KD.ZG)

colnames(wbmodel) <- c('Country', 'Year', 'AidPerCapita', 'IncidenceTuberculosis',
                       'AdultLiteracy', 'LifeExpectancy', 'GDPPerCap')

ggplot(wbmodel, aes(x=Year, y=GDPPerCap)) + geom_line() + 
  facet_wrap( ~ Country) + theme_tufte()

ggplot(wbmodel, aes(x=year, y=SH.TBS.INCD, group=country)) + geom_line() + 
  theme_tufte()

w <- lm(IncidenceTuberculosis ~ as.factor(Country), data=wbmodel)
summary(w)$r.squared

anova(w)

tmp <- aov(IncidenceTuberculosis ~ as.factor(Country), data=wbmodel)

summary(tmp)

ICC1(tmp)

## Fixed Effects

plm.wbmodel <- plm.data(wbmodel, index=c('Country', 'Year'))
m3 <- plm(IncidenceTuberculosis ~ AidPerCapita, data=plm.wbmodel, model='within')

summary(m3)

testlm <- lm(SH.TBS.INCD ~ DT.ODA.ODAT.PC.ZS, data=wbmodel)

## Random EFfects

r1 <- lmer(IncidenceTuberculosis ~ AidPerCapita + (1|Country), data=wbmodel)
r2 <- update(r1, REML=FALSE)

m4 <- plm(IncidenceTuberculosis ~ AidPerCapita, data=plm.wbmodel, model='random')

phtest(m3, m4)

summary(r1)
