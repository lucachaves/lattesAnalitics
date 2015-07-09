library(ggplot2)
library(RPostgreSQL)
# library(reshape2)
# library(scales)
source('generateQuery.r')

generate.heat <- function(imageFile, df, size=c(1000,1000), label=c('origem','destino')){
  png(filename = imageFile, width = size[1], height = size[2])
  
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
    xlab(label[1])+ylab(label[2])#+ggtitle("Flow")
    # scale_x_discrete(limits=c("AMS","AMC","AMN","EU","AS","OC","AF"))+
    # scale_y_discrete(limits=c("AMS","AMC","AMN","EU","AS","OC","AF"))

  print(gg)
  dev.off()
}

convert.scale.value <- function(data, scale){
  if(scale == "log"){
    if(data >= 1){
      data <- log(data)
    }else{
      data <- 0
    }
  }
  data
}

convert.result.todf.timeline <- function(fname, tname, value){
  namescol <- 1900:2013
  namesrow <- unique(tname)
  mat <- matrix(0, nrow = length(namesrow), ncol = length(namescol))
  rownames(mat) <- namesrow
  colnames(mat) <- namescol
  # print(mat)
  for(i in 1:length(fname)){
    # print(paste(fname[i], tname[i],value[i]))
    mat[fname[i], tname[i]] = value[i]
  }
  from <- c()
  to <- c()
  trips <- c()
  for(i in 1:nrow(mat)){
    for(j in 1:ncol(mat)){
      from <- c(from, namescol[i])
      to <- c(to, namesrow[j])
      trips <- c(trips, mat[i,j])
    }
  }
  df <- data.frame(from=from, to=to,valor=trips)
  df
}

convert.result.todf.square <- function(fname, tname, value){
  names <- union(fname,tname)
  mat <- matrix(0, nrow = length(names), ncol = length(names))
  rownames(mat) <- names
  colnames(mat) <- names
  for(i in 1:length(fname)){
    mat[fname[i], tname[i]] = value[i]
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
  df
}

generate.mc.timeline <- function(imageFile, flows, size=c(1000,300), scale = 'normal'){
  flows$trips <- convert.scale.value(flows$trips, scale)
  df <- convert.result.todf.timeline(flows$eyear, flows$place, flows$degree)
  generate.heat(imageFile, df, label=c('anos','instituição'))
}

generate.mc.square <- function(imageFile, flows, kindContext, scale = 'normal'){
  flows$trips <- convert.scale.value(flows$trips, scale)
  df <- convert.result.todf.square(flows$oname, flows$dname, flows$trips)
  imageFile <- paste('./image/mc/',scale,'-',imageFile,sep='')
  size <- if(kindContext == "region"){
    c(500,450)
  }else if(kindContext == "continent"){
    c(600, 500)
  }else{
    c(1000,1000)
  }
  generate.heat(imageFile, df, size)    
}
