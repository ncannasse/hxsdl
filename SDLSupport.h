#ifdef _WIN32
#	include <windows.h>
#	undef RegisterClass
#	define IS_WINDOWS true
#else
#	define IS_WINDOWS false
#endif
#include <GL/GLU.h>
#include <SDL.h>
#define failwith(v)	hx::Throw(HX_CSTRING(v))
#undef main
#undef NO_ERROR

#define LOCAL(e,t)	t e
#define ADDR(e)	&(e)