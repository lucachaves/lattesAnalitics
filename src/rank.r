# acronym, ICG, RUF, DDbyid16, inDregree

# remover outlier

# sigla;people;avgDD;avgD;avgDDbyP;Ano;CodIES;NomeIES;siglai;CategAdmin;OrgAcademica;UF;nAvTri;nCPC;alfa;graduacao;beta;mestrado;doutorado;igcc;igcf;Obs;rufpos;NomeUni;siglar;UFr;PubPri;ensino;pesquisa;mercado;inovacao;interna;rufnota
rank <- read.table("~/Documents/code/github/lucachaves/lattesAnalitics/src/data/rank/rank-ruf-igc.csv", header=TRUE,sep=";", quote="\"")
View(rank)
drops <- c('Ano','CodIES','NomeIES','siglai','CategAdmin','OrgAcademica','UF','nAvTri','nCPC','Obs','NomeUni','siglar','UFr','PubPri')
rank.sel <- rank[,!(names(rank) %in% drops)]
summary(rank.sel)
plot(rank.sel)

ggplot(rank,aes(people,rufnota))+geom_point()+geom_text(aes(label=sigla))+geom_abline()
ggplot(rank,aes(people,rufnota))+geom_point()+geom_text(aes(label=sigla))+geom_smooth()

temp <- subset(rank, rank$sigla != 'ucb' & rank$sigla != 'usp' & rank$sigla != 'puc-campinas')
temp <- subset(rank, rank$sigla != 'ucb'& rank$sigla != 'puc-campinas')
ggplot(temp,aes(people,rufnota))+geom_point()+geom_text(aes(label=sigla))+geom_smooth()
ggplot(temp,aes(log(people),log(rufnota)))+geom_point()+geom_text(aes(label=sigla))+geom_smooth()
ggplot(temp,aes(log(people),log(rufnota)))+geom_point()+geom_smooth()+xlim(5.5,9.5)+xlab('log(pessoa)')+ylab('log(RUF)')
ggplot(temp,aes(log(D),log(rufnota)))+geom_point()+geom_text(aes(label=sigla))+geom_smooth()
cor(log(temp$people),log(temp$rufnota)) # BEST
cor(log(temp$D),log(temp$rufnota))
cor(temp$people,temp$rufnota)

temp <- subset(rank, rank$sigla != 'ucb'& rank$sigla != 'puc-campinas')
ggplot(temp,aes(log(people),log(rufnota)))+geom_point()+geom_smooth()+xlim(5.5,9.5)+ylim(4,4.85)+xlab('pessoas autando')+ylab('RUF')+theme(axis.text = element_text(size = 14, face = "bold"),axis.title = element_text(size = 20, face = "bold"))
cor(log(temp$people),log(temp$rufnota))


temp <- subset(rank, rank$sigla != 'ucb' & rank$sigla != 'usp')
# ggplot(rank,aes(people,igcc))+geom_point()+geom_text(aes(label=sigla))+geom_smooth()
ggplot(rank,aes(log(people),log(igcc)))+geom_point()+geom_text(aes(label=sigla))+geom_smooth()
ggplot(rank,aes(log(D),log(igcc)))+geom_point()+geom_text(aes(label=sigla))+geom_smooth()
temp <- rank[2:length(rank),]
cor(temp$people,temp$igcc)
cor(temp$people,temp$beta)

ggplot(temp,aes(D,igcc))+geom_point()+geom_text(aes(label=sigla))+geom_smooth()
ggplot(temp,aes(D,rufnota))+geom_point()+geom_text(aes(label=sigla))+geom_smooth()
ggplot(temp,aes(D,doutorado))+geom_point()+geom_text(aes(label=sigla))+geom_smooth()
ggplot(temp,aes(D,beta))+geom_point()+geom_text(aes(label=sigla))+geom_smooth()


temp <- subset(rank, rank$sigla != 'ucb' & rank$sigla != 'usp')
ggplot(temp,aes(log(D),log(beta)))+geom_point()+geom_smooth()+xlab('deslocamento')+ylab(expression(paste(beta," IGC")))+theme(axis.text = element_text(size = 14, face = "bold"),axis.title = element_text(size = 20, face = "bold"))
cor(log(temp$D),log(temp$beta)) # BEST	
