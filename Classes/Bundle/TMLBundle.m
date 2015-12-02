//
//  TMLBundle.m
//  Demo
//
//  Created by Pasha on 11/7/15.
//  Copyright © 2015 TmlHub Inc. All rights reserved.
//

#import "NSObject+TMLJSON.h"
#import "NSString+TmlAdditions.h"
#import "TML.h"
#import "TMLAPIClient.h"
#import "TMLAPISerializer.h"
#import "TMLBundle.h"
#import "TMLBundleManager.h"
#import "TMLTranslation.h"

NSString * const TMLBundleVersionFilename = @"snapshot.json";
NSString * const TMLBundleApplicationFilename = @"application.json";
NSString * const TMLBundleSourcesFilename = @"sources.json";
NSString * const TMLBundleTranslationsFilename = @"translations.json";
NSString * const TMLBundleLanguageFilename = @"language.json";
NSString * const TMLBundleSourcesRelativePath = @"sources";

NSString * const TMLBundleVersionKey = @"version";
NSString * const TMLBundleURLKey = @"url";

NSString * const TMLBundleErrorDomain = @"TMLBundleErrorDomain";
NSString * const TMLBundleErrorResourcePathKey = @"resourcePath";
NSString * const TMLBundleErrorsKey = @"errors";

@interface TMLBundle()
@property (readwrite, nonatomic) NSString *version;
@property (readwrite, nonatomic) NSString *path;
@property (readwrite, nonatomic) NSArray *languages;
@property (readwrite, nonatomic) NSMutableDictionary *translations;
@property (readwrite, nonatomic) NSArray *availableLocales;
@property (readwrite, nonatomic) NSArray *locales;
@property (readwrite, nonatomic) TMLApplication *application;
@property (readwrite, nonatomic) NSArray *sources;
@property (readwrite, nonatomic) NSURL *sourceURL;
@end

@implementation TMLBundle

+ (instancetype)mainBundle {
    return [[TMLBundleManager defaultManager] latestBundle];
}

+ (instancetype)apiBundle {
    return [[TMLBundleManager defaultManager] apiBundle];
}

- (instancetype)initWithContentsOfDirectory:(NSString *)path {
    if (self = [super init]) {
        self.path = path;
        _translations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)isMutable {
    return NO;
}

- (void)resetData {
    self.languages = nil;
    self.sources = nil;
    self.application = nil;
    self.version = nil;
    self.sourceURL = nil;
    self.availableLocales = nil;
}

- (void)reloadVersionInfo {
    NSString *path = [self.path stringByAppendingPathComponent:TMLBundleVersionFilename];
    NSData *versionData = [NSData dataWithContentsOfFile:path];
    NSDictionary *versionInfo = [versionData tmlJSONObject];
    if (versionInfo == nil) {
        TMLError(@"Could not determine version of bundle at path: %@", path);
    }
    else {
        self.version = versionInfo[TMLBundleVersionKey];
        self.sourceURL = [NSURL URLWithString:versionInfo[TMLBundleURLKey]];
    }
}

- (void)reloadApplicationData {
    NSString *path = [self.path stringByAppendingPathComponent:TMLBundleApplicationFilename];
    NSData *applicationData = [NSData dataWithContentsOfFile:path];
    NSDictionary *applicationInfo = [applicationData tmlJSONObject];
    if (applicationInfo == nil) {
        TMLError(@"Could not determine application info of bundle at path: %@", path);
    }
    else {
        self.application = [TMLAPISerializer materializeObject:applicationInfo
                                                     withClass:[TMLApplication class]];
    }
}

- (void)reloadSourcesData {
    NSString *path = [self.path stringByAppendingPathComponent:TMLBundleSourcesFilename];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *sources = [data tmlJSONObject];
    if (sources == nil) {
        TMLError(@"Could not determine list of sources at path: %@", path);
    }
    else {
        self.sources = sources;
    }
}

- (void)reloadAvailableLocales {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:self.path error:&error];
    NSMutableArray *locales = [NSMutableArray array];
    if (contents == nil) {
        TMLError(@"Error listing available bundle locales: %@", error);
    }
    else {
        BOOL isDir = NO;
        for (NSString *path in contents) {
            if ([fileManager fileExistsAtPath:[self.path stringByAppendingPathComponent:path] isDirectory:&isDir] == YES
                && isDir == YES) {
                [locales addObject:[path lastPathComponent]];
            }
        }
    }
    self.availableLocales = locales;
}

