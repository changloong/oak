//: \$dmd2 \+..\src\view\jade \-..\src\view\jade\xtpl \+..\src\util 


import oak.view.jade.Jade ;

void main(string[] args ){
	string file = `attr.jade`;
	auto data = cast(string) std.file.read(file);
	
	ptrdiff_t count = 1 ;
        if( args.length > 1 ) {
                count = ctfe_a2i( args[1] );
        }

	StopWatch sw;
	sw.start;
	scope(exit){
		sw.stop;
		writefln("%d times use time = %dms", count, sw.peek.msecs );
	}
	
	Compiler cc ;
	
	for(ptrdiff_t i =0 ; i < count ; i++) {
		cc.Init(file, data) ;
		auto code	= cc.compile ;
		if( i is 0  ){
			writefln(code);
			cc.parser.dump_tok ;
		}
	}
	
}
