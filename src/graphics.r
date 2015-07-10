library(RPostgreSQL)
source('heatMapping.r')
source('flowMapping.r')
source('chordGraph.r')
source('treeMap.r')
source('generateQuery.r')

db.get.connection <- function(drv){
	dbConnect(drv, dbname="mobilitygraph",host="192.168.56.101",port=5432,user="postgres",password="postgres")
}

generate.graphic.each <- function(kindGraphic, kindFlow, kindContext, kindTime='all', valueTime=NULL, kindFilter=''){
  print(paste(kindFlow, kindContext, kindTime,sep='-'))

  drv <- dbDriver("PostgreSQL")
  con <- db.get.connection(drv)

  # TODO graduacao,doutorado...
  valueFilter <- c()
  if(kindFilter == 'doutorado'){
  	valueFilter <- c(valueFilter, "edge.kind='doutorado'")
  	kindFilter <- paste('-',kindFilter,sep='')
  }

  if(kindTime == "all" | kindTime == "rangeAll"){
	  
	  imageFile <- if(kindTime == "all"){
	  	paste(kindContext,'-',kindFlow, kindFilter,'-',kindTime,'.png',sep='')
  	}else if(kindTime == "rangeAll"){
	  	paste(kindContext,'-',kindFlow, kindFilter,'-',paste(valueTime[1],'-',valueTime[2],sep=''),'.png',sep='')
  	}
  	sql <- if(kindTime == "all"){
  		generate.query(kindContext, kindFlow, filter=valueFilter)
  	}else if(kindTime == "rangeAll"){
  		generate.query(kindContext, kindFlow, 'range', valueTime, filter=valueFilter)
  	}
  	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",sql,"\n",sep=""))

  	rs <- dbSendQuery(con,sql)
  	flows <- fetch(rs,n=-1)

  	if(length(flows)>0){
      cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",flows,"\n",sep=""))
	  	if(is.element('mc',kindGraphic)){
			  generate.mc(imageFile, flows, kindContext, 'normal')
			  generate.mc(imageFile, flows, kindContext, 'log')
    	}
    	if(is.element('mfc',kindGraphic)){
		  	generate.mfc(imageFile, flows, kindContext)
		  }
		  if(is.element('gm',kindGraphic)){
		  	generate.gm(imageFile, flows, 'white', kindFlow, kindContext, kindTime)
		  }
	 	}else{
      cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\nempty flows\n",sep=""))
    }	 	

	}else if(kindTime == "rangeYear"){

		for (year in valueTime[1]:valueTime[2]) {
		  print(paste("year ",year,sep=""))

			imageFile <- paste(kindContext,'-',kindFlow, kindFilter,'-',year,'.png',sep='')
		  
		  sql <- generate.query(kindContext, kindFlow, 'year', year, filter=valueFilter)
		  cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",sql,"\n",sep=""))
		  rs <- dbSendQuery(con,sql)
		  flows <- fetch(rs,n=-1)
		  
		  if(length(flows)>0){
      	cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\n",flows,"\n",sep=""))
      	if(is.element('mc',kindGraphic)){
				  generate.mc.square(imageFile, flows, kindContext, 'normal')
				  generate.mc.square(imageFile, flows, kindContext, 'log')
      	}
      	if(is.element('mfc',kindGraphic)){
			  	generate.mfc(imageFile, flows, kindContext)
			  }
			  if(is.element('gm',kindGraphic)){
			  	generate.gm(imageFile, flows, 'white', kindFlow, kindContext, kindTime)
			  }
			}else{
	      cat(paste(format(Sys.time(), ">>>> %d/%m/%Y %X"),"\nempty flows\n",sep=""))
	    }

		}
	}

	dbDisconnect(con)
  dbUnloadDriver(drv)
}

# kindGraphic c('mc', 'gm', 'mfc')
# kindFlow 		c('fnf','fff','fft','all')
# kindContext c('city','state','region','country','continent')
generate.graphic <- function(kindGraphic, kindFlow, kindContext,kindFilter=''){
	sink("outfile.txt")
	print("BEGIN")
	 
	for(flow in kindFlow){
		for(context in kindContext){
				print(paste(flow, context, sep='-'))
				if(flow == 'fnf' | flow == 'fff'){
					# generate.graphic.each(kindGraphic, flow, context, kindTime="rangeAll", valueTime=c(1973,2013), kindFilter=kindFilter)
					# generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(1963,2013), kindFilter=kindFilter)
					generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(1973,1973), kindFilter=kindFilter)
					generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(1983,1983), kindFilter=kindFilter)
					generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(1993,1993), kindFilter=kindFilter)
					generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(2003,2003), kindFilter=kindFilter)
					generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(2013,2013), kindFilter=kindFilter)
				}
				# generate.graphic.each(kindGraphic, flow, context, kindFilter=kindFilter)
		}
	}

	print("END")
	sink()
}

