convert.scale.value <- function(data, scale, kindGraphic, kindContext=NULL,kindFlow=NULL,kindTime=NULL){
  if(scale == 'log'){
    data <- log(data)
  }
  if(scale == 'log10'){
    data <- log10(data)
  }
  if(kindGraphic == 'mc'){
  	if(scale == 'normal'){
	    data <- data
	  }	
  }
  if(kindGraphic == 'gm'){
	  if(scale == 'equal1'){
	    data <- rep(0.9,length(data))
	  }
	  if(scale == 'equal0.1'){
	    data <- rep(0,length(data))
	  }
	  if(scale == 'normal'){
	    splitSize <- 0
	    if(kindContext == 'city' & kindFlow == 'all'){
	      splitSize <- 1000
	    }else if(kindContext == 'city'){
	      splitSize <- 50
	    }else if(kindContext == 'state' & kindFlow == 'fnf' & kindTime == 'all'){
	      splitSize <- 5000
	    }else if(kindContext == 'state' & kindFlow == 'fff' & kindTime == 'all'){
	      splitSize <- 5000
	    }else if(kindContext == 'state' & kindFlow == 'fft'){
	      splitSize <- 5000
	    }else if(kindContext == 'state' & kindFlow == 'all'){
	      splitSize <- 10000
	    }else if(kindContext == 'region' & kindTime == 'rangeYear'){
	      splitSize <- 500
	    }else if(kindContext == 'region'){
	      splitSize <- 1500
	    }else if(kindContext == 'state' & kindFlow == 'fnf' & kindTime == 'all'){
	      splitSize <- 500
	    }else if(kindContext == 'state' & kindFlow == 'fff' & kindTime == 'all'){
	      splitSize <- 500
	    }else if(kindContext == 'state' & kindFlow == 'fft'){
	      splitSize <- 500
	    }else if(kindContext == 'state' & kindFlow == 'all'){
	      splitSize <- 1000
	    }else if(kindContext == 'state'){
	      splitSize <- 50
	    }else if(kindContext == 'country' & kindFlow != 'fnf' & kindTime == 'all'){
	      splitSize <- 2000
	    }else if(kindContext == 'country' & kindFlow == 'fnf' & kindTime == 'all'){
	      splitSize <- 500
	    }else if(kindContext == 'country'){
	      splitSize <- 50
	    }else if(kindContext == 'continent' & kindFlow != 'fnf' & kindTime == 'all'){
	      splitSize <- 2000
	    }else if(kindContext == 'continent' & kindFlow != 'fnf'){
	      splitSize <- 200
	    }else if(kindContext == 'continent' & kindFlow == 'fnf' & kindTime == 'all'){
	      splitSize <- 500
	    }else if(kindContext == 'continent' & kindFlow == 'fnf'){
	      splitSize <- 30
	    }else if(kindContext == 'continent'){
	      splitSize <- 30
	    }
	    data <- data/splitSize # TODO maxvalue
	  }
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

convert.result.todf.square <- function(fname, tname, value, orderrow){
  names <- if(orderrow == FALSE)
  	union(fname,tname)
  else{
  	orderrow
  }
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