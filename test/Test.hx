import sdl.GL;

class Test {

	static function main() {
		trace("INIT");
		sdl.Sdl.init();
		var win = new sdl.Window("Hello", 800, 600);
		win.vsync = true;

		var oldTime = haxe.Timer.stamp();
		var fps = 60.;
		var spentTime = 0.;
		sdl.Sdl.loop(function() {
			GL.clearColor(Math.random(), 0, 0, 1);
			GL.clear(GL.COLOR_BUFFER_BIT);
			win.present();
			var newTime = haxe.Timer.stamp();
			var realFPS = 1 / (newTime - oldTime);
			spentTime += newTime - oldTime;
			oldTime = newTime;
			fps = fps * 0.98 + realFPS * 0.02;
			if( spentTime > 1 ) {
				trace("FPS = " + fps);
				spentTime -= 1;
			}
		});

		win.destroy();
		sdl.Sdl.quit();
		trace("DONE");
	}

}