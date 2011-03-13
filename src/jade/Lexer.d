
module oak.jade.Lexer ;

import oak.jade.Jade ;

struct Lexer {
	Pool*		pool ;
	vBuffer		_str_bu ;
	string		filename ;
	
	const(char)*	_ptr ;
	const(char)*	_end ;
	const(char)*	_start ;
	
	Tok*		_root_token ;
	Tok*		_last_token ;
	
	size_t	ln, _ln, _last_indent_size, _offset_tabs ;
	
	void Init(Compiler* cc)  in {
		assert( cc !is null);
	} body {
		pool		= &cc.pool ;
		_str_bu		= cc._str_bu ;
		filename	= cc .filename ;
		
		_ptr	= &cc.filedata[0];
		_end	= &cc.filedata[$-1];
		_start	= _ptr ;
		ln	= 1 ;
		_ln	= 0 ;
	}
	
	string line() {
		auto val	= cast(string) _ptr[ 0 .. find(_ptr, _end, '\n') ];
		while( val.length && val[$-1] is '\r' ) val	= val[0..$-1] ;
		return val ;
	}
	
	void err(size_t _line = __LINE__, T...)(string fmt, T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) ", __FILE__, _line);
		formattedWrite(a, fmt, t);
		formattedWrite(a, " at file:`%s` line:%d", filename, ln);
		throw new Exception(a.data);
	}
	
	void dump_tok(string _file = __FILE__, ptrdiff_t _line = __LINE__)( bool from_last_tok = false ) {
		writefln("\n--------- dump tok --------\n%s:%d", _file, _line);
		Tok* tk	= _root_token ;
		if( from_last_tok ) {
			tk	= _last_token ;
		}
		while( tk !is null ) {
			//auto node = parseExpr ;
			writefln("tab:%d ln:%d:%d %s = `%s`" , tk.tabs, tk.ln,tk._ln, tk.type(), tk.string_value );
			tk	= tk.next ;
		}
	}
	
	void parse() {
		while( _ptr <= _end ){
			parseIndent ;
			switch( _ptr[0] ) {
				// DocType
				case '!':
					parseDocType ;
					break;
				// Comment
				case '/':
					parseComment;
					break;
				// code
				case '-':
					parseCode;
					break;
				// filter
				case ':':
					parseFilter;
					break;
				// text
				case '|':
					_ptr++;
					if( _ptr <= _end ) {
						parseString();
					}
					break;
				// id
				case '#':
				// class
				case '.':
					parseTag(`*`) ;
					break;
				// tag 
				default:
					parseTag ;
					break;
			}
			if( _ptr >= _end ) {
				break ;
			}
			if( _ptr[0] !is '\r' && _ptr[0] !is '\n' ){
				err("lexer bug `%s`", line);
			}
			skip_newline;
		}
		if( _root_token is null ) {
			err("empty document");
		}
		_last_token = _root_token ;
	}
	
	private Tok* NewTok(string _file = __FILE__, ptrdiff_t _line = __LINE__)(Tok.Type ty, string val = null ) {
		Tok* tk ;
		tk	= pool.New!(Tok)() ;
		tk.ty	= ty ;
		tk.ln	= ln ;
		tk._ln	= ln - _ln ;
		tk.tabs	= _last_indent_size + _offset_tabs ;
		tk.pre	= _last_token ;
		if( _last_token !is null ) {
			_last_token.next	= tk ;
		} else {
			_root_token	= tk ;
		}
		_last_token	= tk ;
		if( val !is null ) {
			tk.string_value	= val ;
			version(JADE_DEBUG_LEXER_TOK)
				Log!(_file, _line)("%s tab:%d  ln:%d = `%s`", Tok.sType(ty), tk.tabs, ln, val);
		} else {
			version(JADE_DEBUG_LEXER_TOK)
				Log!(_file, _line)("`%s` tab:%d ln:%d", Tok.sType(ty), ln, tk.tabs );
		}
		return tk ;
	}
	
	
	private bool skip_space( bool expected = false ){
		while( _ptr <= _end ) {
			if( _ptr[0] != ' ' && _ptr[0] != '\t' ) {
				return true ;
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
	
	private void skip_newline(){
		if( _ptr > _end ) {
			err("expected new line");
		}
		switch( _ptr[0] ) {
			case '\r':
				_ptr++;
				if( _ptr !is _end && _ptr[0] is '\n' ) {
					_ptr++;
				}
				break ;
			case '\n':
				_ptr++;
				break;
			default:
				err("expected new line");
		}
		version(JADE_DEBUG_LEXER_NEWLINE)
			Log("NewLine");
		ln++ ;
	}
	
	private string skip_identifier() {
		auto __ptr = _ptr ;
		while( _ptr <= _end ) {
			if( 
				_ptr[0] >= '0' && _ptr[0] <= '9' || 
				_ptr[0] >= 'a' && _ptr[0] <= 'z' || 
				_ptr[0] >= 'A' && _ptr[0] <= 'Z' || 
				_ptr[0]	is '_' || _ptr[0]	is '-' 
			) {
				_ptr++ ;
			} else {
				break;
			}
		}
		if( __ptr is _ptr ) {
			return null ;
		}
		return cast(string) __ptr[ 0 .. _ptr - __ptr ] ;
	}
	
	private size_t parseIndent() {
		int i	= 0 ;
		auto __ptr	= _ptr ;
		while( _ptr <= _end ) {
			if( _ptr[0] is ' ' ) {
				i++ ;
			} else if(_ptr[0] is '\t'){
				i += 2 ;
			} else {
				break ;
			}
			_ptr++;
		}
		_last_indent_size	= i / 2 ;
		version(JADE_DEBUG_LEXER_SPACE)
			Log("Indent: tab:%d ln:%d  text:`%s`", _last_indent_size, ln, line );
		return _ptr - __ptr  ;
	}
	
	
	private string skip_inline_qstring(char q){
		if( _ptr >= _end ) {
			err("expected qstring");
		}
		if( _ptr[0] !is q ) {
			err("lexer qstring bug");
		}
		auto __ptr	= _ptr ;
		_ptr++;
		
		bool	is_find	= false ;
		while( _ptr <= _end ) {
						
			if( _ptr[0] is '\r' || _ptr[0] is '\n' ) {
				err("missing qstring end");
			}
			
			if( _ptr[0] is q ) {
				is_find	= true ;
				_ptr++;
				break ;
			}
			if( _ptr[0] is '\\' ) {
				if( _ptr >= _end ) {
					err("expected escape qstring");
				}
				_ptr++;
			}
			_ptr++ ;
			
		}
		
		if( !is_find ) {
			err("missing qstring end");
		}
		
		auto val = cast(string) __ptr[0 .. _ptr - __ptr ];
		return val ;
	}
	
	private  bool scan_skip_line() {
		if( _ptr <= _end - 1 && _ptr[0] is '\\' && (_ptr[1] is '\r' || _ptr[1] is '\n') ) {
			_ptr++;
			auto _tabs	= _last_indent_size ;
			skip_newline;
			_ln ++ ;
			parseIndent ;
			if( _last_indent_size < _tabs ){
				err("expected indent at least %d tabs", _tabs);
			}
			_last_indent_size	= _tabs ;
			skip_space ;
			return true ;
		}
		return false ;
	}
		
	
	Tok* parseInlineCode( Tok.Type _tmp_ty = Tok.Type.None ){
		int lcurly  , paren ;
		
		auto __ptr = _ptr ;
		L1:
		while(  _ptr  <= _end ) {
			switch( _ptr[0] ) {
				case '{':
					_ptr++ ;
					lcurly++;
					break;
				case '}':
					if( lcurly is 0 ) {
						if( paren !is 0){
							err("code end error, paren is not match ", paren);
						}
						_ptr++ ;
						auto val	= __ptr[ 0 .. _ptr - __ptr -1 ] ;
						if( _tmp_ty is Tok.Type.Var ) {
							Tok* tk	= NewTok(Tok.Type.Var, cast(string) val);
							// make var escape
							tk.bool_value	= true ;
							return tk ;
						}
						if( val.length < 3 ) {
							err("expected more code '%s' ", val);
						}
				
						if( val[0] is 'i' && val[1] is 'f' && ( val[2] is ' '  || val[2] is '\t'  ) ) {
							auto _val	= val[3..$] ;
							while(_val.length && _val[0] is ' ') _val = _val[1..$];
							while(_val.length && _val[$-1] is ' ') _val = _val[0..$-1];
							if( _val.length > 0 ) {
								return  NewTok(Tok.Type.If, cast(string) _val ) ;
							}
						} else if( val.length > 3 &&  val[0] is 'e' && val[1] is 'l' && val[2] is 's' && val[3] is 'e'  ){
							auto _val	= val[4..$] ;
							while(_val.length && _val[0] is ' ') _val = _val[1..$];
							while(_val.length && _val[$-1] is ' ') _val = _val[0..$-1];
							
							// else 
							if( _val.length is 0 ) {
								return  NewTok(Tok.Type.Else ) ;
							} else {
								// else if
								if( _val.length > 3 &&  _val[0] is 'i' && _val[1] is 'f' && ( _val[2] is ' '  || _val[2] is '\t'  )  ) {
									_val	= val[3..$] ;
									while(_val.length && _val[0] is ' ') _val = _val[1..$];
									if( _val.length > 0 ) {
										return  NewTok(Tok.Type.ElseIf, cast(string) _val ) ;
									}
								}
							}
						} else if( val[0] is '/' ) {
							auto _val	= val[1..$] ;
							while(_val.length && _val[0] is ' ') _val = _val[1..$];
							while(_val.length && _val[$-1] is ' ') _val = _val[0..$-1];
							if( _val.length is 2 && _val[0] is 'i' && _val[1] is 'f' ) {
								return  NewTok(Tok.Type.IfEnd ) ;
							}
						}
						err("inline code error `%s`", val );
					}
					_ptr++ ;
					lcurly--;
					break;
				case '"':
				case '`':
					skip_inline_qstring(_ptr[0]) ;
					break;
				case '(':
					_ptr++ ;
					paren++;
					break;
				case ')':
					_ptr++ ;
					paren--;
					break;
				case '\r':
				case '\n':
					err("expected '}'");
					break;
				default:
					_ptr++ ;
			}
		}
		err("expected '}'");
		return null ;
	}
	

	Tok*  parseInlineString( char _stop_char = 0 ) {
		assert( _ptr <= _end) ;
		assert( _ptr[0] !is '\n' &&  _ptr[0] !is '\r' ) ;

		Tok*	_ret_tk ;
		
		auto _str_pos = _str_bu.length ;
		
		void push_tk(Tok* tk) {
			if( _ret_tk is null ) {
				_ret_tk	= tk ;
			}
		}
		
		void save_string() {
			if(  _str_bu.length > _str_pos ) {
				Tok* _tk	= NewTok(Tok.Type.String, cast(string) _str_bu.slice[ _str_pos ..$ ] );
				_str_pos	=  _str_bu.length ;
				push_tk(_tk);
			}
		}
		
		
		auto __ptr = _ptr ;
		
		bool _stop_zero	= false ;
		bool _stop_paren = false ;
		bool _stop_quote = false ;
		bool _stop_bracket	= false ;
		
		if( _stop_char == 0 ) {
			_stop_zero	= true ;
		} else if(_stop_char is ')' ){
			_stop_paren	= true ;
		} else if(_stop_char is '"' ){
			_stop_quote	= true ;
		} else if(_stop_char is ']' ){
			_stop_bracket	= true ;
		} else {
			err("lexer bug `%s`",  cast(ubyte) _stop_char);
		}

		size_t	paren_count = 0 ;
		
		void string_trim_right(){
			while( _str_bu.length >= _str_pos){
				auto _last_char	=  _str_bu.slice[$-1] ;
				if( _last_char is ' ' || _last_char is '\t' ){
					_str_bu.move(-1);
				} else {
					break;
				}
			}
		}
		
		bool check_stop(){
			if( _ptr > _end ) {
				return false ;
			}
			if( !_stop_zero ) {
				if( _stop_paren ) {
					if( _ptr[0] is ')' ) {
						if( paren_count is 0 ) {
							if( _ptr is _end ){
								err("not end attr");
							}
							string_trim_right();
							return true ;
						}
						paren_count-- ;
					} else if( _ptr[0] is ',' ) {
						if( paren_count is 0 ) {
							string_trim_right();
							return true ;
						}
					} else if( _ptr[0] is '(' ) {
						paren_count++ ;
					} 
				}  else if( _stop_quote ) {
					if( _ptr[0] is '"' ) {
						_ptr++;
						return true ;
					}
				} else if ( _stop_bracket ) {
					if( _ptr[0] is ']' ) {
						_ptr++;
						return true ;
					}
				} else {
					err("lexer bug");
				}
			}
			return false ;
		}
		
		ptrdiff_t len ;
		L1:
		while( (len = _end - _ptr) >= 0 ) {
			
			switch( _ptr[0] ) {
				case '\\' :
					if( len !is 0 ){
						if( _ptr[1] is '\r' || _ptr[1] is '\n' ) {
							// skip \
							_ptr++ ;
							skip_newline;
							size_t _tabs = _last_indent_size ;
							parseIndent();
							if( _last_indent_size < _tabs ){
								err("expected indent at least %d tabs", _tabs);
							}
							_last_indent_size	= _tabs ;
							assert(false);
							break;
						}
						
						if( len > 3 ) {
							if( _ptr[1] is '$' && _ptr[2] is '{' && _ptr[3] !is ' ' && _ptr[3] !is '\t' && _ptr[3] !is '\r' && _ptr[3] !is '\n' ) {
								_str_bu('$')('{');
								_ptr	+= 3;
								break;
							}
							
						} else {
							if( len > 2 && _ptr[1] is '$' && _ptr[2] is '{' ) {
								err("var error");
							}
						}

						if( len > 2 ) {
							if( _ptr[1] is '{' && _ptr[2] !is ' ' && _ptr[2] !is '\t'  && _ptr[2] !is '\r' && _ptr[2] !is '\n' ) {
								_str_bu('{')(_ptr[2]) ;
								_ptr	+= 3;
								break;
							}
						} else {
							if( len > 0 && _ptr[1] is '{' ){
								err("var error");
							}
						}
						
						// skip ('\\')
						if( _ptr < _end ) {
							if(  _ptr[1] is '(' || _ptr[1] is ')'  || _ptr[1] is '[' || _ptr[1] is ']'  || _ptr[1] is '"' || _ptr[1] is '\''  || _ptr[1] is '\\'  ) {
								_str_bu( _ptr[1] );
								_ptr	+= 2 ;
								break;
							}
						} 
						_ptr++;
						_str_bu('\\');
						break;
					}
					err("lexer bug `%s`", line);
					break;
				case '$':
					if( len > 1 && _ptr[1] is '{' && _ptr[2] !is ' ' && _ptr[2] !is '\t' && _ptr[2] !is '\r'  && _ptr[2] !is '\n' ) {
						// save old string
						save_string() ;
						// paser var name 
						_ptr += 2 ;
						Tok* _tk = parseInlineCode(Tok.Type.Var) ;
						assert(_tk !is null);
						 push_tk(_tk) ;
					} else {
						_ptr++;
						_str_bu('$');
					}
					break ;
				case '{':
					if( len > 0 && _ptr[1] !is ' ' && _ptr[1] !is '\t'  && _ptr[1] !is '\r'  && _ptr[1] !is '\n'  ) {
						// save old string
						save_string() ;
						_ptr += 1 ;
						Tok* _tk = parseInlineCode() ;
						assert(_tk !is null) ;
					} else {
						_ptr++;
						_str_bu('{');
					}
					break;
				case '\r':
				case '\n':
					break L1;
				default:
					if( check_stop ) {
						break L1 ;
					}
					_str_bu( _ptr[0] );
					_ptr++;
			}
		}
		skip_space;
		
		save_string() ;
		return _ret_tk ;
	}
	
	string parseLineString( bool trimr = true ){
		if( _ptr > _end ) {
			return null ;
		}
		int i	= 0 ;
		while( _end - i >= _ptr ) {
			if( _ptr[i] is '\n' || _ptr[i] is '\r' ) {
				break ;
			}
			i++ ;
		}
		if( i > 0 ) {
			auto val	= cast(string) _ptr[0..i] ;
			if( trimr ) {
				while( 
					val.length &&
					( val[$-1] is ' ' || val[$-1] is '\t' || val[$-1] is '\r'|| val[$-1] is '\n'  )
				) {
					val	= val[0..$-1];
				}
			}
			_ptr	+= i ;
			return  val ;
		}
		return null ;
	}
	
	void parseTextBlock(Tok* tk, bool _search_code = false) {
		if( _ptr > _end ) {
			err("expected text block");
		}
		if(_ptr[0] !is '\n' && _ptr[0] !is '\r' ){
			err("expected new line");
		}
		
		while( _ptr <= _end ) {
			auto __ptr	= _ptr ;
			skip_newline;
			parseIndent;
			
			if( _last_indent_size <= tk.tabs ) {
				ln-- ;
				_ptr	= __ptr ;
				break ;
			}
			auto _tabs	= _last_indent_size - tk.tabs -1 ;
			auto _str_pos	= _str_bu.length ;
			
			while( _tabs > 0 ) {
				_str_bu(' ')(' ');
				_tabs--;
			}
			_last_indent_size	= tk.tabs + 1 ;
			if( _str_pos != _str_bu.length ){
				NewTok(Tok.Type.String, cast(string) _str_bu.slice[_str_pos ..$] );
			}
			parseString(_search_code) ;
		}
	}
	
	Tok*  parseString(bool _search_code = true ) {
		if( _ptr > _end ) {
			return null ;
		}
		int i	= 0 ;
		while( _end - i >= _ptr ) {
			if( _ptr[i] is '\n' || _ptr[i] is '\r' ) {
				break ;
			}
			i++ ;
		}
		if( i > 0 ) {
			if( _search_code ) {
				return parseInlineString() ;
			} else {
				Tok* tk = NewTok(Tok.Type.String, cast(string) _ptr[0..i] ) ;
				_ptr	+= i ;
				return tk ;
			}
		}
		return null ;
	}
	
	Tok* parseDocType() {
		assert(_ptr[0] is '!' ) ;
		ptrdiff_t len = _end - _ptr ;
		if(  len < 3 || _ptr[1] !is '!' || _ptr[2] !is '!' ){
			err("expected doctype token");
		}
		_ptr	+= 3 ;
		skip_space() ;
		Tok* tk	= NewTok(Tok.Type.DocType, parseLineString) ;
		return tk ;
	}
	
	Tok* parseTagWithIdClass(bool without_content= false ) {
		if( _ptr > _end ) {
			err("expected tag");
		}
		if( _ptr[0] is '#' || _ptr[0] is '.'  ){
			return parseTag( `*`, without_content) ;
		}
		return parseTag( null, without_content) ;
	}

	Tok* parseTag(string tag = null, bool without_content= false ) {
		if( tag is null ) {
			skip_space ;
			tag	= skip_identifier ;
			if( tag is null ) {
				// skip empty line
				if( _ptr[0] is '\r' || _ptr[0] is '\n' ) {
					return null ;
				}
				err("expected tag but find `%s` ", _ptr[0], line ) ;
			}
		}
	
		Tok* _tk	= NewTok(Tok.Type.Tag, tag);
		
		while(true) {
			if( _ptr >= _end ) {
				return _tk;
			}
			if( _ptr[0] is ' ' || _ptr[0] is '\t' || _ptr[0] is '\n' || _ptr[0] is '\r' || _ptr[0] is ':' || _ptr[0] is '%'|| _ptr[0] is '(' ){
				break;
			}
			
			if( _ptr[0] is '#' ) {
				_ptr++ ;
				string value	= skip_identifier ;
				if( value is null ) {
					err("expected tag.id");
				}
				Tok* _tk_id		= NewTok(Tok.Type.Id, value) ;
				continue ;
			}
			
			if( _ptr[0] is '.' ) {
				_ptr++ ;
				string value	= skip_identifier ;
				if( value is null ) {
					err("expected tag.class");
				}
				Tok* _tk_class		= NewTok(Tok.Type.Class, value) ;
				continue ;
			}
			err("tag err `%s`", line);
		}
		
		bool is_embed_tag	= false ;
		if(  _ptr <= _end  && _ptr[0] is ':' ) {
			is_embed_tag	= true ;
			_ptr++;
		}
		skip_space ;
		// new line
		if( _ptr <= _end && (_ptr[0] is '\r' || _ptr[0] is '\n') ) {
			return _tk ;
		}
		
		skip_space ;
		if( _ptr <= _end && _ptr[0] is '(' ) {
			Tok* _tk_attrs	= parseAttrs() ;
			if( _ptr !is _end && _ptr[0] !is '\r' && _ptr[0] !is '\n' && _ptr[0] !is '\t' && _ptr[0] !is ' ' ) {
				err("missing space after attributes `%s`", line);
			}
			skip_space ;
		}
		
		if( is_embed_tag ) {
			if( !scan_skip_line ) {
				skip_space(true) ;
			}
			_offset_tabs++;
			auto _tag	= parseTagWithIdClass(without_content);
			assert(_tag !is null );
			_tag.bool_value	= true ;
			_offset_tabs-- ;
			return _tk ;
		}
		
		if( without_content ) {
			skip_space ;
			return _tk ;
		}
		
		// new line
		if( _ptr > _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
			return _tk ;
		}
		
		parseInlineString() ;
		
		return _tk ;
	}
	
	Tok* parseAttrs() {
		if( _ptr >=_end ) {
			err("expected attrs");
		}
		if( _ptr <= _end && _ptr[0] !is '(' ) {
			err("expected '(' ");
		}
		NewTok(Tok.Type.AttrStart) ;
		_ptr++;
		skip_space ;
		
		bool _last_value	= true ;

		bool scan_inline_code() {
			skip_space;
			if( _ptr < _end && _ptr[0] is '{' && _ptr[1] !is ' ' && _ptr[1] !is '\t'  && _ptr[1] !is '\r' && _ptr[1] !is '\n'   ) {
				_ptr++ ;
				parseInlineCode();
				skip_space;
				scan_skip_line ;
				return true ;
			}
			return false ;
		}
		
		bool scan_comma() {
			skip_space ;
			if(   _ptr <= _end  && _ptr[0] is ',' ) {
				// skip ,
				_ptr++ ;
				_last_value	= true ;
				skip_space ;
				scan_inline_code ;
				scan_skip_line ;
				return true ;
			}
			return false ;
		}
		
		bool scan_attrs_end() {
			skip_space ;
			if( _ptr >= _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
				dump_tok();
				err("expected AttrEnd `%s`", line );
			}
			
			scan_inline_code ;
			
			// attr end 
			if( _ptr <= _end  && _ptr[0] is ')' ) {
				//Log("`%s`", line );
				//assert(false) ;
				_ptr++ ;
				NewTok(Tok.Type.AttrEnd) ;
				return true ;
			}
			
			return false ;
		}
		
		while(  _end >= _ptr ) {
			
			if( scan_attrs_end ) {
				break ;
			}
			
			scan_inline_code ;
			
			// parse AttrKey
			assert(_last_value) ;
			auto key	= skip_identifier ;
			if( key is null ) {
				err("expected AttrKey `%s`", line);
			}
			NewTok(Tok.Type.AttrKey, key);
			
			if( scan_attrs_end ) {
				break ;
			}

			// attribute value 
			if( _ptr <= _end && _ptr[0] is '=' ) {
				_ptr++ ;
				skip_space ;
				if( _ptr >= _end ) {
					err("expected AttrValue") ;
				}
				
				auto __tk =  NewTok(Tok.Type.AttrValueStart) ;
				auto __ptr = _ptr ;
				parseInlineString( ')' ) ;
				// add unQuota
				for( auto _qtk = __tk.next; _qtk !is null; _qtk = _qtk.next ) {
					switch( _qtk.ty ) {
						case Tok.Type.Var:
							_qtk.bool_value = true ;
							break;
						case Tok.Type.String:
							_qtk.bool_value = true ;
							break;
						default:
							break ;
					}
				}
				
				Tok*	_tk_left,	_tk_right  = null ;
				string _val_left,  _val_right  = null ;
		
				for( auto _qtk = __tk.next; _qtk !is null; _qtk = _qtk.next ) {
					if ( _qtk.ty is Tok.Type.String ) {
						_tk_left	= _qtk ;
						_val_left = _qtk.string_value ;
						while( _val_left.length && (_val_left[0] is ' ' || _val_left[0] is '\t' ) ) _val_left = _val_left[1..$] ;
						break ;
					}
				}
				for( auto _qtk = _last_token ; _qtk !is __tk; _qtk = _qtk.pre ) {
					if ( _qtk.ty is Tok.Type.String ) {
						_tk_right	= _qtk ;
						_val_right = _qtk.string_value ;
						while( _val_right.length && (_val_right[$-1] is ' ' || _val_right[$-1] is '\t' ) ) _val_right = _val_right[0..$-1] ;
						break ;
					}
				}
				
				if( _val_left !is null && _val_right !is null  ){
					assert(_tk_left !is null);
					assert(_tk_right !is null);
					if( _val_left.length && _val_right.length ) {
						if( 
							_val_left[0] is '(' && _val_right[$-1] is ')' 
						)  {
							if( _tk_left is _tk_right ) {
								_val_left	= _val_left[1..$-1] ;
								while( _val_left.length && (_val_left[0] is ' ' || _val_left[0] is '\t' ) ) _val_left = _val_left[1..$] ;
								while( _val_left.length && (_val_left[$-1] is ' ' || _val_left[$-1] is '\t' ) ) _val_left = _val_left[0..$-1] ;
								_tk_left.string_value	= _val_left ;
							} else {
								_val_left	= _val_left[1..$] ;
								while( _val_left.length && (_val_left[0] is ' ' || _val_left[0] is '\t' ) ) _val_left = _val_left[1..$] ;
								_tk_left.string_value	= _val_left ;
								_val_right	= _val_right[0..$-1];
								while( _val_right.length && (_val_right[$-1] is ' ' || _val_right[$-1] is '\t' ) ) _val_right = _val_right[0..$-1] ;
								_tk_right.string_value	= _val_right;
							}
						} 
					}
				}					
				
				skip_space ;
				if( _ptr >= _end || _ptr[0] !is ',' && _ptr[0] !is ')' ) {
					err("expected AttrValue end `%s`", line) ;
				}
				NewTok(Tok.Type.AttrValueEnd) ;
			}
			
			if( scan_comma ) {
				continue ;
			}
			
			if( scan_attrs_end ) {
				break ;
			}
			
			err("expected AttrKey or AttrEnd `%s`", line ) ;
		}
		
		return null ;
	}
	
	Tok* parseComment(){
		assert(_ptr[0] is '/' );
		_ptr++;
		if( _ptr >= _end ) {
			err("expected Comment");
		}
		Tok* tk	= null ;
		if( _ptr[0] is '/' ) {
			// inline Common
			_ptr++;
			if( _ptr >= _end ) {
				err("expected Comment");
			}
			tk	= NewTok(Tok.Type.CommentStart);
			if( _ptr[0] is '-' ) {
				_ptr++;
				if( _ptr >= _end ) {
					err("expected Comment");
				}
				tk.bool_value	= true ;
			} else {
				tk.bool_value	= false ;
			}
			_offset_tabs++;
			parseString;
			_offset_tabs--;
			tk	= NewTok(Tok.Type.CommentEnd);
			return tk ;
		}
		
		tk	= NewTok(Tok.Type.CommentBlock);

		if( _ptr[0] is '-' ) {
			_ptr++;
			if( _ptr >= _end ) {
				err("expected Comment");
			}
			tk.bool_value	= true ;
		} else {
			tk.bool_value	= false ;
		}

		_offset_tabs++;
		parseString;
		_offset_tabs--;
		
		return tk ;
	}
	
	Tok* parseCode(){
		Tok* tk ;
		assert(_ptr[0] is '-' );
		_ptr++;
		if( _ptr >= _end ) {
			err("expected Code");
		}
		
		// native code
		if( _ptr[0] is '-' ) {
			_ptr++;
			if( _ptr >= _end ) {
				err("expected Code");
			}
			tk	= NewTok(Tok.Type.Code, parseLineString);
			return tk ;
		}
		if( _ptr[0] !is ' ' && _ptr[0] !is '\t' ) {
			err("expected space");
		}
		skip_space;
		if( _ptr >= _end ) {
			err("expected Code");
		}
		auto code_line	= line ;
		auto code_type	=  _ptr[ 0 .. safeFind!(const(char))(_ptr, &code_line[$-1], ' ') ];
		
		if( code_type == "if" ) {
			_ptr	+= 2 ;
			if( _ptr >= _end ) {
				err("expected Code");
			}
			skip_space ;
			if( _ptr >= _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
				err("expected Code");
			}
			tk	= NewTok(Tok.Type.IfCode, parseLineString);
			return tk ;
		} else if( code_type == "else" ) {
			_ptr	+= 4 ;
			if( _ptr >= _end ) {
				err("expected Code");
			}
			skip_space ;
			if( _ptr >= _end ) {
				err("expected Code");
			}
			if( _ptr[0] is '\r' || _ptr[0] is '\n' ) {
				tk	= NewTok(Tok.Type.ElseCode, parseLineString);
				return tk ;
			}
			auto code_type2	=  _ptr[ 0 .. safeFind!(const(char))(_ptr, &code_line[$-1], ' ') ];
			
			if( code_type2 == "if" ) {
				_ptr	+= 2 ;
				if( _ptr >= _end ) {
					err("expected Code");
				}
				skip_space ;
				if( _ptr >= _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
					err("expected Code");
				}
				tk	= NewTok(Tok.Type.IfCode, parseLineString);
				return tk ;
			}
			err("expected Code `%s`", code_type2);
			
		} else if( code_type == "each" ) {
			_ptr +=4 ;
			skip_space;
			auto _each_line	= line ;
			while( _each_line.length && ( _each_line[$-1] is ' ' || _each_line[$-1] is '\t' ) ) _each_line	= _each_line[0..$-1];
			
			auto _each_in		= find_with_space!"in"(_each_line);
			if( _each_in < 0 ) {
				err("expected each in");
			} else if( _each_in < 2 ){// "i in"
				err("expected each key");
			}  else if( _each_in > _each_line.length -4 ){ // i in o
				err("expected each object");
			}
			auto _each_comma	= countUntil(_each_line, ',' );
			
			if( _each_comma < 0 ) {
				// no key 
				auto _each_val	= skip_identifier ;
				if( _ptr >= _end ) {
					err("expected each in");
				}
				if( _ptr[0] !is '\t' && _ptr[0] !is ' ' ){
					err("expected space but `%s`", _ptr[0] ) ;
				}
				skip_space ;
				if( _ptr - _each_line.ptr != _each_in ){
					err("expected each in");
				}
				_ptr += 3 ;
				skip_space ;
				auto _each_obj	= parseLineString ;
				if( _each_obj is null ) {
					err("expected each obj");
				}
				if( _ptr > _end || _ptr[0] !is '\n' && _ptr[0] !is '\r' ) {
					err("expected new line");
				}
				
				tk	= NewTok(Tok.Type.Each_Object, _each_obj);
				NewTok(Tok.Type.Each_Value, _each_val);
				
				// Log("`%s` in `%s`", _each_val, _each_obj );
				
				return tk ;
			}
			
			if( _each_comma is 0 ) { // "i,j in o"
				err("expected each key");
			} else if( _each_comma >= _each_in - 2 ){ 
				err("each expression error `%s` _each_comma = %d", line, _each_comma);
			}
			
			auto _each_type	= skip_identifier ;
			if( _each_type is null ) {
				err("expected each key");
			}
			if( _ptr >= _end ) {
				err("expected each in");
			}
			if( _ptr >= _end ) {
				err("expected each in");
			}
			skip_space ;
			string _each_key ;
			if( _ptr[0] !is ',' ) {
				// find each_key
				_each_key	= skip_identifier ;
				if( _each_key is null ) {
					err("expected each key");
				}
				skip_space ;
			} else {
				//no _each_type	
				_each_key	= _each_type ;
				_each_type	= null ;
			}
			
			if( _ptr[0] !is ',' ) {
				err("expected each comma");
			}
			// skip ,
			_ptr++;
			skip_space ;
			
			// find _each_value_type
			string _each_value_type = null ;
	
			for(auto __ptr = _ptr;  __ptr <= _end && __ptr[0] !is '\r' && __ptr[0] !is '\n'; __ptr++){
				if( __ptr[0] is '\t' || __ptr[0] is ' ') {
					auto __ptr2 = __ptr ;
					while( __ptr2 <= _end && __ptr2[0] !is '\r' && __ptr2[0] !is '\n' ) {
						if( __ptr2[0] !is '\t' && __ptr2[0] !is ' ' ) {
							break;
						}
						__ptr2++;
					}
					if( __ptr2 - _each_line.ptr !is _each_in ) {
						_each_value_type	= cast(string) _ptr[ 0 .. __ptr - _ptr ] ;
						_ptr	= __ptr2 ;
					}
					break ;
				}
			}
			
			// find _each_value 
			string _each_value = skip_identifier ;
			if( _each_value is null ) {
				err("expected each value");
			}
			if( _ptr >= _end || _ptr[0] !is '\t' && _ptr[0] !is ' ' ) {
				err("expected each space");
			}
			skip_space ;
			if( _each_in != _ptr - _each_line.ptr ) {
				err("expected each in");
			}
			// skip "in "
			_ptr += 3 ;
			skip_space ;
			
			string _each_obj	= parseLineString ;
			if( _each_obj is null ) {
				err("expected each obj");
			}
			if( _ptr > _end || _ptr[0] !is '\n' && _ptr[0] !is '\r' ) {
				err("expected new line");
			}
			
			tk	= NewTok(Tok.Type.Each_Object, _each_obj);
			if( _each_type !is null ) {
				NewTok(Tok.Type.Each_Type, _each_type);
			}
			NewTok(Tok.Type.Each_Key, _each_key);
			if( _each_value_type !is null ) {
				NewTok(Tok.Type.Each_Type, _each_type);
			}
			
			NewTok(Tok.Type.Each_Value, _each_value);
			
			// Log("`%s` `%s` , `%s` in `%s`", _each_type, _each_key, _each_value, _each_obj);
			
			
		} else {
			err("expected Code `%s`", code_type);
		}
		
		return tk ;
	}
	
	Tok* parseFilter() {
		if( _ptr >= _end || _ptr[0] !is ':' ) {
			err("filter error");
		}
		_ptr++;
		
		bool _search_code	= false ;
		
		if( _ptr <= _end && _ptr[0] is ':' ) {
			_search_code	= true ;
			_ptr++ ;
		}
		
		auto filter_type	= skip_identifier();
		if( filter_type is null ) {
			err("expected filter type");
		}
		Tok* tk	= NewTok(Tok.Type.FilterType, filter_type ) ;
		
		scope(exit){
			tk.bool_value	= _search_code ;
			parseTextBlock(tk, _search_code);
		}
		
		// filter arg
		while( _ptr <= _end ) {
			if( _ptr[0] !is '!' ) {
				break ;
			}
			_ptr++ ;
			if( _ptr > _end || _ptr[0] is ' ' ||  _ptr[0] is '\t'  ||  _ptr[0] is '\r'  ||  _ptr[0] is '\n' ){
				err("expected filter tag");
			}
			if( _ptr[0] !is '"' ) {
				string filter_tag = skip_identifier() ;
				if( filter_tag is null ) {
					err("expected filter tag");
				}
				NewTok(Tok.Type.FilterArgStart) ;
				NewTok(Tok.Type.String, filter_tag) ;
				NewTok(Tok.Type.FilterArgEnd) ;
				continue ;
			}
			_ptr++ ;
			if( _ptr > _end || _ptr[0] is ' ' ||  _ptr[0] is '\t'  ||  _ptr[0] is '\r'  ||  _ptr[0] is '\n' ){
				err("expected filter tag");
			}
			NewTok(Tok.Type.FilterArgStart) ;
			parseInlineString('"');
			NewTok(Tok.Type.FilterArgEnd) ;
		}
		if ( _ptr > _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
			return tk ;
		}
		skip_space(true) ;
		if ( _ptr > _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
			return tk ;
		}
		
		if( _ptr[0] !is '[' ) {
			parseTagWithIdClass(true) ;
			if ( _ptr > _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
				return tk ;
			}
			if( !scan_skip_line ) {
				skip_space(true) ;
			}
			if ( _ptr > _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
				return tk ;
			}
		}
		
		// filter tag
		
		while( _ptr <= _end ) {
			if( _ptr[0] !is '[' ) {
				if ( _ptr > _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
					return tk ;
				}
				err("expected filter tag start but find `%s`", line );
			}
			_ptr++;
			if ( _ptr > _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
				err("expected filter tag key" );
			}
			skip_space;
			auto _tag_key	= skip_identifier();
			if ( _tag_key is null ) {
				err("expected filter tag key" );
			}
			// =============================================================================> start tag arg 
			NewTok(Tok.Type.FilterTagKey, _tag_key) ;
			
			// find =
			skip_space;
			if ( _ptr > _end || _ptr[0] !is '=' ) {
				err("expected filter tag key = " );
			}
			_ptr++;
			skip_space;
			
			// find value
			if ( _ptr > _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
				err("expected filter tag value" );
			}
			NewTok(Tok.Type.FilterTagValueStart) ;
			Tok* _tag_val	= parseInlineString(']');
			if( _tag_val is null ) {
				err("expected filter tag value" );
			}
			skip_space;
			
			NewTok(Tok.Type.FilterTagValueEnd) ;

			if( !scan_skip_line ) {
				skip_space() ;
			}
			
			if ( _ptr > _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
				break ;
			}
			
			// find filter tag
			if( _ptr[0] !is '[' ) {
				NewTok(Tok.Type.FilterTagArgStart) ;
				Tok* _tk	= parseTagWithIdClass(true);
				if( _tk is null ) {
					err("expected filter tag" );
				}
				NewTok(Tok.Type.FilterTagArgEnd) ;
				
				if( !scan_skip_line ) {
					skip_space() ;
				}
			}
			NewTok(Tok.Type.FilterTagKeyValueEnd);
			// =============================================================================> end tag arg 
		}
		return tk ;
	}
	
	static ptrdiff_t find_with_space(string obj)(string str){
		ptrdiff_t i  = 1 ;
		for(ptrdiff_t l = str.length - obj.length - 1 ; i < l; i++ ){
			static if(obj.length is 1) {
				if( 
					obj[0] is str[i] 
						&& 
					( str[i+1]  is ' ' || str[i+1]  is '\t' ) 
						&& 
					( str[i-1]  is ' ' || str[i-1]  is '\t' ) 
				){
					return i ;
				}
			} else static if(obj.length is 2) {
				if( 
					obj[0] is str[i] 
						&& 
					obj[1] is str[i+1] 
						&& 
					( str[i+2]  is ' ' || str[i+2]  is '\t' ) 
						&& 
					( str[i-1]  is ' ' || str[i-1]  is '\t' ) 
				){
					return i ;
				}	
			} else {
				static assert(false);
			}
		}
		return -1 ;
	}
	
	static size_t safeFind(T)(T* _from , T* _to, T obj){
		T* _p = _from ;
		while( _p <= _to ) {
			if( _p[0] is obj ) {
				break ;
			}
			_p++;
		}
		return _p - _from ;
	}
	private alias safeFind!(const(char)) find ;
}

