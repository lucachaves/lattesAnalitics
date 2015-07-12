library(RPostgreSQL)
source('heatMapping.r')
source('flowMapping.r')
source('chordGraph.r')
source('treeMap.r')
source('generateQuery.r')
source('converter.r')

##### GM,MC,MFC #####
# kindGraphic c('mc', 'gm', 'mfc')
# kindFlow 		c('fnf','fff','fft','ffft','all')
# kindContext c('city','state','region','country','continent')
# kindTime <- c('all', 2013, 'all-years-1973-2013','each-years-1963-2013','set-year-1973-1983-1993-2003-2013')
generate.graphic <- function(kindGraphic, kindFlow, kindContext, kindTime='', kindFilter=c(), scalemc=c('normal'), scalegm=c('equal0.1'), textvalue=FALSE, mapview=FALSE, maxvalue=FALSE){
	if(kindTime == ''){
		kindTime <- c('all', 'set-year-1973-1983-1993-2003-2013')
	}
	 
	for(flow in kindFlow){
		for(context in kindContext){
				print(paste(flow, context, sep='-'))
				if(flow == 'fnf' | flow == 'fff'){
					if(is.element('all-years-1973-2013', kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeAll", valueTime=c(1973,2013), kindFilter=kindFilter, scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview, maxvalue=maxvalue)
					}
					if(is.element('each-years-1963-2013', kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(1963,2013), kindFilter=kindFilter, scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview, maxvalue=maxvalue)
					}
					if(is.element('set-year-1973-1983-1993-2003-2013',kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="setYear", valueTime=c(1973, 1983, 1993, 2003, 2013), kindFilter=kindFilter, scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview, maxvalue=maxvalue)
					}
					if(is.element(2013,kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(2013,2013), kindFilter=kindFilter, scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview, maxvalue=maxvalue)
					}
				}
				if(is.element('all',kindTime)){
					generate.graphic.each(kindGraphic, flow, context, kindTime="all", kindFilter=kindFilter, scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview, maxvalue=maxvalue)
				}
		}
	}
}

##### GM,MC,MFC #####
generate.graphic.each <- function(kindGraphic, kindFlow, kindContext, kindTime='all', valueTime=NULL, kindFilter=c(), scalemc=c('normal'), scalegm=c('equal0.1'), textvalue=FALSE, mapview=FALSE, maxvalue=maxvalue){
  print(paste(kindFlow, kindContext, kindTime,sep='-'))

  valueFilter <- c()
  if(length(kindFilter) == 0){
  	kindFilter <- ''
  }else{
	  valueFilter <- query.filter(kindFilter)
  	kindFilter <- paste('-',paste(kindFilter,collapse='-'),sep='')
  }

	years <- if(kindTime=="rangeYear"){
		valueTime[1]:valueTime[2]
	}else if(kindTime == "setYear"){
		valueTime
	}else if(kindTime == "all" | kindTime == "rangeAll"){
		'range'
	}

	for (year in years) {
	  print(paste("year ",year,sep=""))

		imageFile <- if(kindTime == "rangeYear" | kindTime == "setYear"){
			paste(kindContext,'-',kindFlow, kindFilter,'-',year,'.png',sep='')
		}else if(kindTime == "all"){
	  	paste(kindContext,'-',kindFlow, kindFilter,'-',kindTime,'.png',sep='')
  	}else if(kindTime == "rangeAll"){
	  	paste(kindContext,'-',kindFlow, kindFilter,'-',paste(valueTime[1],'-',valueTime[2],sep=''),'.png',sep='')
  	}
  	print(imageFile)

	  sql <- if(kindTime == "rangeYear" | kindTime == "setYear"){
	  	generate.query(kindContext, kindFlow, 'year', year, filter=valueFilter)
	  }else if(kindTime == "all"){
  		generate.query(kindContext, kindFlow, filter=valueFilter)
  	}else if(kindTime == "rangeAll"){
  		generate.query(kindContext, kindFlow, 'range', valueTime, filter=valueFilter)
  	}
	  # cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",sql,"\n",sep=""))
	  flows <- getdata(sql)
	  
	  if(length(flows)>0){
    	# cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",flows,"\n",sep=""))
    	if(is.element('mc',kindGraphic)){
    		for(scale in scalemc){
    			imageFileMC <- paste(scale,'-',imageFile,sep='')
    			if(textvalue != FALSE){
    				imageFileMC <- paste('withnum',imageFileMC,sep='-')
  				}

    			imageFileMC <- paste('./image/mc/',imageFileMC,sep='')
    			
    			size <- if(kindContext == "region"){
				    c(500,450)
				  }else if(kindContext == "continent"){
				    c(600, 500)
				  }else{
				    c(1000,1000)
				  }

				  orderrow <- FALSE
				  if(kindTime == 'setYear'){
				  	sql <- generate.query(kindContext, kindFlow, filter=query.filter(c('rangeYear'),valueTime))
	  				result <- getdata(sql)
				  	orderrow <- union(result$oname, result$dname)
				  	maxvalue <- max(table(c(result$oname, result$dname)))
				  }

				  flowsMC <- flows
    			flowsMC$trips <- convert.scale.value(flowsMC$trips, scale, 'mc')
				  df <- convert.result.todf.square(flowsMC$oname, flowsMC$dname, flowsMC$trips, orderrow)				    
    			
    			png(filename = imageFileMC, width = size[1], height = size[2])

				  gg <- generate.heatmap('square', df, scale=scale,textvalue=textvalue, orderrow=orderrow, maxvalue=maxvalue)
				  
				  print(gg)
  				dev.off()
  				cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFileMC,"\n",sep=""))
				}
    	}

    	if(is.element('mfc',kindGraphic)){
    		mat <- convert.result.tomatrix(flows)
				imageFileFC <- paste('./image/mfc/',imageFile,sep='')

		  	generate.chordGraph(imageFileFC, mat, kindContext)
		  	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFileFC,"\n",sep=""))
		  }

		  if(is.element('gm',kindGraphic)){
		  	for(scale in scalegm){
		  		flowsGM <- flows
		  		flowsGM$trips <- convert.scale.value(flowsGM$trips, scale, 'gm', kindContext=kindContext,kindFlow=kindFlow,kindTime=kindTime)
		  		imageFileGM <- paste('./image/gm/',scale,'-',imageFile,sep='')
				  if(mapview != FALSE){
				  	kindContext <- mapview
				  }
		  		width <- if(kindContext == 'region' | kindContext == 'state'){1000}else{1400}
				  height <- if(kindContext == 'region' | kindContext == 'state'){1000}else{750}
				  png(filename = imageFileGM, width = width, height = height)

		  		gg <- generate.flowmapping(flowsGM, kindContext, scale=scale, points=TRUE ,textvalue=textvalue)

		  		print(gg)
  				dev.off()
		  		cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFileGM,"\n",sep=""))
		  	}
		  }
		}else{
      cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\nempty flows\n",sep=""))
    }
	}
}

