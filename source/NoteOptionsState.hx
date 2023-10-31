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
import shaders.ColourSwap;
using StringTools;

/**
   This typedef holds data for the ColourSwap shader, including:
   - `hue`
   - `saturation`
   - and `brightness`
   This is also used to store JSON data.
**/
typedef HSBJson = {
    var hue:Float;
    var saturation:Float;
    var brightness:Float;
}
/**
   This typedef is only for saving the JSON for each note.
**/
typedef NoteHSBData = {
    var purple:HSBJson;
    var blue:HSBJson;
    var green:HSBJson;
    var red:HSBJson;
}
class NoteOptionsState extends MusicBeatState
{
    /*public static var categories:Array<String>;
    var grpAlphabet:FlxTypedGroup<Alphabet>;*/
    // var modBG:FlxSprite;

    // Copy-pasting master!
    // var funnyArrow:FlxSprite;
    var funnyArrowSelect:FlxSprite;
    var funnyArrowSelect2:FlxSprite;
    var funnyArrowSelect3:FlxSprite;
    var funnyArrowSelect4:FlxSprite;
    var funnyArrows:FlxTypedGroup<FlxSprite>;
    var funnySelects:FlxTypedGroup<FlxSprite>;
    var arrowList:Array<String>;

    var shaderList:Array<ColourSwap> = [];
    var shaderData:Array<HSBJson> = [];
    var savedNoteShaders:Dynamic;

    var menuBG:FlxSprite;
    var blackBar:FlxSprite;

    var hue:Alphabet;
    var sat:Alphabet;
    var bright:Alphabet;
    var hueInt:Alphabet;
    var satInt:Alphabet;
    var brightInt:Alphabet;

    var curSelected:Int = 0;
    var curChoice:Int = 0;
    var noChoice:Bool = false;
    var disableInput:Bool = false;
    // var curArrow:String = 'purple0';

    var cmenu:String = '';

