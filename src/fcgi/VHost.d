
module oak.fcgi.VHost ;

import oak.fcgi.all ;

abstract class FCGI_VHost {
	
	package{
		string	host ;
		Pool*	pool ;
	}
	
	this(string host = null) {
		host	= host ;
	}
	
	package void addApplication(FCGI_Application app){
		
	}

}