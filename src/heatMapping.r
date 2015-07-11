library(ggplot2)

generate.heatmap <- function(kind, df, scale='normal',textvalue=FALSE, orderrow=NULL, range=NULL, title=FALSE){

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
  
  # max_value <- max(df$valor)
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

  if(textvalue == TRUE){
    gg <- gg + geom_text(aes(fill = valor, label = round(valor, 1)))
  }

  if(title == TRUE){
    gg <- gg+ggtitle(title)
  }  
  
  if(orderrow == TRUE){
    gg <- gg+scale_y_discrete(limits=orderrow)
  }

  gg    
}
