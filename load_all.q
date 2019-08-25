\cd ../kdb
.kcommute.utils_lists:("utils.q";"arg.q";"kcommute.q");
importfile:{[f] if[() ~ key hsym `$f; show f," path not present";:()]; system("l ", f); };
importfile each .kcommute.utils_lists;


req:.arg.opt[`entry_point;""];
show req;
.utils.loadfile[req];
