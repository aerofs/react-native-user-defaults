#import "RCTUserDefaults.h"

#define DEFAULT_PREFIX @"__SOME_RANDOM_PREFIX_"

@implementation RCTUserDefaults

-(NSUserDefaults*)userDefaultsForSuiteName:(NSString *)suiteName {
    if (suiteName && ![suiteName isEqualToString:@""]) {
        return [[NSUserDefaults alloc] initWithSuiteName:suiteName];
    }
    return [NSUserDefaults standardUserDefaults];
}

-(NSString*)keyWithPrefixForKey:(NSString *)key suiteName:(NSString *)suiteName {
    NSString *prefix = [[suiteName componentsSeparatedByString: @"."] lastObject];
    if (prefix == nil) {
        prefix = DEFAULT_PREFIX;
    }
    NSString *keyWithPrefix = [NSString stringWithFormat:@"%@-%@", prefix, key];
    return keyWithPrefix;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(setObject:(NSString *)key value:(NSString *)value suiteName:(NSString *)suiteName callback:(RCTResponseSenderBlock)cb) {
    NSUserDefaults *userDefaults = [self userDefaultsForSuiteName:suiteName];
    [userDefaults setObject:value forKey:[self keyWithPrefixForKey:key suiteName:suiteName]];
    cb(@[[NSNull null] ,@"Save success"]);
}

RCT_EXPORT_METHOD(getObject:(NSString *)key suiteName:(NSString *)suiteName callback:(RCTResponseSenderBlock)cb) {
    NSUserDefaults *userDefaults = [self userDefaultsForSuiteName:suiteName];
    NSString *result = [userDefaults stringForKey:[self keyWithPrefixForKey:key suiteName:suiteName]];
    if (result) {
        cb(@[[NSNull null], result]);
    } else {
        cb(@[@YES]);
    }
}

RCT_EXPORT_METHOD(removeObject:(NSString *)key suiteName:(NSString *)suiteName callback:(RCTResponseSenderBlock)cb) {
    NSUserDefaults *userDefaults = [self userDefaultsForSuiteName:suiteName];
    [userDefaults removeObjectForKey:[self keyWithPrefixForKey: key suiteName:suiteName]];
    cb(@[[NSNull null] ,@"Remove success"]);
}

RCT_EXPORT_METHOD(empty:(NSString *)suiteName callback:(RCTResponseSenderBlock)cb) {
    NSUserDefaults *userDefaults = [self userDefaultsForSuiteName:suiteName];
    NSDictionary *defaultsDict = [userDefaults dictionaryRepresentation];
    for (NSString *key in [defaultsDict allKeys]) {
        NSString *prefix = [[suiteName componentsSeparatedByString: @"."] lastObject];
        if (prefix == nil) prefix = DEFAULT_PREFIX;
        if ([key hasPrefix:prefix]) {
            [userDefaults removeObjectForKey:key];
        }
    }
    cb(@[[NSNull null] ,@"Empty success"]);
}

RCT_EXPORT_METHOD(getAllInSuite:(NSString *)suiteName callback:(RCTResponseSenderBlock)cb) {
    NSUserDefaults *userDefaults = [self userDefaultsForSuiteName:suiteName];
    NSDictionary *allDict = [userDefaults dictionaryRepresentation];
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] initWithCapacity:10];
    for (NSString *key in [allDict allKeys]) {
        NSString *prefix = [[suiteName componentsSeparatedByString: @"."] lastObject];
        if (prefix == nil) prefix = DEFAULT_PREFIX;
        if ([key hasPrefix:prefix]) {
            NSString *withoutPrefix = [key substringFromIndex:prefix.length + 1];
            [returnDict setObject:[allDict objectForKey:key] forKey:withoutPrefix];
        }
    }
    cb(@[[NSNull null], returnDict]);
}

@end
