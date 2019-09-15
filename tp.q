.utils.loadfile "tp_utils.q";

t:.arg.opt[`schemas;""];
t:"," vs raze t;
.utils.loadfile each t;

.z.pc : {
    .log.info "client disconnected handle ", (string x);
    {if[not y in key .service.client[x];:()]; .service.client[x]:.service.client[x] _ y }[;x] each key .service.client;
  };
