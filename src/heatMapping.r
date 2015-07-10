library(ggplot2)

generate.heat <- function(imageFile, df, size=c(1000,1000), label=c('origem','destino'), orderrow=FALSE, title=FALSE,xangle=-90){
  png(filename = imageFile, width = size[1], height = size[2])
  
  max_value <- max(df$valor)

  gg <- ggplot(df, aes(x=from, y=to)) +
    geom_tile(aes(fill = valor)) + 
    scale_fill_gradient(low='white', high='grey20')+ # white,red
    # scale_fill_continuous(low = "white", high = "red",limits=c(0, max_value), breaks=seq(1,max_value,by=max_value/6))+
    theme(
      title=element_text(size=14,face="bold"), 
      axis.text=element_text(size=14,face="bold"), 
      axis.title=element_text(size=14,face="bold"),
      axis.text.x=element_text(angle=xangle)
    )+
    xlab(label[1])+ylab(label[2])
  
  # TODO gg <- gg + geom_text(aes(fill = valor, label = round(valor, 1)))

  if(title != FALSE){
    gg <- gg+ggtitle(title)
  }  
  
  if(orderrow != FALSE){
    gg <- gg+scale_y_discrete(limits=orderrow)
  }

  print(gg)
  dev.off()
}

convert.scale.value <- function(data, scale){
  if(scale == 'log'){
    # if(data >= 1){
      data <- log(data)
    # }else{
    #   data <- 0
    # }
  }
  data
}

convert.result.todf.timeline <- function(fname, tname, value, range){
  namescol <- range[1]:range[2]
  namesrow <- unique(tname)
  mat <- matrix(0, nrow = length(namesrow), ncol = length(namescol))
  rownames(mat) <- namesrow
  colnames(mat) <- namescol
  for(i in 1:length(fname)){
    mat[tname[i],toString(fname[i])] = value[i]
  }
  from <- c()
  to <- c()
  trips <- c()
  for(i in 1:length(namesrow)){
    for(j in 1:length(namescol)){
      to <- c(to, namesrow[i])
      from <- c(from, namescol[j])
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

generate.mc.timeline <- function(imageFile, flows, names, range, size=c(1000,200), scale='normal'){
  flows$degree <- convert.scale.value(flows$degree, scale)
  df <- convert.result.todf.timeline(flows$eyear, flows$place, flows$degree, range)
  generate.heat(imageFile, df, size, label=c('anos','instituição'), orderrow=names, xangle=0)
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
