//
//  SharedGK.h
//  Pokus
//
//  Created by Samuel Grau on 06/02/11.
//  Copyright 2011 Lagardere Digital France. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

BOOL isGameCenterAvailable();

@interface SGSharedGK : NSObject {
	NSMutableDictionary *achievementsDictionary;
}

@property(nonatomic, retain) NSMutableDictionary *achievementsDictionary;

#pragma mark -
#pragma mark Singleton object methods

+ (SGSharedGK *)instance;

#pragma mark -
#pragma mark Authentication

- (void)authenticateLocalPlayer;
- (void)registerForAuthenticationNotification;
- (void)unregisterForAuthenticationNotification;
- (void)authenticationChanged;

#pragma mark -
#pragma mark Friends Information

- (void)retrieveFriends;
- (void)loadPlayerData:(NSArray *)identifiers;

#pragma mark -
#pragma mark Scoring

- (void)reportScore:(int64_t)score forCategory:(NSString*)category;

#pragma mark -
#pragma mark Leaderboard

- (void)showLeaderboard;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;
- (void)retrieveTopTenScores;
- (void)receiveMatchBestScores:(GKMatch*)match;
- (void)loadCategoryTitles;

#pragma mark -
#pragma mark Achievements

- (void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent;
- (void)loadAchievements;
- (GKAchievement*)getAchievementForIdentifier:(NSString*)identifier;
- (void)resetAchievements;
- (void)showAchievements;
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;

@end
