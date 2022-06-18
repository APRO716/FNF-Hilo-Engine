package;

import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import flixel.group.FlxGroup; //fnf lore engine
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
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
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;

#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public var healthnumlol:FlxText;
	public static var resultaccuracy:Float = 0;
	public static var accuracyshit:Float = 0;
	public static var playershit:Int = 0;
	var displayedHealth:Float = 0;
	var focusshit:String = '';

	var misscombo:Int = 0;
	public var charSelection:Int = CharSelectState.curSelected;
	//var notecomboshit:Int = 0;
	var scoreshit:Int = 0;
	//var focusedChar:Null<Character>=null;
	public static var ratingStuff:Array<Dynamic> = [
		['NO SINGING?', 0.0001], //SUCK
		['AYO WHAT THE FUCK???', 0.02], //From 0.0001% to 1.99% suck as fuck
		['You Very Suck!!!', 0.1], //From 2% to 9.99%
		['Shit!! >:(', 0.2], //From 10% to 19.99%
		['Ugh! >:/', 0.3], //From 20% to 29.99%
		['Damn... :/', 0.4], //From 30% to 39.99%
		['Bad :(', 0.5], //From 40% to 49.99%
		['Bruh', 0.6], //From 50% to 59.99%
		['D', 0.65], //From 60% to 64.99%
		['D+', 0.7], //From 65% to 69.99%
		['C', 0.75], //From 70% to 74.99%
		['C+', 0.8], //From 75% to 79.99%
		['B', 0.85], //From 80% to 84.99%
		['B+', 0.9], //From 85% to 89.99%
        ['A', 0.925], //From 90% to 92.49%
        ['A+', 0.95], //From 92.5% to 94.99%
        ['S', 0.97], //From 95% to 96.99%
        ['S+', 0.99], //From 97% to 98.99%
        ['SS', 0.995], //From 99% to 99.49%
        ['SS+', 0.999], //From 99.5% to 99.89%
        ['SSS', 0.9995], //From 99.9% to 99.949%
		['SSS+', 1], //From 99.95% to 99.999%
		['Perfect!!! ^o^', 1], //100%
	];
	
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();

	var camMovement:Float = 0.09;

	public var healthStrips:FlxSprite;

	public static var hasPlayedOnce:Bool = false;
	
	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;
	public var highestCombo:Int = 0;

	public var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;
	
	public var epics:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	
	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	private var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyCityLights:FlxTypedGroup<BGSprite>;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:ModchartSprite;
	var blammedLightsBlackTween:FlxTween;
	var phillyCityLightsEvent:FlxTypedGroup<BGSprite>;
	var phillyCityLightsEventTween:FlxTween;
	var trainSound:FlxSound;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	public var judgementCounter:FlxText; //credit https://github.com/ShadowMario/FNF-PsychEngine/discussions/3707
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	var songLength:Float = 0;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;
	
	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	override public function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1')); //when i finish this mod i am going to rick roll LOL (ADD NONO GO HERE ในช่องค้นหา)
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);
		curStage = PlayState.SONG.stage;
		/*if(ClientPrefs.hideBG){
			curStage = '';
		}*/
		//trace('stage is: ' + curStage);
		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south':
					curStage = 'spooky';
				case 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				default:
					curStage = 'stage';
			}
		}
		if(ClientPrefs.hideBG){
			curStage = '';
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100]
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}

			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				CoolUtil.precacheSound('thunder_1');
				CoolUtil.precacheSound('thunder_2');

			case 'philly': //Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}
				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<BGSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:BGSprite = new BGSprite('philly/win' + i, city.x, city.y, 0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					phillyCityLights.add(light);
				}

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				CoolUtil.precacheSound('train_passes');
				FlxG.sound.list.add(trainSound);

				var street:BGSprite = new BGSprite('philly/street', -40, 50);
				add(street);

			case 'limo': //Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					CoolUtil.precacheSound('dancerdeath');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				CoolUtil.precacheSound('Lights_Shut_off');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/
				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}
			//default:
				/*switch(charSelection){
					case 0:
						GameOverSubstate.characterName = 'bf';
					case 1:
						GameOverSubstate.characterName = 'bf';
					case 2:
						GameOverSubstate.characterName = 'bf';
					case 3:
						GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
						GameOverSubstate.loopSoundName = 'gameOver-pixel';
						GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
						GameOverSubstate.characterName = 'bf-pixel-dead';
				}*/
		}

		/*switch(charSelection){
			case 0:
				GameOverSubstate.characterName = 'bf';
			case 1:
				GameOverSubstate.characterName = 'bf';
			case 2:
				GameOverSubstate.characterName = 'bf';
			case 3:
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';
		}*/

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dadGroup);
		add(boyfriendGroup);
		
		if(curStage == 'spooky') {
			add(halloweenWhite);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		if(curStage == 'philly') {
			phillyCityLightsEvent = new FlxTypedGroup<BGSprite>();
			for (i in 0...5)
			{
				var light:BGSprite = new BGSprite('philly/win' + i, -10, 0, 0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				phillyCityLightsEvent.add(light);
			}
		}


		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		

		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));
		#end

		if(!modchartSprites.exists('blammedLightsBlack')) { //Creates blammed light black fade in case you didn't make your own
			blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
			blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			var position:Int = members.indexOf(gfGroup);
			if(members.indexOf(boyfriendGroup) < position) {
				position = members.indexOf(boyfriendGroup);
			} else if(members.indexOf(dadGroup) < position) {
				position = members.indexOf(dadGroup);
			}
			insert(position, blammedLightsBlack);

			blammedLightsBlack.wasAdded = true;
			modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
		}
		if(curStage == 'philly') insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
		blammedLightsBlack = modchartSprites.get('blammedLightsBlack');
		blammedLightsBlack.alpha = 0.0;

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		gf = new Character(0, 0, gfVersion);
		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);
		startCharacterLua(gf.curCharacter);

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);
		
		boyfriend = new Boyfriend(0, 0, SONG.player1);
		switch(charSelection)
		{
			/*case -1:
				boyfriend = new Boyfriend(0, 0, SONG.player1);*/
			case 0:
				boyfriend = new Boyfriend(0, 0, 'bf');
				GameOverSubstate.characterName = 'bf';
			case 1:
				boyfriend = new Boyfriend(0, 0, 'bf-car');
				GameOverSubstate.characterName = 'bf';
			case 2:
				boyfriend = new Boyfriend(0, 0, 'bf-christmas');
				GameOverSubstate.characterName = 'bf';
			case 3:
				boyfriend = new Boyfriend(0, 0, 'bf-pixel');
				/*GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';*/
				GameOverSubstate.characterName = 'bf-pixel-dead';
			case 4:
				boyfriend = new Boyfriend(0, 0, SONG.player1);
			default:
				boyfriend = new Boyfriend(0, 0, SONG.player1);
		}
		if(isStoryMode || !ClientPrefs.characterselect){
			boyfriend = new Boyfriend(0, 0, SONG.player1);
		}
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);
		
		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];

		if(ClientPrefs.hideBG){
			gf.visible = false;
			dad.visible = false;
			boyfriend.visible = false;
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				insert(members.indexOf(gfGroup) - 1, fastCar);
			
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF); //WOW ZA XD
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		//add(timeBar);
		//add(timeTxt);
		timeBarBG.sprTracker = timeBar;

			switch (songName) //timebar LOL
			{
				case 'spookeez' | 'south':
					timeBar.createFilledBar(0xFFBEBEBE, 0xFFD57E00);
					add(timeBar);
					add(timeTxt);
				case 'monster' | 'winter-horrorland':
					timeBar.createFilledBar(0xFF000000, 0xFFF3FF6E);
					add(timeBar);
					add(timeTxt);
				case 'pico' | 'blammed' | 'philly' | 'philly-nice': 
					timeBar.createFilledBar(0xFF000000, 0xFFB7D855);
					add(timeBar);
					add(timeTxt);
				case 'milf' | 'satin-panties' | 'high':
					timeBar.createFilledBar(0xFF000000, 0xFFD8558E);
					add(timeBar);
					add(timeTxt);
				case 'cocoa' | 'eggnog':
					timeBar.createFilledBar(0xFF000000, 0xFF8A2BE2); 
					add(timeBar);
					add(timeTxt);
				case 'senpai' | 'roses':
					timeBar.createFilledBar(0xFF000000, 0xFFFFAA6F);
					add(timeBar);
					add(timeTxt);
				case 'thorns':
					timeBar.createFilledBar(0xFF000000, 0xFFFF326E);
					add(timeBar);
					add(timeTxt);
				case 'tutorial':
					timeBar.createFilledBar(0xFF000000, 0xFFA5004D); 
					add(timeBar);
					add(timeTxt);
				case 'bopeebo' | 'fresh' | 'dad-battle':
					timeBar.createFilledBar(0xFF000000, 0xFFAF66CE); 
					add(timeBar);
					add(timeTxt);
				case 'first-rapping' | 'being-serious' :
					timeBar.createFilledBar(0xFF000000, 0xFFCC6600); 
					add(timeBar);
					add(timeTxt);
				default:
					timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
					add(timeBar);
					add(timeTxt);
			}

		add(timeBar);
		add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		//var displayedHealth:Float = 0;
		/*displayedHealth = FlxMath.lerp(displayedHealth, health ,CoolUtil.boundTo(elapsed * 48, 0, 1));
		displayedHealth = health;*/

		displayedHealth = 1;

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;
		
		healthnumlol = new FlxText(0, healthBarBG.y - 75, 0, "", 12);
		healthnumlol.visible = !ClientPrefs.hideHud;
		if(ClientPrefs.downScroll) healthnumlol.y = 10;
		healthnumlol.cameras = [camHUD];
		healthnumlol.text = 'Health : ${Highscore.floorDecimal(((displayedHealth / 2) * 100), 2)} %';
		healthnumlol.scrollFactor.set();
		healthnumlol.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		healthnumlol.screenCenter(X);
		if(ClientPrefs.healthnum) add(healthnumlol);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'displayedHealth', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		healthStrips = new FlxSprite().loadGraphic(Paths.image('wo')); //credit to https://github.com/ShadowMario/FNF-PsychEngine/discussions/7353
		healthStrips.y = FlxG.height * 0.89;
		healthStrips.screenCenter(X);
		healthStrips.scrollFactor.set();
		healthStrips.visible = !ClientPrefs.hideHud;
		healthStrips.color = FlxColor.BLACK;
		healthStrips.blend = MULTIPLY;
		healthStrips.x = healthBarBG.x-1.9;
   
		add(healthStrips);
		if(ClientPrefs.downScroll) healthStrips.y = 0.11 * FlxG.height;

		healthBarBG.y -= 25;
		healthBar.y -= 25;
		healthStrips.y -= 25;
		healthnumlol.y -= 25;
		healthBarBG.alpha = 0;
		healthBar.alpha = 0;
		healthStrips.alpha = 0;
		healthnumlol.alpha = 0;
		FlxTween.tween(healthBarBG, {y: healthBarBG.y + 25, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.4});
		FlxTween.tween(healthBar, {y: healthBar.y + 25, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.4});
		FlxTween.tween(healthStrips, {y: healthStrips.y + 25, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.4});
		FlxTween.tween(healthnumlol, {y: healthnumlol.y + 25, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.4});

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 85;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = 0;
		add(iconP1);
		FlxTween.tween(iconP1, {y: iconP1.y + 35, alpha: ClientPrefs.healthBarAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.4});

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 85;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = 0;
		add(iconP2);
		FlxTween.tween(iconP2, {y: iconP2.y + 35, alpha: ClientPrefs.healthBarAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.4});
		reloadHealthBarColors();

		scoreTxt = new FlxText(0,0, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("PhantomMuff.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		scoreTxt.alpha = 0;
		scoreTxt.y = healthBarBG.y;
		//FlxTween.tween(scoreTxt, {y: scoreTxt.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut});

		judgementCounter = new FlxText(-25, 0, 0, "", 18); //https://github.com/ShadowMario/FNF-PsychEngine/discussions/3707 so COOL LOL
		judgementCounter.setFormat(Paths.font("PhantomMuff.ttf"), 18, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.alpha = 0;
		judgementCounter.text = 'Highest Combo: ${highestCombo}\nEpics: ${epics}\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${songMisses}\nCombo Breaks: ${songMisses}';
		// add(judgementCounter);
		if(ClientPrefs.judgementcounter && !ClientPrefs.hideHud){
			add(judgementCounter);
			FlxTween.tween(judgementCounter, {x: 25, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.4});
		}
		add(scoreTxt);
		FlxTween.tween(scoreTxt, {y: scoreTxt.y + 65, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.4});

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "[NEVER GINNA GIVE YOU UP]\n[NEVER LETS YOU DOWN]\n[NEVER GONNA RUN AROUND]\n[AND DESERT YOU]", 32);
		botplayTxt.setFormat(Paths.font("PhantomMuff.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthStrips.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;


		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		
		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				default:
					startCountdown();
			}
			seenCutscene = true;
		} else {
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) CoolUtil.precacheSound('ChartingTick');
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);
		
		super.create();
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		return value;
	}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
			
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(!gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush)
		{
			for (lua in luaArray)
			{
				if(lua.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				if(endingSong) {
					endSong();
				} else {
					startCountdown();
				}
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
		}
		#end
		if(endingSong) {
			endSong();
		} else {
			startCountdown();
		}
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogueFile, song);
			doof.scrollFactor.set();
			if(endingSong) {
				doof.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				doof.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			doof.nextDialogueThing = startNextDialogue;
			doof.skipDialogueThing = skipDialogue;
			doof.cameras = [camHUD];
			add(doof);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownthree:FlxSprite; //3
	public var countdownReady:FlxSprite; //2
	public var countdownSet:FlxSprite; //1
	public var countdownGo:FlxSprite; //go!!!

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (tmr.loopsLeft % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
				{
					gf.dance();
				}
				if(tmr.loopsLeft % 2 == 0) {
					if (boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing'))
					{
						boyfriend.dance();
					}
					if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
					{
						dad.dance();
					}
				}
				else if(dad.danceIdle && dad.animation.curAnim != null && !dad.stunned && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing"))
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['3', '2', '1', 'go']);
				introAssets.set('pixel', ['pixelUI/3-pixel', 'pixelUI/2-pixel', 'pixelUI/1-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);
	
					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
						countdownthree = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownthree.scrollFactor.set();
						countdownthree.updateHitbox();

						if (PlayState.isPixelStage)
							countdownthree.setGraphicSize(Std.int(countdownthree.width * daPixelZoom));

						countdownthree.screenCenter();
						countdownthree.antialiasing = antialias;
						add(countdownthree);
						FlxTween.tween(countdownthree, {/*y: countdownRead.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownthree);
								countdownthree.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						add(countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						add(countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						add(countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = note.multAlpha;
					if(ClientPrefs.middleScroll && !note.mustPress) {
						note.alpha *= 0.5;
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		
		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
		
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:Array<Dynamic> = [newEventNote[0] + ClientPrefs.noteOffset - eventNoteEarlyTrigger(newEventNote), newEventNote[1], newEventNote[2], newEventNote[3]];
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var char:String;
				if(gottaHitNote)
					char = SONG.player1;
				else
					char = SONG.player2; //credit https://github.com/ShadowMario/FNF-PsychEngine/discussions/6060

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, char);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
				
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var char:String;
						if(gottaHitNote)
							char = SONG.player1;
						else
							char = SONG.player2;

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true, false, char);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
						
						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1)
							{ //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:Array<Dynamic> = [newEventNote[0] + ClientPrefs.noteOffset - eventNoteEarlyTrigger(newEventNote), newEventNote[1], newEventNote[2], newEventNote[3]];
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:Array<Dynamic>) {
		switch(event[1]) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event[2].toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event[2]);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event[3];
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event[1])) {
			eventPushedMap.set(event[1], true);
		}
	}

	function eventNoteEarlyTrigger(event:Array<Dynamic>):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event[1]]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event[1]) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var targetAlpha:Float = 1;
			if (player != 1 && ClientPrefs.middleScroll) targetAlpha = 0.35;
				
			var char:String;
			//var alpha:Float = 0;//
			//targetAlpha = alpha;
			if(player == 1){
				char = SONG.player1;
				playershit = 1;
			}
				/*char = SONG.player1;
				playershit = 1;*/
			else{
				char = SONG.player2;
				playershit = 2;
			}
			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player, char);
			//alpha = 0.3;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				if(!ClientPrefs.middleScroll){
					if(player != 1){
						babyArrow.alpha = 0; //oppoment
						FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.4 + (0.15 * (3 - i))});
					}
					if(player == 1){
						babyArrow.alpha = 0; //bf
						FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.4 + (0.15 * i)});
					}
				}
				if(ClientPrefs.middleScroll){
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.4 + (0.15 * i)});
				}
			}			
			else
			{
				babyArrow.alpha = targetAlpha;
			}
			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{		
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}
			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = false;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = true;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = true;
			
			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/

		//moveCamera(false);

		/*if(FlxG.keys.justPressed.SPACE){
			boyfriend.playAnim('hey', true);
            boyfriend.specialAnim = true;
			boyfriend.heyTimer = 3;
			FlxG.sound.play(Paths.sound('confirmMenu'));
		}*/
		updatecam();
		healthnumlol.text = 'Health : ${Highscore.floorDecimal(((displayedHealth / 2) * 100), 2)} %';
		//healthnumlol.screenCenter(X);

		if(displayedHealth >= 2) {
			healthnumlol.text = 'Health : 100 %';
			displayedHealth = 2;
			//healthnumlol.screenCenter(X);
		}
		if(displayedHealth <= 0) {
			healthnumlol.text = 'Health : 0 %';
			displayedHealth = 0;
			//ealthnumlol.screenCenter(X);
		}
		healthnumlol.screenCenter(X);
		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		var lol:Bool = false;
		if(boyfriend.animation.curAnim.name == 'dodge'){
			lol = true;
		}
		if(FlxG.keys.justPressed.SPACE && !lol && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')){
			//trace(lol);
			boyfriend.playAnim('hey');
            boyfriend.specialAnim = true;
			boyfriend.heyTimer = 1.5;
			//FlxG.sound.play(Paths.sound('cheer'), 0.45);
		}
		//trace(lol);
		super.update(elapsed);
		//displayedHealth = 50;
		displayedHealth = FlxMath.lerp(displayedHealth, health ,CoolUtil.boundTo(elapsed * 8, 0, 1));
		//displayedHealth = health;

		//resultaccuracy = Highscore.floorDecimal(ratingPercent  * 100, 2);
		//var scoreshit:Int = 0;
		scoreshit = Math.ceil(FlxMath.lerp(scoreshit, songScore, CoolUtil.boundTo(elapsed * 35, 0, 1)));
		resultaccuracy =  Highscore.floorDecimal(FlxMath.lerp(resultaccuracy, Highscore.floorDecimal(ratingPercent * 100, 2),  CoolUtil.boundTo(elapsed * 35, 0, 1)), 2);
		//resultaccuracy = Highscore.floorDecimal(ratingPercent  * 100, 2);
		if(ratingName == '?') {
			scoreTxt.text = 'Score:  ' + scoreshit + '  | Combo Breaks:  ' + songMisses + '  | Accuracy: 0%' + '  |  ' + 'Rank: N/A';
		}
		else {
			scoreTxt.text = 'Score:  ' + scoreshit + '  | Combo Breaks:  ' + songMisses + '  | Accuracy:  '+ resultaccuracy +'%' + '  |  ' + 'Rank: ' + ratingName + '  [' + ratingFC + ']';
		}
		
		if(ClientPrefs.judgementcounter){
			if(ratingName == '?') {
				scoreTxt.text = 'Score:  ' + scoreshit + '  | Accuracy: 0%' + '  |  ' + 'Rank: N/A';
			}
			else {
				scoreTxt.text = 'Score:  ' + scoreshit + '  | Accuracy: '  + resultaccuracy + '%' + '  |  ' + 'Rank: ' + ratingName + ' [' + ratingFC + ']';
			}
		}
		//trace(resultaccuracy);
		RecalculateRating();

		//accuracypopuplol();

		//resultaccuracy = (Highscore.floorDecimal(ratingPercent * 100, 2));

		//scoreTxt.text = 'Score: ' + songScore + '          Misses: ' + songMisses; //Challenge mode :O maybe lol

		

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				/*if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					cancelMusicFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					MusicBeatState.switchState(new GitarooPause());
				}
				else {*/
				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					vocals.pause();
				}
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				//}
		
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}


		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene) //NONO GOHERE
		{
			openChartEditor(); //SEARCH THIS
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if (health > 2)
			health = 2;

		if (health < 0)
			health = 0;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		//resultaccuracy = Highscore.floorDecimal(ratingPercent  * 100, 2);

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}
		//resultaccuracy = Highscore.floorDecimal(ratingPercent  * 100, 2);

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		var roundedSpeed:Float = FlxMath.roundDecimal(songSpeed, 2);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 1500;
			if(roundedSpeed < 1) time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				/*if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}*/

				// i am so fucking sorry for this if condition
				var strumX:Float = 0;
				var strumY:Float = 0;
				var strumAngle:Float = 0;
				var strumAlpha:Float = 0;
				if(daNote.mustPress) {
					strumX = playerStrums.members[daNote.noteData].x;
					strumY = playerStrums.members[daNote.noteData].y;
					strumAngle = playerStrums.members[daNote.noteData].angle;
					strumAlpha = playerStrums.members[daNote.noteData].alpha;
				} else {
					strumX = opponentStrums.members[daNote.noteData].x;
					strumY = opponentStrums.members[daNote.noteData].y;
					strumAngle = opponentStrums.members[daNote.noteData].angle;
					strumAlpha = opponentStrums.members[daNote.noteData].alpha;
				}

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;
				var center:Float = strumY + Note.swagWidth / 2;

				if(daNote.copyX) {
					daNote.x = strumX;
				}
				if(daNote.copyAngle) {
					daNote.angle = strumAngle;
				}
				if(daNote.copyAlpha) {
					daNote.alpha = strumAlpha;
				}
				if(daNote.copyY) {
					if (ClientPrefs.downScroll) {
						daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
						if (daNote.isSustainNote && !ClientPrefs.keSustains) {
							//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8;
								} else {
									daNote.y -= 19;
								}
							} 
							daNote.y += (Note.swagWidth / 2) - (60.5 * (roundedSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);

							if(daNote.mustPress || !daNote.ignoreNote)
							{
								if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}
					} else {
						daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

						if(!ClientPrefs.keSustains)
						{
							if(daNote.mustPress || !daNote.ignoreNote)
							{
								if (daNote.isSustainNote
									&& daNote.y + daNote.offset.y * daNote.scale.y <= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (center - daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * songSpeed));

				var doKill:Bool = daNote.y < -daNote.height;
				if(ClientPrefs.downScroll) doKill = daNote.y > FlxG.height;

				if(ClientPrefs.keSustains && daNote.isSustainNote && daNote.wasGoodHit) doKill = true;

				if (doKill)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		if (!inCutscene) {
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
			}
		}
		
		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime + 800 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime + 800 >= Conductor.songPosition) {
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	function openChartEditor() //AAAAAA FAK
	{
		persistentUpdate = false; //if you release mod delete this lol
		paused = true;
		cancelMusicFadeTween();
		CustomFadeTransition.nextCamera = camOther;
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || displayedHealth <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0][0];
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0][2] != null)
				value1 = eventNotes[0][2];

			var value2:String = '';
			if(eventNotes[0][3] != null)
				value2 = eventNotes[0][3];

			triggerEventNote(eventNotes[0][1], value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value)) value = 1;
				gfSpeed = value;

			case 'Blammed Lights':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				if(lightId > 0 && curLightEvent != lightId) {
					if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);

					var color:Int = 0xffffffff;
					switch(lightId) {
						case 1: //Blue
							color = 0xff31a2fd;
						case 2: //Green
							color = 0xff31fd8c;
						case 3: //Pink
							color = 0xfff794f7;
						case 4: //Red
							color = 0xfff96d63;
						case 5: //Orange
							color = 0xfffba633;
					}
					curLightEvent = lightId;

					if(blammedLightsBlack.alpha == 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = FlxTween.color(chars[i], 1, FlxColor.WHITE, color, {onComplete: function(twn:FlxTween) {
								chars[i].colorTween = null;
							}, ease: FlxEase.quadInOut});
						}
					} else {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = null;
						blammedLightsBlack.alpha = 1;

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = null;
						}
						dad.color = color;
						boyfriend.color = color;
						gf.color = color;
					}
					
					if(curStage == 'philly') {
						if(phillyCityLightsEvent != null) {
							phillyCityLightsEvent.forEach(function(spr:BGSprite) {
								spr.visible = false;
							});
							phillyCityLightsEvent.members[lightId - 1].visible = true;
							phillyCityLightsEvent.members[lightId - 1].alpha = 1;
						}
					}
				} else {
					if(blammedLightsBlack.alpha != 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});
					}

					if(curStage == 'philly') {
						phillyCityLights.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});
						phillyCityLightsEvent.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});

						var memb:FlxSprite = phillyCityLightsEvent.members[curLightEvent - 1];
						if(memb != null) {
							memb.visible = true;
							memb.alpha = 1;
							if(phillyCityLightsEventTween != null)
								phillyCityLightsEventTween.cancel();

							phillyCityLightsEventTween = FlxTween.tween(memb, {alpha: 0}, 1, {onComplete: function(twn:FlxTween) {
								phillyCityLightsEventTween = null;
							}, ease: FlxEase.quadInOut});
						}
					}

					var chars:Array<Character> = [boyfriend, gf, dad];
					for (i in 0...chars.length) {
						if(chars[i].colorTween != null) {
							chars[i].colorTween.cancel();
						}
						chars[i].colorTween = FlxTween.color(chars[i], 1, chars[i].color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
							chars[i].colorTween = null;
						}, ease: FlxEase.quadInOut});
					}

					curLight = 0;
					curLightEvent = 0;
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				//nonfocus = true;
				focusshit = 'none';

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}
				//focusshit = 'none';

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.idleSuffix = value2;
				char.recalculateDanceIdle();

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

					switch(charType) {
						case 0:
							if(boyfriend.curCharacter != value2) {
								if(!ClientPrefs.hideBG){
									if(!boyfriendMap.exists(value2)) {
										addCharacterToList(value2, charType);
									}
								
									var lastAlpha:Float = boyfriend.alpha;
									boyfriend.alpha = 0.00001;
									boyfriend = boyfriendMap.get(value2);
									boyfriend.alpha = lastAlpha;
								}
								/*if(!boyfriendMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = boyfriend.alpha;
								boyfriend.alpha = 0.00001;
								boyfriend = boyfriendMap.get(value2);
								boyfriend.alpha = lastAlpha;*/
								iconP1.changeIcon(boyfriend.healthIcon);
							}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

						case 1:
							if(dad.curCharacter != value2) {
								/*if(!dadMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var wasGf:Bool = dad.curCharacter.startsWith('gf');
								var lastAlpha:Float = dad.alpha;
								dad.alpha = 0.00001;
								dad = dadMap.get(value2);
								if(!dad.curCharacter.startsWith('gf')) {
									if(wasGf) {
										gf.visible = true;
									}
								} else {
									gf.visible = false;
								}
								dad.alpha = lastAlpha;*/
								if(!ClientPrefs.hideBG){
									if(!dadMap.exists(value2)) {
										addCharacterToList(value2, charType);
									}
								
									var wasGf:Bool = dad.curCharacter.startsWith('gf');
									var lastAlpha:Float = dad.alpha;
									dad.alpha = 0.00001;
									dad = dadMap.get(value2);
									if(!dad.curCharacter.startsWith('gf')) {
										if(wasGf) {
											gf.visible = true;
										}
									} else {
										gf.visible = false;
									}
									dad.alpha = lastAlpha;
								}
								
								iconP2.changeIcon(dad.healthIcon);
							}
							setOnLuas('dadName', dad.curCharacter);

						case 2:
							if(gf.curCharacter != value2) {
								/*if(!gfMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;*/
								if(!ClientPrefs.hideBG){
									if(!gfMap.exists(value2)) {
										addCharacterToList(value2, charType);
									}
								
									var lastAlpha:Float = gf.alpha;
									gf.alpha = 0.00001;
									gf = gfMap.get(value2);
									gf.alpha = lastAlpha;
								}
								
							}
							setOnLuas('gfName', gf.curCharacter);
					}
				reloadHealthBarColors();
			
			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();
			
			case 'Change Scroll Speed':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (SONG.notes[id].gfSection)
		{
			/*camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0];
			camFollow.y += gf.cameraPosition[1];*/
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			focusshit = 'gf';
			return;
		}

		if (!SONG.notes[id].mustHitSection)
		{
			//moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
			focusshit = 'dad';
		}
		else
		{
			//moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
			focusshit = 'bf';
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{

		if(isDad)
		{
			/*camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + noteHitX;
			camFollow.y += dad.cameraPosition[1] + noteHitY;*/
			//tweenCamIn();
			//race(notecomboshit);
			//notecomboshit = 0;
		}
		else
		{
			/*camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}

			camFollow.x -= boyfriend.cameraPosition[0] - noteHitX;
			camFollow.y += boyfriend.cameraPosition[1] + noteHitY;*/

			/*if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}**/
			/*trace(notecomboshit);
			notecomboshit = 0;*/
		}
	}

	function updatecam(){ //from andromeda lol imsorry
		var focusedChar:Null<Character>=null;
		switch (focusshit)
		{
			case 'gf':
				focusedChar = gf;
				camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
				camFollow.x += gf.cameraPosition[0];
				camFollow.y += gf.cameraPosition[1];
			case 'dad':
				focusedChar = dad;
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.cameraPosition[0];
				camFollow.y += dad.cameraPosition[1];
				//tweenCamIn();
			case 'bf':
				focusedChar = boyfriend;
				camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school' | 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}	

				camFollow.x -= boyfriend.cameraPosition[0];
				camFollow.y += boyfriend.cameraPosition[1];
				
				if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
					{
						cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
							function (twn:FlxTween)
							{
								cameraTwn = null;
							}
						});
					}
			case 'none':

		}
		if(ClientPrefs.movecamera && focusedChar != null){
			if(focusedChar.animation.curAnim != null){
			switch (focusedChar.animation.curAnim.name){
				case 'singUP' | 'singUP-alt' | 'singUPmiss':
					camFollow.y -= 20;
				case 'singDOWN' | 'singDOWN-alt' | 'singDOWNmiss':
					camFollow.y += 20;
				case 'singLEFT' | 'singLEFT-alt' | 'singLEFTmiss':
					camFollow.x -= 20;
				case 'singRIGHT' | 'singRIGHT-alt' | 'singRIGHTmiss':
					camFollow.x += 20;
				}
			}
		}
	}
	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}
		
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger',
				'first_song', 'first_song_FC', 'second_song', 'second_song_FC', 'bot_play']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		
		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				if (!practiceMode && !cpuControlled) {
					#if !switch
					var percent:Float = ratingPercent;
					if(Math.isNaN(percent)) percent = 0;
					Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
					#end
				}
			}

			if (chartingMode)
			{
				openChartEditor(); // SHIT i SHOULD DELETE THIS
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
					//MusicBeatState.switchState(new FreeplayState());
					LoadingState.loadAndSwitchState(new ResultState(), true);
					//FlxG.sound.playMusic(Paths.music('freakyMenu'));
					changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	var prevCurrentTimingShown:FlxText;
	var numscoregroup:FlxGroup = new FlxGroup();
	var combogroup:FlxGroup = new FlxGroup();
	var lastRating:FlxSprite = new FlxSprite();
	var ratingTween:FlxTween;
	var lastcombosprite:FlxSprite = new FlxSprite();
	var combosprite:FlxSprite = new FlxSprite();
	var numScore:FlxSprite = new FlxSprite();
	var sussyseperatedScore:Array<Int> = [];
	
	private function popUpScore(note:Note = null):Void
	{
		//accuracypopuplol();
		misscombogroup.destroy();
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));
		if (ClientPrefs.sussycombo) lastRating.destroy();
		var MSROLL:Float = (note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 0;

		var msforscorelol = CoolUtil.truncateFloat(noteDiff, 2);

		//tryna do MS based judgment due to popular demand
		var daRating:String = Conductor.judgeNote(note, noteDiff);

		if(ClientPrefs.accuracy == 'Normal')
		{
			switch (daRating)
			{
			case "shit": // shit
				score += 0;
				totalNotesHit += 0.05;
				shits++;
			case "bad": // bad
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				totalNotesHit += 0.30;
				bads++;
			case "good": // good
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				totalNotesHit += 0.65;
				goods++;
			case "sick": // sick
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				totalNotesHit += 0.925;
				sicks++;
			case "epic": //epic
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				totalNotesHit += 1;
				epics++;
			}
		}

		if(ClientPrefs.accuracy == 'Apro Engine')
		{
			switch (daRating)
			{
			case "shit": // shit
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				//totalNotesHit += (1 - (noteDiff / 166));
				shits++;
                if(noteDiff < 166){
                	totalNotesHit += (1 - (noteDiff / 166));
                }
                if(noteDiff >= 166){
                	totalNotesHit += 0;
				}
			case "bad": // bad
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				//totalNotesHit += (1 - (noteDiff / 200));
				bads++;
				if(noteDiff < 90){
                	totalNotesHit += (1 - (noteDiff / 200));
                }
				if(noteDiff >= 90 && noteDiff < 120){
                	totalNotesHit += (1 - (noteDiff / 180));
                }
				if(noteDiff >= 120){
                	totalNotesHit += (1 - (noteDiff / 170));
                }
				if(noteDiff >= 135){
                	totalNotesHit += (1 - (noteDiff / 166));
                }
			case "good": // good
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				//totalNotesHit += (1 - (noteDiff / 350));
				goods++;
				if(noteDiff < 45){
                	totalNotesHit += (1 - (noteDiff / 350));
                }
				if(noteDiff >= 45 && noteDiff < 60){
                	totalNotesHit += (1 - (noteDiff / 300));
                }
				if(noteDiff >= 60 && noteDiff < 75){
                	totalNotesHit += (1 - (noteDiff / 250));
                }
                if(noteDiff >= 75){
                	totalNotesHit += (1 - (noteDiff / 200));
				}
				if(noteDiff >= 90){
                	totalNotesHit += (1 - (noteDiff / 200));
				}
			case "sick": // sick
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				totalNotesHit += 1;
				sicks++;
			case "epic": //epic
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				totalNotesHit += 1;
				epics++;
			}
		}

		if(ClientPrefs.accuracy == 'Apro (Alternate)')
		{
			switch (daRating)
			{
			case "shit": // shit
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				//totalNotesHit += (1 - (noteDiff / 166));
				shits++;
                if(noteDiff < 166){
                	totalNotesHit += (1 - (noteDiff / 166));
                }
                if(noteDiff >= 166){
                	totalNotesHit += 0;
				}
			case "bad": // bad
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				//totalNotesHit += (1 - (noteDiff / 200));
				bads++;
				if(noteDiff < 90){
                	totalNotesHit += (1 - (noteDiff / 200));
                }
				if(noteDiff >= 90 && noteDiff < 120){
                	totalNotesHit += (1 - (noteDiff / 180));
                }
				if(noteDiff >= 120){
                	totalNotesHit += (1 - (noteDiff / 170));
                }
				if(noteDiff >= 135){
                	totalNotesHit += (1 - (noteDiff / 166));
                }
			case "good": // good
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				//totalNotesHit += (1 - (noteDiff / 1000));
				goods++;
				if(noteDiff < 45){
                	totalNotesHit += (1 - (noteDiff / 1000));
                }
				if(noteDiff >= 45 && noteDiff < 60){
                	totalNotesHit += (1 - (noteDiff / 750));
                }
				if(noteDiff >= 60 && noteDiff < 75){
                	totalNotesHit += (1 - (noteDiff / 500));
                }
                if(noteDiff >= 75){
                	totalNotesHit += (1 - (noteDiff / 250));
				}
				if(noteDiff >= 90){
                	totalNotesHit += (1 - (noteDiff / 200));
				}
			case "sick": // sick
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				//totalNotesHit += 1;
				sicks++;
				if(noteDiff < 25){
                	totalNotesHit += (1 - (noteDiff / 25000));
				}
                if(noteDiff >= 25 && noteDiff < 35){
                	totalNotesHit += (1 - (noteDiff / 10000));
				}
				if(noteDiff >= 35 && noteDiff < 45){
                	totalNotesHit += (1 - (noteDiff / 2500));
				}
				if(noteDiff >= 45){
                	totalNotesHit += (1 - (noteDiff / 1000));
				}
			case "epic": //epic
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				//totalNotesHit += 1;
				epics++;
				if(noteDiff < 10){
                	totalNotesHit += 1;
				}
                if(noteDiff >= 10){
                	totalNotesHit += (1 - (noteDiff / 25000));
				}
			}
		}

		if(ClientPrefs.accuracy == 'Simple')
			{
				switch (daRating)
				{
				case "shit": // shit
					score += Math.ceil(500 * ((135 - msforscorelol) / 135));
					totalNotesHit += 1;
					shits++;
				case "bad": // bad
					score += Math.ceil(500 * ((135 - msforscorelol) / 135));
					totalNotesHit += 1;
					bads++;
				case "good": // good
					score += Math.ceil(500 * ((135 - msforscorelol) / 135));
					totalNotesHit += 1;
					goods++;
				case "sick": // sick
					score += Math.ceil(500 * ((135 - msforscorelol) / 135));
					totalNotesHit += 1;
					sicks++;
				case "epic": //epic
					score += Math.ceil(500 * ((135 - msforscorelol) / 135));
					totalNotesHit += 1;
					epics++;
				}
			}
		
		if(ClientPrefs.accuracy == 'Complex'){
            switch (daRating)
            {
            case "shit": // shit
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				//totalNotesHit += (1 - (noteDiff / 50));
                shits++;
                if(noteDiff < 150){
                	totalNotesHit += (1 - (noteDiff / 50));
                }
                if(noteDiff >= 150){
                	totalNotesHit += (1 - (noteDiff / 50));
				}
			case "bad": // bad
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				//totalNotesHit += (1 - (noteDiff / 50));
                bads++;
                if(noteDiff < 120){
                    totalNotesHit += (1 - (noteDiff / 50));
                }
                if(noteDiff >= 120){
                    totalNotesHit += (1 - (noteDiff / 50));
				}
			case "good": // good
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				//totalNotesHit += (1 - (noteDiff / 250));
                goods++;
                if(noteDiff < 55){
                    totalNotesHit += (1 - (noteDiff / 250));
                }
				if(noteDiff >= 55 && noteDiff < 70){
                    totalNotesHit += (1 - (noteDiff / 150));
            	}
            	if(noteDiff >= 70){
                    totalNotesHit += (1 - (noteDiff / 50));
				}
			case "sick": // sick
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				//totalNotesHit += (1 - (noteDiff / 5000));
                sicks++;
                if(noteDiff < 20){
                    totalNotesHit += (1 - (noteDiff / 7500));
                }
				if(noteDiff >= 20 && noteDiff < 25){
                    totalNotesHit += (1 - (noteDiff / 7500));
                }
				if(noteDiff >= 25 && noteDiff < 30){
                    totalNotesHit += (1 - (noteDiff / 5000));
                }
                if(noteDiff >= 30 && noteDiff < 40){
                    totalNotesHit += (1 - (noteDiff / 1000));
				}
				if(noteDiff >= 40 && noteDiff < 45){
                    totalNotesHit += (1 - (noteDiff / 250));
				}
				if(noteDiff >= 45){
                    totalNotesHit += (1 - (noteDiff / 100));
				}
			case "epic": //epic
                score += Math.ceil(500 * ((135 - msforscorelol) / 135));
                //totalNotesHit += (1 - (noteDiff / 100000));
                epics++;
                if(noteDiff < 5){
                    totalNotesHit += 1;
                }
				if(noteDiff >= 5 && noteDiff < 10){
                    totalNotesHit += (1 - (noteDiff / 100000));
				}
				if(noteDiff >= 10 && noteDiff < 15){
                    totalNotesHit += (1 - (noteDiff / 10000));
				}
                if(noteDiff >= 15 && noteDiff < 25){
                    totalNotesHit += (1 - (noteDiff / 7500));
				}
				if(noteDiff >= 25 && noteDiff < 30){
                    totalNotesHit += (1 - (noteDiff / 5000));
				}
				if(noteDiff >= 30){
                    totalNotesHit += (1 - (noteDiff / 1000));
				}
			}
		}

		if(ClientPrefs.accuracy == 'Psych')
		{
			switch (daRating)
			{
			case "shit": // shit
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				totalNotesHit += 0;
				shits++;
			case "bad": // bad
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				totalNotesHit += 0.50;
				bads++;
			case "good": // good
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				totalNotesHit += 0.75;
				goods++;
			case "sick": // sick
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				totalNotesHit += 1;
				sicks++;
			case "epic": //epic
				score += Math.ceil(500 * ((135 - msforscorelol) / 135));
				totalNotesHit += 1;
				epics++;
			}
		}

		if(daRating == 'sick' && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(daRating == 'epic' && !note.noteSplashDisabled)
			{
				spawnNoteSplashOnNote(note);
			}

		//if(!cpuControlled) {//if(!practiceMode && !cpuControlled) {
		songScore += score;
		songHits++;
		totalPlayed++;
		RecalculateRating();

		if(ClientPrefs.scoreZoom)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
					}
				});
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		/*rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);*/
		if(!ClientPrefs.sussycombo){
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
		}
		rating.visible = !ClientPrefs.hideHud;
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var timeShown = 0;
		var currentTimingShown:FlxText = new FlxText();
		var msTiming = CoolUtil.truncateFloat(MSROLL, 2);

		var loop:Int = 0;
		
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combosprite'));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x + (43 * loop) + 180;
		comboSpr.y += 60;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = !ClientPrefs.hideHud;
		comboSpr.x += ClientPrefs.comboOffset[2];
		comboSpr.y -= ClientPrefs.comboOffset[3];

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		insert(members.indexOf(strumLineNotes), rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			//comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			//comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		timeShown = 0;
		var daLoop:Float = 0;
		
		var mstiminwow:Float = Math.abs(msTiming); //2.50
		var numberms:Int = Math.floor(mstiminwow); //2 
		var sussydecimal:Float = CoolUtil.truncateFloat(mstiminwow - numberms, 2); //0.50
		var decimalhundred:Int = Math.floor(sussydecimal * 100);

		var seperatedmsint:Array<Int> = [];		
		if(numberms >= 100) {
			seperatedmsint.push(Math.floor(numberms / 100) % 10);
		}
		if(numberms >= 10) {
			seperatedmsint.push(Math.floor(numberms / 10) % 10);
		}
		if(numberms >= 0) {
			seperatedmsint.push(numberms % 10);
		}

		var seperatedmsdot:Array<Int> = [];
		if(decimalhundred >= 100) {
			seperatedmsint.push(Math.floor(decimalhundred / 100) % 10);
		}
		seperatedmsdot.push(Math.floor(decimalhundred / 10) % 10);
		seperatedmsdot.push(decimalhundred % 10);

		for (i in seperatedmsint){ //i think im too noob to coding some flexible code >:(
			if(ClientPrefs.showTiming && daRating != 'hold' && daRating != 'fail' && !ClientPrefs.hideHud){
				var numMS:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numMS.cameras = [camHUD];
				numMS.screenCenter();
				numMS.x = coolText.x + (43 * daLoop) + 180;
				//numMS.y += 0;
				numMS.x += ClientPrefs.comboOffset[0];
				numMS.y -= ClientPrefs.comboOffset[1];

				var negative:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Negative'));
				negative.cameras = [camHUD];
				negative.screenCenter();
				negative.x += ClientPrefs.comboOffset[0];
				negative.y -= ClientPrefs.comboOffset[1];
				negative.alpha = 0;

				var dot:FlxSprite = new FlxSprite().loadGraphic(Paths.image('point'));
				dot.cameras = [camHUD];
				dot.screenCenter();
				dot.y -= 30;
				dot.x += 50;
				dot.x += ClientPrefs.comboOffset[0];
				dot.y -= ClientPrefs.comboOffset[1];
				dot.alpha = 0;

				if(decimalhundred > 0){
					dot.alpha = 1;
				}

				if(PlayState.isPixelStage)
				{
					negative.y += 60;
					dot.y += 60;
				}

				if(msTiming < 0){
					negative.alpha = 1;
				}

				if(numberms < 10){
					//dot.x += 20;
					if(msTiming < 0){
						dot.x -= 5;
					}
					if(msTiming > 0){
						dot.x -= 5;
					}
				}
				if(numberms >= 10){
					numMS.x -= 40;
					negative.x -= 40;
				}
				if(numberms >= 100){
					numMS.x -= 40;
					negative.x -= 40;
				}

				switch (daRating)
				{
					case 'shit':
						numMS.color = 0x00D3D3D3;
						negative.color = 0x00D3D3D3;
						dot.color = 0x00D3D3D3;
					case 'bad':
						numMS.color = 0x00FF0000;
						negative.color = 0x00FF0000;
						dot.color = 0x00FF0000;
					case 'good':
						numMS.color = 0x0000FF00;
						negative.color = 0x0000FF00;
						dot.color = 0x0000FF00;
					case 'sick':
						numMS.color = 0x0000FFFF;
						negative.color = 0x0000FFFF;
						dot.color = 0x0000FFFF;
					case 'epic':
						numMS.color = 0x00DDA0DD;
						negative.color = 0x00DDA0DD;
						dot.color = 0x00DDA0DD;
					}

				if (!PlayState.isPixelStage)
				{
					numMS.antialiasing = ClientPrefs.globalAntialiasing;
					numMS.setGraphicSize(Std.int(numMS.width * 0.4));
					negative.antialiasing = ClientPrefs.globalAntialiasing;
					negative.setGraphicSize(Std.int(negative.width * 0.4));
					dot.antialiasing = ClientPrefs.globalAntialiasing;
					dot.setGraphicSize(Std.int(negative.width * 0.3));
				}
				else
				{
					numMS.setGraphicSize(Std.int(numMS.width * 5));
					negative.setGraphicSize(Std.int(negative.width * 0.5));
					dot.setGraphicSize(Std.int(dot.width * 1));
				}
				numMS.updateHitbox();
				negative.updateHitbox();
				dot.updateHitbox();

				numMS.acceleration.y = FlxG.random.int(200, 300);
				numMS.velocity.y -= FlxG.random.int(140, 160);
				numMS.visible = !ClientPrefs.hideHud;
				
				negative.acceleration.y = 250;
				negative.velocity.y -= 150;
				negative.visible = !ClientPrefs.hideHud;

				dot.acceleration.y = 250;
				dot.velocity.y -= 150;
				dot.visible = !ClientPrefs.hideHud;

				insert(members.indexOf(strumLineNotes), numMS);
				insert(members.indexOf(strumLineNotes), negative);
				insert(members.indexOf(strumLineNotes), dot);

				FlxTween.tween(numMS, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numMS.destroy();
					},
					startDelay: Conductor.crochet * 0.00075
				});
				FlxTween.tween(negative, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						negative.destroy();
					},
					startDelay: Conductor.crochet * 0.00075
				});
				FlxTween.tween(dot, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						dot.destroy();
					},
					startDelay: Conductor.crochet * 0.00075
				});
				daLoop++;
			}
		}
		// im think im fucking stupid lol
		for(i in seperatedmsdot)
		{
			if(ClientPrefs.showTiming && daRating != 'hold' && daRating != 'fail' && !ClientPrefs.hideHud){
				var dotnumMS:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				dotnumMS.cameras = [camHUD];
				dotnumMS.screenCenter();
				dotnumMS.x = coolText.x + (43 * daLoop) + 180;//180
				//dotnumMS.y += 20;
				dotnumMS.x += ClientPrefs.comboOffset[0];
				dotnumMS.y -= ClientPrefs.comboOffset[1];
				dotnumMS.alpha = 0;
	
				if(decimalhundred > 0){
					dotnumMS.alpha = 1;
				}

				if(numberms < 10){
					dotnumMS.x += 20;
				}

				if(numberms >= 10){
					dotnumMS.x -= 20;
				}
				if(numberms >= 100){
					dotnumMS.x -= 40;
				}
	
				switch (daRating)
				{
					case 'shit':
						dotnumMS.color = 0x00D3D3D3;
					case 'bad':
						dotnumMS.color = 0x00FF0000;
					case 'good':
						dotnumMS.color = 0x0000FF00;
					case 'sick':
						dotnumMS.color = 0x0000FFFF;
					case 'epic':
						dotnumMS.color = 0x00DDA0DD;
					}
	
				if (!PlayState.isPixelStage)
				{
					dotnumMS.antialiasing = ClientPrefs.globalAntialiasing;
					dotnumMS.setGraphicSize(Std.int(dotnumMS.width * 0.4));
				}
				else
				{
					dotnumMS.setGraphicSize(Std.int(dotnumMS.width * 5));
				}
				
				dotnumMS.updateHitbox();
				dotnumMS.acceleration.y = FlxG.random.int(200, 300);
				dotnumMS.velocity.y -= FlxG.random.int(140, 160);
				dotnumMS.visible = !ClientPrefs.hideHud;
	
				insert(members.indexOf(strumLineNotes), dotnumMS);
	
				FlxTween.tween(dotnumMS, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						dotnumMS.destroy();
					},
					startDelay: Conductor.crochet * 0.00075
				});
				daLoop++;
			}
		}

		var seperatedScore:Array<Int> = [];
		//var sussyseperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		if(combo >= 100) {
			seperatedScore.push(Math.floor(combo / 100) % 10);
		}
		if(combo >= 10) {
			seperatedScore.push(Math.floor(combo / 10) % 10);
		}
		seperatedScore.push(combo % 10);

		//it fucking hard holy shit AAAAAAHHHHHH
		//im dumb lol

		//trace(seperatedScore);

		var daloopsussy:Float = 0;

		combosprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 +  'combosprite' + pixelShitPart2));
		combosprite.cameras = [camHUD];
		combosprite.screenCenter();
		combosprite.x = coolText.x - 90;
		combosprite.y += 80;
		combosprite.x += 75;
		combosprite.x += ClientPrefs.comboOffset[2];
		combosprite.y -= ClientPrefs.comboOffset[3];

		combosprite.antialiasing = ClientPrefs.globalAntialiasing;
		combosprite.setGraphicSize(Std.int(combosprite.width * 0.5));

		combosprite.updateHitbox();
		/*combosprite.acceleration.y = FlxG.random.int(200, 300);
		combosprite.velocity.y -= FlxG.random.int(140, 160);
		combosprite.velocity.x = FlxG.random.float(-5, 5);*/
		combosprite.visible = !ClientPrefs.hideHud;

		insert(members.indexOf(strumLineNotes), combosprite);

		/*FlxTween.tween(combosprite, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				combosprite.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});*/

		if(PlayState.isPixelStage){
			combosprite.setGraphicSize(Std.int(combosprite.width * 8));
			combosprite.x += 75;
			combosprite.y += 30;
			combosprite.antialiasing = false;
		}

		if(!ClientPrefs.sussycombo){
			combosprite.acceleration.y = FlxG.random.int(200, 300);
			combosprite.velocity.y -= FlxG.random.int(140, 160);
			combosprite.velocity.x = FlxG.random.float(-5, 5);
			FlxTween.tween(combosprite, {alpha: 0}, 0.2, {ease: FlxEase.circOut, startDelay: Conductor.crochet * 0.001});
		}

		if(ClientPrefs.sussycombo){
			numscoregroup.destroy();
			numscoregroup = new FlxGroup();
			add(numscoregroup);

			combogroup.destroy();
			combogroup = new FlxGroup();
			add(combogroup);
			combogroup.add(combosprite);

			combosprite.y -= 30;
			FlxTween.tween(combosprite, {y: combosprite.y + 30}, 0.2, {
				ease: FlxEase.circOut
			});
			
			lastRating = rating;
			var scaleX = rating.scale.x;
			var scaleY = rating.scale.y;
			rating.scale.scale(1.2);
			if(ratingTween!=null && ratingTween.active){
				ratingTween.cancel();
			}
			ratingTween = FlxTween.tween(rating.scale, {x: scaleX, y: scaleY}, 0.1, {
				onComplete: function(tween:FlxTween)
				{
					if(rating.alive && ratingTween==tween){
						ratingTween = FlxTween.tween(rating.scale, {x: 0, y: 0}, 0.2, {
							onComplete: function(tween:FlxTween)
							{
								rating.kill();
								//rating.destroy();
							},
							ease: FlxEase.quadIn,
							startDelay: 0.6
						});
					}
				},
				ease: FlxEase.quadOut
			});
		}
		var suscombo:Int = -1;
		//trace(suscombo);
		//trace(sussyseperatedScore);

		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			suscombo++;
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daloopsussy) - 90;
			numScore.y += 80;
			numScore.alpha = 1;
			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if(combo >= 10){
				numScore.x -= 40;
			}
			if(combo >= 100){
				numScore.x -= 40;
			}
			if(combo >= 1000){
				numScore.x -= 40;
			}

			if(ClientPrefs.combocolor){
				if(ratingFC == 'EFC')
					{
						numScore.color = 0x00DDA0DD;
					}
					if(ratingFC == 'SFC')
					{
						numScore.color = 0x0099FFFF;
					}
					if(ratingFC == 'GFC')
					{
						numScore.color = 0x0033FF99;
					}
					if(ratingFC == 'FC' || ratingFC == 'SDCB' || ratingFC == 'Clear')
					{
						numScore.color = 0x00FFFFFF;
					}
					if(ratingFC == 'NICE BRO'){
						numScore.color = 0x00FF0099;
					}
			}
			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.visible = !ClientPrefs.hideHud;

			insert(members.indexOf(strumLineNotes), numScore);

			if(!ClientPrefs.sussycombo){

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					}
					,startDelay: Conductor.crochet * 0.002
				});
			}
			if(ClientPrefs.sussycombo){
				numscoregroup.add(numScore);
				if(combo == 10 || combo == 100 || combo == 1000){
					numScore.y -= 30;
					FlxTween.tween(numScore, {y: numScore.y + 30}, 0.2, {
						ease: FlxEase.circOut
					});
				}
				if(combo != 10 && combo != 100 && combo != 1000){
					if(sussyseperatedScore[suscombo] != i){
						numScore.y -= 30;
						FlxTween.tween(numScore, {y: numScore.y + 30}, 0.2, {
							ease: FlxEase.circOut
						});
					}
				}
			}

			daloopsussy++;
			//sussyseperatedScore = seperatedScore;
			//trace(sussyseperatedScore);
		}
 
		sussyseperatedScore = seperatedScore;
		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		
		if(!ClientPrefs.sussycombo)
		{
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.08;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
		}
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 10) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
							
						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else if (canMiss) {
					noteMissPress(key);
					callOnLuas('noteMissPress', [key]);
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}
	
	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];
		
		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			} else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	var sussymissseperatedScore:Array<Int> = [];
	var missTween:FlxTween;
	var lastmisses:FlxSprite = new FlxSprite();
	var misscombogroup:FlxGroup = new FlxGroup();
	
	//ccoolText.x = FlxG.width * 0.35;
	/*function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		misscombo++;
		numscoregroup.destroy();

		if(misscombo > 9999){
			misscombo = 9999;
		}
		combogroup.destroy();
		//numscoregroup.destroy();

		var seperatedmiss:Array<Int> = [];
		if(misscombo >= 1000) {
			seperatedmiss.push(Math.floor(misscombo / 1000) % 10);
		}
		if(misscombo >= 100) {
			seperatedmiss.push(Math.floor(misscombo / 100) % 10);
		}
		if(misscombo >= 10) {
			seperatedmiss.push(Math.floor(misscombo / 10) % 10);
		}
		if(misscombo >= 1) {
			seperatedmiss.push(misscombo % 10);
		}

		var loopsus:Float = 0;
		var misssus:Int = -1;
		var aplacement:String = Std.string(misscombo);
		var ccoolText:FlxText = new FlxText(0, 0, 0, aplacement, 32);
		ccoolText.x = FlxG.width * 0.35;

		misscombogroup.destroy();
		misscombogroup = new FlxGroup();
		add(misscombogroup);

		for(i in seperatedmiss)
		{
			if (ClientPrefs.sussycombo) lastmisses.destroy();
			//var aplacement:String = Std.string(misscombo);

			misssus++;

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';

			if (PlayState.isPixelStage)
			{
				pixelShitPart1 = 'pixelUI/';
				pixelShitPart2 = '-pixel';
			}

			var nummiss:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			nummiss.cameras = [camHUD];
			//misssus++;
			nummiss.screenCenter();
			nummiss.x = ccoolText.x + (43 * loopsus) - 90;
			nummiss.y += 80;
			nummiss.color = 0x00B22222;
			nummiss.x += ClientPrefs.comboOffset[2];
			nummiss.y -= ClientPrefs.comboOffset[3];

			var negative:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Negative'));
			negative.cameras = [camHUD];
			negative.screenCenter();
			negative.x = ccoolText.x - 130;
			negative.y += 80;
			if (PlayState.isPixelStage) negative.y += 80;
			negative.x += ClientPrefs.comboOffset[2];
			negative.y -= ClientPrefs.comboOffset[3];
			negative.color = 0x00B22222;

			var missimage:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'miss' + pixelShitPart2));
			missimage.cameras = [camHUD];
			missimage.screenCenter();
			missimage.x = ccoolText.x - 60;
			missimage.x += ClientPrefs.comboOffset[0];
			missimage.y -= ClientPrefs.comboOffset[1];
			if (PlayState.isPixelStage) missimage.x += 20;

			negative.antialiasing = ClientPrefs.globalAntialiasing;
			negative.setGraphicSize(Std.int(negative.width * 0.5));

			combosprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 +  'combosprite' + pixelShitPart2));
			combosprite.cameras = [camHUD];
			combosprite.screenCenter();
			combosprite.x = ccoolText.x - 90;
			combosprite.y += 80;
			combosprite.x += 75;
			combosprite.x += ClientPrefs.comboOffset[2];
			combosprite.y -= ClientPrefs.comboOffset[3];
			combosprite.color = 0x00B22222;
			combosprite.antialiasing = ClientPrefs.globalAntialiasing;
			combosprite.setGraphicSize(Std.int(combosprite.width * 0.5));
			combosprite.visible = !ClientPrefs.hideHud;
			combosprite.updateHitbox();
			insert(members.indexOf(strumLineNotes), combosprite);
			add(combosprite);

			if (!PlayState.isPixelStage)
			{
				nummiss.antialiasing = ClientPrefs.globalAntialiasing;
				nummiss.setGraphicSize(Std.int(nummiss.width * 0.5));
				missimage.antialiasing = ClientPrefs.globalAntialiasing;
				missimage.setGraphicSize(Std.int(missimage.width * 0.5));
			}
			if (PlayState.isPixelStage)
			{
				combosprite.setGraphicSize(Std.int(combosprite.width * 8));
				combosprite.x += 75;
				combosprite.y += 30;
				combosprite.antialiasing = false;
				nummiss.setGraphicSize(Std.int(nummiss.width * 4));
				nummiss.setGraphicSize(Std.int(nummiss.width * 6));
				//negative.setGraphicSize(Std.int(negative.width * 5));
				missimage.setGraphicSize(Std.int(missimage.width * 4.25));
			}

			if(misscombo >= 10){
				nummiss.x -= 40;
				negative.x -= 40;
			}
			if(misscombo >= 100){
				nummiss.x -= 40;
				negative.x -= 40;
			}
			if(misscombo >= 1000){
				nummiss.x -= 40;
				negative.x -= 40;
			}
			

			nummiss.updateHitbox();
			nummiss.visible = !ClientPrefs.hideHud;
			insert(members.indexOf(strumLineNotes), nummiss);

			negative.updateHitbox();
			negative.visible = !ClientPrefs.hideHud;
			insert(members.indexOf(strumLineNotes), negative);

			missimage.updateHitbox();
			missimage.visible = !ClientPrefs.hideHud;
			insert(members.indexOf(strumLineNotes), missimage);

			if(!ClientPrefs.sussycombo){
				missimage.acceleration.y = FlxG.random.int(200, 300);
				missimage.velocity.y -= FlxG.random.int(140, 160);
				missimage.velocity.x = FlxG.random.float(-5, 5);
				nummiss.acceleration.y = FlxG.random.int(200, 300);
				nummiss.velocity.y -= FlxG.random.int(140, 160);
				nummiss.velocity.x = FlxG.random.float(-5, 5);
				negative.acceleration.y = FlxG.random.int(200, 300);
				negative.velocity.y -= FlxG.random.int(140, 160);
				negative.velocity.x = FlxG.random.float(-5, 5);

				FlxTween.tween(negative, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						negative.destroy();
					},
					startDelay: Conductor.crochet * 0.00075
				});
	
				FlxTween.tween(nummiss, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						nummiss.destroy();
					},
					startDelay: Conductor.crochet * 0.00075
				});

				FlxTween.tween(missimage, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						missimage.destroy();
					},
					startDelay: Conductor.crochet * 0.00075
				});
	
				combosprite.acceleration.y = FlxG.random.int(200, 300);
				combosprite.velocity.y -= FlxG.random.int(140, 160);
				combosprite.velocity.x = FlxG.random.float(-5, 5);
				FlxTween.tween(combosprite, {alpha: 0}, 0.2, {ease: FlxEase.circOut, startDelay: Conductor.crochet * 0.001});
			}
		
			if(ClientPrefs.sussycombo){

				misscombogroup.add(negative);
				misscombogroup.add(combosprite);
				combosprite.y -= 30;
				FlxTween.tween(combosprite, {y: combosprite.y + 30}, 0.2, {
					ease: FlxEase.circOut
				});

				misscombogroup.add(missimage);
				lastmisses = missimage;
				var scaleX = missimage.scale.x;
				var scaleY = missimage.scale.y;
				missimage.scale.scale(1.2);
				if(missTween!=null && missTween.active){
					missTween.cancel();
				}
				missTween = FlxTween.tween(missimage.scale, {x: scaleX, y: scaleY}, 0.1, {
					onComplete: function(tween:FlxTween)
					{
						if(missimage.alive && missTween == tween){
							missTween = FlxTween.tween(missimage.scale, {x: 0, y: 0}, 0.2, {
								onComplete: function(tween:FlxTween)
								{
									missimage.kill();
									//rating.destroy();
								},
								ease: FlxEase.quadIn,
								startDelay: 0.6
							});
						}
					},
					ease: FlxEase.quadOut
				});
				
				misscombogroup.add(nummiss);

				if(misscombo == 10 || misscombo == 100 || misscombo == 1000){
					nummiss.y -= 30;
					FlxTween.tween(nummiss, {y: nummiss.y + 30}, 0.2, {
						ease: FlxEase.circOut
					});
				}
				if(misscombo != 10 && misscombo != 100 && misscombo != 1000){
					if(sussymissseperatedScore[misssus] != i){
						nummiss.y -= 30;
						FlxTween.tween(nummiss, {y: nummiss.y + 30}, 0.2, {
							ease: FlxEase.circOut
						});
					}
				}
			}
			loopsus += 1;
		}

		sussymissseperatedScore = seperatedmiss;
		ccoolText.text = Std.string(seperatedmiss);

		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		vocals.volume = 0;
		health -= daNote.missHealth * healthLoss;
		songMisses++;
		songScore -= 100;
		
		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}*/

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		if (ClientPrefs.sussycombo) lastRating.destroy();
		combogroup.destroy();
		numscoregroup.destroy();

		health -= daNote.missHealth * healthLoss;
		//health -= 0.05;
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		songScore -= 100;
		
		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.045 * healthLoss;
			//combogroup.destroy();
			//numscoregroup.destroy();
			//if (ClientPrefs.sussycombo) lastRating.destroy();
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if(ClientPrefs.ghostTapping) return;

			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			
			combo = 0;
			//notecomboshit = 0;

			//if(!Mode)
			songScore -= 100;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			//vocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = "";

			var curSection:Int = Math.floor(curStep / 16);
			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation') {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			char.playAnim(animToPlay, true);
			char.holdTimer = 0;
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			//accuracypopuplol();

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('ChartingTick'), ClientPrefs.hitsoundVolume);
			}

			if(combo >= highestCombo)
				highestCombo = combo + 1;  //andromeda engineLOL

			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
				
				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
				misscombo = 0;
				if(combo > 9999) combo = 9999;
				health += note.hitHealth * healthGain;
			}

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';
	
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				//if (note.isSustainNote){ wouldn't this be fun : P. i think it would be swell
					
					//if(note.gfNote) {
					//  var anim = animToPlay +"-hold" + daAlt;
					//	if(gf.animation.getByName(anim) == null)anim = animToPlay + daAlt;
					//	gf.playAnim(anim, true);
					//	gf.holdTimer = 0;
					//} else {
					//  var anim = animToPlay +"-hold" + daAlt;
					//	if(boyfriend.animation.getByName(anim) == null)anim = animToPlay + daAlt;
					//	boyfriend.playAnim(anim, true);
					//	boyfriend.holdTimer = 0;
					//}
				//}else{
					if(note.gfNote) {
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					} else {
						boyfriend.playAnim(animToPlay + daAlt, true);
						boyfriend.holdTimer = 0;
					}
				//}
				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
	
					if(gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
			gf.specialAnim = true;
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.danced = false; //Sets head to the correct position once the animation ends
		gf.playAnim('hairFall');
		gf.specialAnim = true;
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}
		if(gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
		
		//camera wow
		switch (curSong){
			/*case 'Milf': //camerazoom lmao credit to fnf imposter
				switch (curStep){
					case 16:
						curStage == 'philly';
					case 32:
						defaultCamZoom = 0.75;
					case 36:
						defaultCamZoom = 1;
					case 40:
						defaultCamZoom = 1.25;
				}
			}*/
			case 'first-rapping': //camerazoom lmao credit to fnf imposter
				switch (curStep){
					case 1328:
						defaultCamZoom = 1.3;
					case 1344:
						defaultCamZoom = 1.05;
				}
			
			
			case 'being-serious': //camerazoom lmao credit to fnf imposter
				switch (curStep){
					case 1547:
						FlxG.camera.flash(FlxColor.WHITE, 2);
					case 1548:
						var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
						add(blackScreen);
						blackScreen.scrollFactor.set();
						//add(blackScreen);
				}
			}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		/*if (curSong == 'Milf')
		{
			switch (curBeat)
			{
				case 16:
					curStage == 'philly';
			}
		}*/

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			setOnLuas('altAnim', SONG.notes[Math.floor(curStep / 16)].altAnim);
			setOnLuas('gfSection', SONG.notes[Math.floor(curStep / 16)].gfSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		if(curBeat % 1 == 0){
			iconP1.angle = 25;
			FlxTween.tween(iconP1, {angle: 0}, 0.2);
			iconP2.angle = 25;
			FlxTween.tween(iconP2, {angle: 0}, 0.2);
		}
		if(curBeat % 2 == 0){
			iconP1.angle = -25;
			FlxTween.tween(iconP1, {angle: 0}, 0.2);
			iconP2.angle = -25;
			FlxTween.tween(iconP2, {angle: 0}, 0.2);
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
		{
			gf.dance();
		}

		if(curBeat % 2 == 0) {
			if (boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing"))
			{
				boyfriend.dance();
			}
			if (dad.animation.curAnim.name != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
			{
				dad.dance();
			}
		} else if(dad.danceIdle && dad.animation.curAnim.name != null && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned) {
			dad.dance();
		}

		switch (curStage)
		{
			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:BGSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

				setOnLuas('curBeat', curBeat);//DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	public var closeLuas:Array<FunkinLua> = [];
	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}

		for (i in 0...closeLuas.length) {
			luaArray.remove(closeLuas[i]);
			closeLuas[i].stop();
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);
				// resultaccuracy / 100
				// Rating Name
				if(resultaccuracy / 100 >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string result
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(resultaccuracy / 100 < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (epics > 0) ratingFC= "EFC";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";			
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			if (songMisses >= 10) ratingFC = "Clear";
			if (songMisses == 69) ratingFC = "NICE BRO";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
		judgementCounter.text = 'Highest Combo: ${highestCombo}\nEpics: ${epics}\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${songMisses}\nCombo Breaks: ${songMisses}'; //https://github.com/ShadowMario/FNF-PsychEngine/discussions/3707
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String>):String {
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName)){ //&& !cpuControlled) {
				var unlock:Bool = false;
				switch(achievementName)
				{
					case 'week1_nomiss' | 'week2_nomiss' | 'week3_nomiss' | 'week4_nomiss' | 'week5_nomiss' | 'week6_nomiss' | 'week7_nomiss':
						if(isStoryMode && !cpuControlled && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'week1':
									if(achievementName == 'week1_nomiss') unlock = true;
								case 'week2':
									if(achievementName == 'week2_nomiss') unlock = true;
								case 'week3':
									if(achievementName == 'week3_nomiss') unlock = true;
								case 'week4':
									if(achievementName == 'week4_nomiss') unlock = true;
								case 'week5':
									if(achievementName == 'week5_nomiss') unlock = true;
								case 'week6':
									if(achievementName == 'week6_nomiss') unlock = true;
								case 'week7':
									if(achievementName == 'week7_nomiss') unlock = true;
							}
						}
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode && !cpuControlled) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice && !cpuControlled) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice && !cpuControlled) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice && !cpuControlled) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist ) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice && !cpuControlled) {
							unlock = true;
						}
					case 'first_song':
						if(Paths.formatToSongPath(SONG.song) == 'first-rapping' && !usedPractice && !cpuControlled) {
							unlock = true;
						}
					case 'first_song_FC':
						if(Paths.formatToSongPath(SONG.song) == 'first-rapping' && !cpuControlled && !usedPractice && ratingFC == 'EFC' || ratingFC == 'SFC' || ratingFC == 'GFC' || ratingFC == 'FC') { //&& !cpuControlled) {
							unlock = true;
						}
					case 'second_song':
						if(Paths.formatToSongPath(SONG.song) == 'being-serious' && !usedPractice && !cpuControlled) {
							unlock = true;
						}
					case 'second_song_FC':
						if(Paths.formatToSongPath(SONG.song) == 'being-serious' && !cpuControlled && !usedPractice && ratingFC == 'EFC' || ratingFC == 'SFC' || ratingFC == 'GFC' || ratingFC == 'FC'){ //&& campaignMisses + songMisses < 1 ) { //&& !cpuControlled) {
							unlock = true;
						}
					case 'bot_play':
						if(cpuControlled) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}
