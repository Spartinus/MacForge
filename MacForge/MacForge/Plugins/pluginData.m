//
//  pluginData.m
//  MacForge
//
//  Created by Wolfgang Baird on 6/22/17.
//  Copyright © 2017 Wolfgang Baird. All rights reserved.
//

#import "pluginData.h"
#import "PluginManager.h"

@implementation pluginData

+ (pluginData*) sharedInstance {
    static pluginData* pData = nil;
    
    if (pData == nil)
        pData = [[pluginData alloc] init];
    
    return pData;
}

- (instancetype)init {
    if (self = [super init]) {
        _sourceListDic = [[NSMutableDictionary alloc] init];
        _repoPluginsDic = [[NSMutableDictionary alloc] init];
        _localPluginsDic = [[NSMutableDictionary alloc] init];
        _currentPlugin = [[MSPlugin alloc] init];
    }
    return self;
}

- (NSMutableDictionary*)fetch_repo:(NSString*)source {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSURL* data = [NSURL URLWithString:[NSString stringWithFormat:@"%@/packages_v2.plist", source]];
    NSMutableDictionary* repoPackages = [[NSMutableDictionary alloc] initWithContentsOfURL:data];
    if (repoPackages != nil) {
//        NSMutableDictionary *sourceDic = [[NSMutableDictionary alloc] init];
//        [sourceDic setObject:repoPackages forKey:@"raw_repoPackages"];
        for (NSString *bundleIdentifier in [repoPackages allKeys]) {
            NSMutableDictionary *bundle = [repoPackages objectForKey:bundleIdentifier];
            [bundle setObject:source forKey:@"sourceURL"];
            
            MSPlugin *this_is_a_bundle = [[MSPlugin alloc] init];
            
            this_is_a_bundle.bundleID = [bundle objectForKey:@"package"];
            this_is_a_bundle.webName = [bundle objectForKey:@"name"];
            this_is_a_bundle.webSize = [bundle objectForKey:@"size"];
            this_is_a_bundle.webPublishDate = [bundle objectForKey:@"date"];
            this_is_a_bundle.webPrice = [bundle objectForKey:@"price"];
            this_is_a_bundle.webTarget = [bundle objectForKey:@"apps"];
            this_is_a_bundle.webRepository = source;
            this_is_a_bundle.webVersion = [bundle objectForKey:@"version"];
            this_is_a_bundle.webDeveloperDonate = [bundle objectForKey:@"donate"];
            this_is_a_bundle.webDeveloperEmail = [bundle objectForKey:@"contact"];
            this_is_a_bundle.webDescription = [bundle objectForKey:@"description"];
            this_is_a_bundle.webDescriptionShort = [bundle objectForKey:@"descriptionShort"];
            this_is_a_bundle.webCompatability = [bundle objectForKey:@"compat"];
            this_is_a_bundle.webFileName = [bundle objectForKey:@"filename"];
            this_is_a_bundle.webPlist = bundle;
            this_is_a_bundle.webPaid = [[bundle valueForKey:@"payed"] boolValue];
            
            
            [result setObject:this_is_a_bundle forKey:bundleIdentifier];
//            [sourceDic setObject:this_is_a_bundle forKey:bundleIdentifier];
        }
    }
    return result;
}

