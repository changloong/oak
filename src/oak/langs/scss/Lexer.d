
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
	
	Tok* NewTok( Tok.Type ty, string val = null ){
		Tok* tk = pool.New!(Tok) ;
		tk.ln	= ln ;
		tk.ty	= ty ;
		if( val !is null ) {
			tk.string_value	= val ;
		}
		return tk ;
	}
	
	private bool skip_space( bool expected = false ){
		while( _ptr <= _end ) {
			if( _ptr[0] != ' ' && _ptr[0] != '\t' ) {
				if( _ptr[0] !is '\r' && _ptr[0] !is '\n' ) {
					return true ;
				}
				if( _ptr[0] is '\r' ) {
					ln++ ;
					_ptr++ ;
					if(  _ptr <= _end  && _ptr[0] is '\n' ) {
						_ptr++ ;
					}
					continue ;
				}
				if( _ptr[0] is '\n' ) {
					ln++ ;
					_ptr++ ;
					continue ;
				}
				assert(false);
			}
			_ptr++ ;
		}
		if( expected ) {
			if( _ptr > _end ) {
				err("expected space but find EOF");
			} else {
				err("expected space but find `%s`",  _ptr[0]);
			}
		}
		return false ;
	}
	
	private char eval_find(T...)(T t) if(T.length > 1 ) {
		char _ret  = '\0' ;
		auto __ptr = _ptr ;
		while( __ptr <= _end ) {
			static if( T.length is 1 ) {
				if( __ptr[0] is t[0] ) {
					_ret	= __ptr[0] ;
					break;
				}
			} else static if( T.length is 2 ){
				if( _ptr[0] is t[0] || __ptr[0] is t[1] ) {
					_ret	= __ptr[0] ;
					break;
				}
			}else static if( T.length is 3 ){
				if( __ptr[0] is t[0] || __ptr[0] is t[1] || __ptr[0] is t[2] ) {
					_ret	= __ptr[0] ;
					break;
				}
			} else {
				static assert(false);
			}
			if( __ptr[0] is '\'' || __ptr[0] is '"' ) {
				// skip string
				char quote = __ptr[0] ;
				__ptr++;
				while( __ptr < _end ) {
					if( __ptr[0] is quote ) {
						break ;
					}
					if( __ptr[0] is '\\' ) {
						__ptr++;
						if( __ptr <= _end ) {
							__ptr++;
						}
						continue;
					}
					__ptr++;
				}
				break;
			}
			
			if( __ptr[0] is '#' ) {
				// skip iExp
				assert(false) ;
			}
			__ptr++;
		}
		return _ret ;
	}
	
	void parse() {
		parseBody(false);
	}
	
	Tok* parseBody( bool with_curly = true ) {
		Tok* tk = null ;
		if( with_curly ) {
			if(  _ptr > _end || _ptr[0] !is '{' ) {
				err("expected {");
			}
			_ptr++;
		}
		
		skip_space ;
		size_t count_i ;
		while( _ptr <= _end ){
			switch( _ptr[0] ) {
				case '$':  // def var 
					assert(false);
					break;
				
				case '@': // def mixin, or fun call
					assert(false);
					break;
				case '/':
					assert(false);
					break;
				
				case '}': // end of body
					assert(false);
				default:
					parsePaths(with_curly) ;
			}
			assert( count_i++ < ushort.max >> 6 );
			skip_space ;
		}
		
		if( with_curly ) {
			assert(false);
		}
		return tk ;
	}
	
	bool parseInlineExp(void delegate() dg) {
		if(  _ptr > _end || _ptr[0] !is '#' ) {
			err("expected #");
		}
		if( 
			_ptr >= _end  // no content follow
			|| _ptr[1] !is '{'
		) {
			return false ;
		}
		dg();
		
		assert(false);
		return true ;
	}
	
	void parsePath( bool with_attr_value = true ) {
		auto __ptr = _ptr ;
		auto _string_ptr = _ptr ;
		size_t count_i ;
		NewTok(Tok.Type.PathStart);
		void save_string(){
			if( _string_ptr !is _ptr ) {
				auto string_value = cast(string) _string_ptr[ 0 .. _ptr - _string_ptr] ;
				NewTok(Tok.Type.String ,  string_value ) ;
				_string_ptr	= _ptr ;
			}
		}
		bool isDone 	= false ;
		while( _ptr <= _end ) {
			switch( _ptr[0] ) {
				// end node;
				case ':': // 
					auto _tmp_ptr = _ptr ;
					auto _ln = ln ;
					_ptr++;
					skip_space;
					/**
						Next Char is {, follow a body 
						font : {  size:12px; }
					*/
					if( _ptr <= _end  ){
						if(  _ptr[0] is '{' ) {
							isDone	= true ;
							break;
						}
					} 
					
					_ptr	= _tmp_ptr ;
					ln	= _ln ;
					_ptr++;
					/**
						( ; or } )  befor { , it should be a  pseudo
						else it is a value ;
					*/
					char _next_char = eval_find( ';', '}', '{' ) ;
					
					if( _next_char !is '{' ) {
						// pseudo left char
						if( __ptr !is _ptr ){
							auto _pre = _ptr - 1;
							if( _pre[0] is ' ' && _pre[1] is '\t' ) {
								err("pseudo must around char");
							}
						} else {
							err("pseudo cant by first path char");
						}
						if( _ptr >= _end || !( _ptr[1] >='a' && _ptr[1] <='z' || _ptr[1] >='A' && _ptr[1] <='Z'  ) && _ptr[1] !is '#'  ) {
							err("pseudo must around char");
						}
						_ptr++ ;
					} else {
						// follow a value or body ;
						
						assert( false ) ;
					}
	
					break;
					
				case ',': // end one path, more to go
					isDone	= true ;
					break;
				
				case '{': // start body
					isDone	= true ;
					break;
				
				// inline node
				case '&':
					if( __ptr !is _ptr ){
						save_string();
						// pre _ptr is space 
						auto _pre = _ptr - 1;
						if( _pre[0] !is ' ' && _pre[1] !is '\t' ) {
							err("parent path must around by space");
						}
						auto _next = _ptr + 1;
						if( _next <= _end && _next[0] !is '{' && _next[0] !is '\t' && _next[0] !is ' ' ) {
							err("parent path must around by space");
						}
					}
					NewTok(Tok.Type.ParentPath) ;
					_ptr++ ;
					skip_space;
					break;
					
				case '"':
				case '\'':
					assert(false);
					break;
				
				case '#':
					if(  parseInlineExp( &save_string ) ) {
						break;
					}
				default:
					_ptr++;
			}
			if( isDone ) {
				break ;
			}
			assert( count_i++ < ushort.max >> 5 );
		}
		if( !isDone ) {
			err("missing path end");
		}
		save_string() ;
		NewTok(Tok.Type.PathEnd);
	}
	
	
	void parsePaths( bool with_attr_value = true  ) {
		Tok* tk = null ;
		size_t count_i ;
		while( _ptr <= _end ) {
			parsePath(with_attr_value) ;
			if( _ptr > _end ) {
				err("path missing content");
			}
			
			switch( _ptr[0] ) {
				case ':':
					_ptr++;
					skip_space;
					if( _ptr >= _end || _ptr[0] !is '{' ) {
						err(" missing content for unwind attribute");
					}
				case '{':
					parseBody;
					break;
				default:
					Log("`%s`", _ptr[0]);
			}
			
			assert(false);
			assert( count_i++ < ushort.max >> 6 );
		}
			
	}
	
}

