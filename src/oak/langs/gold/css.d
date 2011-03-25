module oak.langs.gold.css ;
public import oak.langs.gold.Base ;

private {

	static const Symbol[52] SymbolTable = [ 
		 { 0, SymbolType.EOF, "EOF" }, 
		 { 1, SymbolType.Error, "Error" }, 
		 { 2, SymbolType.Whitespace, "Whitespace" }, 
		 { 3, SymbolType.CommentEnd, "Comment End" }, 
		 { 4, SymbolType.CommentStart, "Comment Start" }, 
		 { 5, SymbolType.Terminal, "!important" }, 
		 { 6, SymbolType.Terminal, "%" }, 
		 { 7, SymbolType.Terminal, "(" }, 
		 { 8, SymbolType.Terminal, ")" }, 
		 { 9, SymbolType.Terminal, "," }, 
		 { 10, SymbolType.Terminal, ":" }, 
		 { 11, SymbolType.Terminal, ":active" }, 
		 { 12, SymbolType.Terminal, ":first-letter" }, 
		 { 13, SymbolType.Terminal, ":first-line" }, 
		 { 14, SymbolType.Terminal, ":hover" }, 
		 { 15, SymbolType.Terminal, ":link" }, 
		 { 16, SymbolType.Terminal, ":visited" }, 
		 { 17, SymbolType.Terminal, ";" }, 
		 { 18, SymbolType.Terminal, "@charset" }, 
		 { 19, SymbolType.Terminal, "@font-face" }, 
		 { 20, SymbolType.Terminal, "@import" }, 
		 { 21, SymbolType.Terminal, "@media" }, 
		 { 22, SymbolType.Terminal, "{" }, 
		 { 23, SymbolType.Terminal, "}" }, 
		 { 24, SymbolType.Terminal, "ClassID" }, 
		 { 25, SymbolType.Terminal, "cm" }, 
		 { 26, SymbolType.Terminal, "ColorRGB" }, 
		 { 27, SymbolType.Terminal, "em" }, 
		 { 28, SymbolType.Terminal, "ex" }, 
		 { 29, SymbolType.Terminal, "ID" }, 
		 { 30, SymbolType.Terminal, "in" }, 
		 { 31, SymbolType.Terminal, "mm" }, 
		 { 32, SymbolType.Terminal, "Number" }, 
		 { 33, SymbolType.Terminal, "pc" }, 
		 { 34, SymbolType.Terminal, "pt" }, 
		 { 35, SymbolType.Terminal, "px" }, 
		 { 36, SymbolType.Terminal, "StringLiteral" }, 
		 { 37, SymbolType.NonTerminal, "<Attrib ID List>" }, 
		 { 38, SymbolType.NonTerminal, "<Attrib Values>" }, 
		 { 39, SymbolType.NonTerminal, "<Attribute>" }, 
		 { 40, SymbolType.NonTerminal, "<Attributes>" }, 
		 { 41, SymbolType.NonTerminal, "<Important Opt>" }, 
		 { 42, SymbolType.NonTerminal, "<Params>" }, 
		 { 43, SymbolType.NonTerminal, "<Pseudo Class>" }, 
		 { 44, SymbolType.NonTerminal, "<Style>" }, 
		 { 45, SymbolType.NonTerminal, "<Style ID>" }, 
		 { 46, SymbolType.NonTerminal, "<Style ID List>" }, 
		 { 47, SymbolType.NonTerminal, "<Style IDs>" }, 
		 { 48, SymbolType.NonTerminal, "<StyleSheet>" }, 
		 { 49, SymbolType.NonTerminal, "<Unit>" }, 
		 { 50, SymbolType.NonTerminal, "<Value>" }, 
		 { 51, SymbolType.NonTerminal, "<Values>" }, 
	]; 
	static const SymbolRule[50] RuleTable = [ 
		// <StyleSheet>	  ::= <Style> <StyleSheet>  
		 { 0, 48, [44,48,] }, 
		// <StyleSheet>	  ::=  
		 { 1, 48, [] }, 
		// <Style>	  ::= <Style ID List> { <Attributes> }  
		 { 2, 44, [46,22,40,23,] }, 
		// <Style ID List>	  ::= <Style IDs> , <Style ID List>  
		 { 3, 46, [47,9,46,] }, 
		// <Style ID List>	  ::= <Style IDs>  
		 { 4, 46, [47,] }, 
		// <Style IDs>	  ::= <Style ID> <Style IDs>  
		 { 5, 47, [45,47,] }, 
		// <Style IDs>	  ::= <Style ID>  
		 { 6, 47, [45,] }, 
		// <Style ID>	  ::= ID  
		 { 7, 45, [29,] }, 
		// <Style ID>	  ::= ID <Pseudo Class>  
		 { 8, 45, [29,43,] }, 
		// <Style ID>	  ::= ClassID  
		 { 9, 45, [24,] }, 
		// <Style ID>	  ::= ClassID <Pseudo Class>  
		 { 10, 45, [24,43,] }, 
		// <Attributes>	  ::= <Attribute> <Attributes>  
		 { 11, 40, [39,40,] }, 
		// <Attributes>	  ::=  
		 { 12, 40, [] }, 
		// <Attribute>	  ::= <Attrib ID List> : <Attrib Values> ;  
		 { 13, 39, [37,10,38,17,] }, 
		// <Attrib ID List>	  ::= ID , <Attrib ID List>  
		 { 14, 37, [29,9,37,] }, 
		// <Attrib ID List>	  ::= ID  
		 { 15, 37, [29,] }, 
		// <Attrib Values>	  ::= <Values> <Important Opt> , <Attrib Values>  
		 { 16, 38, [51,41,9,38,] }, 
		// <Attrib Values>	  ::= <Values> <Important Opt>  
		 { 17, 38, [51,41,] }, 
		// <Values>	  ::= <Value> <Values>  
		 { 18, 51, [50,51,] }, 
		// <Values>	  ::= <Value>  
		 { 19, 51, [50,] }, 
		// <Value>	  ::= Number  
		 { 20, 50, [32,] }, 
		// <Value>	  ::= Number <Unit>  
		 { 21, 50, [32,49,] }, 
		// <Value>	  ::= ID  
		 { 22, 50, [29,] }, 
		// <Value>	  ::= StringLiteral  
		 { 23, 50, [36,] }, 
		// <Value>	  ::= ColorRGB  
		 { 24, 50, [26,] }, 
		// <Value>	  ::= ID ( <Params> )  
		 { 25, 50, [29,7,42,8,] }, 
		// <Value>	  ::= ID ( )  
		 { 26, 50, [29,7,8,] }, 
		// <Params>	  ::= <Value> , <Params>  
		 { 27, 42, [50,9,42,] }, 
		// <Params>	  ::= <Value>  
		 { 28, 42, [50,] }, 
		// <Unit>	  ::= em  
		 { 29, 49, [27,] }, 
		// <Unit>	  ::= ex  
		 { 30, 49, [28,] }, 
		// <Unit>	  ::= px  
		 { 31, 49, [35,] }, 
		// <Unit>	  ::= %  
		 { 32, 49, [6,] }, 
		// <Unit>	  ::= in  
		 { 33, 49, [30,] }, 
		// <Unit>	  ::= cm  
		 { 34, 49, [25,] }, 
		// <Unit>	  ::= mm  
		 { 35, 49, [31,] }, 
		// <Unit>	  ::= pt  
		 { 36, 49, [34,] }, 
		// <Unit>	  ::= pc  
		 { 37, 49, [33,] }, 
		// <Important Opt>	  ::= !important  
		 { 38, 41, [5,] }, 
		// <Important Opt>	  ::=  
		 { 39, 41, [] }, 
		// <Pseudo Class>	  ::= :active  
		 { 40, 43, [11,] }, 
		// <Pseudo Class>	  ::= :first-letter  
		 { 41, 43, [12,] }, 
		// <Pseudo Class>	  ::= :first-line  
		 { 42, 43, [13,] }, 
		// <Pseudo Class>	  ::= :hover  
		 { 43, 43, [14,] }, 
		// <Pseudo Class>	  ::= :link  
		 { 44, 43, [15,] }, 
		// <Pseudo Class>	  ::= :visited  
		 { 45, 43, [16,] }, 
		// <Pseudo Class>	  ::= @font-face  
		 { 46, 43, [19,] }, 
		// <Pseudo Class>	  ::= @media  
		 { 47, 43, [21,] }, 
		// <Pseudo Class>	  ::= @charset  
		 { 48, 43, [18,] }, 
		// <Pseudo Class>	  ::= @import  
		 { 49, 43, [20,] }, 
	]; 
	static const Max_Rule_Len = 4 ; 
	static const CharSet[45] CharSetTable = [ 
		// \u9;\n\u11;\u12;  
		 { 0, [9, 10, 11, 12, 13, 32, 160, ] }, 
		// !
		 { 1, [33, ] }, 
		// #
		 { 2, [35, ] }, 
		// %
		 { 3, [37, ] }, 
		// '
		 { 4, [39, ] }, 
		// (
		 { 5, [40, ] }, 
		// )
		 { 6, [41, ] }, 
		// *
		 { 7, [42, ] }, 
		// ,
		 { 8, [44, ] }, 
		// .
		 { 9, [46, ] }, 
		// /
		 { 10, [47, ] }, 
		// 0123456789
		 { 11, [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, ] }, 
		// :
		 { 12, [58, ] }, 
		// ;
		 { 13, [59, ] }, 
		// @
		 { 14, [64, ] }, 
		// ABCDEFGHIJKLMNOPQRSTUVWXYZabdfghjklnoqrstuvwxyz
		 { 15, [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 100, 102, 103, 104, 106, 107, 108, 110, 111, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, ] }, 
		// c
		 { 16, [99, ] }, 
		// e
		 { 17, [101, ] }, 
		// i
		 { 18, [105, ] }, 
		// m
		 { 19, [109, ] }, 
		// p
		 { 20, [112, ] }, 
		// {
		 { 21, [123, ] }, 
		// }
		 { 22, [125, ] }, 
		// o
		 { 23, [111, ] }, 
		// r
		 { 24, [114, ] }, 
		// t
		 { 25, [116, ] }, 
		// a
		 { 26, [97, ] }, 
		// n
		 { 27, [110, ] }, 
		// 0123456789abcdef
		 { 28, [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102, ] }, 
		//  !\"#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ 
		 { 29, [32, 33, 34, 35, 36, 37, 38, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 160, ] }, 
		// ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
		 { 30, [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, ] }, 
		// -
		 { 31, [45, ] }, 
		// 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
		 { 32, [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, ] }, 
		// f
		 { 33, [102, ] }, 
		// h
		 { 34, [104, ] }, 
		// l
		 { 35, [108, ] }, 
		// v
		 { 36, [118, ] }, 
		// s
		 { 37, [115, ] }, 
		// k
		 { 38, [107, ] }, 
		// d
		 { 39, [100, ] }, 
		// 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklnopqrstuvwxyz
		 { 40, [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, ] }, 
		// 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklnopqrstuvwyz
		 { 41, [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 121, 122, ] }, 
		// x
		 { 42, [120, ] }, 
		// 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmopqrstuvwxyz
		 { 43, [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, ] }, 
		// 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabdefghijklmnopqrsuvwyz
		 { 44, [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 117, 118, 119, 121, 122, ] }, 
	]; 
	static const DFAState[119] DFATable = [ 
		 { 0, -1, false, [{0, 1}, {1, 2}, {2, 12}, {3, 14}, {4, 15}, {5, 18}, {6, 19}, {7, 20}, {8, 22}, {9, 23}, {10, 28}, {11, 30}, {12, 33}, {13, 71}, {14, 72}, {15, 100}, {16, 104}, {17, 106}, {18, 109}, {19, 111}, {20, 113}, {21, 117}, {22, 118}, ] }, 
		 { 1, 2, true, [{0, 1}, ] }, 
		 { 2, -1, false, [{18, 3}, ] }, 
		 { 3, -1, false, [{19, 4}, ] }, 
		 { 4, -1, false, [{20, 5}, ] }, 
		 { 5, -1, false, [{23, 6}, ] }, 
		 { 6, -1, false, [{24, 7}, ] }, 
		 { 7, -1, false, [{25, 8}, ] }, 
		 { 8, -1, false, [{26, 9}, ] }, 
		 { 9, -1, false, [{27, 10}, ] }, 
		 { 10, -1, false, [{25, 11}, ] }, 
		 { 11, 5, true, [] }, 
		 { 12, -1, false, [{28, 13}, ] }, 
		 { 13, 26, true, [{28, 13}, ] }, 
		 { 14, 6, true, [] }, 
		 { 15, -1, false, [{29, 16}, {4, 17}, ] }, 
		 { 16, -1, false, [{29, 16}, {4, 17}, ] }, 
		 { 17, 36, true, [] }, 
		 { 18, 7, true, [] }, 
		 { 19, 8, true, [] }, 
		 { 20, -1, false, [{10, 21}, ] }, 
		 { 21, 3, true, [] }, 
		 { 22, 9, true, [] }, 
		 { 23, -1, false, [{30, 24}, ] }, 
		 { 24, 24, true, [{31, 25}, {32, 27}, ] }, 
		 { 25, -1, false, [{32, 26}, ] }, 
		 { 26, 24, true, [{31, 25}, {32, 27}, ] }, 
		 { 27, 24, true, [{31, 25}, {32, 27}, ] }, 
		 { 28, -1, false, [{7, 29}, ] }, 
		 { 29, 4, true, [] }, 
		 { 30, 32, true, [{9, 31}, {11, 30}, ] }, 
		 { 31, -1, false, [{11, 32}, ] }, 
		 { 32, 32, true, [{11, 32}, ] }, 
		 { 33, 10, true, [{26, 34}, {33, 40}, {34, 55}, {35, 60}, {36, 64}, ] }, 
		 { 34, -1, false, [{16, 35}, ] }, 
		 { 35, -1, false, [{25, 36}, ] }, 
		 { 36, -1, false, [{18, 37}, ] }, 
		 { 37, -1, false, [{36, 38}, ] }, 
		 { 38, -1, false, [{17, 39}, ] }, 
		 { 39, 11, true, [] }, 
		 { 40, -1, false, [{18, 41}, ] }, 
		 { 41, -1, false, [{24, 42}, ] }, 
		 { 42, -1, false, [{37, 43}, ] }, 
		 { 43, -1, false, [{25, 44}, ] }, 
		 { 44, -1, false, [{31, 45}, ] }, 
		 { 45, -1, false, [{35, 46}, ] }, 
		 { 46, -1, false, [{17, 47}, {18, 52}, ] }, 
		 { 47, -1, false, [{25, 48}, ] }, 
		 { 48, -1, false, [{25, 49}, ] }, 
		 { 49, -1, false, [{17, 50}, ] }, 
		 { 50, -1, false, [{24, 51}, ] }, 
		 { 51, 12, true, [] }, 
		 { 52, -1, false, [{27, 53}, ] }, 
		 { 53, -1, false, [{17, 54}, ] }, 
		 { 54, 13, true, [] }, 
		 { 55, -1, false, [{23, 56}, ] }, 
		 { 56, -1, false, [{36, 57}, ] }, 
		 { 57, -1, false, [{17, 58}, ] }, 
		 { 58, -1, false, [{24, 59}, ] }, 
		 { 59, 14, true, [] }, 
		 { 60, -1, false, [{18, 61}, ] }, 
		 { 61, -1, false, [{27, 62}, ] }, 
		 { 62, -1, false, [{38, 63}, ] }, 
		 { 63, 15, true, [] }, 
		 { 64, -1, false, [{18, 65}, ] }, 
		 { 65, -1, false, [{37, 66}, ] }, 
		 { 66, -1, false, [{18, 67}, ] }, 
		 { 67, -1, false, [{25, 68}, ] }, 
		 { 68, -1, false, [{17, 69}, ] }, 
		 { 69, -1, false, [{39, 70}, ] }, 
		 { 70, 16, true, [] }, 
		 { 71, 17, true, [] }, 
		 { 72, -1, false, [{16, 73}, {33, 80}, {18, 89}, {19, 95}, ] }, 
		 { 73, -1, false, [{34, 74}, ] }, 
		 { 74, -1, false, [{26, 75}, ] }, 
		 { 75, -1, false, [{24, 76}, ] }, 
		 { 76, -1, false, [{37, 77}, ] }, 
		 { 77, -1, false, [{17, 78}, ] }, 
		 { 78, -1, false, [{25, 79}, ] }, 
		 { 79, 18, true, [] }, 
		 { 80, -1, false, [{23, 81}, ] }, 
		 { 81, -1, false, [{27, 82}, ] }, 
		 { 82, -1, false, [{25, 83}, ] }, 
		 { 83, -1, false, [{31, 84}, ] }, 
		 { 84, -1, false, [{33, 85}, ] }, 
		 { 85, -1, false, [{26, 86}, ] }, 
		 { 86, -1, false, [{16, 87}, ] }, 
		 { 87, -1, false, [{17, 88}, ] }, 
		 { 88, 19, true, [] }, 
		 { 89, -1, false, [{19, 90}, ] }, 
		 { 90, -1, false, [{20, 91}, ] }, 
		 { 91, -1, false, [{23, 92}, ] }, 
		 { 92, -1, false, [{24, 93}, ] }, 
		 { 93, -1, false, [{25, 94}, ] }, 
		 { 94, 20, true, [] }, 
		 { 95, -1, false, [{17, 96}, ] }, 
		 { 96, -1, false, [{39, 97}, ] }, 
		 { 97, -1, false, [{18, 98}, ] }, 
		 { 98, -1, false, [{26, 99}, ] }, 
		 { 99, 21, true, [] }, 
		 { 100, 29, true, [{31, 101}, {32, 103}, ] }, 
		 { 101, -1, false, [{32, 102}, ] }, 
		 { 102, 29, true, [{31, 101}, {32, 103}, ] }, 
		 { 103, 29, true, [{31, 101}, {32, 103}, ] }, 
		 { 104, 29, true, [{31, 101}, {40, 103}, {19, 105}, ] }, 
		 { 105, 25, true, [{31, 101}, {32, 103}, ] }, 
		 { 106, 29, true, [{31, 101}, {41, 103}, {19, 107}, {42, 108}, ] }, 
		 { 107, 27, true, [{31, 101}, {32, 103}, ] }, 
		 { 108, 28, true, [{31, 101}, {32, 103}, ] }, 
		 { 109, 29, true, [{31, 101}, {43, 103}, {27, 110}, ] }, 
		 { 110, 30, true, [{31, 101}, {32, 103}, ] }, 
		 { 111, 29, true, [{31, 101}, {40, 103}, {19, 112}, ] }, 
		 { 112, 31, true, [{31, 101}, {32, 103}, ] }, 
		 { 113, 29, true, [{31, 101}, {44, 103}, {16, 114}, {25, 115}, {42, 116}, ] }, 
		 { 114, 33, true, [{31, 101}, {32, 103}, ] }, 
		 { 115, 34, true, [{31, 101}, {32, 103}, ] }, 
		 { 116, 35, true, [{31, 101}, {32, 103}, ] }, 
		 { 117, 22, true, [] }, 
		 { 118, 23, true, [] }, 
	]; 
	static const LALRState[64] LALRTable = [ 
		 { 0, [{0, LALRActionType.Shift,24,1}, {1, LALRActionType.Shift,29,13}, {2, LALRActionType.Goto,44,15}, {3, LALRActionType.Goto,45,16}, {4, LALRActionType.Goto,46,18}, {5, LALRActionType.Goto,47,59}, {6, LALRActionType.Goto,48,63}, {7, LALRActionType.Reduce,0,1}, ] }, 
		 { 1, [{0, LALRActionType.Shift,11,2}, {1, LALRActionType.Shift,12,3}, {2, LALRActionType.Shift,13,4}, {3, LALRActionType.Shift,14,5}, {4, LALRActionType.Shift,15,6}, {5, LALRActionType.Shift,16,7}, {6, LALRActionType.Shift,18,8}, {7, LALRActionType.Shift,19,9}, {8, LALRActionType.Shift,20,10}, {9, LALRActionType.Shift,21,11}, {10, LALRActionType.Goto,43,12}, {11, LALRActionType.Reduce,9,9}, {12, LALRActionType.Reduce,22,9}, {13, LALRActionType.Reduce,24,9}, {14, LALRActionType.Reduce,29,9}, ] }, 
		 { 2, [{0, LALRActionType.Reduce,9,40}, {1, LALRActionType.Reduce,22,40}, {2, LALRActionType.Reduce,24,40}, {3, LALRActionType.Reduce,29,40}, ] }, 
		 { 3, [{0, LALRActionType.Reduce,9,41}, {1, LALRActionType.Reduce,22,41}, {2, LALRActionType.Reduce,24,41}, {3, LALRActionType.Reduce,29,41}, ] }, 
		 { 4, [{0, LALRActionType.Reduce,9,42}, {1, LALRActionType.Reduce,22,42}, {2, LALRActionType.Reduce,24,42}, {3, LALRActionType.Reduce,29,42}, ] }, 
		 { 5, [{0, LALRActionType.Reduce,9,43}, {1, LALRActionType.Reduce,22,43}, {2, LALRActionType.Reduce,24,43}, {3, LALRActionType.Reduce,29,43}, ] }, 
		 { 6, [{0, LALRActionType.Reduce,9,44}, {1, LALRActionType.Reduce,22,44}, {2, LALRActionType.Reduce,24,44}, {3, LALRActionType.Reduce,29,44}, ] }, 
		 { 7, [{0, LALRActionType.Reduce,9,45}, {1, LALRActionType.Reduce,22,45}, {2, LALRActionType.Reduce,24,45}, {3, LALRActionType.Reduce,29,45}, ] }, 
		 { 8, [{0, LALRActionType.Reduce,9,48}, {1, LALRActionType.Reduce,22,48}, {2, LALRActionType.Reduce,24,48}, {3, LALRActionType.Reduce,29,48}, ] }, 
		 { 9, [{0, LALRActionType.Reduce,9,46}, {1, LALRActionType.Reduce,22,46}, {2, LALRActionType.Reduce,24,46}, {3, LALRActionType.Reduce,29,46}, ] }, 
		 { 10, [{0, LALRActionType.Reduce,9,49}, {1, LALRActionType.Reduce,22,49}, {2, LALRActionType.Reduce,24,49}, {3, LALRActionType.Reduce,29,49}, ] }, 
		 { 11, [{0, LALRActionType.Reduce,9,47}, {1, LALRActionType.Reduce,22,47}, {2, LALRActionType.Reduce,24,47}, {3, LALRActionType.Reduce,29,47}, ] }, 
		 { 12, [{0, LALRActionType.Reduce,9,10}, {1, LALRActionType.Reduce,22,10}, {2, LALRActionType.Reduce,24,10}, {3, LALRActionType.Reduce,29,10}, ] }, 
		 { 13, [{0, LALRActionType.Shift,11,2}, {1, LALRActionType.Shift,12,3}, {2, LALRActionType.Shift,13,4}, {3, LALRActionType.Shift,14,5}, {4, LALRActionType.Shift,15,6}, {5, LALRActionType.Shift,16,7}, {6, LALRActionType.Shift,18,8}, {7, LALRActionType.Shift,19,9}, {8, LALRActionType.Shift,20,10}, {9, LALRActionType.Shift,21,11}, {10, LALRActionType.Goto,43,14}, {11, LALRActionType.Reduce,9,7}, {12, LALRActionType.Reduce,22,7}, {13, LALRActionType.Reduce,24,7}, {14, LALRActionType.Reduce,29,7}, ] }, 
		 { 14, [{0, LALRActionType.Reduce,9,8}, {1, LALRActionType.Reduce,22,8}, {2, LALRActionType.Reduce,24,8}, {3, LALRActionType.Reduce,29,8}, ] }, 
		 { 15, [{0, LALRActionType.Shift,24,1}, {1, LALRActionType.Shift,29,13}, {2, LALRActionType.Goto,44,15}, {3, LALRActionType.Goto,45,16}, {4, LALRActionType.Goto,46,18}, {5, LALRActionType.Goto,47,59}, {6, LALRActionType.Goto,48,62}, {7, LALRActionType.Reduce,0,1}, ] }, 
		 { 16, [{0, LALRActionType.Shift,24,1}, {1, LALRActionType.Shift,29,13}, {2, LALRActionType.Goto,45,16}, {3, LALRActionType.Goto,47,17}, {4, LALRActionType.Reduce,9,6}, {5, LALRActionType.Reduce,22,6}, ] }, 
		 { 17, [{0, LALRActionType.Reduce,9,5}, {1, LALRActionType.Reduce,22,5}, ] }, 
		 { 18, [{0, LALRActionType.Shift,22,19}, ] }, 
		 { 19, [{0, LALRActionType.Shift,29,20}, {1, LALRActionType.Goto,37,23}, {2, LALRActionType.Goto,39,55}, {3, LALRActionType.Goto,40,57}, {4, LALRActionType.Reduce,23,12}, ] }, 
		 { 20, [{0, LALRActionType.Shift,9,21}, {1, LALRActionType.Reduce,10,15}, ] }, 
		 { 21, [{0, LALRActionType.Shift,29,20}, {1, LALRActionType.Goto,37,22}, ] }, 
		 { 22, [{0, LALRActionType.Reduce,10,14}, ] }, 
		 { 23, [{0, LALRActionType.Shift,10,24}, ] }, 
		 { 24, [{0, LALRActionType.Shift,26,25}, {1, LALRActionType.Shift,29,26}, {2, LALRActionType.Shift,32,29}, {3, LALRActionType.Shift,36,40}, {4, LALRActionType.Goto,38,46}, {5, LALRActionType.Goto,50,48}, {6, LALRActionType.Goto,51,50}, ] }, 
		 { 25, [{0, LALRActionType.Reduce,5,24}, {1, LALRActionType.Reduce,8,24}, {2, LALRActionType.Reduce,9,24}, {3, LALRActionType.Reduce,17,24}, {4, LALRActionType.Reduce,26,24}, {5, LALRActionType.Reduce,29,24}, {6, LALRActionType.Reduce,32,24}, {7, LALRActionType.Reduce,36,24}, ] }, 
		 { 26, [{0, LALRActionType.Shift,7,27}, {1, LALRActionType.Reduce,5,22}, {2, LALRActionType.Reduce,8,22}, {3, LALRActionType.Reduce,9,22}, {4, LALRActionType.Reduce,17,22}, {5, LALRActionType.Reduce,26,22}, {6, LALRActionType.Reduce,29,22}, {7, LALRActionType.Reduce,32,22}, {8, LALRActionType.Reduce,36,22}, ] }, 
		 { 27, [{0, LALRActionType.Shift,8,28}, {1, LALRActionType.Shift,26,25}, {2, LALRActionType.Shift,29,26}, {3, LALRActionType.Shift,32,29}, {4, LALRActionType.Shift,36,40}, {5, LALRActionType.Goto,42,41}, {6, LALRActionType.Goto,50,43}, ] }, 
		 { 28, [{0, LALRActionType.Reduce,5,26}, {1, LALRActionType.Reduce,8,26}, {2, LALRActionType.Reduce,9,26}, {3, LALRActionType.Reduce,17,26}, {4, LALRActionType.Reduce,26,26}, {5, LALRActionType.Reduce,29,26}, {6, LALRActionType.Reduce,32,26}, {7, LALRActionType.Reduce,36,26}, ] }, 
		 { 29, [{0, LALRActionType.Shift,6,30}, {1, LALRActionType.Shift,25,31}, {2, LALRActionType.Shift,27,32}, {3, LALRActionType.Shift,28,33}, {4, LALRActionType.Shift,30,34}, {5, LALRActionType.Shift,31,35}, {6, LALRActionType.Shift,33,36}, {7, LALRActionType.Shift,34,37}, {8, LALRActionType.Shift,35,38}, {9, LALRActionType.Goto,49,39}, {10, LALRActionType.Reduce,5,20}, {11, LALRActionType.Reduce,8,20}, {12, LALRActionType.Reduce,9,20}, {13, LALRActionType.Reduce,17,20}, {14, LALRActionType.Reduce,26,20}, {15, LALRActionType.Reduce,29,20}, {16, LALRActionType.Reduce,32,20}, {17, LALRActionType.Reduce,36,20}, ] }, 
		 { 30, [{0, LALRActionType.Reduce,5,32}, {1, LALRActionType.Reduce,8,32}, {2, LALRActionType.Reduce,9,32}, {3, LALRActionType.Reduce,17,32}, {4, LALRActionType.Reduce,26,32}, {5, LALRActionType.Reduce,29,32}, {6, LALRActionType.Reduce,32,32}, {7, LALRActionType.Reduce,36,32}, ] }, 
		 { 31, [{0, LALRActionType.Reduce,5,34}, {1, LALRActionType.Reduce,8,34}, {2, LALRActionType.Reduce,9,34}, {3, LALRActionType.Reduce,17,34}, {4, LALRActionType.Reduce,26,34}, {5, LALRActionType.Reduce,29,34}, {6, LALRActionType.Reduce,32,34}, {7, LALRActionType.Reduce,36,34}, ] }, 
		 { 32, [{0, LALRActionType.Reduce,5,29}, {1, LALRActionType.Reduce,8,29}, {2, LALRActionType.Reduce,9,29}, {3, LALRActionType.Reduce,17,29}, {4, LALRActionType.Reduce,26,29}, {5, LALRActionType.Reduce,29,29}, {6, LALRActionType.Reduce,32,29}, {7, LALRActionType.Reduce,36,29}, ] }, 
		 { 33, [{0, LALRActionType.Reduce,5,30}, {1, LALRActionType.Reduce,8,30}, {2, LALRActionType.Reduce,9,30}, {3, LALRActionType.Reduce,17,30}, {4, LALRActionType.Reduce,26,30}, {5, LALRActionType.Reduce,29,30}, {6, LALRActionType.Reduce,32,30}, {7, LALRActionType.Reduce,36,30}, ] }, 
		 { 34, [{0, LALRActionType.Reduce,5,33}, {1, LALRActionType.Reduce,8,33}, {2, LALRActionType.Reduce,9,33}, {3, LALRActionType.Reduce,17,33}, {4, LALRActionType.Reduce,26,33}, {5, LALRActionType.Reduce,29,33}, {6, LALRActionType.Reduce,32,33}, {7, LALRActionType.Reduce,36,33}, ] }, 
		 { 35, [{0, LALRActionType.Reduce,5,35}, {1, LALRActionType.Reduce,8,35}, {2, LALRActionType.Reduce,9,35}, {3, LALRActionType.Reduce,17,35}, {4, LALRActionType.Reduce,26,35}, {5, LALRActionType.Reduce,29,35}, {6, LALRActionType.Reduce,32,35}, {7, LALRActionType.Reduce,36,35}, ] }, 
		 { 36, [{0, LALRActionType.Reduce,5,37}, {1, LALRActionType.Reduce,8,37}, {2, LALRActionType.Reduce,9,37}, {3, LALRActionType.Reduce,17,37}, {4, LALRActionType.Reduce,26,37}, {5, LALRActionType.Reduce,29,37}, {6, LALRActionType.Reduce,32,37}, {7, LALRActionType.Reduce,36,37}, ] }, 
		 { 37, [{0, LALRActionType.Reduce,5,36}, {1, LALRActionType.Reduce,8,36}, {2, LALRActionType.Reduce,9,36}, {3, LALRActionType.Reduce,17,36}, {4, LALRActionType.Reduce,26,36}, {5, LALRActionType.Reduce,29,36}, {6, LALRActionType.Reduce,32,36}, {7, LALRActionType.Reduce,36,36}, ] }, 
		 { 38, [{0, LALRActionType.Reduce,5,31}, {1, LALRActionType.Reduce,8,31}, {2, LALRActionType.Reduce,9,31}, {3, LALRActionType.Reduce,17,31}, {4, LALRActionType.Reduce,26,31}, {5, LALRActionType.Reduce,29,31}, {6, LALRActionType.Reduce,32,31}, {7, LALRActionType.Reduce,36,31}, ] }, 
		 { 39, [{0, LALRActionType.Reduce,5,21}, {1, LALRActionType.Reduce,8,21}, {2, LALRActionType.Reduce,9,21}, {3, LALRActionType.Reduce,17,21}, {4, LALRActionType.Reduce,26,21}, {5, LALRActionType.Reduce,29,21}, {6, LALRActionType.Reduce,32,21}, {7, LALRActionType.Reduce,36,21}, ] }, 
		 { 40, [{0, LALRActionType.Reduce,5,23}, {1, LALRActionType.Reduce,8,23}, {2, LALRActionType.Reduce,9,23}, {3, LALRActionType.Reduce,17,23}, {4, LALRActionType.Reduce,26,23}, {5, LALRActionType.Reduce,29,23}, {6, LALRActionType.Reduce,32,23}, {7, LALRActionType.Reduce,36,23}, ] }, 
		 { 41, [{0, LALRActionType.Shift,8,42}, ] }, 
		 { 42, [{0, LALRActionType.Reduce,5,25}, {1, LALRActionType.Reduce,8,25}, {2, LALRActionType.Reduce,9,25}, {3, LALRActionType.Reduce,17,25}, {4, LALRActionType.Reduce,26,25}, {5, LALRActionType.Reduce,29,25}, {6, LALRActionType.Reduce,32,25}, {7, LALRActionType.Reduce,36,25}, ] }, 
		 { 43, [{0, LALRActionType.Shift,9,44}, {1, LALRActionType.Reduce,8,28}, ] }, 
		 { 44, [{0, LALRActionType.Shift,26,25}, {1, LALRActionType.Shift,29,26}, {2, LALRActionType.Shift,32,29}, {3, LALRActionType.Shift,36,40}, {4, LALRActionType.Goto,42,45}, {5, LALRActionType.Goto,50,43}, ] }, 
		 { 45, [{0, LALRActionType.Reduce,8,27}, ] }, 
		 { 46, [{0, LALRActionType.Shift,17,47}, ] }, 
		 { 47, [{0, LALRActionType.Reduce,23,13}, {1, LALRActionType.Reduce,29,13}, ] }, 
		 { 48, [{0, LALRActionType.Shift,26,25}, {1, LALRActionType.Shift,29,26}, {2, LALRActionType.Shift,32,29}, {3, LALRActionType.Shift,36,40}, {4, LALRActionType.Goto,50,48}, {5, LALRActionType.Goto,51,49}, {6, LALRActionType.Reduce,5,19}, {7, LALRActionType.Reduce,9,19}, {8, LALRActionType.Reduce,17,19}, ] }, 
		 { 49, [{0, LALRActionType.Reduce,5,18}, {1, LALRActionType.Reduce,9,18}, {2, LALRActionType.Reduce,17,18}, ] }, 
		 { 50, [{0, LALRActionType.Shift,5,51}, {1, LALRActionType.Goto,41,52}, {2, LALRActionType.Reduce,9,39}, {3, LALRActionType.Reduce,17,39}, ] }, 
		 { 51, [{0, LALRActionType.Reduce,9,38}, {1, LALRActionType.Reduce,17,38}, ] }, 
		 { 52, [{0, LALRActionType.Shift,9,53}, {1, LALRActionType.Reduce,17,17}, ] }, 
		 { 53, [{0, LALRActionType.Shift,26,25}, {1, LALRActionType.Shift,29,26}, {2, LALRActionType.Shift,32,29}, {3, LALRActionType.Shift,36,40}, {4, LALRActionType.Goto,38,54}, {5, LALRActionType.Goto,50,48}, {6, LALRActionType.Goto,51,50}, ] }, 
		 { 54, [{0, LALRActionType.Reduce,17,16}, ] }, 
		 { 55, [{0, LALRActionType.Shift,29,20}, {1, LALRActionType.Goto,37,23}, {2, LALRActionType.Goto,39,55}, {3, LALRActionType.Goto,40,56}, {4, LALRActionType.Reduce,23,12}, ] }, 
		 { 56, [{0, LALRActionType.Reduce,23,11}, ] }, 
		 { 57, [{0, LALRActionType.Shift,23,58}, ] }, 
		 { 58, [{0, LALRActionType.Reduce,0,2}, {1, LALRActionType.Reduce,24,2}, {2, LALRActionType.Reduce,29,2}, ] }, 
		 { 59, [{0, LALRActionType.Shift,9,60}, {1, LALRActionType.Reduce,22,4}, ] }, 
		 { 60, [{0, LALRActionType.Shift,24,1}, {1, LALRActionType.Shift,29,13}, {2, LALRActionType.Goto,45,16}, {3, LALRActionType.Goto,46,61}, {4, LALRActionType.Goto,47,59}, ] }, 
		 { 61, [{0, LALRActionType.Reduce,22,3}, ] }, 
		 { 62, [{0, LALRActionType.Reduce,0,0}, ] }, 
		 { 63, [{0, LALRActionType.Accept,0,0}, ] }, 
	]; 
}
struct Lang_css {

	static const string	Name	= `CSS` ; 
	static const string	Version	= `CSS1 - 1996` ; 
	static const string	Author	= `Hakon Wium Lie and Bert Bos` ; 
	static const string	About	= `Cascading Style Sheets` ; 

	static const int	StartSymbolID	= 48; 
	static const int	EofSymbolID	= 0; 
	static const int	ErrorSymbolID	= 1; 
	static const int	InitDfaID	= 0; 
	static const int	InitLALRID	= 0; 

	mixin Gold_Lang_Engine!(typeof(this)) ;
}
