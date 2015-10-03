http://journals.plos.org/plosone/s/figures#loc-file-requirements
http://www.r-bloggers.com/high-resolution-figures-in-r/
http://blog.revolutionanalytics.com/2009/01/10-tips-for-making-your-r-graphics-look-their-best.html
http://thepoliticalmethodologist.com/2013/11/25/making-high-resolution-graphics-for-academic-publishing/
http://stackoverflow.com/questions/3595582/saving-plot-to-tiff-with-high-resolution-for-publication-in-r
http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/

#distance-year
library(ggplot2) 
library(ggExtra)

flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/distance/lattes-flow-distance-year-all.csv", sep=",",header=T, check.names = FALSE)
df <- data.frame(x = flow$years,y=flow$distances)
p <- ggplot(df,aes(x=x,y=y)) + 
  geom_point(size=1) + 
  xlab("year") + ylab("distance (m)")+
  theme(
    title=element_text(family='Arial',size=10), 
    axis.text=element_text(family='Arial',size=10), 
    axis.title=element_text(family='Arial',size=10)
  )+
  xlim(1940,2014)
ggExtra::ggMarginal(p, margins = "y", type = "histogram")

#pie
generate.graphic(c('mfc'),c('fff'),c('state'),kindTime=c('year-2013'),filter=c('doutorado'))

# input-output
generate.graphic.inoutput('country')

# mc-state
generate.graphic(c('mc'),c('fff'),c('state'),kindTime=c('rangeYear-all-1973-2013'),scalemc=c('log'))
c('source','target')