package;

import sys.io.File;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
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

/**
 * This typedef is for the necessary data the loader needs to display a mod.
 * It's also used in mod saves since there are some options that need to be defined and used in the algorithm.
**/
typedef LoaderData = {
    var name:String;
    var uses:String;
    var icon:String;
    var desc:String;
    var version:String;
    var replaceSongList:Bool;
    // var isUsing:String;
}
class ModLoaderState extends MusicBeatState
{
    /*public static var categories:Array<String>;
    var grpAlphabet:FlxTypedGroup<Alphabet>;*/
    // var modBG:FlxSprite;
    var funnyArrows:FlxSprite;
    var funnyArrowsTwo:FlxSprite;

    var menuBG:FlxSprite;
    var bgGroup:FlxTypedGroup<FlxSprite>;
    
    // Yay, loader data!
    var modString:String = 'mod';
    /*var icon:FlxSprite;
    var name:FlxText;
    var description:FlxText;
    var versionTxt:FlxText;
    var checkmark:FlxSprite;*/
    
    public static var modsBruh:Array<String>;
    var moddatReader:Array<String>;
    public var savedMod:String;

    var curSelected:Int = 0;
    var curMod:String = 'm++';
    var cmenu:String = '';

    // A special handler... hehe
    public var dataIsCool:LoaderData;
    var saveData:String;
    var modDataJson:Dynamic;
    // var defaultData:Dynamic;
    var noMods:Bool = false;

