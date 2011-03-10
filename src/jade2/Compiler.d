
module jade.Compiler ;

import jade.Jade ;

private {
	
	enum OutType {
		None,
		Code ,
		String ,
		Var ,
	}

}



struct Compiler {
	Pool		pool ;
	vBuffer		_str_bu ;
	vBuffer		_ret_bu ;
	Parser		parser ;
	string		filedata ;
	string		filename ;
	
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
	
	void compile() in {
		assert(filename !is null);
		assert(filedata !is null);
	} body {
		_str_bu.clear ;
		_ret_bu.clear ;
		pool.Clear ;
		parser.Init(&this) ;
		parser.parse ;
		
		parser.root.asD(_ret_bu);
		
		Log("`%s`",  cast(string) _ret_bu.slice);
	}
	
}