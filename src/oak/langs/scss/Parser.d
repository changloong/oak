
module oak.langs.scss.Parser ;

import oak.langs.scss.Scss ;

struct Parser {
	
	Pool*		pool ;
	string		filename ;
	string		filedata ;
	Lexer		lexer ;
	Node		_last_node, _root_tok ;
	Tok*		_last_tok ;
	
	alias 	_last_tok peek ;
	
	void Init(Compiler* cc) in {
		assert( cc !is null);
	} body {
		pool		= cc.pool ;
		filename	= cc .filename ;
		filedata	= cc .filedata ;
		lexer.Init(cc) ;
	}
	
	void parse(){
		lexer.parse ;
	}
}