    var modGroup:FlxTypedGroup<LoaderItem>;
    var firstItemCheck:Bool;
    var noPressListening:Bool = true;
    var noLeft:Bool = false;
    function resetLoaderData()
    {
        // dataIsCool = Reflect.field(defaultData, modString);
        dataIsCool = {
            name: "Modding++",
            uses: "none",
            icon: "M++",
            desc: "Modding PlusPlus",
            version: "0.1.0-devbuild",
            replaceSongList: true
        }
        /*dataIsCool.name = "Modding++";
        dataIsCool.uses = "none";
        dataIsCool.icon = "M++/";
        dataIsCool.desc = "Modding PlusPlus";
        dataIsCool.version = "0.1.0-devbuild";
        dataIsCool.replaceSongList = true;
        // dataIsCool.isUsing = "M++";*/
    }
    function returnDefaultData()
    {
        var dataisSus:LoaderData = {
            name: "Modding++",
            uses: "none",
            icon: "M++",
            desc: "Modding PlusPlus",
            version: "0.1.0-devbuild",
            replaceSongList: true
        }
        return dataisSus;
    }
    override function create()
    {
        firstItemCheck = false;
        // defaultData = CoolUtil.parseJson(FNFAssets.getText('mods/defaultDATA.json'));
        resetLoaderData();
        trace(dataIsCool);
        moddatReader = CoolUtil.coolTextFile('mods/mod/modData.moddat');
        savedMod = moddatReader[1].toString();
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
		modsBruh = CoolUtil.coolTextFile('mods/modList.txt');
        bgGroup = new FlxTypedGroup<FlxSprite>();
        add(bgGroup);
        for (i in 0...modsBruh.length) {
            var menuBGG:FlxSprite;
            if (cmenu == 'default') {
    			menuBGG = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
    			if (OptionsHandler.options.antialiasing != Everything) {
    				menuBGG.antialiasing = false;
    			}
    		} else {
    			menuBGG = new FlxSprite().loadGraphic('assets/images/custom_menus/' + cmenu + '/main_menus/menuBGBlue.png');
    			if (OptionsHandler.options.antialiasing != Everything) {
    				menuBGG.antialiasing = false;
    			}
    		}
            menuBGG.color = 0xFF7194fc;
            // grpAlphabet = new FlxTypedGroup<Alphabet>();
            menuBGG.updateHitbox();
            menuBGG.screenCenter();
            var xx:Float = menuBGG.width + 124;
            if (firstItemCheck) {
                menuBGG.x = xx * i;
            }
            menuBGG.setGraphicSize(Std.int(menuBGG.width * 1.1));
            add(menuBGG);
            bgGroup.add(menuBGG);
            firstItemCheck = true;
        }
        firstItemCheck = false;
        modGroup = new FlxTypedGroup<LoaderItem>();
        add(modGroup);
        for (i in 0...modsBruh.length) {
            var stringy:String = modsBruh[i].toString();
            var reset:Bool = false;
            var trueStringy:String = modsBruh[i].toString();
            switch(stringy) {
                case 'm++':
                    reset = true;
            }
            var tempData:Dynamic = [];
            if (!reset) {
                tempData = CoolUtil.parseJson(FNFAssets.getText('mods/'+ stringy +'DATA.json'));
            }
            var daMod:LoaderData;
            if (reset) {
                daMod = returnDefaultData();
            } else {
                daMod = Reflect.field(tempData, modString);
            }
            var newMod:LoaderItem;
            if (daMod.uses != savedMod) {
                newMod = new LoaderItem(0, 0, daMod.name, daMod.icon, daMod.desc, daMod.version, daMod.uses, false);
            } else {
                newMod = new LoaderItem(0, 0, daMod.name, daMod.icon, daMod.desc, daMod.version, daMod.uses, true);
            }
            if (firstItemCheck) {
                newMod.daOffset(600 * i);
            }
            /*if (daMod.uses == savedMod) {
                newMod.showCheckmark(true);
                newMod.checkmarkCheck = true;
            } else {
                newMod.showCheckmark(false);
            }*/
            modGroup.add(newMod);
            firstItemCheck = true;
        }
        noPressListening = false;
        // I just realised how stupid this line of code was
        // I'm so duuuuuuummmmmbbbb!!
        /*modBG = new FlxSprite().loadGraphic('assets/images/ModBG.png');
        if (cmenu == 'default') {
            modBG = new FlxSprite().loadGraphic('assets/images/ModBG.png');
            if (OptionsHandler.options.antialiasing != Everything) {
                modBG.antialiasing = false;
            }
        } else {
            modBG = new FlxSprite().loadGraphic('assets/images/custom_menus/' + cmenu + '/save_data/ModBG.png');
            if (OptionsHandler.options.antialiasing != Everything) {
                modBG.antialiasing = false;
            }
        }
        I'M EVEN MORE STUPIDER THAN I JUST THOUGHT I WAS AAAAAAAAAAAAAA!!!!
        /*if (OptionsHandler.options.antialiasing == Everything) {
            modBG.antialiasing = true;
        }
        modBG.updateHitbox();
        modBG.screenCenter();
        modBG.alpha -= 0.3;
        modBG.y = FlxG.height + 25;
        add(modBG);*/
        var tex = FlxAtlasFrames.fromSparrow('', '');
        
        funnyArrows = new FlxSprite();
        tex = FlxAtlasFrames.fromSparrow('assets/images/funnyarrows.png', 'assets/images/funnyarrows.xml');
        funnyArrows.frames = tex;
        funnyArrows.animation.addByPrefix('idle', "idle", 24);
        funnyArrows.animation.addByPrefix('select', "HahaArrowGoWeeeeeeeeee", 48);
        funnyArrows.animation.play('idle');
        funnyArrows.screenCenter();
        funnyArrows.x = FlxG.width - 87;
        funnyArrows.y = FlxG.height - 826;
        funnyArrowsTwo = new FlxSprite();
        funnyArrowsTwo.frames = tex;
        funnyArrowsTwo.animation.addByPrefix('idle', "idle", 24);
        funnyArrowsTwo.animation.addByPrefix('select', "HahaArrowGoWeeeeeeeeee", 48);
        funnyArrowsTwo.animation.play('idle');
        funnyArrowsTwo.flipX = true;
        funnyArrowsTwo.screenCenter();
        funnyArrowsTwo.x = FlxG.width - 1255;
        funnyArrowsTwo.y = FlxG.height - 826;
        if (!noMods) {
            add(funnyArrows);
            add(funnyArrowsTwo);
        }
        /*icon = new FlxSprite().loadGraphic(Paths.icon(dataIsCool.icon, '/Icon'));//(modBG.x + 200, modBG.y + 300);
        add(icon);
        name = new FlxText(69420, 69420, 490, dataIsCool.name, 69);
        name.setFormat("assets/fonts/vcr.ttf", 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        add(name);
        description = new FlxText(69420, 69420, 490, dataIsCool.desc, 69);
        description.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(description);
        versionTxt = new FlxText(69420, 69420, 250, dataIsCool.version, 69);
        versionTxt.setFormat("assets/fonts/vcr.ttf", 15, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        add(versionTxt);
        checkmark = new FlxSprite().loadGraphic('assets/images/checkmark.png');
        checkmark.x = 825;
        checkmark.y = 400;
        add(checkmark);
        if (savedMod == 'm++') {
            checkmark.visible = false;
            new FlxTimer().start(1, function(tmr)
            {
                checkmark.visible = true;
            });
        } else {
            checkmark.visible = false;
        }*/

        super.create();

    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (modsBruh.length == 1) {
            noMods = true;
        } else if (modsBruh.length == 0) {
            // what the hell did you just do ya bastard!?
            LoadingState.loadAndSwitchState(new OptCategoriesState());
            // you're going to crash the game doing this
        }

        /*icon.x = modBG.x + 100;
        icon.y = modBG.y + 50;
        name.x = modBG.x + 5;
        name.y = icon.y + 210;
        description.x = modBG.x + 20;
        description.y = name.y + 30;
        versionTxt.x = icon.x + 15;
        versionTxt.y = FlxG.height - modBG.y - 10;
        checkmark.x = modBG.width * 1.65;
        checkmark.y = modBG.height - 200;
        FlxTween.tween(modBG, {y: FlxG.height / 12}, (1.2), {ease: FlxEase.expoInOut});*/
        if (!noMods) {
          FlxTween.tween(funnyArrows, {y: FlxG.height / 2.25}, (1.2), {ease: FlxEase.expoInOut});
          FlxTween.tween(funnyArrowsTwo, {y: FlxG.height / 2.25}, (1.2), {ease: FlxEase.expoInOut});  
        }

        /*for (moddies in modGroup.members) {
            if (moddies.checkmarkCheck) {
                moddies.showCheckmark(true);
            }
        }*/
        
        if (curSelected == 0) {
            // noOverStep = true;
            noLeft = true;
        }
        
        if (controls.BACK) {
			LoadingState.loadAndSwitchState(new OptCategoriesState());
        }
        if (controls.LEFT_MENU && !noMods && !noPressListening && !noLeft)
        {
            changeSelection(-1);
        }
        if (controls.RIGHT_MENU && !noMods && !noPressListening)
        {
            changeSelection(1);
        }

        if (controls.ACCEPT)
            chooseSelection();
    }

