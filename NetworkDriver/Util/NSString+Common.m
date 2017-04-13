//
//  NSString+Common.m
//  MZJD
//
//  Created by mac on 14-4-14.
//  Copyright (c) 2014年 DIGIT. All rights reserved.
//

#import "NSString+Common.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

#define gkey            @"abcdefghijklmntygoonbaby"
#define gIv             @"01234567"

@implementation NSString (Common)

/**
 *	@brief	缓存目录下的文件夹路径，有则获取，无则创建
 *
 *	@param 	dir 	文件夹
 *
 *	@return	路径
 */
+ (NSString *)getCachePath:(NSString *)dir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory =  [paths objectAtIndex:0];
    if (dir) {
        directory = [directory stringByAppendingPathComponent:dir];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return directory;
}

/**
 *	@brief	Document目录下的文件夹路径，有则获取，无则创建
 *
 *	@param 	dir 	文件夹
 *
 *	@return	路径
 */
+ (NSString *)getDocumentPath:(NSString *)dir
{
    NSString *directory =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if (dir) {
        directory = [directory stringByAppendingPathComponent:dir];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return directory;
}

/**
 *	@brief	日期转时间字符串
 *
 *	@param 	format 	时间格式
 *	@param 	date 	日期
 *
 *	@return	时间字符串
 */
+ (NSString *)stringByDate:(NSString *)format Date:(NSDate *)date;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *timeString = [formatter stringFromDate:date];
    
    return timeString;
}

/**
 *	@brief	字符串转日期
 *
 *	@param 	string 	字符串
 *
 *	@return	日期
 */
+ (NSDate *)convertStringToDate:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:string];
    
    return date;
}

/**
 *	@brief	HmacSHA1加密
 *
 *	@param 	key 	密钥
 *	@param 	text 	待加密内容
 *
 *	@return	加密后内容
 */
+ (NSString *) hmacSha1:(NSString*)key text:(NSString*)text
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hash = [HMAC base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return hash;
}

/**
 *	@brief	HmacSHA1加密
 *
 *	@param 	key 	密钥
 *	@param 	dic 	待加密内容
 *
 *	@return	加密后内容
 */
+ (NSString *) hmacSha1:(NSString*)key dic:(NSDictionary *)dic
{
    NSArray *keys = [dic allKeys];
    if ([keys count] <= 0) {
        return nil;
    }
    
    NSMutableArray *sortArr = [NSMutableArray arrayWithArray:keys];
    [sortArr sortUsingSelector:@selector(compare:)];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *keyId in sortArr) {
        NSString *value = [dic valueForKey:keyId];
        if ([value isKindOfClass:[NSArray class]]) {
            NSUInteger count = [(NSArray *)value count];
            if (count <= 0) {
                value = @"[]";
            }
            else
            {
                NSMutableArray *tempArr = [NSMutableArray array];
                for (NSDictionary *tempDic in (NSArray *)value) {
                    NSMutableArray *tempSubArr = [NSMutableArray array];
                    NSArray *tempkeys = [tempDic allKeys];
                    for (NSString *tempKey in tempkeys) {
                        NSString *tempValue = [tempDic valueForKey:tempKey];
                        NSString *tempSubStr = [NSString stringWithFormat:@"\"%@\":\"%@\"",tempKey,tempValue];
                        [tempSubArr addObject:tempSubStr];
                    }
                    NSString *str = [NSString stringWithFormat:@"{%@}",[tempSubArr componentsJoinedByString:@","]];
                    [tempArr addObject:str];
                }
                value = [NSString stringWithFormat:@"[%@]",[tempArr componentsJoinedByString:@","]];
            }
        }
        else if ([value isKindOfClass:[NSNumber class]])
        {
            value = [(NSNumber *)value stringValue];
        }
        else if ([value isKindOfClass:[NSNull class]])
        {
            value = @"null";
        }
        NSString *str = [NSString stringWithFormat:@"%@=%@",keyId,value];
        [array addObject:str];
    }
    
    NSString *text = [array componentsJoinedByString:@"&"];
    NSString *lastStr = [NSString hmacSha1:key text:text];
    return lastStr;
}

