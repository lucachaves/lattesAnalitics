source('graphics.r')

# sink("outfile.txt")
print("BEGIN")

#### MC,MFC,GM
# generate.graphic(c('mc', 'gm', 'mfc'),c('fft','all','ffft','fff','fnf'),c('state','region','continent'),scalemc=c('normal','log'),scalegm=c('normal','equal0.1'))
# generate.graphic(c('mc', 'gm'),c('fft','all','ffft','fff','fnf'),c('country'),scalemc=c('normal','log'),scalegm=c('normal','equal0.1'))
generate.graphic(c('mfc'),c('fff'),c('country'))
# generate.graphic(c('mfc'),c('fnf','fff','fft','ffft','all'),c('country'))
# generate.graphic(c('gm'),c('all'),c('city'),kindTime=c('all-time'),scale=c('equal0.1')) #HARD

#### MC maxvalue
# generate.graphic(c('mc'),c('fnf'),c('state'),kindTime=c('set-year-1973-1983-1993-2003-2013'),scalemc=c('normal','log'),scalegm=c('normal','equal0.1'),maxvalue=TRUE)
#### MC textvalue
# generate.graphic(c('mc'),c('fff'),c('region'),kindTime=c('all-time'),scalemc=c('normal'), textvalue=TRUE)
#### MC fff doutorado
# generate.graphic(c('mc', 'gm', 'mfc'),c('fff'),c('country'),filter=c('doutorado'))
#### MFC excludeAllBrazilFlows
# generate.graphic(c('mfc'),c('fff'),c('country'),kindTime=c('all-time'), filter=c('excludeAllBrazilFlows'))
#### MFC excludeFlowsInBrazil
# generate.graphic(c('mfc'),c('fff'),c('country'),kindTime=c('all-time'), filter=c('excludeFlowsInBrazil'))
#### GM topDegreeInst & textvalue
# generate.graphic(c('gm'),c('ffft'),c('instituition'),kindTime=c('all-time'), filter=c('topDegreeInst'), scalegm=c('equal0.1'), mapview='state', textvalue=TRUE)
#### GM specificPerson
# generate.graphic(c('gm'),c('all'),c('city'),kindTime=c('all-time'), filter=c('specificPerson-1982919735990024'), scalegm=c('equal0.1'), mapview='state') # Alexandre
#### GM groupPeople
# generate.graphic(c('gm'),c('all'),c('city'),kindTime=c('all-time'), filter=c('groupPeople-pqComp'), scalegm=c('equal0.1'), mapview='state')
#### GM (to/from)-doutorado-(place)
# generate.graphic(c('gm'),c('fff'),c('instituition'),kindTime=c('all-time'),filter=c('to-doutorado-USP'), scalegm=c('equal0.1'))
# generate.graphic(c('gm'),c('fff'),c('instituition'),kindTime=c('all-time'),filter=c('from-doutorado-USP'), scalegm=c('equal0.1'))
# generate.graphic(c('gm'),c('fff'),c('instituition'),kindTime=c('all-time'),filter=c('to-doutorado-UFPE'), scalegm=c('equal0.1'))
# generate.graphic(c('gm'),c('fff'),c('instituition'),kindTime=c('all-time'),filter=c('from-doutorado-UFPE'), scalegm=c('equal0.1'))
# generate.graphic(c('gm'),c('fff'),c('instituition'),kindTime=c('all-time'),filter=c('to-doutorado-USP','excludeFlowsInBrazil'), scalegm=c('equal0.1'))

#### TIMELINE
# generate.graphic.timeline('instituition','fff',filter=c('doutorado','rangeYear-1950-2013'))
# generate.graphic.timeline('instituition','fff',scale='log',filter=c('doutorado','rangeYear-1950-2013'))
# generate.graphic.timeline('city','fff',scale='log',kindNode='target',filter=c('doutorado','rangeYear-1950-2013'))
# generate.graphic.timeline('city','fff',scale='log',kindNode='source',filter=c('doutorado','rangeYear-1950-2013'))
# generate.graphic.timeline('city','fnf',scale='log')

#### TREEMAP
# generate.graphic.treemap('instituition','fff',filter=c('doutorado','rangeYear-1950-2013')) 
# generate.graphic.treemap('instituition','fff',kindNode='source', limit=30,filter=c('doutorado','rangeYear-1950-2013'))
# generate.graphic.treemap('instituition','fff',kindNode='all',limit=30,filter=c('doutorado','rangeYear-1950-2013'))
# generate.graphic.treemap('instituition','fff',kindNode='target',limit=30,include='all',filter=c('doutorado','rangeYear-1950-2013'))
# generate.graphic.treemap('instituition','fnf',kindNode='target',limit=30,filter=c('rangeYear-1950-2013'))
# generate.graphic.treemap('instituition','fnf',kindNode='target',limit=30,include='all',filter=c('rangeYear-1950-2013'))
# generate.graphic.treemap('instituition','fft',kindNode='source', limit=30)
# generate.graphic.treemap('instituition','fft',kindNode='target', limit=30)

#### LINE
# generate.graphic.line('doutorado')
# generate.graphic.line('doutorado-all-nacional')
# generate.graphic.line('doutorado-all-pop-log')

#### PIE
# TODO

#### BAR
# TODO

#### GENERATE QUERY
# print(generate.all.query('city', 'fnf',kindNode='all'))
# print(generate.all.query('city', 'fnf',kindNode='target'))
# print(generate.all.query('city', 'fnf',kindNode='source'))
# print(generate.all.query('city', 'ffft',kindNode='all'))
# print(generate.all.query('city', 'ffft',kindNode='target'))
# print(generate.all.query('city', 'ffft',kindNode='source'))
# print(generate.all.query('city', 'all',kindNode='all'))
# print(generate.all.query('city', 'all',kindNode='target'))
# print(generate.all.query('city', 'all',kindNode='source'))

# print(generate.all.query('country', 'fnf',kindNode='all'))
# print(generate.all.query('country', 'fnf',kindNode='target'))
# print(generate.all.query('country', 'fnf',kindNode='source'))
# print(generate.all.query('country', 'ffft',kindNode='all'))
# print(generate.all.query('country', 'ffft',kindNode='target'))
# print(generate.all.query('country', 'ffft',kindNode='source'))
# print(generate.all.query('country', 'all',kindNode='all'))
# print(generate.all.query('country', 'all',kindNode='target'))
# print(generate.all.query('country', 'all',kindNode='source'))

# print(generate.all.query('instituition', 'fnf',kindNode='all'))
# print(generate.all.query('instituition', 'fnf',kindNode='target'))
# print(generate.all.query('instituition', 'fnf',kindNode='source'))
# print(generate.all.query('instituition', 'ffft',kindNode='all'))
# print(generate.all.query('instituition', 'ffft',kindNode='target'))
# print(generate.all.query('instituition', 'ffft',kindNode='source'))
# print(generate.all.query('instituition', 'all',kindNode='all'))
# print(generate.all.query('instituition', 'all',kindNode='target'))
# print(generate.all.query('instituition', 'all',kindNode='source'))

#### name-count
# print(generate.all.query('instituition', 'all', kindNode='all',kindQuery='id-acronym'))
# print(generate.query('instituition', 'all', kindQuery='name-count', kindNode='all', limit=10, filter=c('doutorado')))
# TODO print(generate.query('instituition', 'all', kindQuery='name-count', kindNode='all', filter=c(), limit=10))

#### DB
# getdata('select * from place')

print("END")
# sink()