/*
 *  Copyright (c) 2015 Translation Exchange, Inc. All rights reserved.
 *
 *  _______                  _       _   _             ______          _
 * |__   __|                | |     | | (_)           |  ____|        | |
 *    | |_ __ __ _ _ __  ___| | __ _| |_ _  ___  _ __ | |__  __  _____| |__   __ _ _ __   __ _  ___
 *    | | '__/ _` | '_ \/ __| |/ _` | __| |/ _ \| '_ \|  __| \ \/ / __| '_ \ / _` | '_ \ / _` |/ _ \
 *    | | | | (_| | | | \__ \ | (_| | |_| | (_) | | | | |____ >  < (__| | | | (_| | | | | (_| |  __/
 *    |_|_|  \__,_|_| |_|___/_|\__,_|\__|_|\___/|_| |_|______/_/\_\___|_| |_|\__,_|_| |_|\__, |\___|
 *                                                                                        __/ |
 *                                                                                       |___/
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

#import "NSObject+TMLJSON.h"
#import "TML.h"
#import "TMLAPIClient.h"
#import "TMLApplication.h"
#import "TMLBase.h"
#import "TMLConfiguration.h"
#import "TMLLanguage.h"
#import "TMLLanguageCase.h"
#import "TMLLanguageContext.h"
#import "TMLSource.h"
#import "TMLTranslationKey.h"
#import "TMLAPISerializer.h"

@implementation TMLLanguage

+ (TMLLanguage *) defaultLanguage {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"en-US" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    TMLLanguage *lang = [TMLAPISerializer materializeData:data withClass:[TMLLanguage class] delegate:nil];
    return lang;
}

- (id)copyWithZone:(NSZone *)zone {
    TMLLanguage *aCopy = [[TMLLanguage alloc] init];
    aCopy.languageID = self.languageID;
    aCopy.locale = [self.locale copyWithZone:zone];
    aCopy.englishName = [self.englishName copyWithZone:zone];
    aCopy.nativeName = [self.nativeName copyWithZone:zone];
    aCopy.rightToLeft = self.rightToLeft;
    aCopy.flagUrl = [self.flagUrl copyWithZone:zone];
    aCopy.status = [self.status copyWithZone:zone];
    
    aCopy.contexts = [self.contexts copyWithZone:zone];
    aCopy.cases = [self.cases copyWithZone:zone];
    return aCopy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.languageID forKey:@"id"];
    [aCoder encodeObject:self.locale forKey:@"locale"];
    [aCoder encodeObject:self.englishName forKey:@"english_name"];
    [aCoder encodeObject:self.nativeName forKey:@"native_name"];
    [aCoder encodeBool:self.rightToLeft forKey:@"right_to_left"];
    [aCoder encodeObject:[self.flagUrl absoluteString] forKey:@"flag_url"];
    [aCoder encodeObject:self.status forKey:@"status"];
}

- (void)decodeWithCoder:(NSCoder *)aDecoder {
    self.languageID = [aDecoder decodeIntegerForKey:@"id"];
    self.locale = [aDecoder decodeObjectForKey:@"locale"];
    self.englishName = [aDecoder decodeObjectForKey:@"english_name"];
    self.nativeName = [aDecoder decodeObjectForKey:@"native_name"];
    self.rightToLeft = [aDecoder decodeBoolForKey:@"right_to_left"];
    self.flagUrl = [NSURL URLWithString:[aDecoder decodeObjectForKey:@"flag_url"]];
    self.status = [aDecoder decodeObjectForKey:@"status"];
}

- (BOOL)isEqualToLanguage:(TMLLanguage *)language {
    return self.languageID = language.languageID && self.locale == language.locale;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([object isKindOfClass:[self class]] == NO) {
        return NO;
    }
    return [self isEqualToLanguage:(TMLLanguage *)object];
}

- (TMLLanguageContext *) contextByKeyword: (NSString *) keyword {
    return [self.contexts objectForKey:keyword];
}

- (TMLLanguageContext *) contextByTokenName: (NSString *) tokenName {
    for (TMLLanguageContext *context in [self.contexts allValues]) {
        if ([context isApplicableToTokenName:tokenName]) {
            return context;
        }
    }
    return nil;
}

- (TMLLanguageCase *) languageCaseByKeyword: (NSString *) keyword {
    return [self.cases objectForKey:keyword];
}

- (BOOL) hasDefinitionData {
    if ([[self.contexts allValues] count] > 0)
        return YES;
    return NO;
}

- (BOOL) isDefault {
    if (self.application == nil)
        return YES;
    if ([self.application.defaultLocale isEqual: self.locale])
        return YES;
    return NO;
}

- (NSString *) htmlDirection {
    if ([self.rightToLeft isEqual:@YES])
        return @"rtl";
    return @"ltr";
}

- (NSString *) htmlAlignmentWithLtrDefault: (NSString *) defaultAlignment {
    if ([self.rightToLeft isEqual:@YES])
        return defaultAlignment;
    if ([defaultAlignment isEqual: @"right"])
        return @"left";
    return @"right";
}

- (NSString *) name {
    return self.englishName;
}

- (NSString *) fullName {
    if (self.nativeName == nil || [self.englishName isEqualToString:self.nativeName]) {
        return self.englishName;
    }
    return [NSString stringWithFormat:@"%@ - %@", self.englishName, self.nativeName];
}

- (NSObject *) valueFromOptions: (NSDictionary *) options forKey: (NSString *) key withDefault: (NSObject *) defaultValue {
    
    NSObject *value = [options objectForKey:key];
    if (value) return value;
    
    value = [TML blockOptionForKey:key];
    if (value) return value;
    
    return defaultValue;
}

- (NSObject *) translationKeyWithKey: (NSString *) key label: (NSString *) label description:(NSString *) description options: (NSDictionary *) options {
    NSString *keyLocale = (NSString *) [self valueFromOptions:options forKey:@"locale" withDefault:[[TML sharedInstance] defaultLanguage].locale];
    NSNumber *keyLevel = (NSNumber *) [self valueFromOptions:options forKey:@"level" withDefault:[NSNumber numberWithInt:0]];

    TMLTranslationKey *translationKey = [[TMLTranslationKey alloc] init];
    translationKey.key = key;
    translationKey.locale = keyLocale;
    translationKey.label = label;
    translationKey.level = keyLevel;
    if (description != nil) {
        translationKey.keyDescription = description;
    }
}

- (NSObject *) translate:(NSString *)label
         withDescription:(NSString *)description
               andTokens:(NSDictionary *)tokens
              andOptions:(NSDictionary *)options
{
    NSString *keyHash = [TMLTranslationKey generateKeyForLabel:label andDescription:description];
    TMLTranslationKey *translationKey = (TMLTranslationKey *) [self translationKeyWithKey:keyHash label:label description:description options:options];
    
    if ([tokens objectForKey:@"viewing_user"] == nil && [TML configuration].viewingUser != nil) {
        NSMutableDictionary *tokensWithViewingUser = [NSMutableDictionary dictionaryWithDictionary:tokens];
        [tokensWithViewingUser setObject:[TML configuration].viewingUser forKey:@"viewing_user"];
        tokens = tokensWithViewingUser;
    }

    NSString *sourceKey = (NSString *) [self valueFromOptions:options forKey:@"source" withDefault:[[TML sharedInstance] currentSource]];
    if (sourceKey) {
        TMLSource *source = (TMLSource *) [self.application sourceForKey:sourceKey andLocale: self.locale];
        if (source) {
            NSArray *translations = [source translationsForKey:keyHash inLanguage:self.locale];
            if (translations != nil) {
                [translationKey setTranslations:translations];
                return [translationKey translateToLanguage: self withTokens: tokens andOptions: options];
            }
            [self.application registerMissingTranslationKey:translationKey forSourceKey:source.key];
//            return [translationKey translateToLanguage: self withTokens: tokens andOptions: options];
        }
    }

    NSArray *matchedTranslations = [self.application translationsForKey:keyHash inLanguage:self.locale];
    if (matchedTranslations != nil) {
        [translationKey setTranslations:matchedTranslations];
        return [translationKey translateToLanguage: self withTokens: tokens andOptions: options];
    }
    
    if (![_application isTranslationKeyRegistered:keyHash]) {
        [_application registerMissingTranslationKey:translationKey];
    }
    
    return [translationKey translateToLanguage: self withTokens: tokens andOptions: options];
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@ name: %@ [%@]", [super description], self.englishName, self.locale];
}

@end
