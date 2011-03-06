
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
	}
	
	void compile() in {
		assert(filename !is null);
		assert(filedata !is null);
	} body {
		pool.Clear ;
		parser.Init(&this) ;
		parser.parse ;
	}
	
}