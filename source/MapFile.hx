package;

import flixel.util.FlxColor;
import haxe.io.Encoding;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

class MapFile
{
	public var bgColor:Int;
	public var spriteObjects:Array<SpriteObject> = [];

	public function new() {}

	public inline function toFile(path:String)
	{
		dataToFile(this, path);
	}

	public inline function fromFile(path:String)
	{
		var d = dataFromFile(path);
		bgColor = d.bgColor;
		spriteObjects = d.spriteObjects;
		d = null;
	}

	public static function dataToFile(mapFile:MapFile, path:String)
	{
		var f = File.write(path);
		f.writeInt32(mapFile.bgColor);
		f.writeInt32(mapFile.spriteObjects.length);
		for (so in mapFile.spriteObjects)
		{
			writeSpriteObject(so, f);
		}
		f.flush();
		f.close();
	}

	public static function dataFromFile(path:String)
	{
		var m:MapFile = new MapFile();
		var f = File.read(path);
		m.bgColor = f.readInt32();
		var l = f.readInt32();
		m.spriteObjects = [];
		for (i in 0...l)
		{
			var so = readSpriteObject(f);
			m.spriteObjects[i] = so;
		}
		f.close();
		return m;
	}

	static function writeSpriteObject(so:SpriteObject, b:FileOutput)
	{
		b.writeFloat(so.x);
		b.writeFloat(so.y);
		b.writeFloat(so.width);
		b.writeFloat(so.height);
		b.writeFloat(so.scale.x);
		b.writeFloat(so.scale.y);
		b.writeFloat(so.angle);
		b.writeFloat(so.alpha);
		b.writeInt32(so.color);
		b.writeByte(so.visible ? 1 : 0);
		b.writeByte(so.immovable ? 1 : 0);
		b.writeByte(so.flipX ? 1 : 0);
		b.writeByte(so.flipY ? 1 : 0);
		b.writeByte(so.graphicPath.length);
		b.writeString(so.graphicPath, Encoding.UTF8);
		b.writeByte(so.tag.length);
		b.writeString(so.tag, Encoding.UTF8);
	}

	static function readSpriteObject(b:FileInput)
	{
		var so = new SpriteObject(0, 0);
		so.x = b.readFloat();
		so.y = b.readFloat();
		so.width = b.readFloat();
		so.height = b.readFloat();
		so.scale.x = b.readFloat();
		so.scale.y = b.readFloat();
		so.angle = b.readFloat();
		so.alpha = b.readFloat();
		so.color = b.readInt32();
		so.visible = b.readByte() != 0;
		so.immovable = b.readByte() != 0;
		so.flipX = b.readByte() != 0;
		so.flipY = b.readByte() != 0;
		var l = b.readByte();
		so.graphicPath = b.readString(l, Encoding.UTF8);
		var l = b.readByte();
		so.tag = b.readString(l, Encoding.UTF8);
		return so;
	}

	public function toString()
	{
		return '(bgColor: ${bgColor} | sprites: ${spriteObjects.length})';
	}
}
