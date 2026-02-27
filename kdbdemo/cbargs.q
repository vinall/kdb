.cfg.srvname:`testsrv;

\d .cbargs

fargs : {[srv;tsrc;tdest;fsrc;fdest]
    kargs[srv;tsrc;tdest;fsrc;fdest;`]
 };

kargs : {[srv;tsrc;tdest;fsrc;fdest;k]
    `sourcesrv`targetsrv`tsrc`tdest`fsrc`fdest`tkey!(.cfg.srvname;srv;tsrc;tdest;fsrc;fdest;k)
 };

\d .
