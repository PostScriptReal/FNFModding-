package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
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
class MenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var daFlash:Bool = false;
	// CHAOS CONTROL!
	public var flashCtrl:Int = 0;
	var susWeek:Int = 0;
	var coolswitch:Int = 0;
	var doCoolSwitch:Bool = false;

	public function new(x:Float, y:Float, weekNum:Int = 0)
	{
		super(x, y);
		// WHAT THE FUCK
		// IS THIS :GRIEF:
		// WHY THE FUCK DO YOU READ A FILE FUCKING 5 TIMES
		// NO WONDER THERE ARE PREFORMANCE ISSUE
		
		var parsedWeekJson:StoryMenuState.StorySongsJson = CoolUtil.parseJson(FNFAssets.getJson("assets/data/storySongList"));
		var rawPic = FNFAssets.getBitmapData('assets/images/campaign-ui-week/week'+weekNum+".png");
		
		var rawXml:String = "";
		if (FNFAssets.exists('assets/images/campaign-ui-week/week' + weekNum + ".xml")) {
			rawXml = FNFAssets.getText('assets/images/campaign-ui-week/week' + weekNum + ".xml");
		}
		if (rawXml != "") {
			var tex = FlxAtlasFrames.fromSparrow(rawPic, rawXml);
			var animName:String = "";
			if (parsedWeekJson.version == 1)
			{
				animName = parsedWeekJson.songs[weekNum][0];
			}
			if (parsedWeekJson.version == 2)
			{
				animName = parsedWeekJson.weeks[weekNum].animation;
			}
			week = new FlxSprite();
			if (OptionsHandler.options.antialiasing != Everything) {
				week.antialiasing = false;
			}
			week.frames = tex;
			// TUTORIAL IS WEEK 0
			week.animation.addByPrefix("default", animName, 24);
			add(week);

			week.animation.play('default');
			week.animation.pause();
			week.updateHitbox();
		} else {
			week.loadGraphic(rawPic);
			add(week);
			week.updateHitbox();
		}
		susWeek = weekNum;
		
	}

	// Don't be like Lego Island and tie stuff to the framerate.
	// This only needs to be done because you can change the game's fps cap.
	// Btw, this is Kade Engine's code (maybe the code for the og fnf too.)
	var magic:Int = Math.round((1 / FlxG.elapsed) / 10);
	// If you can't tell already, i'm not really experienced in coding per se.
	
	public function flashyFlash()
	{
		daFlash = true;
		var json:StoryMenuState.StorySongsJson = CoolUtil.parseJson(FNFAssets.getJson("assets/data/storySongList"));
		if (json.weeks[susWeek].flshColor != null && json.weeks[susWeek].flshColor.length != 1) {
			doCoolSwitch = true;
		}
	}

	override function update(elapsed:Float)
	{
		var weekJson:StoryMenuState.StorySongsJson = CoolUtil.parseJson(FNFAssets.getJson("assets/data/storySongList"));
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 120) + 480, 0.17 / (CoolUtil.fps / 60));
	
		if (doCoolSwitch && flashCtrl % magic >= Math.floor(magic / 2)) {
			coolswitch += 1;
		}
		
		if (doCoolSwitch && coolswitch >= weekJson.weeks[susWeek].flshColor.length) {
			coolswitch = 0;
		}
		
		if (daFlash)
			flashCtrl += 1;

		if (flashCtrl % magic >= Math.floor(magic / 2))
			if (weekJson.weeks[susWeek].flshColor == null) {
				week.color = 0xFF33ffff;
			} else {
				if (doCoolSwitch) {
					week.color = FlxColor.fromString(weekJson.weeks[susWeek].flshColor[coolswitch]);
				} else {
					week.color = FlxColor.fromString(weekJson.weeks[susWeek].flshColor[0]);
				}
			}
		// One problem with stealing code from other projects:
		/* The code won't be compatible with whatever you're working with.
		   So you have to do your best to make things work!*/
		else // if (FlxG.save.data.flashing)
			week.color = FlxColor.WHITE;
	}
}
