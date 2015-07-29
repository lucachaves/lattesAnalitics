source('heatMapping.r')
source('flowMapping.r')
source('chordGraph.r')
source('treeMap.r')
source('generateQuery.r')
source('converter.r')
source('distance.r')

##### GM,MC,MFC #####
# kindGraphic c('mc', 'gm', 'mfc')
# kindFlow 		c('fnf','fff','fft','ffft','all')
# kindContext c('city','state','region','country','continent')
# kindTime <- c('all-time', 'year-2013', 'setYear-1973-1983-1993-2003-2013', 'rangeYear-all-1973-2013', 'rangeYear-each-1973-2013')
generate.graphic <- function(kindGraphic, kindFlow, kindContext, kindTime=c('all-time', 'setYear-1973-1983-1993-2003-2013'), filter=c(), scalemc=c('normal'), scalegm=c('equal0.1'), textvalue=FALSE, mapview=FALSE){
	for(flow in kindFlow){
		for(context in kindContext){
				print(paste(flow, context, sep='-'))
				if(flow == 'fnf' | flow == 'fff'){
					for(time in kindTime){
						namet <- unlist(strsplit(time,'-'))
						if('rangeYear'== namet[1]){
							if('all'== namet[2]){
								timef <- paste(namet[1],namet[3],namet[4],sep='-')
								print(paste(flow, context, timef,sep='-'))
								generate.graphic.each(kindGraphic, flow, context, filter=c(filter,timef), scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview)
							}else if('each' == namet[2]){
								for(year in namet[3]:namet[4]){
									timef <- paste('year',year,sep='-')
									print(paste(flow, context, timef,sep='-'))
									generate.graphic.each(kindGraphic, flow, context, filter=c(filter, timef), scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview)
								}
							}
						}
						if('setYear'== namet[1]){
							range <- namet[! namet %in% c('setYear')]
			  			result <- getdata(generate.query(context, flow, filter=c(filter, time)))
							for(year in range){
								timef <- paste('year',year,sep='-')
								print(paste(flow, context, timef,sep='-'))
								generate.graphic.each(kindGraphic, flow, context, filter=c(filter, timef), 
									scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview, 
									maxvalue=max(table(c(result$sacronym, result$tacronym))),
									orderrow=union(result$sacronym, result$tacronym))
							}
						}
						if('year'== namet[1]){
							print(paste(flow, context, time,sep='-'))
							generate.graphic.each(kindGraphic, flow, context, filter=c(filter,time), scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview)
						}
					}
				}
				if(is.element('all-time',kindTime)){
					print(paste(flow, context, 'allTime', sep='-'))
					generate.graphic.each(kindGraphic, flow, context, filter=c(filter,'allTime'), scalegm=scalegm, scalemc=scalemc, textvalue=textvalue, mapview=mapview)
				}
		}
	}
}

