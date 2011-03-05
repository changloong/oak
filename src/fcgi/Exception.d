module fcgi4d.Exception ;

import fcgi4d.all ;

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
