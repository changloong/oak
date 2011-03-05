module fcgi4d.Base ;


extern (C)
{
	private alias int fd_type ;
	private alias ptrdiff_t byte_size ;
	
	void OS_ShutdownPending ();
	byte_size OS_Write (fd_type fd, const void* buffer, byte_size size);
	byte_size OS_Read (fd_type fd, void* buffer, byte_size size);
	bool OS_IsFcgi (fd_type fd);
	void OS_IpcClose (fd_type fd);
	fd_type OS_CreateLocalIpcFd (const(char)* path, byte_size backlog);
	byte_size OS_LibInit (fd_type* stdioFileDescriptors);
	fd_type OS_Accept (fd_type listenSock, bool failOnInterrupt, const(char)* webServerAddressList);
}
