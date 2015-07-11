library(RPostgreSQL)
source('heatMapping.r')
source('flowMapping.r')
source('chordGraph.r')
source('treeMap.r')
source('generateQuery.r')

convert.scale.value <- function(data, scale, kindGraphic){
  if(scale == 'log'){
    data <- log(data)
  }
  if(scale == 'log10'){
    data <- log10(data)
  }
  if(kindGraphic == 'mc'){
  	if(scale == 'normal'){
	    data <- data
	  }	
  }
  if(kindGraphic == 'gm'){
	  if(scale == 'equal1'){
	    data <- rep(0.9,length(data))
	  }
	  if(scale == 'equal0.1'){
	    data <- rep(0,length(data))
	  }
	  if(scale == 'normal'){
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
	    data <- data/splitSize # TODO maxvalue
	  }
	}
  data
}

convert.result.todf.timeline <- function(fname, tname, value, range){
  namescol <- range[1]:range[2]
  namesrow <- unique(tname)
  mat <- matrix(0, nrow = length(namesrow), ncol = length(namescol))
  rownames(mat) <- namesrow
  colnames(mat) <- namescol
  for(i in 1:length(fname)){
    mat[tname[i],toString(fname[i])] = value[i]
  }
  from <- c()
  to <- c()
  trips <- c()
  for(i in 1:length(namesrow)){
    for(j in 1:length(namescol)){
      to <- c(to, namesrow[i])
      from <- c(from, namescol[j])
      trips <- c(trips, mat[i,j])
    }
  }
  df <- data.frame(from=from, to=to,valor=trips)
  df
}

convert.result.todf.square <- function(fname, tname, value, orderrow){
  names <- if(orderrow == FALSE)
  	union(fname,tname)
  else{
  	orderrow
  }
  mat <- matrix(0, nrow = length(names), ncol = length(names))
  rownames(mat) <- names
  colnames(mat) <- names
  for(i in 1:length(fname)){
    mat[fname[i], tname[i]] = value[i]
  }
  from <- c()
  to <- c()
  trips <- c()
  for(i in 1:nrow(mat)){
    for(j in 1:ncol(mat)){
      from <- c(from, names[i])
      to <- c(to, names[j])
      trips <- c(trips, mat[i,j])
    }
  }
  df <- data.frame(from=from, to=to,valor=trips)
  df
}

convert.result.tomatrix <- function(flows){
	names <- union(flows$oname,flows$dname)
	mat <- matrix(0, nrow = length(names), ncol = length(names))
	rownames(mat) = names
	colnames(mat) = names
	for(i in 1:nrow(flows)){
		mat[flows[i,]$oname, flows[i,]$dname] = flows[i,]$trips
	}
	mat
}

