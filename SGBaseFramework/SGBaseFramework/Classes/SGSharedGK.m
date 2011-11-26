//
//  SharedGK.m
//  Pokus
//
//  Created by Samuel Grau on 06/02/11.
//  Copyright 2011 Lagardere Digital France. All rights reserved.
//

#import "SGSharedGK.h"
#import "GTMObjectSingleton.h"

BOOL isGameCenterAvailable() {
	// Check for presence of GKLocalPlayer API.
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
	// The device must be running running iOS 4.1 or later.
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}


@implementation SGSharedGK

@synthesize achievementsDictionary;

#pragma mark -
#pragma mark Singleton definition

GTMOBJECT_SINGLETON_BOILERPLATE( SGSharedGK, instance )

#pragma mark -
#pragma mark Initialization

- (id)init {
	self = [super init];
	if (self != nil) {
		achievementsDictionary = [[NSMutableDictionary alloc] init];
		
		[self registerForAuthenticationNotification];
	}
	return self;
}

- (void)dealloc {
	[self unregisterForAuthenticationNotification];
	
	[achievementsDictionary release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Authentication

- (void)authenticateLocalPlayer {
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
		if (error == nil) {
			// Insert code here to handle a successful authentication.
			NSLog(@"GK - Success authenticating");
			
			[self loadAchievements];
			// Perform other authentication-completed tasks here.
			
		} else {
			// Your application can process the error parameter to report the error to the player.
			NSLog(@"GK - Error authenticating");
		}
	}];
}

- (void)registerForAuthenticationNotification {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver: self
				 selector:@selector(authenticationChanged)
						 name:GKPlayerAuthenticationDidChangeNotificationName
					 object:nil];
}

- (void)unregisterForAuthenticationNotification {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self 
								name:GKPlayerAuthenticationDidChangeNotificationName 
							object:nil];
}

- (void)authenticationChanged {
	if ([GKLocalPlayer localPlayer].isAuthenticated) {
		// Insert code here to handle a successful authentication.
	} else {
		// Insert code here to clean up any outstanding Game Center-related classes.	
	}
}

#pragma mark -
#pragma mark Friends Information

- (void)retrieveFriends {
	GKLocalPlayer *lp = [GKLocalPlayer localPlayer];
	if (lp.authenticated) {
		[lp loadFriendsWithCompletionHandler:^(NSArray *friends, NSError *error) {
			if (error == nil) {
				// use the player identifiers to create player objects.
			} else {
				// report an error to the user.
			}
		}];
	}
}

- (void)loadPlayerData:(NSArray *)identifiers {
	[GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:^(NSArray *players, NSError *error) {
		if (error != nil) {
			// Handle the error.
		}
		if (players != nil) {
			// Process the array of GKPlayer objects.
		}
	}];
}

#pragma mark -
#pragma mark Scoring

- (void)reportScore:(int64_t)score forCategory:(NSString*)category {
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
	scoreReporter.value = score;
	
	[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
		if (error != nil) {
			// handle the reporting error
		}
	}];
}

#pragma mark -
#pragma mark Leaderboard

- (void)showLeaderboard {
	/*GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	 if (leaderboardController != nil) {
	 leaderboardController.leaderboardDelegate = self;
	 [self presentModalViewController: leaderboardController animated: YES];
	 }*/
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
	//[self dismissModalViewControllerAnimated:YES];
}

- (void)retrieveTopTenScores {
	GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
	if (leaderboardRequest != nil) {
		leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
		leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardRequest.range = NSMakeRange(1,10);
		[leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
			if (error != nil) {
				// handle the error.
			}
			if (scores != nil) {
				// process the score information.
			}
		}];
	}
}

- (void)receiveMatchBestScores:(GKMatch*)match {
	GKLeaderboard *query = [[GKLeaderboard alloc] initWithPlayerIDs: match.playerIDs];
	if (query != nil) {
		[query loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
			if (error != nil) {
				// handle the error.
			}
			if (scores != nil) {
				// process the score information.
			}
		}];
	}
}

- (void)loadCategoryTitles {
	[GKLeaderboard loadCategoriesWithCompletionHandler:^(NSArray *categories, NSArray *titles, NSError *error) {
		if (error != nil) {
			// handle the error
		}
		// use the category and title information
	}];
}

#pragma mark -
#pragma mark Achievements

- (void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent {
	GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
	if (achievement) {
		achievement.percentComplete = percent;
		[achievement reportAchievementWithCompletionHandler:^(NSError *error) {
			if (error != nil) {
				// Retain the achievement object and try again later (not shown).
			}
		}];
	}
}

- (void)loadAchievements {
	[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
		if (error != nil) {
			// handle errors
		}
		if (achievements != nil) {
			// process the array of achievements.
			for (GKAchievement* achievement in achievements) {
				[achievementsDictionary setObject: achievement forKey: achievement.identifier];
			}
		}
	}];
}

- (GKAchievement*)getAchievementForIdentifier:(NSString*)identifier {
	GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
	if (achievement == nil) {
		achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
		[achievementsDictionary setObject:achievement forKey:achievement.identifier];
	}
	return [[achievement retain] autorelease];
}

- (void)resetAchievements {
	// Clear all locally saved achievement objects.
	achievementsDictionary = [[NSMutableDictionary alloc] init];
	// Clear all progress saved on Game Center
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
		if (error != nil) {
			// handle errors
		}
	}];
}

- (void)showAchievements {
	/*GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != nil) {
		achievements.achievementDelegate = self;
		[self presentModalViewController: achievements animated: YES];
	}
	[achievements release];*/
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
	//[self dismissModalViewControllerAnimated:YES];
}


@end