    var holdMod:Float;
    override function create()
    {
    	var menuList = CoolUtil.coolTextFile('assets/data/menupacks.txt');
		cmenu = menuList[OptionsHandler.options.menu];
		if (!FlxG.sound.music.playing) {
			if (cmenu == 'default') {
				FlxG.sound.playMusic(FNFAssets.getSound('assets/music/options' + TitleState.soundExt));
			} else {
				FlxG.sound.playMusic(FNFAssets.getSound('assets/images/custom_menus/' + cmenu + '/music&sounds/options' + TitleState.soundExt));
			}
		}
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
        menuBG.color = 0xFFc24b99;
        // grpAlphabet = new FlxTypedGroup<Alphabet>();
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.x -= 60;
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        add(menuBG);
        FlxTween.tween(menuBG, {x: menuBG.x + 60}, (1.2), {ease: FlxEase.quintInOut});
        blackBar = new FlxSprite(Std.int(FlxG.width / 2.5), Std.int(FlxG.height / 2.5) - 40).makeGraphic(Std.int(FlxG.width / 2), Std.int(FlxG.height / 3), FlxColor.BLACK);
        blackBar.alpha = 0;
        blackBar.visible = false;
        add(blackBar);
        hue = new Alphabet(0, 10, "H", true, false, false);
        hue.alpha = 0;
        hue.visible = false;
        add(hue);
        sat = new Alphabet(0, 10, "S", true, false, false);
        sat.alpha = 0;
        sat.visible = false;
        add(sat);
        bright = new Alphabet(0, 10, "B", true, false, false);
        bright.alpha = 0;
        bright.visible = false;
        add(bright);

        arrowList = [
            'purple0',
            'blue0',
            'green0',
            'red0'
        ];
        savedNoteShaders = CoolUtil.parseJson(FNFAssets.getText('assets/data/notes.json'));
        
        funnySelects = new FlxTypedGroup<FlxSprite>();
        add(funnySelects);
        funnyArrows = new FlxTypedGroup<FlxSprite>();
        add(funnyArrows);
        generateSelect();
        for (i in 0...4) {
            trace(i);
            var funnyArrow:FlxSprite;
            funnyArrow = new FlxSprite();
            var tex = FlxAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/normal/NOTE_assets.png', 'assets/images/custom_ui/ui_packs/normal/NOTE_assets.xml');
            funnyArrow.frames = tex;
            funnyArrow.animation.addByPrefix('idle', arrowList[i], 24);
            funnyArrow.animation.play('idle');
            // funnyArrow.screenCenter();
            funnyArrow.x = FlxG.width - FlxG.width * 2;
            // simple math, only less simpler to read!
            funnyArrow.offset.x = -7 - 200 * i + 10 * i;
            funnyArrow.y = FlxG.height / 2.5;
            funnyArrows.add(funnyArrow);

            var shaderr:ColourSwap = new ColourSwap();
            var parsedShader:HSBJson = Reflect.field(savedNoteShaders, intToReflect(i));
            funnyArrow.shader = shaderr.shader;
            shaderr.hue = parsedShader.hue / 360;
            shaderr.saturation = parsedShader.saturation / 100;
            shaderr.brightness = parsedShader.brightness / 100;
            shaderList.push(shaderr);
            var curShader:HSBJson = {
                hue: shaderr.hue,
                saturation: shaderr.saturation,
                brightness: shaderr.brightness
            }
            shaderData.push(curShader);
        }

        hueInt = new Alphabet(0, 10, Std.string(Math.round(shaderData[0].hue)), false, false, false, 90, 90, true, false, true);
        hueInt.alpha = hue.alpha;
        hueInt.visible = hue.visible;
        add(hueInt);
        satInt = new Alphabet(0, 10, Std.string(Math.round(shaderData[0].saturation)), false, false, false, 90, 90, true, false, true);
        satInt.alpha = hue.alpha;
        satInt.visible = hue.visible;
        add(satInt);
        brightInt = new Alphabet(0, 10, Std.string(Math.round(shaderData[0].brightness)), false, false, false, 90, 90, true, false, true);
        brightInt.alpha = hue.alpha;
        brightInt.visible = hue.visible;
        add(brightInt);

        super.create();

    }
    function intToReflect(id:Int) {
        var reflect:String;
        switch (id) {
            case 0:
                reflect = "purple";
            case 1:
                reflect = "blue";
            case 2:
                reflect = "green";
            case 3:
                reflect = "red";
            default:
                // No "Null object reference" error today!
                reflect = "";
        }
        return reflect;
    }

    function simplification(multiplier:Int) {
        return -200 * multiplier + 10 * multiplier;
    }

    function save_options(sd:Array<HSBJson>) {
        var savedNotes:NoteHSBData = {
            purple: sd[0],
            blue: sd[1],
            green: sd[2],
            red: sd[3]
        }
        File.saveContent('assets/data/notes.json', CoolUtil.stringifyJson(savedNotes)+ "\n// Hey, if you're reading this, don't mess with the file" + "\n// Things will easily break if you're not careful!");
    }

