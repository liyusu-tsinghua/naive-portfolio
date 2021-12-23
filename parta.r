#used data : 'dat.csv'
#used function files : 'yeardat.r' 'calculate.r'
#used packages : 'library.r'

#set up evironment
source('library.r')
source('yeardat.r')
source('calculate.r')

#read data
dat = read.csv('dat.csv')

#initial the yearly betameans and their t-states
tsv = 10:21 * 0
tsm = tsv 
tlist = 10:21
mbv = tsv 
mbm = tsv 

#for every year from 2010 Jan to 2021 May
for (i in 1:12) {
   #choose a year
   t = tlist[i]

   #find this years' data 
   year = yearly(dat , t)

   #get the factor v
   logr = logreturn(year)
   logr10 = app(logr,10,mean)
   logr_idu = minus(logr10)
   sd21 = app(logr,21,sd)
   v = mat(logr_idu)/mat(sd21)
   v = ran(v)

   #get the factor m 
   logrm_idu = minus(logr)
   max21 = app(logrm_idu,21,max)
   m = ran(mat(max21))

   #calculate the daily betas
   r_midu = app(logrm_idu,1,max)
   beta = regr(mat(r_midu),v,m)
   beta_v = beta[1,]
   beta_m = beta[2,]

   #save the means and the t-states
   mbv[i] = mean(beta_v)
   mbm[i] = mean(beta_m)
   tsv[i] = t_s(beta_v)
   tsm[i] = t_s(beta_m)
}

#save the result to a .csv file 'beta.csv'
t = as.data.frame(cbind(tlist,mbv,mbm,tsv,tsm))
write.csv(t,'beta.csv')

png('beta.png')
p = read.csv("beta.csv")

par(mfrow = c(2,2))
for(i in 1:4){
    names(p)[i+2]
    plot(p[,2],p[,i+2],ylab = names(p)[i+2],xlab = 'year 20xx')
}
dev.off()