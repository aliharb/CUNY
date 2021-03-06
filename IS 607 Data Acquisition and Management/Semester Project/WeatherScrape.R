library(rvest)
library(dplyr)
library(plyr)
library(zoo)


monthlookup <- data.frame(
  monthnum = 1:12,
  numdays = c(31,28,31,30,31,30,31,31,30,31,30,31))


df <- data.frame(year = numeric(0),
                 month = numeric(0),
                 day = numeric(0),
                 hour = numeric(0),
                 minute = numeric(0),
                 temp = numeric(0),
                 windchill = numeric(0),
                 heatindex = numeric(0),
                 dewpoint = numeric(0),
                 humidity = numeric(0),
                 pressure = numeric(0),
                 visibility = numeric(0),
                 winddir = character(0),
                 windspeed = numeric(0),
                 gustspeed = numeric(0),
                 precip = numeric(0),
                 events = character(0),
                 conditions = character(0), 
                 stringsAsFactors = FALSE)


for(monthindex in 7:12){


for(date in 1:filter(monthlookup, monthnum == monthindex)$numdays){
  
  weatherpage <- html(paste("http://www.wunderground.com/history/airport/KNYC/2013/",monthindex,"/",date,
                       "/DailyHistory.html", sep = ""))
  
  #####
  # The columns change. The third column could either be Windchill, Heat Index
  # Or Dew Point (which should be the fourth column)
  #####
  
  weathertest <- weatherpage %>%
    html_nodes("#obsTable > thead > tr > th:nth-child(3)") %>%
    html_text()

  time <- weatherpage %>%
    html_nodes("#obsTable > tbody > tr > td:nth-child(1)") %>%
    html_text()
  time <- paste(monthindex,"/",date,"/2013 ", time, sep="")
  time <- strptime(time, format="%m/%d/%Y %I:%M %p")
  
  year <- time$year+1900
  month <- time$mon+1
  day <- time$mday
  hour <- time$hour
  minute <- time$min

  temp <- weatherpage %>%
    html_nodes("#obsTable > tbody > tr > td:nth-child(2) > span > span.wx-value") %>%
    html_text() %>%
    as.numeric()
  
  if(weathertest == "Windchill"){
    
      windchill <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(3)") %>%
        html_text()
      windchill[windchill == "\n  -\n"] <- NA
      windchill[!is.na(windchill)] <- substr(windchill[!is.na(windchill)], 4, 
                                             nchar(windchill[!is.na(windchill)])-4)
      windchill <- as.numeric(windchill)
      
      heatindex <- rep(NA, each=length(temp))
      
      print("Windchill")
      
  }
  
  if(weathertest == "Heat Index"){
      
      windchill <- rep(NA, each=length(temp))
      
      heatindex <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(3)") %>%
        html_text()
      heatindex[heatindex == "\n  -\n"] <- NA
      heatindex[!is.na(heatindex)] <- substr(heatindex[!is.na(heatindex)], 4, 
                                             nchar(heatindex[!is.na(heatindex)])-4)
      heatindex <- as.numeric(heatindex)
      
      print("heatindex")
  }
  
  if(weathertest == "Dew Point"){
    
      windchill <- rep(NA, each=length(temp))
    
      heatindex <- rep(NA, each=length(temp))
      
      print("dew point")
  }

  
  if(weathertest == "Windchill" | weathertest == "Heat Index"){
  
      dewpoint <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(4) > span > span.wx-value") %>%
        html_text() %>%
        as.numeric()

      humidity <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(5)") %>%
        html_text()
      humidity <- as.numeric(substr(humidity, 1, 2))
      
      

      #pressure <- weatherpage %>%
      #  html_nodes("#obsTable > tbody > tr > td:nth-child(6) > span > span.wx-value") %>%
      #  html_text() %>%
      #  as.numeric()
      
      pressure <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(6)") %>%
        html_text()
      pressure[pressure == "\n  -\n"] <- NA
      pressure[!is.na(pressure)] <- substr(pressure[!is.na(pressure)],4,
                                               nchar(pressure[!is.na(pressure)])-4)
      pressure <- as.numeric(pressure)

      visibility <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(7)") %>%
        html_text()
      visibility[visibility == "\n  -\n"] <- NA
      visibility[!is.na(visibility)] <- substr(visibility[!is.na(visibility)],4,
                                               nchar(visibility[!is.na(visibility)])-4)
      visibility <- as.numeric(visibility)

      winddir <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(8)") %>%
        html_text()

      windspeed <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(9)") %>%
        html_text()
      windspeed[windspeed == "\n  -\n"] <- NA
      windspeed[windspeed == "Calm"] <- NA
      windspeed[!is.na(windspeed)] <- substr(windspeed[!is.na(windspeed)], 4, 
               nchar(windspeed[!is.na(windspeed)])-5)
      windspeed <- as.numeric(windspeed)
      
      #heatindex <- rep(NA, each=length(windspeed))

      gustspeed <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(10)") %>%
        html_text()
      gustspeed[gustspeed == "\n  -\n"] <- NA
      gustspeed[!is.na(gustspeed)] <- as.numeric(substr(gustspeed[!is.na(gustspeed)],4,7))

      precip <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(11)") %>%
        html_text()
      precip[precip == "N/A"] <- NA
      precip[!is.na(precip)] <- as.numeric(substr(precip[!is.na(precip)],4,7))

      eventTestPage <- html("http://www.wunderground.com/history/airport/KNYC/2014/12/3/DailyHistory.html")
      eventTest <- eventTestPage %>%
        html_nodes("#obsTable > tbody > tr:nth-child(1) > td:nth-child(12)") %>%
        html_text()

      events <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(12)") %>%
        html_text()
      events[events == eventTest] <- NA
      events[!is.na(events)] <- substr(events[!is.na(events)], 2, nchar(events[!is.na(events)])-1)

      conditions <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(13)") %>%
        html_text()
  
  }
  
  if(weathertest == "Dew Point"){
    
    dewpoint <- weatherpage %>%
      html_nodes("#obsTable > tbody > tr > td:nth-child(3) > span > span.wx-value") %>%
      html_text() %>%
      as.numeric()
    
    humidity <- weatherpage %>%
      html_nodes("#obsTable > tbody > tr > td:nth-child(4)") %>%
      html_text()
    humidity <- as.numeric(substr(humidity, 1, 2))
    
    pressure <- weatherpage %>%
      html_nodes("#obsTable > tbody > tr > td:nth-child(5)") %>%
      html_text()
    pressure[pressure == "\n  -\n"] <- NA
    pressure[!is.na(pressure)] <- substr(pressure[!is.na(pressure)],4,
                                             nchar(pressure[!is.na(pressure)])-4)
    pressure <- as.numeric(pressure)
    
    visibility <- weatherpage %>%
      html_nodes("#obsTable > tbody > tr > td:nth-child(6)") %>%
      html_text()
    visibility[visibility == "\n  -\n"] <- NA
    visibility[!is.na(visibility)] <- substr(visibility[!is.na(visibility)],4,
                                             nchar(visibility[!is.na(visibility)])-4)
    visibility <- as.numeric(visibility)
    
    winddir <- weatherpage %>%
      html_nodes("#obsTable > tbody > tr > td:nth-child(7)") %>%
      html_text()
    
    windspeed <- weatherpage %>%
      html_nodes("#obsTable > tbody > tr > td:nth-child(8)") %>%
      html_text()
    windspeed[windspeed == "\n  -\n"] <- NA
    windspeed[windspeed == "Calm"] <- NA
    windspeed[!is.na(windspeed)] <- substr(windspeed[!is.na(windspeed)], 4, 
                                           nchar(windspeed[!is.na(windspeed)])-5)
    windspeed <- as.numeric(windspeed)
    
    heatindex <- rep(NA, each=length(windspeed))
    
    gustspeed <- weatherpage %>%
      html_nodes("#obsTable > tbody > tr > td:nth-child(9)") %>%
      html_text()
    gustspeed[gustspeed == "\n  -\n"] <- NA
    gustspeed[!is.na(gustspeed)] <- as.numeric(substr(gustspeed[!is.na(gustspeed)],4,7))
    
    precip <- weatherpage %>%
      html_nodes("#obsTable > tbody > tr > td:nth-child(10)") %>%
      html_text()
    precip[precip == "N/A"] <- NA
    precip[!is.na(precip)] <- as.numeric(substr(precip[!is.na(precip)],4,7))
    
    eventTestPage <- html("http://www.wunderground.com/history/airport/KNYC/2014/12/3/DailyHistory.html")
    eventTest <- eventTestPage %>%
      html_nodes("#obsTable > tbody > tr:nth-child(1) > td:nth-child(12)") %>%
      html_text()
    
    events <- weatherpage %>%
      html_nodes("#obsTable > tbody > tr > td:nth-child(11)") %>%
      html_text()
    events[events == eventTest] <- NA
    events[!is.na(events)] <- substr(events[!is.na(events)], 2, nchar(events[!is.na(events)])-1)
    
    conditions <- weatherpage %>%
      html_nodes("#obsTable > tbody > tr > td:nth-child(12)") %>%
      html_text()
    
  }
  
  dfadd <- data.frame(cbind(
    year, month, day, hour, minute, temp, windchill, heatindex, dewpoint, 
    humidity,pressure, visibility, winddir, windspeed, gustspeed, precip, 
    events, conditions), stringsAsFactors = FALSE)
  
  df <- rbind( df,dfadd)
  
  rm(dfadd)
 

}



}

