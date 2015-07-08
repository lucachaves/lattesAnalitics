require 'csv'
require 'byebug'
require 'progress_bar'
# require 'sequel'
# db_inep = Sequel.connect('postgres://postgres:postgres@10.0.1.7/inep-curso')

@latitude_continent = {}
@latitude_continent["america do norte"] = {latitude: 48.1667, longitude: -100.1667}
@latitude_continent["america central"] = {latitude: 17.4, longitude: -91.0}
@latitude_continent["america do sul"] = {latitude: -13.0, longitude: -59.4}
@latitude_continent["europa"] = {latitude: 54.9, longitude: 25.3167}
@latitude_continent["africa"] = {latitude: 7.1881, longitude: 21.0936}
@latitude_continent["oceania"] = {latitude: -30.0, longitude: 140.0}
@latitude_continent["asia"] = {latitude: 46.283, longitude: 86.67}

def continent_latitude(continent)
	@latitude_continent[continent]
end

@latitude_country = {}
@latitude_country["montenegro"] = {latitude: 42.708678, longitude: 19.37439, continent: "europa"}
@latitude_country["united kingdom"] = {latitude: 55.378051, longitude: -3.435973, continent: "europa"}
@latitude_country["greece"] = {latitude: 39.074208, longitude: 21.824312, continent: "europa"}
@latitude_country["denmark"] = {latitude: 56.26392, longitude: 9.501785, continent: "europa"}
@latitude_country["slovakia"] = {latitude: 48.669026, longitude: 19.699024, continent: "europa"}
@latitude_country["switzerland"] = {latitude: 46.818188, longitude: 8.227511999999999, continent: "europa"}
@latitude_country["armenia"] = {latitude: 40.069099, longitude: 45.038189, continent: "europa"}
@latitude_country["italy"] = {latitude: 41.87194, longitude: 12.56738, continent: "europa"}
@latitude_country["croatia"] = {latitude: 45.1, longitude: 15.2, continent: "europa"}
@latitude_country["bulgaria"] = {latitude: 42.733883, longitude: 25.48583, continent: "europa"}
@latitude_country["lithuania"] = {latitude: 55.169438, longitude: 23.881275, continent: "europa"}
@latitude_country["portugal"] = {latitude: 39.39987199999999, longitude: -8.224454, continent: "europa"}
@latitude_country["romania"] = {latitude: 45.943161, longitude: 24.96676, continent: "europa"}
@latitude_country["norway"] = {latitude: 60.47202399999999, longitude: 8.468945999999999, continent: "europa"}
@latitude_country["finland"] = {latitude: 61.92410999999999, longitude: 25.748151, continent: "europa"}
@latitude_country["belarus"] = {latitude: 53.709807, longitude: 27.953389, continent: "europa"}
@latitude_country["slovenia"] = {latitude: 46.151241, longitude: 14.995463, continent: "europa"}
@latitude_country["moldova"] = {latitude: 47.411631, longitude: 28.369885, continent: "europa"}
@latitude_country["estonia"] = {latitude: 58.595272, longitude: 25.013607, continent: "europa"}
@latitude_country["ukraine"] = {latitude: 48.379433, longitude: 31.16558, continent: "europa"}
@latitude_country["serbia"] = {latitude: 44.016521, longitude: 21.005859, continent: "europa"}
@latitude_country["netherlands"] = {latitude: 52.132633, longitude: 5.291265999999999, continent: "europa"}
@latitude_country["bosnia and herzegovina"] = {latitude: 43.915886, longitude: 17.679076, continent: "europa"}
@latitude_country["poland"] = {latitude: 51.919438, longitude: 19.145136, continent: "europa"}
@latitude_country["belgium"] = {latitude: 50.503887, longitude: 4.469936, continent: "europa"}
@latitude_country["czech republic"] = {latitude: 49.81749199999999, longitude: 15.472962, continent: "europa"}
@latitude_country["liechtenstein"] = {latitude: 47.166, longitude: 9.555373, continent: "europa"}
@latitude_country["sweden"] = {latitude: 60.12816100000001, longitude: 18.643501, continent: "europa"}
@latitude_country["ireland"] = {latitude: 53.41291, longitude: -8.24389, continent: "europa"}
@latitude_country["georgia"] = {latitude: 32.1656221, longitude: -82.9000751, continent: "europa"}
@latitude_country["germany"] = {latitude: 51.165691, longitude: 10.451526, continent: "europa"}
@latitude_country["hungary"] = {latitude: 47.162494, longitude: 19.503304, continent: "europa"}
@latitude_country["france"] = {latitude: 46.227638, longitude: 2.213749, continent: "europa"}
@latitude_country["spain"] = {latitude: 40.46366700000001, longitude: -3.74922, continent: "europa"}
@latitude_country["austria"] = {latitude: 47.516231, longitude: 14.550072, continent: "europa"}
@latitude_country["monaco"] = {latitude: 43.73841760000001, longitude: 7.424615799999999, continent: "europa"}
@latitude_country["latvia"] = {latitude: 56.879635, longitude: 24.603189, continent: "europa"}
@latitude_country["albania"] = {latitude: 41.153332, longitude: 20.168331, continent: "europa"}
@latitude_country["macedonia"] = {latitude: 41.608635, longitude: 21.745275, continent: "europa"}
@latitude_country["gibraltar"] = {latitude: 36.140751, longitude: -5.353585, continent: "europa"}

