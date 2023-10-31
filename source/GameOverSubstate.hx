package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.system.System;
import lime.utils.Assets;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end
import haxe.Json;
import tjson.TJSON;
using StringTools;
class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Character;
	var camFollow:FlxObject;

	var stageSuffix:String = "";
	// var daStage = PlayState.curStage;
	var isJeff:Bool;
	var daUI:Judgement.TUI;

	var gameOverList:Array<String> = [];
	var trueList:Array<String> = [];
	var daRNG:Int;

	public function new(x:Float, y:Float)
	{
		var p1 = PlayState.SONG.player1;
		// hscript means everything is custom
		// and they don't  fucking lose their shit if 
		// they don't have the proper animation
		var daBf:String = p1 + '-dead';
		trace(p1);

		daUI = Reflect.field(Judgement.uiJson, PlayState.SONG.uiType);

		isJeff = daUI.jeffGameOver;
		trace('Is Jeff: '+ isJeff +'!');
		if (isJeff) {
			gameOverList = CoolUtil.coolTextFile('assets/images/custom_ui/ui_packs/'+ daUI.uses +'/GameOverList.txt');
		}
		var naughtyCheck:Bool = false;
		if (isJeff) {
			for (i in 0...gameOverList.length) {
				var trueString:String = gameOverList[i].toString();
				trace('miniString: '+ trueString);
				if (!OptionsHandler.options.hahanaughty && StringTools.endsWith(trueString, '--N')) {
					// Replace doesn't work with an empty string so i'm doing this instead!
					// StringTools.replace(trueString, "--N", "");
					trueString = trueString.substring(0, trueString.length - 3);
				} else if (OptionsHandler.options.hahanaughty && StringTools.endsWith(trueString, '--N')) {
					naughtyCheck = true;
				}
				if (!naughtyCheck) {
					trueList.push(trueString);
				}
				naughtyCheck = false;
			}
			trace('Original List: '+gameOverList);
			trace('True List: '+trueList);
		}
		if (isJeff) {
			daRNG = FlxG.random.int(0, trueList.length - 1);
			trace('Random number: '+ daRNG);
		}
		
		super();
		Conductor.songPosition = 0;

		bf = new Character(x, y, daBf, true);
		// : )
		bf.beingControlled = true;
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);
		if (bf.isPixel)
			stageSuffix = "-pixel";
		if (daUI.customGameOver[1]) {
			FlxG.sound.play(FNFAssets.getSound('assets/sounds/game_over/'+ daUI.uses +'/fnf_loss_sfx' + stageSuffix + TitleState.soundExt));
		} else {
			if (stageSuffix != "") {
				FlxG.sound.play(FNFAssets.getSound('assets/sounds/game_over/pixel/fnf_loss_sfx-pixel' + TitleState.soundExt));
			} else {
				FlxG.sound.play(FNFAssets.getSound('assets/sounds/game_over/normal/fnf_loss_sfx' + TitleState.soundExt));
			}
		}
		// FlxG.sound.play('assets/sounds/fnf_loss_sfx' + stageSuffix + TitleState.soundExt);
		
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				LoadingState.loadAndSwitchState(new StoryMenuState());
			else
				LoadingState.loadAndSwitchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			/* You're probably wondering why I did this. This is because haxeflixel is dumb-dumb stupid
			   and can't play music that isn't the original game-over music */
			switch (daUI.uses) {
				case 'normal': 
					FlxG.sound.playMusic('assets/music/game_over/normal/gameOver' + TitleState.soundExt);
				default:
					if (daUI.customGameOver[0]) {
						FlxG.sound.playMusic(FNFAssets.getSound('assets/music/game_over/'+ daUI.uses +'/gameOver' + stageSuffix + TitleState.soundExt));
					} else {
						if (stageSuffix != "") {
							FlxG.sound.playMusic('assets/music/game_over/pixel/gameOver-pixel' + TitleState.soundExt);
						} else {
							FlxG.sound.playMusic('assets/music/game_over/normal/gameOver' + TitleState.soundExt);
						}
					}
			}
			// My brain hurts from trying to read the decompiled week 7 code.
			// Update: OMG I found someone who actually made the decompiled code into actual readable haxe code.
			// THANKS SO MUCH ANGELDTF YOU'RE A LIFE-SAVER! https://github.com/AngelDTF.
			if (isJeff) {
				FlxG.sound.music.volume = 0.2;
				trace('assets/images/custom_ui/ui_packs/'+ daUI.uses +'/jeffGameover/'+ trueList[daRNG].toString() +'.ogg');
				FlxG.sound.play('assets/images/custom_ui/ui_packs/'+ daUI.uses +'/jeffGameover/'+ trueList[daRNG].toString() +'.ogg', 1, false, null, true, function() {
					FlxG.sound.music.fadeIn(4, 0.2, 1);
					trace('Completed dialogue');
				});
			}
		}
		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			PlayState.cutsceneSkip = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			switch (daUI.uses) {
				case 'normal': 
					FlxG.sound.play('assets/music/game_over/normal/gameOverEnd' + TitleState.soundExt);
				default:
					if (daUI.customGameOver[0]) {
						FlxG.sound.play(FNFAssets.getSound('assets/music/game_over/'+ daUI.uses +'/gameOverEnd' + stageSuffix + TitleState.soundExt));
					} else {
						if (stageSuffix != "") {
							FlxG.sound.play('assets/music/game_over/pixel/gameOverEnd-pixel' + TitleState.soundExt);
						} else {
							FlxG.sound.play('assets/music/game_over/normal/gameOverEnd' + TitleState.soundExt);
						}
					}
			}
			
				
			
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