    function playAnim() {
        funnyArrowsTwo.animation.play('select');
        funnyArrowsTwo.offset.set(19, 0);
        new FlxTimer().start(0.1666666666666667, function(tmr)
        {
            funnyArrowsTwo.animation.play('idle');
            funnyArrowsTwo.offset.set(0, 0);
        });
    }

    function changeSelection(change:Int = 0)
    {
        FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);
        if (change == -1) {
            playAnim();
        } else {
            funnyArrows.animation.play('select');
            new FlxTimer().start(0.1666666666666667, function(tmr)
            {
                funnyArrows.animation.play('idle');
            });
        }
        var moveX:Int;
        var noOverStep:Bool = false;

        moveX = 0;
        if (change == -1 && !noLeft) {
            moveX = 600;
        } else if (change == -1 && curSelected == 0) {
            moveX = 0;
        } else if (change == 1) {
            moveX = -600;
        }

        curSelected += change;
        curMod = modsBruh[curSelected].toString();

        if (curSelected < 0)
            curSelected = modGroup.length - 1;
            noLeft = false;
        if (curSelected >= modGroup.length) {
            var curValue = curSelected - 1;
            for (moddies in modGroup.members) {
                noPressListening = true;
                moddies.tweenToX(600 * curValue, 0.5);
                for (bg in bgGroup.members) {
                    FlxTween.tween(bg, {x: bg.x + 600 * 0.1 * modGroup.length * curValue}, (0.5), {ease: FlxEase.backInOut});
                }
                new FlxTimer().start(0.5, function(tmr)
                {
                    noPressListening = false;
                });
            }
            curSelected = 0;
            curMod = 'm++';
            resetLoaderData();
            noOverStep = true;
            noLeft = true;
        }
        /*if (curSelected == 0) {
            noOverStep = true;
            noLeft = true;
        }
        trace('Selected: '+curSelected);
        trace('Change: '+change);*/
        if (!noOverStep) {
            for (moddies in modGroup.members) {
                noPressListening = true;
                moddies.tweenToX(moveX, 0.5);
                // meth
                for (bg in bgGroup.members) {
                    FlxTween.tween(bg, {x: bg.x + moveX * 0.1 * modGroup.length}, (0.5), {ease: FlxEase.backInOut});
                }
                new FlxTimer().start(0.5, function(tmr)
                {
                    noPressListening = false;
                });
            }
        }
        // trace(curMod);
        if (curMod != null && curMod != 'm++') {
            modDataJson = CoolUtil.parseJson(FNFAssets.getText("mods/"+ curMod +"DATA.json"));
            // trace(modDataJson);
            dataIsCool = Reflect.field(modDataJson, 'mod');
            // trace(dataIsCool);
            /*if (dataIsCool.name != "") {
                name.text = dataIsCool.name;
            } else {
                name.text = "No name";
            }
            if (FNFAssets.exists('mods/Icons/'+ dataIsCool.icon + '/' +'Icon.png')) {
                trace(dataIsCool.icon);
                icon.loadGraphic('mods/Icons/'+ dataIsCool.icon + '/' +'Icon.png', false, 300, 200, true);
            } else {
                icon.loadGraphic('mods/Icons/M++/nullreference.png');
            }
            // icon.loadGraphic(Paths.icon('M++', 'missing'));
            if (dataIsCool.desc != "") {
                description.text = dataIsCool.desc;
            } else {
                description.text = "No description";
            }
            if (dataIsCool.version != "") {
                versionTxt.text = dataIsCool.version;
            } else {
                versionTxt.text = "69.69.69";
            }*/
        } else {
            resetLoaderData();
            /*icon.loadGraphic(Paths.icon(dataIsCool.icon, '/Icon'));
            name.text = dataIsCool.name;
            description.text = dataIsCool.desc;
            versionTxt.text = dataIsCool.version;*/
        }
        /*if (curMod == savedMod) {
            checkmark.visible = true;
        } else {
            checkmark.visible = false;
        }*/

