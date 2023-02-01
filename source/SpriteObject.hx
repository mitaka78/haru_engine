package;

import flixel.FlxSprite;

class SpriteObject extends FlxSprite
{
	public var tag:String;
	public var graphicPath:String = "0";

	public function new(x, y, ?tag:String)
	{
		super(x, y);
		this.tag = tag;
	}
}