- (void)fetch_repos {
    _sourceListDic = [[NSMutableDictionary alloc] init];
    _repoPluginsDic = [[NSMutableDictionary alloc] init];
    
    // Changes
    NSString *plist;
    
    plist = @"~/Library/Application Support/MacForge/packageIDs.plist".stringByExpandingTildeInPath;
    NSMutableDictionary *packageIDs = [[NSMutableDictionary alloc] init];
    if ([NSFileManager.defaultManager fileExistsAtPath:plist])
        packageIDs= [NSMutableDictionary dictionaryWithContentsOfFile:plist];
    
    plist = @"~/Library/Application Support/MacForge/newPackages.plist".stringByExpandingTildeInPath;
    NSMutableDictionary *changesPLIST = [[NSMutableDictionary alloc] init];
    if ([NSFileManager.defaultManager fileExistsAtPath:plist])
        changesPLIST= [NSMutableDictionary dictionaryWithContentsOfFile:plist];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSString *checkTimeStamp = [dateFormat stringFromDate:NSDate.date];
    NSLog(@"Update time : %@", checkTimeStamp);
    
    NSMutableDictionary *packagesinCheck = [[NSMutableDictionary alloc] init];
    //
    
    NSMutableArray *sourceURLS = [[NSMutableArray alloc] initWithArray:[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:@"sources"]];
    for (NSString *source in sourceURLS) {
//        NSMutableDictionary *sourceDic = [self fetch_repo:source];
//        NSLog(@"%@", sourceDic);
//        [self.sourceListDic setObject:sourceDic forKey:source];
        
        // Read the repo file
        NSURL* data = [NSURL URLWithString:[NSString stringWithFormat:@"%@/packages_v2.plist", source]];
        NSMutableDictionary* repoPackages = [[NSMutableDictionary alloc] initWithContentsOfURL:data];
        
        // Repo has some contents
        if (repoPackages != nil) {
            
            NSMutableDictionary *sourceDic = [[NSMutableDictionary alloc] init];
            [sourceDic setObject:repoPackages forKey:@"raw_repoPackages"];
            
            // Iterate over all packages
            for (NSString *bundleIdentifier in [repoPackages allKeys]) {
            
                NSMutableDictionary *bundle = [repoPackages objectForKey:bundleIdentifier];
                [bundle setObject:source forKey:@"sourceURL"];

                MSPlugin *this_is_a_bundle = [[MSPlugin alloc] init];

                this_is_a_bundle.bundleID = [bundle objectForKey:@"package"];
                this_is_a_bundle.webName = [bundle objectForKey:@"name"];
                this_is_a_bundle.webSize = [bundle objectForKey:@"size"];
                this_is_a_bundle.webPublishDate = [bundle objectForKey:@"date"];
                this_is_a_bundle.webPrice = [bundle objectForKey:@"price"];
                this_is_a_bundle.webTarget = [bundle objectForKey:@"apps"];
                this_is_a_bundle.webRepository = source;
                this_is_a_bundle.webVersion = [bundle objectForKey:@"version"];
                this_is_a_bundle.webDeveloperDonate = [bundle objectForKey:@"donate"];
                this_is_a_bundle.webDeveloperEmail = [bundle objectForKey:@"contact"];
                this_is_a_bundle.webDescription = [bundle objectForKey:@"description"];
                this_is_a_bundle.webDescriptionShort = [bundle objectForKey:@"descriptionShort"];
                this_is_a_bundle.webCompatability = [bundle objectForKey:@"compat"];
                this_is_a_bundle.webFileName = [bundle objectForKey:@"filename"];
                this_is_a_bundle.webPlist = bundle;
                this_is_a_bundle.webPaid = [[bundle valueForKey:@"payed"] boolValue];
                this_is_a_bundle.webPaddle = [bundle objectForKey:@"paddle"];


                [self.repoPluginsDic setObject:this_is_a_bundle forKey:bundleIdentifier];
                [sourceDic setObject:this_is_a_bundle forKey:bundleIdentifier];
//                NSLog(@"%@", this_is_a_bundle);
                
                NSString *bundleID = this_is_a_bundle.bundleID;
                if ([packageIDs objectForKey:bundleID]) {
                    
                    NSMutableDictionary *packagebundle = [packageIDs objectForKey:bundleID];
                    
                    // Package updated
                    if (![[packagebundle objectForKey:@"version"] isEqualTo:this_is_a_bundle.webVersion]) {
                        [bundle setObject:checkTimeStamp forKey:@"checkdate"];
                        [packageIDs setObject:bundle forKey:bundleID];
                        [packagesinCheck setObject:bundle forKey:bundleID];
                    }
                    
                } else {
                    
                    // New package
                    [bundle setObject:checkTimeStamp forKey:@"checkdate"];
                    [packageIDs setObject:bundle forKey:bundleID];
                    [packagesinCheck setObject:bundle forKey:bundleID];
                    
                }
            }
            [self.sourceListDic setObject:sourceDic forKey:source];
        }
        
    }
    
    if (packagesinCheck.allKeys.count > 0) {
        [changesPLIST setObject:packagesinCheck forKey:checkTimeStamp];
    }
    
    // key (bundleID) >
    //                  most recent version
    //                  most recent update
    
//    NSArray *blacklist = [SIMBLPrefs objectForKey:@"SIMBLApplicationIdentifierBlacklist"];
//    NSArray *alwaysBlaklisted = @[@"org.w0lf.mySIMBL", @"org.w0lf.cDock-GUI", @"com.w0lf.MacForge", @"com.w0lf.MacForgeHelper"];
//    NSMutableArray *newlist = [[NSMutableArray alloc] initWithArray:blacklist];
//    for (NSString *app in alwaysBlaklisted)
//        if (![blacklist containsObject:app])
//            [newlist addObject:app];
//    [SIMBLPrefs setObject:newlist forKey:@"SIMBLApplicationIdentifierBlacklist"];
    
//    NSLog(@"%@", changesPLIST);
//    NSLog(@"%@", @"~/Library/Application Support/MacForge/packageIDs.plist".stringByExpandingTildeInPath);
    [packageIDs writeToFile:@"~/Library/Application Support/MacForge/packageIDs.plist".stringByExpandingTildeInPath atomically:YES];
    [changesPLIST writeToFile:@"~/Library/Application Support/MacForge/newPackages.plist".stringByExpandingTildeInPath atomically:YES];
    
//    NSLog(@"%@", self.sourceListDic);
}

