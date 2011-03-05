//: \$dmd2 -J. -unittest

module tpl2.test ;

import std.stdio, std.conv ;


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

class Tpl(string TplName, string _file = __FILE__, size_t _line = __LINE__ ) {
	alias void* Buffer;
	alias void delegate(Buffer) render_dg_ty ;
	
	static const string _class_loc	 = TplName ~ ":" ~ _file[0..$] ~ "#" ~ ctfe_i2a(_line) ;
	static const import_tpl_object	 =  import( "tpl://new::" ~ _class_loc ) ;
	
	void*	_tpl_tuple ;

	void opDispatch(string s, T)(T i) {
		writefln("S.opDispatch('%s', %s)", s, i);
	}

	typeof(this) assign(string name, string __file = __FILE__, size_t __line = __LINE__, T)(T t){
		static const string _method_loc =  name ~ ":"  ~ _file[0..$] ~ "#" ~ ctfe_i2a(_line) ~ "," ~ __file[0..$] ~ "#" ~ ctfe_i2a(__line) ;
		
		static const tpl_var_id_offset_size	= import( "tpl://assign::" ~ _class_loc ~ "::"  ~ ( _method_loc ~ ":" ~  T.stringof[0..$] ~ ":" ~ typeid(T).stringof[1..$] ~ ":" ~ T.sizeof.stringof ) );
		pragma(msg, tpl_var_id_offset_size );
		
		return this ;
	}
	
	render_dg_ty render(string name, string __file = __FILE__, size_t __line = __LINE__)(){
		static const string _method_loc =  name ~ ":"  ~ _file[0..$] ~ "#" ~ ctfe_i2a(_line) ~ "," ~ __file[0..$] ~ "#" ~ ctfe_i2a(__line) ;
		static const render_fn	= import( "tpl://render::" ~ _class_loc ~ "::"  ~ ( _method_loc ) );
		pragma(msg, render_fn );
		
		mixin(render_fn) ;
	}
}

class User {
	int i = 9;
	int j = 9;
	pragma(msg, typeid(typeof(i)).stringof ~ "\n\n");
}

void main() {
	
	auto tpl = new Tpl!("UserList", __FILE__, __LINE__) ;
	
	int i = 10 ;
	auto u = new User ;
	
	tpl.assign!("user", __FILE__, __LINE__)(u);
	tpl.assign!("i", __FILE__, __LINE__)(i);
	
	auto u2 = new .User ;
	tpl.assign!("user", __FILE__, __LINE__)(u2);
	
	tpl.assign!("import", __FILE__, __LINE__)(i);
	
	auto fn1	= tpl.render!("test.jade", __FILE__, __LINE__)();
	
	fn1(&fn1);
	
}