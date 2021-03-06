/*
 *  Copyright (c) 2017 Translation Exchange, Inc. All rights reserved.
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


#import "TMLTranslator.h"

NSString * const TMLTranslatorIDKey = @"id";
NSString * const TMLTranslatorUserIDKey = @"user_id";
NSString * const TMLTranslatorLevelKey = @"level";
NSString * const TMLTranslatorRankKey = @"rank";
NSString * const TMLTranslatorVotingPowerKey = @"voting_power";
NSString * const TMLTranslatorRoleKey = @"role";

@implementation TMLTranslator

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.translatorID forKey:TMLTranslatorIDKey];
    [aCoder encodeInteger:self.userID forKey:TMLTranslatorUserIDKey];
    [aCoder encodeObject:self.role forKey:TMLTranslatorRoleKey];
    [aCoder encodeInteger:self.level forKey:TMLTranslatorLevelKey];
    [aCoder encodeInteger:self.rank forKey:TMLTranslatorRankKey];
    [aCoder encodeInteger:self.votingPower forKey:TMLTranslatorVotingPowerKey];
}

- (void)decodeWithCoder:(NSCoder *)aDecoder {
    [super decodeWithCoder:aDecoder];
    
    self.translatorID = [aDecoder decodeIntegerForKey:TMLTranslatorIDKey];
    self.userID = [aDecoder decodeIntegerForKey:TMLTranslatorUserIDKey];
    self.role = [aDecoder decodeObjectForKey:TMLTranslatorRoleKey];
    self.level = [aDecoder decodeIntegerForKey:TMLTranslatorLevelKey];
    self.rank = [aDecoder decodeIntegerForKey:TMLTranslatorRankKey];
    self.votingPower = [aDecoder decodeIntegerForKey:TMLTranslatorVotingPowerKey];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    else if ([object isKindOfClass:[TMLTranslator class]] == NO) {
        return NO;
    }
    return [self isEqualToTranslator:object];
}

- (BOOL)isEqualToTranslator:(TMLTranslator *)translator {
    return self.translatorID != translator.translatorID;
}

@end
