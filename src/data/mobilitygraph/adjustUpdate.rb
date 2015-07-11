# latitude longitude id
# 44.93333 4.9 1183
# -29.684 -53.807 643
# -22.505 -43.179 825

# SELECT city.latitude,city.longitude, inst.id FROM public.place city, public.place inst WHERE inst.belong_to = city.id AND city.kind = 'city' AND inst.kind = 'instituition' GROUP BY inst.id, city.latitude, city.longitude;
# UPDATE place SET latitude=30.62798, longitude=-96.33441 WHERE id=1038 AND kind='instituition'

values = "44.93333 4.9 1183
-29.684 -53.807 643
-22.505 -43.179 825"

rs = values.split("\n").map{|row|
	row = row.split(' ')
	"UPDATE place SET latitude=#{row[0]}, longitude=#{row[1]} WHERE id=#{row[2]} AND kind='instituition'"
}
rs = rs.join(";\n")
File.write('adjustUpdate.sql', rs)

