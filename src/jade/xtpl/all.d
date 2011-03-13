
module oak.jade.xtpl.all ;

package import 
	oak.jade.Jade ,
	oak.jade.xtpl.Vars ,
	oak.jade.xtpl.Template ,
	oak.jade.xtpl.Plugin ;


package import 
	std.c.string,
	core.stdc.stdio,
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

