module oka.test ;

import oak.all  ;
import std.process ;

class User {
	bool 	login = false;
	bool 	admin ;
	int	id  = 3001 ;
	string 	name = "<Chang Long>" ;
	
	int opApply(scope int delegate(ref char[] line, ref int o) dg){
		return 0;
	}
	
	final int opApply(scope int delegate(ref char[] line) dg){
		return 0;
	}
	
}

struct User2 {
	bool 	login = false;
	bool 	admin ;
	int	id  = 3001 ;
	string 	name = "<Chang Long>" ;
	
	
	int opApply(scope int delegate(ref char[]) dg){
		return 0;
	}
	
	int opApply(scope int delegate(ref string, ref string) dg) {
		return 0;
	}
}


class MyApp : FCGI_Application {
	
	alias Tpl!("UserList", __FILE__, __LINE__) MyTpl ;
	MyTpl	tpl ;
	User	u ;
	string	page_title	= "test page"[] ;
	vBuffer bu ;
	string[string] env ;
	
	this(){
		tpl	= new MyTpl ;
		u	= new User ;
		
		tpl.assign!("user", __FILE__, __LINE__)(u);
		
		auto u2 = new User2 ;
		tpl.assign!("user2", __FILE__, __LINE__)( *u2 ) ;
		
		tpl.assign!("page_title", __FILE__, __LINE__)( page_title );
		
		tpl.assign!("env", __FILE__, __LINE__)(environment.toAA);
		
		env	= environment.toAA ;
		bu	= new vBuffer(1024 * 32, 1024 * 512 ) ;
	}
	
	bool service(FCGI_Request req, FCGI_Response res) {

		auto stdout = res.stdout ;
		
		StopWatch sw;
		sw.start;
		
		u.login	= !u.login ;
		u.id ++ ;
		if( u.id % 3 is 0 ) {
			u.admin	= !u.admin ;
		}
		int[] test_i = [1, 3, 4];
		
		tpl.assign!"test_i"( test_i );
		
		tpl.assign!"req"( req );
		
		tpl.assign!"env"( env );
		
		
		mixin Tpl_Jade!("./example.jade", typeof(tpl) , __FILE__, __LINE__) jade ;
		
		auto obj	= jade.compile(tpl);

		for( int i =0; i < 1 ; i++) {
			bu.clear;
			assert(bu.length is 0);
			obj.render(bu);
			assert( bu.capability < 1024 * 1024 * 12 );
		}
		
		sw.stop;
		
		auto header = res.header ;
		header ("Content-type: text/html\r\n");
		header ("RenderTime: ")(sw.peek.msecs)("ms\r\n");
		header ("Content-Length: ")( bu.length)("\r\n");
		header("\r\n");
		
		stdout(bu.slice);
		
		bu.clear;
		
		return true ;
	}
	
}


void main() {

	FCGI_Dispatch fcgi ;
	fcgi.Listen(":1983\0");
	fcgi.Dispatch!(MyApp);
	log("FastcCGI Server 127.0.0.1:1983");
	fcgi.Loop();
}