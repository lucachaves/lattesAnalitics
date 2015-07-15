library(ggplot2)

generate.heatmap <- function(kind, df, scale='normal',textvalue=FALSE, orderrow=FALSE, range=NULL, title=FALSE, maxvalue=FALSE){

  label <- if(kind == 'square') 
    c('origem','destino')
  else if(kind == 'timeline'){
    c('anos','instituição')
  }

  xangle <- if(kind == 'square') 
    -90
  else if(kind == 'timeline'){
    0
  }
  
  gg <- ggplot(df, aes(x=from, y=to)) +
    geom_tile(aes(fill = valor)) + 
    theme(
      title=element_text(size=14,face="bold"), 
      axis.text=element_text(size=14,face="bold"), 
      axis.title=element_text(size=14,face="bold"),
      axis.text.x=element_text(angle=xangle)
    )+
    xlab(label[1])+ylab(label[2])

  # white,red
  if(maxvalue != FALSE){
    gg <- gg + scale_fill_continuous(low="white", high="grey20", limits=c(0, maxvalue), breaks=round(seq(1,maxvalue,by=maxvalue/5)))
  }else{
    gg <- gg + scale_fill_gradient(low='white', high='grey20') 
  }

  if(textvalue == TRUE){
    gg <- gg + geom_text(aes(fill = valor, label = round(valor, 1)))
  }

  if(title != FALSE){
    gg <- gg+ggtitle(title)
  }  
  
  if(orderrow != FALSE){
    gg <- gg+scale_y_discrete(limits=orderrow)
  }

  gg    
}
