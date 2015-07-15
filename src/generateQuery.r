library(Hmisc)

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
	if(instituition){
		if(nacional){
			c('instituition', 'city', 'state', 'region', 'country', 'continent')
		}else{
			c('instituition', 'city', 'country', 'continent')
		}	
	}else{
		if(nacional){
			c('city', 'state', 'region', 'country', 'continent')
		}else{
			c('city', 'country', 'continent')
		}	
	}
}

generate.specific.select <- function(kindContext, kindNode, kindQuery, allFlow=FALSE){
	names <- unlist(strsplit(kindQuery,'-'))
	fields <- c()
	prefix <- if(kindNode=='all' | allFlow == TRUE){
		' '
	}else if(kindNode=='source'){
		' s'
	}else if(kindNode=='target'){
		' t'
	}
	for(name in names){
		table <- paste(kindContext,capitalize(kindNode),sep='')
		prefixTable <- ' p'
		if(grepl('edge:',name)){
			table <- 'edge' 
			name <- unlist(strsplit(name,':'))[2]
			prefixTable <- ' e'
		}
		fields <- c(fields,paste(table,'.',name,ifelse(name == 'id',prefixTable,prefix),name,sep=''))
	}
	paste(fields,collapse=', ')
}

generate.specific.from <- function(kindContext, kindNode, nacional, instituition){
	order <- generate.flow(nacional, instituition)
	
	from <- ''
	for(i in order){
		from <- paste(from,paste('public.place ',i,capitalize(kindNode),sep=''),sep=', ')
		if((i == kindContext)|(i == 'city' & kindContext == 'instituition')){
			break;
		}
	}
	from
}

generate.specific.where <- function(kindContext, kindNode, nacional, instituition){
	order <- generate.flow(nacional, instituition)	

	where <- paste("edge.",kindNode," = ",sep='')
	for(i in order){
		where <- paste(where,i,capitalize(kindNode),".id AND ",i,capitalize(kindNode),".kind ='",i,"'",sep='')
		if((i == kindContext)|(i == 'city' & kindContext == 'instituition')){
			break;
		}
		where <- paste(where," AND ",i,capitalize(kindNode),".belong_to = ",sep='')
	}
	where
}

generate.specific.query <- function(kindContext, nacionalSource, instituitionSource, nacionalTarget, instituitionTarget, filter, kindQuery='name-latitude-longitude', kindNode='all',kindFlow='all', allFlow=FALSE){
	
	# SELECT
	kindContextSource <- ifelse((kindContext == 'instituition' & ((kindFlow == 'fnf')|(kindFlow == 'all' & instituitionSource == FALSE))),'city',kindContext)
	
	specific.select <- if(kindNode == 'all'){
		paste(
			generate.specific.select(kindContextSource, 'source', kindQuery=kindQuery),
			generate.specific.select(kindContext, 'target', kindQuery=kindQuery),
			sep=', '	
		)
	}else if(kindNode == 'source'){
		generate.specific.select(kindContextSource, kindNode, kindQuery=kindQuery, allFlow=allFlow)
	}else if(kindNode == 'target'){
		generate.specific.select(kindContext, kindNode, kindQuery=kindQuery, allFlow=allFlow)
	}
	specific.select <- paste(
		"SELECT ",
		specific.select
	)
	
	# FROM
	specific.from <- if(kindNode == 'all'){
		paste(
			generate.specific.from(kindContext, 'source', nacionalSource, instituitionSource),
			generate.specific.from(kindContext, 'target', nacionalTarget, instituitionTarget),
			sep=' '
		)
	}else{
		generate.specific.from(kindContext, kindNode, nacionalSource, instituitionSource)
	}
	specific.from <- paste(
		"FROM ",
		"public.edge edge",
		specific.from,
		sep=' '
	)
	
	# WHERE
	filterValue <- if(length(filter)>0){
		paste(generate.filter(filter),' AND ',sep='')
	}else{
		''
	}
	specific.where <- if(kindNode == 'all'){
		paste(
			generate.specific.where(kindContext, 'source', nacionalSource, instituitionSource),
			' AND ',
			generate.specific.where(kindContext, 'target', nacionalTarget, instituitionTarget),
			sep=' '
		)
	}else{
		generate.specific.where(kindContext, kindNode, nacionalSource, instituitionSource)
	}
	specific.where <- paste(
		'WHERE',
		filterValue,
		specific.where,
		sep=' '
	)
	
	paste(specific.select, specific.from, specific.where, sep=' ')
}

