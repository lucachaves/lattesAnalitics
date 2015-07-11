# Artefatos/states\ lattes
# TODO PEGAR SQL
# TODO ORGANIZAR

library(ggplot2) 

# data/latteslocation/data-latteslocation.zip
degrees <- read.csv("degrees.csv")
degrees_count <- read.csv("degrees_count.csv")
xml_size <- read.csv("xml_size.csv")


# length(degrees$degree2)
# length(degrees_count$degrees.count)
# length(xml_size$xml_size)
# str(degrees)
# levels(df$degree)

df = data.frame (degree = degrees$degree2, degree_count = degrees_count$degrees.count, size = xml_size$xml_size)
df = data.frame (degree = degrees$degree2[1:10000], degree_count = degrees_count$degrees.count[1:10000], size = xml_size$xml_size[1:10000])
df = data.frame (degree = factor(degrees$degree2[1:10000], levels = c("ensino-fundamental","ensino-medio","graduacao","especializacao", "mestrado", "doutorado","pos-doutorado"),ordered = TRUE), degree_count = degrees_count$degrees.count[1:10000], size = xml_size$xml_size[1:10000])


# formationBySize.png
# formationPercentage.png
# densitySize.png
# distanceByYear.png
# distanceByYearAll.png
# distanceByYearBr.png
# distancePercentage.png
# distancePercentageAll.png
# distancePercentageBr.png

# countFormation.png
ggplot(df, aes(x = degree, y = degree_count))+ 
  geom_boxplot(outlier.size=NA)+
  ylim(0,15)+
	theme(
      title=element_text(size=14,face="bold"), 
      axis.text=element_text(size=14,face="bold"), 
      axis.title=element_text(size=14,face="bold")#,
      # axis.text.x=element_text(angle=-90)
  )+
  xlab("Titulação") + ylab("Número de formação")+
	scale_x_discrete(limits=c("ensino-fundamental","ensino-medio","graduacao","especializacao", "mestrado", "doutorado","pos-doutorado"))+
	coord_flip()

# size
ggplot(df, aes(x=degree,y=size))+
	geom_boxplot(outlier.size=NA)+
	ylim(0,40000)+
	theme(
      title=element_text(size=14,face="bold"), 
      axis.text=element_text(size=14,face="bold"), 
      axis.title=element_text(size=14,face="bold")#,
      # axis.text.x=element_text(angle=-90)
  )+
  xlab("Titulação") + ylab("Tamanho dos Currílos (Bytes)")+
	scale_x_discrete(limits=c("sem-formacao","ensino-fundamental","ensino-medio","graduacao","especializacao", "mestrado", "doutorado","pos-doutorado"))+
	coord_flip()

ggplot(df, aes(x = size)) +
	geom_density()

df2 = data.frame (size = sort(df$size)[1:3500000])
ggplot(df2, aes(x = size)) +
    stat_bin(binwidth=2048)+
    xlab('Tamanhos a cada 2KB')+ylab('Número de currículos')+
		theme(
	      title=element_text(size=14,face="bold"), 
	      axis.text=element_text(size=14,face="bold"), 
	      axis.title=element_text(size=14,face="bold")#,
	      # axis.text.x=element_text(angle=-90)
	  )

ggplot(df, aes(x=degree_count,y=size, color=degree))+
	geom_point(size=4, alpha=.2)+
	geom_smooth(method=lm,se=FALSE)

table(df$degree_count)
summary(df$degree_count)
hist(df$degree_count, breaks = 200, xlim=c(0,15))
ggplot(df, aes(x = degree_count, y = (..count..)/sum(..count..)))+ 
  geom_bar()+ 
  xlim(0, 15)+
  stat_bin(aes(label=paste("n = ",(..count..)/sum(..count..))), vjust=1, geom="text")

#degree
ggplot(df, aes(x = degree, y = (..count..)/sum(..count..)))+ 
  geom_bar()+ 
  stat_bin(aes(label=paste("n = ",(..count..)/sum(..count..))), vjust=1, geom="text")+
  scale_x_discrete(limits=c("ensino-fundamental","ensino-medio","graduacao","especializacao", "mestrado", "doutorado","pos-doutorado","sem-formacao"))

