library(ggplot2)
library(RPostgreSQL)
# library(reshape2)
# library(scales)
# source('generateQuery.r')

generate.heat <- function(imageFile, df, kindContext){
  width <- height <- 1000
  if(kindContext == "region"){
    width <- 500
    height <- 450
  }else if(kindContext == "continent"){
    width <- 600
    height <- 500
  }
  png(filename = imageFile, width = width, height = height)
  max_value <- max(df$valor)

  gg <- ggplot(df, aes(x=from, y=to)) +
    geom_tile(aes(fill = valor)) + 
    scale_fill_gradient(low='white', high='grey20')+
    # geom_text(aes(fill = valor, label = round(valor, 1)))+
    # scale_fill_gradient(low = "white", high = "red")+
    # scale_fill_continuous(low = "white", high = "red",limits=c(0, max_value), breaks=seq(1,max_value,by=max_value/6))+
    theme(
      title=element_text(size=14,face="bold"), 
      axis.text=element_text(size=14,face="bold"), 
      axis.title=element_text(size=14,face="bold"),
      axis.text.x=element_text(angle=-90)
    )+
    xlab("origem")+ylab("destino")#+ggtitle("Flow")
    # scale_x_discrete(limits=c("AMS","AMC","AMN","EU","AS","OC","AF"))+
    # scale_y_discrete(limits=c("AMS","AMC","AMN","EU","AS","OC","AF"))

  print(gg)
  dev.off()
}
scale.value <- function(data, scale){
  if(scale == "normal"){
    # 
  }else if(scale == "log"){
    if(data < 1){
      data <- 0
    }else{
      data <- log(data)
    }
  }
  data
}

generate.mc <- function(kindFlow, kindContext, kindTime, valueTime=null, scale='normal'){
  subDir <- paste('data/mc-',kindContext,sep="")
  if(!file.exists(subDir)){
    dir.create(file.path('./', subDir))
  }

  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname="mobilitygraph",host="192.168.56.101",port=5432,user="postgres",password="postgres")
  sqlFile <- paste('./data/table-',kindContext,'/',kindFlow,'-',kindTime, '.sql',sep='')

  if(kindTime == "all"){
    print("generating heat all")
    sql <- paste(readLines(sqlFile),collapse=" ")
    rs <- dbSendQuery(con,sql)
    flows <- fetch(rs,n=-1)
    flows$trips <- scale.value(flows$trips, scale)
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
    df <- data.frame(from=from, to=to,valor=trips)
    imageFile <- paste('./data/mc-',kindContext,'/',kindFlow,'-',scale,'-',kindTime, '.png',sep='')
    generate.heat(imageFile, df, kindContext)
  }else if(kindTime == "rangeAll"){
    print("generating graph rangeAll")
    sql <- paste(readLines(sqlFile),collapse=" ")
    sql <- gsub("_START_YEAR_", valueTime[1], sql)
    sql <- gsub('_END_YEAR_', valueTime[2], sql)
    rs <- dbSendQuery(con,sql)
    flows <- fetch(rs,n=-1)
    flows$trips <- scale.value(flows$trips, scale)
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
    df <- data.frame(from=from, to=to,valor=trips)
    range <- paste(valueTime[1],'-',valueTime[2],sep='')
    imageFile <- paste('./data/mc-',kindContext,'/',kindFlow,'-',scale,'-',range,'.png',sep='')
    generate.heat(imageFile, df, kindContext)
  }else if(kindTime == "rangeYear"){
    for (year in valueTime[1]:valueTime[2]) {
      print(paste("generating graph year ",year,sep=""))
      sql <- paste(readLines(sqlFile),collapse=" ")
      sql <- gsub('_YEAR_', year, sql)
      rs <- dbSendQuery(con,sql)
      flows <- fetch(rs,n=-1)
      flows$trips <- scale.value(flows$trips, scale)
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
      df <- data.frame(from=from, to=to,valor=trips)
      imageFile <- paste('./data/mc-',kindContext,'/',kindFlow,'-',scale,'-',year,'.png',sep='')
      generate.heat(imageFile, df, kindContext)
    }
  }
}
