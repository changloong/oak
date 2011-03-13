module oak.fcgi.Exception ;

import oak.fcgi.all ;

class FCGI_ProtocolException : StreamException {
    this (string msg)
    {
        super (msg);
    }
}

class FCGI_AbortException : StreamException {
    this () {
        super ("Server aborted request");
    }
}
