	static struct Symbol {
		const ptrdiff_t	id ;
		const SymbolType	type ;
		const string		name ;
	}
	
	static struct CharSet {
		const ptrdiff_t	id ;
		const dchar[]		set ;
	}
	
	static struct DfaEdge {
		const ptrdiff_t	charset_id ;
		const ptrdiff_t	dfa_id ;
	}
	
	static struct DfaNode {
		const ptrdiff_t	id ;
		const ptrdiff_t	sym_id ;
		const bool		accept ;
		const DfaEdge[]	edges ;
	}
	
	static struct RuleNode {
		const ptrdiff_t	id ;
		const ptrdiff_t[]	symbols;
	}
	
	static struct Action {
		const ptrdiff_t	id ;
		const ActionType	ty ;
		const ptrdiff_t	sym_id;
		const ptrdiff_t	target ;
	}
	
	static struct LaLrNode {
		const ptrdiff_t	id ;
		const Action[]		actions ;
	}