
module oak.langs.jade.xtpl.Template ;

import 
	oak.langs.jade.xtpl.all ;


class XTpl {

	static __gshared _tpl_protocol	= "tpl://" ;
	static __gshared _OK_message	= cast(char[]) "tpl::ok" ;
	static __gshared Compiler	jade ;
	
	alias  typeof(this)	This ;
	static __gshared This[string]	tpl_instances ;
	static __gshared string[] inner_vars	= ctfe_split(
									"ob empty put front back popFront popBack toHash toString init destroy clear length remove typeinfo"
									, ' ');
	static __gshared string[] inner_type	= ["render"];
	static __gshared string[] buildin_type	= ctfe_split(
					" void byte bool ubyte short ushort int uint long ulong cent ucent float double real ifloat idouble ireal cfloat cdouble creal char wchar dchar body asm bool true false function delegate"
					" Object ClassInfo  ModuleInfo IUnknown"
					" std math"
					" string size_t ptrdiff_t ssize_t"
					" __LINE__ __FILE__ __DATE__ __TIME__ __TIMESTAMP__ __VENDOR__ __VERSION__ __EOF__"
					,' ') ;
	static __gshared string[] key_words	= ctfe_split(
					" public private protected with extern "
					" final abstract override const debug version pragma public private deprecated protected volatile"
					" class struct interface enum new this null delete invariant super union template"
					" if for foreach while do assert return unittest try catch else throw switch case break continue default finally goto synchronized"
					" is import module alias typedef with cast package typeof typeid classinfo mixin"
					" in out const static inout lazy ref extern export auto align scope pure"
					" tupleof stringof sizeof offsetof mangleof tupleof alignof"
					" __gshared __traits __ctfe __vptr __monitor __coverage __ctor __dtor __cpctor __postblit __invariant __unitTest __result __returnLabel"
					,' ') ;
	
