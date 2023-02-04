package;

import flixel.FlxCamera;
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
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import openfl.display.Bitmap;
import openfl.display.Graphics;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.events.Event;
import openfl.filters.ShaderFilter;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef FR = FileReference;

class Editor extends FlxState
{
	var map:MapFile;
	var spriteObjects:FlxTypedGroup<SpriteObject>;
	var UI:FlxSprite;
	var UI_itemSelectedGroup:FlxTypedGroup<FlxSprite>;
	var UI_noneSelectedGroup:FlxTypedGroup<FlxSprite>;
	var selected:SpriteObject;

	var fromNewImage:Bool = false;

	var UIcam:FlxCamera;

	var fromLoadImage:Bool = false;

	public static var projectPath:String = "test";

	public function new(?data:MapFile, ?projectPath:String = "test")
	{
		super();
		if (data != null)
			map = data;
		else
			map = new MapFile();

		Editor.projectPath = projectPath;
		if (!FileSystem.exists('projects/' + Editor.projectPath))
		{
			Project.make(Editor.projectPath);
		}
	}

	public override function create()
	{
		super.create();

		spriteObjects = new FlxTypedGroup<SpriteObject>();
		UI_itemSelectedGroup = new FlxTypedGroup<FlxSprite>();
		UI_noneSelectedGroup = new FlxTypedGroup<FlxSprite>();

		add(spriteObjects);

		UIcam = new FlxCamera();
		FlxG.cameras.add(UIcam);

		UI = new FlxSprite().makeGraphic(Std.int(FlxG.width / 5), FlxG.height, FlxColor.GRAY);
		add(UI);
		UI.cameras = [UIcam];

		UI.scrollFactor.set();

		UI_itemSelectedGroup.memberAdded.add(s ->
		{
			s.cameras = [UIcam];
			s.scrollFactor.set();
		});

		UI_noneSelectedGroup.memberAdded.add(s ->
		{
			s.cameras = [UIcam];
			s.scrollFactor.set();
		});

		add(UI_noneSelectedGroup);
		add(UI_itemSelectedGroup);

		genNoneSelectGroup();
		genItemSelectedGroup();
		UI_itemSelectedGroup.kill();
	}

	var inputTexts:Array<FlxInputText> = [];
	var numericSteppers:Array<FlxUINumericStepper> = [];

	var bgColorInput:FlxInputText;
	var bgColorApply:FlxButton;
	var newImageButton:FlxButton;

	function genNoneSelectGroup()
	{
		bgColorInput = new FlxInputText(10, 30, 60, "", 12);
		bgColorApply = new FlxButton(bgColorInput.x + bgColorInput.width + 10, 30, "Apply", () ->
		{
			map.bgColor = Std.parseInt('0xFF' + bgColorInput.text);
		});

		newImageButton = new FlxButton(10, bgColorInput.y + 30, "New Image", () ->
		{
			loadImage();
			fromNewImage = true;
			fromLoadImage = false;
		});

		inputTexts.push(bgColorInput);

		UI_noneSelectedGroup.add(new FlxText(10, 10, 0, "BG color", 12));
		UI_noneSelectedGroup.add(bgColorInput);
		UI_noneSelectedGroup.add(newImageButton);
	}

	var xStepper:FlxUINumericStepper;
	var yStepper:FlxUINumericStepper;
	var scaleXStepper:FlxUINumericStepper;
	var scaleYStepper:FlxUINumericStepper;
	var angleStepper:FlxUINumericStepper;
	var alphaStepper:FlxUINumericStepper;
	var colorInput:FlxInputText;
	var colorApplyButton:FlxButton;
	var visibleCheckbox:FlxUICheckBox;
	var immovableCheckbox:FlxUICheckBox;
	var flipXCheckbox:FlxUICheckBox;
	var flipYCheckbox:FlxUICheckBox;
	var tagInput:FlxInputText;
	var loadImageButton:FlxButton;

