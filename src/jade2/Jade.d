
module jade.Jade ;

package import 
	jade.util.Pool ,
	jade.util.Buffer , 
	jade.util.Pcre ;

package import 
	jade.Token ,
	
	jade.Node ,
	
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

extern(C){
	private void exit(ptrdiff_t);
}

struct _J {
	static void Exit(ptrdiff_t ret){
		exit(ret);
	}
}


uint ctfe_a2i(T) (T[] s, int radix = 10){
        uint value;
        foreach (c; s)
                 if (c >= '0' && c <= '9')
                     value = value * radix + (c - '0') ;
                 else
                    break;
        return value;
}

string ctfe_i2a(int i){
    char[] digit	= cast(char[]) "0123456789";
    char[] res		= cast(char[]) "";
    if (i==0){
        return  "0" ;
    }
    bool neg=false;
    if (i<0){
        neg=true;
        i=-i;
    }
    while (i>0) {
        res=digit[i%10]~res;
        i/=10;
    }
    if (neg)
        return cast( string) ( '-' ~res );
    else
        return cast( string) res;
}

string[] ctfe_split(string s, char c){
	string[] ret ;
	
	while(s.length >0 && s[0] is c ) s = s[1..$];
	while(s.length >0 && s[$-1] is c ) s = s[0..$-1];
	
	ptrdiff_t i, j =0, len = s.length;
	while(i < len ){
		while( i < len && s[i] !is c ){
			i++ ;
		}
		ret	~= s[j..i] ;
		while( i < len && s[i] is c ){
			i++ ;
		}
		j	= i ;
	}
	if( j != i ) {
		ret	~= s[j..$] ;
	}

	return ret ;
}