#pragma mark - Accessors

- (NSString *)version {
    if (_version == nil) {
        [self reloadVersionInfo];
    }
    return _version;
}

- (NSURL *)sourceURL {
    if (_sourceURL == nil) {
        [self reloadVersionInfo];
    }
    return _sourceURL;
}

- (TMLApplication *)application {
    if (_application == nil) {
        [self reloadApplicationData];
    }
    return _application;
}

- (NSArray *)sources {
    if (_sources == nil) {
        [self reloadSourcesData];
    }
    return _sources;
}

- (NSArray *)availableLocales {
    if (_availableLocales == nil) {
        [self reloadAvailableLocales];
    }
    return _availableLocales;
}

- (NSArray *)locales {
    NSArray *langs = self.languages;
    return [langs valueForKeyPath:@"locale"];
}

- (NSArray *)languages {
    TMLApplication *app = self.application;
    return app.languages;
}

#pragma mark - Translations

- (NSString *)translationsPathForLocale:(NSString *)locale {
    return [[self.path stringByAppendingPathComponent:locale] stringByAppendingPathComponent:TMLBundleTranslationsFilename];
}

- (NSDictionary *)translationsForLocale:(NSString *)locale {
    NSDictionary *translations = _translations[locale];
    if (translations == nil) {
        [self loadLocalTranslationsForLocale:locale];
        translations = _translations[locale];
    }
    return translations;
}

- (void)loadLocalTranslationsForLocale:(NSString *)aLocale {
    NSString *locale = [aLocale lowercaseString];
    NSArray *availableLocales = self.availableLocales;
    NSString *translationsPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([availableLocales containsObject:locale] == YES) {
        translationsPath = [self translationsPathForLocale:locale];
        if ([fileManager fileExistsAtPath:translationsPath] == NO) {
            translationsPath = nil;
        }
    }
    if (translationsPath != nil) {
        NSMutableDictionary *translations = [NSMutableDictionary dictionary];
        NSData *data = [NSData dataWithContentsOfFile:translationsPath];
        NSDictionary *info = [data tmlJSONObject];
        if (info[TMLAPIResponseResultsKey] != nil) {
            info = info[TMLAPIResponseResultsKey];
        }
        for (NSString *key in info) {
            NSArray *translationsList = nil;
            if ([info[key] isKindOfClass:[NSArray class]] == YES) {
                translationsList = info[key];
            }
            else if ([info[key] isKindOfClass:[NSDictionary class]] == YES) {
                translationsList = info[key][TMLAPIResponseResultsTranslationsKey];
            }
            if (translationsList.count > 0) {
                NSArray *newTranslations = [TMLAPISerializer materializeObject:translationsList
                                                                     withClass:[TMLTranslation class]];
                translations[key] = newTranslations;
            }
        }
        
        _translations[locale] = [translations copy];
    }
}

- (void)loadTranslationsForLocale:(NSString *)aLocale
                       completion:(void(^)(NSError *error))completion
{
    NSString *locale = [aLocale lowercaseString];
    NSDictionary *loadedTranslations = [self translationsForLocale:locale];
    if (loadedTranslations == nil) {
        
        NSString *version = self.version;
        NSMutableArray *paths = [NSMutableArray array];
        NSArray *sources = [self sources];
        [paths addObject:[locale stringByAppendingPathComponent:TMLBundleLanguageFilename]];
        [paths addObject:[locale stringByAppendingPathComponent:TMLBundleTranslationsFilename]];
        for (NSString *source in sources) {
            [paths addObject:[[locale stringByAppendingPathComponent:TMLBundleSourcesRelativePath] stringByAppendingPathComponent:[source stringByAppendingPathExtension:@"json"]]];
        }
        
        [[TMLBundleManager defaultManager] fetchPublishedResources:paths
                                                     bundleVersion:version
                                                     baseDirectory:nil
                                                   completionBlock:^(BOOL success, NSArray *paths, NSArray *errors) {
                                                       if (success == YES && paths.count > 0) {
                                                           [self installResources:paths completion:completion];
                                                       }
                                                       else if (completion != nil) {
                                                           NSDictionary *errorInfo = @{
                                                                                       TMLBundleErrorsKey: errors
                                                                                       };
                                                           NSError *ourError = [NSError errorWithDomain:TMLBundleErrorDomain
                                                                                                   code:TMLBundleMissingResources
                                                                                               userInfo:errorInfo];
                                                           completion(ourError);
                                                       }
                                                   }];
    }
}

