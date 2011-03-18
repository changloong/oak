module oak.fcgi.test ;


version(FCGI_TEST) :

import oak.fcgi.all ;


void main(char[][] args){
	
	FCGI_Dispatch dispatch ;
	dispatch.Listen(":1983\0");
	
	dispatch.setDefaultService( (FCGI_Request req, FCGI_Response res){
		res.stdout("Content-Type: text/plain\r\n");
		
		res.stdout("\r\n");
		
		foreach(string key, value; req.header ) {
			res.stdout(key)(" => ") (value)("\n") ;
		}
		
	});
	dispatch.Loop();
}