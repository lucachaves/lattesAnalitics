
## R

RPostgreSQL
* https://code.google.com/p/rpostgresql/
* http://www.r-bloggers.com/r-and-postgresql-using-rpostgresql-and-sqldf/

circlize
* http://www.rdocumentation.org/packages/circlize/functions/circos.text

# TODO

* sigla a partir dos nomes
* otimizar as consultas sql
* mc histórico
* cor
* evolução do número de doutroes
* substituir os demais gráficos do lattesGephi (treemap, scatterplot, histograma)

## MIX

Indent SQL
http://www.statmethods.net/management/operators.html

Shapefile
https://wwwn.cdc.gov/epiinfo/html/shapefiles.htm
http://www.baruch.cuny.edu/geoportal/data/esri/esri_intl.htm
http://www.arcgis.com/home/search.html?t=content&q=tags:continents


# TODO coletar código das Figuras usadas na diss.
fff-all (state-mfc, state-mc-log, region-mc-num #TODO, continent-mfc, continent-mc) 
tm-rank-city-fff-all
tl-topInst-fnf-all
stats-latteslocation

####### TODO #######
# tl-top-city
# rank de onde vamos no exterior na formacao de doutorado (gráfico de barra/pizza?!)
# calcular as métricas de mobilidade: DD, ID
# dump mobilitygraph

# rankInstituition vs DD
# pegar código dos gráficos que já foram usados na dissertação

# Criar arquivo GML (igraph) sna.r
# gerar arquivos para o gephi (GML)
	# Criar GML file http://gephi.github.io/users/supported-graph-formats/gml-format/
	# OR
	# Id,Label,Modularity Class,Latitude,Longitude (nodes )
	# Id,Label,Type,Source,TargetModularity Class,Weight (edges )
	# 1,,Directed,5,1,birth,369 #Weight(all, fff, fft,...)
# calcular outras métricas de sna para comprar MMP: api gephi or igraph
# pegar ids dePQs de computação e comparar seu DD com a média global
# outros gráficos que estao no lattesGephi
# filter: graduacao,doutorado...
# graduacao: source,target, out/in
# analisar a importancia do start_year
# suprir todos os gráficos da dissertação
# validate generateQuery
# siglas
# custom title

######## GM ########
# same color (point edge)
# loop
# theme (white,black)
# aresta afinando para o destino

######## MFC ########
# ordem
# color instituition?
