
module oak.fcgi.Dispatch ;

import oak.fcgi.all ;

struct FCGI_Dispatch {
	
	fcgi_fd	_fd ;
	
	
	void Init(string socket_s){
		FCGX_Init() ;
		_fd	= FCGX_OpenSocket(toStringz(socket_s), 10);
	}
	
}