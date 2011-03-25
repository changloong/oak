
module oak.langs.scss.Compiler ;

import oak.langs.scss.Scss ;


struct Compiler {
	alias typeof(this) This;
	
	Pool*		pool ;
	vBuffer		_str_bu , _ret_bu ;
	string		filedata ;
	string		filename ;
	Parser		parser ;
		
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
		
		/*
		parser.root.asD( &this ) ;
		FinishLastOut;
		*/
		
		return _ret_bu.toString ; 
	}
}