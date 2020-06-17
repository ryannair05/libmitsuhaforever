//
//  MSHFUtils.h
//  Mitsuha
//
//  Created by c0ldra1n on 2/6/17.
//  Copyright © 2017 c0ldra1n. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MSHFPreferencesIdentifier @"com.ryannair05.mitsuhaforever"
#define MSHFColorsIdentifier @"com.ryannair05.mitsuhaforever.colors"
#define MSHFPreferencesChanged @"com.ryannair05.mitsuhaforever/ReloadPrefs"
#define MSHFPrefsFile                                                          \
  @"/var/mobile/Library/Preferences/"                                          \
  @"com.ryannair05.mitsuhaforever.plist"
#define MSHFColorsFile                                                         \
  @"/var/mobile/Library/Preferences/"                                          \
  @"com.ryannair05.mitsuhaforever.colors.plist"
#define MSHFAppSpecifiersDirectory                                             \
  @"/Library/PreferenceBundles/MitsuhaForeverPrefs.bundle/Apps"
#define SylphPreferencesFile                                                   \
  @"/var/mobile/Library/Preferences/ch.mdaus.sylph.plist"
#define SylphTweakDylibFile                                                    \
  @"/Library/MobileSubstrate/DynamicLibraries/Sylph.dylib"
#define SylphTweakPlistFile                                                    \
  @"/Library/MobileSubstrate/DynamicLibraries/Sylph.plist"
#define ArtsyPreferencesFile                                                   \
  @"/var/mobile/Library/Preferences/ch.mdaus.artsy.plist"
#define ArtsyTweakDylibFile                                                    \
  @"/Library/MobileSubstrate/DynamicLibraries/Artsy.dylib"
#define ArtsyTweakPlistFile                                                    \
  @"/Library/MobileSubstrate/DynamicLibraries/Artsy.plist"
#define MSHFAudioBufferSize 1024
#define ASSPort 44333

@interface NSUserDefaults (mshfPrivate)
- (instancetype)_initWithSuiteName:(NSString *)suiteName
                         container:(NSURL *)container;
@end