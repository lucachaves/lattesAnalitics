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

generate.specific.query <- function(kindContext, nacionalSource, instituitionSource, nacionalTarget, instituitionTarget, filter=''){
	specific.select <- "SELECT continentSource.acronym oname, continentSource.latitude oy, continentSource.longitude ox, continentTarget.acronym dname, continentTarget.latitude dy, continentTarget.longitude dx"
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
	if(filter != ''){
		specific.where <- paste(specific.where, filter,sep=' AND ')
	}
	paste(specific.select, specific.from, specific.where, sep= ' ')
}

generate.all.query <- function(kindContext, kindFlow){
	union <- ''
	if(kindFlow == 'fnf'){
		union <- paste(
			generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE),
			'UNION ALL',
			generate.specific.query(kindContext,TRUE,FALSE,FALSE,TRUE),
			'UNION ALL',
			generate.specific.query(kindContext,FALSE,FALSE,TRUE,TRUE),
			'UNION ALL',
			generate.specific.query(kindContext,FALSE,FALSE,FALSE,TRUE),
			sep=' '
		)
	}else if(kindFlow == 'fff' | kindFlow == 'fft'){
		filter <- "edge.kind = 'work'"
		if(kindFlow == 'fff'){
			filter <- "edge.kind != 'work'"
		}
		union <- paste(
			generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE,filter=filter),
			'UNION ALL',
			generate.specific.query(kindContext,TRUE,TRUE,FALSE,TRUE,filter=filter),
			'UNION ALL',
			generate.specific.query(kindContext,FALSE,TRUE,TRUE,TRUE,filter=filter),
			'UNION ALL',
			generate.specific.query(kindContext,FALSE,TRUE,FALSE,TRUE,filter=filter),
			sep=' '
		)
	}else if(kindFlow == 'all'){
		union <- paste(
			generate.specific.query(kindContext,TRUE,FALSE,TRUE,TRUE),
			'UNION ALL',
			generate.specific.query(kindContext,TRUE,FALSE,FALSE,TRUE),
			'UNION ALL',
			generate.specific.query(kindContext,FALSE,FALSE,TRUE,TRUE),
			'UNION ALL',
			generate.specific.query(kindContext,FALSE,FALSE,FALSE,TRUE),
			'UNION ALL',
			generate.specific.query(kindContext,TRUE,TRUE,TRUE,TRUE),
			'UNION ALL',
			generate.specific.query(kindContext,TRUE,TRUE,FALSE,TRUE),
			'UNION ALL',
			generate.specific.query(kindContext,FALSE,TRUE,TRUE,TRUE),
			'UNION ALL',
			generate.specific.query(kindContext,FALSE,TRUE,FALSE,TRUE),
			sep=' '
		)
	}
	union
}

generate.global.query <- function(kindContext, kindFlow){
	global.select <- "SELECT row_number() OVER () as id, oname, oy, ox, dname, dy, dx, count(*) trips"
	global.from <- paste("FROM (", generate.all.query(kindContext, kindFlow),") flow",sep='')
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

print(generate.global.query('continent','fff'))
# print(generate.specific.from('continent', 'source', TRUE, FALSE))
# print(generate.specific.from('continent', 'source', TRUE, TRUE))
# print(generate.specific.where('continent', 'source', TRUE, TRUE))