	static char[] Invoke(char[] _argument){

		if( _argument is null || _argument.length < _tpl_protocol.length || _argument[0.._tpl_protocol.length] != _tpl_protocol ){
			return null ;
		}
		auto args	= cast(char[][]) std.array.split(_argument[_tpl_protocol.length..$], "::");
		if( args.length < 2 ) {
			return null ;
		}
		
		for(ptrdiff_t i = _tpl_protocol.length; i < _argument.length;i++){
			if( _argument[i] is ':' ){
				ptrdiff_t j = i+1 ;
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
		
		auto var	= _this.getVar( _args , args[3] ) ;
		
		return cast(char[]) var.index_message() ;
	}
	
	static char[] Tpl_Render(char[][] args ){
		This _this	= Tpl_New(args);
		auto _args	= cast(char[][]) std.array.split(args[2], ":" ) ;
		if( _args.length !is 2 ){
			tpl_error("tpl:render invalid argument `%s`", args);
		}
		return cast(char[]) _this.getRender(_args[0],  _args[1])  ;
	}
	
	static void check_var_name(char[] var, char[] loc){
		
		if( var is null || var.length is 0 ){
			tpl_error("var name can't be empty", 0);
		}
		
		if( !(var[0] is '_' || var[0] >='a' && var[0] <='z' ||var[0] >='A' && var[0] <='Z')  ){
			tpl_error("var name `%s` on loc(%s) first char must be [_a-zA-Z] ", var, loc);
		}
		
		foreach(int i, c; var[1..$] ) {
			if( !(c is '_' || c >='a' && c <='z' || c >='A' && c <='Z'|| c >='0' && c <='9')  ){
				tpl_error("var name `%s` on loc(%s) must be [_a-zA-Z0-9]+ ", var, loc);
			}
		}
		
		if( std.algorithm.countUntil(buildin_type , cast(string) var) >= 0 ){
			tpl_error("var name `%s` on loc:(%s) is a buildin type", var, loc );
		}
		
		if( std.algorithm.countUntil(inner_type, cast(string) var) >= 0 ){
			tpl_error("var name `%s` on loc:(%s) is a type", var, loc );
		}
		
		if( std.algorithm.countUntil(inner_vars, cast(string) var) >= 0 ){
			tpl_error("var name `%s` on loc:(%s) is already been used as inner var, please use other name", var, loc );
		}
		
		if( std.algorithm.countUntil(key_words, cast(string) var) >= 0 ){
			tpl_error("var name `%s` on loc:(%s) is a key word, please use other name", var, loc );
		}
		
		static __gshared RegExp re1 ;
		if( re1.empty ) {
			re1(`^op[A-Z][a-zA-z\_]+$`);
		}
		
		re1.each(cast(string) var, (string[] ms){
			tpl_error("var name `%s` on loc:(%s) is invalid", var, loc );
			return false;
		});
	}
	
	static string Load_Source_(char[] file, ref char[] _file_path , bool _throw = true ){
		
		foreach( _dir; project_paths ){
			char[] __file__path = _dir ~ file  ;
			if( std.file.exists( __file__path ) ) {
				_file_path	= __file__path ;
				break ;
			}
		}
		if( _file_path is null ) {
			if( _throw ) {
				tpl_error("temmplate source file `%s` can't be find in %s", file, project_paths);
			}
			return null ;
		}
		
		if( !std.file.exists(_file_path) ) {
			if( _throw ) {
				tpl_error("temmplate source file `%s` can't be find in %s", file, project_paths);
			}
			return null ;
		}
		
		auto data	= cast(string) std.file.read(_file_path);
		return data ;
	}
	
	string 		_name ;
	string 		_loc ;
	XTpl_Var[string]	_vars ;
	size_t		_offset ;
		
	string 		_tuple_loc ;
	vBuffer		_tuple_bu ;
	size_t		_tuple_len ;
	string		_tpl_file ;
	
	public this(char[] name, char[] loc) {
		check_var_name(name, loc);
		_name		= cstring_dup( name.ptr ) ;
		_loc		= cstring_dup( loc.ptr ) ;
		_tuple_bu	= new vBuffer(1024, 1024);
	}
	
	private XTpl_Var getVar(char[][] args, char[] _each_types){
		
		string _name = cast(string) args[0] ;
		
		auto _pvar	= _name in _vars ;
		XTpl_Var var 	= null ;
		if( _pvar is null ) {
			if( _tuple_len ) {
				tpl_error("%s.assign at (%s) , but already build tuple at %s", this, args[XTpl_Var.Index.Loc], _tuple_loc) ;
			}
			check_var_name(args[0], args[1]);
			
			foreach(ref __var; _vars) {
				// check the var.name is used as type 
				if( __var.name == cast(string) args[XTpl_Var.Index.Type] ){
					tpl_error("var `%s` (%s) is use type %s (%s) as name", __var.name, __var.loc, args[XTpl_Var.Index.Type], args[XTpl_Var.Index.Loc]);
				} 
				if( __var.type == cast(string) args[XTpl_Var.Index.Name] ){
					tpl_error("var `%s` (%s) is use type %s (%s) as name", args[XTpl_Var.Index.Type], args[XTpl_Var.Index.Loc], __var.type, __var.loc);
				}
			}
			var		= new XTpl_Var(this, args) ;
			
			var.setEachType(_each_types );
		
		} else {
			var	= *_pvar ;
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
	
	public string getRender(char[] file, char[] loc) {

		char[] _file_path ;
		auto _file_data = Load_Source_( file, _file_path);
		jade.Init( cast(string) _file_path, _file_data);
		
		auto _old_tpl_file	= _tpl_file ;
		_tpl_file		= cast(string) _file_path ;
		scope(exit){
			_tpl_file	= _old_tpl_file ;
		}
		
		if( _tuple_len ) {
			if( _tuple_len != _vars.length ){
				tpl_error("%s build tuple error ( %s != %s ) ", this, loc, _tuple_loc) ;
			}
			return _tuple_bu.toString ;
		}
		
		_tuple_loc	= loc.idup ;
		_tuple_len	= _vars.length ;
		_tuple_bu
			("\n#line 1 \"xtpl_tuple_")(_name)(".d\" \n")
			("static struct xtpl_tuple_")(_name)(" {\n")
			("\tprivate alias typeof(this) _This ; \n")
		;

		XTpl_Var[] var_list	= new XTpl_Var[_tuple_len] ;
		foreach(ref var; _vars) {
			if( var_list[var.id] !is null ) {
				tpl_error("big error");
			}
			var_list[var.id] = var ;
		}
		
		foreach(size_t key_i, var; var_list) {
			
			string key	= var.name ;
			auto pos_sharp = lastIndexOf( var.loc, '#') ;
			auto pos_comma = lastIndexOf( var.loc, ',') ;
			
			_tuple_bu
				("\n")
				("#line ")(  var.loc[  pos_sharp + 1.. $]) (" \"")(  var.loc[ pos_comma + 1.. pos_sharp])("\"\n")
				("\t")(var.type)("	")( key ) (";\n")
			
				("#line ")(  var.loc[  pos_sharp + 1.. $]) (" \"")(  var.loc[ pos_comma + 1.. pos_sharp])("\"\n")
				("\tstatic assert( typeid(typeof(_This.tupleof[")(key_i)("])).stringof == `&")( var.tyid ) ("` , `")(this._name)("(")(this._loc)(").")(var.type)(":")(var.name)("(")(var.loc)(").typeid (")(var.tyid)(") !=")("` ~ typeid(typeof(_This.tupleof[")(key_i)("])) ) ;\n")
				("#line ")(  var.loc[  pos_sharp + 1.. $]) (" \"")(  var.loc[ pos_comma + 1.. pos_sharp])("\"\n")
				("\tstatic assert(_This.tupleof[")(key_i)("].offsetof is ")( var.offset ) (", `")(this._name)("(")(this._loc)(").")(var.type)(":")(var.name)("(")(var.loc)(")(")(var.tyid)(").offsetof (")(var.offset)(") !=")("` ~ _This.tupleof[")(key_i)("].offsetof.stringof  ) ;\n")
				("#line ")(  var.loc[  pos_sharp + 1.. $]) (" \"")(  var.loc[ pos_comma + 1.. pos_sharp])("\"\n")
				("\tstatic assert( typeof(_This.tupleof[")(key_i)("]).sizeof is ")( var.size ) (", `")(this._name)("(")(this._loc)(").")(var.type)(":")(var.name)("(")(var.loc)(")(")(var.tyid)(").sizeof (")(var.size)(") !=")("` ~ typeof(_This.tupleof[")(key_i)("]).sizeof.stringof ) ;\n")
				("\n")
			;
		}
		
		_tuple_bu("\n\t void render(vBuffer ob){\n\tassert(ob !is null);\n ");
		
		auto _tmp_each	= jade.check_each_keyvalue ;
		auto _tmp_load	= jade.load_source ;
		jade.check_each_keyvalue = &this.check_each_keyvalue ;
		jade.load_source	= &this.load_source ;
		_tuple_bu(jade.compile) ;
		 jade.check_each_keyvalue	= _tmp_each ;
		 jade.load_source	= _tmp_load ;
		
		_tuple_bu("\t}\n");
		_tuple_bu("} \n");
		_tuple_bu("private alias xtpl_tuple_")(_name)(" _tpl_struct ;\n");
		
		return _tuple_bu.toString ;
	}
	
	string load_source(ref string file) {
		char[] _file_path ;
		auto _file_data = Load_Source_( cast(char[]) file, _file_path, false) ;
		file	= cast(string) _file_path ;
		return _file_data ;
	}
	
	public bool check_each_keyvalue(string obj, ref string type, ref string value_type ) {
		auto pvar = obj in _vars ;
		if( pvar is null  ) {
			return true ;
		}
		auto var = *pvar ;
		foreach( it; var._Each_Types ) {
			if( type !is null ) {
				if( value_type is null ) {
					if( it.key == type ) {
						value_type	= it.value ;
						break ;
					}
				}
			} else {
				if( value_type !is null ) {
					if( it.value  == value_type ) {
						if( it.key != "void" ) {
							type	= it.key ;
							break ;
						}
					}
				}
			}
		}
		
		if( type is null && value_type is null  ) {
			foreach( it; var._Each_Types ) {
				if( it.key !is null ) {
					type	= it.key ;
					value_type	= it.value ;
					break ;
				}
			}
		}
		
		if( type is null && value_type is null  ) {
			foreach( it; var._Each_Types ) {
				value_type	= it.value ;
				break ;
			}
		}
		
		return true ;
	}
	
	public string toString(){
		return _name ;
	}

}
