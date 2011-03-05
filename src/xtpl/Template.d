
module xtpl.Template ;

import 
	xtpl.all;

class XTpl {
	static __gshared _tpl_protocol	= "tpl://" ;
	static __gshared _OK_message	= cast(char[]) "tpl::ok" ;
	
	alias  typeof(this)	This ;
	static __gshared This[string]	tpl_instances ;
	
	static char[] Invoke(char[] _argument){
		if( _argument is null || _argument.length < _tpl_protocol.length || _argument[0.._tpl_protocol.length] != _tpl_protocol ){
			return null ;
		}
		auto args	= cast(char[][]) std.array.split(_argument[_tpl_protocol.length..$], "::");
		if( args.length < 2 ) {
			return null ;
		}
		
		for(int i = _tpl_protocol.length; i < _argument.length;i++){
			if( _argument[i] is ':' ){
				int j = i+1 ;
				if( j < _argument.length && _argument[j] is ':' ){
					_argument[i]	= 0 ;
					i++;
				}
			}
		}
		
		
		switch( args[0] ) {
			case "new":
				This _this = Tpl_New(args, true) ; 
				return  _this is null ? null : _OK_message;
			case "assign":
				return Tpl_Assign(args);
			case "render":
				return Tpl_Render(args);
			default:
				tpl_error("`tpl::%s` is invalid ", args[0] );
		}
		
		return null ;
	}
	
	static This Tpl_New(char[][] args, bool create = false ) {
		
		char[][] _args	= cast(char[][]) std.array.split(args[1], ":");
		
		foreach(int i, ref c; args[1]) {
			if( c is ':' ) c = '\0' ;
		}
		
		string _tpl_name = cast(string) _args[0] ;
		
		auto _pthis	= _tpl_name in tpl_instances ;
		
		This _this ;
		
		if( _pthis is null ) {
			if( !create ) {
				return null ;
			}
			_this	= new XTpl(_args[0], _args[1] );
		
			tpl_instances[ _tpl_name.idup ] = _this ;
			
			version(PLUGIN_DEBUG)
				tpl_print("New Template (%s:%s) ", _args[0], _args[1] );
			
		} else {
			_this	= *_pthis ;
			version(PLUGIN_DEBUG)
				tpl_print("New Template (%s:%s) Find exists Template (%s:%s)  ", _args[0], _args[1], _this._name, _this._loc );
			
			if( _this._name != _tpl_name ) {
				tpl_print("inner error" );
				return null ;
			}
			
		}
		
		return _this ;
	}
	
	static char[] Tpl_Assign(char[][] args) {
		
		This _this	= Tpl_New(args);

		auto _args	= cast(char[][]) std.array.split(args[2], ":" ) ;
		
		if( _args is null || _args.length !is 5 ){
			tpl_error("tpl::assign invalid arguments number:%d  = `%s` ", _args.length,  _args[0] );
		}
		
		foreach(ref c;args[2]) if(c is ':') c = 0;
		
		auto var	= _this.getVar( _args ) ;
		if( var is null ) {
			return null ;
		}
		
		return cast(char[]) var.index_message() ;
	}
	
	static char[] Tpl_Render(char[][] args ){
		This _this	= Tpl_New(args);
		auto _args	= cast(char[][]) std.array.split(args[2], ":" ) ;
		
		return cast(char[]) _this.getStruct( _args[1])  ;
	}
	
	string 		_name ;
	string 		_loc ;
	XTpl_Var[string]	_vars ;
	size_t		_offset ;
	
	string 		_tuple_loc ;
	XTpl_Buffer		_tuple_bu ;
	size_t		_tuple_len ;
	
	public this(char[] name, char[] loc) {
		_name	= cstring_dup( name.ptr ) ;
		_loc		= cstring_dup( loc.ptr ) ;
		_tuple_bu	= new XTpl_Buffer(1024, 1024);
	}
	