#pragma mark - Synchronization

- (void)loadCompleteBundle:(void(^)(NSError *error))completion {
    NSURL *url = self.sourceURL;
    TMLBundleManager *manager = [TMLBundleManager defaultManager];
    [manager installBundleFromURL:url completionBlock:^(NSString *path, NSError *error) {
        if (path != nil) {
            TMLInfo(@"Bundle successfully synchronized: %@", path);
        }
        else {
            TMLError(@"Bundle failed to synchronize: %@", error);
        }
        if (completion != nil) {
            completion(error);
        }
    }];
}

- (void)loadMetaData:(void(^)(NSError *error))completion {
    NSString *version = self.version;
    NSArray *paths = @[
                       TMLBundleApplicationFilename,
                       TMLBundleSourcesFilename,
                       TMLBundleVersionFilename
                       ];
    
    [[TMLBundleManager defaultManager] fetchPublishedResources:paths
                                                 bundleVersion:version
                                                 baseDirectory:nil
                                               completionBlock:^(BOOL success, NSArray *paths, NSArray *errors) {
                                                   [self installResources:paths completion:^(NSError *error) {
                                                       if (completion != nil) {
                                                           completion(error);
                                                       }
                                                   }];
                                               }];
}

#pragma mark - Resources

- (void)installResources:(NSArray *)resourcePaths
              completion:(void(^)(NSError *))completion
{
    if (resourcePaths.count == 0) {
        if (completion != nil) {
            completion(nil);
        }
        return;
    }
    
    __block NSInteger count = 0;
    NSString *version = self.version;
    TMLBundleManager *bundleManager = [TMLBundleManager defaultManager];
    __block NSMutableArray *allErrors = [NSMutableArray array];
    
    for (NSString *path in resourcePaths) {
        NSArray *pathComponents = [path pathComponents];
        NSInteger index = [pathComponents indexOfObject:version];
        NSString *relativePath = nil;
        if (index < pathComponents.count - 1) {
            relativePath = [NSString pathWithComponents:[pathComponents subarrayWithRange:NSMakeRange(index+1, pathComponents.count - index - 1)]];
        }
        if (relativePath == nil) {
            NSError *installError = [NSError errorWithDomain:TMLBundleErrorDomain
                                                        code:TMLBundleInvalidResourcePath
                                                    userInfo:@{
                                                               TMLBundleErrorResourcePathKey: path
                                                               }];
            [allErrors addObject:installError];
            continue;
        }
        [bundleManager installResourceFromPath:path
                        withRelativeBundlePath:relativePath
                             intoBundleVersion:version
                               completionBlock:^(NSString *path, NSError *error) {
                                   count++;
                                   if (error != nil) {
                                       [allErrors addObject:error];
                                   }
                                   if (count == resourcePaths.count) {
                                       [self resetData];
                                       if ([[TML sharedInstance] currentBundle] == self) {
                                           [[TMLBundleManager defaultManager] notifyBundleMutation:TMLLocalizationDataChangedNotification
                                                                                            bundle:self
                                                                                            errors:allErrors];
                                       }
                                       if (completion != nil) {
                                           completion((allErrors.count > 0) ? [allErrors firstObject] : nil);
                                       }
                                   }
                               }];
    }
}

#pragma mark -
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%@: %p>", [self class], self.version, self];
}

@end