for(monthindex in 1:8){
  
  
  for(date in 1:filter(monthlookup, monthnum == monthindex)$numdays){
    
    weatherpage <- html(paste("http://www.wunderground.com/history/airport/KNYC/2014/",monthindex,"/",date,
                              "/DailyHistory.html", sep = ""))
    
    #####
    # The columns change. The third column could either be Windchill, Heat Index
    # Or Dew Point (which should be the fourth column)
    #####
    
    weathertest <- weatherpage %>%
      html_nodes("#obsTable > thead > tr > th:nth-child(3)") %>%
      html_text()
    
    time <- weatherpage %>%
      html_nodes("#obsTable > tbody > tr > td:nth-child(1)") %>%
      html_text()
    time <- paste(monthindex,"/",date,"/2014 ", time, sep="")
    time <- strptime(time, format="%m/%d/%Y %I:%M %p")
    
    year <- time$year+1900
    month <- time$mon+1
    day <- time$mday
    hour <- time$hour
    minute <- time$min
    
    temp <- weatherpage %>%
      html_nodes("#obsTable > tbody > tr > td:nth-child(2) > span > span.wx-value") %>%
      html_text() %>%
      as.numeric()
    
    if(weathertest == "Windchill"){
      
      windchill <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(3)") %>%
        html_text()
      windchill[windchill == "\n  -\n"] <- NA
      windchill[!is.na(windchill)] <- substr(windchill[!is.na(windchill)], 4, 
                                             nchar(windchill[!is.na(windchill)])-4)
      windchill <- as.numeric(windchill)
      
      heatindex <- rep(NA, each=length(temp))
      
      print("Windchill")
      
    }
    
    if(weathertest == "Heat Index"){
      
      windchill <- rep(NA, each=length(temp))
      
      heatindex <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(3)") %>%
        html_text()
      heatindex[heatindex == "\n  -\n"] <- NA
      heatindex[!is.na(heatindex)] <- substr(heatindex[!is.na(heatindex)], 4, 
                                             nchar(heatindex[!is.na(heatindex)])-4)
      heatindex <- as.numeric(heatindex)
      
      print("heatindex")
    }
    
    if(weathertest == "Dew Point"){
      
      windchill <- rep(NA, each=length(temp))
      
      heatindex <- rep(NA, each=length(temp))
      
      print("dew point")
    }
    
    
    if(weathertest == "Windchill" | weathertest == "Heat Index"){
      
      dewpoint <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(4) > span > span.wx-value") %>%
        html_text() %>%
        as.numeric()
      
      humidity <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(5)") %>%
        html_text()
      humidity <- as.numeric(substr(humidity, 1, 2))
      
      
      
      #pressure <- weatherpage %>%
      #  html_nodes("#obsTable > tbody > tr > td:nth-child(6) > span > span.wx-value") %>%
      #  html_text() %>%
      #  as.numeric()
      
      pressure <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(6)") %>%
        html_text()
      pressure[pressure == "\n  -\n"] <- NA
      pressure[!is.na(pressure)] <- substr(pressure[!is.na(pressure)],4,
                                           nchar(pressure[!is.na(pressure)])-4)
      pressure <- as.numeric(pressure)
      
      visibility <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(7)") %>%
        html_text()
      visibility[visibility == "\n  -\n"] <- NA
      visibility[!is.na(visibility)] <- substr(visibility[!is.na(visibility)],4,
                                               nchar(visibility[!is.na(visibility)])-4)
      visibility <- as.numeric(visibility)
      
      winddir <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(8)") %>%
        html_text()
      
      windspeed <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(9)") %>%
        html_text()
      windspeed[windspeed == "\n  -\n"] <- NA
      windspeed[windspeed == "Calm"] <- NA
      windspeed[!is.na(windspeed)] <- substr(windspeed[!is.na(windspeed)], 4, 
                                             nchar(windspeed[!is.na(windspeed)])-5)
      windspeed <- as.numeric(windspeed)
      
      #heatindex <- rep(NA, each=length(windspeed))
      
      gustspeed <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(10)") %>%
        html_text()
      gustspeed[gustspeed == "\n  -\n"] <- NA
      gustspeed[!is.na(gustspeed)] <- as.numeric(substr(gustspeed[!is.na(gustspeed)],4,7))
      
      precip <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(11)") %>%
        html_text()
      precip[precip == "N/A"] <- NA
      precip[!is.na(precip)] <- as.numeric(substr(precip[!is.na(precip)],4,7))
      
      eventTestPage <- html("http://www.wunderground.com/history/airport/KNYC/2014/12/3/DailyHistory.html")
      eventTest <- eventTestPage %>%
        html_nodes("#obsTable > tbody > tr:nth-child(1) > td:nth-child(12)") %>%
        html_text()
      
      events <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(12)") %>%
        html_text()
      events[events == eventTest] <- NA
      events[!is.na(events)] <- substr(events[!is.na(events)], 2, nchar(events[!is.na(events)])-1)
      
      conditions <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(13)") %>%
        html_text()
      
    }
    
    if(weathertest == "Dew Point"){
      
      dewpoint <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(3) > span > span.wx-value") %>%
        html_text() %>%
        as.numeric()
      
      humidity <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(4)") %>%
        html_text()
      humidity <- as.numeric(substr(humidity, 1, 2))
      
      pressure <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(5)") %>%
        html_text()
      pressure[pressure == "\n  -\n"] <- NA
      pressure[!is.na(pressure)] <- substr(pressure[!is.na(pressure)],4,
                                           nchar(pressure[!is.na(pressure)])-4)
      pressure <- as.numeric(pressure)
      
      visibility <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(6)") %>%
        html_text()
      visibility[visibility == "\n  -\n"] <- NA
      visibility[!is.na(visibility)] <- substr(visibility[!is.na(visibility)],4,
                                               nchar(visibility[!is.na(visibility)])-4)
      visibility <- as.numeric(visibility)
      
      winddir <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(7)") %>%
        html_text()
      
      windspeed <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(8)") %>%
        html_text()
      windspeed[windspeed == "\n  -\n"] <- NA
      windspeed[windspeed == "Calm"] <- NA
      windspeed[!is.na(windspeed)] <- substr(windspeed[!is.na(windspeed)], 4, 
                                             nchar(windspeed[!is.na(windspeed)])-5)
      windspeed <- as.numeric(windspeed)
      
      heatindex <- rep(NA, each=length(windspeed))
      
      gustspeed <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(9)") %>%
        html_text()
      gustspeed[gustspeed == "\n  -\n"] <- NA
      gustspeed[!is.na(gustspeed)] <- as.numeric(substr(gustspeed[!is.na(gustspeed)],4,7))
      
      precip <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(10)") %>%
        html_text()
      precip[precip == "N/A"] <- NA
      precip[!is.na(precip)] <- as.numeric(substr(precip[!is.na(precip)],4,7))
      
      eventTestPage <- html("http://www.wunderground.com/history/airport/KNYC/2014/12/3/DailyHistory.html")
      eventTest <- eventTestPage %>%
        html_nodes("#obsTable > tbody > tr:nth-child(1) > td:nth-child(12)") %>%
        html_text()
      
      events <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(11)") %>%
        html_text()
      events[events == eventTest] <- NA
      events[!is.na(events)] <- substr(events[!is.na(events)], 2, nchar(events[!is.na(events)])-1)
      
      conditions <- weatherpage %>%
        html_nodes("#obsTable > tbody > tr > td:nth-child(12)") %>%
        html_text()
      
    }
    
    dfadd <- data.frame(cbind(
      year, month, day, hour, minute, temp, windchill, heatindex, dewpoint, 
      humidity,pressure, visibility, winddir, windspeed, gustspeed, precip, 
      events, conditions), stringsAsFactors = FALSE)
    
    df <- rbind( df,dfadd)
    
    rm(dfadd)
    
    
  }
  
  
  
}

