.kcommute.info:([] service:`$(); host:();port:`int$();last_hb:`timestamp$());

.kcommute.register:{[s;h;p] if[1 = count select from .kcommute.info where service = s; :()]; insert[`.kcommute.info;(s;h;p;.z.P)]; };
  
.kcommute.get:{[s] select from .kcommute.info where service = s};

.kcommute.hb: {[s] `.kcommute.info set update last_hb:.z.P from .kcommute.info where service = s;};

.z.ts : { show .kcommute.info; if[ 0 = count .kcommute.info; :()]; `.kcommute.info set delete from .kcommute.info where ((`long$(.z.P - last_hb))%1000000) > 5000; };

