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
		// *
		 { 1, [42, ] }, 
		// /
		 { 2, [47, ] }, 
		// !
		 { 3, [33, ] }, 
		// %
		 { 4, [37, ] }, 
		// (
		 { 5, [40, ] }, 
		// )
		 { 6, [41, ] }, 
		// ,
		 { 7, [44, ] }, 
		// ;
		 { 8, [59, ] }, 
		// {
		 { 9, [123, ] }, 
		// }
		 { 10, [125, ] }, 
		// .
		 { 11, [46, ] }, 
		// #
		 { 12, [35, ] }, 
		// ABCDEFGHIJKLMNOPQRSTUVWXYZabdfghjklnoqrstuvwxyz
		 { 13, [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 100, 102, 103, 104, 106, 107, 108, 110, 111, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, ] }, 
		// 0123456789
		 { 14, [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, ] }, 
		// '
		 { 15, [39, ] }, 
		// :
		 { 16, [58, ] }, 
		// @
		 { 17, [64, ] }, 
		// c
		 { 18, [99, ] }, 
		// e
		 { 19, [101, ] }, 
		// i
		 { 20, [105, ] }, 
		// m
		 { 21, [109, ] }, 
		// p
		 { 22, [112, ] }, 
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
		// ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
		 { 28, [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, ] }, 
		// 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
		 { 29, [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, ] }, 
		// -
		 { 30, [45, ] }, 
		// 0123456789abcdef
		 { 31, [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102, ] }, 
		//  !\"#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ 
		 { 32, [32, 33, 34, 35, 36, 37, 38, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 160, ] }, 
		// h
		 { 33, [104, ] }, 
		// l
		 { 34, [108, ] }, 
		// v
		 { 35, [118, ] }, 
		// f
		 { 36, [102, ] }, 
		// k
		 { 37, [107, ] }, 
		// s
		 { 38, [115, ] }, 
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
		 { 0, -1, false, [{0, 1}, {1, 2}, {2, 4}, {3, 6}, {4, 16}, {5, 17}, {6, 18}, {7, 19}, {8, 20}, {9, 21}, {10, 22}, {11, 23}, {12, 28}, {13, 30}, {14, 34}, {15, 37}, {16, 40}, {17, 78}, {18, 106}, {19, 108}, {20, 111}, {21, 113}, {22, 115}, ] }, 
		 { 1, 2, true, [{0, 1}, ] }, 
		 { 2, -1, false, [{2, 3}, ] }, 
		 { 3, 3, true, [] }, 
		 { 4, -1, false, [{1, 5}, ] }, 
		 { 5, 4, true, [] }, 
		 { 6, -1, false, [{20, 7}, ] }, 
		 { 7, -1, false, [{21, 8}, ] }, 
		 { 8, -1, false, [{22, 9}, ] }, 
		 { 9, -1, false, [{23, 10}, ] }, 
		 { 10, -1, false, [{24, 11}, ] }, 
		 { 11, -1, false, [{25, 12}, ] }, 
		 { 12, -1, false, [{26, 13}, ] }, 
		 { 13, -1, false, [{27, 14}, ] }, 
		 { 14, -1, false, [{25, 15}, ] }, 
		 { 15, 5, true, [] }, 
		 { 16, 6, true, [] }, 
		 { 17, 7, true, [] }, 
		 { 18, 8, true, [] }, 
		 { 19, 9, true, [] }, 
		 { 20, 17, true, [] }, 
		 { 21, 22, true, [] }, 
		 { 22, 23, true, [] }, 
		 { 23, -1, false, [{28, 24}, ] }, 
		 { 24, 24, true, [{29, 25}, {30, 26}, ] }, 
		 { 25, 24, true, [{29, 25}, {30, 26}, ] }, 
		 { 26, -1, false, [{29, 27}, ] }, 
		 { 27, 24, true, [{29, 25}, {30, 26}, ] }, 
		 { 28, -1, false, [{31, 29}, ] }, 
		 { 29, 26, true, [{31, 29}, ] }, 
		 { 30, 29, true, [{29, 31}, {30, 32}, ] }, 
		 { 31, 29, true, [{29, 31}, {30, 32}, ] }, 
		 { 32, -1, false, [{29, 33}, ] }, 
		 { 33, 29, true, [{29, 31}, {30, 32}, ] }, 
		 { 34, 32, true, [{14, 34}, {11, 35}, ] }, 
		 { 35, -1, false, [{14, 36}, ] }, 
		 { 36, 32, true, [{14, 36}, ] }, 
		 { 37, -1, false, [{32, 38}, {15, 39}, ] }, 
		 { 38, -1, false, [{32, 38}, {15, 39}, ] }, 
		 { 39, 36, true, [] }, 
		 { 40, 10, true, [{26, 41}, {33, 47}, {34, 52}, {35, 56}, {36, 63}, ] }, 
		 { 41, -1, false, [{18, 42}, ] }, 
		 { 42, -1, false, [{25, 43}, ] }, 
		 { 43, -1, false, [{20, 44}, ] }, 
		 { 44, -1, false, [{35, 45}, ] }, 
		 { 45, -1, false, [{19, 46}, ] }, 
		 { 46, 11, true, [] }, 
		 { 47, -1, false, [{23, 48}, ] }, 
		 { 48, -1, false, [{35, 49}, ] }, 
		 { 49, -1, false, [{19, 50}, ] }, 
		 { 50, -1, false, [{24, 51}, ] }, 
		 { 51, 14, true, [] }, 
		 { 52, -1, false, [{20, 53}, ] }, 
		 { 53, -1, false, [{27, 54}, ] }, 
		 { 54, -1, false, [{37, 55}, ] }, 
		 { 55, 15, true, [] }, 
		 { 56, -1, false, [{20, 57}, ] }, 
		 { 57, -1, false, [{38, 58}, ] }, 
		 { 58, -1, false, [{20, 59}, ] }, 
		 { 59, -1, false, [{25, 60}, ] }, 
		 { 60, -1, false, [{19, 61}, ] }, 
		 { 61, -1, false, [{39, 62}, ] }, 
		 { 62, 16, true, [] }, 
		 { 63, -1, false, [{20, 64}, ] }, 
		 { 64, -1, false, [{24, 65}, ] }, 
		 { 65, -1, false, [{38, 66}, ] }, 
		 { 66, -1, false, [{25, 67}, ] }, 
		 { 67, -1, false, [{30, 68}, ] }, 
		 { 68, -1, false, [{34, 69}, ] }, 
		 { 69, -1, false, [{19, 70}, {20, 75}, ] }, 
		 { 70, -1, false, [{25, 71}, ] }, 
		 { 71, -1, false, [{25, 72}, ] }, 
		 { 72, -1, false, [{19, 73}, ] }, 
		 { 73, -1, false, [{24, 74}, ] }, 
		 { 74, 12, true, [] }, 
		 { 75, -1, false, [{27, 76}, ] }, 
		 { 76, -1, false, [{19, 77}, ] }, 
		 { 77, 13, true, [] }, 
		 { 78, -1, false, [{18, 79}, {36, 86}, {20, 95}, {21, 101}, ] }, 
		 { 79, -1, false, [{33, 80}, ] }, 
		 { 80, -1, false, [{26, 81}, ] }, 
		 { 81, -1, false, [{24, 82}, ] }, 
		 { 82, -1, false, [{38, 83}, ] }, 
		 { 83, -1, false, [{19, 84}, ] }, 
		 { 84, -1, false, [{25, 85}, ] }, 
		 { 85, 18, true, [] }, 
		 { 86, -1, false, [{23, 87}, ] }, 
		 { 87, -1, false, [{27, 88}, ] }, 
		 { 88, -1, false, [{25, 89}, ] }, 
		 { 89, -1, false, [{30, 90}, ] }, 
		 { 90, -1, false, [{36, 91}, ] }, 
		 { 91, -1, false, [{26, 92}, ] }, 
		 { 92, -1, false, [{18, 93}, ] }, 
		 { 93, -1, false, [{19, 94}, ] }, 
		 { 94, 19, true, [] }, 
		 { 95, -1, false, [{21, 96}, ] }, 
		 { 96, -1, false, [{22, 97}, ] }, 
		 { 97, -1, false, [{23, 98}, ] }, 
		 { 98, -1, false, [{24, 99}, ] }, 
		 { 99, -1, false, [{25, 100}, ] }, 
		 { 100, 20, true, [] }, 
		 { 101, -1, false, [{19, 102}, ] }, 
		 { 102, -1, false, [{39, 103}, ] }, 
		 { 103, -1, false, [{20, 104}, ] }, 
		 { 104, -1, false, [{26, 105}, ] }, 
		 { 105, 21, true, [] }, 
		 { 106, 29, true, [{40, 31}, {30, 32}, {21, 107}, ] }, 
		 { 107, 25, true, [{29, 31}, {30, 32}, ] }, 
		 { 108, 29, true, [{41, 31}, {30, 32}, {21, 109}, {42, 110}, ] }, 
		 { 109, 27, true, [{29, 31}, {30, 32}, ] }, 
		 { 110, 28, true, [{29, 31}, {30, 32}, ] }, 
		 { 111, 29, true, [{43, 31}, {30, 32}, {27, 112}, ] }, 
		 { 112, 30, true, [{29, 31}, {30, 32}, ] }, 
		 { 113, 29, true, [{40, 31}, {30, 32}, {21, 114}, ] }, 
		 { 114, 31, true, [{29, 31}, {30, 32}, ] }, 
		 { 115, 29, true, [{44, 31}, {30, 32}, {18, 116}, {25, 117}, {42, 118}, ] }, 
		 { 116, 33, true, [{29, 31}, {30, 32}, ] }, 
		 { 117, 34, true, [{29, 31}, {30, 32}, ] }, 
		 { 118, 35, true, [{29, 31}, {30, 32}, ] }, 
	]; 
	static const LALRState[64] LALRTable = [ 
		 { 0, [{0, LALRActionType.Shift,24,1}, {1, LALRActionType.Shift,29,2}, {2, LALRActionType.Goto,44,3}, {3, LALRActionType.Goto,45,4}, {4, LALRActionType.Goto,46,5}, {5, LALRActionType.Goto,47,6}, {6, LALRActionType.Goto,48,7}, {7, LALRActionType.Reduce,0,1}, ] }, 
		 { 1, [{0, LALRActionType.Shift,11,8}, {1, LALRActionType.Shift,12,9}, {2, LALRActionType.Shift,13,10}, {3, LALRActionType.Shift,14,11}, {4, LALRActionType.Shift,15,12}, {5, LALRActionType.Shift,16,13}, {6, LALRActionType.Shift,18,14}, {7, LALRActionType.Shift,19,15}, {8, LALRActionType.Shift,20,16}, {9, LALRActionType.Shift,21,17}, {10, LALRActionType.Goto,43,18}, {11, LALRActionType.Reduce,9,9}, {12, LALRActionType.Reduce,22,9}, {13, LALRActionType.Reduce,24,9}, {14, LALRActionType.Reduce,29,9}, ] }, 
		 { 2, [{0, LALRActionType.Shift,11,8}, {1, LALRActionType.Shift,12,9}, {2, LALRActionType.Shift,13,10}, {3, LALRActionType.Shift,14,11}, {4, LALRActionType.Shift,15,12}, {5, LALRActionType.Shift,16,13}, {6, LALRActionType.Shift,18,14}, {7, LALRActionType.Shift,19,15}, {8, LALRActionType.Shift,20,16}, {9, LALRActionType.Shift,21,17}, {10, LALRActionType.Goto,43,19}, {11, LALRActionType.Reduce,9,7}, {12, LALRActionType.Reduce,22,7}, {13, LALRActionType.Reduce,24,7}, {14, LALRActionType.Reduce,29,7}, ] }, 
		 { 3, [{0, LALRActionType.Shift,24,1}, {1, LALRActionType.Shift,29,2}, {2, LALRActionType.Goto,44,3}, {3, LALRActionType.Goto,45,4}, {4, LALRActionType.Goto,46,5}, {5, LALRActionType.Goto,47,6}, {6, LALRActionType.Goto,48,20}, {7, LALRActionType.Reduce,0,1}, ] }, 
		 { 4, [{0, LALRActionType.Shift,24,1}, {1, LALRActionType.Shift,29,2}, {2, LALRActionType.Goto,45,4}, {3, LALRActionType.Goto,47,21}, {4, LALRActionType.Reduce,9,6}, {5, LALRActionType.Reduce,22,6}, ] }, 
		 { 5, [{0, LALRActionType.Shift,22,22}, ] }, 
		 { 6, [{0, LALRActionType.Shift,9,23}, {1, LALRActionType.Reduce,22,4}, ] }, 
		 { 7, [{0, LALRActionType.Accept,0,0}, ] }, 
		 { 8, [{0, LALRActionType.Reduce,9,40}, {1, LALRActionType.Reduce,22,40}, {2, LALRActionType.Reduce,24,40}, {3, LALRActionType.Reduce,29,40}, ] }, 
		 { 9, [{0, LALRActionType.Reduce,9,41}, {1, LALRActionType.Reduce,22,41}, {2, LALRActionType.Reduce,24,41}, {3, LALRActionType.Reduce,29,41}, ] }, 
		 { 10, [{0, LALRActionType.Reduce,9,42}, {1, LALRActionType.Reduce,22,42}, {2, LALRActionType.Reduce,24,42}, {3, LALRActionType.Reduce,29,42}, ] }, 
		 { 11, [{0, LALRActionType.Reduce,9,43}, {1, LALRActionType.Reduce,22,43}, {2, LALRActionType.Reduce,24,43}, {3, LALRActionType.Reduce,29,43}, ] }, 
		 { 12, [{0, LALRActionType.Reduce,9,44}, {1, LALRActionType.Reduce,22,44}, {2, LALRActionType.Reduce,24,44}, {3, LALRActionType.Reduce,29,44}, ] }, 
		 { 13, [{0, LALRActionType.Reduce,9,45}, {1, LALRActionType.Reduce,22,45}, {2, LALRActionType.Reduce,24,45}, {3, LALRActionType.Reduce,29,45}, ] }, 
		 { 14, [{0, LALRActionType.Reduce,9,48}, {1, LALRActionType.Reduce,22,48}, {2, LALRActionType.Reduce,24,48}, {3, LALRActionType.Reduce,29,48}, ] }, 
		 { 15, [{0, LALRActionType.Reduce,9,46}, {1, LALRActionType.Reduce,22,46}, {2, LALRActionType.Reduce,24,46}, {3, LALRActionType.Reduce,29,46}, ] }, 
		 { 16, [{0, LALRActionType.Reduce,9,49}, {1, LALRActionType.Reduce,22,49}, {2, LALRActionType.Reduce,24,49}, {3, LALRActionType.Reduce,29,49}, ] }, 
		 { 17, [{0, LALRActionType.Reduce,9,47}, {1, LALRActionType.Reduce,22,47}, {2, LALRActionType.Reduce,24,47}, {3, LALRActionType.Reduce,29,47}, ] }, 
		 { 18, [{0, LALRActionType.Reduce,9,10}, {1, LALRActionType.Reduce,22,10}, {2, LALRActionType.Reduce,24,10}, {3, LALRActionType.Reduce,29,10}, ] }, 
		 { 19, [{0, LALRActionType.Reduce,9,8}, {1, LALRActionType.Reduce,22,8}, {2, LALRActionType.Reduce,24,8}, {3, LALRActionType.Reduce,29,8}, ] }, 
		 { 20, [{0, LALRActionType.Reduce,0,0}, ] }, 
		 { 21, [{0, LALRActionType.Reduce,9,5}, {1, LALRActionType.Reduce,22,5}, ] }, 
		 { 22, [{0, LALRActionType.Shift,29,24}, {1, LALRActionType.Goto,37,25}, {2, LALRActionType.Goto,39,26}, {3, LALRActionType.Goto,40,27}, {4, LALRActionType.Reduce,23,12}, ] }, 
		 { 23, [{0, LALRActionType.Shift,24,1}, {1, LALRActionType.Shift,29,2}, {2, LALRActionType.Goto,45,4}, {3, LALRActionType.Goto,46,28}, {4, LALRActionType.Goto,47,6}, ] }, 
		 { 24, [{0, LALRActionType.Shift,9,29}, {1, LALRActionType.Reduce,10,15}, ] }, 
		 { 25, [{0, LALRActionType.Shift,10,30}, ] }, 
		 { 26, [{0, LALRActionType.Shift,29,24}, {1, LALRActionType.Goto,37,25}, {2, LALRActionType.Goto,39,26}, {3, LALRActionType.Goto,40,31}, {4, LALRActionType.Reduce,23,12}, ] }, 
		 { 27, [{0, LALRActionType.Shift,23,32}, ] }, 
		 { 28, [{0, LALRActionType.Reduce,22,3}, ] }, 
		 { 29, [{0, LALRActionType.Shift,29,24}, {1, LALRActionType.Goto,37,33}, ] }, 
		 { 30, [{0, LALRActionType.Shift,26,34}, {1, LALRActionType.Shift,29,35}, {2, LALRActionType.Shift,32,36}, {3, LALRActionType.Shift,36,37}, {4, LALRActionType.Goto,38,38}, {5, LALRActionType.Goto,50,39}, {6, LALRActionType.Goto,51,40}, ] }, 
		 { 31, [{0, LALRActionType.Reduce,23,11}, ] }, 
		 { 32, [{0, LALRActionType.Reduce,0,2}, {1, LALRActionType.Reduce,24,2}, {2, LALRActionType.Reduce,29,2}, ] }, 
		 { 33, [{0, LALRActionType.Reduce,10,14}, ] }, 
		 { 34, [{0, LALRActionType.Reduce,5,24}, {1, LALRActionType.Reduce,8,24}, {2, LALRActionType.Reduce,9,24}, {3, LALRActionType.Reduce,17,24}, {4, LALRActionType.Reduce,26,24}, {5, LALRActionType.Reduce,29,24}, {6, LALRActionType.Reduce,32,24}, {7, LALRActionType.Reduce,36,24}, ] }, 
		 { 35, [{0, LALRActionType.Shift,7,41}, {1, LALRActionType.Reduce,5,22}, {2, LALRActionType.Reduce,8,22}, {3, LALRActionType.Reduce,9,22}, {4, LALRActionType.Reduce,17,22}, {5, LALRActionType.Reduce,26,22}, {6, LALRActionType.Reduce,29,22}, {7, LALRActionType.Reduce,32,22}, {8, LALRActionType.Reduce,36,22}, ] }, 
		 { 36, [{0, LALRActionType.Shift,6,42}, {1, LALRActionType.Shift,25,43}, {2, LALRActionType.Shift,27,44}, {3, LALRActionType.Shift,28,45}, {4, LALRActionType.Shift,30,46}, {5, LALRActionType.Shift,31,47}, {6, LALRActionType.Shift,33,48}, {7, LALRActionType.Shift,34,49}, {8, LALRActionType.Shift,35,50}, {9, LALRActionType.Goto,49,51}, {10, LALRActionType.Reduce,5,20}, {11, LALRActionType.Reduce,8,20}, {12, LALRActionType.Reduce,9,20}, {13, LALRActionType.Reduce,17,20}, {14, LALRActionType.Reduce,26,20}, {15, LALRActionType.Reduce,29,20}, {16, LALRActionType.Reduce,32,20}, {17, LALRActionType.Reduce,36,20}, ] }, 
		 { 37, [{0, LALRActionType.Reduce,5,23}, {1, LALRActionType.Reduce,8,23}, {2, LALRActionType.Reduce,9,23}, {3, LALRActionType.Reduce,17,23}, {4, LALRActionType.Reduce,26,23}, {5, LALRActionType.Reduce,29,23}, {6, LALRActionType.Reduce,32,23}, {7, LALRActionType.Reduce,36,23}, ] }, 
		 { 38, [{0, LALRActionType.Shift,17,52}, ] }, 
		 { 39, [{0, LALRActionType.Shift,26,34}, {1, LALRActionType.Shift,29,35}, {2, LALRActionType.Shift,32,36}, {3, LALRActionType.Shift,36,37}, {4, LALRActionType.Goto,50,39}, {5, LALRActionType.Goto,51,53}, {6, LALRActionType.Reduce,5,19}, {7, LALRActionType.Reduce,9,19}, {8, LALRActionType.Reduce,17,19}, ] }, 
		 { 40, [{0, LALRActionType.Shift,5,54}, {1, LALRActionType.Goto,41,55}, {2, LALRActionType.Reduce,9,39}, {3, LALRActionType.Reduce,17,39}, ] }, 
		 { 41, [{0, LALRActionType.Shift,8,56}, {1, LALRActionType.Shift,26,34}, {2, LALRActionType.Shift,29,35}, {3, LALRActionType.Shift,32,36}, {4, LALRActionType.Shift,36,37}, {5, LALRActionType.Goto,42,57}, {6, LALRActionType.Goto,50,58}, ] }, 
		 { 42, [{0, LALRActionType.Reduce,5,32}, {1, LALRActionType.Reduce,8,32}, {2, LALRActionType.Reduce,9,32}, {3, LALRActionType.Reduce,17,32}, {4, LALRActionType.Reduce,26,32}, {5, LALRActionType.Reduce,29,32}, {6, LALRActionType.Reduce,32,32}, {7, LALRActionType.Reduce,36,32}, ] }, 
		 { 43, [{0, LALRActionType.Reduce,5,34}, {1, LALRActionType.Reduce,8,34}, {2, LALRActionType.Reduce,9,34}, {3, LALRActionType.Reduce,17,34}, {4, LALRActionType.Reduce,26,34}, {5, LALRActionType.Reduce,29,34}, {6, LALRActionType.Reduce,32,34}, {7, LALRActionType.Reduce,36,34}, ] }, 
		 { 44, [{0, LALRActionType.Reduce,5,29}, {1, LALRActionType.Reduce,8,29}, {2, LALRActionType.Reduce,9,29}, {3, LALRActionType.Reduce,17,29}, {4, LALRActionType.Reduce,26,29}, {5, LALRActionType.Reduce,29,29}, {6, LALRActionType.Reduce,32,29}, {7, LALRActionType.Reduce,36,29}, ] }, 
		 { 45, [{0, LALRActionType.Reduce,5,30}, {1, LALRActionType.Reduce,8,30}, {2, LALRActionType.Reduce,9,30}, {3, LALRActionType.Reduce,17,30}, {4, LALRActionType.Reduce,26,30}, {5, LALRActionType.Reduce,29,30}, {6, LALRActionType.Reduce,32,30}, {7, LALRActionType.Reduce,36,30}, ] }, 
		 { 46, [{0, LALRActionType.Reduce,5,33}, {1, LALRActionType.Reduce,8,33}, {2, LALRActionType.Reduce,9,33}, {3, LALRActionType.Reduce,17,33}, {4, LALRActionType.Reduce,26,33}, {5, LALRActionType.Reduce,29,33}, {6, LALRActionType.Reduce,32,33}, {7, LALRActionType.Reduce,36,33}, ] }, 
		 { 47, [{0, LALRActionType.Reduce,5,35}, {1, LALRActionType.Reduce,8,35}, {2, LALRActionType.Reduce,9,35}, {3, LALRActionType.Reduce,17,35}, {4, LALRActionType.Reduce,26,35}, {5, LALRActionType.Reduce,29,35}, {6, LALRActionType.Reduce,32,35}, {7, LALRActionType.Reduce,36,35}, ] }, 
		 { 48, [{0, LALRActionType.Reduce,5,37}, {1, LALRActionType.Reduce,8,37}, {2, LALRActionType.Reduce,9,37}, {3, LALRActionType.Reduce,17,37}, {4, LALRActionType.Reduce,26,37}, {5, LALRActionType.Reduce,29,37}, {6, LALRActionType.Reduce,32,37}, {7, LALRActionType.Reduce,36,37}, ] }, 
		 { 49, [{0, LALRActionType.Reduce,5,36}, {1, LALRActionType.Reduce,8,36}, {2, LALRActionType.Reduce,9,36}, {3, LALRActionType.Reduce,17,36}, {4, LALRActionType.Reduce,26,36}, {5, LALRActionType.Reduce,29,36}, {6, LALRActionType.Reduce,32,36}, {7, LALRActionType.Reduce,36,36}, ] }, 
		 { 50, [{0, LALRActionType.Reduce,5,31}, {1, LALRActionType.Reduce,8,31}, {2, LALRActionType.Reduce,9,31}, {3, LALRActionType.Reduce,17,31}, {4, LALRActionType.Reduce,26,31}, {5, LALRActionType.Reduce,29,31}, {6, LALRActionType.Reduce,32,31}, {7, LALRActionType.Reduce,36,31}, ] }, 
		 { 51, [{0, LALRActionType.Reduce,5,21}, {1, LALRActionType.Reduce,8,21}, {2, LALRActionType.Reduce,9,21}, {3, LALRActionType.Reduce,17,21}, {4, LALRActionType.Reduce,26,21}, {5, LALRActionType.Reduce,29,21}, {6, LALRActionType.Reduce,32,21}, {7, LALRActionType.Reduce,36,21}, ] }, 
		 { 52, [{0, LALRActionType.Reduce,23,13}, {1, LALRActionType.Reduce,29,13}, ] }, 
		 { 53, [{0, LALRActionType.Reduce,5,18}, {1, LALRActionType.Reduce,9,18}, {2, LALRActionType.Reduce,17,18}, ] }, 
		 { 54, [{0, LALRActionType.Reduce,9,38}, {1, LALRActionType.Reduce,17,38}, ] }, 
		 { 55, [{0, LALRActionType.Shift,9,59}, {1, LALRActionType.Reduce,17,17}, ] }, 
		 { 56, [{0, LALRActionType.Reduce,5,26}, {1, LALRActionType.Reduce,8,26}, {2, LALRActionType.Reduce,9,26}, {3, LALRActionType.Reduce,17,26}, {4, LALRActionType.Reduce,26,26}, {5, LALRActionType.Reduce,29,26}, {6, LALRActionType.Reduce,32,26}, {7, LALRActionType.Reduce,36,26}, ] }, 
		 { 57, [{0, LALRActionType.Shift,8,60}, ] }, 
		 { 58, [{0, LALRActionType.Shift,9,61}, {1, LALRActionType.Reduce,8,28}, ] }, 
		 { 59, [{0, LALRActionType.Shift,26,34}, {1, LALRActionType.Shift,29,35}, {2, LALRActionType.Shift,32,36}, {3, LALRActionType.Shift,36,37}, {4, LALRActionType.Goto,38,62}, {5, LALRActionType.Goto,50,39}, {6, LALRActionType.Goto,51,40}, ] }, 
		 { 60, [{0, LALRActionType.Reduce,5,25}, {1, LALRActionType.Reduce,8,25}, {2, LALRActionType.Reduce,9,25}, {3, LALRActionType.Reduce,17,25}, {4, LALRActionType.Reduce,26,25}, {5, LALRActionType.Reduce,29,25}, {6, LALRActionType.Reduce,32,25}, {7, LALRActionType.Reduce,36,25}, ] }, 
		 { 61, [{0, LALRActionType.Shift,26,34}, {1, LALRActionType.Shift,29,35}, {2, LALRActionType.Shift,32,36}, {3, LALRActionType.Shift,36,37}, {4, LALRActionType.Goto,42,63}, {5, LALRActionType.Goto,50,58}, ] }, 
		 { 62, [{0, LALRActionType.Reduce,17,16}, ] }, 
		 { 63, [{0, LALRActionType.Reduce,8,27}, ] }, 
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