df$year <- as.numeric(df$year)
df$month <- as.numeric(df$month)
df$day <- as.numeric(df$day)
df$hour <- as.numeric(df$hour)
df$minute <- as.numeric(df$minute)
df$temp <- as.numeric(df$temp)
df$windchill <- as.numeric(df$windchill)
df$heatindex <- as.numeric(df$heatindex)
df$dewpoint <- as.numeric(df$dewpoint)
df$humidity <- as.numeric(df$humidity)
df$pressure <- as.numeric(df$pressure)
df$visibility <- as.numeric(df$visibility)
df$windspeed <- as.numeric(df$windspeed)
df$gustspeed <- as.numeric(df$gustspeed)
df$precip <- as.numeric(df$precip)

df <- dfraw %>%
  arrange(year, month, day, hour, minute)

approxo <- function(vec)
{
  vec <- zoo(vec)
  vec <- na.approx(vec)
  vec <- as.vector(vec)
  
  return(vec)
}

df$temp <- approxo(df$temp)
df$dewpoint <- approxo(df$dewpoint)
df$humidity <- approxo(df$humidity)
df$pressure <- approxo(df$pressure)
df$visibility <- approxo(df$visibility)
df$windspeed <- approxo(df$windspeed)


cleanup <- function(data)
{
  data$hourtest <- c(1, ifelse(head(data$hour,-1) != tail(data$hour,-1), 1, 0))
  data <- data %>%
    filter(hourtest == 1) %>%
    select(-hourtest)
  
  data$midnighttest <- c(0, ifelse(head(data$hour,-1) == 23 & tail(data$hour,-1) == 0, 1, 0))
  data <- data %>%
    filter(midnighttest == 0) %>%
    select(-midnighttest)
  
  d <- 0:23
  missinghours <- d[!(d %in% data$hour)]
  naaddition <- rep(NA, each=length(missinghours))
  dfadd <- data.frame(
    year = rep(data$year[1], each=length(missinghours)),
    month = rep(data$month[1], each=length(missinghours)),
    day = rep(data$day[1], each=length(missinghours)),
    hour = missinghours,
    minute = naaddition,
    temp = naaddition,
    windchill = naaddition,
    heatindex = naaddition,
    dewpoint = naaddition,
    humidity = naaddition,
    pressure = naaddition,
    visibility = naaddition,
    winddir = naaddition,
    windspeed = naaddition,
    gustspeed = naaddition,
    precip = naaddition,
    events = naaddition,
    conditions = naaddition,
    stringsAsFactors = FALSE)
  
  data <- rbind(data, dfadd)
  data <- arrange(data, hour)
  
  return(data)
}



