//: \$dmd2p -L+goldie \+..\..\..\util\


module oak.langs.gold.genx ;

import std.path;
import std.stdio;
import std.string;
import std.traits;
import std.conv;

import semitwist.util.all;

import goldie.all;
import goldie.util;
import oak.util.Buffer;
import oak.util.Log;
import oak.util.Ctfe;

vBuffer bu ;
ptrdiff_t iTab	= 1 ;
string[] _symbols ;
string[] _symbols_origin ;

static string[] sym_type = [	
		"NonTerminal",
		"Terminal",
		"Whitespace", 
		"EOF",      
		"CommentStart",
		"CommentEnd",  
		"CommentLine", 
		"Error", ];
		
static string[] actions = [
		null , 
		"Shift",
		"Reduce",
		"Goto", 
		"Accept",  ];

string Tab(){
	static string[] _tabs ;
	if( _tabs.length <= iTab ) {
		_tabs.length = iTab ;
	}
	if( iTab is 0 ) {
		return "" ;
	}
	int _i = iTab -1 ;
	assert(_tabs.length);
	if( _tabs[_i] is null ) {
		_tabs[_i]	= "" ;
		for(int i =0 ; i < iTab;i++){
			_tabs[_i]	~= "\t" ;
		}
	}
	return _tabs[_i] ;
}

void asVar(T)(string name, T value){
	bu( Tab ) ;
	static if( isIntegral!(T)  ) {
		bu("static const ")( T.stringof)("\t")(name)("\t=")(" ") (value)("; \n") ;
	} else static if( isSomeString!(T) ) {
		bu("static const ")( T.stringof)("\t")(name)("\t=")(" `") (value)("` ; \n") ;
	} else {
		static assert(false);
	}
}


void main(){
	bu	= new vBuffer(1024 * 16 , 1024 * 16);
	auto file	= `../../scss/css.cgt` ;
	auto lang 	= Language.loadCGT(file);
	auto _file_name = getName(basename(file));
	
	
	scope(exit){
		auto out_file	= "../" ~ _file_name ~ ".d" ;
		writefln("%s", cast(string) bu.slice);
		std.file.write( out_file, bu.slice);
	}
	
	bu("module oak.langs.gold.")(_file_name)(" ;\n");
	
	bu("public import oak.langs.gold.Base ;\n\n");
	bu("private {\n");
	

	bu("\n");
	
	load_symbol(lang);
	
	load_rule(lang);
	load_charset(lang);
	load_dfa(lang);
	load_lalr(lang);

	bu("}\n");
	bu("struct Lang_")( _file_name)(" {\n\n") ;
	
	asVar("Name", lang.name ) ;
	asVar("Version", lang.ver ) ;
	asVar("Author", lang.author ) ;
	asVar("About", lang.about ) ;
	
	bu("\n");
	
	asVar("StartSymbolID", lang.startSymbolIndex ) ;
	asVar("EofSymbolID", lang.eofSymbolIndex ) ;
	asVar("ErrorSymbolID", lang.errorSymbolIndex ) ;
	
	asVar("InitDfaID", lang.initialDFAState ) ;
	asVar("InitLALRID", lang.initialLALRState ) ;
	
	bu("\n");
	bu(Tab)("mixin Gold_Lang_Engine!(typeof(this)) ;\n");
	bu("}\n");
	
}

void gen_enum(string name, string[] list){
	bu(Tab)("enum ")(name)(" { \n");
	iTab++;
	foreach( int i , _ty; list) {
		if( _ty !is null )
		bu(Tab)( _ty)("	= ")( i )(" ,\n");
	}
	iTab--;
	bu(Tab)("}\n");
}

string get_symbol_name(T)(T name) if( isSomeString!(T) ) {
	_symbols_origin	~= name.idup ;
	string _name ;
	if( name.length > 2 && name[0] is '<' && name[$-1] is '>' ) {
		name	= "_"~ name[1..$-1] ~ "_";
	}
	foreach(int i, dchar d; name){
		if( d >= 'a' && d <='z' || d >= 'A' && d <='Z' || d >= '0' && d <='9' ) {
			_name	~= d ;
			continue ;
		}
		if( d >= byte.max ) {
			_name	~= to!string( to!( int) (d) ) ; 
			continue ;
		}
		switch( d) {
			case '$':
				_name	~= "_Dollar_";
				break;
			
			case '%':
				_name	~= "_Percent_";
				break;
			case '{':
				_name	~= "_lCurly_";
				break;
			case '}':
				_name	~= "_rCurly_";
				break;
			case '(':
				_name	~= "_lParen_";
				break;
			case ')':
				_name	~= "_rParen_";
				break;
			case '*':
				_name	~= "_Star_";
				break;
			case '+':
				_name	~= "_Plus_";
				break;
			case '-':
				_name	~= "_Min_";
				break;
			case '/':
				_name	~= "_Div_";
				break;
			case '_':
				_name	~= "_";
				break;
			case ' ':
				_name	~= "_Space_";
				break;
			case '!':
				_name	~= "_ExPoint_";
				break;
			case ',':
				_name	~= "_Comma_";
				break;
			case ':':
				_name	~= "_Colon_";
				break;
			case ';':
				_name	~= "_Semicolon_";
				break;
			case '@':
				_name	~= "_AT_";
				break;
			
			default:
				assert(false, to!string(d) );
		}
	}
	
	assert( _name.length > 0 );
	if( _name[0] >= '0' &&  _name[0] <= '9' ) {
		 _name	= "_" ~  _name ;
	}
	
	if( _name[0] !is '_' ) {
		_name	= "_" ~ _name ;
	}
	
	string _name_new = _name ;
	
	int _name_offset = 0 ;
	while(true){
		int _old_i	 = -1 ;
		foreach(int i, _old_name; _symbols ) {
			if( _old_name == _name_new ) {
				_old_i	= i ;
				break;
			}
		}
		if( _old_i is -1 ) {
			break;
		}
		_name_new	= _name ~"_" ~to!string(_name_offset);
		_name_offset++;
	}
	_symbols ~= _name_new ;
	return _name_new ;
}