	private XTpl_Var getVar(char[][] args){
		XTpl_Var var	= null ;
		foreach( _var; this._vars){
			if( _var.name == args[0] ) {
				var	= _var;
				break ;
			}
		}

		if( var is null ) {
			if( _tuple_len ) {
				tpl_error("%s.assign at (%s) , but already build tuple at %s", this, args[XTpl_Var.Index.Loc], _tuple_loc) ;
			}
			var		= new XTpl_Var(this, args) ;
		} else {
			if( var.name != args[ XTpl_Var.Index.Name ] ) {
				tpl_error("tpl:assign (%s) inner error ln:%d ",  this);
			}
			
			if( var.tyid != args[ XTpl_Var.Index.TypeID ] ) {
				if( var.name != args[ XTpl_Var.Index.Name ] ){
					tpl_error("tpl:assign (%s) type conflict (%s:%s=%s) with (%s:%s=%s) ",  this, var.type , var.name , var.loc , args[XTpl_Var.Index.Type], args[XTpl_Var.Index.Name],  args[XTpl_Var.Index.Loc] );
				} else {
					tpl_error("tpl:assign (%s) type conflict (%s:%s=%s)(%s) with (%s:%s=%s)(%s) ",  this, var.type , var.name , var.loc , var.tyid , args[XTpl_Var.Index.Type], args[XTpl_Var.Index.Name],  args[XTpl_Var.Index.Loc], args[XTpl_Var.Index.TypeID ] );
				}
			}
			
			if( var.size != ctfe_a2i(args[XTpl_Var.Index.Size ]) ) {
				tpl_error("tpl:assign (%s) error size ",  this);
			}
		}
		
		return var ;
	}
	
	public string getStruct(char[] loc) {
		if( _tuple_len ) {
			if( _tuple_len != _vars.length ){
				tpl_error("%s build tuple error ( %s != %s ) ", this, loc, _tuple_loc) ;
			}
			return _tuple_bu.toString ;
		}
		_tuple_loc	= loc.idup ;
		_tuple_len	= _vars.length ;
		_tuple_bu
			("\n// xtpl tuple ")(_name)("\n")
			("static struct xtpl_tuple_")(_name)(" {\n")
			("\tprivate alias typeof(this) _This ; \n")
		;
		ubyte[1024 * 16] _tmp_bu ;
		scope bu	= new XTpl_Buffer(_tmp_bu);

		XTpl_Var[] var_list	= new XTpl_Var[_tuple_len] ;
		foreach(ref var; _vars) {
			if( var_list[var.id] !is null ) {
				tpl_error("big error");
			}
			var_list[var.id] = var ;
		}
		
		foreach(size_t key_i, var; var_list) {
			
			string key	= var.name ;
			
			_tuple_bu
				("\n\t")(var.type)("	")( key ) (";\n")
				("\tstatic assert( typeid(typeof(_This.tupleof[")(key_i)("])).stringof == `&")( var.tyid ) ("` , `")(this._name)("(")(this._loc)(").")(var.type)(":")(var.name)("(")(var.loc)(").typeid (")(var.tyid)(") !=")("` ~ typeid(typeof(_This.tupleof[")(key_i)("])) ) ;\n")
				("\tstatic assert(_This.tupleof[")(key_i)("].offsetof is ")( var.offset ) (", `")(this._name)("(")(this._loc)(").")(var.type)(":")(var.name)("(")(var.loc)(")(")(var.tyid)(").offsetof (")(var.offset)(") !=")("` ~ _This.tupleof[")(key_i)("].offsetof.stringof  ) ;\n")
				("\tstatic assert( typeof(_This.tupleof[")(key_i)("]).sizeof is ")( var.size ) (", `")(this._name)("(")(this._loc)(").")(var.type)(":")(var.name)("(")(var.loc)(")(")(var.tyid)(").sizeof (")(var.size)(") !=")("` ~ typeof(_This.tupleof[")(key_i)("]).sizeof.stringof ) ;\n")
			;
		}
		
		_tuple_bu("\n\t void xtpl_tuple_")(_name)("_function_render(Buffer bu){\n");
			_tuple_bu
					("int jj = i ;\n")
			;
		
		_tuple_bu("\t}\n");
		_tuple_bu("} \n");
		
		_tuple_bu("return & ( (cast(xtpl_tuple_")(_name)("*)  this._tpl_tuple). xtpl_tuple_")(_name)("_function_render );\n");
		return _tuple_bu.toString ;
	}
	
	public string toString(){
		return _name ;
	}
}