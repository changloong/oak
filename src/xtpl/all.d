
module xtpl.all ;

package import 
	jade.Jade ,
	xtpl.Vars ,
	xtpl.Template ,
	xtpl.Plugin ,
	xtpl.Buffer ;


package import 
	std.algorithm,
	std.traits,
	std.exception,
	std.format,
	std.range,
	std.array,
	std.string,
	std.conv;
	

string cstring_dup(char* s){
	int i =0 ;
	while( s[i] !is 0 ) i++;
	string ret = s[0..i+1].idup ;
	return ret[0..i] ;
}

