package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import lime.utils.Assets;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var cmenu:String = '';

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Change Options', 'Change Modifiers', 'Exit to menu'];
	var menuItems2ElectricBoogaloo:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Change Options', 'Change Modifiers', 'Exit to menu'];
	var difficultyChoices:Array<String> = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	public static var difficultyDat:Array<String> = CoolUtil.coolTextFile("assets/images/custom_difficulties/difficultiesStuff.txt");

	public function new(x:Float, y:Float)
	{
		// So, I'm gonna try to optimise the hell out of my code so the pause menu loads faster.
		super();
		var menuList = CoolUtil.coolTextFile('assets/data/menupacks.txt');
		cmenu = menuList[OptionsHandler.options.menu];

		// I finally learnt how Arrays work...
		for (i in 0...difficultyDat.length) {
			var diff:String = '' + difficultyDat[i].toString();
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		if (cmenu == 'default' || cmenu != 'default' && !FNFAssets.exists('assets/images/custom_menus/' + cmenu + '/music&sounds/breakfast' + TitleState.soundExt)) {
			pauseMusic = new FlxSound().loadEmbedded('assets/music/breakfast' + TitleState.soundExt, true, true);
		} else {
			if (FNFAssets.exists('assets/images/custom_menus/' + cmenu + '/music&sounds/breakfast' + TitleState.soundExt)) {
				pauseMusic = new FlxSound().loadEmbedded('assets/images/custom_menus/' + cmenu + '/music&sounds/breakfast' + TitleState.soundExt, true, true);
			}
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(2*FlxG.width, 2*FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_MENU;
		var downP = controls.DOWN_MENU;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			
			for (i in 0...difficultyChoices.length-1) {
				if(difficultyChoices[i] == daSelected) {
					var name:String = PlayState.SONG.song.toLowerCase();
					var poop = Highscore.formatDifficulty(name, curSelected);
					trace(poop);
					if (FNFAssets.exists('assets/data/'
						+ name + '/' + poop + '.json')) {
						PlayState.SONG = Song.loadFromJson(poop, name);
						PlayState.storyDifficulty = curSelected;
						FlxG.resetState();
						//MusicBeatState.resetState();
						FlxG.sound.music.volume = 0;
					}
					return;
				}
			}
			// Porting code is weird.

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					PlayState.flushData();
					PlayState.cutsceneSkip = true;
					if (PlayState.isStoryMode) {
						LoadingState.loadAndSwitchState(new StoryMenuState());
					} else {
						LoadingState.loadAndSwitchState(new FreeplayState());
					}
				case "Change Modifiers":
					LoadingState.loadAndSwitchState(new ModifierState());
				case "Change Options":
					LoadingState.loadAndSwitchState(new OptCategoriesState());
				case "Change Difficulty":
					menuItems = difficultyChoices;
					regenMenu();
				case 'BACK':
					menuItems = menuItems2ElectricBoogaloo;
					regenMenu();
				// Yes, the Change Difficulty code is from Psych Engine's source, sue me.
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.stop();
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
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

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
	// Lightweight!
}