##### TIMELINE #####
# flowMoment (target,source,all)
generate.graphic.timeline <- function(kindContext, kindMoment, flowMoment='target', scale='normal', range=c(1950,2013), limit=10){
	query.names <- generate.query(kindContext, kindFlow, kindQuery='name-eyear-target',kindMoment=kindMoment, flowMoment='target', range=c(1950,2013), limit=10, valuename=TRUE)
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",query.names,"\n",sep=""))
	rn <- getdata(query.names)

	# TODO
	query.range <- generate.query(kindContext, kindFlow, kindQuery='name-eyear-target',kindMoment=kindMoment, flowMoment='target', range=c(1950,2013), limit=10)
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",query.range,"\n",sep=""))
	flows <- getdata(query.range)
	
	imageFile <- paste(limit,scale,kindContext,kindMoment,paste(range,collapse='-'),sep='-')
	imageFile <- paste('./image/tl/top',imageFile,'.png',sep='')
	flows$degree <- convert.scale.value(flows$degree, scale, 'mc')
	size <- c(1000,200)
	df <- convert.result.todf.timeline(flows$eyear, flows$place, flows$degree, range)
	png(filename = imageFile, width = size[1], height = size[2])
	
	gg <- generate.heatmap('timeline', df, orderrow=rev(rn$name), range=range, scale=scale)
	
	print(gg)
	dev.off()
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFile,"\n",sep=""))
}

