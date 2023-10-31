package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import Controls.Control;

class ModdingWarningState extends FlxState
{
	var warning:FlxText;
	override public function create()
	{
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		if (OptionsHandler.options.antialiasing != Everything) {
			bg.antialiasing = false;
		}
		add(bg);
		warning = new FlxText(10, 360 - 40, FlxG.width - 20,
		"Warning! Modding options are outdated and may completely break the game if used."
		+ " I am not liable for any damage these may cause on your mod."
		+ " Press Enter to continue or press Escape to go back.",
		32);
		warning.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		add(warning);
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			LoadingState.loadAndSwitchState(new SaveDataState());
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			SaveDataState.modding = false;
			LoadingState.loadAndSwitchState(new OptCategoriesState());
		}
		super.update(elapsed);

	}
}
