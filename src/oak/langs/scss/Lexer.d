
module oak.langs.scss.Lexer ;

import oak.langs.scss.Scss ;

struct Lexer {
	alias typeof(this) This ;
	
	Pool*		pool ;
	vBuffer		_str_bu ;
	ptrdiff_t	ln ;
	string		filename ;
	
	Tok*		_root_token ;
	Tok*		_last_token ;
	
	const(char)*	_ptr ;
	const(char)*	_end ;
	const(char)*	_start ;
	
	void Init(Compiler* cc)  in {
		assert( cc !is null);
	} body {
		pool		= cc.pool ;
		_str_bu		= cc._str_bu ;
		filename	= cc .filename ;
		
		_ptr	= &cc.filedata[0];
		_end	= &cc.filedata[$-1];
		_start	= _ptr ;
		ln	= 1 ;
	}
	
	void err(size_t _line = __LINE__, T...)(string fmt, T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) ", __FILE__, _line);
		formattedWrite(a, fmt, t);
		formattedWrite(a, " at file:`%s` line:%d", filename, ln);
		throw new Exception(a.data);
	}
	
	
	void parse() {
		
	}
}

