
module xtpl.all ;

package import 
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
	
	for(int i, j =0, len = s.length; i < len ;i++){
		while( i < len && s[i] !is c ){
			i++ ;
		}
		ret	~= s[j..i] ;
		while( i < len && s[i] is c ){
			i++ ;
		}
		j	= i ;
	}		

	return ret ;
}