@latitude_country["israel"] = {latitude: 31.046051, longitude: 34.851612, continent: "asia"}
@latitude_country["china"] = {latitude: 35.86166, longitude: 104.195397, continent: "asia"}
@latitude_country["south korea"] = {latitude: 35.907757, longitude: 127.766922, continent: "asia"}
@latitude_country["yemen"] = {latitude: 15.552727, longitude: 48.516388, continent: "asia"}
@latitude_country["iraq"] = {latitude: 33.223191, longitude: 43.679291, continent: "asia"}
@latitude_country["azerbaijan"] = {latitude: 40.143105, longitude: 47.576927, continent: "asia"}
@latitude_country["palestinian territory"] = {latitude: 31.9465703, longitude: 35.3027226, continent: "asia"}
@latitude_country["taiwan"] = {latitude: 23.69781, longitude: 120.960515, continent: "asia"}
@latitude_country["indonesia"] = {latitude: -0.789275, longitude: 113.921327, continent: "asia"}
@latitude_country["uzbekistan"] = {latitude: 41.377491, longitude: 64.585262, continent: "asia"}
@latitude_country["lebanon"] = {latitude: 33.854721, longitude: 35.862285, continent: "asia"}
@latitude_country["japan"] = {latitude: 36.204824, longitude: 138.252924, continent: "asia"}
@latitude_country["turkey"] = {latitude: 38.963745, longitude: 35.243322, continent: "asia"}
@latitude_country["kazakhstan"] = {latitude: 48.019573, longitude: 66.923684, continent: "asia"}
@latitude_country["philippines"] = {latitude: 12.879721, longitude: 121.774017, continent: "asia"}
@latitude_country["hong kong"] = {latitude: 22.396428, longitude: 114.109497, continent: "asia"}
@latitude_country["syria"] = {latitude: 34.80207499999999, longitude: 38.996815, continent: "asia"}
@latitude_country["pakistan"] = {latitude: 30.375321, longitude: 69.34511599999999, continent: "asia"}
@latitude_country["malaysia"] = {latitude: 4.210484, longitude: 101.975766, continent: "asia"}
@latitude_country["bangladesh"] = {latitude: 23.684994, longitude: 90.356331, continent: "asia"}
@latitude_country["iran"] = {latitude: 32.427908, longitude: 53.688046, continent: "asia"}
@latitude_country["russia"] = {latitude: 61.52401, longitude: 105.318756, continent: "asia"}
@latitude_country["thailand"] = {latitude: 15.870032, longitude: 100.992541, continent: "asia"}
@latitude_country["india"] = {latitude: 20.593684, longitude: 78.96288, continent: "asia"}
@latitude_country["east timor"] = {latitude: -8.874217, longitude: 125.727539, continent: "asia"}
@latitude_country["vietnam"] = {latitude: 14.058324, longitude: 108.277199, continent: "asia"}
@latitude_country["jordan"] = {latitude: 30.585164, longitude: 36.238414, continent: "asia"}

