library(Hmisc)

# TODO identificar em qualquer contexto o que e nacional
sql.inst.inst.nacional <- "SELECT edge.id FROM PUBLIC.edge edge, PUBLIC.place instituitionSource, PUBLIC.place citySource, PUBLIC.place stateSource, PUBLIC.place regionSource, PUBLIC.place countrySource, PUBLIC.place instituitionTarget, PUBLIC.place cityTarget, PUBLIC.place stateTarget, PUBLIC.place regionTarget, PUBLIC.place countryTarget WHERE edge.source = instituitionSource.id AND instituitionSource.kind = 'instituition' AND instituitionSource.belong_to = citySource.id AND citySource.kind = 'city' AND citySource.belong_to = stateSource.id AND stateSource.kind = 'state' AND stateSource.belong_to = regionSource.id AND regionSource.kind = 'region' AND regionSource.belong_to = countrySource.id AND countrySource.kind = 'country' AND countrySource.id = 131 AND edge.target = instituitionTarget.id AND instituitionTarget.kind = 'instituition' AND instituitionTarget.belong_to = cityTarget.id AND cityTarget.kind = 'city' AND cityTarget.belong_to = stateTarget.id AND stateTarget.kind = 'state' AND stateTarget.belong_to = regionTarget.id AND regionTarget.kind = 'region' AND regionTarget.belong_to = countryTarget.id AND countryTarget.kind = 'country' AND countryTarget.id = 131"
sql.city.inst.nacional <- "SELECT edge.id FROM PUBLIC.edge edge, PUBLIC.place citySource, PUBLIC.place stateSource, PUBLIC.place regionSource, PUBLIC.place countrySource, PUBLIC.place instituitionTarget, PUBLIC.place cityTarget, PUBLIC.place stateTarget, PUBLIC.place regionTarget, PUBLIC.place countryTarget WHERE edge.source = citySource.id AND citySource.kind = 'city' AND citySource.belong_to = stateSource.id AND stateSource.kind = 'state' AND stateSource.belong_to = regionSource.id AND regionSource.kind = 'region' AND regionSource.belong_to = countrySource.id AND countrySource.kind = 'country' AND countrySource.id = 131 AND edge.target = instituitionTarget.id AND instituitionTarget.kind = 'instituition' AND instituitionTarget.belong_to = cityTarget.id AND cityTarget.kind = 'city' AND cityTarget.belong_to = stateTarget.id AND stateTarget.kind = 'state' AND stateTarget.belong_to = regionTarget.id AND regionTarget.kind = 'region' AND regionTarget.belong_to = countryTarget.id AND countryTarget.kind = 'country' AND countryTarget.id = 131"

getdata <- function(sql){
	drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname="mobilitygraph",host="192.168.56.101",port=5432,user="postgres",password="postgres")
  rs <- dbSendQuery(con,sql)
	rows <- fetch(rs,n=-1)
  dbDisconnect(con)
  dbUnloadDriver(drv)
  rows
}


generate.flow <- function(nacional, instituition){
	order <- NULL
	if(instituition){
		if(nacional){
			order <- c('instituition', 'city', 'state', 'region', 'country', 'continent')
		}else{
			order <- c('instituition', 'city', 'country', 'continent')
		}	
	}else{
		if(nacional){
			order <- c('city', 'state', 'region', 'country', 'continent')
		}else{
			order <- c('city', 'country', 'continent')
		}	
	}
	order
}

generate.specific.select <- function(kindQuery, kindContext){
	if(kindQuery == 'name-lat-lon-source-target'){
		paste(
			"SELECT ",
			kindContext,
			"Source.acronym oname, ",
			kindContext,
			"Source.latitude oy, ",
			kindContext,
			"Source.longitude ox, ",
			kindContext,
			"Target.acronym dname, ",
			kindContext,
			"Target.latitude dy, ",
			kindContext,
			"Target.longitude dx",
			sep=''
		)
	}
}

generate.specific.from <- function(kindContext, destination, nacional, instituition){
	order <- generate.flow(nacional, instituition)
	
	from <- ''
	for(i in order){
		from <- paste(from,paste('public.place ',i,capitalize(destination),sep=''),sep=', ')
		if(i == kindContext){
			break;
		}
	}
	from
}

generate.specific.where <- function(kindContext, destination, nacional, instituition){
	order <- generate.flow(nacional, instituition)	
	where <- paste("edge.",destination," = ",sep='')
	for(i in order){
		where <- paste(where,i,capitalize(destination),".id AND ",i,capitalize(destination),".kind ='",i,"'",sep='')
		if(i == kindContext){
			break;
		}
		where <- paste(where," AND ",i,capitalize(destination),".belong_to = ",sep='')
	}
	where
}

