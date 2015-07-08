require(Hmisc)

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

generate.specific.from <- function(kindContext, destination, nacional, instituition){
	order <- generate.flow(nacional, instituition)
	
	from <- ''
	for(i in order){
		from <- paste(from,paste('public.place ', i,capitalize(destination),sep=''),sep=', ')
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

generate.specific.query <- function(kindContext, nacionalSource, instituitionSource, nacionalTarget, instituitionTarget, filter){
	specific.select <- paste(
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
	specific.from <- paste(
		"FROM ",
		"public.edge edge",
		generate.specific.from(kindContext, 'source', nacionalSource, instituitionSource),
		generate.specific.from(kindContext, 'target', nacionalTarget, instituitionTarget),
		sep=' '
	)
	specific.where <- paste(
		"WHERE",
		generate.specific.where(kindContext, 'source', nacionalSource, instituitionSource),
		' AND ',
		generate.specific.where(kindContext, 'target', nacionalTarget, instituitionTarget),
		sep=' '
	)
	if(length(filter)!=0){
		specific.where <- paste(specific.where, paste(filter, collapse=' AND '),sep=' AND ')
	}
	paste(specific.select, specific.from, specific.where, sep= ' ')
}

generate.all.query <- function(kindContext, kindFlow, kindTime, valueTime, global){
	if(kindContext == 'region' | kindContext == 'state'){
		global <- FALSE
	}
	filter <- c()
	if(kindTime == 'range'){
		filter <- c(filter, paste("edge.end_year BETWEEN ",valueTime[1]," AND ",valueTime[2],sep=''))
	}else if(kindTime == 'year'){
		filter <- c(filter, paste("edge.end_year = ",valueTime,sep=''))
	}
	union <- ''
	if(kindFlow == 'fnf'){
		if(global){
			union <- paste(
				generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,TRUE,FALSE,FALSE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,FALSE,TRUE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,FALSE,FALSE,TRUE,filter),
				sep=' '
			)	
		}else{
			union <- generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE,filter)
		}
	}else if(kindFlow == 'fff' | kindFlow == 'fft'){
		if(kindFlow == 'fff'){
			filter <- c(filter,"edge.kind != 'work'")
		}else if(kindFlow == 'fft'){
			filter <- c(filter, "edge.kind = 'work'")
		}
		if(global){
			union <- paste(
				generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,TRUE,TRUE,FALSE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,TRUE,TRUE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,TRUE,FALSE,TRUE,filter),
				sep=' '
			)
			}else{
				union <- generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter)
			}
	}else if(kindFlow == 'all'){
		if(global){
			union <- paste(
				generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,TRUE,FALSE,FALSE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,FALSE,TRUE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,FALSE,FALSE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,TRUE,TRUE,FALSE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,TRUE,TRUE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,FALSE,TRUE,FALSE,TRUE,filter),
				sep=' '
			)
		}else{
			union <- paste(
				generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE,filter),
				'UNION ALL',
				generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter),
				sep=' '
			)
		}
	}
	union
}

generate.query <- function(kindContext, kindFlow, kindTime='all', valueTime=NULL, global=TRUE){
	global.select <- "SELECT row_number() OVER () as id, oname, oy, ox, dname, dy, dx, count(*) trips"
	global.from <- paste("FROM (", generate.all.query(kindContext, kindFlow, kindTime, valueTime, global),") flow",sep='')
	global.group <- "GROUP BY oy, ox, oname, dx, dy, dname"
	global.order <- "ORDER BY oname, dname"
	paste(
		global.select,
		global.from,
		global.group,
		global.order,
		sep=' '
	)
}

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