maintest
{ 
  *m = reverse_list( list("3","2","1","0") )
  *e = list_get (*m,-2)
  writeLine ("stdout","reversed list [*m] - next to last is  [*e]")
}

list_get(*L, *i) 
{
  if (*i < 0) { *i = size(*L) + *i }
  elem(*L,*i)
}

reverse_list(*L) 
{
  *s=size(*L)
  *M=list()
  for (*i=0; *i<*s; *i = *i + 1) { *M=cons(elem(*L,*i),*M) }
  *M
}

input null
output ruleExecOut
