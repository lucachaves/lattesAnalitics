library(circlize)
library(gridExtra)
library(ggplot2)
library(RPostgreSQL)

generate.grid.col <- function(kindContext){
	grid.col = NULL
	if(kindContext == "region"){
		grid.col["centro-oeste"] = "#00FFFF"
		grid.col["nordeste"] = "#FF0000"
		grid.col["norte"] = "#FF00FF"
		grid.col["sudeste"] = "#FFFF00"
		grid.col["sul"] = "#CCCCCC"
	}else if(kindContext == "country"){
		grid.col["brazil"] = "#00FF00"
		grid.col["spain"] = "#00FFFF"
		grid.col["united states"] = "#FF0000"
		grid.col["united kingdom"] = "#FF00FF"
		grid.col["canada"] = "#FFFF00"
		grid.col["france"] = "#CCCCCC"
		grid.col["portugal"] = "#0000AA"
		grid.col["belgium"] = "#00FFAA"
		grid.col["uruguay"] = "#00AA00"
		grid.col["germany"] = "#00AAFF"
		grid.col["australia"] = "#00AAAA"
		grid.col["colombia"] = "#FF00AA"
		grid.col["belize"] = "#FFFFAA"
		grid.col["argentina"] = "#FFAA00"
		grid.col["japan"] = "#FFAAFF"
		grid.col["chile"] = "#FFAAAA"
		grid.col["netherlands"] = "#AA0000"
		grid.col["italy"] = "#AA00FF"
		grid.col["peru"] = "#AA00AA"
		grid.col["denmark"] = "#AAFF00"
		grid.col["switzerland"] = "#AAFFFF"
		grid.col["sweden"] = "#AAFFAA"
		grid.col["cuba"] = "#AAAA00"
		grid.col["venezuela"] = "#AAAAFF"
	}
	grid.col
}

generate.chord <- function(imageFile, mat, kindContext){
	grid.col <- generate.grid.col(kindContext)
	png(imageFile, 1000, 1000, pointsize = 12)
  circos.par(start.degree = 90)

  chordDiagram(
		mat, 
		grid.col = grid.col,
		annotationTrack = "grid", 
		preAllocateTracks = list(track.height = 0.3)
	)

	circos.trackPlotRegion(
		track.index = 1, 
		panel.fun = function(x, y) {
			xlim = get.cell.meta.data("xlim")
			ylim = get.cell.meta.data("ylim")
			sector.name = get.cell.meta.data("sector.index")
			
			circos.text(
				mean(xlim), 
				ylim[1], 
				sector.name, 
				facing = "clockwise",
				niceFacing = TRUE, 
				adj = c(0, 0.5),
				cex = 1.5
			)
		}, 
		bg.border = NA
	)

	circos.clear()

	dev.off()
}

generate.mfc <- function(kindFlow, kindContext, kindTime, valueTime=null){
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname="mobilitygraph",host="192.168.56.101",port=5432,user="postgres",password="postgres")
  sqlFile <- paste('./data/table-',kindContext,'/',kindFlow,'-',kindTime, '.sql',sep='')
  
  if(kindTime == "all"){
  	print("generating chord all")
  	sql <- paste(readLines(sqlFile),collapse=" ")
  	rs <- dbSendQuery(con,sql)
  	flows <- fetch(rs,n=-1)
  	names <- union(flows$oname,flows$dname)
  	mat <- matrix(0, nrow = length(names), ncol = length(names))
  	rownames(mat) = names
  	colnames(mat) = names
  	for(i in 1:nrow(flows)){
  		mat[flows[i,]$oname, flows[i,]$dname] = flows[i,]$trips
  	}
  	imageFile <- paste('./data/mfc-',kindContext,'/',kindFlow,'-',kindTime, '.png',sep='')
  	generate.chord(imageFile, mat, kindContext)
	}else if(kindTime == "rangeAll"){
		print("generating chord rangeAll")
  	sql <- paste(readLines(sqlFile),collapse=" ")
		sql <- gsub("_START_YEAR_", valueTime[1], sql)
    sql <- gsub('_END_YEAR_', valueTime[2], sql)
  	rs <- dbSendQuery(con,sql)
  	flows <- fetch(rs,n=-1)
  	names <- union(flows$oname,flows$dname)
  	mat <- matrix(0, nrow = length(names), ncol = length(names))
  	rownames(mat) = names
  	colnames(mat) = names
  	for(i in 1:nrow(flows)){
  		mat[flows[i,]$oname, flows[i,]$dname] = flows[i,]$trips
  	}
  	range <- paste(valueTime[1],'-',valueTime[2],sep='')
    imageFile <- paste('./data/mfc-',kindContext,'/',kindFlow,'-',range,'.png',sep='')
  	generate.chord(imageFile, mat, kindContext)
	}else if(kindTime == "rangeYear"){
		for (year in valueTime[1]:valueTime[2]) {
		  print(paste("generating chord year ",year,sep=""))
		  sql <- paste(readLines(sqlFile),collapse=" ")
		  sql <- gsub('_YEAR_', year, sql)
		  rs <- dbSendQuery(con,sql)
		  flows <- fetch(rs,n=-1)
		  names <- union(flows$oname,flows$dname)
		  mat <- matrix(0, nrow = length(names), ncol = length(names))
		  rownames(mat) = names
		  colnames(mat) = names
		  for(i in 1:nrow(flows)){
		  	mat[flows[i,]$oname, flows[i,]$dname] = flows[i,]$trips
		  }
		  imageFile <- paste('./data/mfc-',kindContext,'/',kindFlow,'-',year,'.png',sep='')
		  generate.chord(imageFile, mat, kindContext)
		}
	}
	print("END")
}

# generate.mfc("fnf", "region", "all")
# generate.mfc("fnf", "region", "rangeAll", c(2000,2013))
generate.mfc("fnf", "region", "rangeYear", c(2000,2013))
# generate.mfc("fnf", "region", "rangeYear", c(2000,2000))

# TODO
# 1973, 1983, 1993, 2003, 2013
# sigla
# ordem