    function updateObjs() {
        hue.y = blackBar.y + 20;
        sat.y = hue.y;
        sat.x = hue.x + 170;
        bright.y = sat.y;
        bright.x = sat.x + 170;
        // hue.x = if (noCull) blackBar.x + 30 else blackBar.width - 30;
        hueInt.y = hue.y + 100;
        hueInt.x = hue.x;
        hueInt.alpha = hue.alpha;
        hueInt.visible = hue.visible;
        satInt.y = sat.y + 100;
        satInt.x = sat.x;
        satInt.alpha = sat.alpha;
        satInt.visible = hue.visible;
        brightInt.y = bright.y + 100;
        brightInt.x = bright.x;
        brightInt.alpha = bright.alpha;
        brightInt.visible = hue.visible;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        for (arrow in funnyArrows.members) {
            FlxTween.tween(arrow, {x: FlxG.width / 4.9}, (Std.int(1.2 + 0.02 * Math.abs(arrow.offset.x) / 200)), {ease: FlxEase.quartInOut});
        }
        for (arrow in funnySelects.members) {
            FlxTween.tween(arrow, {x: FlxG.width / 4.9}, (Std.int(1.2 + 0.02 * Math.abs(arrow.offset.x) / 200)), {ease: FlxEase.quartInOut});
        }

        var noCull:Bool;
        if (curSelected > 1) {
            noCull = true;
        } else {
            noCull = false;
        }
        blackBar.x = funnyArrows.members[curSelected].x - funnyArrows.members[curSelected].offset.x - if (noCull) blackBar.width / 1.3245 else 0;

        holdMod = if (curSelected == 0) 90 else 50;

        if (controls.UP_MENU && noChoice && !disableInput && !FlxG.keys.pressed.CONTROL) {
            updateValue(1);
        }
        if (controls.UP_MENU_H && noChoice && !disableInput && FlxG.keys.pressed.CONTROL) {
            updateValue(elapsed * holdMod);
        }
        if (controls.DOWN_MENU && noChoice && !disableInput && !FlxG.keys.pressed.CONTROL) {
            updateValue(-1);
        }
        if (controls.DOWN_MENU_H && noChoice && !disableInput && FlxG.keys.pressed.CONTROL) {
            updateValue(elapsed * -holdMod);
        }
        if (controls.RESET && noChoice && !disableInput) {
            if (curChoice == 0) {
                shaderData[curSelected].hue = 0;
            } else if (curChoice == 1) {
                shaderData[curSelected].saturation = 0;
            } else {
                shaderData[curSelected].brightness = 0;
            }
        }

        updateObjs();

        if (noCull) {
            hue.x = blackBar.x + 30;
        } else {
            if (curSelected == 1) {
                hue.x = blackBar.width - 0;
            } else {
                hue.x = blackBar.width - 190;
            }
        }
        
        if (controls.BACK && !disableInput) {
            if (!noChoice) {
                save_options(shaderData);
			    LoadingState.loadAndSwitchState(new OptCategoriesState());
            } else {
                var iCheck = 0;
                bbInvisTween(true);
                for (arrow in funnyArrows.members) {
                    if (iCheck != curSelected) {
                        FlxTween.tween(arrow, {y: 288}, (0.6), {
                            ease: FlxEase.quartInOut,
                            onStart: function(flxTween:FlxTween)
                            {
                                disableInput = true;
                            },
                            onComplete: function(flxTween:FlxTween)
                            {
                                disableInput = false;
                                noChoice = false;
                                curChoice = 0;
                                // trace("Y: "+ arrow.y);
                            }
                        });
                    }
                    iCheck++;
                }
                iCheck = 0;
                for (select in funnySelects.members) {
                    if (iCheck != curSelected) {
                        FlxTween.tween(select, {y: 283}, (0.6), {ease: FlxEase.quartInOut});
                    } else {
                        select.visible = true;
                    }
                    iCheck++;
                }
                FlxTween.tween(menuBG, {y: -5}, (0.6), {ease: FlxEase.backInOut});
            }
        }
        if (controls.LEFT_MENU && !disableInput)
        {
            changeSelection(-1);
        }
        if (controls.RIGHT_MENU && !disableInput)
        {
            changeSelection(1);
        }

        if (controls.ACCEPT && !noChoice)
            chooseSelection();
        if (curSelected == 0) {
            funnySelects.members[0].animation.play('selected');
            funnySelects.members[1].animation.play('idle');
            funnySelects.members[2].animation.play('idle');
            funnySelects.members[3].animation.play('idle');
            funnySelects.members[0].setGraphicSize(Std.int(funnySelects.members[0].width * 1.15));
            funnySelects.members[1].setGraphicSize(Std.int(funnySelects.members[0].width * 1));
            funnySelects.members[2].setGraphicSize(Std.int(funnySelects.members[0].width * 1));
            funnySelects.members[3].setGraphicSize(Std.int(funnySelects.members[0].width * 1));
            funnySelects.members[0].offset.x = 2;
            funnySelects.members[0].offset.y = 4;
            funnySelects.members[1].offset.x = simplification(1);
            funnySelects.members[1].offset.y = 0;
            funnySelects.members[2].offset.x = simplification(2);
            funnySelects.members[2].offset.y = 0;
            funnySelects.members[3].offset.x = simplification(3);
            funnySelects.members[3].offset.y = 0;
            // menuBG.color = 0xFFc24b99;
            FlxTween.color(menuBG, 0.25, menuBG.color, 0xFFc24b99);
        } else if (curSelected == 1) {
            funnySelects.members[1].animation.play('selected');
            funnySelects.members[0].animation.play('idle');
            funnySelects.members[2].animation.play('idle');
            funnySelects.members[3].animation.play('idle');
            funnySelects.members[1].setGraphicSize(Std.int(funnySelects.members[0].width * 1.15));
            funnySelects.members[0].setGraphicSize(Std.int(funnySelects.members[0].width * 1));
            funnySelects.members[2].setGraphicSize(Std.int(funnySelects.members[0].width * 1));
            funnySelects.members[3].setGraphicSize(Std.int(funnySelects.members[0].width * 1));
            funnySelects.members[0].offset.x = 0;
            funnySelects.members[0].offset.y = 0;
            funnySelects.members[1].offset.x = simplification(1)+ 2;
            funnySelects.members[1].offset.y = 4;
            funnySelects.members[2].offset.x = simplification(2);
            funnySelects.members[2].offset.y = 0;
            funnySelects.members[3].offset.x = simplification(3);
            funnySelects.members[3].offset.y = 0;
            // menuBG.color = 0xFF00FFFF;
            FlxTween.color(menuBG, 0.25, menuBG.color, 0xFF00FFFF);
        } else if (curSelected == 2) {
            funnySelects.members[2].animation.play('selected');
            funnySelects.members[0].animation.play('idle');
            funnySelects.members[1].animation.play('idle');
            funnySelects.members[3].animation.play('idle');
            funnySelects.members[2].setGraphicSize(Std.int(funnySelects.members[0].width * 1.15));
            funnySelects.members[1].setGraphicSize(Std.int(funnySelects.members[0].width * 1));
            funnySelects.members[0].setGraphicSize(Std.int(funnySelects.members[0].width * 1));
            funnySelects.members[3].setGraphicSize(Std.int(funnySelects.members[0].width * 1));
            funnySelects.members[0].offset.x = 0;
            funnySelects.members[0].offset.y = 0;
            funnySelects.members[1].offset.x = simplification(1);
            funnySelects.members[1].offset.y = 0;
            funnySelects.members[2].offset.x = simplification(2) + 2;
            funnySelects.members[2].offset.y = 0;
            funnySelects.members[3].offset.x = simplification(3);
            funnySelects.members[3].offset.y = 0;
            // menuBG.color = 0xFF12FA05;
            FlxTween.color(menuBG, 0.25, menuBG.color, 0xFF12FA05);
        } else if (curSelected == 3) {
            funnySelects.members[3].animation.play('selected');
            funnySelects.members[1].animation.play('idle');
            funnySelects.members[2].animation.play('idle');
            funnySelects.members[0].animation.play('idle');
            funnySelects.members[3].setGraphicSize(Std.int(funnySelects.members[0].width * 1.15));
            funnySelects.members[1].setGraphicSize(Std.int(funnySelects.members[0].width * 1));
            funnySelects.members[2].setGraphicSize(Std.int(funnySelects.members[0].width * 1));
            funnySelects.members[0].setGraphicSize(Std.int(funnySelects.members[0].width * 1));
            funnySelects.members[0].offset.x = 0;
            funnySelects.members[0].offset.y = 0;
            funnySelects.members[1].offset.x = simplification(1);
            funnySelects.members[1].offset.y = 0;
            funnySelects.members[2].offset.x = simplification(2);
            funnySelects.members[2].offset.y = -2;
            funnySelects.members[3].offset.x = simplification(3) + 4;
            funnySelects.members[3].offset.y = 3;
            // menuBG.color = 0xFFF9393F;
            FlxTween.color(menuBG, 0.25, menuBG.color, 0xFFF9393F);
        }
        menuBG.shader = shaderList[curSelected].shader;
    }