ggplot(df, aes(x = degree, y = (..count..)/sum(..count..)))+ 
  stat_bin()+
  scale_x_discrete(limits=c("ensino-fundamental","ensino-medio","graduacao","especializacao", "mestrado", "doutorado","pos-doutorado"))+
	xlab('Titulações')+ylab('Porcentagem')+
	theme(
      title=element_text(size=14,face="bold"), 
      axis.text=element_text(size=14,face="bold"), 
      axis.title=element_text(size=14,face="bold")#,
      # axis.text.x=element_text(angle=-90)
  )+
  coord_flip()

# downloadXml.png
download = c(139, 147405, 266527, 124099, 79281, 76130, 211903, 126284, 146610, 89283, 34118, 24052, 71304, 152100, 211932, 155277, 31977, 0, 0, 188814, 433831, 244485, 436300, 350938, 130583, 0, 142561, 35652)
day = c("29/09/14", "30/09/14", "31/09/14", "01/10/14", "02/10/14", "03/10/14", "04/10/14", "05/10/14", "06/10/14", "07/10/14", "08/10/14", "09/10/14", "10/10/14", "11/10/14", "12/10/14", "13/10/14", "14/10/14", "15/10/14", "16/10/14", "17/10/14", "18/10/14", "19/10/14", "20/10/14", "21/10/14", "22/10/14", "23/10/14", "24/10/14", "25/10/14")
df = data.frame(day=day,download=download)
ggplot(df, aes(x = day, y = download))+
	geom_bar(stat = "identity")+
	theme(
      title=element_text(size=14,face="bold"), 
      axis.text=element_text(size=14,face="bold"), 
      axis.title=element_text(size=14,face="bold"),
      axis.text.x=element_text(angle=-90)
  )+
  xlab("Dia") + ylab("Número de downloads")+
  scale_x_discrete(limits=c("29/09/14", "30/09/14", "31/09/14", "01/10/14", "02/10/14", "03/10/14", "04/10/14", "05/10/14", "06/10/14", "07/10/14", "08/10/14", "09/10/14", "10/10/14", "11/10/14", "12/10/14", "13/10/14", "14/10/14", "15/10/14", "16/10/14", "17/10/14", "18/10/14", "19/10/14", "20/10/14", "21/10/14", "22/10/14", "23/10/14", "24/10/14", "25/10/14"))


# updateCount.png
year = c(1997, 1999, 1998, 2001, 2000, 2003, 2002, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014)
count = c(203, 1720, 2140, 3683, 7137, 26078, 28442, 41071, 60214, 100248, 113043, 139858, 187171, 230394, 313857, 473214, 745369, 1437638)
df = data.frame(year=year,count=count)
ggplot(df, aes(x = year, y = count))+
	geom_bar(stat = "identity")+
	theme(
      title=element_text(size=14,face="bold"), 
      axis.text=element_text(size=14,face="bold"), 
      axis.title=element_text(size=14,face="bold")#,
      # axis.text.x=element_text(angle=-90)
  )+
  xlab("Ano") + ylab("Número de atualização")

# distance
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/distance/lattes-flow-distance-year-all-br.csv", sep=",",header=T, check.names = FALSE)
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/distance/lattes-flow-distance-year-all.csv", sep=",",header=T, check.names = FALSE)

is.list(flow)
is.vector(flow$distances)
sumary(flow$distances)
sort(flow$distances)

hist(flow$distances)
hist(flow$distances, breaks = 20)
hist(flow$distances, breaks = 20, col = "gray", labels = TRUE)
hist(flow$distances[1:20000], breaks = 200, col = "gray")
hist(log(flow$distances+1), col = "gray")

plot(density(flow$distances))
plot(flow$distances, flow$years)
plot(flow$years, flow$distances, xlim=c(1940,2014))

# http://stackoverflow.com/questions/7714677/r-scatterplot-with-too-many-points
df <- data.frame(x = flow$years,y=flow$distances)

