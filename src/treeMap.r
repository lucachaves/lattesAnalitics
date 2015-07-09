library(RPostgreSQL)
library(treemap)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="mobilitygraph",host="192.168.56.101",port=5432,user="postgres",password="postgres")
sql <- "SELECT place.acronym place, count(*) degree FROM public.edge, public.place WHERE edge.target = place.id AND place.kind = 'instituition' GROUP BY place ORDER BY degree DESC LIMIT 10"
rs <- dbSendQuery(con,sql)
flows <- fetch(rs,n=-1)

imageFile <- paste('./image/tm/rank-intituition-all-start-in.png',sep='')

df <- data.frame(index=flows$place,vSize=flows$degree,vColor=flows$degree)
png(filename = imageFile)
treemap(
	df,
	index="index",
	vSize="vSize",
	vColor="vColor",
	type="value"
)
dev.off()