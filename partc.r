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
#logr_year = 10:21 * 0
#sd_year = 10:21 * 0
#sharp  =  10:21 * 0
tlist = 10:21
glist = 11:19/10
rf_day = array(0,dim = c(300,12,9))

for(gama in 1:9){
    g =glist[gama] 
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
        w = weightc(re,g)
        rf = factc(w,mat(logr))
        

        #save the means and the t-states
        rf_day[1:length(rf),i,gama] = rf 
    }

}

png("pnl9.png")
par(mfrow = c(3,3))
for(i in 1:9){
    logr = rf_day[1:224,2:12,i]
    dim(logr) = c(224*11,1)
    t = length(logr)
    x = 0:t
    y = array(1,dim = c(1,t+1))
    for(i in 1:t){
        y[i+1] = y[i] * exp(logr[i])
    }
    plot(x,y)
}
dev.off()
