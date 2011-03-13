
module oak.fcgi.test ;

import oak.fcgi.all ;

version(FCGI_TEST):

public int run (FCGI_Request req){
	auto stdout = req.stdout ;
	
	stdout ("Content-type: text/html\r\n");
	stdout("\r\n");
	stdout ("<html>");
	stdout("<head><title>My first page</title></head>");
        stdout ("<body>");
	
	stdout( "thread_id =")( req.thread_id)  (" <br /> \n") ;
	for(int j =0; j < 40 ;j++) 
	foreach(int i, _field; req.header.tupleof){
		 stdout(j)(" ") ( req.header.key!i() )(" => ")( _field ) (" <br /> \n");
	}
	
	stdout ("</body>");
	stdout ("</html>");
	return 0;
}

void main() {
	auto conn	= new shared(FCGI_Connection)(null, "1983" );
	FCGI_Application.loop!run(conn, true, 2) ;
}
