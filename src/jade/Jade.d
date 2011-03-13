
module oak.jade.Jade ;

package import 
	oak.util.Pool,
	oak.util.Pcre,
	oak.util.Ctfe ,
	oak.util.Buffer ;

package import 
	oak.jade.Token ,
	
	oak.jade.Node ,
	
	oak.jade.Lexer ,
	oak.jade.Parser ,
	oak.jade.Compiler ;
	
package import 
	std.algorithm,
	std.format,
	core.memory ,
	std.datetime,
	std.conv,
	std.array,
	std.string,
	std.traits,
	std.stdio;

version(JADE_XTPL) {
	package import  oak.jade.xtpl.all ;
}


public void Log( string file= __FILE__, int line = __LINE__, T...)(T t){//
	std.stdio.write(file, ":", line, " ");
	std.stdio.writefln(t);
}

extern(C){
	private void exit(ptrdiff_t);
}

