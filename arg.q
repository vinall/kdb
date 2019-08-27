.arg.opt:{[k;d] if [first ((.Q.opt .z.x) k) like "" ; :d]; first (.Q.ty d)$((.Q.opt .z.x) k) } ;
//.arg.req:{[k;d] if [first ((.Q.opt .z.x) k) like ""; .log.info (string k)," param is required"; 'k]; (.Q.ty d)$((.Q.opt .z.x) k)  };
.arg.req:{ if[ not x in (key .Q.opt .z.x); '(string x)," is not provided";]; (.Q.opt .z.x) x };
