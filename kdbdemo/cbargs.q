.cfg.srvname:`testsrv;

\d .cbargs

fargs : {[srv;ts;td;f]
    kargs[srv;ts;td;f;f;`]
 };

kargs : {[srv;tsrc;tdest;fsrc;fdest;k]
    `sourcesrv`targetsrv`tsrc`tdest`fsrc`fdest`tkey!(.cfg.srvname;srv;tsrc;tdest;fsrc;fdest;k)
 };

\d .