    function changeSelection(change:Int = 0)
    {
        if (!noChoice) {
            FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

            curSelected += change;
            // curArrow = arrowList[curSelected].toString();

            if (curSelected < 0)
                curSelected = arrowList.length - 1;
            if (curSelected >= arrowList.length)
                curSelected = 0;
            // WHY just WHY does obj.text not work!? 
            hueInt.changeText(Std.string(Math.round(shaderData[curSelected].hue)), true);
            satInt.changeText(Std.string(Math.round(shaderData[curSelected].saturation)), true);
            brightInt.changeText(Std.string(Math.round(shaderData[curSelected].brightness)), true);
        } else {
            FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

            curChoice += change;

            if (curChoice < 0)
                curChoice = 2;
            if (curChoice > 2)
                 curChoice = 0;

            if (curChoice == 0) {
                hue.alpha = 1;
                sat.alpha = 0.6;
                bright.alpha = 0.6;
            } else if (curChoice == 1) {
                hue.alpha = 0.6;
                sat.alpha = 1;
                bright.alpha = 0.6;
            } else {
                hue.alpha = 0.6;
                sat.alpha = 0.6;
                bright.alpha = 1;
            }
            //fortnite battlepass - Abraham Lincoln
            //So I asked a taxidermist what he did for a livin'. He said, "Oh, you know, stuff". - Sean
        }
        /*trace('Selected: '+curSelected);
        trace('Change: '+change);*/
    }