generate.graphic.each <- function(kindGraphic, kindFlow, kindContext, kindTime='all', valueTime=NULL, kindFilter=c(), kindScale=c('normal'), textvalue=FALSE, mapview=FALSE){
  print(paste(kindFlow, kindContext, kindTime,sep='-'))

  valueFilter <- c()
  if(length(kindFilter) == 0){
  	kindFilter <- ''
  }else{
	  valueFilter <- query.filter(kindFilter)
  	kindFilter <- paste('-',paste(kindFilter,sep='-'),sep='')
  }

	collection <- if(kindTime=="rangeYear"){
		valueTime[1]:valueTime[2]
	}else if(kindTime == "setYear"){
		valueTime
	}else if(kindTime == "all" | kindTime == "rangeAll"){
		'range'
	}

	for (year in collection) {
	  print(paste("year ",year,sep=""))

		imageFile <- if(kindTime == "rangeYear" | kindTime == "setYear"){
			paste(kindContext,'-',kindFlow, kindFilter,'-',year,'.png',sep='')
		}else if(kindTime == "all"){
	  	paste(kindContext,'-',kindFlow, kindFilter,'-',kindTime,'.png',sep='')
  	}else if(kindTime == "rangeAll"){
	  	paste(kindContext,'-',kindFlow, kindFilter,'-',paste(valueTime[1],'-',valueTime[2],sep=''),'.png',sep='')
  	}

	  sql <- if(kindTime == "rangeYear" | kindTime == "setYear"){
	  	generate.query(kindContext, kindFlow, 'year', year, filter=valueFilter)
	  }else if(kindTime == "all"){
  		generate.query(kindContext, kindFlow, filter=valueFilter)
  	}else if(kindTime == "rangeAll"){
  		generate.query(kindContext, kindFlow, 'range', valueTime, filter=valueFilter)
  	}

	  cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",sql,"\n",sep=""))
	  flows <- db.query(sql)
	  
	  if(length(flows)>0){
    	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",flows,"\n",sep=""))

    	if(is.element('mc',kindGraphic)){
    		for(scale in kindScale){
    			if(textvalue != FALSE){
    				imageFile <- paste('withnum',imageFile,sep='-')
  				}
    			imageFile <- paste('./image/mc/',scale,'-',imageFile,sep='')
    			
    			size <- if(kindContext == "region"){
				    c(500,450)
				  }else if(kindContext == "continent"){
				    c(600, 500)
				  }else{
				    c(1000,1000)
				  }

				  orderrow <- if(kindTime == 'setYear'){
				  	sql <- generate.query(kindContext, kindFlow, filter=query.filter(c('rangeYear'),valueTime))
	  				result <- db.query(sql)
				  	union(result$oname, result$dname)
				  }else{
				  	FALSE
				  }

    			flows$trips <- convert.scale.value(flows$trips, scale, 'mc')
				  df <- convert.result.todf.square(flows$oname, flows$dname, flows$trips, orderrow)				    
    			
    			png(filename = imageFile, width = size[1], height = size[2])

				  gg <- generate.heatmap('square', df, scale=scale,textvalue=textvalue, orderrow=orderrow)
				  
				  print(gg)
  				dev.off()
				}
    	}

    	if(is.element('mfc',kindGraphic)){
    		mat <- convert.result.tomatrix(flows)
				imageFile <- paste('./image/mfc/',imageFile,sep='')

		  	generate.chordGraph(imageFile, flows, kindContext)
		  }

		  if(is.element('gm',kindGraphic)){
		  	for(scale in kindScale){
		  		flows$trips <- convert.scale.value(flows$trips, scale, 'gm')
		  		imageFile <- paste('./image/gm/',scale,'-',imageFile,sep='')
				  if(mapview != FALSE){
				  	kindContext <- mapview
				  }
		  		width <- if(kindContext == 'region' | kindContext == 'state'){1000}else{1400}
				  height <- if(kindContext == 'region' | kindContext == 'state'){1000}else{750}
				  png(filename = imageFile, width = width, height = height)

		  		gg <- generate.flowmapping(flows, kindContext, scale=scale, points=TRUE ,textvalue=textvalue)

		  		print(gg)
  				dev.off()
		  	}
		  }
		  cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",imageFile,"\n",sep=""))
		}else{
      cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\nempty flows\n",sep=""))
    }
	}
}

