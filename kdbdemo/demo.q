t:([] time:`time$();sym:`$())

h:hopen `::5010
h(`f;(2;3))

sym aur exchange
select from table where price=(max;price) fby ([] sym;exch )

.Q.dpft[dir;date;`sym;`t]

`:/hdb/date/table/cols

trade:([] time:10?.z.T;sym:10?`3;date:10?.z.D)
sample:([] time:10?.z.T;sym:10?`3;date:10?.z.D;description:10#enlist "apple")
trade
\l /home/vinay/newkdb/newhdb
meta sample
select from sample where date=max date
.Q.dpft[`$":/home/vinay/newkdb/newhdb";2025.06.29;`sym;`sample]
.Q.dpft[`$":/home/vinay/newkdb/newhdb";2025.06.29;`sym;`trade]
`:newhdb/2025.06.29/trade/ set .Q.en[`:newhdb;trade]
meta trade
\l newhdb
\rm -rf newhdb
select from trade where date=max date


("SSZD";enlist ",") 0: `:file

\ts cnt:count get `:/home/vinay/newkdb/newhdb/2025.06.29/sample/description
@[`:/home/vinay/newkdb/newhdb/2025.06.29/sample/;`newcol;:;10#`]
`:/home/vinay/newkdb/newhdb/2025.06.29/sample/.d set ((get `:/home/vinay/newkdb/newhdb/2025.06.29/sample/.d),`newcol)
get `:/home/vinay/newkdb/newhdb/2025.06.29/sample/.d

-11!`:replaylog
-11!(-1;`:replaylog)
n:first -11!(-2;`:replaylog)
-11!(n;`:replaylog)


{1+til last x} 1
9 {1+til 1+last x}\1

10{x,-1#x+1}\1

(+) prior 1+til 5
sum 1+til 5