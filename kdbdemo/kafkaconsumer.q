\l `kfk.q

queue:([] time:`datetime$();msg:());

.kafka.ismsgqueue:1b;
.kafka.audittab:first exec distinct tblname from .kafka.config;
.kafka.audittab set ([] sendtime:`timestamp$();rawmessage:());

.kafka.connParams:();
.cfg.env:`UAT;
.kafka.readParams:{
    paramfile: .util.filemap `$first cmdline[`kafkaparamfile];
    if[() ~ key hsym `$paramfile; s:raze (first cmdline[`kafkaparamfile]), " param file not present."; exit 1;];
    params: .j.k raze read0 hsym `$paramfile;
    if[99h<> type .kafka.connParams: params[`$.cfg.env]; s: "Malformed json file."; exit 1;];
    {.kafka.connParams[x]: ssr[.kafka.connParams[x]; "SSL_KEYS_PATH";getenv`TREX_SSL_KEYS_PATH];} each key .kafka.connParams;
    .kafka.connParams[`metadata.broker.list]:ssr[.kafka.connParams[`metadata.broker.list];"|";","];
    .kafka.connParams:`$.kafka.connParams;
    s:"Connection params read are ", .Q.s1 .kafka.connParams;
 };

.kafka.readParams[];

.kfk.consumecb:{[msg]
    if[msg[`mtype]~`$"_PARTITION_EOF"; s: "Ignoring _PARTITION_EOF msg: ",("c"$msg`data),", partition: ",string[msg`partition],", offset: ",string[msg`offset];:()];
    if[null first msg`topic; s: "non-null mtype:",string[msg`mtype],"; data ",("c"$msg`data),"; remaining msg: ",.Q.s1 `mtype`data _ msg];
    $[.kafka.ismsgqueue;
     [
      s: "Adding msgs to the queue";
      `queue upsert ([] time:enlist .z.Z;msg:enlist msg);
         ];
      [
        s: "raw msgs : ",data:"c"$msg`data;
        .kafka.audittab upsert ([]sendtime:enlist .z.Z; rawmessage:enlist msg);
        .kafka.process[data;] each .kafka.config
          ];
     ]
 };

.kafka.process : {[d;c]
    if[null c`transform;s:"null transform for ",.Q.s1 c`loaderid;:()];
    s:"Applying transform {",string[c`transform],"}]";
    if[10h=type t:@[value;(c`transform;d);::]; s: .Q.s1 t;:() ];
    if[(0<count t) and .Q.qt t;
      res:update loaderid:`long$c[`loaderid],lastupdate:.z.Z from
          normalizedata[`rawtbl`config`src`feedtbl!(t;c`normalization;c`source;c`schema)];
      //if[c`publish;neg[tpfeedhandler](`.u.upd;c`schema;.util.unkey res)]
      ];
 }

heartbeat:{[x;y]
    srvname:y[0;`srvname];
    event:y[0;`event];
    if[any `recover`hdbend in (srvname;event);
      .kafka.ismsgqueue:0b;
      s:"Sending queued up data count:{",string[count queue],"}]";
      .kfk.consumecb each exec msg from queue;
      delete from `queue;
      ];
    if[`hdbstart in (srvname;event); .kafka.ismsgqueue:1b]
 }

.kafka.init:{
   if[0=count .kafka.connParams;:()];
    .kafka.client:.kfk.Consumer[.kafka.connParams];
    .kfk.MaxMsgsPerPoll[1000];
    .kfk.Sub[.kafka.client;`$first cmdline`topic;enlist .kfk.PARTITION_UA];
 };