# kindGraphic c('mc', 'gm', 'mfc')
# kindFlow 		c('fnf','fff','fft','ffft','all')
# kindContext c('city','state','region','country','continent')
# kindTime <- c('all', 2013, 'all-years-1973-2013','each-years-1963-2013','set-year-1973-1983-1993-2003-2013')
generate.graphic <- function(kindGraphic, kindFlow, kindContext, kindTime='', kindFilter=c(), scale=c('normal'), textvalue=FALSE, mapview=FALSE){
	if(kindTime == ''){
		kindTime <- c('all', 'set-year-1973-1983-1993-2003-2013')
	}
	 
	for(flow in kindFlow){
		for(context in kindContext){
				print(paste(flow, context, sep='-'))
				if(flow == 'fnf' | flow == 'fff'){
					if(is.element('all-years-1973-2013', kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeAll", valueTime=c(1973,2013), kindFilter=kindFilter, kindScale=scale, textvalue=textvalue, mapview=mapview)
					}
					if(is.element('each-years-1963-2013', kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(1963,2013), kindFilter=kindFilter, kindScale=scale, textvalue=textvalue, mapview=mapview)
					}
					if(is.element('set-year-1973-1983-1993-2003-2013',kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="setYear", valueTime=c(1973, 1983, 1993, 2003, 2013), kindFilter=kindFilter, kindScale=scale, textvalue=textvalue, mapview=mapview)
					}
					if(is.element(1973,kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(1973,1973), kindFilter=kindFilter, kindScale=scale, textvalue=textvalue, mapview=mapview)
					}
				}
				if(is.element('all',kindTime)){
					generate.graphic.each(kindGraphic, flow, context, kindFilter=kindFilter, kindScale=scale, textvalue=textvalue, mapview=mapview)
				}
		}
	}
}

# flowMoment (target,source,all)
generate.graphic.timeline <- function(kindContext, kindMoment, flowMoment='target', scale='normal', range=c(1950,2013), limit=10){
	sql.range <- generate.query(kindContext, kindFlow, kindQuery='name-eyear-target',kindMoment=kindMoment, flowMoment='target', scale='normal', range=c(1950,2013), limit=10)

	rn <- db.query(sql.names)
	flows <- db.query(sql.range)
	
	imageFile <- paste(limit,scale,kindContext,kindMoment,paste(range,collapse='-'),sep='-')
	imageFile <- paste('./image/tl/top',imageFile,'.png',sep='')
	flows$degree <- convert.scale.value(flows$degree, scale, 'mc')
	size <- c(1000,200)
	df <- convert.result.todf.timeline(flows$eyear, flows$place, flows$degree, range)
	png(filename = imageFile, width = size[1], height = size[2])
	gg <- generate.heatmap('timeline', df, orderrow=rev(rn$name), range=range, scale=scale)
	print(gg)
	dev.off()
}

# include (all,range)
# range (c(x,y), all, year)
# flowMoment (target,source,all)
# kindMoment (last,first,work,doutorado,graduacao,...)
# kindContext (instituition,city,...)
generate.graphic.treemap <- function(kindContext, kindMoment, flowMoment='target', range=c(1950,2013), limit=10, include='range'){
	
	query <- sql.instituition.count.rank(flowMoment, kindMoment, range, limit)
	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",query,"\n",sep=""))

	flows <- db.query(query)

	if(include == 'all'){
		flows.all <- db.query(sql.instituition.count.rank(flowMoment, kindMoment, range ,limit='none'))
		flows[nrow(flows),]$place <- 'demais'
		flows[nrow(flows),]$degree <- sum(flows.all$degree)-sum(flows$degree)
	}

	imageFile <- paste(limit,kindContext,kindMoment,flowMoment,paste(range,collapse='-'),sep='-')
	imageFile <- paste('./image/tm/rank',imageFile,'.png',sep='')

	generate.treemap(imageFile, flows)
}

generate.graphic.line <- function(kindMoment, flowMoment='target', range=c(1970,2012)){
	
	flows.all <- db.query(sql.all)
	flows.nacional <- db.query(sql.nacional)
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
}

sink("outfile.txt")
print("BEGIN")

# generate.graphic(c('mc', 'gm', 'mfc'),c('fnf','fff','fft','all'),c('state','region','continent'))
# generate.graphic(c('mc', 'gm'),c('fnf','fff','fft','all'),c('country'))
# generate.graphic(c('mfc'),c('fff'),c('country'))
# generate.graphic(c('mc'),c('fff'),c('state'),kindTime=c('all'),scale=c('normal'), textvalue=TRUE)
# generate.graphic(c('mc'),c('fff'),c('state'),kindTime=c('set-year-1973-1983-1993-2003-2013'),scale=c('log'))
# generate.graphic(c('mfc'),c('fnf','fff','fft','all'),c('country'))
# generate.graphic(c('mfc'),c('fff'),c('country'),kindTime=c('all'), kindFilter=c('excludeAllBrazilFlows'))
# generate.graphic(c('mfc'),c('fff'),c('country'),kindTime=c('all'), kindFilter=c('excludeFlowsInBrazil'))
# generate.graphic(c('gm'),c('all'),c('city'),kindTime=c('all'), scale=c('equal0.1'))
# generate.graphic(c('gm'),c('ffft'),c('instituition'),kindTime=c('all'), kindFilter=c('topDegreeInst'), scale=c('equal0.1'), mapview='state', textvalue=TRUE)
# generate.graphic(c('gm'),c('all'),c('city'),kindTime=c('all'), kindFilter=c('specificPerson-1982919735990024'), scale=c('equal0.1')) # Alexandre
# generate.graphic(c('gm'),c('all'),c('city'),kindTime=c('all'), kindFilter=c('groupPeople-pqComp'), scale=c('equal0.1'))
# generate.graphic(c('mc', 'gm', 'mfc'),c('fff'),c('country'),kindFilter=c('doutorado'))
# generate.graphic(c('gm'),c('fff'),c('instituition'),kindTime=c('all'),kindFilter=c('to-doutorado-USP','to-doutorado-UFPE','from-doutorado-USP','from-doutorado-UFPE'), scale=c('equal0.1'))

# generate.graphic.timeline('instituition','doutorado')
# generate.graphic.timeline('instituition','doutorado',scale='log')
generate.graphic.timeline('city','doutorado',scale='log')

# generate.graphic.treemap('instituition','doutorado')
# generate.graphic.treemap('instituition','doutorado',flowMoment='source', limit=50)
# generate.graphic.treemap('instituition','doutorado',flowMoment='all',limit=50)
# generate.graphic.treemap('instituition','doutorado',flowMoment='target',limit=50,include='all')
# generate.graphic.treemap('instituition','first',flowMoment='target',limit=50)
# generate.graphic.treemap('instituition','last',flowMoment='source', limit=50)

# generate.graphic.line('doutorado')
# generate.graphic.line('doutorado-all-nacional')
# generate.graphic.line('doutorado-all-pop-log')

# print(generate.query('country','fft'))
# print(generate.query('region','fnf', 'range', c(1950,2013)))
# print(generate.query('region','fnf', 'year', 2013))
# print(generate.specific.from('continent', 'source', TRUE, FALSE))
# print(generate.specific.where('continent', 'source', TRUE, TRUE))
print("END")
sink()
