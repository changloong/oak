
module jade.Jade ;

package import 
	jade.util.Pool ,
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
	std.algorithm,
	std.format,
	core.memory ,
	std.datetime,
	std.conv,
	std.array,
	std.string,
	std.traits,
	std.stdio;


public void Log( string file= __FILE__, int line = __LINE__, T...)(T t){//
	std.stdio.write(file, ":", line, " ");
	std.stdio.writefln(t);
}

ptrdiff_t ctfe_indexOf(T)(T[] a, T v){
	foreach(int i, _v ; a ){
		if( _v == v ) {
			return i ;
		}
	}
	return - 1;
}

package string[] EnumMemberName(T)() if(is(T==enum)){
	alias traits_allMembers!(T) names;
	string[] _names;
	foreach(int i, name; names){
		_names	~= names[i].stringof[1..$-1] ;
	}
	return _names ;
}