@latitude_country["madagascar"] = {latitude: -18.766947, longitude: 46.869107, continent: "africa"}
@latitude_country["tunisia"] = {latitude: 33.886917, longitude: 9.537499, continent: "africa"}
@latitude_country["nicaragua"] = {latitude: 12.865416, longitude: -85.207229, continent: "africa"}
@latitude_country["guinea bissau"] = {latitude: 11.803749, longitude: -15.180413, continent: "africa"}
@latitude_country["senegal"] = {latitude: 14.497401, longitude: -14.452362, continent: "africa"}
@latitude_country["democratic republic of the congo"] = {latitude: -4.038333, longitude: 21.758664, continent: "africa"}
@latitude_country["egypt"] = {latitude: 26.820553, longitude: 30.802498, continent: "africa"}
@latitude_country["liberia"] = {latitude: 6.428055, longitude: -9.429499000000002, continent: "africa"}
@latitude_country["togo"] = {latitude: 8.619543, longitude: 0.824782, continent: "africa"}
@latitude_country["zambia"] = {latitude: -13.133897, longitude: 27.849332, continent: "africa"}
@latitude_country["nigeria"] = {latitude: 9.081999, longitude: 8.675277, continent: "africa"}
@latitude_country["ivory coast"] = {latitude: 7.539988999999999, longitude: -5.547079999999999, continent: "africa"}
@latitude_country["south africa"] = {latitude: -30.559482, longitude: 22.937506, continent: "africa"}
@latitude_country["ethiopia"] = {latitude: 9.145000000000001, longitude: 40.489673, continent: "africa"}
@latitude_country["cameroon"] = {latitude: 7.369721999999999, longitude: 12.354722, continent: "africa"}
@latitude_country["tanzania"] = {latitude: -6.369028, longitude: 34.888822, continent: "africa"}
@latitude_country["sudan"] = {latitude: 12.862807, longitude: 30.217636, continent: "africa"}
@latitude_country["zimbabwe"] = {latitude: -19.015438, longitude: 29.154857, continent: "africa"}
@latitude_country["ghana"] = {latitude: 7.946527, longitude: -1.023194, continent: "africa"}
@latitude_country["republic of the congo"] = {latitude: -0.228021, longitude: 15.827659, continent: "africa"}
@latitude_country["kenya"] = {latitude: -0.023559, longitude: 37.906193, continent: "africa"}
@latitude_country["mozambique"] = {latitude: -18.665695, longitude: 35.529562, continent: "africa"}
@latitude_country["angola"] = {latitude: -11.202692, longitude: 17.873887, continent: "africa"}
@latitude_country["niger"] = {latitude: 17.607789, longitude: 8.081666, continent: "africa"}
@latitude_country["morocco"] = {latitude: 31.791702, longitude: -7.092619999999999, continent: "africa"}
@latitude_country["gabon"] = {latitude: -0.803689, longitude: 11.609444, continent: "africa"}
@latitude_country["macao"] = {latitude: 22.198745, longitude: 113.543873, continent: "africa"}
@latitude_country["cape verde"] = {latitude: 15.120142, longitude: -23.6051721, continent: "africa"}
@latitude_country["rwanda"] = {latitude: -1.940278, longitude: 29.873888, continent: "africa"}
@latitude_country["burkina faso"] = {latitude: 12.238333, longitude: -1.561593, continent: "africa"}
@latitude_country["mauritania"] = {latitude: 21.00789, longitude: -10.940835, continent: "africa"}
@latitude_country["algeria"] = {latitude: 28.033886, longitude: 1.659626, continent: "africa"}
@latitude_country["mauritius"] = {latitude: -20.348404, longitude: 57.55215200000001, continent: "africa"}
@latitude_country["benin"] = {latitude: 9.30769, longitude: 2.315834, continent: "africa"}

@latitude_country["australia"] = {latitude: -25.274398, longitude: 133.775136, continent: "oceania"}
@latitude_country["new zealand"] = {latitude: -40.900557, longitude: 174.885971, continent: "oceania"}
@latitude_country["samoa"] = {latitude: -13.759029, longitude: -172.104629, continent: "oceania"}
@latitude_country["papua new guinea"] = {latitude: -6.314992999999999, longitude: 143.95555, continent: "oceania"}