    function chooseSelection()
    {
        var iCheck = 0;
        bbInvisTween(false);
        for (arrow in funnyArrows.members) {
            if (iCheck != curSelected) {
                FlxTween.tween(arrow, {y: 688}, (0.6), {
                    ease: FlxEase.quartInOut,
                    onStart: function(flxTween:FlxTween)
                    {
                        disableInput = true;
                    },
                    onComplete: function(flxTween:FlxTween)
                    {
                        disableInput = false;
                        noChoice = true;
                        // trace("Y: "+ arrow.y);
                    }
                });
            }
            iCheck++;
        }
        iCheck = 0;
        for (select in funnySelects.members) {
            if (iCheck != curSelected) {
                FlxTween.tween(select, {y: 683}, (0.6), {ease: FlxEase.quartInOut});
            } else {
                select.visible = false;
            }
            iCheck++;
        }
        FlxTween.tween(menuBG, {y: 35}, (0.6), {ease: FlxEase.backInOut});
    }

    function bbInvisTween(reverse:Bool) {
        if (!reverse) {
            blackBar.visible = true;
            hue.visible = true;
            sat.visible = true;
            bright.visible = true;
        }
        FlxTween.tween(blackBar, {alpha: if (!reverse) 0.5 else 0}, (if (!reverse) 1.0 else 0.8), {ease: FlxEase.quartInOut});
        FlxTween.tween(hue, {alpha: if (!reverse) 1 else 0}, (if (!reverse) 1.0 else 0.8), {ease: FlxEase.quartInOut});
        FlxTween.tween(sat, {alpha: if (!reverse) 0.6 else 0}, (if (!reverse) 1.0 else 0.8), {ease: FlxEase.quartInOut});
        FlxTween.tween(bright, {alpha: if (!reverse) 0.6 else 0}, (if (!reverse) 1.0 else 0.8), {ease: FlxEase.quartInOut});
        if (reverse) {
            blackBar.visible = false;
            hue.visible = false;
            sat.visible = false;
            bright.visible = false;
        }
    }

