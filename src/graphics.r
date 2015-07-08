source('heatMapping.r')
source('flowMapping.r')
source('chordGraph.r')
require 'progress_bar'

print("BEGIN")

######## ALL ########
# TODO
# validar generateQuery
# filtro
# time; nacional/foreign; specific degree; 
# genertor to 
# 	kindFlow, kindContext, kintTime, scale

# MC <- c()
# MC['kindFlow'] <- c('fnf','fff','fft','all')
# MC['kindContext'] <- c('state','region','country','continent')
# MC['times'] <- c(c(1950,2013),c(1973,1973),c(1983,1983),c(1993,1993),c(2003,2003),c(2013,2013))
# scale <- c('normal', 'log')
# bar = ProgressBar.new(4+4+6)
# for(kindFlow in MC['kindFlow']){
# 	for(kindContext in MC['kindContext']){
# 		for(time in MC['times']){
# 			print(kindFlow, kindContext, times,sep='-')
# 			generate.mc(kindFlow, kindContext, "rangeAll", time)
# 			bar.increment!
# 		}
# 	}
# }

# MFC <- c()
# MFC['kindFlow'] <- c('fnf','fff','fft','all')
# MFC['kindContext'] <- c('state','region','country','continent')
# MFC['times'] <- c(c(1950,2013),c(1973,1973),c(1983,1983),c(1993,1993),c(2003,2003),c(2013,2013))
# bar = ProgressBar.new(4+4+6)
# for(kindFlow in MFC['kindFlow']){
# 	for(kindContext in MFC['kindContext']){
# 		for(time in MFC['times']){
# 			print(kindFlow, kindContext, times,sep='-')
# 			generate.mfc(kindFlow, kindContext, "rangeAll", time)
# 			bar.increment!
# 		}
# 	}
# }

# GM <- c()
# GM['kindFlow'] <- c('fnf','fff','fft','all')
# GM['kindContext'] <- c('city', 'state','region','country','continent')
# GM['times'] <- c(c(1950,2013),c(1973,1973),c(1983,1983),c(1993,1993),c(2003,2003),c(2013,2013))
# bar = ProgressBar.new(4+5+6)
# for(kindFlow in GM['kindFlow']){
# 	for(kindContext in GM['kindContext']){
# 		for(time in GM['times']){
# 			print(kindFlow, kindContext, times,sep='-')
# 			generate.gm(kindFlow, kindContext, "rangeAll", time)
# 			bar.increment!
# 		}
# 	}
# }

######## MC ########
# TODO
# same comparator size
# colocar número

# REGION
# generate.mc("fnf", "region", "all")
# generate.mc("fff", "region", "all")
# generate.mc("fft", "region", "all")
# generate.mc("all", "region", "all")
# generate.mc("all", "region", "all", scale='log')
# generate.mc("fnf", "region", "rangeAll", c(2000,2013))
# generate.mc("fnf", "region", "rangeYear", c(2000,2013))

# CONTINENT
# generate.mc("fnf", "continent", "all")
# generate.mc("fnf", "continent", "all", scale='log')
# generate.mc("fff", "continent", "all")

######## MFC ########
# TODO
# 1973, 1983, 1993, 2003, 2013
# sigla
# ordem

# STATE
# generate.mfc("fff", "state", "all")
# generate.mfc("fft", "state", "all")
# generate.mfc("all", "state", "all")
# generate.mfc("fnf", "state", "all")
# generate.mfc("fnf", "state", "rangeAll", c(2000,2013))
# generate.mfc("fnf", "state", "rangeYear", c(2000,2013))
# generate.mfc("fnf", "state", "rangeYear", c(2000,2000))

# REGION
# generate.mfc("fff", "region", "all")
# generate.mfc("fft", "region", "all")
# generate.mfc("all", "region", "all")
# generate.mfc("fnf", "region", "all")
# generate.mfc("fnf", "region", "rangeAll", c(2000,2013))
# generate.mfc("fnf", "region", "rangeYear", c(2000,2013))
# generate.mfc("fnf", "region", "rangeYear", c(2000,2000))

# COUNTRY
# generate.mfc("fff", "country", "rangeYear", c(2013,2013))
# generate.mfc("fff", "country", "rangeYear", c(2003,2003))
# generate.mfc("fff", "country", "rangeYear", c(1993,1993))
# generate.mfc("fff", "country", "rangeYear", c(1983,1983))
generate.mfc("fff", "country", "rangeYear", c(1973,1973))

# CONTINENT
# generate.mfc("fff", "continent", "all")
# generate.mfc("fft", "continent", "all")
# generate.mfc("all", "continent", "all")
# generate.mfc("fnf", "continent", "all")
# generate.mfc("fnf", "continent", "rangeAll", c(2000,2013))
# generate.mfc("fnf", "continent", "rangeYear", c(2000,2013))
# generate.mfc("fnf", "continent", "rangeYear", c(2000,2000))

######## GM ########
# TODO
# point
# same color (point edge)
# loop
# splitSize / log scale
# custom title
# mapa global/nacional
# theme (white,black)
# kindFlow(all,fnf,fff,ffft,graduacao,doutorado...)
# kindContext(instituition,city,state,region,country,continent)
# kindTime(all,rangeAll,rangeYear)

# REGION
# generate.gm("white", "fnf", "region", "all")
# generate.gm("white", "fff", "region", "all")
# generate.gm("white", "fft", "region", "all")
# generate.gm("white", "all", "region", "all")
# generate.gm("white", "fnf", "region", "rangeAll", c(2000,2013))
# generate.gm("white", "fnf", "region", "rangeYear", c(2000,2013))

print("END")