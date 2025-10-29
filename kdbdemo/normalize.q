\d .util

filemap:()!();
addScript:{if[not 2= count o:` vs hsym x;`type]; filemap,:(enlist last o)!(enlist string x);};
isFile:{x~key x:hsym[x]};
getDirObjs:{`$(string[x],"/"),/:string (key[hsym x] except `.project`.svn`build)} // ignore list
mapDirObjs:{addScript each o where i:isFile each o:getDirObjs[x]; .z.s each o where not i;}


//Path is the location where your code resides.
.util.mapDirObjs each reverse except[`$":" vs getenv[`PATH];` ];
------------------------------------------------------------------------------------------------------------------


typetbl:@[("SSS";enlist ",") 0: `TypeConversion.csv;`conversion;each[{value string x}]];

convertType:{[fromtype;totype;list]
    $[count conv:(exec conversion from typetbl where itype=`$fromtype,otype=`$totype);conv[0][list];list]
 };

convertTbl: {
   dictList:{[tbl;tblname;mtbl;mtblname;cnt;colname]
       $[colname in cols tbl;
            [
                fromtype:(mtbl)[colname][`t];
                totype:last string `C^$(mtblname)[colname][`t];
                $[fromtype~totype;colname;(`.util.convertType;fromtype;totype;colname)]
            ];
            [
                totype:last string `C^`$(mtblname)[colname][`t];
                $[totype~"C"; enlist cnt#enlist .util.nullTypeDict[totype]; enlist cnt#.util.nullTypeDict[totype]]
             ]
        ]
   }[tbl;tblname;meta tbl;meta tblname; count ?[tbl;();0b;()]] each cols tblname;
    ?[tbl;();0b;(cols tblname)!(dictList)]
 };

nullTypeDict:"bxhijefcsmdzuvtC"!(0b;0x00;0Nh;0Ni;0Nj;0Ne;0n;"";`0Nm;0Nd;0Nz;0Nu;0Nv;0Nt;"");
dataTypeDict:(1;4;5;6;7;8;9;10;11;13;14;15;17;18;19;99;98)!"bxhijefcsmdzuvtDT";
convType:(`boolean`byte`short`int`long`real`float`char`symbol`month`date`datetime`minute`second`time)!"bxhijefcsmdzuvt";

\d .



loadNormalize :{
    raze {( flip (enlist`name)!(enlist enlist .util.filemap?x))|(flip (enlist `config)!enlist enlist exec normalized!raw from (("SS";enlist ",") 0: lns where not (lns:trim each read0 hsym `$x)like ""))} each value[.util.filemap] where key[.util.filemap] like "normalize.*.csv"
 };

.cfg.location:`NA;
normalize : {[DICT] normalizedata[DICT,enlist[`feedtbl]!enlist`rawexecutions]};
normalizeorder : {[DICT] normalizedata[DICT,enlist[`feedtbl]!enlist`raworders]};


/
normalizedata[`rawtbl`config`src`feedtbl!(data;`normalize.file.csv;`source;schemaname)]
\

normalizedata : {[DICT]
    cfg:{(key[y] where value y in inter[value y; cols x`rawtbl])#y}[DICT] .cfg.normalize[DICT`config][`config];
    //` sv (`.schema;DICT[`feedtbl] is target schema
    //DICT[`rawtbl] is raw table which you want to normalize
    .util.convertTbl[` sv (`.schema;DICT[`feedtbl]);![?[DICT[`rawtbl];();0b;cfg];();`country`source!((enlist .cfg.location;`country) `country in key cfg;enlist DICT[`src]) ]]
 };

normalizedataWithFields:{[DICT]
    cfg:{(key[y] where value y in inter[value y;cols x`rawtbl])#y}[DICT] DICT`config;
    .util.convertTbl[` sv (`.schema;DICT[`feedtbl]);![?[DICT[`rawtbl];();0b;cfg];();`country`source!((enlist .cfg.location;`country) `country in key cfg;enlist DICT[`src]) ]]
 };

.cfg.normalize:loadNormalize[]

