
module jade.Parser ;

import jade.Jade ;

struct Parser {
	Pool*		pool ;
	string		filename ;
	string		filedata ;
	Lexer		lexer ;
	
	void Init(Compiler* cc) in {
		assert( cc !is null);
	} body {
		pool		= &cc.pool ;
		filename	= cc .filename ;
		filedata	= cc .filedata ;
		lexer.Init(cc) ;
	}
	
	void parse() {
		lexer.parse ;
		
	}
}