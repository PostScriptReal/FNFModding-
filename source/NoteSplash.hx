package;
import flixel.FlxSprite;
import DynamicSprite.DynamicAtlasFrames;
import flixel.FlxG;
import Judgement.TUI;
import shaders.ColourSwap;

using StringTools;
class NoteSplash extends FlxSprite {
    var curUiType:TUI;
    var colourSwap:ColourSwap;
    var coolShaderArray:Array<String> = ['purple', 'blue', 'green', 'red'];
    public function new(xPos:Float,yPos:Float,?c:Int) {
        if (c == null) c = 0;
        super(xPos,yPos);
		if (PlayState.splashusStringus == '') {
			curUiType = Reflect.field(Judgement.uiJson, PlayState.SONG.uiType);
		} else {
			curUiType = Reflect.field(Judgement.uiJson, PlayState.splashusStringus);
		}
		frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.png',
			'assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.xml');
        animation.addByPrefix("note1-0", "note impact 1  blue", 24, false);
		animation.addByPrefix("note2-0", "note impact 1 green", 24, false);
		animation.addByPrefix("note0-0", "note impact 1 purple", 24, false);
		animation.addByPrefix("note3-0", "note impact 1 red", 24, false);

		animation.addByPrefix("note1-1", "note impact 2 blue", 24, false);
		animation.addByPrefix("note2-1", "note impact 2 green", 24, false);
		animation.addByPrefix("note0-1", "note impact 2 purple", 24, false);
		animation.addByPrefix("note3-1", "note impact 2 red", 24, false);
        setupNoteSplash(xPos,xPos,c);
    }
    public function setupNoteSplash(xPos:Float, yPos:Float, ?c:Int) {
        if (c == null) c = 0;
        setPosition(xPos, yPos);
        alpha = 0.6;
        animation.play("note"+c+"-"+FlxG.random.int(0,1), true);
		animation.curAnim.frameRate += FlxG.random.int(-2, 2);
        updateHitbox();
        offset.set(0.3 * width, 0.3 * height);
        if (curUiType.noteShaderAffected) {
            colourSwap = new ColourSwap();
            var shaderJSON:Dynamic = CoolUtil.parseJson(FNFAssets.getText('assets/data/notes.json'));
            var parsedShader:NoteOptionsState.HSBJson = Reflect.field(shaderJSON, if (StringTools.endsWith(animation.curAnim.name, 'purple')) coolShaderArray[0] else coolShaderArray[c]);
            shader = colourSwap.shader;
            colourSwap.hue = parsedShader.hue / 360;
            colourSwap.saturation = parsedShader.saturation / 100;
            colourSwap.brightness = parsedShader.brightness / 100;
        }
    }
    override public function update(elapsed) {
        if (animation.curAnim.finished) {
            // club pengiun is
            kill();
        }
        super.update(elapsed);
    }
}