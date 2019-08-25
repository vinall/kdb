.kcommute.info:()!();

.kcommute.register:{[s;h;p] if[s in key .kcommute.info; :()]; .kcommute.info[s]:hsym `$(h ,":",(string p)); };
.kcommute.get:{[s] $[s in key(.kcommute.info) ; : .kcommute.info[s] ; :()] };
