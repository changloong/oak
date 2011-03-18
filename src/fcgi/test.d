module oak.fcgi.test ;


version(FCGI_TEST) :

import oak.fcgi.all ;


class MyApp : FCGI_Application {
	
	
	bool service(FCGI_Request req, FCGI_Response res) {
		
		foreach( string k, string v; req.header ) {
			res.stdout(k)("=>")(v)("\n") ;
		}
		
		return true ;
	}
	
}

void main(char[][] args){
	
	FCGI_Dispatch fcig  ;
	fcig.Listen(":1983\0");
	
	fcig.Dispatch!(MyApp)() ;
	
	fcig.Loop();
}