
module oak.fcgi.VHost ;

import oak.fcgi.all ;

abstract class FCGI_VHost {
	
	package {
		string	_host ;
		FCGI_VHost_Factory* _factory ;
		FCGI_Application[]	apps ;
	}
	
	package void addApplication(FCGI_Application app){
		// Log("%s -> `%s` ", _host, app.path ) ;
		apps	~= app ;
	}
	
	string name() {
		return _host ;
	}
	
	void service(FCGI_Request req, FCGI_Response res) {
		foreach( _app; apps ) {
			if( _app.service(req, res) ) {
				break ;
			}
		}
		// 404 page 
	}
	
	string toString() {
		return _factory.toString ~ _host  ;
	}
	
	string[] getAliaNames() {
		return null ;
	}
}