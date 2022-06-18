package;
//CODE FROM https://github.com/EIT0/PE-tutorials/blob/main/CharSelectState.hx
//BUT I FIX THAT CODE TO ADD it EASISER [i think]
//                    --hiro not hilo

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup; //fnf lore engine

class CharSelectState extends MusicBeatState{
    var charsArray:Array<String> = ['BOYFRIEND', 'BF-CAR', 'BF-christmas', 'BF-PIXEL', 'Character in Chart'];
    var leBG:FlxSprite;
    private var bf:Boyfriend;
    public var player:String;
    var iconP1:HealthIcon;
    public var selectedText:FlxText;
    public var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
    public var charSelect:FlxSprite;
    var bfgroup:FlxGroup = new FlxGroup();
    public static var curSelected:Int = 0;
    var stopspamming:Bool = false;
    var leftgrouplol:FlxGroup = new FlxGroup();
    var rightgrouplol:FlxGroup = new FlxGroup();
    public var leftArrow:FlxSprite;
    public var rightArrow:FlxSprite;

    private var bfArray:Array<Boyfriend> = [];

    override function create(){
        //FlxG.sound.playMusic(Paths.music('tea-time'));;
        leBG = new FlxSprite().loadGraphic(Paths.image('menuBG'));
        leBG.color = FlxColor.BLUE;
        leBG.screenCenter();
        add(leBG);
        /*bf = new FlxSprite(450, 300).loadGraphic(Paths.image('characters/BOYFRIEND'));
        bf.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
        bf.animation.addByPrefix('idle', 'BF idle dance', 24, true);
        bf.animation.addByPrefix('hey', 'BF HEY!!', 24, true);
        bf.animation.play('idle');
        add(bf);*/
        /*bfcar = new FlxSprite(450, 300).loadGraphic(Paths.image('characters/bfCar'));
        bfcar.frames = Paths.getSparrowAtlas('characters/bfCar');
        bfcar.animation.addByPrefix('idle', 'BF idle dance', 24, true);
        bfcar.animation.addByPrefix('hey', 'BF HEY!!', 24, true);
        bfcar.animation.addByPrefix('singUP', 'BF NOTE UP', 24, true);
        bfcar.animation.play('idle');
        add(bfcar);*/

		selectedText = new FlxText(0, 10, charsArray[0], 24);
		selectedText.alpha = 0.5;
		selectedText.x = (FlxG.width) - (selectedText.width) - 125;
        add(selectedText);
        charSelect = new Alphabet(0, 50, "Select Your Character", true, false);
        charSelect.offset.x -= 150;
        add(charSelect);
        changeSelection();
        //bf.updateHitbox();

        super.create();
    }

    override function beatHit() {
		if (FlxG.camera.zoom < 1.35 && curBeat % 2 == 0 && !stopspamming){
			FlxG.camera.zoom += 0.03;
			bf.dance();
            bf.updateHitbox();
		}
        super.beatHit();
	}

    function changeSelection(change:Int = 0){
        bfgroup.destroy();
		bfgroup = new FlxGroup();
		add(bfgroup);
        
        curSelected += change;

        if (curSelected < 0)
			curSelected = charsArray.length - 1;
		if (curSelected >= charsArray.length && !stopspamming)
			curSelected = 0;

        selectedText.text = charsArray[curSelected];

        switch(curSelected){
            case 0:
                /*bf.visible = true;
                bfcar.visible = false;*/
                player = 'bf';
                FlxTween.color(leBG, 2, leBG.color, FlxColor.BLUE, {onComplete:function(twn:FlxTween){
                FlxTween.cancelTweensOf(leBG);
                }});
            case 1:
                /*bf.visible = false;
                bfcar.visible = true;*/
                player = 'bf-car';
                /*FlxTween.color(leBG, 2, leBG.color, FlxColor.BLUE, {onComplete:function(twn:FlxTween){
                FlxTween.cancelTweensOf(leBG);
                }});*/
            case 2:
                player = 'bf-christmas';
            case 3:
                player = 'bf-pixel';
            case 4:
                player = PlayState.SONG.player1;
        }

        bf = new Boyfriend(0,0, player);
        bf.updateHitbox();
        bf.x = 450;
        bf.y = 200;
        
        if(player != 'bf-pixel'){
            bf.antialiasing = ClientPrefs.globalAntialiasing;
        }
        bfgroup.add(bf);

        iconP1 = new HealthIcon(bf.healthIcon, true);
        iconP1.screenCenter(X);
        iconP1.y = 575;
        iconP1.updateHitbox();
        iconP1.animation.curAnim.curFrame = 0;
        iconP1.scale.set(1.2, 1.2);
        bfgroup.add(iconP1);
    }

