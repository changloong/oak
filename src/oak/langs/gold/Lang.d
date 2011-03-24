module oak.langs.gold.Lang ;

import std.conv ;


template Gold_Lang(This) {
	
	static struct Tok {
		ptrdiff_t	symbol_id ;
		ptrdiff_t	lalr_id ;
		ptrdiff_t	rule_id ;
		ptrdiff_t	ln ;
		dchar[]	data ;
		
		Tok*[Max_Rule_Len]
				sub ;
		
		string symbol(){
			if( symbol_id >=0 && symbol_id < SymbolTable.length ) {
				return SymbolTable[ symbol_id] .name ;
			}
			return null ;
		}
	}
	
	private {
		Pool*		pool ;
		ptrdiff_t	comment_level ;
		
		Stack!(Tok*, 0, 512)	
				lalr_tok_stack ,
				input_stack ;
		
		dchar*		_start, _end, _ptr ;
		ptrdiff_t	_cur_lalr_id ;
	}
	
	private Tok* NewTok(ptrdiff_t sym_id = -1 , ptrdiff_t lalr_id = -1 ){
		Tok* tk	=  pool.New!(Tok) ;
		
		tk.symbol_id	= sym_id  ;
		tk.lalr_id	= lalr_id  ;
		
		return tk ;
	}
	
	dchar[] input(){
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
		
		Clear();
		_start	= cast(dchar*) pool.alloc( dchar.sizeof * _input.length ) ;
		_end	= _start + _input.length ;
		_ptr	= _start ;
		foreach( int i, dchar c ; _input){
			_ptr[i]	= c ;
		}
		
		auto tk = NewTok(StartSymbolID, InitLALRID) ;
		lalr_tok_stack.push( tk ) ;
	}
	
	
	void Clear() {
		pool.Clear ;
		comment_level	= 0 ;
		lalr_tok_stack.clear ;
		input_stack.clear ;
		
		_cur_lalr_id	= InitLALRID ;
	}
	
	Tok* RetrieveToken () {
		Tok* tk	= null ;
		if( _ptr > _end ) {
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
				throw new Exception("err");
			}
			
			if( state.accept ) {
				accept_state	= state ;
				accept_len	= len ;
			}
			
			auto _edge = dfa_find_edge(state, _ptr[len]) ;
			
			if( _edge !is null ) {
				state	= cast(DFAState*) &DFATable[ _edge.dfa_id ] ;
				len++ ;
			} else {
				if( accept_state !is null ) {
					tk = NewTok( accept_state.sym_id,  accept_state.id ) ;
					tk.data	= _ptr[ 0 .. len + 1 ] ; 
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
		static LALRAction* find_act(ptrdiff_t lalr_id, Tok* tk) {
			for( ptrdiff_t i = 0; i < LALRTable[lalr_id].actions.length; i++ ) {
				LALRAction* act = cast(LALRAction*) &LALRTable[lalr_id].actions[i] ;
				if( act.sym_id is tk.symbol_id ) {
					return act ;
				}
			}
			return null ;
		}
		
		LALRAction* act = find_act(_cur_lalr_id, tk) ;
		if( act is null ) {
			return TokingRet.SyntaxError ;
		}
		
		Tok*[Max_Rule_Len] Tok_Pool ;
		
		TokingRet ret ;
		switch( act.ty ) {
			case LALRActionType.Accept:
				ret	= TokingRet.Accept ;
				break;
			
			case LALRActionType.Shift:
				tk.lalr_id	= _cur_lalr_id ;
				lalr_tok_stack.push(tk);
				_cur_lalr_id	= act.target ;
				ret	= TokingRet.Shift ;
				break;
			
			case LALRActionType.Reduce:
				auto rule = &RuleTable[ act.target] ;
				int  sym_len = rule.symbols.length  ;
				if( input_stack.length < sym_len ) {
					assert(false);
				}
				
				Tok* reduced_tk = NewTok( rule.sym_id ) ;
				reduced_tk.rule_id = act.target ;
				
				for( int i = sym_len; i--; ) {
					reduced_tk.sub[i] = input_stack.pop ;
				}
				
				input_stack.push( reduced_tk ) ;
				
				foreach(int i, __tk ; reduced_tk.sub[0..sym_len] ){
					if( __tk.symbol_id !is rule.symbols[i] ) {
						assert(false);
					}
				}
				auto _act = find_act(_cur_lalr_id, tk);
				if( _act is null ) {
					assert(false, "Couldn't find appropriate goto after reduction.") ;
				}
				
				if( _act.ty !is LALRActionType.Goto) {
					assert(false, "After reduction, found action type #%s instead of goto.") ;
				}
				_cur_lalr_id = act.target ;
				break;
			
			default:
				assert(false);
		}
		
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