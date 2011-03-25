module oak.langs.scss.Token;

import oak.langs.scss.Scss ;

struct Tok {
	
	enum Type {
		None ,
		Eof ,
		CommentLine ,
		CommentBlock ,
		
		// css 
		
		PathStart ,
		PathEnd ,
		
		BodyStart ,
		BodyEnd ,
		
		AttrStart ,
		AttrEnd ,
		ValueStart ,
		ValueEnd ,
		
		// scss
		VarName ,
		VarStart ,
		VarEnd ,
		
		Var ,
		
		MixName ,
		MixParamsStart ,
		MixParamName ,
		MixParamValue ,
		MixParamsEnd ,
		
		MixCall , // @mixin my_fun(12px);
		FunCall ,  //  @hsl(123, 456, 456) ;
		FunArgStart,
		FunArgEnd ,
		
		Extend ,
		If ,
		ElseIf ,
		Else ,
		
		ForVar ,
		ForFrom ,
		ForTo ,
		ForStep ,
		WhileExp ,
		
		iExpStart , // #{$var_name} ,
		iExpEnd ,
		
		ExpStart , // 11px + 12px * 3
		ExpEnd ,  // 2px - $width ;
		
		// css & scss
		Number ,
		String ,
		qStringStart ,
		qStringEnd ,
		ParentPath , // &
	}
	
	

}
