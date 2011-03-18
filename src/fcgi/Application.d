
module oak.fcgi.Application ;

import oak.fcgi.all ;

abstract class FCGI_Application {
	
	private {
		FCGI_VHost	_host ;
		string		_path =  "/" ;
	}

	void Init(FCGI_VHost host, string path = null ) in {
		assert(host !is null) ;
	} body {
		_host	= host ;
		if( path !is null ) {
			_path	= path ;
		}
		_host.addApplication(this) ;
	}
	
	string path(){
		return _path ;
	}
	
		
	abstract bool service(FCGI_Request req, FCGI_Response res) ;

}