library(circlize)
library(gridExtra)
library(ggplot2)

generate.chordGraph <- function(imageFile, mat, kindContext){
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
		grid.col["MT"] = "#444444"
		grid.col["MS"] = "#FF00AA"
		grid.col["MG"] = "#00AAAA"
		grid.col["PA"] = "#FFAAFF"
		grid.col["PB"] = "#FFAA00"
		grid.col["PR"] = "#FFAAAA"
		grid.col["PE"] = "#8B4513"
		grid.col["PI"] = "#AA00FF"
		grid.col["RJ"] = "#AA00AA"
		grid.col["RN"] = "#AAFFFF"
		grid.col["RS"] = "#AAFF00"
		grid.col["RO"] = "#AAFFAA"
		grid.col["RR"] = "#AAAA00"
		grid.col["SC"] = "#AAAAFF"
		grid.col["SP"] = "#A83938"
		grid.col["SE"] = "#FAFAFA"
		grid.col["TO"] = "#AFAFAF"
	}else if(kindContext == "country"){
		# http://www.worldatlas.com/aatlas/ctycodes.htm
		grid.col["BRA"] = "#00FF00"
		grid.col["ESP"] = "#00FFFF"
		grid.col["USA"] = "#FF0000"
		grid.col["GBR"] = "#FF00FF"
		grid.col["CAN"] = "#FFFF00"
		grid.col["FRA"] = "#CCCCCC"
		grid.col["PRT"] = "#0000AA"
		grid.col["BEL"] = "#00FFAA"
		grid.col["URY"] = "#00AA00"
		grid.col["DEU"] = "#00AAFF"
		grid.col["AUS"] = "#00AAAA"
		grid.col["COL"] = "#FF00AA"
		grid.col["BLZ"] = "#FFFFAA"
		grid.col["ARG"] = "#FFAA00"
		grid.col["JPN"] = "#FFAAFF"
		grid.col["CHL"] = "#FFAAAA"
		grid.col["NLD"] = "#AA0000"
		grid.col["ITA"] = "#AA00FF"
		grid.col["PER"] = "#AA00AA"
		grid.col["DNK"] = "#AAFF00"
		grid.col["CHE"] = "#AAFFFF"
		grid.col["SWE"] = "#AAFFAA"
		grid.col["CUB"] = "#AAAA00"
		grid.col["VEN"] = "#AAAAFF"
	}
	grid.col
}
