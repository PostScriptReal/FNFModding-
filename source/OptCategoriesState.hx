package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import DifficultyIcons;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.ui.FlxUITabMenu;
import lime.system.System;
import lime.app.Event;
import haxe.Json;
import tjson.TJSON;
using StringTools;


class OptCategoriesState extends MusicBeatState
{
    public static var categories:Array<String>;
    var grpAlphabet:FlxTypedGroup<Alphabet>;

    var curSelected:Int = 0;
    var curCategory:String;
    var cmenu:String = '';

    var backyardigans:FlxTypedGroup<FlxSprite>;
    override function create()
    {
    	var menuList = CoolUtil.coolTextFile('assets/data/menupacks.txt');
		cmenu = menuList[OptionsHandler.options.menu];
		var goodSound = FNFAssets.getSound('');
		if (!FlxG.sound.music.playing) {
			if (cmenu == 'default') {
				FlxG.sound.playMusic(FNFAssets.getSound('assets/music/options' + TitleState.soundExt));
			} else {
				FlxG.sound.playMusic(FNFAssets.getSound('assets/images/custom_menus/' + cmenu + '/music&sounds/options' + TitleState.soundExt));
			}
		}

        categories = [ //CoolUtil.coolTextFile('assets/data/categories.txt');
                        'Notes',
                        'Graphics/Performance',
                        'Preferences',
                        'Gameplay',
                        'Modding',
                        'Mods',
                        'Credits'
                     ];

        // Am I funny?????
        backyardigans = new FlxTypedGroup<FlxSprite>();

		for (i in 0...3) {
    		var menuBG:FlxSprite;
            if (cmenu == 'default') {
    			menuBG = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
    			if (OptionsHandler.options.antialiasing != Everything) {
    				menuBG.antialiasing = false;
    			}
    		} else {
    			menuBG = new FlxSprite().loadGraphic('assets/images/custom_menus/' + cmenu + '/main_menus/menuBGBlue.png');
    			if (OptionsHandler.options.antialiasing != Everything) {
    				menuBG.antialiasing = false;
    			}
    		}
            menuBG.color = 0xFF7194fc;
            menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
            menuBG.updateHitbox();
            menuBG.screenCenter();
            menuBG.y = -30;
            var yOffset:Float = menuBG.height - 410;
            if (i != 1) {
                menuBG.y = yOffset * i - 30;
            } else {
                continue;
            }
            menuBG.antialiasing = true;
            add(menuBG);
            backyardigans.add(menuBG);
        }

        grpAlphabet = new FlxTypedGroup<Alphabet>();

        for(category in 0...categories.length){ 
            var awesomeChar = new Alphabet(0, 10, "   "+categories[category], true, false, false);
            awesomeChar.isMenuItem = true;
            awesomeChar.targetY = category;
            grpAlphabet.add(awesomeChar);
        }


        add(grpAlphabet);
        trace("it's 11 pm"); //it's 12 pm

        super.create();

    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (controls.BACK) {
        	FlxG.sound.music.stop();
			LoadingState.loadAndSwitchState(new MainMenuState());
        }
        if (controls.UP_MENU)
        {
            changeSelection(-1);
        }
        if (controls.DOWN_MENU)
        {
            changeSelection(1);
        }

        if (controls.ACCEPT)
            chooseSelection();
    }

    function changeSelection(change:Int = 0)
    {

        FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

        curSelected += change;
        curCategory = categories[curSelected].toString();

        if (curSelected < 0)
            curSelected = categories.length - 1;
        if (curSelected >= categories.length)
            curSelected = 0;

        var curValue = curSelected - 1;

        FlxTween.tween(backyardigans.members[0], {y: -30 + -60 * curSelected}, (0.5), {ease: FlxEase.backInOut});
        FlxTween.tween(backyardigans.members[1], {y: 755 + -60 * curSelected}, (0.5), {ease: FlxEase.backInOut});
        /*for (bg in backyardigans.members) {
            // FlxTween.tween(bg, {y: bg.y + if (change == 1) -600 else 600 * 0.1 * curValue}, (0.5), {ease: FlxEase.backInOut});
            FlxTween.tween(bg, {y: bg.y + moveY * 0.05 * backyardigans.length}, (0.5), {ease: FlxEase.backInOut});
        }*/


        var bullShit:Int = 0;

        for (item in grpAlphabet.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.6;
            // item.setGraphicSize(Std.int(item.width * 0.8));

            if (item.targetY == 0)
            {
                item.alpha = 1;
                // item.setGraphicSize(Std.int(item.width));
            }
        }
    }

    function chooseSelection()
    {
    	if (curCategory == 'Notes') {
            LoadingState.loadAndSwitchState(new NoteOptionsState());
        } else if (curCategory == 'Graphics/Performance') {
    		SaveDataState.graphics = true;
    		LoadingState.loadAndSwitchState(new SaveDataState());
    	} else if (curCategory == 'Preferences') {
    		SaveDataState.preferences = true;
    		LoadingState.loadAndSwitchState(new SaveDataState());
    	} else if (curCategory == 'Gameplay') {
    		SaveDataState.gameplay = true;
    		LoadingState.loadAndSwitchState(new SaveDataState());
    	} else if (curCategory == 'Modding') {
    		SaveDataState.modding = true;
    		LoadingState.loadAndSwitchState(new ModdingWarningState());
    	} else if (curCategory == 'Mods') {
            LoadingState.loadAndSwitchState(new ModLoaderState());
        } else if (curCategory == 'Credits') {
    		LoadingState.loadAndSwitchState(new CreditsState());
    	}
    }
}