source('heatMapping.r')
source('flowMapping.r')
source('chordGraph.r')

print("BEGIN")

# TODO 
# generateQuery
# filtro
# time; nacional/foreign; specific degree; 

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
generate.mc("fff", "continent", "all")

######## MFC ########
# TODO
# 1973, 1983, 1993, 2003, 2013
# sigla
# ordem

# generate.mfc("fnf", "region", "all")
# generate.mfc("fnf", "region", "rangeAll", c(2000,2013))
# generate.mfc("fnf", "region", "rangeYear", c(2000,2013))
# generate.mfc("fnf", "region", "rangeYear", c(2000,2000))

######## GM ########
# TODO
# point
# same color (point edge)
# loop
# splitSize / log scale
# theme

# generate.gm("white", "fnf", "region", "all")
# generate.gm("white", "fff", "region", "all")
# generate.gm("white", "fft", "region", "all")
# generate.gm("white", "all", "region", "all")
# generate.gm("white", "fnf", "region", "rangeAll", c(2000,2013))
# generate.gm("white", "fnf", "region", "rangeYear", c(2000,2013))

print("END")