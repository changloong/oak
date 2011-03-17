
module oak.view.jade.xtpl.all ;

package import 
	oak.view.jade.Jade ,
	oak.view.jade.xtpl.Vars ,
	oak.view.jade.xtpl.Template ,
	oak.view.jade.xtpl.Plugin ;


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