	function genItemSelectedGroup()
	{
		xStepper = new FlxUINumericStepper(10, 30, 1, 0, -99999, 99999, 2);
		yStepper = new FlxUINumericStepper(80, 30, 1, 0, -99999, 99999, 2);
		scaleXStepper = new FlxUINumericStepper(10, xStepper.y + 60, 1, 1, 0.01, 100, 2);
		scaleYStepper = new FlxUINumericStepper(80, xStepper.y + 60, 1, 1, 0.01, 100, 2);

		angleStepper = new FlxUINumericStepper(10, scaleXStepper.y + 60, 1, 0, -360, 360, 2);

		alphaStepper = new FlxUINumericStepper(80, angleStepper.y, .1, 1, 0, 1, 2);

		colorInput = new FlxInputText(10, alphaStepper.y + 60, 60, "", 12);
		colorApplyButton = new FlxButton(colorInput.x + colorInput.width + 10, colorInput.y, "Apply", () ->
		{
			if (colorInput.text.length > 0)
				selected.color = Std.parseInt('0xFF' + colorInput.text.replace('#', ''));
			else
				selected.color = FlxColor.WHITE;
		});

		visibleCheckbox = new FlxUICheckBox(10, colorInput.y + 60, null, null, "Visible", 50);
		visibleCheckbox.callback = () ->
		{
			selected.isVisible = !selected.isVisible;
		};

		immovableCheckbox = new FlxUICheckBox(80, visibleCheckbox.y, null, null, "Immovable", 76);
		immovableCheckbox.callback = () ->
		{
			selected.immovable = !selected.immovable;
		};

		flipXCheckbox = new FlxUICheckBox(10, visibleCheckbox.y + 30, null, null, "Flip X", 50);
		flipXCheckbox.callback = () ->
		{
			selected.flipX = !selected.flipX;
		};

		flipYCheckbox = new FlxUICheckBox(80, flipXCheckbox.y, null, null, "Flip Y", 50);
		flipYCheckbox.callback = () ->
		{
			selected.flipY = !selected.flipY;
		};

		tagInput = new FlxInputText(10, flipYCheckbox.y + 60, 120, "", 12);

		loadImageButton = new FlxButton(10, tagInput.y + 40, "Load Image", () ->
		{
			loadImage();

			fromNewImage = false;
			fromLoadImage = true;
		});

		inputTexts.push(colorInput);
		inputTexts.push(tagInput);

		numericSteppers = [xStepper, yStepper, scaleXStepper, scaleYStepper, angleStepper, alphaStepper];

		UI_itemSelectedGroup.add(new FlxText(xStepper.x, xStepper.y - 20, 0, "X Pos", 12));
		UI_itemSelectedGroup.add(xStepper);
		UI_itemSelectedGroup.add(new FlxText(yStepper.x, yStepper.y - 20, 0, "Y Pos", 12));
		UI_itemSelectedGroup.add(yStepper);
		UI_itemSelectedGroup.add(new FlxText(scaleXStepper.x, scaleXStepper.y - 20, 0, "X Scale", 12));
		UI_itemSelectedGroup.add(scaleXStepper);
		UI_itemSelectedGroup.add(new FlxText(scaleYStepper.x, scaleYStepper.y - 20, 0, "Y Scale", 12));
		UI_itemSelectedGroup.add(scaleYStepper);
		UI_itemSelectedGroup.add(new FlxText(angleStepper.x, angleStepper.y - 20, 0, "Angle", 12));
		UI_itemSelectedGroup.add(angleStepper);
		UI_itemSelectedGroup.add(new FlxText(alphaStepper.x, alphaStepper.y - 20, 0, "Alpha", 12));
		UI_itemSelectedGroup.add(alphaStepper);
		UI_itemSelectedGroup.add(new FlxText(colorInput.x, colorInput.y - 20, 0, "Color (#RRGGBB)", 12));
		UI_itemSelectedGroup.add(colorInput);
		UI_itemSelectedGroup.add(colorApplyButton);
		UI_itemSelectedGroup.add(visibleCheckbox);
		UI_itemSelectedGroup.add(immovableCheckbox);
		UI_itemSelectedGroup.add(flipXCheckbox);
		UI_itemSelectedGroup.add(flipYCheckbox);
		UI_itemSelectedGroup.add(new FlxText(tagInput.x, tagInput.y - 20, 0, "Tag", 12));
		UI_itemSelectedGroup.add(tagInput);
		UI_itemSelectedGroup.add(loadImageButton);
	}

