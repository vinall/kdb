parts : {[d;r] {` sv (x;y)}[hsym `$d] each `$string neg[r]_asc "D"$string f where (f:key hsym `$d) like "????.??.??" };

deletepath : {
   s: "Removing ",1_string[x]; res:@[system;"rm -rf ",(1_string[x]);::];
    if[10h~type res;err:"Count not remove [path:{",string[x],"} msg:{",res,"}]"];
 };

cleanPartition : {deletepath each parts . (x;y)};

cleantabs : {
    {
        ftabs : key x; tab2del: .Q.dd[x;] each `$((string ftabs) where not ftabs~\:`summary);
        if[0=count tab2del; :()];
        deletepath each tab2del;
    } each parts . (x;y)
 };

cleanHdb : {
    s:"Running hdb cleanup for table ",(string first x`tbl)," and having retention ",string first x`retention;
    hdbdir:getenv`HDB_BASE; // path of HDB
    dir2del:parts[hdbdir;x`retention];
    tbls2del:.Q.dd[;x`tbl] each dir2del;
    if[0 = count tbls2del; s:"Partition not found for HDB cleanup of table ",string first x`tbl;()];
    deletepath each tbls2del;
    s:"Completed HDB cleanup for table ",string first x`tbl;
 };


/
tbl,retention

\
.cfg.eod:("SI";enlist ",") 0: hsym `$"eod.csv";
housekeeping_new : {
    if[("" ~ hdbdir:getenv`HDB_BASE);:()];
    s:"Running Hdb housekeeping path:{",hdbdir,"}";
    cleanHdb each .cfg.eod;
    s:"Deleting hdb partitions path:{",hdbdir,"}";
    cleanPartition[hdbdir;max .cfg.eod`retention];
    res:@[.Q.chk;hsym `$hdbdir;::];
    if[10h~type res;e:"fill hdb function failed msg:{",res,"}"];
 };

housekeeping:{
   if[("" ~ hdbdir:getenv`HDB_BASE);:()];
    hdbretention:"I"$first cmdline[`hdbretention];
   s:"Running Hdb housekeeping path:{",hdbdir,"} retention:{",string[hdbretention],"}]";
   {s:"Removing from hdb", 1_string[x];
       res:@[system;"rm -rf ",(1_string[x]);::];
       if[10h~type res;s:"Could not remove [path:{",string[x],"} msg:{",res,"}]"]
   } each parts . (hdbdir;hdbretention)
 };


//
.util.compressFile : {[fp]
    if[not 0=count -21!fp; s: string [fp], " is already compressed. skipping";:()];
    cfp:`$string[fp],".kdbzip";
    res:@[{-19!x};(fp;cfp;17;1;0);{s:raze "compression failed. skipping reason ",string[x];x}]
    if[10h=type res;:()];
    if[not get[cfp]~get[fp]; s:"failed to compress",string fp; hdel cfp;:()];
    .log.INFO "compressed ",string fp;
    system "mv '",(1_string cfp),"' '",(1_string fp),"'";
    if[not ()~key `$string[cfp],"#";system"mv '",(1_string cfp),"#' '",(1_string fp),"#'"];
    if[not ()~key `$string[cfp],"##";system "mv '",(1_string cfp),"##' '",(1_string fp),"##"]
    };

updateHistoricalSchema : {
    h:hopen `:<hostname>:<port> //of hdb
    h(addTables;::);
    h(removeTables;::);
    h(addColumns;::);
    h(removeColumns;::);
    h(`loadHdb;::);
 }


addTables:{.Q.chk`:.};
date:.z.D //to be removed.

removeTables : {
   t:distinct[raze key each hsym each `$string -1_date]except key hsym `$string last date;
   {@[system;x;::]} each "rm -r",/:string[-1_date] cross "/",/:string t;
 };

addColumns : {
    {[t]
        {[t;c]
            {[t;c;d]
                defaults:" Cbefihjsdtz"!(enlist"";enlist ""),first each "befihjsdtz"$\:();
                f:hsym `$string[d],"/",string[t],"/",string c;
                if[0=type key f;
                  tabledir:hsym `$string[d],"/",string[t];
                  .[f;();:;count[get (`) sv tabledir,first get[tabledir,`.d]]#defaults meta[t][c]`t ];
                  @[tabledir;`.d;,;c]];
            }[t;c] each -1_date;
        }[t] each cols[t]except `date;
    } each key hsym `$string last date;
 };

removeColumns : {
    {[dt;t]
        {[dt;t;d]
            path:hsym `$string[d],"/",string[t];
            nd:string key[hsym`$string[dt],"/",string t];
            delcols:`$((string key[path]) except nd,nd,\:"#");
            {[t;c] hdel`$string[t],"/",string c;}[path] each delcols;
            if[count delcols; @[path;`.d;:;get[path;`.d] except delcols ]];
        }[dt;t] each -1_date
    }[last date; ] each key hsym `$string last date;
 };

compressHdb:{[hdbdir;maxage]
    parts:{.Q.dd[x;] each `$string neg[y]#asc "D"$string f where (f:key x) like "????.??.??"}[hdbdir;maxage];
    tbldirs:raze {.Q.dd[x;] each key x} each parts;
    {.util.compressFile each f where not ()~/:key each f:.Q.dd[x;] each get .Q.dd[x;`.d] } each tbldirs;
 };

cmdline:.Q.opt .z.x;
$[`usesummaaryretention in key cmdline; housekeeping_new[];housekeeping[]];
compressHdb[hsym `$getenv`HDB_BASE;1];