generate.specific.query <- function(kindContext, nacionalSource, instituitionSource, nacionalTarget, instituitionTarget, filter, kindQuery){
	specific.select <- generate.specific.select(kindQuery, kindContext)
	specific.from <- paste(
		"FROM ",
		"public.edge edge",
		generate.specific.from(kindContext, 'source', nacionalSource, instituitionSource),
		generate.specific.from(kindContext, 'target', nacionalTarget, instituitionTarget),
		sep=' '
	)
	where <- "WHERE"
	if(length(filter)!=0){
		where <- paste(where, paste(filter, collapse=' AND '),' AND ',sep=' ')
	}
	specific.where <- paste(
		where,
		generate.specific.where(kindContext, 'source', nacionalSource, instituitionSource),
		' AND ',
		generate.specific.where(kindContext, 'target', nacionalTarget, instituitionTarget),
		sep=' '
	)
	
	paste(specific.select, specific.from, specific.where, sep= ' ')
}

generate.all.query <- function(kindContext, kindFlow, kindTime, valueTime, global, filter=c(), kindQuery='name-lat-lon-source-target'){
	if(kindContext == 'region' | kindContext == 'state'){
		global <- FALSE
	}
	
	if(kindTime == 'range'){
		filter <- c(filter, paste("edge.end_year BETWEEN ",valueTime[1]," AND ",valueTime[2],sep=''))
	}else if(kindTime == 'year'){
		filter <- c(filter, paste("edge.end_year = ",valueTime,sep=''))
	}


	union <- ''
	if(kindFlow == 'fnf'){
		if(global){
			union <- paste(
				generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,TRUE,FALSE,FALSE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,FALSE,TRUE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,FALSE,FALSE,TRUE,filter,kindQuery),
				sep=' '
			)	
		}else{
			union <- generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE,filter,kindQuery)
		}
	}else if(kindFlow == 'fff' | kindFlow == 'fft' | kindFlow == 'ffft'){
		if(kindFlow == 'fff'){
			filter <- c(filter,"edge.kind != 'work'")
		}else if(kindFlow == 'fft'){
			filter <- c(filter, "edge.kind = 'work'")
		}
		if(global){
			union <- paste(
				generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,TRUE,TRUE,FALSE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,TRUE,TRUE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,TRUE,FALSE,TRUE,filter,kindQuery),
				sep=' '
			)
			}else{
				union <- generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter,kindQuery)
			}
	}else if(kindFlow == 'all'){
		if(global){
			union <- paste(
				generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,TRUE,FALSE,FALSE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,FALSE,TRUE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,FALSE,FALSE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,TRUE,TRUE,FALSE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,TRUE,TRUE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,TRUE,FALSE,TRUE,filter,kindQuery),
				sep=' '
			)
		}else{
			union <- paste(
				generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE,filter,kindQuery),
				'UNION ALL',
				generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter,kindQuery),
				sep=' '
			)
		}
	}
	union
}

generate.query <- function(kindContext, kindFlow, kindTime='all', valueTime=NULL, global=TRUE, filter=c(), kindMoment='', flowMoment='target', range=c(1950,2013), limit=10, valuename=FALSE, kindQuery='name-lat-lon-source-target'){
	if(kindQuery == 'name-lat-lon-source-target'){
		global.select <- "SELECT row_number() OVER () as id, oname, oy, ox, dname, dy, dx, count(*) trips"
		global.from <- paste("FROM (", generate.all.query(kindContext, kindFlow, kindTime, valueTime, global,filter=filter,kindQuery=kindQuery),") flow",sep='')
		global.group <- "GROUP BY oy, ox, oname, dx, dy, dname"
		global.order <- "ORDER BY oname, dname"
		paste(
			global.select,
			global.from,
			global.group,
			global.order,
			sep=' '
		)
	}else if(kindQuery == 'name-eyear-target'){
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
		if(valuename == FALSE){
			paste("SELECT place.acronym place, edge.end_year eyear, count(*) degree FROM public.edge, public.place WHERE edge.end_year BETWEEN ",range[1]," AND ", range[2]," AND edge.target = place.id AND place.id in (",sql.ids,") AND place.kind = 'instituition' AND edge.kind = 'doutorado' GROUP BY place, eyear ORDER BY place, eyear",sep='')
		}else{
			sql.names
		}
			
	}else if(kindQuery == 'name-count-'){
		sql.instituition.count.rank(kindContext, flowMoment, kindMoment, range, limit)
	}else if(kindQuery == 'eyear-count-doutorado-all'){
		paste("SELECT edge.end_year eyear, count(*) count FROM public.edge WHERE edge.kind = 'doutorado' AND edge.end_year BETWEEN ",range[1]," AND ", range[2]," GROUP BY eyear ORDER BY eyear",sep='')
	}else if(kindQuery == 'eyear-count-doutorado-nacional'){
		paste("SELECT edge.end_year eyear, count(*) count FROM public.edge WHERE edge.kind = 'doutorado' AND edge.end_year BETWEEN ",range[1]," AND ", range[2]," AND edge.id IN (",sql.inst.inst.nacional," UNION ",sql.city.inst.nacional,") GROUP BY eyear ORDER BY eyear",sep='')
	}
}