        // var bullShit:Int = 0;

       /* for (item in grpAlphabet.members)
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
        }*/
    }

    function chooseSelection()
    {
        if (curMod != null && curMod != 'm++') {
            modDataJson = CoolUtil.parseJson(FNFAssets.getText("mods/"+ curMod +"DATA.json"));
            dataIsCool = Reflect.field(modDataJson, modString);
            if (dataIsCool.uses != "") {
                save_mod_strings();
                // checkmark.visible = true;
            } else {
                throw "Please add a 'uses' argument to the mod's data.\nThe program will automatically shut down to prevent the game from breaking!";
            }
        } else {
            resetLoaderData();
            save_mod_strings();
            // checkmark.visible = true;
        }
    }
    function booltoString(bool:Bool) {
        var stringconverter:String;
        stringconverter = '' + bool;
        return stringconverter;
    }
    function save_mod_strings() {
        var rsl:String;
        /* Bool to string conversion!
           I need to do this because the saveData variable will only accept strings :P.*/
        rsl = booltoString(dataIsCool.replaceSongList);
        saveData = curMod +"\n"+ dataIsCool.uses +"\n"+ rsl;
        // #if sys
        File.saveContent('mods/mod/modData.moddat', saveData);
        moddatReader = CoolUtil.coolTextFile('mods/mod/modData.moddat');
        savedMod = moddatReader[0].toString();
        /* #else
        FlxG.save.data.mods = saveData;
        #end*/
    }
}