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
generate.graphic <- function(kindGraphic, kindFlow, kindContext, kindTime=c('all-time', 'set-year-1973-1983-1993-2003-2013'), filter=c(), scalemc=c('normal'), scalegm=c('equal0.1'), textvalue=FALSE, mapview=FALSE, maxvalue=FALSE){
	 
	for(flow in kindFlow){
		for(context in kindContext){
				print(paste(flow, context, sep='-'))

				if(flow == 'fnf' | flow == 'fff'){
					for(time in kindTime){
						namet <- unlist(strsplit(time,'-'))
						if('rangeYear'== namet[1]){
							if('all'== namet[2]){
								timef <- paste(namet[1],namet[3],namet[4],sep='-')
								filter <- c(filter,timef)
								print(paste(kindFlow, kindContext, timef,sep='-'))
								generate.graphic.each(kindGraphic, flow, context, filter=filter, scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview, maxvalue=maxvalue)
							}else if('each' == namet[2]){
								for(year in namet[3]:namet[4]){
									timef <- paste('year',year,sep='-')
									filter <- c(filter, timef)
									print(paste(kindFlow, kindContext, timef,sep='-'))
									generate.graphic.each(kindGraphic, flow, context, filter=filter, scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview, maxvalue=maxvalue)
								}
							}
						}
						if('setYear'== namet[1]){
							filter <- c(filter,time)
							print(paste(kindFlow, kindContext, time,sep='-'))
							generate.graphic.each(kindGraphic, flow, context, filter=filter, scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview, maxvalue=maxvalue)
						}
						if('year'== namet[1]){
							filter <- c(filter,time)
							print(paste(kindFlow, kindContext, time,sep='-'))
							generate.graphic.each(kindGraphic, flow, context, filter=filter, scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview, maxvalue=maxvalue)
						}
					}
				}
				if(is.element('all-time',kindTime)){
					print(paste(kindFlow, kindContext, 'all-time', sep='-'))
					generate.graphic.each(kindGraphic, flow, context, filter=filter, scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview, maxvalue=maxvalue)
				}
		}
	}
}

