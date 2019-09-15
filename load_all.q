\cd ../kdb
.kcommute.utils_lists:("utils.q";"arg.q";"kcommute.q";"cron.q");
importfile:{[f] if[() ~ key hsym `$f; show f," path not present";:()]; system("l ", f); };
importfile each .kcommute.utils_lists;

ep:first .arg.req[`entry_point];
ks:`$first .arg.req[`ksvc];

.self.info.Service:`$.arg.opt[`svc;""];
.self.info.Host:"." sv string "h"$0x0 vs .z.a;
.self.info.Port:"i"$system "p";

.log.info string .self.info.Service;

//h:hopen hsym ks;
//neg[h] (`.kcommute.register;.self.info.Service;.self.info.Host;.self.info.Port);
.service.register:{ `h set hopen hsym ks; neg[h] (`.kcommute.register;.self.info.Service;.self.info.Host;.self.info.Port);  };

.service.register[];

.publish.hb:{
     if[h < 0; `h set hopen hsym ks];
     //h(`.kcommute.hb;.self.info.Service);
     .[{ neg[h] (x;y) };(`.kcommute.hb;.self.info.Service); {.log.info "exception : kcommute service is down - trying to reconnect"; .service.register[]; } ]; 
  };
.cron.add[`.publish.hb;.self.info.Service;5000;`repeat];

show ep;
.utils.loadfile[ep];

