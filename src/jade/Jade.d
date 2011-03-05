
module jade.Jade ;

package import 
	jade.util.Buffer , 
	jade.util.Pcre ;

package import 
	jade.Token ,
	
	jade.Node ,
	
	jade.Filter ,
	
	jade.Lexer ,
	jade.Parser ,
	jade.Compiler ;
	
	
package import 
	std.datetime,
	std.conv,
	std.array,
	std.string,
	std.traits,
	std.stdio;

version(JADE_TEST){
	
} else {
	public import jade.tpl.Template , jade.tpl.Factory ;
}

public void log( string file= __FILE__, int line = __LINE__, T...)(T t){//
	std.stdio.write(file, "(", line, ") ",  t, "\n");
}

public void Log( string file= __FILE__, int line = __LINE__, T...)(T t){//
	std.stdio.write(file, ":", line, " ");
	std.stdio.writefln(t);
}

package string[] EnumNames(T)() if(is(T==enum)){
	alias traits_allMembers!(T) names;
	string[] _names;
	foreach(int i, name; names){
		_names	~= names[i].stringof[1..$-1] ;
	}
	return _names ;
}