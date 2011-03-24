module oak.langs.gold.Base ;

public import 
	oak.langs.gold.Lang , 
	oak.util.Stack ,
	oak.util.Pool , 
	oak.util.Buffer , 
	oak.util.Log , 
	oak.util.Ctfe ;


enum SymbolType { 
	NonTerminal	= 0 ,
	Terminal	= 1 ,
	Whitespace	= 2 ,
	EOF	= 3 ,
	CommentStart	= 4 ,
	CommentEnd	= 5 ,
	CommentLine	= 6 ,
	Error	= 7 ,
}

enum DFAActionType { 
	Shift	= 1 ,
	Reduce	= 2 ,
	Goto	= 3 ,
	Accept	= 4 ,
}

struct Symbol {
	const ptrdiff_t	id ;
	const SymbolType	type ;
	const string		name ;
}

struct CharSet {
	const ptrdiff_t	id ;
	const dchar[]		set ;
}

struct SymbolRule {
	const ptrdiff_t	id ;
	const ptrdiff_t	sym_id ;
	const ptrdiff_t[]	symbols;
}

struct DFAEdge {
	const ptrdiff_t	charset_id ;
	const ptrdiff_t	dfa_id ;
}

struct DFAState {
	const ptrdiff_t	id ;
	const ptrdiff_t	sym_id ;
	const bool		accept ;
	const DFAEdge[]	edges ;
}


struct LALRAction {
	const ptrdiff_t	id ;
	const DFAActionType	ty ;
	const ptrdiff_t	sym_id;
	const ptrdiff_t	target ;
}

struct LALRState {
	const ptrdiff_t	id ;
	const LALRAction[]	actions ;
}

enum TokingRet {
	Shift ,
	Reduce ,
	ReduceTrimmed ,
	Accept ,
	SyntaxError ,
	InternalError ,
}

enum ParsingRet {
	TokenRead , 
	Reduction , 
	Accept ,
	NotLoadedError ,
	LexicalError ,
	SyntaxError ,
	RunawayCommentError ,
	UnmatchedCommentError ,
	InternalError ,
}