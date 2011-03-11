
module jade.Compiler ;

import jade.Jade ;


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
		static const string[] asType_Name	= EnumMemberName!(asType) ;
		
		static string sType(asType ty){
			assert( ty >=0 && ty <= asType_Name.length );
			return asType_Name[ty];
		}
	}
	
	Pool		pool ;
	vBuffer		_str_bu , _ret_bu ;
	Parser		parser ;
	string		filedata ;
	string		filename ;
	asType		_astype ;
	
	~this(){
		pool.__dtor ;
	}
	
	void Init(string _filename, string _filedata) in {
		assert(_filename !is null);
		assert(_filedata !is null);
	} body {
		filename	= _filename ;
		filedata	= _filedata ;
		if( _str_bu is null ) {
			_str_bu	= new vBuffer(1024, 1024) ;
		}
		if( _ret_bu is null ) {
			_ret_bu	= new vBuffer(1024, 1024) ;
		}
	}
	
	void check_each(Each node){
		
	}
	
	void check_var(Var var){
		
	}
	
	string compile() in {
		assert(filename !is null);
		assert(filedata !is null);
	} body {
		_str_bu.clear ;
		pool.Clear ;
		parser.Init(&this) ;
		parser.parse ;
		_ret_bu.clear;
		parser.root.asD( &this ) ;
		FinishLastOut;
		return _ret_bu.toString ; 
	}
	
	private string type(){
		return asType_Name[_astype] ;
	}
	
	private void FinishLastOut(){
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
	}
	
	public pThis asLine(size_t ln){
		FinishLastOut() ;
		_astype	=  asType.None ;
		_ret_bu ("#line ")(ln)(" \"")(filename)("\" \n") ;
		return &this ;
	}
	
	public pThis asString(string val, bool unstrip = true ){
		if( _astype !is asType.String){
			FinishLastOut() ;
			if( _astype !is asType.String ) {
				_ret_bu("\tob(\"");
			}
		}
		if( unstrip ) {
			_ret_bu.unstrip(val);
		} else {
			_ret_bu( val) ;
		}
		_astype	=  asType.String ;
		return &this ;
	}
	
	public pThis asVar(string val, bool unstrip = false ){
		if( _astype is asType.String ) {
			FinishLastOut ;
		}
		if( unstrip ) {
			_ret_bu("\tob(")(val)(");\n") ;
		} else {
			_ret_bu("\tob(")(val)(");\n") ;
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