##### GM,MC,MFC #####
generate.graphic.each <- function(kindGraphic, kindFlow, kindContext, filter=c(), scalemc=c('normal'), scalegm=c('equal0.1'), textvalue=FALSE, mapview=FALSE, maxvalue=maxvalue){

	namef <- if(length(filter)>0){
		paste('-',paste(filter,collapse='-'),sep='')
	}else{
		''
	}
	imageFile <- paste(kindContext,'-',kindFlow,namef,'.png',sep='')
	print(imageFile)

  sql <- generate.query(kindContext, kindFlow, filter=filter)
  cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",sql,"\n",sep=""))
  flows <- getdata(sql)
  
  if(length(flows)>0){
  	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",flows,"\n",sep=""))
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
			  for(f in filter){
				  if(unlist(strsplit(f,'-'))[1] == 'setYear'){
				  	sql <- generate.query(kindContext, kindFlow, filter=c(f))
	  				result <- getdata(sql)
				  	orderrow <- union(result$sacronym, result$tacronym)
				  	maxvalue <- max(table(c(result$sacronym, result$tacronym)))
				  }	
			  }

			  flowsMC <- flows
  			flowsMC$count <- convert.scale.value(flowsMC$count, scale, 'mc')
			  df <- convert.result.todf.square(flowsMC$sacronym, flowsMC$tacronym, flowsMC$count, orderrow)				    
  			
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
	  	
	  	kindTime <- ''
	  	for(f in filter){
	  		if(!is.element(unlist(strsplit(f,'-'))[1],c('year','setYear','rangeYear')))
	  			kindTime <- 'all'
	  	}

	  	for(scale in scalegm){
	  		flowsGM <- flows
	  		flowsGM$count <- convert.scale.value(flowsGM$count, scale, 'gm', kindContext=kindContext,kindFlow=kindFlow,kindTime=kindTime)
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

##### TIMELINE #####
# kindNode (target,source,all)
generate.graphic.timeline <- function(kindContext, kindFlow, kindNode='target', scale='normal', limit=10, filter=c('rangeYear-1950-2013')){

	for(f in filter){
		if(unlist(strsplit(f,'-'))[1] == 'rangeYear')
			range <- c(unlist(strsplit(f,'-'))[2],unlist(strsplit(f,'-'))[3])
	}

	query.names <- generate.query(kindContext, kindFlow,filter=filter,kindNode=kindNode,limit=limit,kindQuery='top-name')
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",query.names,"\n",sep=""))
	rn <- getdata(query.names)
	
	query.range <- generate.query(kindContext, kindFlow,filter=filter,kindNode=kindNode,limit=limit,kindQuery='top-name-edge:end_year')
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",query.range,"\n",sep=""))
	flows <- getdata(query.range)
	flows$count <- convert.scale.value(flows$count, scale, 'mc')
	df <- convert.result.todf.timeline(flows$end_year, flows$acronym, flows$count, range)
	
	imageFile <- paste(limit,scale,kindContext,kindFlow,kindNode,paste(filter,collapse='-'),sep='-')
	imageFile <- paste('./image/tl/top',imageFile,'.png',sep='')
	
	size <- c(1000,200)
	png(filename = imageFile, width = size[1], height = size[2])
	gg <- generate.heatmap('timeline', df, orderrow=rev(rn$acronym), range=range, scale=scale)
	print(gg)
	dev.off()
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFile,"\n",sep=""))
}

##### TREEMAP #####
# include (all,range)
# range (c(x,y), all, year)
# kindNode (target,source,all)
# kindFlow (last,first,work,doutorado,graduacao,...)
# kindContext (instituition,city,...)
generate.graphic.treemap <- function(kindContext, kindFlow, kindNode='target', filter=c(), limit=10, include='range'){
	
	sql <- generate.query(kindContext, kindFlow, kindQuery='name-count', kindNode=kindNode, filter=filter, limit=limit)
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",sql,"\n",sep=""))
	flows <- getdata(sql)

	if(include == 'all'){
		flows.all <- getdata(generate.query(kindContext, kindFlow,kindQuery='name-count', kindNode=kindNode, filter=filter, limit='none'))
		flows[nrow(flows),]$acronym <- 'outros'
		flows[nrow(flows),]$count <- sum(flows.all$count)-sum(flows$count)
	}

	df <- data.frame(index=flows$acronym,vSize=flows$count,vColor=flows$count)

	imageFile <- paste(limit,kindContext,kindFlow,kindNode,paste(filter,collapse='-'),sep='-')
	imageFile <- paste('./image/tm/rank',imageFile,'.png',sep='')

	generate.treemap(imageFile, df)
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFile,"\n",sep=""))
}

##### LINE #####
generate.graphic.line <- function(kindFlow, kindNode='target', range=c(1970,2012)){
	
	flows.all <- getdata(generate.query('', '', kindQuery='count-all-doutorado-by-end_year'))
	flows.nacional <- getdata(generate.query('', '', kindQuery='count-all-doutorado-nacional-by-end_year'))
	people <- read.csv("data/populacao-ipeadata-1872-2012.csv")

	diff <- range[2]-range[1]
	doutorado.all = flows.all$count[(length(flows.all$count) - diff):length(flows.all$count)]
	doutorado.nacional = flows.nacional$count[(length(flows.nacional$count) - diff):length(flows.nacional$count)]
	population = people$Populacao[(length(people$Populacao) - diff):length(people$Populacao)]

	df <- data.frame(years=range[1]:range[2], all=doutorado.all, nacional=doutorado.nacional, population=population)
	
	imageFile <- paste(kindFlow,kindNode,paste(range,collapse='-'),sep='-')
	imageFile <- paste('./image/line/line',imageFile,'.png',sep='')
	png(filename = imageFile)

	gg <- if(kindFlow == 'doutorado-all-pop-log'){
		ggplot(df, aes(x = years, y = value, colour = 'valor')) + 
			geom_line(aes(y = log(all), colour = "doutores")) + 
			geom_line(aes(y = log(population), colour = "população"))+
			xlab('anos')+ylab('quantidade')
	}else if(kindFlow == 'doutorado-all-nacional'){
		ggplot(df, aes(x = years, y = value, colour = 'valor')) + 
			geom_line(aes(y = log(all), colour = "nacional")) + 
			geom_line(aes(y = log(nacional), colour = "total"))+
			xlab('anos')+ylab('quantidade')
	}else if(kindFlow == 'doutorado'){
		ggplot(df, aes(x = years, y = all)) + 
			geom_line() + 
			xlab('anos')+ylab('quantidade')	
	}

	print(gg)
	dev.off()
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFile,"\n",sep=""))
}


