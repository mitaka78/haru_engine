package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.io.BytesOutput;
import sys.io.File;
import sys.io.FileOutput;

using StringTools;

class PlayState extends FlxState
{
	override public function create()
	{
		var m = new MapFile();
		m.spriteObjects = [new SpriteObject(182, 222, "HelloWorld"), new SpriteObject(72, 72, "Hey!x")];
		m.spriteObjects[0].angle = 83.2;
		m.spriteObjects[1].width = 32.1;
		m.spriteObjects[1].height = 42.3;
		MapFile.dataToFile(m, "assets/data/test.txt");
		var d = MapFile.dataFromFile("assets/data/test.txt");
		new FlxTimer().start(1, _ ->
		{
			for (x in d.spriteObjects)
			{
				trace(x.toString());
				trace(x.graphicPath);
				trace(x.tag);
			}
		});
		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.K)
		{
			FlxG.switchState(new Editor());
		}
		super.update(elapsed);
	}
}
