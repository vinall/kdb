.utils.loadfile:{ if[` ~ key hsym `$x; '"file not present"]; system("l ",x)};
.log.info:{if[(-10h <> type x ) and (10h <> type x); .log.info "string type only";'x]; show ((string .z.Z)," ", x); };
//.utils.exec_remote:{[s;cmd] 
