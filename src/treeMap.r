library(treemap)

generate.graphic.tm <- function(imageFile, flows){
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
}
