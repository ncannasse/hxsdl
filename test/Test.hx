class Test {

	static function main() {
		trace("INIT");
		sdl.Sdl.init();
		var win = new sdl.Window("Hello", 800, 600);
		sdl.Sdl.delay(1000);
		win.destroy();
		sdl.Sdl.quit();
		trace("DONE");
	}

}