##### TREEMAP #####
# include (all,range)
# range (c(x,y), all, year)
# flowMoment (target,source,all)
# kindMoment (last,first,work,doutorado,graduacao,...)
# kindContext (instituition,city,...)
generate.graphic.treemap <- function(kindContext, kindMoment, flowMoment='target', range=c(1950,2013), limit=10, include='range'){
	
	sql <- generate.query(kindContext, '',kindQuery='name-count-', flowMoment=flowMoment, kindMoment=kindMoment, range=range, limit=limit)
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",sql,"\n",sep=""))

	flows <- getdata(sql)

	if(include == 'all'){
		flows.all <- getdata(generate.query(kindContext, '',kindQuery='name-count-', flowMoment=flowMoment, kindMoment=kindMoment, range=range, limit='none'))
		flows[nrow(flows),]$place <- 'outros'
		flows[nrow(flows),]$degree <- sum(flows.all$degree)-sum(flows$degree)
	}

	imageFile <- paste(limit,kindContext,kindMoment,flowMoment,paste(range,collapse='-'),sep='-')
	imageFile <- paste('./image/tm/rank',imageFile,'.png',sep='')

	generate.treemap(imageFile, flows)
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFile,"\n",sep=""))
}

##### LINE #####
generate.graphic.line <- function(kindMoment, flowMoment='target', range=c(1970,2012)){
	
	flows.all <- getdata(generate.query('', '', kindQuery='eyear-count-doutorado-all'))
	flows.nacional <- getdata(generate.query('', '', kindQuery='eyear-count-doutorado-nacional'))
	people <- read.csv("data/populacao-ipeadata-1872-2012.csv")

	diff <- range[2]-range[1]
	doutorado.all = flows.all$count[(length(flows.all$count) - diff):length(flows.all$count)]
	doutorado.nacional = flows.nacional$count[(length(flows.nacional$count) - diff):length(flows.nacional$count)]
	population = people$Populacao[(length(people$Populacao) - diff):length(people$Populacao)]

	df <- data.frame(years=range[1]:range[2], all=doutorado.all, nacional=doutorado.nacional, population=population)
	
	imageFile <- paste(kindMoment,flowMoment,paste(range,collapse='-'),sep='-')
	imageFile <- paste('./image/line/line',imageFile,'.png',sep='')
	png(filename = imageFile)

	gg <- if(kindMoment == 'doutorado-all-pop-log'){
		ggplot(df, aes(x = years, y = value, colour = 'valor')) + 
			geom_line(aes(y = log(all), colour = "doutores")) + 
			geom_line(aes(y = log(population), colour = "população"))+
			xlab('anos')+ylab('quantidade')
	}else if(kindMoment == 'doutorado-all-nacional'){
		ggplot(df, aes(x = years, y = value, colour = 'valor')) + 
			geom_line(aes(y = log(all), colour = "nacional")) + 
			geom_line(aes(y = log(nacional), colour = "total"))+
			xlab('anos')+ylab('quantidade')
	}else if(kindMoment == 'doutorado'){
		ggplot(df, aes(x = years, y = all)) + 
			geom_line() + 
			xlab('anos')+ylab('quantidade')	
	}

	print(gg)
	dev.off()
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFile,"\n",sep=""))
}
