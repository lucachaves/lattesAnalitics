library(circlize)
library(gridExtra)
library(ggplot2)

generate.grid.col <- function(kindContext){
	grid.col = NULL
	if(kindContext == "region"){
		grid.col["CO"] = "#00FFFF"
		grid.col["NE"] = "#FF0000"
		grid.col["N"] = "#FF00FF"
		grid.col["SE"] = "#FFFF00"
		grid.col["S"] = "#CCCCCC"
	}else if(kindContext == "continent"){
		grid.col["AMN"] = "#00FF00"
		grid.col["AMC"] = "#00FFFF"
		grid.col["AMS"] = "#FF0000"
		grid.col["EU"] = "#FF00FF"
		grid.col["AF"] = "#FFFF00"
		grid.col["OC"] = "#CCCCCC"
		grid.col["AS"] = "#0000AA"
	}else if(kindContext == "state"){
		grid.col["AC"] = "#00FF00"
		grid.col["AL"] = "#00FFFF"
		grid.col["AP"] = "#FF0000"
		grid.col["AM"] = "#FF00FF"
		grid.col["BA"] = "#FFFF00"
		grid.col["CE"] = "#CCCCCC"
		grid.col["DF"] = "#0000AA"
		grid.col["ES"] = "#00FFAA"
		grid.col["GO"] = "#00AA00"
		grid.col["MA"] = "#00AAFF"
		grid.col["MT"] = "#00AAAA"
		grid.col["MS"] = "#FF00AA"
		grid.col["MG"] = "#FFFFAA"
		grid.col["PA"] = "#FFAA00"
		grid.col["PB"] = "#FFAAFF"
		grid.col["PR"] = "#FFAAAA"
		grid.col["PE"] = "#AA0000"
		grid.col["PI"] = "#AA00FF"
		grid.col["RJ"] = "#AA00AA"
		grid.col["RN"] = "#AAFF00"
		grid.col["RS"] = "#AAFFFF"
		grid.col["RO"] = "#AAFFAA"
		grid.col["RR"] = "#AAAA00"
		grid.col["SC"] = "#AAAAFF"
		grid.col["SP"] = "#AFAFFF"
		grid.col["SE"] = "#FAFAFA"
		grid.col["TO"] = "#AFAFAF"
	}else if(kindContext == "country"){
		grid.col["brazil"] = "#00FF00"
		grid.col["spain"] = "#00FFFF"
		grid.col["united states"] = "#FF0000"
		grid.col["united kingdom"] = "#FF00FF"
		grid.col["canada"] = "#FFFF00"
		grid.col["france"] = "#CCCCCC"
		grid.col["portugal"] = "#0000AA"
		grid.col["belgium"] = "#00FFAA"
		grid.col["uruguay"] = "#00AA00"
		grid.col["germany"] = "#00AAFF"
		grid.col["australia"] = "#00AAAA"
		grid.col["colombia"] = "#FF00AA"
		grid.col["belize"] = "#FFFFAA"
		grid.col["argentina"] = "#FFAA00"
		grid.col["japan"] = "#FFAAFF"
		grid.col["chile"] = "#FFAAAA"
		grid.col["netherlands"] = "#AA0000"
		grid.col["italy"] = "#AA00FF"
		grid.col["peru"] = "#AA00AA"
		grid.col["denmark"] = "#AAFF00"
		grid.col["switzerland"] = "#AAFFFF"
		grid.col["sweden"] = "#AAFFAA"
		grid.col["cuba"] = "#AAAA00"
		grid.col["venezuela"] = "#AAAAFF"
	}
	grid.col
}

generate.chord <- function(imageFile, mat, kindContext){
	grid.col <- generate.grid.col(kindContext)
	png(imageFile, 1000, 1000, pointsize = 12)
  circos.par(start.degree = 90)

  chordDiagram(
		mat, 
		grid.col = grid.col,
		annotationTrack = "grid", 
		preAllocateTracks = list(track.height = 0.3)
	)

	circos.trackPlotRegion(
		track.index = 1, 
		panel.fun = function(x, y) {
			xlim = get.cell.meta.data("xlim")
			ylim = get.cell.meta.data("ylim")
			sector.name = get.cell.meta.data("sector.index")
			
			circos.text(
				mean(xlim), 
				ylim[1], 
				sector.name, 
				facing = "clockwise",
				niceFacing = TRUE, 
				adj = c(0, 0.5),
				cex = 1.5
			)
		}, 
		bg.border = NA
	)

	circos.clear()

	dev.off()
}

convert.result.tomatrix <- function(flows){
	names <- union(flows$oname,flows$dname)
	mat <- matrix(0, nrow = length(names), ncol = length(names))
	rownames(mat) = names
	colnames(mat) = names
	for(i in 1:nrow(flows)){
		mat[flows[i,]$oname, flows[i,]$dname] = flows[i,]$trips
	}
	mat
}

generate.mfc <- function(imageFile, flows, kindContext){
	mat <- convert.result.tomatrix(flows)
	imageFile <- paste('./image/mfc/',imageFile,sep='')
	generate.chord(imageFile, mat, kindContext)
}
