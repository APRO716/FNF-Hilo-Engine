package;

import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Json;

#if sys
import sys.FileSystem;
#end

//"Static access to instance field (varible) is not allowed" mean you stupid go read kade version lol

using StringTools;

class ResultState extends MusicBeatState
{
    var accuracynumber:Float = 0;
    var score:Int = 0;
    var misses:Int = 0;
    var topcombo:Int = 0;
    var rank:String = "";
    var FC:String = "";
    var accuracytxt:FlxText;
    var epicnum:Int = 0;
    var sicknum:Int = 0;
    var goodnum:Int = 0;
    var badnum:Int = 0;
    var shitnum:Int = 0;

    override function create()
    {    
        /*accuracynumber = FlxMath.lerp(accuracynumber, PlayState.resultaccuracy, CoolUtil.boundTo(elapsed * 8, 0, 1));
        score = PlayState.instance.songScore;
        misses = PlayState.instance.songMisses;
        topcombo = PlayState.instance.highestCombo;*/
        rank = PlayState.instance.ratingName;
        FC = PlayState.instance.ratingFC;

        DiscordClient.changePresence("Result Screen", null);

        accuracytxt = new FlxText(12, 12, 0, "", 6);
        accuracytxt.scrollFactor.set();
		accuracytxt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(accuracytxt);
        ////accuracytxt.alpha = 0;
        //accuracytxt.x -= 50;

        /*accuracytxt.text = 'accuracy = ${accuracynumber} %
        \nscore = ${score}
        \nmisses = ${misses}
        \nhighestCombo = ${topcombo}
        \nRanking = ${rank} [${FC}]
        \nepic = ${PlayState.instance.epics}        sick = ${PlayState.instance.sicks}
        \ngood = ${PlayState.instance.goods}        bad = ${PlayState.instance.bads}
        \nshit = ${PlayState.instance.shits}
        ';*/
        
        //FlxTween.tween(accuracytxt, {x: accuracytxt.x + 50, alpha: 1}, 0.5);
        super.create();
    }

    override function update(elapsed:Float)
    {
        accuracynumber = Highscore.floorDecimal(FlxMath.lerp(accuracynumber, PlayState.resultaccuracy, CoolUtil.boundTo(elapsed * 8, 0, 1)), 2);
        score =  Math.ceil(FlxMath.lerp(score, PlayState.instance.songScore, CoolUtil.boundTo(elapsed * 8, 0, 1)));
        misses =  Math.ceil(FlxMath.lerp(misses, PlayState.instance.songMisses, CoolUtil.boundTo(elapsed * 8, 0, 1)));
        topcombo =  Math.ceil(FlxMath.lerp(topcombo, PlayState.instance.highestCombo, CoolUtil.boundTo(elapsed * 8, 0, 1)));
        epicnum = Math.ceil(FlxMath.lerp(epicnum, PlayState.instance.epics, CoolUtil.boundTo(elapsed * 8, 0, 1)));
        sicknum = Math.ceil(FlxMath.lerp(sicknum, PlayState.instance.sicks, CoolUtil.boundTo(elapsed * 8, 0, 1)));
        goodnum = Math.ceil(FlxMath.lerp(goodnum, PlayState.instance.goods, CoolUtil.boundTo(elapsed * 8, 0, 1)));
        badnum = Math.ceil(FlxMath.lerp(badnum, PlayState.instance.bads, CoolUtil.boundTo(elapsed * 8, 0, 1)));
        shitnum = Math.ceil(FlxMath.lerp(shitnum, PlayState.instance.shits, CoolUtil.boundTo(elapsed * 8, 0, 1)));

        accuracytxt.text = 'accuracy = ${accuracynumber} %
        \nscore = ${score}
        \nmisses = ${misses}
        \nhighestCombo = ${topcombo}
        \nRanking = ${rank} [${FC}]
        \nepic = ${epicnum}                         sick = ${sicknum}
        \ngood = ${goodnum}                         bad = ${badnum}
        \nshit = ${shitnum}
        ';

        if (controls.ACCEPT)
        {
            FlxG.sound.play(Paths.sound('confirmMenu'));
            MusicBeatState.switchState(new FreeplayState());
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
        }
    }
}