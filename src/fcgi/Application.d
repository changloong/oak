
module oak.fcgi.Application ;

import oak.fcgi.all ;

abstract class FCGI_Application {
	
	private {
		FCGI_VHost	host ;
		string		path =  "/" ;
		Pool*		pool ;
	}

	this(FCGI_VHost host, string path = null ) in {
		assert(host !is null) ;
	} body {
		this.host	= host ;
		if( path !is null ) {
			this.path	= path ;
		}
		host.addApplication(this) ;
	}

}