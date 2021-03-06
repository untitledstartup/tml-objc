/*
 *  Copyright (c) 2014 Michael Berkovich, http://tr8nhub.com All rights reserved.
 *
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
#import "TMLAPISerializer.h"
#import "TMLApplication.h"
#import "TMLLanguage.h"
#import "TMLTestBase.h"

@implementation TMLTestBase

- (NSDictionary *) loadJSON: (NSString *) name {
    NSData *jsonData = [self loadJSONDataFromResource:name];
    NSDictionary *result = [jsonData tmlJSONObject];
    return  result;
}

- (NSData *) loadJSONDataFromResource:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:name ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    return jsonData;
}

- (TMLApplication *) application {
    NSData *jsonData = [self loadJSONDataFromResource:@"app"];
    TMLApplication *app = [TMLAPISerializer materializeData:jsonData withClass:[TMLApplication class]];
    return app;
}

- (TMLLanguage *) languageForLocale: (NSString *) locale {
    NSData *jsonData = [self loadJSONDataFromResource:locale];
    TMLLanguage *lang = [TMLAPISerializer materializeData:jsonData withClass:[TMLLanguage class]];
    return lang;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.x
    [super tearDown];
}

@end
