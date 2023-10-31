package;

import OptionsHandler.FullOptions;
import haxe.ds.Option;
import OptionsHandler.TOptions;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import lime.utils.Assets;
import Controls.KeyboardScheme;
// visual studio code gets pissy when you don't use conditionals
#if sys
import sys.io.File;
#end
import haxe.Json;
import tjson.TJSON;

using StringTools;
typedef TCategoryy = {
	var name:String;
	var intName:String;
	var value:Bool;
	var desc:String;
	var ?ignore:Bool;
	var ?amount:Float;
	var ?defAmount:Float;
	var ?precision:Float;
	var ?max:Float;
	var ?min:Float;
}
class OptCategoriesState extends MusicBeatState
{
	var saves:FlxTypedSpriteGroup<SaveFile>;
	var options:FlxTypedSpriteGroup<Alphabet>;
	var optionMenu:FlxTypedSpriteGroup<FlxSprite>;
	// this will need to be initialized in title state!!!
	public static var optionList:Array<TCategoryy>;
	var curSelected:Int = 0;
	var mappedOptions:Dynamic = {};
	var inOptionsMenu:Bool = true;
	var optionsSelected:Int = 0;
	var checkmarks:FlxTypedSpriteGroup<FlxSprite>;
	var numberDisplays:Array<NumberDisplay> = [];
	var sfxJson:Dynamic = CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json"));
	var musicJson:Dynamic = CoolUtil.parseJson(FNFAssets.getText("assets/music/custom_menu_music/custom_menu_music.json"));
	var preferredSave:Int = 0;
	var description:FlxText;
	var forbiddenIndexes:Array<Int> = [];
	var cmenu:String = '';
	//var cmenucoolstring:Array<String> = [];
	//var cmenucolour:FlxColor = [];
	override function create()
	{
		var menuList = CoolUtil.coolTextFile('assets/data/menupacks.txt');
		cmenu = menuList[OptionsHandler.options.menu];
		/*if (cmenu != 'default') {
			cmenucoolstring = CoolUtil.coolTextFile('assets/images/custom_menus/' + cmenu + '/colours/options.txt');
		}*/
		FlxG.sound.music.stop();
		var goodSound = FNFAssets.getSound('assets/music/options' + TitleState.soundExt);
		if (cmenu != 'default') {
			goodSound = FNFAssets.getSound('assets/images/custom_menus/' + cmenu + '/music&sounds/options' + TitleState.soundExt);
			/*+ musicJson.Options
			+ '/options'
			+ TitleState.soundExt);*/
		} else {
			goodSound = FNFAssets.getSound('assets/music/options' + TitleState.soundExt);
		}
		FlxG.sound.playMusic(goodSound);
		var menuBG:FlxSprite;
		if (cmenu == 'default') {
			menuBG = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
		} else {
			menuBG = new FlxSprite().loadGraphic('assets/images/custom_menus/' + cmenu + '/main_menus/menuBGBlue.png');
		}
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
			optionList = [
							{name: "Graphics", intName: "graphics", value: false, desc: "Got a toaster? Toggle these options to improve performance on your hardware!"},
							{name: "Preferences", intName: "preferences", value: false, desc: "What do you prefer?"},
							{name: "Gameplay", intName: "gameplay", value: false, desc: "Load, save and manage save files for the game."}, 
							{name: "Modding", value: false, intName: "modding", desc: "Options for modding, create new characters, stages, songs and weeks with the help of a graphical interface!"},
						];
		// amount of things that aren't options
		var curOptions:TOptions = OptionsHandler.options;
		for (i in 0...optionList.length) {
			if (optionList[i].ignore)
				continue;
			Reflect.setField(mappedOptions, optionList[i].intName, optionList[i]);
			optionList[i].value = Reflect.field(curOptions, optionList[i].intName);
			if ((Reflect.field(curOptions, optionList[i].intName) is Int) || (Reflect.field(curOptions, optionList[i].intName) is Float)) {
				optionList[i].amount = Reflect.field(curOptions, optionList[i].intName);
				optionList[i].value = optionList[i].amount != optionList[i].defAmount;
			}
		}
		// we use a var because if we don't it will read the file each time
		// although it isn't as laggy thanks to assets
		
		preferredSave = curOptions.preferredSave;
		/*
		optionList[0].value = curOptions.alwaysDoCutscenes;
		optionList[1].value = curOptions.skipModifierMenu;
		optionList[2].value = curOptions.skipVictoryScreen;
		optionList[3].value = curOptions.downscroll;
		optionList[4].value = curOptions.useCustomInput;
		optionList[5].value = curOptions.DJFKKeys;
		optionList[6].value = curOptions.showSongPos;
		*/
		trace("x3");
		checkmarks = new FlxTypedSpriteGroup<FlxSprite>();
		options = new FlxTypedSpriteGroup<Alphabet>();
		optionMenu = new FlxTypedSpriteGroup<FlxSprite>();
		optionMenu.add(options);
		trace("hmmm");
		var curNum = 0;
		for (j in 0...optionList.length) {
			forbiddenIndexes.push(j);
			trace("l53");
			var swagOption = new Alphabet(0,0,optionList[j].name,true,false, false);
			swagOption.isMenuItem = true;
			swagOption.targetY = curNum;
			trace("l57");
			var coolCheckmark:FlxSprite;
			if (cmenu == 'default') {
				coolCheckmark = new FlxSprite().loadGraphic('assets/images/checkmark.png');
			} else {
				coolCheckmark = new FlxSprite().loadGraphic('assets/images/custom_menus/' + cmenu + '/misc/checkmark.png');
			}
			
			var numDisplay = new NumberDisplay(0, 0, optionList[j].defAmount, optionList[j].precision != null ? optionList[j].precision : 1, optionList[j].min != null ? optionList[j].min : 0, optionList[j].max);
			numDisplay.visible = optionList[j].amount != null;
			numberDisplays.push(numDisplay);
			numDisplay.value = optionList[j].amount;
			coolCheckmark.visible = optionList[j].value;
			if (optionList[j].intName == "judge") {
				switch (cast(Std.int(optionList[j].amount) : Judge.Jury))
				{
					case Judge.Jury.Classic:
						numDisplay.text = "Classic";
					case Judge.Jury.Hard:
						numDisplay.text = "Hard";
					default:
						numDisplay.text = optionList[j].amount + 1 + "";
				}
			}
			numDisplay.size = 40;
			numDisplay.x += numDisplay.width + swagOption.width;
			
			checkmarks.add(coolCheckmark);
			swagOption.add(coolCheckmark);
			swagOption.add(numDisplay);
			options.add(swagOption);
			curNum++;
		}
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);
		add(saves);
		add(optionMenu);
		trace("hewwo");
		options.x = 10;
		optionMenu.x = FlxG.width;
		options.y = 10;
		description = new FlxText(750, 150, 350, "", 90);
		description.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		description.text = "Amongus???";
		description.scrollFactor.set();
		optionMenu.add(description);
		changeSelection();
		super.create();
	}
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.UP_MENU)
		{
			changeSelection(-1);
		}
		if (controls.DOWN_MENU)
		{
			changeSelection(1);
		}
		if (controls.BACK) {
			// our current save saves this
			// we are gonna have to do some shenanagins to save our preffered save

			FlxG.sound.music.stop();
			LoadingState.loadAndSwitchState(new MainMenuState());
		}
		// holding control makes changing things go WEEEEEEEEEEE
		if (controls.ACCEPT) {
			switch (optionList[optionsSelected].name) {
				case "Graphics":
					SaveDataState.graphics = true;
					LoadingState.loadAndSwitchState(new SaveDataState());
				case "Preferences":
					SaveDataState.preferences = true;
					LoadingState.loadAndSwitchState(new SaveDataState());
				case "Gameplay":
					SaveDataState.gameplay = true;
					LoadingState.loadAndSwitchState(new SaveDataState());
				case "Modding":
					SaveDataState.modding = true;
					LoadingState.loadAndSwitchState(new SaveDataState());
				case "CoolSwag":
					// do nothing 'cause placeholder
			}
				FlxG.sound.play('assets/sounds/custom_menu_sounds/'
					+ CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuScroll+'/scrollMenu' + TitleState.soundExt);
		}

	}
	function changeAmount(increase:Bool=false) {
		if (!numberDisplays[optionsSelected].visible)
			return;
		numberDisplays[optionsSelected].changeAmount(increase);
		optionList[optionsSelected].amount = Std.int(numberDisplays[optionsSelected].value);
		if (numberDisplays[optionsSelected].value == numberDisplays[optionsSelected].useDefaultValue && optionList[optionsSelected].value) {
			toggleSelection();
		}
		else if (numberDisplays[optionsSelected].value != numberDisplays[optionsSelected].useDefaultValue && !optionList[optionsSelected].value) {
			toggleSelection();
		}
		if (optionList[optionsSelected].intName == "judge") {
			switch (cast (Std.int(optionList[optionsSelected].amount) : Judge.Jury)) {
				case Judge.Jury.Classic:
					numberDisplays[optionsSelected].text = "Classic";
				case Judge.Jury.Hard:
					numberDisplays[optionsSelected].text = "Hard";
				default:
					numberDisplays[optionsSelected].text = optionList[optionsSelected].amount + 1 + "";
			}
		}
		if (optionList[optionsSelected].intName == "preferJudgement") {
			var judgementList = CoolUtil.coolTextFile('assets/data/judgements.txt');
			numberDisplays[optionsSelected].text = judgementList[Std.int(optionList[optionsSelected].amount)];
		}
		if (optionList[optionsSelected].intName == "menu") {
			var menuList = CoolUtil.coolTextFile('assets/data/menupacks.txt');
			numberDisplays[optionsSelected].text = menuList[Std.int(optionList[optionsSelected].amount)];
		}
		if (optionList[optionsSelected].intName == "antialiasing") {
			var antioptList = CoolUtil.coolTextFile('assets/data/antialiasing.txt');
			numberDisplays[optionsSelected].text = antioptList[Std.int(optionList[optionsSelected].amount)];
		}
	}
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play('assets/sounds/custom_menu_sounds/'
			+ CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuScroll+'/scrollMenu' + TitleState.soundExt, 0.4);

		optionsSelected += change;

		if (optionsSelected < 0)
			optionsSelected = options.members.length - 1;
		if (optionsSelected >= options.members.length)
			optionsSelected = 0;


		var bullShit:Int = 0;

		for (item in options.members)
		{
			item.targetY = bullShit - optionsSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		description.text = optionList[optionsSelected].desc;
	}
	function toggleSelection() { 
		switch (optionList[optionsSelected].name)
		{
			case "Graphics":
					SaveDataState.graphics = true;
					LoadingState.loadAndSwitchState(new SaveDataState());
				case "Preferences":
					SaveDataState.preferences = true;
					LoadingState.loadAndSwitchState(new SaveDataState());
				case "Gameplay":
					SaveDataState.gameplay = true;
					LoadingState.loadAndSwitchState(new SaveDataState());
				case "Modding":
					SaveDataState.modding = true;
					LoadingState.loadAndSwitchState(new SaveDataState());
				case "CoolSwag":
					// do nothing 'cause placeholder
		}
	}
}