	function updateUIValues()
	{
		xStepper.value = selected.x;
		yStepper.value = selected.y;
		scaleXStepper.value = selected.scale.x;
		scaleYStepper.value = selected.scale.y;
		angleStepper.value = selected.angle;
		alphaStepper.value = selected.alphaVal;
		colorInput.text = StringTools.hex(selected.color);
		visibleCheckbox.checked = selected.isVisible;
		immovableCheckbox.checked = selected.immovable;
		flipXCheckbox.checked = selected.flipX;
		flipYCheckbox.checked = selected.flipY;
		tagInput.text = selected.tag;
	}

	function attachThingToMouse(o:FlxObject, offsetX:Float = 0, offsetY:Float = 0)
		o.setPosition(FlxG.mouse.x + offsetX, FlxG.mouse.y + offsetY);

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (selected != null)
		{
			if (!UI_itemSelectedGroup.alive)
			{
				updateUIValues();
				UI_itemSelectedGroup.revive();
				UI_noneSelectedGroup.kill();
			}

			selected.x = xStepper.value;
			selected.y = yStepper.value;
			selected.scale.x = scaleXStepper.value;
			selected.scale.y = scaleYStepper.value;
			selected.angle = angleStepper.value;
			selected.alphaVal = alphaStepper.value;
			selected.alpha = selected.alphaVal + .1;
			selected.updateHitbox();
		}
		else
		{
			if (UI_itemSelectedGroup.alive)
			{
				UI_itemSelectedGroup.kill();
				UI_noneSelectedGroup.revive();
			}
		}

		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(spriteObjects) && !FlxG.mouse.overlaps(UI, UIcam))
		{
			spriteObjects.forEach(function(so)
			{
				if (FlxG.mouse.overlaps(so))
					selected = so;
			});
		}
		else if (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(spriteObjects) && !FlxG.mouse.overlaps(UI, UIcam))
		{
			selected = null;
		}
	}

	function loadImage()
	{
		var fr:FR = new FR();
		fr.addEventListener(Event.SELECT, loadImage_onSelect, false, 0, true);
		fr.browse([
			new FileFilter("PNG files", "*.png"),
			new FileFilter("JPEG files", "*.jpg;*.jpeg;")
		]);
	}

	function loadImage_onSelect(e:Event)
	{
		var fr:FR = cast(e.target, FR);
		fr.addEventListener(Event.COMPLETE, loadImage_onComplete, false, 0, true);
		fr.load();
	}

	function loadImage_onComplete(e:Event)
	{
		var fr:FR = cast(e.target, FR);
		fr.removeEventListener(Event.COMPLETE, loadImage_onComplete);

		trace(fr);
		trace(fr.name);

		var p = 'projects/$projectPath/export/images/${fr.name}';
		var file = File.write(p, true);
		file.write(fr.data);
		file.flush();
		file.close();

		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadImage_onImageLoad);
		loader.loadBytes(fr.data);
	}

	function loadImage_onImageLoad(e:Event)
	{
		var loaderInfo:LoaderInfo = cast(e.target, LoaderInfo);
		loaderInfo.removeEventListener(Event.COMPLETE, loadImage_onImageLoad);
		var bmp = cast(loaderInfo.content, Bitmap);

		if (fromNewImage)
		{
			var so = new SpriteObject(0, 0, "");
			so.width = bmp.width;
			so.height = bmp.height;
			so.pixels = bmp.bitmapData.clone();
			bmp.bitmapData.dispose();
			spriteObjects.add(so);
			so.screenCenter();
			selected = so;
		}
		else
		{
			selected.width = bmp.width;
			selected.height = bmp.height;
			selected.pixels = bmp.bitmapData.clone();
			bmp.bitmapData.dispose();
		}
	}
}