/**
 *	@brief	获取一个随机整数，范围在[from,to]
 *
 *	@param 	from 	最小值
 *	@param 	to 	最大值
 *
 *	@return	范围在[from,to]中的一个随机数
 */
+ (NSString *)getRandomNumber:(long long)from to:(long long)to
{
    long long number = from + arc4random() % (to - from);
    return [NSString stringWithFormat:@"%lld",number];
}

/**
 *	@brief	md5加密
 *
 *	@param 	str 	待加密字符串
 *
 *	@return	加密后的字符串
 */
+ (NSString *)md5:(NSString *)str
{
    const char *charStr = [str UTF8String];
    if (charStr == NULL) {
        charStr = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(charStr, (CC_LONG)strlen(charStr), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

/**
 *	@brief	获取文件类型
 *
 *	@param 	urlStr 	网址
 *
 *	@return	文件后缀
 */
+ (NSString *)getImageType:(NSString *)urlStr
{
    NSString *imageType = @"jpg";
    //从url中获取图片类型
    NSMutableArray *arr = (NSMutableArray *)[urlStr componentsSeparatedByString:@"."];
    if (arr) {
        imageType = [arr objectAtIndex:arr.count - 1];
    }
    if ([[imageType lowercaseString] isEqualToString:@"png"])
    {
        imageType = @"png";
    }
    else if ([[imageType lowercaseString] isEqualToString:@"jpg"] || [[imageType lowercaseString] isEqualToString:@"jpeg"])
    {
        imageType = @"jpg";
    }
    else
    {
        imageType = nil;
    }
    return imageType;
}

/**
 *	@brief	切分字符串
 *
 *	@param 	str 	字符串
 *
 *	@return	数组
 */
+ (NSArray *)spliteStr:(NSString *)str
{
    NSArray *array = [str componentsSeparatedByString:@"[img"];
    NSMutableArray *lastArr = [NSMutableArray array];
    for (NSString *subStr in array) {
        if ([subStr isEqualToString:@"\n"] || [subStr isEqualToString:@""]) {
            continue;
        }
        NSString *newsubStr = [subStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
        NSArray *secArr = [newsubStr componentsSeparatedByString:@"\"]"];
        for (NSString *secSub in secArr) {
            if ([secSub isEqualToString:@"\n"] || [secSub isEqualToString:@""]) {
                continue;
            }
            NSString *newsecSub = [secSub stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
            
            if ([newsecSub hasPrefix:@"+id"]) {
                NSRange range = [newsecSub rangeOfString:@"http"];
                NSString *imgStr = [newsecSub substringFromIndex:range.location];
                [lastArr addObject:imgStr];
            }
            else
            {
                [lastArr addObject:newsecSub];
            }
        }
    }
    
    return lastArr;
}

/**
 *	@brief	获取字节数
 *
 *	@param 	_str 	字符串
 *
 *	@return	字节数
 */
+ (int)calc_charsetNum:(NSString *)_str
{
    int strlength = 0;
    char *p = (char *)[_str cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0 ; i < [_str lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
    
}

/**
 *	@brief	计算时间
 *
 *	@param 	pubTime 	时间
 *
 *	@return	计算后的时间
 */
+ (NSString *)calculateTimeDistance:(NSString *)pubTime
{
    //时间
    NSString *time = [pubTime stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    time = [time stringByReplacingOccurrencesOfString:@"-" withString:@""];
    time = [time stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd HHmmss"];
    NSDate *date = [dateFormatter dateFromString:time];
    NSTimeInterval timeInterval = fabs([date timeIntervalSinceNow]);
    NSString *timeStr = nil;
    if (timeInterval < 60) {
        timeStr = [NSString stringWithFormat:@"%.0f秒前",timeInterval];
        //timeStr = @"1分钟前";
    }
    else
    {
        timeInterval = timeInterval / 60;
        if (timeInterval < 60) {
            timeStr = [NSString stringWithFormat:@"%.0f分钟前",timeInterval];
        }
        else
        {
            NSDateFormatter *indexDateFormatter = [[NSDateFormatter alloc] init];
            [indexDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *indexDate = [indexDateFormatter dateFromString:pubTime];
            [indexDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
            timeStr = [indexDateFormatter stringFromDate:indexDate];
            /*timeInterval = timeInterval / 60;
            if (timeInterval < 24) {
                timeStr = [NSString stringWithFormat:@"%.0f小时前",timeInterval];
            }
            else
            {
                timeInterval = timeInterval / 24;
                if (timeInterval < 30) {
                    timeStr = [NSString stringWithFormat:@"%.0f天前",timeInterval];
                }
                else
                {
                    timeInterval = timeInterval / 30;
                    if (timeInterval < 12) {
                        timeStr = [NSString stringWithFormat:@"%.0f月前",timeInterval];
                    }
                    else
                    {
                        timeInterval = timeInterval / 12;
                        timeStr = [NSString stringWithFormat:@"%.0f年前",timeInterval];
                    }
                    //timeStr = pubTime;
                }
            }*/
        }
    }
    
    return timeStr;
}

/**
 *	@brief	比较是否同一天
 *
 *	@param 	first 	当前日期
 *	@param 	other 	其他日期
 *
 *	@return	yes－同一天
 */
+ (BOOL)compareSameDay:(NSString *)first Other:(NSString *)other
{
    //时间
    NSString *time = [first stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    time = [time stringByReplacingOccurrencesOfString:@"-" withString:@""];
    time = [time stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSString *time2 = [other stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    time2 = [time2 stringByReplacingOccurrencesOfString:@"-" withString:@""];
    time2 = [time2 stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *date1 = [dateFormatter dateFromString:time];
    NSDate *date2 = [dateFormatter dateFromString:time2];
    
    return ([date1 compare:date2] == NSOrderedSame);
}

/**
 *	@brief	键盘表情输入判断
 *
 *	@param 	string 	表情
 *
 *	@return	yes－表情
 */
+ (BOOL)isContainsEmoji:(NSString *)string {
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     isEomji = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 isEomji = YES;
             }
             //判断是否匹配特殊字符
             NSString *regex = @"^[a-zA-Z0-9_\u4e00-\u9fa5]+$";
             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
             BOOL isValid = [predicate evaluateWithObject:substring];
             isEomji=!isValid;
             
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
         }
     }];
    return isEomji;
}

/**
 *	@brief	键盘表情输入判断
 *
 *	@param 	string 	表情
 *
 *	@return	yes－表情
 */
+ (int ) containsEmoji:(NSString *)string {
    __block int  eomji = -1;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     
                     eomji=(int)(substringRange.location*10000+substringRange.length);
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                eomji=(int)(substringRange.location*10000+substringRange.length);
             }
             
             //判断是否匹配特殊字符
             NSString *regex = @"^[a-zA-Z0-9_\u4e00-\u9fa5]+$";
             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
             BOOL isValid = [predicate evaluateWithObject:substring];
             if (!isValid) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             }
             
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             }
         }
     }];
    return eomji;
}

/**
 *	@brief	判断是否输入的汉字数字字母组合
 *
 *	@param 	string 	文本内容
 *
 *	@return	yes－正常
 */
+(BOOL)isText:(NSString *)value
{
    //判断是否匹配特殊字符
    NSString *regex = @"^[a-zA-Z0-9\u4e00-\u9fa5]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:value];
    return isValid;
}

#pragma mark - utf8
+ (NSString *)stringByUTF8:(NSString *)oriStr
{
    if (oriStr.length == 0) {
        return @"";
    }
    
    NSString *value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)oriStr,NULL,CFSTR("!'();:@&=+$,/?%#[]~"),kCFStringEncodingUTF8));
    return value;
}

#pragma mark - calculate
+ (CGSize)calculeteSizeBy:(NSString *)str Font:(UIFont *)font MaxWei:(CGFloat)wei
{
    CGSize lastSize = CGSizeZero;
    if ([str length] > 0) {
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [str boundingRectWithSize:CGSizeMake(wei, CGFLOAT_MAX) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    }
    return lastSize;
}

+ (NSDictionary *)convertDicToStr:(NSDictionary *)dic
{
    NSMutableDictionary *oneDic = [NSMutableDictionary dictionary];
    NSArray *oneArray = [dic allKeys];
    for (NSString *oneKey in oneArray) {
        id oneValue = [dic valueForKey:oneKey];
        if ([oneValue isKindOfClass:[NSString class]]) {
            [oneDic setValue:[oneValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[oneKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        else if ([oneValue isKindOfClass:[NSDictionary class]])
        {
            NSArray *twoArray = [oneValue allKeys];
            NSMutableDictionary *twoDic = [NSMutableDictionary dictionary];
            for (NSString *twoKey in twoArray) {
                id twoValue = [oneValue valueForKey:twoKey];
                if ([twoValue isKindOfClass:[NSString class]])
                {
                    [twoDic setObject:[twoValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[twoKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
                else if ([twoValue isKindOfClass:[NSArray class]])
                {
                    NSMutableArray *thirdArr = [NSMutableArray array];
                    for (id thirdKey in twoValue) {
                        if ([thirdKey isKindOfClass:[NSString class]]) {
                            [thirdArr addObject:[thirdKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        }
                        else if ([thirdKey isKindOfClass:[NSArray class]])
                        {
                            NSMutableArray *fourArr = [NSMutableArray array];
                            for (NSString *fourKey in thirdKey) {
                                [fourArr addObject:[fourKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                            }
                            [thirdArr addObject:fourArr];
                        }
                        else if ([thirdKey isKindOfClass:[NSDictionary class]])
                        {
                            NSMutableDictionary *fourDic = [NSMutableDictionary dictionary];
                            NSArray *fourArr = [thirdKey allKeys];
                            for (NSString *fourKey in fourArr) {
                                NSString *fourValue = [thirdKey valueForKey:fourKey];
                                [fourDic setValue:[fourValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[fourKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                            }
                            [thirdArr addObject:fourDic];
                        }
                    }
                    [twoDic setValue:thirdArr forKey:[twoKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
                else if ([twoValue isKindOfClass:[NSDictionary class]])
                {
                    NSArray *thirdArr = [twoValue allKeys];
                    NSMutableDictionary *thirdDic = [NSMutableDictionary dictionary];
                    for (NSString *thirdKey in thirdArr) {
                        id thirdValue = [twoValue objectForKey:thirdKey];
                        if ([thirdValue isKindOfClass:[NSString class]]) {
                            [thirdDic setValue:[thirdValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[thirdKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        }
                        else if ([thirdValue isKindOfClass:[NSArray class]])
                        {
                            NSMutableArray *fourArr = [NSMutableArray array];
                            for (id fourValue in thirdValue) {
                                if ([fourValue isKindOfClass:[NSArray class]]) {
                                    NSMutableArray *fiveArr = [NSMutableArray array];
                                    for (NSString *fiveValue in fourValue) {
                                        [fiveArr addObject:[fiveValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                    }
                                    [fourArr addObject:fiveArr];
                                }
                                else if ([fourValue isKindOfClass:[NSString class]])
                                {
                                    [fourArr addObject:[fourValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                }
                                
                            }
                            [thirdDic setValue:fourArr forKey:[thirdKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        }
                    }
                    [twoDic setValue:thirdDic forKey:[twoKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
            }
            [oneDic setValue:twoDic forKey:[oneKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    return oneDic;
}

+ (CGFloat)getFloadSize:(CGFloat)plus six:(CGFloat)six five:(CGFloat)five{
    return iPhone6Plus ? plus : (iPhone6 ? six : five);
}

@end