generate.graphic.timeline <- function(kindContext, kindMoment, flowMoment='target', scale='normal', range=c(1950,2013), limit=10){

	drv <- dbDriver("PostgreSQL")
	con <- db.get.connection(drv)

	sql.ids <- ''
	sql.names <- ''
	sql.instituition.doutorado.target.names <- paste("SELECT place.acronym as name FROM public.edge, public.place WHERE edge.target = place.id AND edge.kind = 'doutorado' AND place.kind = 'instituition' GROUP BY place.id ORDER BY count(place) DESC LIMIT",limit)
	sql.instituition.doutorado.target.ids <- paste("SELECT place.id FROM public.edge, public.place WHERE edge.target = place.id AND edge.kind = 'doutorado' AND place.kind = 'instituition' GROUP BY place.id ORDER BY count(place) DESC LIMIT",limit)
	# sql.city.doutorado.target.names <- paste("SELECT place.acronym as name FROM public.edge, public.place WHERE edge.target = place.id AND edge.kind = 'doutorado' AND place.kind = 'instituition' GROUP BY place.id ORDER BY count(place) DESC LIMIT",limit)
	# sql.city.doutorado.target.ides <- paste("SELECT place.id FROM public.edge, public.place WHERE edge.target = place.id AND edge.kind = 'doutorado' AND place.kind = 'instituition' GROUP BY place.id ORDER BY count(place) DESC LIMIT",limit)

	if(kindContext == 'instituition' & kindMoment == 'doutorado' & flowMoment == 'target'){
		sql.ids <- sql.instituition.doutorado.target.ids
		sql.names <- sql.instituition.doutorado.target.names
	}
		
	sql.range <- paste("SELECT place.acronym place, edge.end_year eyear, count(*) degree FROM public.edge, public.place WHERE edge.end_year BETWEEN ",range[1]," AND ", range[2]," AND edge.target = place.id AND place.id in (",sql.ids,") AND place.kind = 'instituition' AND edge.kind = 'doutorado' GROUP BY place, eyear ORDER BY place, eyear",sep='')

	rs <- dbSendQuery(con, sql.names)
	rn <- fetch(rs,n=-1)
	rs <- dbSendQuery(con, sql.range)
	flows <- fetch(rs,n=-1)

	imageFile <- paste(limit,kindContext,kindMoment,paste(range,collapse='-'),scale,sep='-')
	imageFile <- paste('./image/tl/top',imageFile,'.png',sep='')
	generate.mc.timeline(imageFile, flows, rev(rn$name), range, scale=scale)

	dbDisconnect(con)
	dbUnloadDriver(drv)

}

generate.graphic.treemap <- function(kindContext, kindMoment, flowMoment='target', range=c(1950,2013), limit=10){
	drv <- dbDriver("PostgreSQL")
	con <- db.get.connection(drv)
	# TODO incluindo os demais
	sql <- if(kindContext == 'instituition' & kindMoment == 'doutorado' & flowMoment == 'target'){
	 paste("SELECT place.acronym place, count(*) degree FROM public.edge, public.place WHERE edge.end_year BETWEEN ",range[1]," AND ", range[2]," AND edge.target = place.id AND place.kind = 'instituition' GROUP BY place ORDER BY degree DESC LIMIT ",limit)
	}
	rs <- dbSendQuery(con,sql)
	flows <- fetch(rs,n=-1)

	imageFile <- paste(limit,kindContext,kindMoment,flowMoment,paste(range,collapse='-'),sep='-')
	imageFile <- paste('./image/tm/rank',imageFile,'.png',sep='')

	generate.graphic.tm(imageFile, flows)

	dbDisconnect(con)
	dbUnloadDriver(drv)
}

generate.graphic.line <- function(kindMoment, flowMoment='target', range=c(1950,2013)){
	drv <- dbDriver("PostgreSQL")
	con <- db.get.connection(drv)

	sql <- paste("SELECT edge.end_year eyear, count(*) count FROM public.edge WHERE edge.kind = 'doutorado' AND edge.end_year BETWEEN ",range[1]," AND ", range[2]," GROUP BY eyear ORDER BY eyear",sep='')

	# TODO add crescimento brasil
	rs <- dbSendQuery(con,sql)
	flows <- fetch(rs,n=-1)

	imageFile <- paste(kindMoment,flowMoment,paste(range,collapse='-'),sep='-')
	imageFile <- paste('./image/tm/line',imageFile,'.png',sep='')

	# TODO graph

	dbDisconnect(con)
	dbUnloadDriver(drv)
}

# generate.graphic(c('mc', 'gm', 'mfc'),c('fnf','fff','fft','all'),c('state','region','country','continent'))
# generate.graphic(c('mfc'),c('fff'),c('country'))
generate.graphic(c('mfc'),c('fff'),c('country'),kindFilter='doutorado')
# generate.graphic(c('mc', 'gm', 'mfc'),c('fff'),c('country'),kindFilter='doutorado')
# generate.graphic(c('mfc'),c('fnf','fff','fft','all'),c('country'))
# generate.graphic.timeline('instituition','doutorado')
# generate.graphic.timeline('instituition','doutorado',scale='log')
# generate.graphic.treemap('instituition','doutorado')
# generate.graphic.treemap('instituition','doutorado',limit=50)
# generate.graphic.line('doutorado')

# print(generate.query('continent','fff'))
# print(generate.query('continent','fnf'))
# print(generate.query('continent','fft'))
# print(generate.query('continent','all'))
# print(generate.query('country','fft'))
# print(generate.query('country','all'))
# print(generate.query('city','fnf'))
# print(generate.query('state','fnf'))
# print(generate.query('region','fnf'))
# print(generate.query('region','fnf'))
# print(generate.query('region','fnf', 'range', c(1950,2013)))
# print(generate.query('region','fnf', 'year', 2013))
# print(generate.specific.from('continent', 'source', TRUE, FALSE))
# print(generate.specific.from('continent', 'source', TRUE, TRUE))
# print(generate.specific.where('continent', 'source', TRUE, TRUE))

####### TODO #######
# siglas
# validate generateQuery
# custom filter
# nacional/foreign
# outros gráficos que estao no lattesGephi
# linha - evolução do número de doutores 
# dump mobilitygraph
# rank de onde vamos no exterior

######## MC ########
# same comparator size
# colocar número

######## GM ########
# point
# same color (point edge)
# loop
# splitSize / log scale
# custom title
# theme (white,black)

######## MFC ########
# ordem
