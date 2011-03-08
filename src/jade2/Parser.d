
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
	
	void err(size_t _line = __LINE__, T...)(string fmt, T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) ", __FILE__, _line);
		formattedWrite(a, fmt, t);
		formattedWrite(a, " at file:`%s` line:%d", filename, ln);
		stderr.write("\n- ", a.data, "\n");
		_J.Exit(1);
	}
	
	void err(size_t _line = __LINE__, T...)(string fmt, T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) ", __FILE__, _line);
		formattedWrite(a, fmt, t);
		//formattedWrite(a, " at file:`%s` line:%d", filename, ln);
		stderr.write("\n- ", a.data, "\n");
		_J.Exit(1);
	}
	
	void parse() {
		lexer.parse ;

		Block block	= NewTok!(Block)();
		
		/*
		Tok* tk	= lexer.parse ;
		while( tk !is null ) {
			auto node = parseExpr ;
			tk	= tk.next ;
		}
		*/
	}
	
	private N NewTok(N,T...)(T t) if( is(N==class) && BaseClassesTuple!(N).length > 0 && is( BaseClassesTuple!(N)[0] == Node) ){
		N node = pool.New!(N)(t) ;
		mixin("node.ty = Node.Type." ~ N.stringof  ~ ";" );
		return node ;
	}
	
	private Node parseExpr(){
		
		return null ;
	}
}
