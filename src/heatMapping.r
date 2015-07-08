library(ggplot2)
library(RPostgreSQL)
# library(reshape2)
# library(scales)

generate.heat <- function(imageFile, df){
  png(filename = imageFile, width = 1000, height = 1000)
  max_value <- max(df$trips)

  gg <- ggplot(df, aes(x=from, y=to)) +
    geom_tile(aes(fill = trips)) + 
    # geom_text(aes(fill = trips, label = round(trips, 1)))+
    # scale_fill_gradient(low = "white", high = "red")+
    # scale_fill_continuous(low = "white", high = "red",limits=c(0, max_value), breaks=seq(1,max_value,by=max_value/6))+
    theme(
      axis.text.x=element_text(angle=-90)
    )+
    xlab("origem")+ylab("destino")#+ggtitle("Flow")

  print(gg)
  dev.off()
}

generate.mc <- function(kindFlow, kindContext, kindTime, valueTime=null){
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname="mobilitygraph",host="192.168.56.101",port=5432,user="postgres",password="postgres")
  sqlFile <- paste('./data/table-',kindContext,'/',kindFlow,'-',kindTime, '.sql',sep='')

  if(kindTime == "all"){
    print("generating heat all")
    sql <- paste(readLines(sqlFile),collapse=" ")
    rs <- dbSendQuery(con,sql)
    flows <- fetch(rs,n=-1)
    names <- union(flows$oname,flows$dname)
    mat <- matrix(0, nrow = length(names), ncol = length(names))
    rownames(mat) = names
    colnames(mat) = names
    for(i in 1:nrow(flows)){
      mat[flows[i,]$oname, flows[i,]$dname] = flows[i,]$trips
    }
    from <- c()
    to <- c()
    trips <- c()
    for(i in 1:nrow(mat)){
      for(j in 1:ncol(mat)){
        from <- c(from, names[i])
        to <- c(to, names[j])
        trips <- c(trips, mat[i,j])
      }
    }
    df <- data.frame(from=from, to=to,trips=trips)
    imageFile <- paste('./data/mc-',kindContext,'/',kindFlow,'-',kindTime, '.png',sep='')
    generate.heat(imageFile, df)
  }
}

generate.mc("fnf", "region", "all")
# generate.mc("fff", "region", "all")
# generate.mc("fft", "region", "all")
# generate.mc("all", "region", "all")
# generate.mc("fnf", "region", "rangeAll", c(2000,2013))
# generate.mc("fnf", "region", "rangeYear", c(2000,2013))
