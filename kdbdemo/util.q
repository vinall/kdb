\d .util

filemap:()!();
addScript:{if[not 2= count o:` vs hsym x;`type]; filemap,:(enlist last o)!(enlist string x);};
isFile:{x~key x:hsym[x]};
getDirObjs:{`$(string[x],"/"),/:string (key[hsym x] except `.project`.svn`build)} // ignore list
mapDirObjs:{addScript each o where i:isFile each o:getDirObjs[x]; .z.s each o where not i;}


//Path is the location where your code resides.
mapDirObjs each reverse except[`$":" vs getenv[`KDB_SRC];` ];

\d .



readcsv:{[p;ty;de]
    if[not count key p;:()];
    (ty;enlist de) 0: p
 };

.cfg.services:readcsv[hsym `$cmdline[`srvcsv];"SS*S";","];
