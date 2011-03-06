
module jade.Parser ;

import jade.Jade ;

struct Parser {
	Compiler*	compiler ;
	Lexer		lexer ;
	
	void Init(){
		lexer.compiler	= compiler ;
		lexer.Init ;
	}
	
	void parse(){
		auto tk	= lexer.peek ;
	}
}