    override function update(elapsed:Float){

        bf.updateHitbox();
        if (FlxG.sound.music != null){
            Conductor.songPosition = FlxG.sound.music.time;
        }
        FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));

        leftArrow = new FlxSprite(350, 400);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;

        rightArrow = new FlxSprite(leftArrow.x + 538, leftArrow.y);
        rightArrow.frames = ui_tex;
        rightArrow.animation.addByPrefix('idle', 'arrow right');
        rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
        rightArrow.antialiasing = ClientPrefs.globalAntialiasing;

        if (controls.UI_LEFT_P && !stopspamming){
            changeSelection(-1);
            bf.x -= 50;
            FlxTween.tween(bf, {x: bf.x + 50}, 0.2, {ease: FlxEase.circOut});
            iconP1.y -= 50;
            FlxTween.tween(iconP1, {y: iconP1.y + 50}, 0.2, {ease: FlxEase.circOut});
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }

        if (controls.UI_LEFT && !stopspamming){
            leftgrouplol.destroy();
            leftgrouplol = new FlxGroup();
		    add(leftgrouplol);

            leftgrouplol.add(leftArrow);

            leftArrow.animation.play('press');
        }
        else{
            leftgrouplol.destroy();
            leftgrouplol = new FlxGroup();
		    add(leftgrouplol);

            leftgrouplol.add(leftArrow);

            leftArrow.animation.play('idle');
        }

        if (controls.UI_RIGHT && !stopspamming){
            rightgrouplol.destroy();
            rightgrouplol = new FlxGroup();
		    add(rightgrouplol);

            rightgrouplol.add(rightArrow);

            rightArrow.animation.play('press');
            
        }
        else{
            rightgrouplol.destroy();
            rightgrouplol = new FlxGroup();
		    add(rightgrouplol);

            rightgrouplol.add(rightArrow);

            rightArrow.animation.play('idle');
        }

        if (controls.UI_RIGHT_P && !stopspamming){
            changeSelection(1);
            //leftArrow.animation.play('idle');
            //rightArrow.animation.play('press');
            bf.x += 50;
            FlxTween.tween(bf, {x: bf.x - 50}, 0.2, {ease: FlxEase.circOut});
            iconP1.y += 50;
            FlxTween.tween(iconP1, {y: iconP1.y - 50}, 0.2, {ease: FlxEase.circOut});
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
        if (controls.ACCEPT && !stopspamming){
            //bf.updateHitbox();
            FlxG.sound.play(Paths.sound('confirmMenu'));
            stopspamming = true;
            FlxG.camera.zoom += 0.8;
            bf.playAnim('hey', true);
            bf.specialAnim = true;
			bf.heyTimer = 3;
            FlxFlicker.flicker(bf, 1.5, 0.15, false);
            bf.updateHitbox();
            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                {
                    //bf.updateHitbox();
                    MusicBeatState.switchState(new PlayState());
                    FreeplayState.destroyFreeplayVocals();
                    FlxG.sound.music.volume = 0;
                });
        }
        if (controls.BACK && !stopspamming){
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new FreeplayState());
        }
        super.update(elapsed);
    }
}