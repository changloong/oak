
module oak.util.Ctfe ;

import 
	std.bind,
	std.algorithm,
	std.array,
	std.string,
	std.traits;

string ctfe_i2a(ptrdiff_t i){
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

size_t ctfe_a2i(T) (T[] s, ptrdiff_t radix = 10){
        size_t value;
        foreach (c; s)
                 if (c >= '0' && c <= '9')
                     value = value * radix + (c - '0') ;
                 else
                    break;
        return value;
}

ptrdiff_t ctfe_indexof(T)(T[] a, T v){
	foreach(int i, _v ; a ){
		if( _v == v ) {
			return i ;
		}
	}
	return - 1;
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

string[] ctfe_enum_array(T)() if(is(T==enum)){
	alias traits_allMembers!(T) names;
	string[] _names;
	foreach(int i, name; names){
		_names	~= names[i].stringof[1..$-1] ;
	}
	return _names ;
}






string ctfe_typeof(T : V[K], K, V)() if( isAssociativeArray!(T) ) {
	return ctfe_typeof!(K) ~ "[" ~ ctfe_typeof!(V) ~ "]" ; 
}

string ctfe_typeof(T)() if( !isPointer!(T) && !isAssociativeArray!(T) ) {
	return T.stringof ;
}

string ctfe_typeof(T)() if( isPointer!(T) ) {
	return ctfe_typeof(pointerTarget!(T)) ~ "*" ;
}

template ctfe_eachtype(T : V[K], K, V) {
	alias ctfe_tuple!(K) Keys ;
	alias ctfe_tuple!(V) Values ;
}

template ctfe_eachtype(T : V[], V) if( !isSomeString!(T) ) {
	alias ctfe_tuple!(ptrdiff_t) Keys ;
	alias ctfe_tuple!(V) Values ;
}

template ctfe_eachtype(T : V[N], V, size_t N) if( !isSomeString!(T) ) {
	alias ctfe_tuple!(ptrdiff_t) Keys ;
	alias ctfe_tuple!(V) Values ;
}


template ctfe_tuple( TList... ){
	alias TList ctfe_tuple ;
}

private  template ctfe_Apply(T) {
	static if( !is(T==function) || !isIntegral!( ReturnType!(T) )  ) {
		alias void Key ;
		alias void Value ;
	} else {
		alias ParameterTypeTuple!(T) p1 ;
		static if( p1.length !is 1 || !is(p1[0]==delegate) || !isIntegral!( ReturnType!(p1[0]) )  ) {
			alias void Key ;
			alias void Value ;
		} else {
			alias ParameterTypeTuple!(p1[0]) p2 ;
			
			static if( p2.length is 1 ) { //  && __traits(isRef, p2[0])
				alias void Key ;
				alias p2[0] Value ;
			} else static if (  p2.length is 2  ) { // && __traits(isRef, p2[0]) && __traits(isRef, p2[1])
				alias p2[0] Key ;
				alias p2[1] Value ;
			} else {
				alias void Key ;
				alias void Value ;
			}
		}
	}
}

private template ctfe_eachtype_impl( size_t I, TS...) {
	alias TS[I] T ;
	alias ctfe_Apply!(T) _T ;
	static if( I is 0  ) {
		alias ctfe_tuple!(_T.Key) Keys ;
		alias ctfe_tuple!(_T.Value) Values ;
	} else {
		alias ctfe_tuple!(_T.Key, ctfe_eachtype_impl!(I-1, TS).Keys ) Keys ;
		alias ctfe_tuple!(_T.Value, ctfe_eachtype_impl!(I-1, TS).Values) Values ;
	}
}

template ctfe_eachtype(T) if(  ( is(T==class) || is(T==struct) ) &&  is( typeof(__traits(getOverloads, T, "opApply" )) ) && typeof(__traits(getOverloads, T, "opApply" )).length > 0 ) {
	alias  typeof(__traits(getOverloads, T, "opApply" )) TS ;
	alias ctfe_eachtype_impl!(TS.length -1, TS ) Ret ;
	alias Ret.Keys 	Keys ;
	alias Ret.Values 	Values ;
}

template ctfe_eachtype(T) if(  !isIterable!(T) && !isPointer!(T) || isSomeString!(T) ) {
	alias ctfe_tuple!(void) Keys  ;
	alias ctfe_tuple!(void) Values ;
}

string ctfe_each_type(T)() {
	alias ctfe_eachtype!(T) E ;
	string ret = "" ;
	foreach( i , c; E.Values ) {
		static if( !is(c==void) ) {
			ret	~= ctfe_typeof!(E.Keys[i]) ~ "," ~ ctfe_typeof!(c) ~ ":";
		}
	}
	return ret ;
}

template ctfe_eachtype(T) if( isPointer!(T) ) {
	alias ctfe_eachtype!(pointerTarget!(T) ) ctfe_eachtype ;
}

template ctfe_isIterable(T) if( isPointer!(T) ){
	enum bool ctfe_isIterable	= ctfe_isIterable!( pointerTarget!(T) ) ;
}

template ctfe_isIterable(T) if( !isPointer!(T) ) {
	static if( isSomeString!(T) ) {
		enum bool ctfe_isIterable	= false ;
	} else static if( isIterable!(T) ) {
		enum bool ctfe_isIterable	= true ;
	} else {
		enum bool ctfe_isIterable	= false ;
	}
}



template ctfe_contains(C, T...){
	static if( T.length is 0 ) {
		enum bool ctfe_contains = false ;
	} else static if( is(C==T[0]) ){
		enum bool ctfe_contains = true ;
	} else {
		enum bool ctfe_contains = ctfe_contains!(C, T[1..$] ) ;
	}
}