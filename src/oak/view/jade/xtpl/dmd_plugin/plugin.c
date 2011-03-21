
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#if DOS386
#include <dos.h>
#include <sys\stat.h>
#endif

#if linux || __APPLE__ || __FreeBSD__ || __sun&&__SVR4
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <pthread.h>
#include <dlfcn.h>
#elif	_WIN32
#include <dos.h>
#include <sys\stat.h>
#include	<windows.h>
#endif

#include "mars.h"
#include "root.h"

// os_error from backend/os.c
void os_error(int line);
#define os_error() os_error(__LINE__)
#pragma noreturn(os_error)


#ifdef __cplusplus
extern "C" {
#endif
	typedef size_t (*plugin_lib_import_fn)(char*, char**,void**) ;
	typedef size_t (*plugin_lib_export_fn)(size_t, void*) ;
	
	static plugin_lib_import_fn plugin_lib_import ;
	static plugin_lib_export_fn plugin_lib_export ;
	static bool	dmd_xtpl_loaded	= false ;
#ifdef __cplusplus
}
#endif

#if _WIN32

static	HINSTANCE plugin_hdll ;
void plugin_export_dmd_data();

bool plugin_load() {
	dmd_xtpl_loaded	= true ;
	plugin_hdll	= LoadLibrary("dmd_xtpl.dll");
	if (!plugin_hdll) {
		printf("load dmd_xtpl error \n");
       		os_error();
	}
	// load plugin_lib_export
	plugin_lib_export	=  (plugin_lib_export_fn) GetProcAddress(plugin_hdll, "plugin_lib_export");
	if( !plugin_lib_export ) {
		printf("load dmd_xtpl.plugin_lib_export error \n");
		return false ;
	}
	
	plugin_export_dmd_data();
	
	// load plugin_lib_import
	plugin_lib_import	= (plugin_lib_import_fn) GetProcAddress(plugin_hdll, "plugin_lib_import");
	if( !plugin_lib_import ) {
		printf("load dmd_xtpl.plugin_lib_import error \n");
		return false ;
	}
	return true ;
}

#endif

#if linux || __APPLE__ || __FreeBSD__ || __sun&&__SVR4

static	void* plugin_hdll ;

bool plugin_load() {
	dmd_xtpl_loaded	= true ;
	plugin_hdll	= dlopen( "dmd_xtpl.so", 2 );
	if (!plugin_hdll) {
		printf("load dmd_xtpl error \n");
       		os_error();
	}
	// load plugin_lib_export
	plugin_lib_export	=  (plugin_lib_export_fn) dlsym(plugin_hdll, "plugin_lib_export");
	if( !plugin_lib_export ) {
		printf("load dmd_xtpl.plugin_lib_export error \n");
		return false ;
	}

	plugin_export_dmd_data();
	
	// load plugin_lib_import
	plugin_lib_import	= (plugin_lib_import_fn) dlsym(plugin_hdll, "plugin_lib_import");
	if( !plugin_lib_import ) {
		printf("load dmd_xtpl.plugin_lib_import error \n");
		return false ;
	}
	return true ;
}

#endif

void plugin_export_dmd_data(){
	
	plugin_lib_export(0, stdout ) ;
	plugin_lib_export(1, fflush ) ;
	plugin_lib_export(2, fprintf ) ;
	
	for (int i = 0; i < global.filePath->dim; i++){
		void *path	= (void *) global.filePath->data[i];
		plugin_lib_export(3,  path) ;
	}
	
	// global.params.isX86_64
	plugin_lib_export(4, (void*) global.params.isX86_64 ) ;
}

size_t plugin_import(/* in */char* name, /* out */ char** dname, /* out */ void** d_source){
	if( !dmd_xtpl_loaded ){
		if( !plugin_load()  ) {
			return 0 ;
		}
	}
	return plugin_lib_import(name, dname, d_source) ;	
}
