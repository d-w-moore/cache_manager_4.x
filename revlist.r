maintest
{ 
  *m = reverse_list( list("a","b","c") )
  writeLine ("stdout",*m)
}

reverse_list(*L) {
  *s=size(*L)
  *M=list()
  for (*i=0; *i<*s; *i = *i + 1) { *M=cons(elem(*L,*i),*M) }
  *M
}

input null
output ruleExecOut
