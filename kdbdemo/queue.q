/
id,`long$()
activitytype,`$()
activityid,`long$()
subactivityid,`$()
requestid,`long$()
entrytime,`datetime$()
assigntime,`datetime$()
enabled,`boolean$()
ignoredcount,`long$()
args,()

queue
activitytype,tblservices,tbllog,tbllogid,addlogfunc,callbackfunc,srvtype
R,dynamicengines,reconlog,id,addReconlog,reconReqCompleted,M
E,extractors,extractlog,requestid,addExtractlog,extractReqCompleted,EXT
\
///////////////////////////////////////
disableQueueEntry:{[activity;queueid]
    update enabled:0b from `activityqueue where activitytype=activity,id=queueid;
 };

resetQueueEntry:{[activity;queueid]
    update requestid:0Nj,assigntime:0Nz,enabled:1b,retrycount-:1 from `activityqueue where activitytype=activity,id=queueid;
 };

markSrvAvailable:{[srv;activity]
    update available:1b from (.cfg.queue[activity][`tblservices]) where srvname=srv,seen;
 };

markSrvUnavailable:{[srv;activity]
    update available:0b from (.cfg.queue[activity][`tblservices]) where srvname=srv,seen
 };

isSrvDynamic:{[srv;activity]
    :0< count select from (.cfg.queue[activity][`tblservices]) where srvname=srv,seen;
 };

getSeenServices :{
    ?[.cfg.queue[x][`tblservices];enlist `seen;0b;()]
 }

getPendingQueueEntry:{[activity;threshold]
    :`ID`ActivityType`ActivityId`EntryTime`Threshold`PendingTime xcol select id,activitytype,activityid,entrytime,threshold:threshold,pendingtime:.z.T-`time$entrytime from activityqueue where enabled,activitytype in activity,.z.Z > entrytime+threshold
 };

runActivity:{[aid;activity;args]
    addToQueue[activity;aid;args];
    processActivity[activity];
 }

processActivity:{[activity]
    srvname:serviceLookup[activity];
    if[null srvname;.log.INFO "No service available for activity",(string activity);:()];
    task:queueLookup[activity];
    $[99h~type task;value[.cfg.queue[activity][`addlogfunc]][activity;task;srvname];.log.INFO "No Task in Activity Queue!!!"];
 };

handleCallback : {
    upsert[x;y];
    a:exec from y where errorcode<>-1;
    activity:$[`activity in key a;a[`activity]; (.cfg.queue[;`tbllog]?x)[`activitytype]];
    d:exec distinct callbackfunc by tbllog from .cfg.queue;
    if[null a[.cfg.queue[activity][`tbllogid]];:() ];
    markSrvAvailable[a[`srvname];activity ];
    value[.cfg.queue[activity][`callbackfunc]][a];
    if[isSrvDynamic[a[`srvname];activity]; processActivity[activity]];
 }

validateAssignment:{[srv;activity]
    if[`R~activity;validateDynamicengine[srv]];
    if[activity in `L`PL`FL;validateLoaders[srv]];
 };

validateLoaders : {
    //
 };

validateDynamicengine :{
    //
 };

validateServicesAvailability : {
   cond:(count ?[`.recon.info;((in;`enabled;1 2);(null;`engine));0b;()]) and (not count getSeenServices[`R]);
    res:$[cond;"No services seen for Recon Activity \n\n";""];
    res:res,raze {
                    cond:(count ?[`.cfg.loaders;(`enabled;(null;`srvname);((in;`srvtype;enlist .cfg.queue[x][`srvtype])));0b;()]) and (not count getSeenServices x);
                    :$[cond;"No services seen for loading activity of type :",(string x),"\n\n";""]
                 } each `PL`FL`L;
    if[count res;
      .log.ERROR "Services for dynamic activity unavailable";
      ];
 };

handleSrvHeartbeat:{
    upsert[x;y];
    activity:(.cfg.queue[;`tblservices]?x)[`activityqueue];
    logtbl:.cfg.queue[activity][`tbllog];
    srv:y[`srvname][0];
    a:exec from logtbl where errorcode=-1,srvname=srv;
    if[not null rid:a[.cfg.queue[activity][`tblogid]];
      .log.ERROR "Service crashed for activity with details: Service: ",(string srv)," ,Request id: ",(string rid);
      ![logtbl;enlist (in;.cfg.queue[activity][`tbllogid];rid);0b;(`end`errorcode`errormsg)!(.z.Z;1;(enlist;"Service Crashed")) ];
      value[.cfg.queue[activity][`callbackfunc]][?[logtbl;enlist (in;.cfg.queue[activity][`tbllogid];`rid);();()]]];
    if[isSrvDynamic[srv;activity];processActivity[activity]];
    if[isSrvDynamic[srv;activity];validateAssignment[srv;activity]];
 };

serviceLookup:{[activity]
    tbl:.cfg.queue[activity][`tblservices];
    :$[(tbl in tables`.) & count s: exec srvname from (value tbl) where seen, available; first s;`]
 };

queueLookup:{[activity]
    :$[(`activityqueue in tables`.) & count a:select from activityqueue where activitytype=activity,enabled;flip select [1] id,activityid,subactivityid,args from a;`]
 };

logLookup : {[logtbl;srvname]
    :$[count l:select from logtbl where errorcode=-1,srvname=y[`srvname][0];l[`id][0];-1]
 };

addToQueue : {[activity;aid;args]
    subactid:$[99h~type args;$[`subactivityid in key args; args[`subactivityid];`];`];
    rdt:args[`recondate];
    if[count select from activityqueue where activitytype=activity,activityid=aid,subactivityid=subactid,enabled,rdt in args[;`recondate];
      update ignoredcount:ignoredcount+1 from `activityqueue where activitytype=activity,activityid=aid,subactivityid=subactid,enabled;:()];
    upsert[`activityqueue](`id`activitytype`activityid`subactivityid`entrytime`enabled`ignoredcount`args)!(.cfg.id[`queue]+:1;activity;aid;subactid;.z.Z;1b;0j;args);
 }

addReconlog: { [activity;task;srvname]
    arg:task[`args][0];
    upsert[`reconlog]`id`subreconid`srvname`start`errorcode`recondate!(.cfg.id[`recon]+:1;task[`activityid][0];srvname;.z.Z;-1;arg[`recondate]);
    upsert[`activityqueue] `id`requestid`assigntime`enabled!(task[`id][0];.cfg.id[`recon];.z.Z;0b);
    (neg tprequest)(`.u.upd;`reconlog;select from reconlog where id=.cfg.id[`recon]);
    markSrvUnavailable[srvname;activity]
 };