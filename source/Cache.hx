#if sys
package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.system.FlxSound;
import lime.app.Application;
#if windows
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class Cache extends MusicBeatState
{
	public static var bitmapData:Map<String,FlxGraphic>;
	public static var bitmapData2:Map<String,FlxGraphic>;

	var images = [];
	var music = [];

	var shitz:FlxText;

	var loadingBarBG:FlxSprite;

	var loadingBar:FlxBar;

	var barProgress:Float = 0;

	override function create()
	{
		FlxG.mouse.visible = true;

		FlxG.worldBounds.set(0,0);

		bitmapData = new Map<String,FlxGraphic>();
		bitmapData2 = new Map<String,FlxGraphic>();

		FlxG.sound.play(Paths.music('offsetSong'),1,false,null,false);

		#if cpp
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
		{
			if (!i.endsWith(".png"))
				continue;
			images.push(i);
		}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
		{
			music.push(i);
		}
		#end
		//add loading % BUT HOW
		sys.thread.Thread.create(() -> {
			cache();
		});

		super.create();
	}

	override function update(elapsed) 
	{
		super.update(elapsed);
	}

	function cache()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('funkay'));
		menuBG.screenCenter();
		add(menuBG);
		menuBG.scale.set(0.8, 0.8);
		
		shitz = new FlxText(12, 680, 0, "Loading...", 12);
		shitz.scrollFactor.set();
		shitz.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(shitz);

		#if !linux
			var sound1:FlxSound;
			sound1 = new FlxSound().loadEmbedded(Paths.voices('fresh'));
			sound1.play();
			sound1.volume = 0.00001;
			FlxG.sound.list.add(sound1);

			var sound2:FlxSound;
			sound2 = new FlxSound().loadEmbedded(Paths.inst('fresh'));
			sound2.play();
			sound2.volume = 0.00001;
			FlxG.sound.list.add(sound2);
		for (i in images)
		{
			var replaced = i.replace(".png","");
			var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced,graph);
			trace(i);
		}

		for (i in music)
		{
			trace(i);
			FlxG.sound.cache(Paths.inst(i));
			FlxG.sound.cache(Paths.voices(i));
		}

		FlxTween.tween(menuBG, {alpha: 0}, 1, {ease: FlxEase.cubeInOut});
		
		shitz.text = "Done!";
		shitz.scrollFactor.set();
		shitz.setFormat("VCR OSD Mono", 32, FlxColor.PINK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		FlxTween.tween(shitz, {alpha: 0}, 1, {ease: FlxEase.cubeInOut});

		FlxG.sound.play(Paths.sound('titleShoot'),0.6,false,null,false,function(){
		FlxG.autoPause = true;
		FlxG.switchState(new TitleState());
		});
		#end
	}
	
}
#end