df <- ddply(df, .variables=c("year", "month", "day"), .fun = cleanup)

df$temp <- approxo(df$temp)
df$dewpoint <- approxo(df$dewpoint)
df$humidity <- approxo(df$humidity)
df$pressure <- approxo(df$pressure)
df$visibility <- approxo(df$visibility)
df$windspeed <- approxo(df$windspeed)

#############################################################


# dfagg <- df %>%
#   filter(month == monthindex, year == yearyear) %>%
#   group_by(day) %>%
#   summarise(Count=n()) %>%
#   filter(Count != 24)
# 
# problemdays <- dfagg$day
# 
# 
# for(dateproblem in problemdays){
#   dftest <- df %>%
#     filter(day == dateproblem, month == monthindex)
#   
#   d <- 0:23
#   missinghours <- d[!(d %in% dftest$hour)]
#   naaddition <- rep(NA, each=length(missinghours))
#   dfadd <- data.frame(
#     year = rep(yearyear, each=length(missinghours)),
#     month = rep(monthindex, each=length(missinghours)),
#     day = rep(dateproblem, each=length(missinghours)),
#     hour = missinghours,
#     minute = naaddition,
#     temp = naaddition,
#     windchill = naaddition,
#     heatindex = naaddition,
#     dewpoint = naaddition,
#     humidity = naaddition,
#     pressure = naaddition,
#     visibility = naaddition,
#     winddir = naaddition,
#     windspeed = naaddition,
#     gustspeed = naaddition,
#     precip = naaddition,
#     events = naaddition,
#     conditions = naaddition,
#     stringsAsFactors = FALSE)
#   
#   df<- rbind(df, dfadd)
#   rm(dfadd, dftest)
# }
# 
# #dfpatch <- data.frame(year = numeric(0),
# #                      month = numeric(0),
# #                      day = numeric(0),
# #                      hour = numeric(0),
# #                      minute = numeric(0),
# #                      temp = numeric(0),
# #                      windchill = numeric(0),
# #                      heatindex = numeric(0),
# #                      dewpoint = numeric(0),
# #                      humidity = numeric(0),
# #                      pressure = numeric(0),
# #                      visibility = numeric(0),
# #                      winddir = character(0),
# #                      windspeed = numeric(0),
# #                      gustspeed = numeric(0),
# #                      precip = numeric(0),
# #                      events = character(0),
# #                      conditions = character(0), 
# #                      stringsAsFactors = FALSE)
# 
# rm(dfagg)
# 
# 
# 
# if(dfadd[dim(dfadd)[1],'hour'] == 0){
#   dfadd <- dfadd[1:(dim(dfadd)[1]-1),]
# }
# 
# dfadd$hourtest <- c(1, ifelse(head(dfadd$hour,-1) != tail(dfadd$hour,-1), 1, 0))
# 
# dfadd <- dfadd %>%
#   filter(hourtest == 1) %>%
#   select(-hourtest)
# 
# 
# 
# #  dftest <- df %>%
# #    filter(is.na(day))
# #  
# #  if(dim(dftest)[1] != 0){
# #    error <- c(error, date)
# #  }
# 
# 