    function updateValue(change:Float = 0) {
        trace("Updated value by "+ change);
        // var newChange:Float = change / if (curChoice == 0) 360 else 180;
        var updatedValue:Float;
        var reachedMax:Bool = false;
        if (curChoice == 0) {
            updatedValue = shaderData[curSelected].hue + change;
        } else if (curChoice == 1) {
            updatedValue = shaderData[curSelected].saturation + change;
        } else {
            updatedValue = shaderData[curSelected].brightness + change;
        }
        var roundedChange:Int = Math.round(updatedValue);

        var breakProtection:Float = if (curChoice == 0) 180 else 100;

        if (roundedChange < -breakProtection) {
            reachedMax = true;
            updatedValue = -breakProtection;
        } else if (roundedChange > breakProtection) {
            reachedMax = true;
            updatedValue = breakProtection;
        }

        if (curChoice == 0) {
            shaderData[curSelected].hue = updatedValue;
        } else if (curChoice == 1) {
            shaderData[curSelected].saturation = updatedValue;
        } else {
            shaderData[curSelected].brightness = updatedValue;
        }
        shaderList[curSelected].hue = shaderData[curSelected].hue / 360;
        shaderList[curSelected].saturation = shaderData[curSelected].saturation / 100;
        shaderList[curSelected].brightness = shaderData[curSelected].brightness / 100;

        if (curChoice == 0 && !reachedMax) {
            hueInt.changeText(Std.string(Math.round(updatedValue)), true);
        } else if (curChoice == 1 && !reachedMax) {
            satInt.changeText(Std.string(Math.round(updatedValue)), true);
        } else/* if (!reachedMax)*/ {
            brightInt.changeText(Std.string(Math.round(updatedValue)), true);
        }
    }

    function generateSelect() {
        funnyArrowSelect = new FlxSprite();
        funnyArrowSelect2 = new FlxSprite();
        funnyArrowSelect3 = new FlxSprite();
        funnyArrowSelect4 = new FlxSprite();
        var rawPic = FNFAssets.getBitmapData("assets/images/arrowSelect.png");
        var rawXml:String = "";
        rawXml = FNFAssets.getText('assets/images/arrowSelect.xml');
        var texSelect = FlxAtlasFrames.fromSparrow(rawPic, rawXml);
        funnyArrowSelect.frames = texSelect;
        funnyArrowSelect.animation.addByPrefix('idle', "left0", 24);
        funnyArrowSelect.animation.addByPrefix('selected', "leftwhite0", 24);
        funnyArrowSelect.animation.play('idle');
        // funnyArrowSelect.screenCenter();
        funnyArrowSelect.x = FlxG.width - FlxG.width * 2;
        funnyArrowSelect.y = FlxG.height / 2.5 - 5;
        funnySelects.add(funnyArrowSelect);
        funnyArrowSelect2.frames = texSelect;
        funnyArrowSelect2.animation.addByPrefix('idle', "down0", 24);
        funnyArrowSelect2.animation.addByPrefix('selected', "downwhite0", 24);
        funnyArrowSelect2.animation.play('idle');
        // funnyArrowSelect2.screenCenter();
        funnyArrowSelect2.x = FlxG.width - FlxG.width * 2;
        funnyArrowSelect2.offset.x = -200 + 10;
        funnyArrowSelect2.y = FlxG.height / 2.5 - 5;
        funnySelects.add(funnyArrowSelect2);
        funnyArrowSelect3.frames = texSelect;
        funnyArrowSelect3.animation.addByPrefix('idle', "up0", 24);
        funnyArrowSelect3.animation.addByPrefix('selected', "upwhite0", 24);
        funnyArrowSelect3.animation.play('idle');
        // funnyArrowSelect2.screenCenter();
        funnyArrowSelect3.x = FlxG.width - FlxG.width * 2;
        funnyArrowSelect3.offset.x = -200 * 2 + 10 * 2;
        funnyArrowSelect3.y = FlxG.height / 2.5 - 5;
        funnySelects.add(funnyArrowSelect3);
        funnyArrowSelect4.frames = texSelect;
        funnyArrowSelect4.animation.addByPrefix('idle', "right0", 24);
        funnyArrowSelect4.animation.addByPrefix('selected', "rightwhite0", 24);
        funnyArrowSelect4.animation.play('idle');
        // funnyArrowSelect.screenCenter();
        funnyArrowSelect4.x = FlxG.width - FlxG.width * 2;
        funnyArrowSelect4.offset.x = -200 * 3 + 10 * 3;
        funnyArrowSelect4.y = FlxG.height / 2.5 - 5;
        funnySelects.add(funnyArrowSelect4);
    }
}