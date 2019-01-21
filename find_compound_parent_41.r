test_find_compound_parent
{
#
#  -- this code for iRODS 4.1.x
#  based on name of child (cch,arc,etc) find the name of the compound resource just above it
#
    foreach (*x in select RESC_NAME,RESC_CHILDREN) {
	*y=*x.RESC_NAME
	*z=*x.RESC_CHILDREN
	if (*z like '*inpnm{*' || *z like '*;*inpnm{*')      #--lol--}}
	{
	    writeLine("stdout","*y -> '*z'")
	}
    }
}
input *inpnm=$''
output ruleExecOut
