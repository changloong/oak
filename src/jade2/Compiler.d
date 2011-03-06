
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
	
	void Init(string _filename, string _filedata) in {
		assert(_filename !is null);
		assert(_filedata !is null);
	} body {
		filename	= _filename ;
		filedata	= _filedata ;
		parser.compiler	= &this ;
		parser.Init ;
	}
	
	void compile(){
		parser.parse ;
	}
}