/*
 * Copyright (C) 2014 The Illinois-Indiana Sea Grant
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "NSString+ConvertingHTML.h"

@implementation NSString (ConvertingHTML)

-(NSString *) convertHTMLBodyToText
{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSString *bodyText = nil;
    NSString *tagText = nil;
    
    [scanner scanUpToString:@"<body>" intoString:NULL];
    [scanner scanUpToString:@"</body>" intoString:&bodyText];
    
    scanner = [NSScanner scannerWithString:bodyText];
    
    while ([scanner isAtEnd] == NO) {
        
        [scanner scanUpToString:@"<" intoString:NULL] ;
        
        [scanner scanUpToString:@">" intoString:&tagText] ;
        
        bodyText = [bodyText stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", tagText] withString:@""];
    }
    
    bodyText = [bodyText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return bodyText;
}

@end
