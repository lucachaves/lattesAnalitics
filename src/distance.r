
# http://www.r-bloggers.com/great-circle-distance-calculations-in-r/
gcd.hf <- function(long1, lat1, long2, lat2) {
  R <- 6371 # Earth mean radius [km]
  delta.long <- (long2 - long1)
  delta.lat <- (lat2 - lat1)
  a <- sin(delta.lat/2)^2 + cos(lat1) * cos(lat2) * sin(delta.long/2)^2
  c <- 2 * asin(min(1,sqrt(a)))
  d = R * c
  return(d) # Distance in km
}

time.interval <- function(end_year, start_year){
	if(end_year == '' | start_year == '')
		return(0)
	ifelse(end_year - start_year > 0, end_year -start_year, 0)
}

<-function(){
	DD <- c()
	DDi <- c()
	ID <- c()
	IDi <- c()
	for(i in 1:nrow(df)){
		DD <- c(DD, gcd.hf(df[i,]$slatitude,df[i,]$slongitude,df[i,]$tlatitude,df[i,]$tlongitude))
		DDi[df[i,]$id16] <- c(DDi[df[i,]$id16] , gcd.hf(df[i,]$slatitude,df[i,]$slongitude,df[i,]$tlatitude,df[i,]$tlongitude))
		ID <- c(ID, time.interval(df[i,]$end_year, df[i,]$syear))
		IDi[df[i,]$id16] <- c(IDi[df[i,]$id16], time.interval(df[i,]$end_year, df[i,]$syear))
	}

	DDt <- c()
	IDt <- c()
	for(id16 in id16s){
		DDt <- c(DDt,sum(DDi[id16]))
		IDt <- c(IDt,sum(IDi[id16]))
	}	
}