@latitude_country["united states"] = {latitude: 37.09024, longitude: -95.712891, continent: "america do norte"}
@latitude_country["mexico"] = {latitude: 23.634501, longitude: -102.552784, continent: "america do norte"}
@latitude_country["canada"] = {latitude: 56.130366, longitude: -106.346771, continent: "america do norte"}

@latitude_country["dominican republic"] = {latitude: 18.735693, longitude: -70.162651, continent: "america central"}
@latitude_country["panama"] = {latitude: 8.537981, longitude: -80.782127, continent: "america central"}
@latitude_country["martinique"] = {latitude: 14.641528, longitude: -61.024174, continent: "america central"}
@latitude_country["honduras"] = {latitude: 15.199999, longitude: -86.241905, continent: "america central"}
@latitude_country["trinidad and tobago"] = {latitude: 10.691803, longitude: -61.222503, continent: "america central"}
@latitude_country["sao tome and principe"] = {latitude: 0.18636, longitude: 6.613080999999999, continent: "america central"}
@latitude_country["costa rica"] = {latitude: 9.748916999999999, longitude: -83.753428, continent: "america central"}
@latitude_country["puerto rico"] = {latitude: 18.220833, longitude: -66.590149, continent: "america central"}
@latitude_country["jamaica"] = {latitude: 18.109581, longitude: -77.297508, continent: "america central"}
@latitude_country["cuba"] = {latitude: 21.521757, longitude: -77.781167, continent: "america central"}
@latitude_country["el salvador"] = {latitude: 13.794185, longitude: -88.89653, continent: "america central"}
@latitude_country["guatemala"] = {latitude: 15.783471, longitude: -90.23075899999999, continent: "america central"}
@latitude_country["belize"] = {latitude: 17.189877, longitude: -88.49765, continent: "america central"}
@latitude_country["guadeloupe"] = {latitude: 16.265, longitude: -61.55099999999999, continent: "america central"}

@latitude_country["ecuador"] = {latitude: -1.831239, longitude: -78.18340599999999, continent: "america do sul"}
@latitude_country["brazil"] = {latitude: -14.235004, longitude: -51.92528, continent: "america do sul"}
@latitude_country["bolivia"] = {latitude: -16.290154, longitude: -63.58865299999999, continent: "america do sul"}
@latitude_country["chile"] = {latitude: -35.675147, longitude: -71.542969, continent: "america do sul"}
@latitude_country["paraguay"] = {latitude: -23.442503, longitude: -58.443832, continent: "america do sul"}
@latitude_country["suriname"] = {latitude: 3.919305, longitude: -56.027783, continent: "america do sul"}
@latitude_country["peru"] = {latitude: -9.189967, longitude: -75.015152, continent: "america do sul"}
@latitude_country["guyana"] = {latitude: 4.860416, longitude: -58.93018, continent: "america do sul"}
@latitude_country["colombia"] = {latitude: 4.570868, longitude: -74.297333, continent: "america do sul"}
@latitude_country["uruguay"] = {latitude: -32.522779, longitude: -55.765835, continent: "america do sul"}
@latitude_country["argentina"] = {latitude: -38.416097, longitude: -63.61667199999999, continent: "america do sul"}
@latitude_country["venezuela"] = {latitude: 6.42375, longitude: -66.58973, continent: "america do sul"}

def country_latitude(country)
	@latitude_country[country]
end

@latitude_region = {}
@latitude_region["norte"] = {latitude: -4.603292, longitude: -59.199124}
@latitude_region["nordeste"] = {latitude: -8.624365, longitude: -41.742753}
@latitude_region["centro-oeste"] = {latitude: -15.298172, longitude: -54.305408}
@latitude_region["sudeste"] = {latitude: -19.730012, longitude: -45.483580}
@latitude_region["sul"] = {latitude: -27.542207, longitude: -52.252997}

def region_latitude(region)
	@latitude_region[region]
end

