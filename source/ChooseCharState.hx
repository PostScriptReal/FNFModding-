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
import flixel.addons.ui.FlxUITabMenu;
import lime.system.System;
import lime.app.Event;
import haxe.Json;
import tjson.TJSON;
using StringTools;


class ChooseCharState extends MusicBeatState
{
    public static var characters:Array<String>;
    var char:Character;
    var anim:String = PlayState.SONG.player1;
    var grpAlphabet:FlxTypedGroup<Alphabet>;

    var curSelected:Int = 0;
    var curChar:String = PlayState.SONG.player1;

    var dadMenu:Bool = false;


    public function new(anim:String = "bf")
    {
        super();
        this.anim = anim;
    }

    override function create()
    {
        var menuBG:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
        menuBG.color = 0xFFea71fd;
        grpAlphabet = new FlxTypedGroup<Alphabet>();
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        if (OptionsHandler.options.antialiasing != Everything) {
            menuBG.antialiasing = false;
        } else {
            menuBG.antialiasing = true;
        }
        add(menuBG);

        var charJson:Dynamic = null;

        char = new Character(400, 100, anim);
        if (OptionsHandler.options.antialiasing == None) {
            char.antialiasing = false;
        }
        add(char);

        char.flipX = false;


    
        charJson = CoolUtil.parseJson(FNFAssets.getJson('assets/images/custom_chars/custom_chars'));

        if (characters == null) {
            // that is not how arrays work
            // characters = mergeArray(Reflect.fields(charJson), Reflect.fields(regCharacters)); // this doesn't work, try to make this work or just ignore it
            // reg characters should be first
            characters = Reflect.fields(charJson);
        }


        var none = new Alphabet(0, 10, "   None", true, false, false);
        for(character in 0...characters.length){ //add chars
            var awesomeChar = new Alphabet(0, 10, "   "+characters[character], true, false, false);
            awesomeChar.isMenuItem = true;
            awesomeChar.targetY = character;
            grpAlphabet.add(awesomeChar);
            none.targetY = character;
        }
        grpAlphabet.add(none);

        add(grpAlphabet);
        trace("it's 11 pm"); //it's 12 pm

        super.create();

    }
    // i'd recommend moving smth like this to coolutil but w/e
    function mergeArray(base:Dynamic, ext:Dynamic){ //need this to combine regular chars and customs, CHANGE THIS if you know a better way
        var res = Reflect.copy(base);
        for(f in Reflect.fields(ext)) Reflect.setField(res,f,Reflect.field(res,f));
        return res;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (controls.BACK) {
			LoadingState.loadAndSwitchState(new ModifierState());
        }
        if (controls.UP_MENU)
        {
            changeSelection(-1);
        }
        if (controls.DOWN_MENU)
        {
            changeSelection(1);
        }

        if (controls.RIGHT_MENU || controls.LEFT_MENU) {
                swapMenus();
        }

        if (controls.ACCEPT)
            chooseSelection();
    }

    function changeSelection(change:Int = 0)
    {

        FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

        curSelected += change;
        curChar = characters[curSelected].toString();

        if (curSelected < 0)
            curSelected = characters.length - 1;
        if (curSelected >= characters.length + 1)
            curSelected = 0;


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
        remove(char);
        if (curSelected != characters.length + 1) {
            char = new Character(400, 100, curChar);
            if (!dadMenu) //cleaned up
            {
                char.flipX = true;
                PlayState.keepSelectedBf = true;
                PlayState.bfString = curChar;
                trace("BF is now " + curChar);
            }
            else
            {
                char.flipX = false;
                PlayState.keepSelectedDad = true;
                PlayState.dadString = curChar;
                trace("DAD is now " + curChar);
            }
            if (curChar == null)
                curChar = "bf";
            add(char);
        } else {
            curChar = PlayState.SONG.player1;
            char = new Character(400, 100, PlayState.SONG.player1);
            if (!dadMenu)
            {
                char.flipX = true;
                PlayState.keepSelectedBf = false;
                PlayState.bfString = '';
                trace("BF is now DEFAULT" + PlayState.SONG.player1);
            }
            else
            {
                char.flipX = false;
                PlayState.keepSelectedDad = false;
                PlayState.dadString = '';
                trace("DAD is now DEFAULT");
            }
            // doesn't need to be here
            /*if (curChar == null)
                curChar = "bf";*/
            add(char);
        }

    }
    // well yeah it lags you are creating a new character
    function swapMenus() { //this lags somewhat on my end so please try to optimize it
        FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);
        dadMenu = !dadMenu;
        remove(char);
        if (!dadMenu){ //cleaned this too
            char = new Character(400, 100, PlayState.SONG.player1);
            char.flipX = true;
        }
        else{
            char = new Character(400, 100, PlayState.SONG.player2);
            char.flipX = false;
        }
        add(char);
        trace('switchin the swag');
    }
}