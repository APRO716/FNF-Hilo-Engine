package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.TransitionData;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class StorynotreadyState extends MusicBeatState
{
    private var wtf:FlxTypedGroup<Alphabet>;

    override function create()
    {
        DiscordClient.changePresence("Waiting for full week lol", null);

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
        bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.alpha = 0;
        
        wtf = new FlxTypedGroup<Alphabet>();

        var gg:Alphabet = new Alphabet(0, 0, "Story mode will", true, false);
		gg.y = 100;
        gg.isMenuItem = true;
        gg.screenCenter(X);
        gg.alpha = 0;

        var xd:Alphabet = new Alphabet(0, 0, "release in full week", true, false);
        xd.y = 180;
        xd.isMenuItem = true;
        xd.screenCenter(X);
        xd.alpha = 0;

        var huh:Alphabet = new Alphabet(0, 0, "Press ESC to return", true, false);
        huh.color = 0xFF4CBB17;
        huh.isMenuItem = true;
        huh.y = 300;
        huh.screenCenter(X);
        huh.alpha = 0;

        add(bg);
        add(wtf);
        wtf.add(gg);
        wtf.add(xd);
        wtf.add(huh);
        FlxTween.tween(bg, {alpha: 1}, 0.3);
        FlxTween.tween(gg, {alpha: 1}, 0.3);
        FlxTween.tween(xd, {alpha: 1}, 0.3);
        FlxTween.tween(huh, {alpha: 1}, 0.3);
    }

    override function update(elapsed:Float)
    {
        if (controls.BACK)
        {
			FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
		}
    }
}