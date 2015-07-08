library(maps)
library(rgdal)
library(ggplot2)
library(maptools)
library(geosphere)
library(grid)
library(RPostgreSQL)
source('generateQuery.r')

draw.map <- function(year, ylim=c(0,85)) {
  # https://wwwn.cdc.gov/epiinfo/html/shapefiles.htm
  state.map <- readShapeSpatial("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/BR/br.shp")
  state.map.df <- fortify(state.map, region = "ADMIN_NAME")
  
  ggplot(state.map.df, aes(x=long, y=lat, group=group)) +
    # geom_polygon(size = 0.2, fill="#191919") + # fill = #FFFFFF, #CCCCCC, #F9F9F9
    geom_polygon(size = 0.2, fill="#FFFFFF") +
    geom_path(size=0.2, colour = "grey65") +
    # coord_map("mercator", ylim=ylim, xlim=c(-180,180)) +
    theme(
      panel.background = element_blank(), 
      # panel.background = element_rect(fill = "#000000", colour = NA), 
      panel.grid.minor = element_blank(), 
      panel.grid.major = element_blank(),  
      axis.ticks = element_blank(), 
      axis.title.x = element_blank(), 
      axis.title.y = element_blank(), 
      axis.text.x = element_blank(), 
      axis.text.y = element_blank(),
      plot.title = element_text(size = rel(3))
    )+
    ggtitle(paste("Flow",year, sep=""))
 }

bezier.curve <- function(p1, p2, p3) {
  n <- seq(0,1,length.out=50)
  bx <- (1-n)^2 * p1[[1]] +
    (1-n) * n * 2 * p3[[1]] +
    n^2 * p2[[1]]
  by <- (1-n)^2 * p1[[2]] +
    (1-n) * n * 2 * p3[[2]] +
    n^2 * p2[[2]]
  data.frame(lon=bx, lat=by)
}

bezier.uv.arc <- function(p1, p2) {
  # Get unit vector from P1 to P2
  u <- p2 - p1
  u <- u / sqrt(sum(u*u))
  d <- sqrt(sum((p1-p2)^2))

  # Calculate third point for spline
  m <- d / 2
  h <- floor(d * .2)

  # Create new points in rotated space 
  pp1 <- c(0,0)
  pp2 <- c(d,0)
  pp3 <- c(m, h)

  mx <- as.matrix(bezier.curve(pp1, pp2, pp3))

  # Now translate back to original coordinate space
  theta <- acos(sum(u * c(1,0))) * sign(u[2])
  ct <- cos(theta)
  st <- sin(theta)
  tr <- matrix(c(ct,  -1 * st, st, ct),ncol=2)
  tt <- matrix(rep(p1,nrow(mx)),ncol=2,byrow=TRUE)
  points <- tt + (mx %*% tr)

  tmp.df <- data.frame(points)
  colnames(tmp.df) <- c("lon","lat")
  tmp.df
}

bezier.uv.merc.arc <- function(p1, p2) {
  # http://dsgeek.com/2013/06/08/DrawingArcsonMaps.html
  # Do a mercator projection of the latitude
  # coordinates
  pp1 <- p1
  pp2 <- p2
  pp1[2] <- asinh(tan(p1[2]/180 * pi))/pi * 180
  pp2[2] <- asinh(tan(p2[2]/180 * pi))/pi * 180

  arc <- bezier.uv.arc(pp1,pp2)
  arc$lat <-  atan(sinh(arc$lat/180 * pi))/pi * 180
  arc
}

draw.map.flow <- function(file_map, title, theme, flows, splitSize){
  png(filename = file_map, width = 1000, height = 1000)
  
  gg <- NULL
  gg <- draw.map(title, c(-90,90))

  for (i in 1:length(flows$trips)) {  
    arc <- bezier.uv.merc.arc(
      c(flows[i,]$ox, flows[i,]$oy), 
      c(flows[i,]$dx, flows[i,]$dy)
    )
    size <- (flows[i,]$trips/splitSize)+0.1 # max(flows$trips)/30
    colour <- "#EE0000" # green, #1292db, #6a6262
    gg <- gg + geom_path(
      data=as.data.frame(arc), 
      size=size, 
      colour=colour, 
      aes(x=lon, y=lat, group=NULL)
    ) 
  }

  print(gg)
  dev.off()
}

generate.gm <- function(theme, kindFlow, kindContext, kindTime, valueTime=null){
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname="mobilitygraph",host="192.168.56.101",port=5432,user="postgres",password="postgres")
  
  splitSize <- 0
  if(kindContext == 'region'){
    splitSize <- 1500
  }

  if(kindTime == "all"){
    print("generating graph all")
    sql <- generate.query(kindContext, kindFlow)
    rs <- dbSendQuery(con,sql)
    flows <- fetch(rs,n=-1)
    imageFile <- paste('./image/gm/',kindContext,'-',kindFlow,'-',kindTime, '.png',sep='')
    draw.map.flow(imageFile, '', theme, flows, splitSize)
  }else if(kindTime == "rangeAll"){
    print("generating graph rangeAll")
    sql <- generate.query(kindContext, kindFlow, 'range', valueTime)
    rs <- dbSendQuery(con,sql)
    flows <- fetch(rs,n=-1)
    range <- paste(valueTime[1],'-',valueTime[2],sep='')
    imageFile <- paste('./image/gm/',kindContext,'-',kindFlow,'-',range,'.png',sep='')
    draw.map.flow(imageFile, range, theme, flows, splitSize)
  }else if(kindTime == "rangeYear"){
    for (year in valueTime[1]:valueTime[2]) {
      print(paste("generating graph year ",year,sep=""))
      sql <- generate.query(kindContext, kindFlow, 'year', year)
      rs <- dbSendQuery(con,sql)
      flows <- fetch(rs,n=-1)
      imageFile <- paste('./image/gm/',kindContext,'-',kindFlow,'-',year,'.png',sep='')
      draw.map.flow(imageFile, year, theme, flows, splitSize)
    }
  }
}
