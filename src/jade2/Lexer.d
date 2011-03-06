
module jade.Lexer ;

import jade.Jade ;

struct Lexer {
	Pool*		pool ;
	string		filename ;
	string		filedata ;
	Tok*		root;
	
	void Init(Compiler* cc){
		pool		= &cc.pool ;
		filename	= cc .filename ;
		filedata	= cc .filedata ;
	}
	
	Tok* peek() {
		
		return null ;
	}
}

