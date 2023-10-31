package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import flash.display.BitmapData;
#end
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
class LoaderItem extends FlxSpriteGroup
{
	var modBG:FlxSprite;
	var name:FlxText;
	var icon:FlxSprite;
	var noCustomIcon:Bool = false;
	var desc:FlxText;
	var versionTxt:FlxText;
	var checkmark:FlxSprite;
	// public var modNum:Int;
	// public var checkmarkCheck:Bool = false;
	var modUses:String;

	// var saveData:Array<String>;
    var chkmrkVisibility:Bool = false;

	var cmenu:String = '';

	public function new(x:Float, y:Float, namee:String, iconPath:String, description:String, version:String, uses:String, checkmarkVisible:Bool)
	{
		var menuList = CoolUtil.coolTextFile('assets/data/menupacks.txt');
		cmenu = menuList[OptionsHandler.options.menu];

		super(x, y);

		// saveData = CoolUtil.coolTextFile('mods/mod/modData.moddat');

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
		modBG.updateHitbox();
        modBG.screenCenter();
        modBG.alpha -= 0.3;
        modBG.y = FlxG.height + 25;
        add(modBG);
        name = new FlxText(69420, 69420, 490, namee, 69);
        name.setFormat("assets/fonts/vcr.ttf", 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        add(name);
        // Loading the graphic directly without making raw bitmap data appears to have issues...
        var rawPic = FNFAssets.getBitmapData("mods/Icons/"+ iconPath +"/Icon.png");
        switch (iconPath) {
        	case 'M++':
        		icon = new FlxSprite().loadGraphic('mods/Icons/M++/Icon.png');
        		noCustomIcon = true;
        }
        if (!noCustomIcon) {
            if (FNFAssets.exists('mods/Icons/'+ iconPath +'/Icon.png')) {
                icon = new FlxSprite();
                icon.loadGraphic(rawPic);
            } else {
                rawPic = FNFAssets.getBitmapData("mods/Icons/M++/nullreference.png");
                icon = new FlxSprite();
                icon.loadGraphic(rawPic);
            }
	        
	    }
        trace(Paths.icon(iconPath, '/Icon'));
        // icon.loadGraphic(Paths.icon('M++', 'missing'));
        add(icon);
        desc = new FlxText(69420, 69420, 490, description, 69);
        desc.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(desc);
        versionTxt = new FlxText(69420, 69420, 250, version, 69);
        versionTxt.setFormat("assets/fonts/vcr.ttf", 15, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        add(versionTxt);
        checkmark = new FlxSprite().loadGraphic('assets/images/checkmark.png');
        if (checkmarkVisible) {
            add(checkmark);
            chkmrkVisibility = true;
        }
        modUses = uses;
	}

	public function daOffset(x:Float) {
		modBG.x += x;
		checkmark.x += x;
	}

	public function showCheckmark(booly:Bool) {
		this.chkmrkVisibility = booly;
        if (booly) {
            add(checkmark);
        } else {
            remove(checkmark);
        }
	}

    public function chkmrkVisible() {
        return this.chkmrkVisibility;
    }

	/*public function delayedCheckmark() {
        new FlxTimer().start(1, function(tmr)
        {
        	checkmark.visible = true;
        });
	}*/
	
	public function tweenToX(xy:Float, time:Float) {
		FlxTween.tween(modBG, {x: modBG.x + xy}, (time), {ease: FlxEase.smoothStepInOut});
		FlxTween.tween(checkmark, {x: checkmark.x + xy}, (time), {ease: FlxEase.smoothStepInOut});
	}

	override function update(elapsed:Float)
	{
		trace('Is checkmark visible? '+ checkmark.visible+'!');
		super.update(elapsed);
		icon.x = modBG.x + 100;
        icon.y = modBG.y + 50;
        name.x = modBG.x + 5;
        name.y = icon.y + 210;
        desc.x = modBG.x + 20;
        desc.y = name.y + 30;
        versionTxt.x = icon.x + 15;
        versionTxt.y = FlxG.height - modBG.y - 20;
        checkmark.x = modBG.x - 165;
        checkmark.y = modBG.y - 341.5833333333333;
        /*trace('ModBG X: '+modBG.x);
        trace('ModBG Y: '+modBG.y);
        trace('Checkmark X: '+checkmark.x);
        trace('Checkmark Y: '+checkmark.y);
        if (checkmarkCheck) {
        	checkmark.visible = true;
        }*/
        FlxTween.tween(modBG, {y: Std.int(FlxG.height / 12)}, (1.2), {ease: FlxEase.expoInOut});
	}
}
