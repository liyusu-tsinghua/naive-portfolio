#used data : 'dat.csv'
#used function files : 'yeardat.r' 'calculate.r'
#used packages : 'library.r'

#set up evironment
source('library.r')
source('yeardat.r')
source('calculate.r')

#read data
dat = read.csv('dat.csv')
beta = read.csv('beta.csv')

#initial the yearly betameans and their t-states
logr_year = 10:21 * 0
sd_year = 10:21 * 0
sharp  =  10:21 * 0
tlist = 10:21
rf_day = array(0,dim = c(300,12))

#for every year from 2010 Jan to 2021 May
for (i in 11:21 - 9) {
    #choose a year
   t = tlist[i]

   #find this years' data 
   year = yearly(dat , t)

   #get the factor v
   logr = logreturn(year)
   logr10 = app(logr,10,mean)
   logr_idu = minus(logr10)
   sd21 = app(logr,21,sd)
   v = mata(logr_idu)/mata(sd21)
   v = ran(v)

   #get the factor m 
   logrm_idu = minus(logr)
   max21 = app(logrm_idu,21,max)
   m = ran(mata(max21))

   #calculate the daily logreturn in fact
   beta = read.csv('beta.csv')[i-1,3:4]
   re = expect(beta,v,m)
   w = weight(re)
   rf = factc(w,mat(logr))
   

   #save the means and the t-states
    sd_year[i] = sd(rf)
    logr_year[i] = sum(rf)
    sharp[i] = mean(rf)/sd(rf)
    rf_day[1:length(rf),i] = rf 
}

#save the result to a .csv file 
fact = as.data.frame(cbind(tlist,logr_year,sd_year,sharp))
write.csv(fact,'returnc.csv')
write.csv(as.data.frame(rf_day),'dailyreturnc.csv')


dat = as.matrix(read.csv('dailyreturnc.csv')[1:224,3:13])
dim(dat) = c(224*11,1)
pnl(dat,'pnlcostc.png')