# kindNode= ('all-edge','all-node','source','target')
generate.all.query <- function(kindContext, kindFlow, global='', filter=c(), kindNode='all', kindQuery='name-latitude-longitude', allFlow=FALSE){
	if(kindFlow == 'fff'){
		filter <- c(filter,'fff')
	}else if(kindFlow == 'fft'){
		filter <- c(filter,'fft')
	}

	global <- ifelse(((kindContext == 'country' | kindContext == 'continent') & global == ''),TRUE, FALSE)

	result <- if(kindFlow == 'fnf'){
		if(kindNode == 'all'){
			if(global == TRUE){
				paste(
					generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,TRUE,FALSE,FALSE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,FALSE,TRUE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,FALSE,FALSE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					sep=' '
				)	
			}else{
				generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow)
			}
		}else if(kindNode == 'target'){
			if(global == TRUE){
				paste(
					generate.specific.query(kindContext,TRUE,TRUE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,TRUE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					sep=' '
				)
			}else{
				generate.specific.query(kindContext,TRUE,TRUE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow)
			}
		}else if(kindNode == 'source'){
			if(global == TRUE){
				paste(
					generate.specific.query(kindContext,TRUE,FALSE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,FALSE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					sep=' '
				)
			}else{
				generate.specific.query(kindContext,TRUE,FALSE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow)
			}
		}


	}else if(kindFlow == 'fff' | kindFlow == 'fft' | kindFlow == 'ffft'){
		if(global == TRUE){
			if(kindNode == 'all'){
				paste(
					generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,TRUE,TRUE,FALSE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,TRUE,TRUE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,TRUE,FALSE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					sep=' '
				)
			}else{ # source,target
				paste(
					generate.specific.query(kindContext,TRUE,TRUE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,TRUE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					sep=' '
				)
			}
		}else{ #nacional
			if(kindNode == 'all'){	
				generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow)
			}else{
				generate.specific.query(kindContext,TRUE,TRUE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow)
			}
		}


	}else if(kindFlow == 'all'){
		if(kindNode == 'all'){
			if(global == TRUE){
				paste(
					generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,TRUE,FALSE,FALSE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,FALSE,TRUE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,FALSE,FALSE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,TRUE,TRUE,FALSE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,TRUE,TRUE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,TRUE,FALSE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					sep=' '
				)
			}else{
				paste(
					generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter,kindQuery,kindFlow=kindFlow, allFlow=allFlow),
					sep=' '
				)
			}
		}else if(kindNode == 'source'){
			if(global == TRUE){
				paste(
					generate.specific.query(kindContext,TRUE,FALSE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,FALSE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,TRUE,TRUE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,TRUE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					sep=' '
				)
			}else{
				paste(
					generate.specific.query(kindContext,TRUE,FALSE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,TRUE,TRUE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					sep=' '
				)
			}
		}else if(kindNode == 'target'){
			if(global == TRUE){
				paste(
					generate.specific.query(kindContext,TRUE,TRUE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					'UNION ALL',
					generate.specific.query(kindContext,FALSE,TRUE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow),
					sep=' '
				)
			}else{
				generate.specific.query(kindContext,TRUE,TRUE,FALSE,FALSE,filter,kindQuery, kindNode=kindNode,kindFlow=kindFlow, allFlow=allFlow)
			}
		}
	}

	result
}

generate.query <- function(
	kindContext,
	kindFlow,
	global='',
	filter=c(),
	kindNode='target',
	range=c(1950,2013), 
	limit='none', 
	valuename=FALSE, 
	kindQuery='acronym-latitude-longitude'
){

	if(kindQuery == 'acronym-latitude-longitude'){
		global.select <- "SELECT row_number() OVER () as id, sacronym, slatitude, slongitude, tacronym, tlatitude, tlongitude, count(*) count"
		global.from <- paste("FROM (", generate.all.query(kindContext, kindFlow, global,filter=filter,kindQuery=kindQuery),") flow",sep='')
		global.group <- "GROUP BY sacronym, slatitude, slongitude, tacronym, tlatitude, tlongitude"
		global.order <- "ORDER BY sacronym, tacronym"
		paste(
			global.select,
			global.from,
			global.group,
			global.order,
			sep=' '
		)

	}else if(kindQuery == 'top-name'){
		paste(
			"SELECT acronym FROM (",
			generate.query(kindContext, kindFlow, kindQuery='name-count', kindNode=kindNode, filter=filter, limit=limit),
			") flows ORDER BY count DESC",
			if(limit != 'none'){paste("LIMIT ",limit)}
		)
	}else if(kindQuery == 'top-name-edge:end_year'){
		topid <- paste(
			"SELECT pid FROM (",
			generate.query(kindContext, kindFlow, kindQuery='name-count', kindNode=kindNode, filter=filter, limit=limit),
			") flows ORDER BY count DESC",
			if(limit != 'none'){paste("LIMIT ",limit)}
		)

		result <- if(kindNode == 'target'|kindNode == 'source'){
			generate.all.query(kindContext, kindFlow, kindNode=kindNode,kindQuery='id-acronym-edge:end_year', filter=filter)
		}	else if(kindNode == 'all'){
			paste(
				generate.all.query(kindContext, kindFlow, kindNode='source', kindQuery='id-acronym-edge:end_year', filter=filter, allFlow=TRUE),
				"UNION ALL",
				generate.all.query(kindContext, kindFlow, kindNode='target', kindQuery='id-acronym-edge:end_year', filter=filter, allFlow=TRUE)
			) 
		}

		columnName <- if(kindNode=='all'){
			'acronym, end_year'
		}else if(kindNode=='target'){
			'tacronym acronym, tend_year end_year'
		}else if(kindNode=='source'){
			'sacronym acronym, send_year end_year'
		}

		paste( 
			"SELECT ",
			columnName,
			", count(*) count FROM (",
			result,
			") flows WHERE pid IN (",
			topid,
			") GROUP BY acronym, end_year ORDER BY acronym, end_year"
		)

	}else if(kindQuery == 'name-count'){
		result <- if(kindNode == 'target'|kindNode == 'source'){
			generate.all.query(kindContext, kindFlow, kindNode=kindNode,kindQuery='id-acronym', filter=filter)
		}	else if(kindNode == 'all'){
			paste(
				generate.all.query(kindContext, kindFlow, kindNode='source', kindQuery='id-acronym', filter=filter, allFlow=TRUE),
				"UNION ALL",
				generate.all.query(kindContext, kindFlow, kindNode='target', kindQuery='id-acronym', filter=filter, allFlow=TRUE)
			) 
		}
		
		columnName <- if(kindNode=='all'){
			'acronym'
		}else if(kindNode=='target'){
			'tacronym acronym'
		}else if(kindNode=='source'){
			'sacronym acronym'
		}
		
		paste( 
			"SELECT pid, ",
			columnName,
			", count(*) count FROM (",
			result,
			") flows GROUP BY pid, acronym ORDER BY count DESC",
			if(limit != 'none'){paste("LIMIT ",limit)}
		)

	}else if(kindQuery == 'count-all-doutorado-by-end_year'){
		paste("SELECT edge.end_year end_year, count(*) count FROM public.edge WHERE edge.kind = 'doutorado' AND edge.end_year BETWEEN ",range[1]," AND ", range[2]," GROUP BY end_year ORDER BY end_year",sep='')
	
	}else if(kindQuery == 'count-all-doutorado-nacional-by-end_year'){
		paste("SELECT edge.end_year end_year, count(*) count FROM public.edge WHERE edge.kind = 'doutorado' AND edge.end_year BETWEEN ",range[1]," AND ", range[2]," AND edge.id IN (",sql.inst.inst.nacional," UNION ",sql.city.inst.nacional,") GROUP BY end_year ORDER BY end_year",sep='')
	}
}

sql.inst.inst.nacional <- "SELECT edge.id FROM PUBLIC.edge edge, PUBLIC.place instituitionSource, PUBLIC.place citySource, PUBLIC.place stateSource, PUBLIC.place regionSource, PUBLIC.place countrySource, PUBLIC.place instituitionTarget, PUBLIC.place cityTarget, PUBLIC.place stateTarget, PUBLIC.place regionTarget, PUBLIC.place countryTarget WHERE edge.source = instituitionSource.id AND instituitionSource.kind = 'instituition' AND instituitionSource.belong_to = citySource.id AND citySource.kind = 'city' AND citySource.belong_to = stateSource.id AND stateSource.kind = 'state' AND stateSource.belong_to = regionSource.id AND regionSource.kind = 'region' AND regionSource.belong_to = countrySource.id AND countrySource.kind = 'country' AND countrySource.id = 131 AND edge.target = instituitionTarget.id AND instituitionTarget.kind = 'instituition' AND instituitionTarget.belong_to = cityTarget.id AND cityTarget.kind = 'city' AND cityTarget.belong_to = stateTarget.id AND stateTarget.kind = 'state' AND stateTarget.belong_to = regionTarget.id AND regionTarget.kind = 'region' AND regionTarget.belong_to = countryTarget.id AND countryTarget.kind = 'country' AND countryTarget.id = 131"
sql.city.inst.nacional <- "SELECT edge.id FROM PUBLIC.edge edge, PUBLIC.place citySource, PUBLIC.place stateSource, PUBLIC.place regionSource, PUBLIC.place countrySource, PUBLIC.place instituitionTarget, PUBLIC.place cityTarget, PUBLIC.place stateTarget, PUBLIC.place regionTarget, PUBLIC.place countryTarget WHERE edge.source = citySource.id AND citySource.kind = 'city' AND citySource.belong_to = stateSource.id AND stateSource.kind = 'state' AND stateSource.belong_to = regionSource.id AND regionSource.kind = 'region' AND regionSource.belong_to = countrySource.id AND countrySource.kind = 'country' AND countrySource.id = 131 AND edge.target = instituitionTarget.id AND instituitionTarget.kind = 'instituition' AND instituitionTarget.belong_to = cityTarget.id AND cityTarget.kind = 'city' AND cityTarget.belong_to = stateTarget.id AND stateTarget.kind = 'state' AND stateTarget.belong_to = regionTarget.id AND regionTarget.kind = 'region' AND regionTarget.belong_to = countryTarget.id AND countryTarget.kind = 'country' AND countryTarget.id = 131"

generate.filter <- function(kindFilter){

	sql.inst.top10.count <- "SELECT id FROM (SELECT edge.target id FROM edge, place WHERE edge.target=place.id AND place.kind='instituition' UNION ALL SELECT edge.source id FROM edge, place WHERE edge.source=place.id AND place.kind='instituition') ids GROUP BY id ORDER BY count(id) DESC LIMIT 10"

	filters <- c()
	filters['doutorado'] <- "edge.kind='doutorado'"
	filters['to-doutorado-USP'] <- "edge.kind='doutorado' AND instituitionTarget.id = 179"
	filters['from-doutorado-USP'] <- "edge.kind='doutorado' AND instituitionSource.id = 179"
	filters['to-doutorado-UFPE'] <- "edge.kind='doutorado' AND instituitionSource.id = 588"
	filters['from-doutorado-UFPE'] <- "edge.kind='doutorado' AND instituitionSource.id = 588"
	filters['excludeAllBrazilFlows'] <- "(countrySource.id != 131 AND countryTarget.id != 131)"
	filters['excludeFlowsInBrazil'] <- paste("edge.id NOT IN (",sql.inst.inst.nacional,") AND edge.id NOT IN (",sql.city.inst.nacional,")",sep='')
	filters['onlyFlowsInBrazil'] <- paste("edge.id IN (",sql.inst.inst.nacional," UNION",sql.city.inst.nacional,")",sep='')
	filters['topDegreeInst'] <- paste("instituitionSource.id IN (",sql.inst.top10.count,") AND instituitionTarget.id IN (",sql.inst.top10.count,")",sep='')
	filters['fft'] <- "edge.kind = 'work'"
	filters['fff'] <- "edge.kind != 'work'"

	resultFilter <- c()
	if(length(kindFilter)>0){
		  for(kf in kindFilter){
		  	for(filter in names(filters)){
			  	if(filter == kf){
				  	resultFilter <- c(resultFilter, filters[filter])
				  }
				}

		  	if('plainFilter' == unlist(strsplit(kf,'::'))[1]){
		  		resultFilter <- c(resultFilter, unlist(strsplit(kf,'::'))[2])
		  	}
		  	
		  	if('specificPerson' == unlist(strsplit(kf,'-'))[1]){
			  	resultFilter <- c(resultFilter, paste("edge.id16='",unlist(strsplit(kf,'-'))[2],"'",sep=''))
			  }
		  	# TODO FILE http://plsql1.cnpq.br/divulg/RESULTADO_PQ_102003.prc_comp_cmt_links?V_COD_DEMANDA=200310&V_TPO_RESULT=CURSO&V_COD_AREA_CONHEC=10300007&V_COD_CMT_ASSESSOR=CC
		  	if('groupPeople' == unlist(strsplit(kf,'-'))[1]){
		  		groupFile <- paste('./data/',unlist(strsplit(kf,'-'))[2],'.csv',sep= '')
			  	group <- read.table(groupFile, header=TRUE, quote="\'")
			  	groupIds <-  paste(group$id16,collapse=',')
			  	resultFilter <- c(resultFilter, paste("edge.id16 IN (",groupIds,")",sep=''))
			  }
			  if('setYear' == unlist(strsplit(kf,'-'))[1]){
					years <- unlist(strsplit(kf,'-'))
			  	resultFilter <- c(resultFilter, paste('edge.end_year IN (',paste(years[2]:years[length(years)],collapse=', '),') ',sep=''))
			  }
			  if('rangeYear' == unlist(strsplit(kf,'-'))[1]){
					years <- unlist(strsplit(kf,'-'))
			  	resultFilter <- c(resultFilter, paste("edge.end_year BETWEEN ",years[2]," AND ",years[3],sep=''))
				}
				if('year' == unlist(strsplit(kf,'-'))[1]){
			  	resultFilter <- c(resultFilter, paste("edge.end_year = ",unlist(strsplit(kf,'-'))[2],sep=''))
				}
		  }
	}
  paste(resultFilter, collapse=' AND ')
}
