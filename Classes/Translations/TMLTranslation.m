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

#import "TMLDataToken.h"
#import "TMLLanguage.h"
#import "TMLLanguageContext.h"
#import "TMLLanguageContextRule.h"
#import "TMLTranslation.h"
#import "TMLTranslationKey.h"

@implementation TMLTranslation

- (id)copyWithZone:(NSZone *)zone {
    TMLTranslation *aCopy = [[TMLTranslation alloc] init];
    aCopy.label = [self.label copyWithZone:zone];
    aCopy.locked = self.locked;
    aCopy.context = [self.context copyWithZone:zone];
    aCopy.language = [self.language copyWithZone:zone];
    aCopy.translationKey = [self.translationKey copyWithZone:zone];
    return aCopy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.label forKey:@"label"];
    [aCoder encodeBool:self.locked forKey:@"locked"];
    [aCoder encodeObject:self.context forKey:@"context"];
}

- (void)decodeWithCoder:(NSCoder *)aDecoder {
    self.label = [aDecoder decodeObjectForKey:@"label"];
    self.locked = [aDecoder decodeBoolForKey:@"locked"];
    self.context = [aDecoder decodeObjectForKey:@"context"];
}

- (BOOL) hasContextRules {
    if (self.context == nil || [[self.context allKeys] count] == 0)
        return NO;
    return YES;
}

- (BOOL) isValidTranslationForTokens: (NSDictionary *) tokens {
    if (![self hasContextRules])
        return YES;
    
    for (NSString *tokenName in [self.context allKeys]) {
        NSDictionary *rules = [self.context objectForKey:tokenName];
        
        NSObject *tokenObject = [TMLDataToken tokenObjectForName: tokenName fromTokens: tokens];
        
        if (tokenObject == nil)
            return NO;

        for (NSString *contextKey in [rules allKeys]) {
            NSString *ruleKey = [rules objectForKey:contextKey];
            
            if ([TMLLanguageContextRule isFallback: ruleKey])
                continue;
            
            TMLLanguageContext *languageContext = (TMLLanguageContext *) [self.language contextByKeyword:contextKey];
            if (languageContext == nil)
                return NO;
                
            TMLLanguageContextRule *rule = (TMLLanguageContextRule *) [languageContext findMatchingRule:tokenObject];
            if (rule == nil || ![rule.keyword isEqualToString:ruleKey])
                return NO;
        }
    }
    
    return YES;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@ [%@](Language: %@; Context: %@)", self.label, self.locale, self.language, self.context];
}



@end