@latitude_state = {}
@latitude_state["acre"] = {latitude: -9.11, longitude: -70.52, region: "norte"}
@latitude_state["roraima"] = {latitude: 2.05, longitude: -61.4, region: "norte"}
@latitude_state["rondonia"] = {latitude: -10.9, longitude: -62.76, region: "norte"}
@latitude_state["amapa"] = {latitude: 1, longitude: -52, region: "norte"}
@latitude_state["amazonas"] = {latitude: -5, longitude: -63, region: "norte"}
@latitude_state["para"] = {latitude: -5.666667, longitude: -52.733333, region: "norte"}
@latitude_state["tocantins"] = {latitude: -10.183333, longitude: -48.333333, region: "norte"}
@latitude_state["alagoas"] = {latitude: -9.57, longitude: -36.55, region: "nordeste"}
@latitude_state["bahia"] = {latitude: -12.52, longitude: -41.69, region: "nordeste"}
@latitude_state["ceara"] = {latitude: -5.08, longitude: -39.65, region: "nordeste"}
@latitude_state["maranhao"] = {latitude: -6.183333, longitude: -45.616667, region: "nordeste"}
@latitude_state["paraiba"] = {latitude: -7.166667, longitude: -36.833333, region: "nordeste"}
@latitude_state["pernambuco"] = {latitude: -8.34, longitude: -37.81, region: "nordeste"}
@latitude_state["rio grande do norte"] = {latitude: -5.74, longitude: -36.55, region: "nordeste"}
@latitude_state["sergipe"] = {latitude: -10.59, longitude: -37.38, region: "nordeste"}
@latitude_state["piaui"] = {latitude: -8.233333, longitude: -43.1, region: "nordeste"}
@latitude_state["federal district"] = {latitude: -15.795, longitude: -47.757778, region: "centro-oeste"}
@latitude_state["goias"] = {latitude: -15.933333, longitude: -50.133333, region: "centro-oeste"}
@latitude_state["mato grosso"] = {latitude: -15.566667, longitude: -56.066667, region: "centro-oeste"}
@latitude_state["mato grosso do sul"] = {latitude: -20.442778, longitude: -54.645833, region: "centro-oeste"}
@latitude_state["espirito santo"] = {latitude: -20.318889, longitude: -40.337778, region: "sudeste"}
@latitude_state["minas gerais"] = {latitude: -19.816667, longitude: -43.95, region: "sudeste"}
@latitude_state["rio de janeiro"] = {latitude: -22.9, longitude: -43.2, region: "sudeste"}
@latitude_state["sao paulo"] = {latitude: -23.533333, longitude: -46.633333, region: "sudeste"}
@latitude_state["parana"] = {latitude: -24, longitude: -51, region: "sul"}
@latitude_state["rio grande do sul"] = {latitude: -30, longitude: -53, region: "sul"}
@latitude_state["santa catarina"] = {latitude: -27.25, longitude: -50.333333, region: "sul"}

def state_latitude(state)
	@latitude_state[state]
end

places_extra = []
places_key = {}
countNode = 0
@latitude_continent.each{|name,value|
	countNode += 1
	places_extra << [countNode,name,"continent",value[:latitude],value[:longitude],nil]
	places_key[name] = countNode
}

@latitude_country.each{|name,value|
	countNode += 1
	places_extra << [countNode,name,"country",value[:latitude],value[:longitude],places_key[value[:continent]]]
	places_key[name] = countNode
}

@latitude_region.each{|name,value|
	countNode += 1
	places_extra << [countNode,name,"region",value[:latitude],value[:longitude],places_key['brazil']]
	places_key[name] = countNode
}

@latitude_state.each{|name,value|
	countNode += 1
	places_extra << [countNode,name,"state",value[:latitude],value[:longitude],places_key[value[:region]]]
	places_key[name] = countNode
}


def sort_degrees(degrees)
	list = {}
	degrees.each{|deg|
		start_year = deg[6]
		start_year = start_year.to_i unless start_year.nil?
		end_year = deg[7]
		end_year = end_year.to_i unless end_year.nil?

		index = 0
		if start_year.nil? and end_year.nil?
			index = 3000 
		elsif start_year.nil?
			index = end_year 
		elsif end_year.nil?
			index = start_year
		end

		list[index] = deg
	}
	Hash[list.sort].values
end

flow_degrees = [
	"birth",
	"ensino-fundamental",
	"ensino-medio",
	"curso-tecnico",
	"graduacao",
	"aperfeicoamento",
	"residencia",
	"especializacao",
	"mestrado",
	"mestrado-profissionalizante",
	"livre-docencia",
	"doutorado",
	"pos-doutorado",
	"work",
]

