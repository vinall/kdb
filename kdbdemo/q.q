setenv[`KDB_SRC;"/home/vinay/newkdb/"];
system "l ",getenv[`KDB_SRC],"/util.q";

cmdline:.Q.opt .z.x;

.cfg.srvname:first exec srvname from .cfg.services where port=system "p";

loadPath : {[path]
    .Q.trp[value;"\\l ",path;{[path;err;bt] show "loading error ",path,"\n error: ",err,"\nbacktrace:\n",.Q.sbt bt; exit 1}[path;]];
    show "Loaded ",path;
    1b
 };