##### GM,MC,MFC #####
generate.graphic.each <- function(kindGraphic, kindFlow, kindContext, filter=c(), scalemc=c('normal'), scalegm=c('equal0.1'), textvalue=FALSE, mapview=FALSE, maxvalue=FALSE, orderrow=FALSE){

	namef <- if(length(filter)>0){
		paste('-',paste(filter,collapse='-'),sep='')
	}else{
		''
	}

	imageFile <- paste(kindContext,'-',kindFlow,namef,'.png',sep='')
	print(imageFile)

  sql <- generate.query(kindContext, kindFlow, filter=filter[!filter %in% c('allTime','maxvalue')])
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

	  	for(scale in scalegm){
	  		flowsGM <- flows
	  		flowsGM$count <- convert.scale.value(flowsGM$count, scale, 'gm', 
	  				kindContext=kindContext, kindFlow=kindFlow, kindTime=ifelse(is.element('allTime',filter),'all',''))
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
	png(filename = imageFile, width=400, height=200)

	gg <- if(kindFlow == 'doutorado-all-pop-log'){
		ggplot(df, aes(x = years, y = value, colour = 'valor')) + 
			geom_line(aes(y = log(all), colour = "doutores")) + 
			geom_line(aes(y = log(population), colour = "população"))+
			xlab('anos')+ylab('quantidade')
	}else if(kindFlow == 'doutorado-all-nacional'){
		ggplot(df, aes(x = years, y = value, colour = 'valor')) + 
			geom_line(aes(y = log(all), colour = "total")) + 
			geom_line(aes(y = log(nacional), colour = "nacional"))+
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

##### PIE #####
generate.graphic.pie <- function(kindContext, kindFlow, kindPie='inout', kindNode='all', filter=c()){
	scaleValue <- c()
	df <- if(kindPie == 'inout'){
		scaleValue <- c("#00FF00", "#f1c40f")
		sql <- generate.query(kindContext, kindFlow, kindQuery='name-count', kindNode=kindNode, filter=filter)
		# cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",sql,"\n",sep=""))
		flows <- getdata(sql)
		internalFlow <- subset(flows,pid==131)$count/sum(flows$count)
		data.frame(
		  fluxo = c("externo", "interno"),
		  percentage = c(internalFlow, 1-internalFlow)
		)
	}else{
		scaleValue <- c("#0000FF", "#f1c40f", "#00FF00", "#FF0000")
		sql <- generate.query(kindContext, kindFlow, kindNode=kindNode, filter=filter)
		# cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",sql,"\n",sep=""))
		flows <- getdata(sql)
		internalFlow <- subset(flows,(sacronym=='brazil'&tacronym=='brazil'))$count/sum(flows$count)
		outFlow <- sum(subset(flows,(sacronym=='brazil'&tacronym!='brazil'))$count)/sum(flows$count)
		inFlow <- sum(subset(flows,(sacronym!='brazil'&tacronym=='brazil'))$count)/sum(flows$count)
		externalFlow <- sum(subset(flows,(sacronym!='brazil'&tacronym!='brazil'))$count)/sum(flows$count)
		data.frame(
		  fluxo = c('interno', "entrada", "saída", "externo"),
		  percentage = c(internalFlow, inFlow, outFlow, externalFlow)
		)
	}
	
	imageFile <- paste(kindPie,kindContext,kindFlow,kindNode,sep='-')
	if(length(filter)>0){imageFile <- paste(imageFile, paste(filter,collapse='-'),sep='-')}
	imageFile <- paste('./image/pie/',imageFile,'.png',sep='')
	png(filename = imageFile)

	gg <- ggplot(df, aes(x = "", y = percentage, fill = fluxo)) +
	  geom_bar(width = 1, stat = "identity")+
	  # geom_text(aes(label=paste(round(percentage*100,0),"%",sep="")))+
	  scale_fill_manual(values = scaleValue)+
	  coord_polar("y", start = 0)+
	  # ggtitle("Padrão do Movimento Global")+
	  theme(
	  	legend.position = "none",
	  	plot.title = element_text(size = rel(2)),
		  panel.background = element_blank(),
			panel.grid = element_blank(),
			panel.border = element_blank(),
			axis.ticks.x = element_blank(),
			axis.text = element_text(size = 14),
			axis.title.y = element_blank(),
			axis.title.x = element_blank(),
			plot.title = element_text(size = 16, face = "bold")
		)

	print(gg)
	dev.off()
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFile,"\n",sep=""))
}

##### bartop #####
# kindBar ('in','out','all')
generate.graphic.bartop <- function(kindContext, kindFlow, kindNode='all', filter=c(), limit=5){
	sql <- generate.query(kindContext, kindFlow, kindQuery='name-count', kindNode=kindNode, filter=filter)
	# cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",sql,"\n",sep=""))
	flows <- getdata(sql)
	flows <- subset(flows,acronym!='brazil')
	sum <- sum(flows$count)
	df <- data.frame(percentage = ceiling(flows[1:limit,]$count*100/sum), pais = flows[1:limit,]$acronym)
	print(df)
	
	# TODO
	# color <- NULL
	# color['brazil'] <- "#00FF00"
	# colornames <- color[color %in% flows[order(-flows$count),]$acronym[1:limit]]
	
	imageFile <- paste(kindContext,kindFlow,kindNode,sep='-')
	if(length(filter)>0){imageFile <- paste(imageFile, paste(filter,collapse='-'),sep='-')}
	imageFile <- paste('./image/bar/',imageFile,'.png',sep='')
	png(imageFile, 500, 200, pointsize = 12)

	gg <- ggplot(df,aes(x= pais, y= percentage, fill=pais))+
		geom_bar(stat="identity")+
		geom_text(aes(label=pais, hjust= 0))+
		coord_flip()+
	  scale_x_discrete(limits=rev(flows[order(-flows$count),]$acronym[1:limit]))+
	  # scale_fill_manual(values=colornames)+ 
	  ylim(0, 75)+
	  # ggtitle("Top 5 - Fluxo de Entrada no Brasil")+
	  theme(
	  	legend.position = "none",
	  	plot.title = element_text(size = rel(2)),
		  panel.background = element_blank(),
			panel.grid = element_blank(),
			panel.border = element_blank(),
			axis.ticks.x = element_blank(),
			axis.text = element_text(size = 14),
			axis.text.y = element_blank(),
			axis.title.y = element_blank(),
			axis.title.x = element_blank(),
			plot.title = element_text(size = 16, face = "bold")
	  )

	print(gg)
	dev.off()
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFile,"\n",sep=""))
}

