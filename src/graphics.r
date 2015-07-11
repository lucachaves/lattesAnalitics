library(RPostgreSQL)
source('heatMapping.r')
source('flowMapping.r')
source('chordGraph.r')
source('treeMap.r')
source('generateQuery.r')

db.get.connection <- function(drv){
	dbConnect(drv, dbname="mobilitygraph",host="192.168.56.101",port=5432,user="postgres",password="postgres")
}

sql.inst.inst.nacional <- "SELECT edge.id FROM PUBLIC.edge edge, PUBLIC.place instituitionSource, PUBLIC.place citySource, PUBLIC.place stateSource, PUBLIC.place regionSource, PUBLIC.place countrySource, PUBLIC.place instituitionTarget, PUBLIC.place cityTarget, PUBLIC.place stateTarget, PUBLIC.place regionTarget, PUBLIC.place countryTarget WHERE edge.source = instituitionSource.id AND instituitionSource.kind = 'instituition' AND instituitionSource.belong_to = citySource.id AND citySource.kind = 'city' AND citySource.belong_to = stateSource.id AND stateSource.kind = 'state' AND stateSource.belong_to = regionSource.id AND regionSource.kind = 'region' AND regionSource.belong_to = countrySource.id AND countrySource.kind = 'country' AND countrySource.id = 131 AND edge.target = instituitionTarget.id AND instituitionTarget.kind = 'instituition' AND instituitionTarget.belong_to = cityTarget.id AND cityTarget.kind = 'city' AND cityTarget.belong_to = stateTarget.id AND stateTarget.kind = 'state' AND stateTarget.belong_to = regionTarget.id AND regionTarget.kind = 'region' AND regionTarget.belong_to = countryTarget.id AND countryTarget.kind = 'country' AND countryTarget.id = 131"
sql.city.inst.nacional <- "SELECT edge.id FROM PUBLIC.edge edge, PUBLIC.place citySource, PUBLIC.place stateSource, PUBLIC.place regionSource, PUBLIC.place countrySource, PUBLIC.place instituitionTarget, PUBLIC.place cityTarget, PUBLIC.place stateTarget, PUBLIC.place regionTarget, PUBLIC.place countryTarget WHERE edge.source = citySource.id AND citySource.kind = 'city' AND citySource.belong_to = stateSource.id AND stateSource.kind = 'state' AND stateSource.belong_to = regionSource.id AND regionSource.kind = 'region' AND regionSource.belong_to = countrySource.id AND countrySource.kind = 'country' AND countrySource.id = 131 AND edge.target = instituitionTarget.id AND instituitionTarget.kind = 'instituition' AND instituitionTarget.belong_to = cityTarget.id AND cityTarget.kind = 'city' AND cityTarget.belong_to = stateTarget.id AND stateTarget.kind = 'state' AND stateTarget.belong_to = regionTarget.id AND regionTarget.kind = 'region' AND regionTarget.belong_to = countryTarget.id AND countryTarget.kind = 'country' AND countryTarget.id = 131"
sql.top10.degree.inst <- "SELECT id FROM (SELECT edge.target id FROM edge, place WHERE edge.target=place.id AND place.kind='instituition' UNION ALL SELECT edge.source id FROM edge, place WHERE edge.source=place.id AND place.kind='instituition') ids GROUP BY id ORDER BY count(id) DESC LIMIT 10"