void load_symbol(Language lang){
	
	foreach(int i, Symbol sym; lang.symbolTable) {
		get_symbol_name(sym.name) ;
	}
	
	/*
	// symbol enum
	bu(Tab)("enum SymbolID : ptrdiff_t ")("{\n");
	iTab++;
		foreach(int i, Symbol sym; lang.symbolTable) {
			auto _name	= _symbols[i] ;
			bu(Tab)(_name)(", 	//")
				("")(i)("	")( _symbols_origin[i] )("	")( symbolTypeToString(sym.type)  )
			("\n")
			;
		}
	iTab--;
	bu(Tab)("}\n");
	*/
	
	// symbolTable
	bu(Tab)("static const Symbol[")( lang.symbolTable.length )("] SymbolTable = [ \n");
	iTab++;
	foreach(int i, Symbol sym; lang.symbolTable) {
		auto name	= _symbols[i] ;
		
		bu
			(Tab)(" { ") (i) (", SymbolType.") ( sym_type[sym.type])(", \"").unQuote(sym.name)("\" }, ")
			// (" //  ") ( symbolTypeToString(sym.type) ) (" \t =  ") ( name ) 
			("\n")
		;
	}
	iTab--;
	bu(Tab)("]; \n");
}


void load_charset(Language lang){
	// CharSetTable
	bu(Tab)("static const CharSet[")( lang.charSetTable.length )("] CharSetTable = [ \n");
	iTab++;
	foreach(int i, tab ; lang.charSetTable) {
		auto _strin_char = to!string(tab.chars) ;
		bu
			(Tab)(  "// " ) .unstrip(_strin_char) 
		;
		bu
			("\n") (Tab)(" { ") (i) (", [")
		;
		foreach(dchar _dchar; tab.chars ) {
			bu( cast(int) _dchar )(", ");	
		}
		bu("] }, \n");
	}
	iTab--;
	bu(Tab)("]; \n");
}



void load_dfa(Language lang){
	// DfaTable
	bu(Tab)("static const DFAState[")( lang.dfaTable.length )("] DFATable = [ \n");
	iTab++;
	foreach(int i, dfa ; lang.dfaTable) {
		bu
			(Tab)(" { ") (i) (", ")(dfa.acceptSymbolIndex)(", ")(dfa.accept)(", [")
		;
		foreach(int iEdge, edge; dfa.edges){
			bu("{")(edge.charSetIndex)(", ") (edge.targetDFAStateIndex)("}, ");
		}
		bu("] }, \n");
	}
	iTab--;
	bu(Tab)("]; \n");
}


void load_rule(Language lang) {
	// RuleTable
	bu(Tab)("static const SymbolRule[")( lang.ruleTable.length )("] RuleTable = [ \n");
	iTab++;
	ptrdiff_t max_len = 0 ;
	foreach(int i, rule ; lang.ruleTable) {
		
		bu(Tab)("// ")( _symbols_origin[rule.symbolIndex] )("\t  ::= ");
		
		if( rule.subSymbolIndicies.length > max_len ) {
			max_len	= rule.subSymbolIndicies.length ;
		}
		foreach(int j, it ;rule.subSymbolIndicies){
			bu( _symbols_origin[it])( " " )
			;
		}
		bu(" \n");
		
		bu
			(Tab)(" { ") (i) (", ")(rule.symbolIndex)(", [")
		;
		
		foreach(int j, it ;rule.subSymbolIndicies){
			bu(it)
			(",")
			;
		}
		bu("] }, \n");
		
		
	}
	iTab--;
	bu(Tab)("]; \n");
	bu(Tab)("static const Max_Rule_Len = ")(max_len)(" ; \n");
	
}


void load_lalr(Language lang) {
	// LaLrTable
	bu(Tab)("static const LALRState[")( lang.lalrTable.length )("] LALRTable = [ \n");
	iTab++;
	foreach(int i, state ; lang.lalrTable) {
		
		bu
			(Tab)(" { ") (i) (", [")
		;
		foreach(int iAct, LALRAction action; state.actions) {
			bu("{")(iAct)(", LALRActionType.")( actions[action.type])(",")( action.symbolId)(",")(action.target)("}, ");
		}
		
		bu("] },")
		(" \n");
	}
	iTab--;
	bu(Tab)("]; \n");
}