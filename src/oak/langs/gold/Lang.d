module oak.langs.gold.Lang ;

import std.conv ;

alias wchar GCHAR ;


template Gold_Lang_Engine(This) {
	
	static struct Tok {
		ptrdiff_t	symbol_id ;
		ptrdiff_t	lalr_state_id ;
		ptrdiff_t	rule_id ;
		ptrdiff_t	ln ;
		GCHAR[]		data ;
		
		
		Tok*[Max_Rule_Len]
				sub ;
		
		string symbol(){
			if( symbol_id >=0 && symbol_id < SymbolTable.length ) {
				return SymbolTable[ symbol_id] .name ;
			}
			return null ;
		}
		
		bool isTerminal(){
			return  SymbolTable[ symbol_id].type is SymbolType.Terminal ;
		}
		
		SymbolType type(){
			return SymbolTable[ symbol_id].type ;
		}
		
		string sType(){
			return SymbolTypes[ SymbolTable[ symbol_id].type ] ;
		}
	}
	
	private {
		Pool*		pool ;
		ptrdiff_t	comment_level ;
		
		Stack!(Tok*, 0, 64)	
				lalr_stack ,
				input_stack ;
		
		GCHAR*		_start, _end, _ptr ;
		ptrdiff_t	_cur_lalr_id ;
		
		Tok* delegate() GetToken ;
		
		bool		trim_reductions ;
	}
	
	private Tok* NewTok(ptrdiff_t symbol_id = -1 , ptrdiff_t lalr_state_id = -1 ){
		Tok* tk	=  pool.New!(Tok) ;
		
		tk.symbol_id		= symbol_id  ;
		tk.lalr_state_id	= lalr_state_id  ;
		
		return tk ;
	}
	
	GCHAR[] input(){
		if( _start is null || _end is null || _start >= _end ) {
			return null ;
		}
		return _start[ 0 .. _end - _start] ;
	}
	
	void Init(string _input ) {
		if( pool is null ) {
			pool	= new Pool ;
			pool.Init(1024 * 1024 * 4 ) ;
		}
		
		GetToken	= &RetrieveToken ;
		
		Clear();
		_start	= cast(GCHAR*) pool.alloc( GCHAR.sizeof * _input.length ) ;
		_end	= _start ;
		_ptr	= _start ;
		foreach( int i, GCHAR c ; _input){
			_end[0] = c ;
			_end++;
		}
		
		auto tk = NewTok(StartSymbolID, InitLALRID) ;
		lalr_stack.push( tk ) ;
	}
	
	
	void Clear() {
		pool.Clear ;
		comment_level	= 0 ;
		lalr_stack.clear ;
		input_stack.clear ;
		
		_cur_lalr_id	= InitLALRID ;
	}
	
	Tok* RetrieveToken () {
		Tok* tk	= null ;
		if( _ptr >= _end ) {
			tk = NewTok( EofSymbolID ) ;
			return tk ;
		}
		bool isDone	= false ;
		ptrdiff_t len	= 0 ;
		DFAState* state	= cast(DFAState*) &DFATable[InitDfaID] ;
		
		DFAState*	accept_state ;
		ptrdiff_t	accept_len ;
		
		static const(DFAEdge*) dfa_find_edge(DFAState* state, dchar c){
			for(int i =0 ; i < state.edges.length;i++) {
				CharSet* set = cast(CharSet*) &CharSetTable[state.edges[i].charset_id ] ;
				foreach( _c; set.set ){
					if( _c is c ) {
						return &state.edges[i] ;
					}
				}
				
			}
			return null ;
		}

		while( !isDone ) {
			
			bool eof = _ptr + len > _end  ;
			
			if( eof ) {
				throw new Exception("eof err");
			}
			
			if( state.accept ) {
				accept_state	= state ;
				accept_len	= len ;
			}
			
			auto _edge = dfa_find_edge(state, _ptr[len]) ;
			
			if( _edge !is null ) {
				state	= cast(DFAState*) &DFATable[ _edge.target_dfa_state_id ] ;
				len++ ;
			} else {
				if( accept_state !is null ) {
					tk = NewTok( accept_state.accept_symbol_id,  accept_state.id ) ;
					tk.data	= _ptr[ 0 .. len   ] ; 
					_ptr	+= len ;
					// Log("%d, len = %d   `%s` = `%s`", accept_len, len, tk.symbol,  tk.data );
				} else {
					tk = NewTok( ErrorSymbolID ) ;
					tk.data	= _ptr[ 0 .. 1 ] ; 
				}
				isDone	= true ;
			}
			
		}
		
		return tk ;
	}
	
	TokingRet ParseToken(Tok* tk) {
		static const(LALRAction*) find_act(ptrdiff_t lalr_id, Tok* tk) {
			for( ptrdiff_t i = 0; i < LALRTable[lalr_id].actions.length; i++ ) {
				auto act =  &LALRTable[lalr_id].actions[i] ;
				if( act.symbol_id is tk.symbol_id ) {
					return act ;
				}
			}
			return null ;
		}
		
		auto act = find_act(_cur_lalr_id, tk) ;
		if( act is null ) {
			Log("Error: _cur_lalr_id = %d , tok = %s: `%s` ", _cur_lalr_id, tk.symbol, tk.data);
			return TokingRet.SyntaxError ;
		}
		// Log(">>> Next Action: %s", LALRActionTypes[act.ty] );
		
		TokingRet ret ;
		switch( act.ty ) {
			case LALRActionType.Accept:
				ret	= TokingRet.Accept ;
				break;
			
			case LALRActionType.Shift:
				// Log(" lalr_state %d => %d", _cur_lalr_id, act.target ) ;
				tk.lalr_state_id	=  act.target ;
				lalr_stack.push(tk);
				_cur_lalr_id	= act.target ;
				ret	= TokingRet.Shift ;
				break;
			
			case LALRActionType.Reduce:
				auto rule = &RuleTable[ act.target] ;
				int  sym_len = rule.symbols.length  ;
				
				Tok* head ;
			
				if( trim_reductions /* rule has one Terminal */ ) {
					
					head	= lalr_stack.pop ;
					assert( head.symbol_id is rule.symbol_id );
					ret = TokingRet.ReduceTrimmed ;
					
				} else {
					// Part 1.a: Pop the handle off the Token Stack and create a reduction.
					
					if( lalr_stack.length < sym_len ) {
						Log(" %d = %d reduce_rule = %d ",lalr_stack.length,  sym_len, rule.id );
						assert(false);
					}
					
					Tok* reduced_tk = NewTok( rule.symbol_id ) ;
					reduced_tk.rule_id = rule.id ;
					
					for( int i = sym_len; i--; ) {
						reduced_tk.sub[i] = lalr_stack.pop ;
					}
					
					for( int i = sym_len; i--; ) {
						if( reduced_tk.sub[i].symbol_id !is rule.symbols[i] ) {
							Log("Error: rule = %s, reduced_tk = `%s`:`%s`", rule.description , reduced_tk.symbol, reduced_tk.data);
							assert(false);
						}
					}
					
					
					// Part 2.b: Create a new token that will contain the nonterminal representing the reduced rule.
					head	= reduced_tk ; 
					ret	= TokingRet.Reduce ;
					
				}
				
				// GO TO THE NEXT STATE
				
				//Set Lookup-State = State property of the token on the top of the LALR-Token-Stack.
				auto _lookup_state = lalr_stack.top.lalr_state_id ;
				
				// Set Current-LALR-State = State specified by the goto for Head in Lookup-State.
				auto _act = find_act(_lookup_state, head);
				if( _act is null ) {
					assert(false, "Couldn't find appropriate goto after reduction.") ;
				}
				
				if( _act.ty !is LALRActionType.Goto) {
					Log(">>>* Next Action: %s", LALRActionTypes[_act.ty] );
					assert(false, "After reduction, found action type #%s instead of goto.") ;
				}
				_cur_lalr_id = _act.target ;
				
				// PART 3: PUSH THE NEW NONTERMINAL TOKEN
				head.lalr_state_id	= _cur_lalr_id ;
				lalr_stack.push(head);

				break;
			
			default:
				assert(false);
		}
		
		return ret ;
	}
	
	ParsingRet Parse() {
		
		ParsingRet ret ;
		bool isDone = false ;
		size_t count_i = 0;
		Tok* tk ;
		
		while( !isDone ) {
			if( input_stack.empty ) {
				tk	= GetToken() ;
				input_stack.push(tk) ;
				if( comment_level is 0 && tk.isTerminal ) {				
					ret	= ParsingRet.TokenRead ;
					isDone	= true ;
				} 
				
				// Log("`%s` = `%s` ", tk.symbol, tk.data);

			} else if( comment_level > 0) {
				tk	= input_stack.pop ;
				switch( tk.type ) {
					case SymbolType.CommentStart :
							comment_level++ ;
						break ;
					case SymbolType.CommentEnd :
							comment_level-- ;
						break ;
					case SymbolType.EOF :
							ret	= ParsingRet.MessageCommentError ;
							isDone	= true ;
						break ;
					default:
						break ;
				}
			} else {
				tk	= input_stack.top ;
				
				switch( tk.type ) {
					case SymbolType.Whitespace :
							// Discard the token from the front of the Input-Stack.
							input_stack.pop();
						break ;
					case SymbolType.CommentStart :
							comment_level = 1 ;
							// Discard the token from the front of the Token-Queue.
							input_stack.pop();
						break ;
					case SymbolType.CommentLine :
							// Discard the token from the front of the Input-Stack.
							auto _tk2	= input_stack.pop();
							// Discard the rest of the current line in Source.
							for(auto __ptr = _ptr ; _ptr <= _end; _ptr++ ) {
								if( _ptr[0] is '\r' ) {
									if( _ptr < _end && _ptr[1] is '\n' ) {
										_ptr++;
									}
									_ptr++;
									break;
								}
								if( _ptr[0] is '\n' ) {
									_ptr++;
									break;
								}
							}
						break ;
					case SymbolType.Error :
							ret	= ParsingRet.MessageLexicalError;
							isDone	= true ;
						break ;
					default:
						auto _parse_ret = ParseToken( tk ) ;
						// Log("ParseToken return = %s ", enum_name(_parse_ret) );
						switch(_parse_ret) {
							case TokingRet.Accept :
									ret	= ParsingRet.Accept;
									isDone	= true ;
								break;
							case TokingRet.InternalError :
									ret	= ParsingRet.InternalError ;
									isDone	= true ;
								break;
							
							case TokingRet.Reduce :
									ret	= ParsingRet.Reduction ;
									isDone	= true ;
								break;
							
							case TokingRet.Shift :
									// Discard the token from the front of the Input-Stack.
									input_stack.pop();
								break;
							
							case TokingRet.SyntaxError :
									ret	= ParsingRet.MessageSyntaxError ;
									isDone	= true ;
								break;
							default:
								// Do nothing. This includes Shift and Trim-Reduced.
								;
						}
				}
			}
		}
		
		assert(count_i++ < int.max) ;
		return ret ;
	}
	
	
	static int id(string val){
		foreach(ref sym ;SymbolTable){
			if( sym.name == val ) {
				return sym.id ;
			}
		}
		return -1 ;
	}
	
}