generate.graphic.each <- function(kindGraphic, kindFlow, kindContext, kindTime='all', valueTime=NULL, kindFilter=c(), kindScale=c('normal')){
  print(paste(kindFlow, kindContext, kindTime,sep='-'))

  drv <- dbDriver("PostgreSQL")
  con <- db.get.connection(drv)

  valueFilter <- c()
  print(length(kindFilter))
  if(length(kindFilter) == 0){
  	kindFilter <- ''
  }else{
	  if(is.element('doutorado',kindFilter)){
	  	valueFilter <- c(valueFilter, "edge.kind='doutorado'")
	  }
	  if(is.element('to-doutorado-USP',kindFilter)){
	  	valueFilter <- c(valueFilter, "edge.kind='doutorado' AND instituitionTarget.id = 179")
	  }
	  if(is.element('from-doutorado-USP',kindFilter)){
	  	valueFilter <- c(valueFilter, "edge.kind='doutorado' AND instituitionSource.id = 179")
	  }
	  if(is.element('to-doutorado-UFPE',kindFilter)){
	  	valueFilter <- c(valueFilter, "edge.kind='doutorado' AND instituitionTarget.id = 588")
	  }
	  if(is.element('from-doutorado-UFPE',kindFilter)){
	  	valueFilter <- c(valueFilter, "edge.kind='doutorado' AND instituitionSource.id = 588")
	  }
	  if(is.element('excludeAllBrazilFlows',kindFilter)){
	  	valueFilter <- c(valueFilter, "(countrySource.id != 131 AND countryTarget.id != 131)")
	  }
	  if(is.element('excludeFlowsInBrazil',kindFilter)){
	  	valueFilter <- c(valueFilter, paste("edge.id NOT IN (",sql.inst.inst.nacional,") AND edge.id NOT IN (",sql.city.inst.nacional,")",sep=''))
	  }
	  if(is.element('onlyFlowsInBrazil',kindFilter)){
	  	valueFilter <- c(valueFilter, paste("edge.id IN (",sql.inst.inst.nacional," UNION",sql.city.inst.nacional,")",sep=''))
	  }
	  if(is.element('topDegreeInst',kindFilter)){
	  	valueFilter <- c(valueFilter, paste("instituitionSource.id IN (",sql.top10.degree.inst,") AND instituitionTarget.id IN (",sql.top10.degree.inst,")",sep=''))
	  }
	  for(filter in kindFilter){
	  	if(unlist(strsplit(filter,'-'))[1] == 'specificPerson'){
		  	valueFilter <- c(valueFilter, paste("edge.id16='",unlist(strsplit(filter,'-'))[2],"'",sep=''))
		  }
	  	# TODO FILE http://plsql1.cnpq.br/divulg/RESULTADO_PQ_102003.prc_comp_cmt_links?V_COD_DEMANDA=200310&V_TPO_RESULT=CURSO&V_COD_AREA_CONHEC=10300007&V_COD_CMT_ASSESSOR=CC
	  	if(unlist(strsplit(filter,'-'))[1] == 'groupPeople'){
	  		groupFile <- paste('./data/',unlist(strsplit(filter,'-'))[2],'.csv',sep= '')
		  	group <- read.table(groupFile, header=TRUE, quote="\'")
		  	groupIds <-  paste(group$id16,collapse=',')
		  	valueFilter <- c(valueFilter, paste("edge.id16 IN (",groupIds,")",sep=''))
		  }
	  }
  	kindFilter <- paste('-',paste(kindFilter,sep='-'),sep='')
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
			  for(scale in kindScale){
			  	generate.mc.square(imageFile, flows, kindContext, scale=scale)
			  }
    	}
    	if(is.element('mfc',kindGraphic)){
		  	generate.mfc(imageFile, flows, kindContext)
		  }
		  if(is.element('gm',kindGraphic)){
		  	for(scale in kindScale){
		  		generate.gm(imageFile, flows, kindFlow, kindContext, kindTime, scale=scale, points=TRUE ,texts=TRUE)
		  	}
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
      		for(scale in kindScale){
					  generate.mc.square(imageFile, flows, kindContext, scale=scale)
					}
      	}
      	if(is.element('mfc',kindGraphic)){
			  	generate.mfc(imageFile, flows, kindContext)
			  }
			  if(is.element('gm',kindGraphic)){
			  	for(scale in kindScale){
			  		generate.gm(imageFile, flows, kindFlow, kindContext, kindTime, scale=scale, points=TRUE ,texts=TRUE)
			  	}
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
# kindTime <- c('rangeAll-1973-2013','rangeYear-1963-2013','all', 1973, 1983, 1993, 2003, 2013)
generate.graphic <- function(kindGraphic, kindFlow, kindContext, kindTime='', kindFilter=c(),scale=c('normal')){
	sink("outfile.txt")
	print("BEGIN")

	if(kindTime == ''){
		kindTime <- c('all', 1973, 1983, 1993, 2003, 2013)
	}
	 
	for(flow in kindFlow){
		for(context in kindContext){
				print(paste(flow, context, sep='-'))
				if(flow == 'fnf' | flow == 'fff'){
					if(is.element('rangeAll-1973-2013', kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeAll", valueTime=c(1973,2013), kindFilter=kindFilter, kindScale=scale)
					}
					if(is.element('rangeYear-1963-2013', kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(1963,2013), kindFilter=kindFilter, kindScale=scale)
					}
					if(is.element(1973,kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(1973,1973), kindFilter=kindFilter, kindScale=scale)
					}
					if(is.element(1983,kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(1983,1983), kindFilter=kindFilter, kindScale=scale)
					}
					if(is.element(1993,kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(1993,1993), kindFilter=kindFilter, kindScale=scale)
					}
					if(is.element(2003,kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(2003,2003), kindFilter=kindFilter, kindScale=scale)
					}
					if(is.element(2013,kindTime)){
						generate.graphic.each(kindGraphic, flow, context, kindTime="rangeYear", valueTime=c(2013,2013), kindFilter=kindFilter, kindScale=scale)
					}
				}
				if(is.element('all',kindTime)){
					generate.graphic.each(kindGraphic, flow, context, kindFilter=kindFilter, kindScale=scale)
				}
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

generate.graphic.line <- function(kindMoment, flowMoment='target', range=c(1970,2012)){
	drv <- dbDriver("PostgreSQL")
	con <- db.get.connection(drv)

	sql.all <- paste("SELECT edge.end_year eyear, count(*) count FROM public.edge WHERE edge.kind = 'doutorado' AND edge.end_year BETWEEN ",range[1]," AND ", range[2]," GROUP BY eyear ORDER BY eyear",sep='')
	sql.nacional <- paste("SELECT edge.end_year eyear, count(*) count FROM public.edge WHERE edge.kind = 'doutorado' AND edge.end_year BETWEEN ",range[1]," AND ", range[2]," AND edge.id IN (",sql.inst.inst.nacional," UNION ",sql.city.inst.nacional,") GROUP BY eyear ORDER BY eyear",sep='')

	rs <- dbSendQuery(con,sql.all)
	flows.all <- fetch(rs,n=-1)

	rs <- dbSendQuery(con,sql.nacional)
	flows.nacional <- fetch(rs,n=-1)

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

	dbDisconnect(con)
	dbUnloadDriver(drv)
}

# generate.graphic(c('mc', 'gm', 'mfc'),c('fnf','fff','fft','all'),c('state','region','continent'))
# generate.graphic(c('mc', 'gm'),c('fnf','fff','fft','all'),c('country'))
# generate.graphic(c('mfc'),c('fff'),c('country'))
# generate.graphic(c('mfc'),c('fnf','fff','fft','all'),c('country'))
# generate.graphic(c('mfc'),c('fff'),c('country'),kindTime=c('all'), kindFilter=c('excludeAllBrazilFlows'))
# generate.graphic(c('mfc'),c('fff'),c('country'),kindTime=c('all'), kindFilter=c('excludeFlowsInBrazil'))
# generate.graphic(c('gm'),c('all'),c('city'),kindTime=c('all'), scale=c('equal0.1'))
generate.graphic(c('gm'),c('ffft'),c('instituition'),kindTime=c('all'), kindFilter=c('topDegreeInst'), scale=c('equal0.1'))
# generate.graphic(c('gm'),c('all'),c('city'),kindTime=c('all'), kindFilter=c('specificPerson-1982919735990024'), scale=c('equal0.1')) # Alexandre
# generate.graphic(c('gm'),c('all'),c('city'),kindTime=c('all'), kindFilter=c('groupPeople-pqComp'), scale=c('equal0.1'))
# generate.graphic(c('mc', 'gm', 'mfc'),c('fff'),c('country'),kindFilter=c('doutorado'))
# generate.graphic(c('gm'),c('fff'),c('instituition'),kindTime=c('all'),kindFilter=c('to-doutorado-USP','to-doutorado-UFPE','from-doutorado-USP','from-doutorado-UFPE'), scale=c('equal0.1'))
# generate.graphic.timeline('instituition','doutorado')
# generate.graphic.timeline('instituition','doutorado',scale='log')
# generate.graphic.treemap('instituition','doutorado')
# generate.graphic.treemap('instituition','doutorado',limit=50)
# generate.graphic.line('doutorado')
# generate.graphic.line('doutorado-all-nacional')
# generate.graphic.line('doutorado-all-pop-log')

# print(generate.query('country','fft'))
# print(generate.query('region','fnf', 'range', c(1950,2013)))
# print(generate.query('region','fnf', 'year', 2013))
# print(generate.specific.from('continent', 'source', TRUE, FALSE))
# print(generate.specific.where('continent', 'source', TRUE, TRUE))

####### TODO #######
# rank de onde vamos no exterior na formacao de doutorado (gráfico de barra?!)
# calcular as métricas de mobilidade: DD, ID
# dump mobilitygraph
# pegar código dos gráficos que já foram usados na dissertação
# cap2: 3 gephi
# hm-fff-state/continent (number)
# tm-cidade
# mfc-fff-state
# 6 graphics
# treemap: incluindo os demais
# gerar arquivos para o gephi

# calcular outras métricas de sna para comprar MMP: api gephi or igraph
# pegar ids dePQs de computação e comparar seu DD com a média global
# outros gráficos que estao no lattesGephi
# concentrar o scale
# filter: graduacao,doutorado...
# graduacao: source,target, out/in
# analisar a importancia do start_year
# suprir todos os gráficos da dissertação
# custom filter
# validate generateQuery
# siglas
# custom title

######## MC ########
# same size comparator
# colocar número

######## GM ########
# point
# same color (point edge)
# loop
# splitSize
# theme (white,black)
# aresta afinando para o destino

######## MFC ########
# ordem
# color: instituition?
