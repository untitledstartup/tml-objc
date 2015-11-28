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


#import <Foundation/Foundation.h>

@class TMLTranslationKey, TMLLanguage;

@interface TMLTranslation : TMLModel

// Reference to the translation key it belongs to
@property(nonatomic, strong) TMLTranslationKey *translationKey;

// Reference to the language it belongs to
@property(nonatomic, strong) TMLLanguage *language;

// Locale of the language it belongs to
@property(nonatomic, strong) NSString *locale;

// Translation label
@property(nonatomic, strong) NSString *label;

@property(assign, nonatomic) BOOL locked;

// Translation context hash:
// {token1: {context1: rule1}, token2: {context2: rule2}}
@property(nonatomic, strong) NSDictionary *context;

// Precedence of the translation.
// The higher the precedence the higher the order of the translation.
@property(nonatomic, assign) NSInteger precedence;

// Check if the translation has context rules
- (BOOL) hasContextRules;

// Checks if the translation is valid for the given tokens
- (BOOL) isValidTranslationForTokens: (NSDictionary *) tokens;

@end
