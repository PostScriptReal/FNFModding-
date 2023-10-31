package;

#if FEATURE_LUAMODCHART
import flixel.graphics.FlxGraphic;
#end
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}
	static var currentLevel:String;

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null && library != "mods")
			return getLibraryPath(file, library);
		if (library != null && library == "mods")
			return getModPath(file);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	#if FEATURE_LUAMODCHART
	static public function loadImage(key:String, ?library:String):FlxGraphic
	{
		var path = image(key, library);

		#if FEATURE_FILESYSTEM
		if (Caching.bitmapData != null)
		{
			if (Caching.bitmapData.exists(key))
			{
				KadeDebug.logTrace('Loading image from bitmap cache: $key');
				// Get data from cache.
				return Caching.bitmapData.get(key);
			}
		}
		#end

		if (OpenFlAssets.exists(path, IMAGE))
		{
			var bitmap = OpenFlAssets.getBitmapData(path);
			return FlxGraphic.fromBitmapData(bitmap);
		}
		else
		{
			KadeDebug.logWarn('Could not find image at path $path');
			return null;
		}
	}
	#end

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}
	inline static function getModPath(file:String)
	{
		return 'mods/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function mods(key:String = '') {
		return 'assets/' + key;
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}
	// lua modcharting from kade engine that's used with compatability mode
	inline static public function luakade(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	/*static public function video(key:String)
	{
		var file:String = theVideo(key);
		if(FNFAssets.exists(file)) {
			return file;
		}
		return 'assets/images/custom_cutscenes/$key.mp4';
	}*/
	inline static public function video(key:String)
	{
		return 'assets/images/custom_cutscenes/videos/$key';
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}
	inline static public function icon(iconFolder:String, key:String)
	{
		return getPath('Icons/'+ iconFolder +'$key.png', IMAGE, "mods");
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
	static public function videoFolder(key:String) {
		var fileToCheck:String = mods('images/custom_cutscenes/' + key);
		if(FNFAssets.exists(fileToCheck)) {
			return fileToCheck;
		}
		return 'assets/images/custom_cutscenes/' + key;
	}

	inline static public function theVideo(key:String) {
		return videoFolder(key);
	}
}
