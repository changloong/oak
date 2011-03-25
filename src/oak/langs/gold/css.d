module oak.langs.gold.css ;
public import oak.langs.gold.Base ;

private {

	static const Symbol[14] SymbolTable = [ 
		 { 0, SymbolType.EOF, "EOF" }, 
		 { 1, SymbolType.Error, "Error" }, 
		 { 2, SymbolType.Whitespace, "Whitespace" }, 
		 { 3, SymbolType.Terminal, "-" }, 
		 { 4, SymbolType.Terminal, "(" }, 
		 { 5, SymbolType.Terminal, ")" }, 
		 { 6, SymbolType.Terminal, "*" }, 
		 { 7, SymbolType.Terminal, "/" }, 
		 { 8, SymbolType.Terminal, "+" }, 
		 { 9, SymbolType.Terminal, "Number" }, 
		 { 10, SymbolType.NonTerminal, "<Add Exp>" }, 
		 { 11, SymbolType.NonTerminal, "<Mult Exp>" }, 
		 { 12, SymbolType.NonTerminal, "<Negate Exp>" }, 
		 { 13, SymbolType.NonTerminal, "<Value>" }, 
	]; 
	static const SymbolRule[10] RuleTable = [ 
		 { 0, 10, [10,8,11,] , "<Add Exp> ::= <Add Exp> + <Mult Exp> "}, 
		 { 1, 10, [10,3,11,] , "<Add Exp> ::= <Add Exp> - <Mult Exp> "}, 
		 { 2, 10, [11,] , "<Add Exp> ::= <Mult Exp> "}, 
		 { 3, 11, [11,6,12,] , "<Mult Exp> ::= <Mult Exp> * <Negate Exp> "}, 
		 { 4, 11, [11,7,12,] , "<Mult Exp> ::= <Mult Exp> / <Negate Exp> "}, 
		 { 5, 11, [12,] , "<Mult Exp> ::= <Negate Exp> "}, 
		 { 6, 12, [3,13,] , "<Negate Exp> ::= - <Value> "}, 
		 { 7, 12, [13,] , "<Negate Exp> ::= <Value> "}, 
		 { 8, 13, [9,] , "<Value> ::= Number "}, 
		 { 9, 13, [4,10,5,] , "<Value> ::= ( <Add Exp> ) "}, 
	]; 
	static const Max_Rule_Len = 3 ; 
	static const CharSet[8] CharSetTable = [ 
		// \u9;\n\u11;\u12;  
		 { 0, [9, 10, 11, 12, 13, 32, 160, ] }, 
		// -
		 { 1, [45, ] }, 
		// (
		 { 2, [40, ] }, 
		// )
		 { 3, [41, ] }, 
		// *
		 { 4, [42, ] }, 
		// /
		 { 5, [47, ] }, 
		// +
		 { 6, [43, ] }, 
		// 0123456789
		 { 7, [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, ] }, 
	]; 
	static const DFAState[9] DFATable = [ 
		 { 0, -1, false, [{0, 1}, {1, 2}, {2, 3}, {3, 4}, {4, 5}, {5, 6}, {6, 7}, {7, 8}, ] }, 
		 { 1, 2, true, [{0, 1}, ] }, 
		 { 2, 3, true, [] }, 
		 { 3, 4, true, [] }, 
		 { 4, 5, true, [] }, 
		 { 5, 6, true, [] }, 
		 { 6, 7, true, [] }, 
		 { 7, 8, true, [] }, 
		 { 8, 9, true, [{7, 8}, ] }, 
	]; 
	static const LALRState[19] LALRTable = [ 
		 { 0, [{0, LALRActionType.Shift,3,1}, {1, LALRActionType.Shift,4,2}, {2, LALRActionType.Shift,9,3}, {3, LALRActionType.Goto,10,4}, {4, LALRActionType.Goto,11,5}, {5, LALRActionType.Goto,12,6}, {6, LALRActionType.Goto,13,7}, ] }, 
		 { 1, [{0, LALRActionType.Shift,4,2}, {1, LALRActionType.Shift,9,3}, {2, LALRActionType.Goto,13,8}, ] }, 
		 { 2, [{0, LALRActionType.Shift,3,1}, {1, LALRActionType.Shift,4,2}, {2, LALRActionType.Shift,9,3}, {3, LALRActionType.Goto,10,9}, {4, LALRActionType.Goto,11,5}, {5, LALRActionType.Goto,12,6}, {6, LALRActionType.Goto,13,7}, ] }, 
		 { 3, [{0, LALRActionType.Reduce,0,8}, {1, LALRActionType.Reduce,3,8}, {2, LALRActionType.Reduce,5,8}, {3, LALRActionType.Reduce,6,8}, {4, LALRActionType.Reduce,7,8}, {5, LALRActionType.Reduce,8,8}, ] }, 
		 { 4, [{0, LALRActionType.Accept,0,0}, {1, LALRActionType.Shift,3,10}, {2, LALRActionType.Shift,8,11}, ] }, 
		 { 5, [{0, LALRActionType.Shift,6,12}, {1, LALRActionType.Shift,7,13}, {2, LALRActionType.Reduce,0,2}, {3, LALRActionType.Reduce,3,2}, {4, LALRActionType.Reduce,5,2}, {5, LALRActionType.Reduce,8,2}, ] }, 
		 { 6, [{0, LALRActionType.Reduce,0,5}, {1, LALRActionType.Reduce,3,5}, {2, LALRActionType.Reduce,5,5}, {3, LALRActionType.Reduce,6,5}, {4, LALRActionType.Reduce,7,5}, {5, LALRActionType.Reduce,8,5}, ] }, 
		 { 7, [{0, LALRActionType.Reduce,0,7}, {1, LALRActionType.Reduce,3,7}, {2, LALRActionType.Reduce,5,7}, {3, LALRActionType.Reduce,6,7}, {4, LALRActionType.Reduce,7,7}, {5, LALRActionType.Reduce,8,7}, ] }, 
		 { 8, [{0, LALRActionType.Reduce,0,6}, {1, LALRActionType.Reduce,3,6}, {2, LALRActionType.Reduce,5,6}, {3, LALRActionType.Reduce,6,6}, {4, LALRActionType.Reduce,7,6}, {5, LALRActionType.Reduce,8,6}, ] }, 
		 { 9, [{0, LALRActionType.Shift,3,10}, {1, LALRActionType.Shift,5,14}, {2, LALRActionType.Shift,8,11}, ] }, 
		 { 10, [{0, LALRActionType.Shift,3,1}, {1, LALRActionType.Shift,4,2}, {2, LALRActionType.Shift,9,3}, {3, LALRActionType.Goto,11,15}, {4, LALRActionType.Goto,12,6}, {5, LALRActionType.Goto,13,7}, ] }, 
		 { 11, [{0, LALRActionType.Shift,3,1}, {1, LALRActionType.Shift,4,2}, {2, LALRActionType.Shift,9,3}, {3, LALRActionType.Goto,11,16}, {4, LALRActionType.Goto,12,6}, {5, LALRActionType.Goto,13,7}, ] }, 
		 { 12, [{0, LALRActionType.Shift,3,1}, {1, LALRActionType.Shift,4,2}, {2, LALRActionType.Shift,9,3}, {3, LALRActionType.Goto,12,17}, {4, LALRActionType.Goto,13,7}, ] }, 
		 { 13, [{0, LALRActionType.Shift,3,1}, {1, LALRActionType.Shift,4,2}, {2, LALRActionType.Shift,9,3}, {3, LALRActionType.Goto,12,18}, {4, LALRActionType.Goto,13,7}, ] }, 
		 { 14, [{0, LALRActionType.Reduce,0,9}, {1, LALRActionType.Reduce,3,9}, {2, LALRActionType.Reduce,5,9}, {3, LALRActionType.Reduce,6,9}, {4, LALRActionType.Reduce,7,9}, {5, LALRActionType.Reduce,8,9}, ] }, 
		 { 15, [{0, LALRActionType.Shift,6,12}, {1, LALRActionType.Shift,7,13}, {2, LALRActionType.Reduce,0,1}, {3, LALRActionType.Reduce,3,1}, {4, LALRActionType.Reduce,5,1}, {5, LALRActionType.Reduce,8,1}, ] }, 
		 { 16, [{0, LALRActionType.Shift,6,12}, {1, LALRActionType.Shift,7,13}, {2, LALRActionType.Reduce,0,0}, {3, LALRActionType.Reduce,3,0}, {4, LALRActionType.Reduce,5,0}, {5, LALRActionType.Reduce,8,0}, ] }, 
		 { 17, [{0, LALRActionType.Reduce,0,3}, {1, LALRActionType.Reduce,3,3}, {2, LALRActionType.Reduce,5,3}, {3, LALRActionType.Reduce,6,3}, {4, LALRActionType.Reduce,7,3}, {5, LALRActionType.Reduce,8,3}, ] }, 
		 { 18, [{0, LALRActionType.Reduce,0,4}, {1, LALRActionType.Reduce,3,4}, {2, LALRActionType.Reduce,5,4}, {3, LALRActionType.Reduce,6,4}, {4, LALRActionType.Reduce,7,4}, {5, LALRActionType.Reduce,8,4}, ] }, 
	]; 
}
struct Lang_css {

	static const string	Name	= `Calc` ; 
	static const string	Version	= `0.01` ; 
	static const string	Author	= `Nick Sabalausky` ; 
	static const string	About	= `Basic Calculator Grammar` ; 

	static const int	StartSymbolID	= 10; 
	static const int	EofSymbolID	= 0; 
	static const int	ErrorSymbolID	= 1; 
	static const int	InitDfaID	= 0; 
	static const int	InitLALRID	= 0; 

	mixin Gold_Lang_Engine!(typeof(this)) ;
}