##### scatterplot #####
##### histogram #####
generate.graphic.scatterplot <- function(kindContext, kindFlow, kindNode='all', filter=c()){
	sql <- generate.query(kindContext, kindFlow, kindNode=kindNode, filter=filter, kindQuery='latitude-longitude-edge:start_year-edge:end_year')
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",sql,"\n",sep=""))
	flows <- getdata(sql)
	flows.aggregate <- aggregate(list(count=rep(1,nrow(flows))), flows[,1:4], length)
	dd <- distance.flow.global(flows.aggregate)
	dd.all <- c()
	year <- c()
	# for(i in 1:nrow(flows)){
	for(i in 1:100000){
		dd.all <- c(dd.all, dd[paste(flows[i,]$slatitude,flows[i,]$slongitude,flows[i,]$tlatitude,flows[i,]$tlongitude,collapse='-')])
		year <- c(year, flows[i,]$end_year)
	}
	metrics <- data.frame(dd=dd.all,year=year)

	imageFile <- paste(kindContext,kindFlow,kindNode,sep='-')
	if(length(filter)>0){imageFile <- paste(imageFile, paste(filter,collapse='-'),sep='-')}
	
	png(paste('./image/scatterplot/',imageFile,'.png',sep=''))
	gg <- ggplot(metrics, aes(year, dd))+
		geom_point()+
		xlim(1950,2013)
	print(gg)
	dev.off()
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFile,"\n",sep=""))
	
	png(paste('./image/scatterplot/histogram',imageFile,'.png',sep=''))
	gg <- ggplot(metrics, aes(dd))+
		# geom_bar()
		geom_histogram()
		# geom_histogram(binwidth = 1)
	print(gg)
	dev.off()
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFile,"\n",sep=""))
}


###### IN/OUT graphic
generate.graphic.inoutput <- function(kindContext){
	sql <- generate.query(kindContext, 'all')
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",sql,"\n",sep=""))
  flows <- getdata(sql)
  inputPlace <- c()
  outputPlace <- c()
	for(i in 1:nrow(flows)){  
		if(!is.element(flows[i,]$tacronym,names(inputPlace)))
			inputPlace[flows[i,]$tacronym] = 0
		if(!is.element(flows[i,]$sacronym,names(outputPlace)))
			outputPlace[flows[i,]$sacronym] = 0

		inputPlace[flows[i,]$tacronym] <- inputPlace[flows[i,]$tacronym] + flows[i,]$count
		outputPlace[flows[i,]$sacronym] <- outputPlace[flows[i,]$sacronym] + flows[i,]$count
	}
	names <- union(names(inputPlace),names(outputPlace))

	inputFinal <- c()
	outputFinal <- c()
	for(i in 1:length(names)){ 
		inputFinal <- c(inputFinal, ifelse(is.element(names[i],names(inputPlace)),inputPlace[names[i]],0))
		outputFinal <- c(outputFinal, ifelse(is.element(names[i],names(outputPlace)),outputPlace[names[i]],0))
	}

	inout <- data.frame(name=names, input=log(inputFinal), output=log(outputFinal))
	linedf <- data.frame(x=c(5,15),y=c(5,15))

	png(paste('./image/scatterplot/inout-',kindContext,'-all.png',sep=''))
	gg <- ggplot(inout, aes(input, output))+
		geom_point()+
		geom_text(data=inout,aes(label=name,x=input,y=output, group=NULL),hjust=0,just=0)+
		geom_line(data=linedf,aes(x=x,y=y, group=NULL))+
		xlab('entrada')+ylab('saída')+
		xlim(5,15)+ylim(5,15)
	print(gg)
	dev.off()
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFile,"\n",sep=""))

}

