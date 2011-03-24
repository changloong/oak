	static struct Symbol {
		const ptrdiff_t	id ;
		const SymbolType	type ;
		const string		name ;
	}
	
	static struct CharSet {
		const ptrdiff_t	id ;
		const dchar[]		set ;
	}
	
	static struct Rule {
		const ptrdiff_t	id ;
		const ptrdiff_t	sym_id ;
		const ptrdiff_t[]	symbols;
	}
	
	static struct DFAEdge {
		const ptrdiff_t	charset_id ;
		const ptrdiff_t	dfa_id ;
	}
	
	static struct DFAState {
		const ptrdiff_t	id ;
		const ptrdiff_t	sym_id ;
		const bool		accept ;
		const DFAEdge[]	edges ;
	}
	
	
	static struct LALRAction {
		const ptrdiff_t	id ;
		const ActionType	ty ;
		const ptrdiff_t	sym_id;
		const ptrdiff_t	target ;
	}
	
	static struct LALRState {
		const ptrdiff_t	id ;
		const LALRAction[]	actions ;
	}