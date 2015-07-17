require 'progress_bar'
require 'sequel'
require 'byebug'

# https://gist.github.com/j05h/673425
class Numeric
  def to_rad
    self * Math::PI / 180
  end
end

def distance_coord(lat1, lon1, lat2, lon2)
	dLat = (lat2-lat1).to_rad;
	dLon = (lon2-lon1).to_rad;
	a = Math.sin(dLat/2) * Math.sin(dLat/2) +
	   Math.cos(lat1.to_rad) * Math.cos(lat2.to_rad) *
	   Math.sin(dLon/2) * Math.sin(dLon/2);
	c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
	6371 * c;
end

idPlace = "SELECT instituitionTarget.id FROM PUBLIC.edge edge, PUBLIC.place instituitionTarget WHERE edge.kind = 'work' AND edge.target = instituitionTarget.id AND instituitionTarget.kind = 'instituition' GROUP BY instituitionTarget.id"
id16Work = "SELECT edge.id16 FROM PUBLIC.edge edge, PUBLIC.place instituitionTarget WHERE edge.kind = 'work' AND edge.target = instituitionTarget.id AND instituitionTarget.kind = 'instituition'"
id16idPlaceWork = "SELECT edge.id16, instituitionTarget.id, instituitionTarget.acronym FROM PUBLIC.edge edge, PUBLIC.place instituitionTarget WHERE edge.kind = 'work' AND edge.target = instituitionTarget.id AND instituitionTarget.kind = 'instituition'"
flowsById16 = "SELECT edge.id16, citySource.latitude slatitude, citySource.longitude slongitude, instituitionTarget.latitude tlatitude, instituitionTarget.longitude tlongitude FROM PUBLIC.edge edge, PUBLIC.place citySource, PUBLIC.place instituitionTarget WHERE edge.source = citySource.id AND citySource.kind = 'city' AND edge.target = instituitionTarget.id AND instituitionTarget.kind = 'instituition' UNION ALL SELECT edge.id16, instituitionSource.latitude slatitude, instituitionSource.longitude slongitude, instituitionTarget.latitude tlatitude, instituitionTarget.longitude tlongitude FROM PUBLIC.edge edge, PUBLIC.place instituitionSource, PUBLIC.place instituitionTarget WHERE edge.source = instituitionSource.id AND instituitionSource.kind = 'instituition' AND edge.target = instituitionTarget.id AND instituitionTarget.kind = 'instituition' AND edge.id16 IN (#{id16Work})"

mobilitygraph = Sequel.connect('postgres://postgres:postgres@192.168.56.101/mobilitygraph')
flows = mobilitygraph[flowsById16]
bar = ProgressBar.new(flows.count)
dd = {}
flows.each{|row|
	dd[row[:id16]] ||= [] 
	dd[row[:id16]] << distance_coord(row[:slatitude], row[:slongitude], row[:tlatitude], row[:tlongitude])
	bar.increment!
}

dd_sum = {}
dd_count = {}
dd.each{|id16,value|
	dd_sum[id16] = value.inject(:+)
	dd_count[id16] = value.size
}

dd_inst = {}
dd_inst_count = {}
dd_inst_avg = {}
inst_name = {}
mobilitygraph[id16idPlaceWork].each{|row|
	dd_inst[row[:id]] ||= []
	dd_inst_count[row[:id]] ||= []
	dd_inst_avg[row[:id]] ||= []
	dd_inst[row[:id]] << if(dd_sum[row[:id16]].nil?)
		0
	else
		dd_sum[row[:id16]]
	end
	dd_inst_count[row[:id]] << if(dd_count[row[:id16]].nil?)
		0
	else
		dd_count[row[:id16]]
	end
	dd_inst_avg[row[:id]] << if((dd_sum[row[:id16]].nil? | dd_count[row[:id16]].nil?))
		0
	else
		(dd_sum[row[:id16]]/dd_count[row[:id16]])
	end
	inst_name[row[:id]] = row[:acronym] 
}

File.write('data/rank/temp.csv',dd_inst)

dd_inst_info = []
dd_inst_info << "idInst,people,DD,avgDD,D,avgD,avgDDbyPerson"
inst_info = {}
bar = ProgressBar.new(dd_inst.count)
dd_inst.each{|idPlace, value|
	people = dd_inst[idPlace].count
	sum_dd = dd_inst[idPlace].inject(:+)
	sum_dd_avg = sum_dd/people
	count_dd = dd_inst_count[idPlace].inject(:+)
	count_dd_avg = count_dd/people
	avg_dd = dd_inst_avg[idPlace].inject(:+)/people
	dd_inst_info << "#{inst_name[idPlace]};#{people};#{sum_dd};#{sum_dd_avg};#{count_dd};#{count_dd_avg};#{avg_dd}"
	inst_info[inst_name[idPlace].downcase] = [people, sum_dd, sum_dd_avg, count_dd, count_dd_avg, avg_dd] 
	bar.increment!
}
File.write('data/rank/ddInst.csv',dd_inst_info.join("\n"))

igc_info = {}
File.read('data/rank/igc-2013.csv').gsub(/\r\n/,"\n").split("\n")[1..-1].each{|row| 
	igc_info[row.split(";")[3].downcase] = row
}

ruf_info = {}
File.read('data/rank/ruf-2014.csv').gsub(/\r\n/,"\n").split("\n")[1..-1].each{|row|
	ruf_info[row.split(";")[2].downcase] = row
}

rank_igc_ruf = ['sigla;people;DD;avgDD;D;avgD;avgDDbyP;Ano;CodIES;NomeIES;siglai;CategAdmin;OrgAcademica;UF;nAvTri;nCPC;alfa;graduacao;beta;mestrado;doutorado;igcc;igcf;Obs;rufpos;NomeUni;siglar;UFr;PubPri;ensino;pesquisa;mercado;inovacao;interna;rufnota']
instituition = ['USP', 'UFMG', 'UFRJ', 'UFRGS', 'UNICAMP', 'UNESP', 'UFSC', 'UnB', 'UFPR', 'UFSCAR', 
	'UFPE', 'UNIFESP', 'UFC', 'UFBA', 'UFSC', 'UFF', 'UERJ', 'PUCRS', 'UFV', 'UFRN', 'UFG', 'UEM', 
	'UEL', 'UFPB', 'UFPA', 'UFJF', 'UFLA', 'UFU', 'UFSM', 'PUC-RIO', 'UFPEL', 'UFES', 'PUCPR', 'UFS', 
	'UFOP', 'UFMT', 'UFMS', 'UFAL', 'UECE', 'UFAM', 'PUC MINAS', 'UNISINOS', 'UCS', 'UFPI', 'UFABC',
	'UFCG', 'UFRRJ', 'UCB', 'UTFPR', 'PUCSP', 'UFMA','UFRPE', 'UFTM', 'FURG','UEPG','UNIOESTE', 'UESC',
	'UNIFEI', 'UNIFAL-MG', 'PUC-CAMPINAS']

bar = ProgressBar.new(instituition.count)
instituition.each{|inst|
	inst = inst.downcase
	igc = if(igc_info[inst].nil?)
		Array.new(17,'').join("\;")
	else
		igc_info[inst]
	end
	rank_igc_ruf << inst+";"+inst_info[inst].join("\;")+";"+igc+";"+ruf_info[inst]
	bar.increment!
}

File.write('data/rank/rank-ruf-igc.csv',rank_igc_ruf.join("\n"))
