package sdl;

class Sdl implements NativeWrapper {

	public static function init() {
		if( SDL_Init(SDL_INIT_EVERYTHING ) != 0 ) failwith("Failed to init SDL");
	}

	public static function quit() {
		SDL_Quit();
	}

	public static function delay(time:Int) {
		SDL_Delay(time);
	}

}