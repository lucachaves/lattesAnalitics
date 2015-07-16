
# http://www.r-bloggers.com/great-circle-distance-calculations-in-r/
gcd.hf <- function(long1, lat1, long2, lat2) {
  R <- 6371 # Earth mean radius [km]
  delta.long <- (long2 - long1)
  delta.lat <- (lat2 - lat1)
  a <- sin(delta.lat/2)^2 + cos(lat1) * cos(lat2) * sin(delta.long/2)^2
  c <- 2 * asin(min(1,sqrt(a)))
  d = R * c
  return(d)
}

time.interval.specific <- function(end_year, start_year){
	ifelse((end_year - start_year > 0), end_year-start_year, 0)
}

time.interval.global <- function(df){

}

distance.flow.global <-function(df){
	DD <- c()
	for(i in 1:nrow(df)){
		DD[paste(df[i,]$slatitude,df[i,]$slongitude,df[i,]$tlatitude,df[i,]$tlongitude,collapse='-')] <- gcd.hf(df[i,]$slatitude,df[i,]$slongitude,df[i,]$tlatitude,df[i,]$tlongitude)
	}
	DD
}

# TODO DD, ID (global/by id16)
# distance.flow <-function(df){
# 	# global
# 	DD <- c()
# 	ID <- c()
# 	year <- c()
# 	for(i in 1:nrow(df)){
# 		time <- time.interval.specific(df[i,]$end_year, df[i,]$start_year)
# 		DD <- c(DD, gcd.hf(df[i,]$slatitude,df[i,]$slongitude,df[i,]$tlatitude,df[i,]$tlongitude))
# 		ID <- c(ID, time)
# 		year <- c(year,df[i,]$end_year)
# 	}
# 	# sum(DD)/length(DD)
# 	# sum(ID)/length(ID)
# 	data.frame(dd=DD,id=ID,year=year)
	
# 	## by id16
# 	# DDi <- c()
# 	# IDi <- c()
# 	# for(i in 1:nrow(df)){
# 	# 	time <- time.interval.specific(df[i,]$end_year, df[i,]$start_year)
# 	# 	if(time == 0) next
# 	# 	DDi[df[i,]$id16] <- c(DDi[df[i,]$id16], gcd.hf(df[i,]$slatitude,df[i,]$slongitude,df[i,]$tlatitude,df[i,]$tlongitude))
# 	# 	IDi[df[i,]$id16] <- c(IDi[df[i,]$id16], time)
# 	# }
# 	# DDt <- c()
# 	# IDt <- c()
# 	# for(id16 in id16s){
# 	# 	DDt <- c(DDt,sum(DDi[id16]))
# 	# 	IDt <- c(IDt,sum(IDi[id16]))
# 	# }	
# 	# # sum(DDt)/length(DDt)
# 	# # sum(IDt)/length(IDt)
# 	# data.frame(dd=DD,id=ID)
# }

