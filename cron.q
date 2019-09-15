.cron.table:([] id:`long$();
		timerinterval:`int$();
		last_run:`time$(); 
		next_run:`time$(); 
		mode:`$();
		func:();
		params:());

.cron.add:{[func;param;timer;mode]
	$[0 > type param ; func[param] ; func . param];
 	insert[`.cron.table;(`long$.z.T;timer;.z.T;.z.T+timer;mode;func;param)];
 };

.cron.run:{[id;func;param;mode;interval]
	.cron.table:$[`once = mode; delete from .cron.table where id=id,mode=`once; update next_run:.z.T+interval,last_run:next_run from .cron.table where id = id];
	$[0 > type param ; func[param] ; func . param];
 };

.cron.trigger:{
	toberun:select id,func,mode,timerinterval from .cron.table where next_run <= .z.T;
	{ .cron.run [x`id;x`func;x`param;x`mode;x`timerinterval]; } each toberun;
 };

 .z.ts:.cron.trigger;