- (void)fetch_local {
    self.localPluginsDic = [[NSMutableDictionary alloc] init];
    NSArray *folders = [PluginManager MacEnhancePluginPaths];
    for (NSString *str in folders) {
        NSArray *appFolderContents = [[NSArray alloc] init];
        appFolderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:str error:nil];
        for (NSString* fileName in appFolderContents) {
            if ([fileName hasSuffix:@".bundle"]) {
                NSString *path = [str stringByAppendingPathComponent:fileName];
                NSString *name = [fileName stringByDeletingPathExtension];
                
                NSBundle *bundle = [NSBundle bundleWithPath:path];
                NSString *plistPath = [NSString stringWithFormat:@"%@/Contents/Info.plist", [bundle bundlePath]];
                NSDictionary *info = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
                
                NSString *bundleIdentifier = [bundle bundleIdentifier];
                
                if (!bundleIdentifier.length)
                    bundleIdentifier = [info objectForKey:@"CFBundleIdentifier"];
                
                if (![bundleIdentifier length])
                    bundleIdentifier = [NSString stringWithFormat:@"(null - %@)", [NSUUID UUID].UUIDString];
                
                NSString *bundleVersion = [info objectForKey:@"CFBundleShortVersionString"];
                if (![bundleVersion length])
                    bundleVersion = [info objectForKey:@"CFBundleVersion"];
                
                Boolean isActive = false;
                Boolean isUser = false;
                NSArray *components = [path pathComponents];
                NSString* location= [components objectAtIndex:1];
                NSString* endcomp= [components objectAtIndex:[components count] - 2];
                NSString *localDescription = [NSString stringWithFormat:@"%@ - %@ - %@", bundleVersion, bundleIdentifier, location];
                if ([location length]) {
                    if (![endcomp rangeOfString:@"Disabled"].length) {
                        isActive = true;
                    } else {
                        localDescription = [NSString stringWithFormat:@"%@ (Disabled)", localDescription];
                    }
                    
                    if (![location rangeOfString:@"Library"].length)
                        isUser = true;
                }
                
                MSPlugin *this_is_a_bundle = [[MSPlugin alloc] init];
                
                this_is_a_bundle.localName = name;
                this_is_a_bundle.bundleID = bundleIdentifier;
                this_is_a_bundle.localVersion = bundleVersion;
                this_is_a_bundle.isInstalled = true;
                this_is_a_bundle.isUser = isUser;
                this_is_a_bundle.isEnabled = isActive;
                this_is_a_bundle.localPlist = info;
                this_is_a_bundle.localPath = path;
                this_is_a_bundle.localDescription = localDescription;
                
                [self.localPluginsDic setObject:this_is_a_bundle forKey:bundleIdentifier];
//                NSLog(@"%@", this_is_a_bundle.bundleInfoPlist);
            }
        }
    }
}

- (NSImage*)fetch_icon:(MSPlugin*)plugin {
    NSImage* result = nil;
    NSArray* targets = [[NSArray alloc] init];
    targets = [plugin.localPlist objectForKey:@"SIMBLTargetApplications"];
    NSString* iconPath = [NSString stringWithFormat:@"%@/Contents/icon.icns", plugin.localPath];
    NSString* iconFile = [plugin.localPlist objectForKey:@"CFBundleIconFile"];
    
    if ([iconFile length])
        iconPath = [NSString stringWithFormat:@"%@/Contents/Resources/%@.icns", plugin.localPath, iconFile];
    
    if ([iconPath length]) {
        result = [[NSImage alloc] initWithContentsOfFile:iconPath];
        if (result) return result;
    }
    
//    NSData *defaultIcon = [[[NSWorkspace sharedWorkspace] iconForFile:@"/System/Library/CoreServices/loginwindow.app"] TIFFRepresentation];
    for (NSDictionary* targetApp in targets) {
        iconPath = [targetApp objectForKey:@"BundleIdentifier"];
        iconPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:iconPath];
        
        if ([iconPath length]) {
            if ([[targetApp objectForKey:@"BundleIdentifier"] isEqualToString:@"com.apple.notificationcenterui"]) {
                result = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Notifications.icns"];
                if (result) return result;
            }

            if ([[targetApp objectForKey:@"BundleIdentifier"] isEqualToString:@"com.apple.systemuiserver"]) {
                result = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/Assistant.icns"];
                if (result) return result;
            }

            if ([[targetApp objectForKey:@"BundleIdentifier"] isEqualToString:@"com.apple.loginwindow"]) {
                result = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GroupIcon.icns"];
                if (result) return result;
            }

            result = [[NSWorkspace sharedWorkspace] iconForFile:iconPath];
//            NSData *appIcon = [result TIFFRepresentation];
//            if (![defaultIcon isEqualToData:appIcon])
                return result;
        }
    }
    
    result = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/KEXT.icns"];
    return result;
}

@end
