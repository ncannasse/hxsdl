package sdl;

class Window implements NativeWrapper {

	var win : SDL_Window;

	public function new( title : String, width : Int, height : Int ) {
		win = SDL_CreateWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
		if( win == NULL ) failwith("Failed to create window");
	}

	public function destroy() {
		SDL_DestroyWindow(win);
		win = NULL;
	}

}