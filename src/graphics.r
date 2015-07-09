source('heatMapping.r')
source('flowMapping.r')
source('chordGraph.r')

db.get.connection <- function(){
	drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname="mobilitygraph",host="192.168.56.101",port=5432,user="postgres",password="postgres")
  con
}

generate.graphic.each <- function(kindGraphic, kindFlow, kindContext, kindTime='all', valueTime=NULL){
  print(paste(kindFlow, kindContext, kindTime,sep='-'))

  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname="mobilitygraph",host="192.168.56.101",port=5432,user="postgres",password="postgres")

  if(kindTime == "all" | kindTime == "rangeAll"){
	  
	  imageFile <- if(kindTime == "all"){
	  	paste(kindContext,'-',kindFlow,'-',kindTime, '.png',sep='')
  	}else if(kindTime == "rangeAll"){
	  	paste(kindContext,'-',kindFlow,'-',paste(valueTime[1],'-',valueTime[2],sep=''),'.png',sep='')
  	}
  	sql <- if(kindTime == "all"){
  		generate.query(kindContext, kindFlow)
  	}else if(kindTime == "rangeAll"){
  		generate.query(kindContext, kindFlow, 'range', valueTime)
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

			imageFile <- paste(kindContext,'-',kindFlow,'-',year,'.png',sep='')
		  
		  sql <- generate.query(kindContext, kindFlow, 'year', year)
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

generate.graphic <- function(){
	sink("outfile.txt")
	print("BEGIN")

	# kindGraphic <- c('mc', 'gm', 'mfc')
	kindGraphic <- c('mc')
	# for(kindFlow in c('fnf','fff','fft','all')){
	for(kindFlow in c('fnf')){
		# for(kindContext in c('city','state','region','country','continent')){
		for(kindContext in c('region')){
				print(paste(kindFlow, kindContext, sep='-'))
				if(kindFlow == 'fnf' | kindFlow == 'fff'){
					# generate.graphic.each(kindFlow, kindContext, kindTime="rangeAll", valueTime=c(1973,2013))
					# generate.graphic.each(kindGraphic, kindFlow, kindContext, kindTime="rangeYear", valueTime=c(1973,1973))
					# generate.graphic.each(kindGraphic, kindFlow, kindContext, kindTime="rangeYear", valueTime=c(1983,1983))
					# generate.graphic.each(kindGraphic, kindFlow, kindContext, kindTime="rangeYear", valueTime=c(1993,1993))
					# generate.graphic.each(kindGraphic, kindFlow, kindContext, kindTime="rangeYear", valueTime=c(2003,2003))
					generate.graphic.each(kindGraphic, kindFlow, kindContext, kindTime="rangeYear", valueTime=c(2013,2013))
				}
				# generate.graphic.each(kindGraphic, kindFlow, kindContext)
		}
	}

	print("END")
	sink()
}

generate.graphic()

# con <- db.get.connection()

# sql.top10.instituition.doutorado <- "SELECT place.id FROM public.edge, public.place WHERE edge.target = place.id AND edge.kind = 'doutorado' AND place.kind = 'instituition' GROUP BY place.id ORDER BY count(place) DESC LIMIT 10"
# sql.top10.city.doutorado <- ""
# top10 <- sql.top10.instituition.doutorado
# sql <- paste("SELECT place.acronym place, edge.end_year eyear, count(*) degree FROM public.edge, public.place WHERE edge.end_year BETWEEN 1900 AND 2013 AND edge.target = place.id AND place.id in (",top10,") AND place.kind = 'instituition' AND edge.kind = 'doutorado' GROUP BY place, eyear ORDER BY place, eyear",sep='')
# rs <- dbSendQuery(con,sql)
# flows <- fetch(rs,n=-1)

# imageFile <- paste('./image/tl/top10.instituition.doutorado.png',sep='')
# # TODO preencher valores vazios e criar siglas
# generate.mc.timeline(imageFile, flows)


####### TODO #######
# evitar duplicidade de consulta
# sigla
# formação do doutorado
# validar databases (dados duplicados)
# validar generateQuery
# filtro
# time; nacional/foreign; specific degree; 
# kindFlow(all,fnf,fff,ffft,graduacao,doutorado...)
# kindContext(instituition,city,state,region,country,continent)
# kindTime(all,rangeAll,rangeYear)

######## MC ########
# TODO
# same comparator size
# colocar número

######## GM ########
# TODO
# point
# same color (point edge)
# loop
# splitSize / log scale
# custom title
# theme (white,black)

######## MFC ########
# TODO
# ordem

######## TL ########

######## LINE ########
