//: \$dmd2p -L+goldie \+..\..\util\


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
		bu( T.stringof)("\t")(name)("\t=")(" ") (value)("; \n") ;
	} else static if( isSomeString!(T) ) {
		bu( T.stringof)("\t")(name)("\t=")(" `") (value)("` ; \n") ;
	} else {
		static assert(false);
	}
}


void main(){
	bu	= new vBuffer(1024 * 16 , 1024 * 16);
	auto cgtFile	= `../scss/scss.cgt` ;
	auto lang = Language.loadCGT(cgtFile);
	scope(exit){
		writefln("%s", cast(string) bu.slice);
	}
	
	asVar("Name", lang.name ) ;
	asVar("Version", lang.ver ) ;
	asVar("Author", lang.author ) ;
	asVar("About", lang.about ) ;
	
	bu("\n");
	
	asVar("StartSymbolID", lang.startSymbolIndex ) ;
	asVar("EofSymbolID", lang.eofSymbolIndex ) ;
	asVar("ErrorSymbolID", lang.errorSymbolIndex ) ;
	
	// symbolTable
	bu(Tab)("Symbol[")( lang.symbolTable.length )("] SymbolTable = [ \n");
	iTab++;
	foreach(int i, Symbol sym; lang.symbolTable) {
		bu
			(Tab)(" { ") (i) (", ") ( cast(ptrdiff_t) sym.type)(", \"").unQuote(sym.name)("\" }, ")
			(" //  ") ( symbolTypeToString(sym.type) ) (" ") ("\n")
		;
	}
	iTab--;
	bu(Tab)("]; \n");
	
	// CharSetTable
	bu(Tab)("CharSet[")( lang.charSetTable.length )("] CharSetTable = [ \n");
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