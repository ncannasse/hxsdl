#ifdef _WIN32
#	include <windows.h>
#	undef RegisterClass
#	define IS_WINDOWS true
#else
#	define IS_WINDOWS false
#	define GL_GLEXT_PROTOTYPES
#endif
#include <GL/GLU.h>
#include <SDL.h>
#include <glext.h>
#define failwith(v)	hx::Throw(HX_CSTRING(v))
#undef main
#undef NO_ERROR

#define LOCAL(e,t)	t e
#define ADDR(e)	&(e)
#define ARR2PTR(a) a.CheckGetPtr()->Pointer()
#define VOIDPTR(v)	((void*)(v))