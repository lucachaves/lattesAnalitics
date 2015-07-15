library(treemap)

generate.treemap <- function(imageFile, flows){
	png(filename = imageFile)
	treemap(
		flows,
		index="index",
		vSize="vSize",
		vColor="vColor",
		type="value"
	)
	dev.off()	
}
