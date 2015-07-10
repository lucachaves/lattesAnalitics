library(maps)
library(rgdal)
library(ggplot2)
library(maptools)
library(geosphere)
library(grid)

draw.map <- function(kindContext, year, ylim=c(0,85)) {

  shapeFile <- if(kindContext == 'region'){
    'data/map/brasil_region/br.shp'
  }else if(kindContext == 'state'){
    'data/map/brasil_state/br.shp'
  }else if(kindContext == 'continent'){
    'data/map/continent/continent.shp'
  }

  field <- if(kindContext == 'region'){
    'nome'
  }else if(kindContext == 'state'){
    'ADMIN_NAME'
  }else if(kindContext == 'continent'){
    'CONTINENT'
  }

  map.view <- if(kindContext == 'region' | kindContext == 'state' | kindContext == 'continent'){
    fortify(readShapeSpatial(shapeFile), region = field)
  }else{
    map_data("world")
  }

  ggplot(map.view, aes(x=long, y=lat, group=group)) +
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

draw.map.flow <- function(kindContext, file_map, title, flows, splitSize){
  width <- if(kindContext == 'region' | kindContext == 'state'){1000}else{1400}
  height <- if(kindContext == 'region' | kindContext == 'state'){1000}else{750}

  png(filename = file_map, width = width, height = height)
  
  gg <- NULL
  gg <- draw.map(kindContext, title, c(-90,90))

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

generate.gm <- function(imageFile, flows, theme, kindFlow, kindContext, kindTime){

  draw.map.theme <- theme

  splitSize <- 0
  if(kindContext == 'city' & kindFlow == 'all'){
    splitSize <- 1000
  }else if(kindContext == 'city'){
    splitSize <- 50
  }else if(kindContext == 'state' & kindFlow == 'fnf' & kindTime == 'all'){
    splitSize <- 5000
  }else if(kindContext == 'state' & kindFlow == 'fff' & kindTime == 'all'){
    splitSize <- 5000
  }else if(kindContext == 'state' & kindFlow == 'fft'){
    splitSize <- 5000
  }else if(kindContext == 'state' & kindFlow == 'all'){
    splitSize <- 10000
  }else if(kindContext == 'region' & kindTime == 'rangeYear'){
    splitSize <- 500
  }else if(kindContext == 'region'){
    splitSize <- 1500
  }else if(kindContext == 'state' & kindFlow == 'fnf' & kindTime == 'all'){
    splitSize <- 500
  }else if(kindContext == 'state' & kindFlow == 'fff' & kindTime == 'all'){
    splitSize <- 500
  }else if(kindContext == 'state' & kindFlow == 'fft'){
    splitSize <- 500
  }else if(kindContext == 'state' & kindFlow == 'all'){
    splitSize <- 1000
  }else if(kindContext == 'state'){
    splitSize <- 50
  }else if(kindContext == 'country' & kindFlow != 'fnf' & kindTime == 'all'){
    splitSize <- 2000
  }else if(kindContext == 'country' & kindFlow == 'fnf' & kindTime == 'all'){
    splitSize <- 500
  }else if(kindContext == 'country'){
    splitSize <- 50
  }else if(kindContext == 'continent' & kindFlow != 'fnf' & kindTime == 'all'){
    splitSize <- 2000
  }else if(kindContext == 'continent' & kindFlow != 'fnf'){
    splitSize <- 200
  }else if(kindContext == 'continent' & kindFlow == 'fnf' & kindTime == 'all'){
    splitSize <- 500
  }else if(kindContext == 'continent' & kindFlow == 'fnf'){
    splitSize <- 30
  }else if(kindContext == 'continent'){
    splitSize <- 30
  }
  imageFile <- paste('./image/gm/',imageFile,sep='')
  draw.map.flow(kindContext, imageFile, '', flows, splitSize)

}
