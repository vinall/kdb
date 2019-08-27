\cd ../kdb
.kcommute.utils_lists:("utils.q";"arg.q";"kcommute.q");
importfile:{[f] if[() ~ key hsym `$f; show f," path not present";:()]; system("l ", f); };
importfile each .kcommute.utils_lists;

ep:.arg.opt[`entry_point;""];
ks:`$first .arg.req[`ksvc];

.self.info.Service:`$.arg.opt[`svc;""];
.self.info.Host:"." sv string "h"$0x0 vs .z.a;
.self.info.Port:"i"$system "p";

h:hopen hsym ks;
neg[h] (`.kcommute.register;.self.info.Service;.self.info.Host;.self.info.Port);
.z.ts:{ neg[h] (`.kcommute.hb;.self.info.Service); };

show .self.info;

show ep;
.utils.loadfile[ep];
