source('graphics.r')

# getdata('select * from place')

##### TEST ##### 
# sink("outfile.txt")
print("BEGIN")

# MC,MFC,GM
# generate.graphic(c('mc', 'gm', 'mfc'),c('fft','all','ffft','fff','fnf'),c('state','region','continent'),scalemc=c('normal','log'),scalegm=c('normal','equal0.1'))
# generate.graphic(c('mc', 'gm'),c('fft','all','ffft','fff','fnf'),c('country'),scalemc=c('normal','log'),scalegm=c('normal','equal0.1'))
# generate.graphic(c('mfc'),c('fff'),c('country'))
# generate.graphic(c('mfc'),c('fnf','fff','fft','ffft','all'),c('country'))
# generate.graphic(c('gm'),c('all'),c('city'),kindTime=c('all'),scale=c('equal0.1')) #HARD

# MC maxvalue
# generate.graphic(c('mc'),c('fnf'),c('state'),kindTime=c('set-year-1973-1983-1993-2003-2013'),scalemc=c('normal','log'),scalegm=c('normal','equal0.1'),maxvalue=TRUE)
# MC textvalue
# generate.graphic(c('mc'),c('fff'),c('region'),kindTime=c('all'),scalemc=c('normal'), textvalue=TRUE)
# MFC excludeAllBrazilFlows
# generate.graphic(c('mfc'),c('fff'),c('country'),kindTime=c('all'), kindFilter=c('excludeAllBrazilFlows'))
# MFC excludeFlowsInBrazil
# generate.graphic(c('mfc'),c('fff'),c('country'),kindTime=c('all'), kindFilter=c('excludeFlowsInBrazil'))
# GM topDegreeInst & textvalue
# generate.graphic(c('gm'),c('ffft'),c('instituition'),kindTime=c('all'), kindFilter=c('topDegreeInst'), scalegm=c('equal0.1'), mapview='state', textvalue=TRUE)
# GM specificPerson
# generate.graphic(c('gm'),c('all'),c('city'),kindTime=c('all'), kindFilter=c('specificPerson-1982919735990024'), scalegm=c('equal0.1'), mapview='state') # Alexandre
# GM groupPeople
# generate.graphic(c('gm'),c('all'),c('city'),kindTime=c('all'), kindFilter=c('groupPeople-pqComp'), scalegm=c('equal0.1'), mapview='state')
# MC fff doutorado
# generate.graphic(c('mc', 'gm', 'mfc'),c('fff'),c('country'),kindFilter=c('doutorado'))
# GM (to/from)-doutorado-(place)
# generate.graphic(c('gm'),c('fff'),c('instituition'),kindTime=c('all'),kindFilter=c('to-doutorado-USP'), scalegm=c('equal0.1'))
# generate.graphic(c('gm'),c('fff'),c('instituition'),kindTime=c('all'),kindFilter=c('from-doutorado-USP'), scalegm=c('equal0.1'))
# generate.graphic(c('gm'),c('fff'),c('instituition'),kindTime=c('all'),kindFilter=c('to-doutorado-UFPE'), scalegm=c('equal0.1'))
# generate.graphic(c('gm'),c('fff'),c('instituition'),kindTime=c('all'),kindFilter=c('from-doutorado-UFPE'), scalegm=c('equal0.1'))
# generate.graphic(c('gm'),c('fff'),c('instituition'),kindTime=c('all'),kindFilter=c('to-doutorado-USP','excludeFlowsInBrazil'), scalegm=c('equal0.1'))

# TIMELINE
# generate.graphic.timeline('instituition','doutorado')
# generate.graphic.timeline('instituition','doutorado',scale='log')
# TODO generate.graphic.timeline('city','doutorado',scale='log')

# TREEMAP
# generate.graphic.treemap('instituition','doutorado')
# generate.graphic.treemap('instituition','doutorado',flowMoment='source', limit=50)
# generate.graphic.treemap('instituition','doutorado',flowMoment='all',limit=50)
# generate.graphic.treemap('instituition','doutorado',flowMoment='target',limit=50,include='all')
# TODO generate.graphic.treemap('instituition','first',flowMoment='target',limit=50)
# TODO generate.graphic.treemap('instituition','last',flowMoment='source', limit=50)

# LINE
# generate.graphic.line('doutorado')
# generate.graphic.line('doutorado-all-nacional')
# generate.graphic.line('doutorado-all-pop-log')

# PIE
# TODO

# BAR
# TODO

print("END")
# sink()