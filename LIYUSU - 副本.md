# final assignment

## global

we firstly used`>Rscript getdata.R`to get 'dat.csv' from 'data_cn/tickers.csv' , 'data_cn/adjusted.csv' and 'data_cn/in_univ.csv' , all what we use is in 'dat.csv' , later all the code is start from dat.csv . during this step , we remove those don't have Gics code from our universe.

we write all the functions to modify data in 'calculate.r'

we write all the `library()` in 'library.r'


## part A


### 1.
we first choose a specific year t . Then we remove those stocks don't exist in this year , for 21_day_lookback factor , we chose the timeseries from 21days before that year

we write this step in 'yeardat.r' , as an example , we choose 2018 and the data is saved in test18.csv . 

### 2.

we firstly write some functions in file 'calculate.r'
* `app(dat,tau,f)` , apply function `f` to past `tau` days in every time series in `dat` . use the result to constructure a data.frame derive the timesreies in this year 
* `logreturn()`  to change the  data in the specific year to daily log return .
* `minus()` subtract out the industry mean 
* `mat()` change the data.frame to matrix purely derive values(don't contain Gics , date , etc.)
* `ran()` return the rank :
$$(2*rank-N-1)/(N-1) $$ 
  
then we have these to get v : 
 
```R
#get the factor v
#grt the daily logreturn , we change NA to 0 here
logr = logreturn(year)

# a)
#get the 10-day-logreturn
logr10 = app(logr,10,mean)

# b)
#subtract out the industry return
logr_idu = minus(logr10)

# c)
#calculate the volatility 
#and then divide the 10-day return by the volatility 
sd21 = app(logr,21,sd)
v = mat(logr_idu)/mat(sd21)

# d
#rank the normalized factor)
v = ran(v)
```

### 3.

similar to 2. we have :
```R
# a) 
#we already get that in 2. 
#logr is what we need

# b)
#subtract out the industry return
logrm_idu = minus(logr)

# c)
#get the maximum of the magnitude of the daily return
max21 = app(logrm_idu,21,max)

# d)
#rank the factor
m = ran(mat(max21))
```

### 4.

we add a function to 'calculate.r'
* `regr(a,b,c)` , `a,b,c`are all $i× j$ matrix this function return the $(i-1)× 2$ matrix $β = (\beta_{i,b} , \beta_{i,c})$

then this step is:
```R
   #calculate the daily betas
   r_midu = app(logrm_idu,1,max)
   beta = regr(mat(r_midu),v,m)
   beta_v = beta[1,]
   beta_m = beta[2,]
```

### 5.

we add a function to 'calculate.r'
* `ts(x)` return the t-stat of x

then this step is:
```R
#calculate the 1-year average and the t-stat of beta
and the t-stat
mbm = mean(beta_m)
tsv = ts(beta_v)
tsm = ts(beta_m)
```
### result
we do a loop to apply the steps to every year , and save the results together to 'beta.csv' , the that is:

@import "beta.csv"

we can also plot
```R
png('beta.png')
p = read.csv("beta.csv")

par(mfrow = c(2,2))
for(i in 1:4){
    names(p)[i+2]
    plot(p[,2],p[,i+2],ylab = names(p)[i+2])
}
dev.off()
```
@import "beta.png"

the script this part is saved as 'parta.r' , the input data it used is 'dat.csv' , the out put files are : "beta.csv" and "beta.png"

## part B
we add a function to 'calculate.r'
* `expect(b,v,m)`
  $$ b[1]*v + b[2] * m$$ 
* `change()`
$$
f(n) =
\begin{cases}
-1,  & \text{if $n$ <-0.6} \\
1, & \text{if $n$ > 0.6}\\
0, & \text{else}
\end{cases}
$$
* `weight(re)` , `apply(re,change)`
* `fact()`
  $$ fact\_logreturn    =ln(1+\frac{\sum_iw_i(\exp(logreturn_i)-1)}{\sum_i\frac{1}{2}|w_i|})$$
  
```R
# 1.
#construct portfolio
re = expect(beta,v,m)
w = weight(re)

# 2.
#get the portfolio return at each time step t.
rf = fact(w,mat(logr))
```

the daily logreturn is saved in 'dailyreturn.csv' , yearly result saved in 'return.csv' 

@import "return.csv"

from here we know that the best year is 2015 , and the worst is 2011 .the the annual return (annually logreturn) volatility of the portfolio is `sd(read.csv('return.csv')[,3])` : $0.115089054444508$

we also use function `pnl()` to plot the total PnL:

@import "pnl.png"

## part C

when considering cost model , we simply minus 0.001 from the everyday-log-return and get the part-B-PnL considering cost (trade every day,buy cost 0.0005,sell cost 0.0005, 0.0005 << 1 ,so simply minus 0.001)`pnl(dailyreturn-0.0005,"pnlcost.png")`

@import "pnlcost.png"

then we considering hold some position longer then one day , which means the daily log return cost is less than 0.001 (if we hold A today , and tomorrow , it doesn't make cost)

so we change the daily logreturn fomula , from $ln(1+\frac{\sum_iw_i(\exp(logreturn_i)-1)}{\sum_i\frac{1}{2}|w_i|})$ to:
$$fact\_logreturn    =ln(1+\frac{\sum_iw_i(\exp(logreturn_i)-1)}{\sum_i\frac{1}{2}|w_i|}-\frac{\sum_i|δ w_i|*0.0005}{\sum_i\frac{1}{2}|w_i|})
$$

we add function `factc()` to 'calculate.r' , and use it instead of fact , to get the modified resullt of part B. this is in 'partbc.r'

and the PnL is :

@import "pnlcostc.png"

this picture beeing much better than above is because this item $-\frac{\sum_i|δ w_i|*0.0005}{\sum_i\frac{1}{2}|w_i|}$ take the place of minusing 0.001 directly.

to if $\sum_i|δ w_i|$ get less , the PnL will be better , so we import a hurdle to modify the expcted return :

after import hurdle , we make the decision that if we long stockᵢ today and want to long it tomorrow , we would holde it , instead of selling and buying again , to save the trading cost.

we choose γ from {1.1,1.2,...,1.9} while $h = \gamma*\sigma$ and here is the 9 PnLs:

@import "pnl9.png"

the first 2 photo in partC means `factc()` works well , but the 9 PnLs means that different hurdles made little differences on PnL , so I guess the function `weightc()` may have something wrong , but i didn't find it .  

## part D

### a) contribution to the project

the outline of the whole project is desigined by me , at the wery begining , i write an Abstract in Chinese containing all the math fomula and then we translate it together to the form we upload .

before the coding process , to make the cooperation easier , i wrote a detailed task.md file to illustrate what should every body do , as well as the form of intermediate-step-file . i thought that this could help people start the later part of the whole project easily , after all , without data , they can know the data form from that file . you can refer it at the bottom of this file.

during the coding process , i found that the early part and the later part both didn't meet the requirement of our every-onr-tesk , none of them can offer me a standard data file or the script . they didn't give me the monthly industry return , the factors they didn't modified successfully , there wasn't r.csv or e.csv either . so i need to adjust the plan near the ddl. and i have to pick up all the troubles and nearly do the whole works again.

for the strategy part , i communicate with them and tell them which strategy may be useful.

during the report writting and ppt making part , i write our regrassion part . How we get the α , β ,and why.

 

### b) difficulty
i think coding and debug is the most difficult part for me , especially when there must be some cooperation . coding alone is really different from coding with each other , though i've tried a lot to make the cooperation being more smooth , it's still bother me a lot . even cooperation with myself from different time makes a lot trouble.

before coding line by line , i thought that the difficult part is drawing the outline , dividing the whole project into specific tesk , writting the math behind the model , even writting the pseudocode . however , infact , the time transforming the pseudocode into real code is the same as summing all other together . 

the 3 assignment contain the same part . in principle , we can use the earlier one to solve the later one . however , because the lack of experience , i write the first one by pyhton , the second one R , when i want to use the second one to do the last one , i find i just write all the code in a single file , a single function , that is because i don't know the function `source()` in R . To make my final work more readable , i have to write all the work again.

reading my own early work can bother me that much , no matter how difficult it is to read the others. during the cooperation process , i find that reality is really different from what i thought.

at last , after this introspection , i find all my difficulty is technologically instead of theoretically . i know after 1~2 years training i can overcome all this technological problem , but i also strongly wander if there is a shortcut.

### c) most interesting

i think the cost are the most interesting part , especially this photo:

@import "p.png"

the qualitative analysis is obvious , but the quantitative behand it is mysterious , mabe people have some empirical formula , but we still don't know the dynamic principle details . i think this part is interesting . 
### d)

i think it's not difficult at all for me to understand the topics . the logic and math behind them is intuitionistic.

---

next i will offer some refference:
* tesk.md
* functions : calculate.r 
* script for each part : parta.r partb.r partbc.r partc.r

---
# tesk.md :
@import "task.md"
---
# calculate.r 
@import "calculate.r"
---
# parta.r 
@import "parta.r"
---
# partb.r 
@import "partb.r"
---
# partbc.r 
@import "partbc.r"
---
# partc.r 
@import "partc.r"










