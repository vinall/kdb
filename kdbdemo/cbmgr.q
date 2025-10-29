loadPath .util.filemap`cbargs.q;

\d .cbmgr

config : ([]
    srv_src:`$();
    tsrc:`$();
    tdest:`$();
    fsrc:();
    fdest:();
    tkey:`$();
    handle:`long$()
 );

//.cfg.services[`tp01]
//x:`tp01


cb:{
    k:$[not null x[`tkey];x`tkey;()];
    res:@[x[`fdest];(y);{x}];
    if[10h ~ type res; show "error ",res; :()];
    x[`tdest] set k xkey res;
    pub[x[`tdest];value x[`tdest]];
 };

updateHdl :{
    ![`.cfg.services;enlist (=;`srvname;enlist y);0b;(enlist `hdl)!(enlist x)];
 };

openConnection : {
    if[null x; show ".cbmgr.openConnection:: Service name is empty"; exit 1];
    if[not count .cfg.services[x]; show ".cbmgr.openConnection:: service is not present "; exit 1];
    connStr:hsym `$":" sv (string[.cfg.services[x][`hostname]];string[.cfg.services[x][`port]];string[1000]);
    h:@[hopen;connStr;{x}];
    if[10h=type h;show "Unable to connect to service ",string[x];0b];
    updateHdl[h;x];
    1b
 };

//TODO :: validateArgs can be written for table in remote service
//On second thought its actually is not required.
validateArgs : {[args]
    if[not args[`tsrc] in tables`. ; show string[args[`tsrc]]," is not present";:0b];
    1b
 };

pubutil : {[tbl;data;d]
    res:@[d[`fsrc];(data);{x}];
    if[10h~type res; show res; : ()];
    res:.[{neg[x](`.cbmgr.cb;y;z) };(d[`handle];d;res);{x}];
    if[10h~type res; show "error while executing fdest function ",string[d`srv_src]];
 };



registersub : {[args;remote]
    if[remote; if[not validateArgs[args]; :()]; ];
    `.cbmgr.config upsert (args`sourcesrv;args`tsrc;args`tdest;args`fsrc;args`fdest;args`tkey;.z.w);
 };

subscribe : {[hdl;args]
    .[{[h;f;a;r] neg[h](f;a;r)};(hdl;`.cbmgr.registersub; args ; 1b );{x}];
 };

pub : {[tbl;data]
    d:select from config where tsrc=tbl;
    pubutil[tbl;data;] each d;
 };

sub : {[args]
    if[null args[`targetsrv]; registersub[args;0b]; :()];
    if[.cbmgr.openConnection[args`targetsrv]; subscribe[.cfg.services[args`targetsrv][`hdl];args]; ];
 };

snap : {[args]
    sub[args];
    .cfg.services[args`targetsrv][`hdl]({.cbmgr.pub[x`tdest;value x`tdest]};::)
 };

\d .
