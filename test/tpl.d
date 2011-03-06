//: \$dmd2 -J. -unittest \+..\src\xtpl\Buffer.d

module tpl2.test ;

import std.stdio, std.conv, std.traits, xtpl.Buffer ;


alias XTpl_Buffer Buffer;

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

	typeof(this) assign(string name, string __file = __FILE__, size_t __line = __LINE__, T)(T t){
		static const string _method_loc =  name ~ ":"  ~ _file[0..$] ~ "#" ~ ctfe_i2a(_line) ~ "," ~ __file[0..$] ~ "#" ~ ctfe_i2a(__line) ;
		
		static const tpl_var_id_offset_size	= import( "tpl://assign::" ~ _class_loc ~ "::"  ~ ( _method_loc ~ ":" ~  T.stringof[0..$] ~ ":" ~ typeid(T).stringof[1..$] ~ ":" ~ T.sizeof.stringof ) );
		static const list = ctfe_split(tpl_var_id_offset_size, ':');
		static assert(list.length is 5);
		static const id = ctfe_a2i(list[2]);
		static const offset = ctfe_a2i(list[3]);
		static const size	= ctfe_a2i(list[4]);
		
		pragma(msg, tpl_var_id_offset_size);

		assert( _tpl_tuple.length > offset + size );
		
		memcpy( &_tpl_tuple[offset  ], &t, size  );
		
		return this ;
	}

}

template Tpl_Jade(string name, T, string _file = __FILE__, size_t _line = _LINE__) {

	static const string render_arg = "tpl://render::" ~ T._class_loc ~ "::"  ~ name ~ ":"  ~ T._file[0..$] ~ "#" ~ ctfe_i2a(T._line) ~ "," ~ _file[0..$] ~ "#" ~ ctfe_i2a(_line)  ;
	static const string render_src = import( render_arg ) ;
	pragma(msg, render_src) ;
	mixin(render_src) ;
	alias  typeof(&_tpl_struct.init.render) _tpl_render_delegate ;

	_tpl_struct* compile(T tpl){
		return cast(_tpl_struct*) tpl._tpl_tuple.ptr ;
	}
}


class User {
	bool 	login = true ;
	bool 	admin ;
	int	id  = 300 ;
	string 	name = "Chang Long" ;
}

void main() {

	auto tpl = new Tpl!("UserList", __FILE__, __LINE__) ;
	
	auto u = new User ;
	tpl.assign!("user", __FILE__, __LINE__)(u);
	
	tpl.assign!("page_title", __FILE__, __LINE__)( "test page"[] );
	
	mixin Tpl_Jade!("../src/jade/example.jade", typeof(tpl) , __FILE__, __LINE__) jade ;
	
	auto obj = jade.compile(tpl);
	auto bu = new XTpl_Buffer(1024, 1024);
	obj.render(bu);
	
	writefln("%s", bu);
}