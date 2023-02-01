package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUISlider;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class Editor extends FlxState
{
	var map:MapFile;
	var spriteObjects:FlxTypedGroup<SpriteObject>;
	var UI:FlxSprite;
	var UI_itemSelectedGroup:FlxTypedGroup<FlxSprite>;
	var UI_noneSelectedGroup:FlxTypedGroup<FlxSprite>;

	public function new(?data:MapFile)
	{
		super();
		if (data != null)
			map = data;
		else
			map = new MapFile();
	}

	public override function create()
	{
		super.create();
		spriteObjects = new FlxTypedGroup<SpriteObject>();
		UI_itemSelectedGroup = new FlxTypedGroup<FlxSprite>();
		UI_noneSelectedGroup = new FlxTypedGroup<FlxSprite>();

		UI = new FlxSprite().makeGraphic(Std.int(FlxG.width / 5), FlxG.height, FlxColor.GRAY);
		add(UI);

		UI.scrollFactor.set();

		UI_itemSelectedGroup.memberAdded.add(s ->
		{
			s.scrollFactor.set();
		});

		UI_noneSelectedGroup.memberAdded.add(s ->
		{
			s.scrollFactor.set();
		});

		add(UI_noneSelectedGroup);
		add(UI_itemSelectedGroup);

		genItemSelectedGroup();
	}

	var xStepper:FlxUINumericStepper;
	var yStepper:FlxUINumericStepper;
	var scaleXStepper:FlxUINumericStepper;
	var scaleYStepper:FlxUINumericStepper;
	var angleSlider:FlxSlider;
	var alphaSlider:FlxSlider;
	var colorInput:FlxInputText;
	var visibleCheckbox:FlxUICheckBox;
	var immovableCheckbox:FlxUICheckBox;
	var flipXCheckbox:FlxUICheckBox;
	var flipYCheckbox:FlxUICheckBox;
	var tagInput:FlxInputText;
	var loadImageButton:FlxButton;
	var teleportToButton:FlxButton;

	inline static var SIXTY = 60;

	function genItemSelectedGroup()
	{
		xStepper = new FlxUINumericStepper(10, 30, 1, 0, -99999, 99999, 2);
		yStepper = new FlxUINumericStepper(80, 30, 1, 0, -99999, 99999, 2);
		scaleXStepper = new FlxUINumericStepper(10, xStepper.y + SIXTY, 1, 1, 0.01, 100, 2);
		scaleYStepper = new FlxUINumericStepper(80, xStepper.y + SIXTY, 1, 1, 0.01, 100, 2);
		UI_itemSelectedGroup.add(new FlxText(xStepper.x, xStepper.y - 20, 0, "X Pos", 12));
		UI_itemSelectedGroup.add(xStepper);
		UI_itemSelectedGroup.add(new FlxText(yStepper.x, yStepper.y - 20, 0, "Y Pos", 12));
		UI_itemSelectedGroup.add(yStepper);
		UI_itemSelectedGroup.add(new FlxText(scaleXStepper.x, scaleXStepper.y - 20, 0, "X Scale", 12));
		UI_itemSelectedGroup.add(scaleXStepper);
		UI_itemSelectedGroup.add(new FlxText(scaleYStepper.x, scaleYStepper.y - 20, 0, "Y Scale", 12));
		UI_itemSelectedGroup.add(scaleYStepper);
	}

	function attachThingToMouse(o:FlxObject)
		o.setPosition(FlxG.mouse.x, FlxG.mouse.y);

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
