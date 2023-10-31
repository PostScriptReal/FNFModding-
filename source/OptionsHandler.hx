package;
import lime.utils.Assets;
#if sys
import sys.io.File;
#end
import flixel.FlxG;
enum abstract AccuracyMode(Int) from Int to Int {
    var None = -1;
    var Simple;
    var Complex;
    var Binary;
}
enum abstract Antialiasing(Int) from Int to Int {
    var Everything;
    var CharactersStages;
    var Characters;
    var None;
}
enum abstract Resolution(Int) from Int to Int {
    var Default;
    var R1080p;
}
/**
 * Avaliable options. 
 * 
 */
typedef TOptions = {
    var skipVictoryScreen:Bool;
    var skipModifierMenu:Bool;
    var nomoreepilepsy:Bool;
    var hahanaughty:Bool;
    var alwaysDoCutscenes:Bool;
    var lyrics:Bool;
    var useCustomInput:Bool;
    var playMissAnim:Bool;
    var weakCamera:Bool;
    // var DJFKKeys:Bool;
    var allowEditOptions:Bool;
    var downscroll:Bool;
    var middlescroll:Bool;
    var useSaveDataMenu:Bool;
    var preferredSave:Int;
    var showSongPos:Bool;
    var style:Bool;
    var stressTankmen:Bool;
    //var siivagunnermode:Bool;
    // var ignoreShittyTiming:Bool;
    var ignoreUnlocks:Bool;
    var judge:Int;
    var preferJudgement:Int;
    var togglesplash:Bool;
    var menu:Int;
    var antialiasing:Antialiasing;
    var toaster:Bool;
    var vhs:Bool;
    // var screenresolution:Resolution;
    var newJudgementPos:Bool;
    var emuOsuLifts:Bool;
    var showComboBreaks:Bool;
    var useKadeHealth:Bool;
    // var funnyCloneHero:Bool;
    var useMissStun:Bool;
    var offset:Float;
    var accuracyMode:AccuracyMode;
    var danceMode:Bool;
    var dontMuteMiss:Bool;
    //var moddingOptions:Bool;
    //var funnyOptions:Bool;
    var me:Bool;
    var allowStoryMode:Bool;
    var allowFreeplay:Bool;
    var allowDonate:Bool;
    var hitSounds:Int;
    var titleToggle:Bool;
    var fpsCap:Int;
    var ignoreVile:Bool;
}
/*typedef TCategories = {
    var graphics:Bool;
    var preferences:Bool;
    var savedata:Bool;
    var modding:Bool;
}*/
/**
 * All options that can display on the savedatamenu. Used with mask
 * for some shenanangins : ))
 */
typedef FullOptions = {
    > TOptions,
    var newChar:Bool;
    var newstage:Bool;
    var newsong:Bool;
    var newweek:Bool;
    var sort:Bool;
    var soundtest:Bool;
    var controls:Bool;
    // Why did it take me so long to comment this out?
    // var credits:Bool;
}
/**
 * OptionsHandler Handles options : )
 */
class OptionsHandler {
    /**
     *  The options. On desktop it's read from file then cached. 
     */
    public static var options(get, set):TOptions;
    //public static var categoriess(get, set):TCategories;
    // Preformance!
    // We only read the file once...
    // As all calls to options should go through options handler
    // we can just cache the last options read until the file gets edited. 
    static var lastOptions:TOptions;
    static var needToRefresh:Bool = true;
    static function get_options() {
        #if sys
        // update the file
        if (needToRefresh) {
            lastOptions = CoolUtil.parseJson(FNFAssets.getJson('assets/data/options'));
            needToRefresh = false;
        }
        // these are the canon options
        // if your options aren't these it isn't canon
        if (lastOptions.danceMode) {
            lastOptions.skipVictoryScreen = false;
			lastOptions.skipModifierMenu = true; // i'm going to use a special thing to do it
			lastOptions.alwaysDoCutscenes = false;
			lastOptions.useCustomInput = true;
            lastOptions.allowEditOptions = false;
            lastOptions.useSaveDataMenu = false;
            // lastOptions.downscroll // we are going to add this to a special new menu
            lastOptions.preferredSave = 0;
            lastOptions.style = true;
            lastOptions.stressTankmen = false; // sorry guys no funny songs  : (
            lastOptions.ignoreUnlocks = true; // If we are in an arcade a person won't have enough time to unlock everything
            // lastOptions.preferJudgement // going to the new menu
            // lastOptions.judge // new menu
			lastOptions.newJudgementPos = true;
			lastOptions.emuOsuLifts = false;
            // lastOptions.skipDebugScreen // i'm removing debug entirely in dance mode
            // lastOptions.showComboBreaks // i'm going to add this to the special new menu
            lastOptions.useKadeHealth = false;
            // lastOptions.offset // i'll remove it from options, but json can still be edited. perfect those things!
            lastOptions.useMissStun = false;
			lastOptions.accuracyMode = Simple;
            lastOptions.dontMuteMiss = true;
            //lastOptions.moddingOptions = true;
            //lastOptions.funnyOptions = true;
            lastOptions.allowStoryMode = true;
            lastOptions.allowFreeplay = true;
            lastOptions.allowDonate = false;
            lastOptions.hitSounds = 0;
            lastOptions.titleToggle = true;
            lastOptions.fpsCap = 60;

        }
		return lastOptions;
        #else
        if (!Reflect.hasField(FlxG.save.data, "options"))
			FlxG.save.data.options = CoolUtil.parseJson(FNFAssets.getJson('assets/data/options'));
        return FlxG.save.data.options;
        #end
    }

    static function set_options(opt:TOptions) {
        #if sys
        needToRefresh = true;
        File.saveContent('assets/data/options.json', CoolUtil.stringifyJson(opt));
        #else
        FlxG.save.data.options = CoolUtil.stringifyJson(opt);
        #end
        return opt;
    }
    /*static function get_categoriess() {
        #if sys
        // update the file
        // these are the canon options
        // if your options aren't these it isn't canon

        return lastOptions;
        #else
        if (!Reflect.hasField(FlxG.save.data, "options"))
            FlxG.save.data.options = CoolUtil.parseJson(FNFAssets.getJson('assets/data/categories'));
        return FlxG.save.data.options;
        #end
    }
    static function set_categoriess(cat:TCategories) {
        // don't do anything for god's sakes
        #if sys
        File.saveContent('assets/data/categories.json', CoolUtil.stringifyJson(cat));
        #else
        FlxG.save.data.options = CoolUtil.stringifyJson(cat);
        #end
        return cat;
    }*/
}