.log.info:{if[(-10h <> type x ) and (10h <> type x); .log.info "string type only";'x]; show ((string .z.Z)," ", x); };
.arg.opt:{[k;d] if [first ((.Q.opt .z.x) k) like "" ; :d]; (.Q.ty d)$((.Q.opt .z.x) k) } ;
.arg.req:{[k;d] if [first ((.Q.opt .z.x) k) like ""; .log.info (string k)," param is required"; 'k]; (.Q.ty d)$((.Q.opt .z.x) k)  };
importfile:{[f] if[() ~ key hsym `$f; .log.info f," path not present";:()]; system("l ", f); };

t:.arg.opt[`schemas;""];
t:"," vs raze t;
importfile each t;

.z.pc : {
    .log.info "client disconnected handle ", (string x);
    {if[not y in key .service.client[x];:()]; .service.client[x]:.service.client[x] _ y }[;x] each key .service.client;
  };

.service.client:()!();

.service.sub:{
  .log.info "client sub request on handle ", (string .z.w);
  if[` = x;neg[.z.w](`.log.info;"Table is required");:()];
  if[not x in tables`.; neg[.z.w](`.log.info;(string x)," is not present")];
  $[(count .service.client x) = 0; .service.client[x]:((enlist .z.w)!enlist y); .service.client[x],:(enlist .z.w)! enlist y ];
  };

.service.unsub:{
    .log.info ".service.unsub ",(string x) ," " ,string .z.w;
    .service.client[x]:.service.client[x] _ .z.w;
   };

.service.pub:{
    if[0=count .service.client[x];:()];
    $[(99h = type y) or (98h = type y);
    	{neg[y](.service.client[x] y; z);}[x;;y] each key .service.client[x];
	{neg[y](.service.client[x] y; z);}[x;;enlist ((cols x)! y)] each key .service.client[x]
    ];
 };
.service.upd:{
    $[ (99h = type y) or (98h = type y); .service.pub[x;((count y)#([] enlist tp_time:.z.P)),'y]; .service.pub[x;] each flip .z.P,y];
 };





