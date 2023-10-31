# FNF Modding++
FNF Modding++ was a fork of BulbyVR's FNF ModdingPlus, a modding engine that aimed to make FNF modding easier and give users the ability to make mods without the need to modify the source code.

I forked the original after it was abandoned and continued to update and make improvements to the engine for another year or so.
# WARNING!
This project was the first time I worked with JavaScript, I was completely self-taught and as a result the engine may be unstable.

There may also be performance issues (one I noticed during development was that the game would temporarily freeze when pausing the game, causing some notes to be missed during gameplay). As a result of abandoning the project because of disinterest the engine will contain unfinished/buggy features.

## Features Added

- Revamped options menu with sub-catagories to be more user-friendly and allow efficient navigation
- New options such as: Middlescroll, anti-aliasing, toggling miss animations, dynamic camera effects, censoring, custom hitsounds, toggling lyrics, toggling note-splashes, switching custom menus and changing fps cap.
- Fixed broken miss behaviour where miss animation for characters don't play.
- Added custom colours for character win/lose bar (customisable via custom character .JSONs)
- Added Dynamically moving camera
- Added the ability to change difficulty in-game
- Video cutscene support via HxCodec
- Quick-switching to Chart editor in modifier state
- Allowing Change Character Modifier to persist between songs
- Added customisable lyrics system with features such as colouring and camera effects
- Additional performance options such as disabling anti-aliasing and disabling visual elements
- Pixel note splashes
- Ability to execute multiple modcharts
- Ability to make and execute custom functions in modchart
- Overriding menu assets using "menupacks"
- And many more features and improvements
## Incomplete/buggy Features
### Incomplete features
- Changing note colours through settings (can be overridden by custom ui)
- Built-in modloader
### Buggy features
- Menupacks

# BUILDING INSTRUCTIONS
First things first, follow the instructions from the original FNF Building instructions:

" To run it from your desktop (Windows, Mac, Linux) it can be a bit more involved. For Linux, you only need to open a terminal in the project directory and run 'lime test linux -debug' and then run the executible file in export/release/linux/bin. For Windows, you need to install Visual Studio Community 2019. While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:
* MSVC v142 - VS 2019 C++ x64/x86 build tools (Latest)
* Windows SDK (10.0.17763.0)
* C++ Profiling tools
* C++ CMake tools for windows
* C++ ATL for v142 build tools (x86 & x64)
* C++ MFC for v142 build tools (x86 & x64)
* C++/CLI support for v142 build tools (14.21)
* C++ Modules for v142 build tools (x64/x86)
* Clang Compiler for Windows
* Windows 10 SDK (10.0.17134.0)
* Windows 10 SDK (10.0.16299.0)
* MSVC v141 - VS 2017 C++ x64/x86 build tools
* MSVC v140 - VS 2015 C++ build tools (v14.00)

or just install these:
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)

This will install about 22GB of crap (4GB if installing just the two dependencies), but once that is done you can open up a command line in the project's directory and run `lime test windows -debug`. Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\release\windows\bin
As for Mac, 'lime test mac -debug' should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac. "

Once you have done this (or maybe you have done these steps before), install these extra libraries using "haxe install (library)"
```
hscript
flixel-ui
tjson
json2object
uniontypes
hxcpp-debug-server
hxcodec
```
then install the following libraries using "haxelib git (library name) (Library github url)"
```
haxelib git hscript-ex https://github.com/ianharrigan/hscript-ex
haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit.git
haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit
```
The luajit libraries there aren't supposed to be necessary for compiling, but because I was new to programming in haxe at the time, I mistakenly made them dependant on those libraries.

### Here's some stuff I copied from my original README

## Credits
- [BulbyVR](https://github.com/TheDrawingCoder-Gamer) and contributers - For the original Modding+
- Postscript - Owner/Programmer/Art
- [ShadowMario](https://github.com/ShadowMario) - Some code I took :P
- [Dan Roberts/PolybiusProxy](https://github.com/polybiusproxy) - HxCodec (TYSM YOU HAVE NO IDEA HOW MUCH THIS HELPED ME!)
- [AngelDTF](https://github.com/AngelDTF) - [The reverse-engineered week 7 code!](https://github.com/AngelDTF/FNF-NewgroundsPort/tree/remaster/source) (YOU'RE A LIFE SAVER! MY BRAIN CAN FINALLY REST EASY!!)

## Known bugs and issues

Since this is a project worked on by one individual (me!) there's gonna be bugs I have yet to find out a way to iron out. These include:

- Sound test not loading songs in the '/songs' folder.
- Playing songs in freeplay sets the difficulty to normal despite what you've chosen (Easily can be avoided by going into the pause menu and changing the difficulty there).
- GF won't stop crying in week 7 (stupid bug that doesn't even happen in the original M+)
- Pausing freezes the game for a few seconds, often causing the song to skip.
- NoteOptionsState doesn't properly read your saved options (the issue didn't even occur during its early stages of development)
- The positioning of some objects on LoaderItems are broken

These bugs may be fixed eventually!