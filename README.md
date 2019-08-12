# GameCenter ANE for iOS
Create experiences that keep players coming back to your game. Add leaderboards, achievements, matchmaking, challenges, and more.

**Main Features:**
* Signing in/out
* Achievements
* Leaderboards
* Challenges
* Score submitting
* iCloud game data saving
* *Turn-based Games (coming soon)*
* *Real-Time Matches (coming soon)*
* *Player Invitations (coming soon)*

[find the latest **asdoc** for this ANE here.](https://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/gameCenter/package-detail.html)  

# AIR Usage
For the complete AS3 code usage, see the [demo project here](https://github.com/myflashlab/GameCenter-ANE/tree/master/AIR/src).

```actionscript
import com.myflashlab.air.extensions.gameCenter.*;
import com.myflashlab.air.extensions.dependency.OverrideAir;

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
	});
}


```

# AIR .xml manifest
```xml
<!--
Add Entitlements based on your iOS app .mobileprovision file.
Read the "Requirements" section below to learn more about this.
-->



<!--
Embedding the ANE:
-->
  <extensions>

        <extensionID>com.myflashlab.air.extensions.gameCenter</extensionID>
        <extensionID>com.myflashlab.air.extensions.dependency.overrideAir</extensionID>

    </extensions>
-->
```

# Requirements 
1. iOS 10+
2. AIR SDK 32+
3. Go to your Apple developer console and activate *iCloud* for your app ID:  

![iCloud](https://myflashlab.github.io/resources/iCloudActivation.jpg)

4. Regenerate your *.mobileprovision* files and download them. Open it with a text editor and look for the key ```<key>Entitlements</key>```. Add the Entitlements values to your manifest .xml file similar to what you see in the [demo sample project](https://github.com/myflashlab/GameCenter-ANE/blob/master/AIR/Main-app.xml#L34).

5. While copying the Entitlements, make sure that the value for the key ```<key>com.apple.developer.icloud-services</key>``` is not ```<string>*</string>```. Make sure its value is like below:

```xml
<key>com.apple.developer.icloud-services</key>
<array>
  <string>CloudDocuments</string>
  <string>CloudKit</string>
</array>
```

# Commercial Version
Only available through [ANELAB Software](https://github.com/myflashlab/ANE-LAB/)

# Tutorials
[How to embed ANEs into **FlashBuilder**, **FlashCC** and **FlashDevelop**](https://www.youtube.com/watch?v=Oubsb_3F3ec&list=PL_mmSjScdnxnSDTMYb1iDX4LemhIJrt1O)  
[How to get started with Games Services?](https://github.com/myflashlab/GameServices-ANE/wiki#get-started-with-games-services)

# Premium Support #
[![Premium Support package](https://www.myflashlabs.com/wp-content/uploads/2016/06/professional-support.jpg)](https://www.myflashlabs.com/product/myflashlabs-support/)
If you are an [active MyFlashLabs club member](https://www.myflashlabs.com/product/myflashlabs-club-membership/), you will have access to our private and secure support ticket system for all our ANEs. Even if you are not a member, you can still receive premium help if you purchase the [premium support package](https://www.myflashlabs.com/product/myflashlabs-support/).