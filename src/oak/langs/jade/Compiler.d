
module oak.langs.jade.Compiler ;

import oak.langs.jade.Jade ;


struct Compiler {
	alias typeof(this) This;
	alias This*	pThis ;
	
	package {
		enum asType {
			None,
			Code ,
			String ,
			Var ,
		}
		static const string[] asType_Name	= ctfe_enum_array!(asType) ;
		
		static string sType(asType ty){
			assert( ty >=0 && ty <= asType_Name.length );
			return asType_Name[ty];
		}
	}
	
	Pool*		pool ;
	vBuffer		_str_bu , _ret_bu ;
	Parser		parser ;
	string		filedata ;
	string		filename ;
	asType		_astype ;
	ptrdiff_t	i18n_id ;
	
	bool delegate(string, ref string, ref string) check_each_keyvalue ;
	bool delegate(ref string) check_var_name ;
	string delegate(ref string) load_source ;
	
	~this(){
		if( pool !is null ) {
			pool.__dtor ;
		}
	}
	
	void Init(string _filename, string _filedata) in {
		assert(_filename !is null);
		assert(_filedata !is null);
	} body {
		if( pool is null ) {
			pool	= new Pool ;
		}
		filename	= _filename ;
		filedata	= _filedata ;
		if( _str_bu is null ) {
			_str_bu	= new vBuffer(1024, 1024) ;
		}
		if( _ret_bu is null ) {
			_ret_bu	= new vBuffer(1024, 1024) ;
		}
		i18n_id	= 0 ;
	}
	
	void err(size_t _line = __LINE__, T...)(string fmt, T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) %s ", __FILE__, _line, filename);
		formattedWrite(a, fmt, t);
		//formattedWrite(a, " at file:`%s` line:%d", filename, ln);
		throw new Exception( a.data );
	}
	
	void check_each(Each node){
		if( check_each_keyvalue !is null && ! check_each_keyvalue(node.obj, node.type, node.value_type) ) {
			parser.err("can't infer each type at `%s`:`%d` ", filename , node.ln);
		}
	}
	
	void reuse(Compiler* cc){
		cc.FinishLastOut();
		_str_bu	= cc._str_bu ;
		_ret_bu	= cc._ret_bu ;
		pool	= cc.pool ;
		i18n_id	= cc.i18n_id ;
	}
	
	void reuse_clear(){
		
		FinishLastOut() ;
		
		_str_bu	= null ;
		_ret_bu	= null ;
		pool	= null ;

	}
	
	string load_file(ref string file){
		if( load_source !is null ) {
			return load_source(file);
		} else {
			if( std.file.exists( file ) ) {
				return cast(string) std.file.read(file);
			}
		}
		return null ;
	}
	
	void check_var(Var var){
		
	}
	
	string compile( bool reuse = false ) in {
		assert(filename !is null);
		assert(filedata !is null);
	} body {
		if( !reuse ) {
			_str_bu.clear ;
			pool.Clear ;
		}
		parser.Init(&this) ;
		parser.parse ;
		
		if( !reuse ) {
			_ret_bu.clear;
		}
		
		parser.root.asD( &this ) ;
		FinishLastOut;
		return _ret_bu.toString ; 
	}
	
	private string type(){
		return asType_Name[_astype] ;
	}
	
	void FinishLastOut(){
		switch(_astype){
			case asType.String:
				_ret_bu("\");\n");
			case asType.Var:
				break;
			case asType.None:
				break;
			case asType.Code:
				break;
			default:
				assert(false,type );
		}
		
		_astype	=  asType.None ;
	}
	
	public pThis asLine(size_t ln){
		FinishLastOut() ;
		_astype	=  asType.None ;
		_ret_bu ("#line ")(ln)(" \"")(filename)("\" \n") ;
		return &this ;
	}
	
	public pThis asString(string val,  bool escape = false ) {
		if( _astype !is asType.String){
			FinishLastOut() ;
			if( _astype !is asType.String ) {
				_ret_bu("\tob(\"");
			}
		}
		if( escape ) {
			_ret_bu.escape(val) ;
		} else {
			_ret_bu.unstrip(val) ;
		}
		_astype	=  asType.String ;
		return &this ;
	}
	
	public pThis asVar(string val,  bool escape = false ){
		if( _astype is asType.String ) {
			FinishLastOut ;
		}
		
		if( escape ) {
			_ret_bu("\tob.escape(")(val)(");\n");
		} else {
			_ret_bu("\tob(")(val)(");\n");
		}
		
		_astype	=  asType.Var ;
		return &this ;
	}
	
	public pThis asCode(T)(T val){
		if( _astype is asType.String ) {
			FinishLastOut ;
		}
		_ret_bu(val);
		_astype	= asType.Code ;
		return &this ;
	}
	
}