# KickAss-SEUCK-Framework-V4
Kick Assembler SEUCK Framework - For enhancing your own C64 SEUCK games for fun. 

This frame work allows you to program a custom title screen/front end and add an optional high score table to it. The project also allows you to implement programmable in game enhancements, to make your game even more interesting. For example power ups, shield, smart bomb features, etc. The entire code is self-explanatory and should hopefully help you learn to enhance your SEUCK master pieces and share with the community. The majority of source code is based on the TND SEUCK School tutorials. Where credit goes to those who have provided the tips which have been implemented inside this framework:

For tips and tricks, please visit:
http://tnd64.unikat.sk/SEUCK_School.html

Requirements:

* KickAssembler V4 (or higher) (Requires JAVA)
* VICE C64 Emulator / C64 with Action Replay Cartridge / Ultimate 64 or 1541Ultimate 2 with Action Replay plugin. Retro replay plugins are fine
* Charpad V2.0 (For title screen design)
* Goat Tracker (or SIDReloc music relocator)
* Exomizer (Any version)
* Any text IDE editor that supports code (Notepad++ is a good example)
* Multi-Paint (or any art package that supports making Koala Paint Logos) - Optional
* Game created using the Shoot Em Up Construction Kit or the Sideways Scrolling SEUCK -Left
* Dir Master (For making your disk with the game inside)

# Instructions:

Load in your SEUCK game:
Your SEUCK/Sideways scrolling SEUCK game must be loaded as a finished game state (or perhaps loaded and de-frozen from any cartridge). After your game has finished loading. Press the Freeze button on your Action Replay and save the finished game in two separate parts from the machine code monitor. 

S "MYGAMEPT1",8,0900,6580

S "MYGAMEPT2",8,6580,B6C0

It is very important that you save the game as two segments, as memory between $6580-$B6C0 is saved for the data and code for the enhancements.

The most imporatant is to create and generate a batch file, in which to run through Notepad ++ or any other IDE application that supports running batch files. This way you are able to check the progress of compiling.

Using your IDE create a batch file called buildit.bat (or whatever you like to call it). Then enter the following command:

java -jar "c:\kickassembler\kickass.jar" framework.asm 
ifnot exist framework.prg goto skip:
c:\exomizer\win32\exomizer.exe sfx $0400 framework.prg -o nameofgame.prg
c:\VICE_runtime\x64sc.exe nameofgame.prg
skip:

NOTE: You must set the correct patch and run time to the batch file in order for it to run properly.  Please check manual for IDE on how to set run batch files to post-build options.

That's everything. I hope you have loads of fun playing around with this source code, enhancing your own SEUCK game creations. Let you games come to life. :)

# Update in V2.0 

* New front end which displays credits screen and flips to high score table list
* Options for in game sound effects or music 
* Optional Get Ready and Game Over screen
* Object detection and full enemy explosion (Handy for collectibles or boss object types)
* End screen
* Optional player safe spawn position (Spawns the player in the last position before  it died, avoiding getting stuck on background that forces the player to stop on push scrolling games. 
* Enhancements are expandable
* PAL/NTSC compatible (Although the score panel's lives will not be 100% on NTSC machines)

# Update in V3.0

* Custom front end charset animation (Please check out the Charpad CTM files to know which 8 chars represent the animation frames)
* Custom in game background animation (Can scroll down, or left) 
* Sideways SEUCK scroller fixup (Stabilize the map scroller a little)
* Custom level colour scheme code (Based on comparing values of the level counter by units of seven).
* Power Ups (including sprite changing for bullets)

# Bug fixes in V3

* Player spawning at the top left of the screen, when safe respawn was disabled
* Music player slowing down completely when trying to detect PAL/NTSC 
* Title Screen Colour bug fixed (Where char multicolour 2 overwritten char multicolour 3)
* Extra life bug issue fixed

# Update in V4.0

* Player score panel can now use multicolour (Use Charpad to design the 3 colours of your score panel, and then import into the source code).
* Added a hi score saver (The hi score saver will automatically check that a disk is being used for your game, if mastered to tape, hi score saving/loading is skipped).
* Added Power up features: based on SEUCK sprite tables (see objects in SEUCK)- Bullet upgrades (Optional)
* Added Player transformation: based on SEUCK sprite tables (see objects in SEUCK)
* A choice of 3 different front ends to pick from:
  1. Normal front end from framework V3. Allows optional in game sound music. Uses hiscore table (loader needs onetime.asm to be enabled for this)
  2. Restricted by stylish front end, which uses a multi colour bitmap logo for the title screen. (Dimensions are currently 40x10 characters at the top, using in Guillotine - The Doom Machine). Currently cannot use in game music if using this feature.
  3. Colour bar washing title screen (SEUCKMOD.ASM), as suggested by Pinov Vox. Note that this does not use additional in game enhancements apart from music player.
* Custom sprite expansion: You can play your games with EXPANDED sprites if you want to. Sprite sizes can be changed by X or Y axis.
* Sprite/Background priority - Handy for games where the player can hide behind a scene, if enabled. Please be aware that the sprite can hide behind the colours Background Multicolour 2 and Char Colours

That's everything featured. Older features are still supported in V4.0.

V5.0 coming some time in the forseeable future, which will allow additional in game features.


