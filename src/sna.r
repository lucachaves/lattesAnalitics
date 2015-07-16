# http://www.shizukalab.com/toolkits/sna
# http://www.rdatamining.com/examples/social-network-analysis
# http://igraph.org/r/doc/plot.common.html
library(igraph)
g<-read.graph("./image/gephi/lattes-states-all.gml",format=c("gml"))
g$layout <- layout.circle
print(g)