sql.instituition.count <- function(flowMoment, kindMoment, range){
	paste("SELECT place.acronym place FROM public.edge, public.place WHERE place.kind = 'instituition' AND edge.kind = '",kindMoment,"' AND place.id = edge.",flowMoment," AND edge.end_year BETWEEN ",range[1]," AND ", range[2],sep='')
} 
sql.instituition.count.rank <-function(kindContext, flowMoment, kindMoment, range,limit=limit){
	limit <- if(limit != 'none'){paste("LIMIT ",limit)}
	if(kindContext == 'instituition' & (kindMoment == 'doutorado' | kindMoment == 'work')){
		result <- if(flowMoment == 'target'|flowMoment == 'source'){
			sql.instituition.count(flowMoment, kindMoment, range)
		}	else if(flowMoment == 'all'){
			paste(sql.instituition.count('source', kindMoment, range)," UNION ALL",sql.instituition.count('target', kindMoment, range)) 
		}
		paste("SELECT place, count(*) degree FROM (",result,") flows GROUP BY place ORDER BY degree DESC",limit)
	}	
}

query.filter <- function(kindFilter, range=NULL){
	valueFilter <- c()
	if(is.element('doutorado',kindFilter)){
  	filterValue <- c(valueFilter, "edge.kind='doutorado'")
  }
  if(is.element('to-doutorado-USP',kindFilter)){
  	filterValue <- c(valueFilter, "edge.kind='doutorado' AND instituitionTarget.id = 179")
  }
  if(is.element('from-doutorado-USP',kindFilter)){
  	filterValue <- c(valueFilter, "edge.kind='doutorado' AND instituitionSource.id = 179")
  }
  if(is.element('to-doutorado-UFPE',kindFilter)){
  	filterValue <- c(valueFilter, "edge.kind='doutorado' AND instituitionTarget.id = 588")
  }
  if(is.element('from-doutorado-UFPE',kindFilter)){
  	filterValue <- c(valueFilter, "edge.kind='doutorado' AND instituitionSource.id = 588")
  }
  if(is.element('excludeAllBrazilFlows',kindFilter)){
  	filterValue <- c(valueFilter, "(countrySource.id != 131 AND countryTarget.id != 131)")
  }
  if(is.element('excludeFlowsInBrazil',kindFilter)){
  	filterValue <- c(valueFilter, paste("edge.id NOT IN (",sql.inst.inst.nacional,") AND edge.id NOT IN (",sql.city.inst.nacional,")",sep=''))
  }
  if(is.element('onlyFlowsInBrazil',kindFilter)){
  	filterValue <- c(valueFilter, paste("edge.id IN (",sql.inst.inst.nacional," UNION",sql.city.inst.nacional,")",sep=''))
  }
  if(is.element('topDegreeInst',kindFilter)){
  	sql.inst.top10.degree <- "SELECT id FROM (SELECT edge.target id FROM edge, place WHERE edge.target=place.id AND place.kind='instituition' UNION ALL SELECT edge.source id FROM edge, place WHERE edge.source=place.id AND place.kind='instituition') ids GROUP BY id ORDER BY count(id) DESC LIMIT 10"
  	filterValue <- c(valueFilter, paste("instituitionSource.id IN (",sql.inst.top10.degree,") AND instituitionTarget.id IN (",sql.inst.top10.degree,")",sep=''))
  }

  for(filter in kindFilter){
  	if(unlist(strsplit(filter,'-'))[1] == 'specificPerson'){
	  	filterValue <- c(valueFilter, paste("edge.id16='",unlist(strsplit(filter,'-'))[2],"'",sep=''))
	  }
  	# TODO FILE http://plsql1.cnpq.br/divulg/RESULTADO_PQ_102003.prc_comp_cmt_links?V_COD_DEMANDA=200310&V_TPO_RESULT=CURSO&V_COD_AREA_CONHEC=10300007&V_COD_CMT_ASSESSOR=CC
  	if(unlist(strsplit(filter,'-'))[1] == 'groupPeople'){
  		groupFile <- paste('./data/',unlist(strsplit(filter,'-'))[2],'.csv',sep= '')
	  	group <- read.table(groupFile, header=TRUE, quote="\'")
	  	groupIds <-  paste(group$id16,collapse=',')
	  	filterValue <- c(valueFilter, paste("edge.id16 IN (",groupIds,")",sep=''))
	  }
  }
  # TODO rangeYear-syear-eyear
  if(is.element('rangeYear',kindFilter)){
  	filterValue <- paste('edge.end_year IN (',paste(range,collapse=', '),') ',sep='')
  }

  filterValue
}
