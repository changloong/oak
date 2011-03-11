//: \$dmd2 -J. \+..\jade\util\Buffer.d \+..\fcgi -O -inline -release -unittest

module tpl2.test ;

import std.stdio, std.conv, std.traits, jade.util.Buffer , std.datetime,  fcgi4d.all ,  std.process ;


alias vBuffer Buffer;

/// compile time integer to string
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
	
	int i, j =0, len = s.length;
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

uint ctfe_a2i(T) (T[] s, int radix = 10){
        uint value;
        foreach (c; s)
                 if (c >= '0' && c <= '9')
                     value = value * radix + (c - '0') ;
                 else
                    break;
        return value;
}


class Tpl(string TplName, string _class_file = __FILE__, size_t _class_line = __LINE__ ) {
	static const _file = _class_file ;
	static const _line = _class_line ;
	
	
	
	static const string _class_loc	 = TplName ~ ":" ~ _file[0..$] ~ "#" ~ ctfe_i2a(_line) ;
	static const import_tpl_object	 =  import( "tpl://new::" ~ _class_loc ) ;
	
	ubyte[]	_tpl_tuple ;
	
	this(){
		_tpl_tuple	= new ubyte[1024];
	}

	void opDispatch(string s, T)(T i) {
		writefln("S.opDispatch('%s', %s)", s, i);
	}
	
	static string type_of(T : V[K], K, V)() if( isAssociativeArray!(T) ) {
		return type_of!(K) ~ "[" ~ type_of!(V) ~ "]" ; 
	}
	
	static string type_of(T)() if( !isPointer!(T) && !isAssociativeArray!(T) ) {
		return T.stringof ;
	}
	
	static string type_of(T)() if( isPointer!(T) ) {
		return type_of(pointerTarget!(T)) ~ "*" ;
	}
	
	/*
	static template each_type(T : V[K], K, V) if( isAssociativeArray!(T) ) {
		alias K Key ;
		alias V Value ;
	}
	*/

	typeof(this) assign(string name, string __file = __FILE__, size_t __line = __LINE__, T)(T t){
		static const string _method_loc =  name ~ ":"  ~ _file[0..$] ~ "#" ~ ctfe_i2a(_line) ~ "," ~ __file[0..$] ~ "#" ~ ctfe_i2a(__line) ;
		
		enum _type = type_of!(T) ;
		
		static if( isArray!(T) ) {
			// ForeachType
		} else	static if( isPointer!(T) && isArray!( pointerTarget!(T) ) ) {
			
		} else static if( isAssociativeArray!(T) ) {
			
		} else static if( isPointer!(T) && isAssociativeArray!( pointerTarget!(T) )  ) {
			
		} else static if( isIterable!(T)  ) {
			static assert( is(T==class) || is(T==struct), T.stringof );
			// opApply
			//__traits(getMember, T, )
		}
		
		static const tpl_var_id_offset_size	= import( "tpl://assign::" ~ _class_loc ~ "::"  ~ ( _method_loc ~ ":" ~  _type ~ ":" ~ typeid(T).stringof[1..$] ~ ":" ~ T.sizeof.stringof ) );
		static const list = ctfe_split(tpl_var_id_offset_size, ':');
		static assert(list.length is 5);
		static const id = ctfe_a2i(list[2]);
		static const offset = ctfe_a2i(list[3]);
		static const size	= ctfe_a2i(list[4]);
		// pragma(msg, tpl_var_id_offset_size);
		assert( _tpl_tuple.length > offset + size );
		memcpy( &_tpl_tuple[offset  ], &t, size  );
		
		return this ;
	}

}

template Tpl_Jade(string name, T, string _file = __FILE__, size_t _line = _LINE__) {

	static const string render_arg = "tpl://render::" ~ T._class_loc ~ "::"  ~ name ~ ":"  ~ T._file[0..$] ~ "#" ~ ctfe_i2a(T._line) ~ "," ~ _file[0..$] ~ "#" ~ ctfe_i2a(_line)  ;
	static const string render_src = import( render_arg ) ;
	// pragma(msg, render_src) ;
	
	mixin(render_src) ;
	
	alias  typeof(&_tpl_struct.init.render) _tpl_render_delegate ;

	_tpl_struct* compile(T tpl){
		return cast(_tpl_struct*) tpl._tpl_tuple.ptr ;
	}
}


class User {
	bool 	login = false;
	bool 	admin ;
	int	id  = 3001 ;
	string 	name = "Chang Long" ;
}


class MyApp : FCGI_Application {
	alias Tpl!("UserList", __FILE__, __LINE__) MyTpl ;
	
	MyTpl	tpl ;
	User	u ;
	string	page_title	= "test page"[] ;
	vBuffer bu ;
	
	
	public this(size_t id) {
		super(id) ;
		
		tpl	= new MyTpl ;
		u	= new User ;
		
		static assert(isPointer!( typeof(&u) ));
		
		tpl.assign!("user", __FILE__, __LINE__)(u);
		
		tpl.assign!("page_title", __FILE__, __LINE__)( page_title );
		
		tpl.assign!("env", __FILE__, __LINE__)(environment.toAA);
		
		bu		= new vBuffer(1024, 1024) ;
		
	}
	
	int run(FCGI_Request req) {
	
		assert( bu !is null);
		
		assert( req !is null);
		auto stdout = req.stdout ;
		assert( stdout !is null);
		
		StopWatch sw;
		sw.start;
		
		u.login	= !u.login ;
		u.id ++ ;
		if( u.id % 3 is 0 ) {
			u.admin	= !u.admin ;
		}
		
		tpl.assign!"req"( req );
		
		mixin Tpl_Jade!("./example.jade", typeof(tpl) , __FILE__, __LINE__) jade ;
		
		auto obj	= jade.compile(tpl);

		obj.render(bu);
		scope(exit){
			bu.clear;
		}
		sw.stop;
		
		stdout ("Content-type: text/html\r\n");
		stdout ("RenderTime: ")(sw.peek.msecs)("ms\r\n");
		stdout("\r\n");
		stdout(bu.slice);
		
		return 0 ;
	}
}


void main() {
	auto conn	= new shared(FCGI_Connection)(null, "1983" );
	FCGI_Application.loop!MyApp(conn, true, 1) ;
}

unittest{

	int[] test_i ;
	static assert( isIterable!( typeof(test_i) ));
	static assert( !isIterable!( typeof(&test_i) ));
	int[int] test_aa ;
	static assert( isIterable!( typeof(test_aa) ));
	auto test_aa_ptr = &test_aa;
	static assert( !isIterable!( typeof(test_aa_ptr) ));
	
	struct test_b {
		alias int delegate(ref int)  dg_ty;
		int opApply(dg_ty  dg) {
			return 0;
		}
	}
	test_b b;
	static assert( isIterable!( typeof(b) ));
	auto b_ptr = &b ;
	static assert( !isIterable!( typeof( b_ptr ) ) );
	
	class test_c {
		alias int delegate(ref int)  dg_ty;
		int opApply(dg_ty  dg) {
			return 0;
		}
	}
	test_c c = new test_c ;
	static assert( isIterable!( typeof(c) ));
	auto c_ptr = &c ;
	static assert( !isIterable!( typeof( c_ptr ) ) ) ;

}