ids16 = {}
places = {}
cities_key = {}
puts "Iniciar"
locations = CSV.read("../../lattesGephi/data/locationslatlon.csv", col_sep: ';')
# locations = CSV.read("../../lattesGephi/data/locationslatlon2.csv", col_sep: ';')
locations.shift
bar = ProgressBar.new(locations.size)
puts
locations.each{|loc|
	bar.increment!
	id16 = loc[1]
	kind = loc[2]

	mod_class = if kind == "birth"
		"city"
	else
		"instituition"
	end

	place = if mod_class == "city"
		loc[9]
	else
		loc[4]
	end

	id = if mod_class == "city"
		loc[14]+loc[15]
	else
		loc[3]+loc[4]+loc[14]+loc[15]
	end

	ids16[id16] ||= {}
	ids16[id16][kind] ||= [] 
	ids16[id16][kind] << loc 
	if places[id].nil?
		countNode += 1
		places[id] = {id: countNode, place: place, class: mod_class,city: loc[9], state: loc[10], country: loc[12], latitude: loc[14], longitude: loc[15]} 
		cities_key["#{loc[14]},#{loc[15]}"] = countNode if mod_class == "city"
	end
}

csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["id", "name", "kind", "latitude", "longitude", "belong_to"]
	places_extra.each{|place|
		csv << place
	}
	places.each{|index,place|
		if place[:class] == "city"
			if place[:country] == "brazil"
				csv << [place[:id],place[:place],place[:class],place[:latitude],place[:longitude],places_key[place[:state]]]
			else
				csv << [place[:id],place[:place],place[:class],place[:latitude],place[:longitude],places_key[place[:country]]]
			end
		else
			if(!cities_key.has_key?("#{place[:latitude]},#{place[:longitude]}"))
				countNode += 1
				if place[:country] == "brazil"
					csv << [countNode,place[:city],"city",place[:latitude],place[:longitude],places_key[place[:state]]]
				else
					csv << [countNode,place[:city],"city",place[:latitude],place[:longitude],places_key[place[:country]]]
				end
				cities_key["#{place[:latitude]},#{place[:longitude]}"] = countNode
			end
			csv << [place[:id],place[:place],place[:class],nil,nil,cities_key["#{place[:latitude]},#{place[:longitude]}"]]
		end
	}
	
end
File.write("./data/nodes-flow-instituition.csv", csv_string)

ids16flow = {}
bar = ProgressBar.new(ids16.size)
puts
ids16.each{|id16, degrees|
	bar.increment!
	ids16flow[id16] = []
	flow_degrees.each{|degree|
		unless degrees[degree].nil? 
			if degrees[degree].size == 1
				ids16flow[id16] << degrees[degree].first
			else
				sort_degrees(degrees[degree]).each{|deg|
					ids16flow[id16] << deg
				}
			end
		end
	}
}

edges = []
bar = ProgressBar.new(ids16flow.size)
puts
ids16flow.each{|id16, locations|
	bar.increment!
	if locations.size > 1
		source = nil
		locations.each{|location|
			target = location
			edges << {source: source, target: target} unless source.nil?
			source = target
		}
	end
}

network = []
countEdge = 0 
bar = ProgressBar.new(edges.size)
puts
edges.each{|edge|
	bar.increment!
	countEdge += 1

	source = edge[:source]
	target = edge[:target]

	kind = target[2]

	source_id = if kind == "birth"
		edge[:source][14]+edge[:source][15]
	else
		edge[:source][3]+edge[:source][4]+edge[:source][14]+edge[:source][15]
	end

	target_id = edge[:target][3]+edge[:target][4]+edge[:target][14]+edge[:target][15]

	source = places[source_id][:id]
	target = places[target_id][:id]

	id16 = edge[:source][1]

	start_year = edge[:target][6]
	end_year = edge[:target][7]

	network << [kind, source, target, id16, start_year, end_year]
}

csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["id", "kind", "source", "target", "id16", "start_year", "end_year"]
	count = 0
	network.each{|edge|
		count += 1
		csv << [count]+edge
	}
end
csv_string.gsub! "\"\"", ""
File.write("./data/edges-flow-instituition.csv", csv_string)


puts "fim"