library(ggplot2) 
ggplot(df,aes(x=x,y=y)) + 
  geom_point(alpha = 0.3) + 
  # xlab("year") + ylab("distance (m)")+ggtitle("Distance by Year")+
  xlab("ano") + ylab("distância (m)")+
  theme(
    title=element_text(size=14,face="bold"), 
    axis.text=element_text(size=14,face="bold"), 
    axis.title=element_text(size=14,face="bold")#,
    # axis.text.x=element_text(angle=-90)
  )+
  xlim(1940,2014)

ggplot(df,aes(x=x,y=y)) + 
  geom_point(alpha = 0.3) + 
  xlim(1940,2014)+ 
  geom_density2d()

ggplot(df,aes(x=x,y=y))+ 
  stat_binhex()+ 
  xlim(1940,2014)

flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/distance/lattes-flow-distance-year-all.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/distance/lattes-flow-distance-year-all-br.csv")

summary(flow$distances)
head(table(flow$distances))
length(flow$distances)
sort(flow$distances)[177229*0.7]
# 0 -> 114324 (114324/177229 - 64,5%)
# total -> 177229

ggplot(flow, aes(x = flow$distances, y = (..count..)/sum(..count..)))+ 
  geom_bar()

ggplot(flow, aes(x = flow$distances, y = (..count..)/sum(..count..)))+ 
  geom_bar()+
  # xlim(0, 12000000)+
  xlab("distância (m)") + ylab("porcentagem (%)")+
  theme(
    title=element_text(size=14,face="bold"), 
    axis.text=element_text(size=14,face="bold"), 
    axis.title=element_text(size=14,face="bold")#,
    # axis.text.x=element_text(angle=-90)
  )

ggplot(flow, aes(x = flow$distances, y = (..count..)/sum(..count..)))+ 
  geom_bar()+xlim(-1000000, 12000000)+
  stat_bin(aes(label=paste((..count..)/sum(..count..))), vjust=1, geom="text")

ggplot(flow, aes(x = flow$distances, y = ..count..))+ 
  geom_bar()+xlim(-1000000, 12000000)+
  stat_bin(aes(label=paste(..count..)), vjust=1, geom="text")



# MIX

ggplot(df, aes(degree))+
	geom_point(aes(y=degree_count), size=4, alpha=.2)

ggplot(df, aes(degree))+
	geom_boxplot(aes(y=degree_count))

ggplot(df, aes(x=degree,y=degree_count, fill=degree))+
	geom_boxplot(outlier.size=NA)+
	ylim(0, 8)+
	scale_x_discrete(limits=c("ensino-fundamental","ensino-medio","graduacao","especializacao", "mestrado", "doutorado","pos-doutorado","sem-formacao"))

ggplot(df, aes(x=degree,y=degree_count))+
	geom_boxplot(outlier.size=NA)+
	ylim(0, 15)+
	scale_x_discrete(limits=c("ensino-fundamental","ensino-medio","graduacao","especializacao", "mestrado", "doutorado","pos-doutorado","sem-formacao"))

ggplot(df, aes(degree))+
	geom_boxplot(aes(y=degree_count))+
	geom_point(aes(y=degree_count), size=4, alpha=.2)

ggplot(df, aes(degree))+
	geom_boxplot(aes(y=degree_count))+
	scale_x_discrete(limits=c("ensino-fundamental","ensino-medio","graduacao","especializacao", "mestrado", "doutorado","pos-doutorado","sem-formacao"))

ggplot(df, aes(degree))+
	geom_boxplot(aes(y=degree_count))+
	geom_point(aes(y=degree_count), size=4, alpha=.2)+
	scale_x_discrete(limits=c("sem-formacao","ensino-fundamental","ensino-medio","graduacao","especializacao", "mestrado", "doutorado","pos-doutorado"))

ggplot(df, aes(x = degree_count)) +
  stat_density(aes(ymax = ..density..,  ymin = -..density..),
    fill = "grey50", colour = "grey50",
    geom = "ribbon", position = "identity") +
  facet_grid(. ~ degree) +
  coord_flip()

ggplot(diamonds, aes(x = price)) +
  stat_density(aes(ymax = ..density..,  ymin = -..density..),
    fill = "grey50", colour = "grey50",
    geom = "ribbon", position = "identity") +
  facet_grid(. ~ cut) +
  coord_flip()