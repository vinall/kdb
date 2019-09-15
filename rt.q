TP_SVC:		`$.arg.opt[`tp_svc;""];
TABLES:		.arg.req[`tables];
HDB:		first .arg.req[`hdb];
SAVE_TABLES:	.arg.opt[`save_tables;""];
SAVE_TABLES:	`$"," vs SAVE_TABLES;

show system "pwd";
.utils.loadfile["tp_utils.q"];

.rt.populate_table:{[u;t]
  insert[u;t];
 };

.service.info:h(`.kcommute.get;TP_SVC);

h_rt:hopen hsym `$((first .service.info`host),":",(string first .service.info`port));

{show x; a:first `$x; a set h_rt(a); neg[h_rt](`.service.sub;a;`.rt.populate_table); } [TABLES];

