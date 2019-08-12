package
{
import com.doitflash.consts.Direction;
import com.doitflash.consts.Orientation;
import com.doitflash.mobileProject.commonCpuSrc.DeviceInfo;
import com.doitflash.starling.utils.list.List;
import com.doitflash.text.modules.MySprite;

import com.luaye.console.C;
import com.myflashlab.air.extensions.gameCenter.PhotoSize;

import flash.desktop.NativeApplication;
import flash.desktop.SystemIdleMode;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLRequest;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

import com.myflashlab.air.extensions.gameCenter.*;
import com.myflashlab.air.extensions.dependency.OverrideAir;

import flash.utils.ByteArray;


/**
 * ...
 * @author Hadi Tavakoli - 12/8/2019 10:44 AM
 */
public class Main extends Sprite
{
	private const BTN_WIDTH:Number = 150;
	private const BTN_HEIGHT:Number = 40;
	private const BTN_SPACE:Number = 1;
	private var _txt:TextField;
	private var _body:Sprite;
	private var _list:List;
	private var _numRows:int = 1;
	
	private var _players:Vector.<Player>;
	private var _playerIDs:Vector.<String> = new Vector.<String>();
	private var _guestPlayer:Player;
	private var _achievement:Achievement;
	
	public function Main():void
	{
		Multitouch.inputMode = MultitouchInputMode.GESTURE;
		NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate);
		NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate);
		NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
		NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
		
		stage.addEventListener(Event.RESIZE, onResize);
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		C.startOnStage(this, "`");
		C.commandLine = false;
		C.commandLineAllowed = false;
		C.x = 20;
		C.width = 250;
		C.height = 150;
		C.strongRef = true;
		C.visible = true;
		C.scaleX = C.scaleY = DeviceInfo.dpiScaleMultiplier;
		
		_txt = new TextField();
		_txt.autoSize = TextFieldAutoSize.LEFT;
		_txt.antiAliasType = AntiAliasType.ADVANCED;
		_txt.multiline = true;
		_txt.wordWrap = true;
		_txt.embedFonts = false;
		_txt.htmlText = "<font face='Arimo' color='#333333' size='20'><b>GameCenter ANE V" + GameCenter.VERSION + "</font>";
		_txt.scaleX = _txt.scaleY = DeviceInfo.dpiScaleMultiplier;
		this.addChild(_txt);
		
		_body = new Sprite();
		this.addChild(_body);
		
		_list = new List();
		_list.holder = _body;
		_list.itemsHolder = new Sprite();
		_list.orientation = Orientation.VERTICAL;
		_list.hDirection = Direction.LEFT_TO_RIGHT;
		_list.vDirection = Direction.TOP_TO_BOTTOM;
		_list.space = BTN_SPACE;
		
		init();
		onResize();
	}
	
	private function onInvoke(e:InvokeEvent):void
	{
		NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvoke);
	}
	
	private function handleActivate(e:Event):void
	{
		NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
	}
	
	private function handleDeactivate(e:Event):void
	{
		NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
	}
	
	private function handleKeys(e:KeyboardEvent):void
	{
		if(e.keyCode == Keyboard.BACK)
		{
			e.preventDefault();
			NativeApplication.nativeApplication.exit();
		}
	}
	
	private function onResize(e:* = null):void
	{
		if(_txt)
		{
			_txt.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
			
			C.x = 0;
			C.y = _txt.y + _txt.height + 0;
			C.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
			C.height = 300 * (1 / DeviceInfo.dpiScaleMultiplier);
		}
		
		if(_list)
		{
			_numRows = Math.floor(stage.stageWidth / (BTN_WIDTH * DeviceInfo.dpiScaleMultiplier + BTN_SPACE));
			_list.row = _numRows;
			_list.itemArrange();
		}
		
		if(_body)
		{
			_body.y = stage.stageHeight - _body.height;
		}
	}
	
	private function init():void
	{
		// Remove OverrideAir debugger in production builds
		OverrideAir.enableDebugger(function ($ane:String, $class:String, $msg:String):void
		{
			trace("\t>>> " + $ane+" ("+$class+") "+$msg);
		});
		
		GameCenter.init();
		GameCenter.localPlayer.observeAuthentication(function ():void
		{
			trace("auth state changed! isAuthenticated: " + GameCenter.localPlayer.isAuthenticated);
		});
		
		GameCenter.localPlayer.authenticate(function ($isAuthenticated:Boolean, $error:String):void
		{
			if($error)
			{
				trace("authenticate error: " + $error);
			}
			
			if($isAuthenticated)
			{
				trace("displayName: " + 		GameCenter.localPlayer.displayName);
				trace("alias: " + 				GameCenter.localPlayer.alias);
				trace("playerID: " + 			GameCenter.localPlayer.playerID);
				trace("isAuthenticated: "+		GameCenter.localPlayer.isAuthenticated);
				trace("isUnderage: " + 		GameCenter.localPlayer.isUnderage);
				
				loadDefaultLeaderboard();
			}
		});
		
		function loadDefaultLeaderboard():void
		{
			GameCenter.localPlayer.loadDefaultLeaderboardId(function ($leaderboardId:String, $error:String):void
			{
				if($leaderboardId) trace("loadDefaultLeaderboardId: " + $leaderboardId);
				
				if($error) trace("loadDefaultLeaderboardId: " + $error);
				
				loadRecentPlayers();
			});
		}
		
		function loadRecentPlayers():void
		{
			GameCenter.localPlayer.loadRecentPlayers(function($players:Vector.<Player>, $error:String):void
			{
				if($error) trace("loadRecentPlayers: " + $error);
				
				if($players)
				{
					_players = $players;
					
					for(var i:int=0; i < $players.length; i++)
					{
						$players[i].loadPhoto(PhotoSize.SMALL, function($player:Player, $path:String, $error:String):void
						{
							// saving the player id for later tests!
							_playerIDs.push($player.playerID);
							
							trace("RecentPlayer: "+ $player.playerID + " - " + $player.displayName + " - " + $player.alias);
							
							if($path)
							{
								var file:File = new File($path);
								var fs:FileStream = new FileStream();
								fs.open(file, FileMode.READ);
								var bytes:ByteArray = new ByteArray();
								fs.readBytes(bytes);
								var loader:Loader = new Loader();
								loader.mouseEnabled = false;
								loader.alpha = 0.5;
								loader.loadBytes(bytes);
								addChild(loader);
								loader.x = stage.stageWidth * Math.random();
								loader.y = stage.stageHeight * Math.random();
								fs.close();
							}
							else
							{
								trace($error);
							}
						})
					}
				}
			});
		}
		
		//----------------------------------------------------------------------
		
		var btn004:MySprite = createBtn("save game");
		btn004.addEventListener(MouseEvent.CLICK, saveGame);
		_list.add(btn004);
		
		function saveGame(e:MouseEvent):void
		{
			var data:Object = {msg:"some data..."};
			
			GameCenter.localPlayer.saveGame(
					"mySaveGameName2",
					JSON.stringify(data),
					function ($game:SavedGame, $error:String):void
					{
						if($error)
						{
							trace("saveGame failed: " + $error);
						}
						
						if($game)
						{
							trace("-------------saveGame OK");
							trace("deviceName: " + $game.deviceName);
							trace("name: " + $game.name);
							trace("modificationDate: " + $game.modificationDate.toLocaleString());
						}
					}
			)
		}
		
		//----------------------------------------------------------------------
		
		var btn0041:MySprite = createBtn("fetch saved games");
		btn0041.addEventListener(MouseEvent.CLICK, fetchSavedGames);
		_list.add(btn0041);
		
		function fetchSavedGames(e:MouseEvent):void
		{
			GameCenter.localPlayer.fetchSavedGames(function ($savedGames:Vector.<SavedGame>, $error:String):void
			{
				if($error) trace("GameCenter.localPlayer.fetchSavedGames, error: " + $error);
				
				if($savedGames)
				{
					for(var i:int=0; i < $savedGames.length; i++)
					{
						$savedGames[i].loadData(function ($game:SavedGame, $gameData:String, $error:String):void
						{
							if($error) trace("currSavedGame.loadData, error: " + $error);
							else
							{
								trace("$game.name = " + $game.name);
								trace("$game.modificationDate = " + $game.modificationDate.toLocaleString());
								trace("$game.deviceName = " + $game.deviceName);
								trace("$gameData = " + $gameData);
								trace("- - - - - - - - - - - -");
							}
						})
					}
				}
			});
		}
		
		//----------------------------------------------------------------------
		
		var btn0042:MySprite = createBtn("delete saved games");
		btn0042.addEventListener(MouseEvent.CLICK, deleteSavedGames);
		_list.add(btn0042);
		
		function deleteSavedGames(e:MouseEvent):void
		{
			GameCenter.localPlayer.deleteSavedGame("mySaveGameName2", function ($error:String):void
			{
				if($error) trace("deleteSavedGame, error: " + $error);
				else trace("deleteSavedGame done");
			});
		}
		
		//----------------------------------------------------------------------
		
		var btn1:MySprite = createBtn("clearCache", 0xdff7ff);
		btn1.addEventListener(MouseEvent.CLICK, clearCache);
		_list.add(btn1);
		
		function clearCache(e:MouseEvent):void
		{
			GameCenter.cache.players = true;
			GameCenter.cache.savedGames = true;
			GameCenter.cache.leaderboards = true;
			GameCenter.cache.scores = true;
			GameCenter.cache.leaderboardSets = true;
			GameCenter.cache.challenges = true;
			GameCenter.cache.achievements = true;
			GameCenter.cache.achievementsDesc = true;
			GameCenter.cache.clear();
		}
		
		//----------------------------------------------------------------------
		
		var btn10:MySprite = createBtn("see Cache", 0xdff7ff);
		btn10.addEventListener(MouseEvent.CLICK, seeCache);
		_list.add(btn10);
		
		function seeCache(e:MouseEvent):void
		{
			trace("savedGamesInstances: " + 					GameCenter.cache.savedGamesInstances);
			trace("playersInstances: " + 						GameCenter.cache.playersInstances);
			trace("scoresInstances: " + 						GameCenter.cache.scoresInstances);
			trace("achievementsDescInstances: " + 				GameCenter.cache.achievementsDescInstances);
			trace("achievementsInstances: " + 					GameCenter.cache.achievementsInstances);
			trace("leaderboardSetsInstances: " + 				GameCenter.cache.leaderboardSetsInstances);
			trace("leaderboardsInstances: " + 					GameCenter.cache.leaderboardsInstances);
			trace("savedGamesscoresInstancesInstances: " + 	GameCenter.cache.scoresInstances);
		}
		
		//----------------------------------------------------------------------
		
		var btn2:MySprite = createBtn("showBanner");
		btn2.addEventListener(MouseEvent.CLICK, showBanner);
		_list.add(btn2);
		
		function showBanner(e:MouseEvent):void
		{
			GameCenter.showBanner(
					"title",
					"message",
					4,
					function ($title:String,$msg:String):void
			{
				trace("banner finished!");
			})
		}
		
		//----------------------------------------------------------------------
		
		var btn005:MySprite = createBtn("load Players For IDs");
		btn005.addEventListener(MouseEvent.CLICK, loadPlayersForIDs);
		_list.add(btn005);
		
		function loadPlayersForIDs(e:MouseEvent):void
		{
			Player.load(_playerIDs, function ($players:Vector.<Player>, $error:String):void
			{
				if($error) trace("loadPlayersForIDs error: " + $error);
				
				if($players)
				{
					for(var i:int=0; i < $players.length; i++)
					{
						var curr:Player = $players[i];
						trace("Player: " + curr.playerID + " - " + curr.displayName + " - " + curr.alias);
					}
				}
			});
		}
		
		//----------------------------------------------------------------------
		
		var btn006:MySprite = createBtn("init New Leaderboard");
		btn006.addEventListener(MouseEvent.CLICK, initNewLeaderboard);
		_list.add(btn006);
		
		function initNewLeaderboard(e:MouseEvent):void
		{
			var leaderboardRequest:Leaderboard = Leaderboard.initNew();
			leaderboardRequest.identifier = "leaderboardOneInteger";
			leaderboardRequest.timeScope = TimeScope.ALL_TIME;
			leaderboardRequest.setRange(1, 10);
			leaderboardRequest.loadScores(function ($leaderboard:Leaderboard, $scores:Vector.<Score>, $error:String):void
			{
				if($error) trace("Leaderboard.initNew, loadScores: "+ $error);
				
				if($scores)
				{
					for(var i:int=0; i < $scores.length; i++)
					{
						trace("score date: " + $scores[i].date.toLocaleString());
						trace("score formattedValue: " + $scores[i].formattedValue);
						trace("- - - - - - - - - -");
					}
				}
			})
		}
		
		//----------------------------------------------------------------------
		
		var btn007:MySprite = createBtn("load Leaderboard");
		btn007.addEventListener(MouseEvent.CLICK, loadLeaderboards);
		_list.add(btn007);
		
		function loadLeaderboards(e:MouseEvent):void
		{
			Leaderboard.load(function ($leaderboards:Vector.<Leaderboard>, $error:String):void
			{
				if($error) trace("Leaderboard.load, error: " + $error);
				
				if($leaderboards)
				{
					for (var i:int=0; i < $leaderboards.length; i++)
					{
						if($leaderboards[i].identifier == "leaderboardOneInteger")
						{
							var curr:Leaderboard = $leaderboards[i];
							
							curr.loadImage(function($leaderboard:Leaderboard, $photo:String, $error:String):void
							{
								if($error) trace("curr.loadImage, error: " + $error);
								else
								{
									trace("$photo: " + $photo);
									var file:File = new File($photo);
									if(file.exists)
									{
										var loader:Loader = new Loader();
										loader.load(new URLRequest(file.url));
										addChild(loader);
									}
								}
							});
							
							curr.loadScores(function ($leaderboard:Leaderboard, $scores:Vector.<Score>, $error:String):void
							{
								
								trace("identifier: " + curr.identifier);
								trace("getRange: " + curr.getRange());
								trace("isLoading: " + curr.isLoading);
								trace("title: " + curr.title);
								trace("maxRange: " + curr.maxRange);
								
								if(curr.scores)
								{
									trace("- - - - - -");
									for(var j:int=0; j < curr.scores.length; j++)
									{
										trace("formattedValue: " + curr.scores[j].formattedValue);
									}
									trace("- - - - - -");
								}
								
								var timeScope:int = curr.timeScope;
								if(timeScope == TimeScope.TODAY) trace("timeScope: TimeScope.TODAY");
								else if(timeScope == TimeScope.WEEK) trace("timeScope: TimeScope.WEEK");
								else if(timeScope == TimeScope.ALL_TIME) trace("timeScope: TimeScope.ALL_TIME");
								
								var playerScope:int = curr.playerScope;
								if(playerScope == PlayerScope.GLOBAL) trace("playerScope: PlayerScope.GLOBAL");
								else if(playerScope == PlayerScope.FRIENDS_ONLY) trace("playerScope: PlayerScope.FRIENDS_ONLY");
							});
						}
					}
				}
			});
		}
		
		//----------------------------------------------------------------------
		
		var btn008:MySprite = createBtn("test Score");
		btn008.addEventListener(MouseEvent.CLICK, testScore);
		_list.add(btn008);
		
		function testScore(e:MouseEvent):void
		{
			var score:Score = Score.initNew("leaderboardOneInteger");
			
			if(score)
			{
				
				score.value = 38;
				score.context = 0;
				
				Score.report(new <Score>[score], null, function ($error:String):void
				{
					if($error) trace("Score.report, error: " + $error);
					else trace("Score.report OK");
				})
			}
			else
			{
				trace("Error occurred!");
			}
		}
		
		//----------------------------------------------------------------------
		
		var btn009:MySprite = createBtn("open native window");
		btn009.addEventListener(MouseEvent.CLICK, openNativeWindow);
		_list.add(btn009);
		
		function openNativeWindow(e:MouseEvent):void
		{
			GameCenter.openNativeWindow(
					"leaderboardOneInteger",
					ViewState.LEADERBOARDS,
					TimeScope.ALL_TIME,
					function ():void
					{
						trace("window closed");
					});
		}
		
		//----------------------------------------------------------------------
		
		var btn013:MySprite = createBtn("load achievements Desc", 0xdfffdf);
		btn013.addEventListener(MouseEvent.CLICK, loadAchievementsDesc);
		_list.add(btn013);
		
		function loadAchievementsDesc(e:MouseEvent):void
		{
			AchievementDescription.load(function($descriptions:Vector.<AchievementDescription>, $error:String):void
			{
				if($error) trace("AchievementDescription.load, error: " + $error);
				
				if($descriptions)
				{
					for(var i:int=0; i < $descriptions.length; i++)
					{
						var fileCompleteImg:File = new File($descriptions[i].completeDefImgPath);
						var fileInCompleteImg:File = new File($descriptions[i].incompleteDefImgPath);
						
						var loader:Loader = new Loader();
						loader.load(new URLRequest(fileCompleteImg.url));
						addChild(loader);
						
						var loader2:Loader = new Loader();
						loader2.load(new URLRequest(fileInCompleteImg.url));
						loader2.x = 200;
						addChild(loader2);
						
						trace("groupIdentifier: " + $descriptions[i].groupIdentifier);
						trace("identifier: " + $descriptions[i].identifier);
						trace("isHidden: " + $descriptions[i].isHidden);
						trace("isReplayable: " + $descriptions[i].isReplayable);
						trace("maximumPoints: " + $descriptions[i].maximumPoints);
						trace("title: " + $descriptions[i].title);
						trace("unachievedDescription: " + $descriptions[i].unachievedDescription);
						trace("achievedDescription: " + $descriptions[i].achievedDescription);
						trace("- - - - - - - - - - -");
						
						$descriptions[i].loadImage(function($achievementDescription:AchievementDescription, $image:String, $error:String):void
						{
							var fileImg:File = new File($image);
							var loader3:Loader = new Loader();
							loader3.load(new URLRequest(fileImg.url));
							loader3.x = Math.random() * 600;
							loader3.y = Math.random() * 600;
							addChild(loader3);
						});
					}
				}
			});
		}
		
		//----------------------------------------------------------------------
		
		var btn010:MySprite = createBtn("load Achievement", 0xdfffdf);
		btn010.addEventListener(MouseEvent.CLICK, loadAchievements);
		_list.add(btn010);
		
		function loadAchievements(e:MouseEvent):void
		{
			Achievement.load(function ($achievements:Vector.<Achievement>, $error:String):void
			{
				if($error) trace("loadAchievements, error: " + $error);
				
				if($achievements)
				{
					for(var i:int=0; i < $achievements.length; i++)
					{
						_achievement = $achievements[i];
						
						trace("identifier: " + $achievements[i].identifier);
						trace("isCompleted: " + $achievements[i].isCompleted);
						trace("lastReportedDate: " + $achievements[i].lastReportedDate.toLocaleString());
						trace("percentComplete: " + $achievements[i].percentComplete);
						trace("player: " + $achievements[i].player.displayName);
					}
					
					if($achievements.length < 1)
					{
						trace("no previously submitted achievement... let's submit the first one!");
						submitAchievement();
					}
				}
			});
		}
		
		function submitAchievement():void
		{
			// achievementOne
			// achiveTwo
			var achievement:Achievement = Achievement.initNew("achievementOne");
			achievement.percentComplete = 42;
			
			Achievement.report(new <Achievement>[achievement], null, function($error:String):void
			{
				if($error) trace("Achievement.report, error: "+ $error);
				else  trace("Achievement.report, DONE");
			});
		}
		
		//----------------------------------------------------------------------
		
		var btn012:MySprite = createBtn("complete Achievements", 0xdfffdf);
		btn012.addEventListener(MouseEvent.CLICK, completeAchievement);
		_list.add(btn012);
		
		function completeAchievement(e:MouseEvent):void
		{
			if(!_achievement)
			{
				trace("_achievement is still null");
				return;
			}
			
			_achievement.percentComplete = 100;
			_achievement.showsCompletionBanner = true;
			
			Achievement.report(new <Achievement>[_achievement], null, function($error:String):void
			{
				if($error) trace("Achievement.report, error: "+ $error);
				else  trace("Achievement.report, DONE");
			});
		}
		
		//----------------------------------------------------------------------
		
		var btn011:MySprite = createBtn("rest Achievements", 0xdfffdf);
		btn011.addEventListener(MouseEvent.CLICK, resetAchievements);
		_list.add(btn011);
		
		function resetAchievements(e:MouseEvent):void
		{
			Achievement.reset(function ($error:String):void
			{
				if($error) trace("Achievement.reset, error: "+ $error);
				else  trace("Achievement.reset, DONE");
			});
		}
		
		//----------------------------------------------------------------------
		
		onResize();
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	private function createBtn($str:String, $color:uint=0xDFE4FF):MySprite
	{
		var sp:MySprite = new MySprite();
		sp.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		sp.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		sp.addEventListener(MouseEvent.CLICK, onOut);
		sp.bgAlpha = 1;
		sp.bgColor = $color;
		sp.drawBg();
		sp.width = BTN_WIDTH * DeviceInfo.dpiScaleMultiplier;
		sp.height = BTN_HEIGHT * DeviceInfo.dpiScaleMultiplier;
		
		function onOver(e:MouseEvent):void
		{
			sp.bgAlpha = 1;
			sp.bgColor = 0xFFDB48;
			sp.drawBg();
		}
		
		function onOut(e:MouseEvent):void
		{
			sp.bgAlpha = 1;
			sp.bgColor = $color;
			sp.drawBg();
		}
		
		var format:TextFormat = new TextFormat("Arimo", 13, 0x666666, null, null, null, null, null, TextFormatAlign.CENTER);
		
		var txt:TextField = new TextField();
		txt.autoSize = TextFieldAutoSize.LEFT;
		txt.antiAliasType = AntiAliasType.ADVANCED;
		txt.mouseEnabled = false;
		txt.multiline = true;
		txt.wordWrap = true;
		txt.scaleX = txt.scaleY = DeviceInfo.dpiScaleMultiplier;
		txt.width = sp.width * (1 / DeviceInfo.dpiScaleMultiplier);
		txt.defaultTextFormat = format;
		txt.text = $str;
		
		txt.y = sp.height - txt.height >> 1;
		sp.addChild(txt);
		
		return sp;
	}
}
	
}