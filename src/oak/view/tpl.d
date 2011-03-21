module oak.view.tpl ;

import oak.all ;

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
		
		enum _type = ctfe_typeof!(T) ;
		enum _each_type = ctfe_each_type!(T);
		
		static const tpl_var_id_offset_size	= import( "tpl://assign::" ~ _class_loc ~ "::"  ~ ( _method_loc ~ ":" ~  _type ~ ":" ~ typeid(T).stringof[1..$] ~ ":" ~ T.sizeof.stringof ~ "::" ~ _each_type ) );
		static const list = ctfe_split(tpl_var_id_offset_size, ':');
		static assert(list.length is 5);
		static const id = ctfe_a2i(list[2]);
		static const offset = ctfe_a2i(list[3]);
		static const size	= ctfe_a2i(list[4]);
		// pragma(msg, tpl_var_id_offset_size);
		assert( _tpl_tuple.length > offset + size );
		std.array.memcpy( &_tpl_tuple[offset ], &t, size  );
		
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