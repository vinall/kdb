
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
    d:.service.client[x];
    k: first key d;
    f: value d;
     
    {[tab;port;func;out] neg[port](func;tab;out);}[x;k;;y] each f;
    
 };
.service.upd:{
    $[ (99h = type y) or (98h = type y); .service.pub[x;((count y)#([] enlist tp_time:.z.P)),'y]; .service.pub[x;.z.P,y]];
 };


