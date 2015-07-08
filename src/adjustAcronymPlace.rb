require 'sequel'
require 'progress_bar'

mobilitygraph = Sequel.connect('postgres://postgres:postgres@192.168.56.101/mobilitygraph')
places = mobilitygraph.from(:place)
# SELECT id, name FROM place
result = places.all
bar = ProgressBar.new(result.count)
result.each{|place|
	# UPDATE place SET (acronym= ?) WHERE id = 
	places.where('id = ?', place[:id]).update(:acronym => place[:name])
	bar.increment!
}