module oak.fcgi.test ;


version(FCGI_TEST) :

import oak.fcgi.all ;



    const size_t THREADS = 4 ;

    int main(char[][] args)
    {
        size_t totalRequests = 0;
        Thread threads[THREADS];

        int socket = 0;

        // Initialize FastCGI Library
        FCGX_Init();

        // If a path is passed in, open a socket to it
        if (args.length > 1)
        {
            socket = FCGX_OpenSocket(toStringz(args[1]), 10);

            if (socket < 0)
                throw new ErrnoException("FCGX_OpenSocket");
        } else {
	   socket = FCGX_OpenSocket(":1983\0".ptr, 10);
	}

        // Spawn some threads (the quick & dirty scripty way)
        foreach (ref thread; threads)
        {
            thread = new Thread(
            {
                // Initialize the per-thread request
                size_t nr = 0;
                FCGX_Request request;
                request.init(socket);

                // request loop
                while(request.accept())
                {
		    scope(exit){
			request.outStream.flush ;
		    }
                    size_t nrTotal;
                    nr++;

                    // this is synchronized access to the global totalRequests
                    synchronized
                    {
                        totalRequests++;
                        nrTotal = totalRequests;
                    }

                    // Output some crap                    
                    request.outStream.putstr("Content-Type: text/html\r\n\r\n");
                    request.outStream.putstr("<html><head><title>D FastCGI Test</title></head>");
                    request.outStream.putstr("<body><h1>D FastCGI Test</h1>");
                    request.outStream.putstr(format("<h2>Thread Request #%s<br/>", nr));
                    request.outStream.putstr(format("Total Requests %s</h2><hr/>", nrTotal));

                    request.outStream.putstr("<table>");

                    // This is the ugly C way of walking the params
                    char** param = request.envp;
                    while (*param !is null)
                    {
                        // find the equals sign
                        int eq = 0;
                        while ((*param)[eq] != '\0' && (*param)[eq] != '=')
                            eq++;

                        int end = eq;
                        while ((*param)[end] != '\0')
                            end++;

                        char[] key = (*param)[0..eq];
                        char[] value = (*param)[eq+1..end];

                        request.outStream.putstr(format("<tr><td>%s</td><td>%s</td></tr>", key, value));

                        param++;
                    }

                    request.outStream.putstr("</table></body></html>");
                }
            });

            thread.start();
        }

        thread_joinAll();

        return 0;
    }