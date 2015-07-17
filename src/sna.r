# http://www.shizukalab.com/toolkits/sna
# http://www.rdatamining.com/examples/social-network-analysis
# http://igraph.org/r/doc/plot.common.html
# http://igraph.org/r/doc/igraph.pdf
# http://www.inside-r.org/packages/cran/igraph/docs/graph.data.frame
# http://stackoverflow.com/questions/12751497/how-to-convert-csv-file-containing-network-data-into-gml
# http://www.shizukalab.com/toolkits/sna/weighted-edges

# Id,Label,Modularity Class,Latitude,Longitude (nodes )
# node
# [
#   id 1
#   label "UFSC"
#   ModularityClass "instituition"
#   Latitude "-27.25"
#   Longitude "-50.333333"
# ]
# Id,Label,Type,Source,Target,Modularity Class,Weight (edges )
# edge
# [
#   id 17
#   source 1
#   target 1
#   value 15195.0
#   Modularity Class "fff"
# ]

library(igraph)
g<-read.graph("./image/gephi/lattes-states-all.gml",format=c("gml"))
g$layout <- layout.circle
print(g)
plot(g)


flows <- getdata(generate.all.query('instituition','fff',filter=c('doutorado','topDegreeInst'),kindQuery='acronym'))
# flows <- flows[!duplicated(flows), ]
flows.ag <- aggregate(list(weight=rep(1,nrow(flows))), flows, length)
graph <- graph.data.frame(d = flows.ag, directed = TRUE)
plot(graph)
write.graph(graph = graph, file = 'topDegreeInst.gml', format = 'gml')
# change name->label

