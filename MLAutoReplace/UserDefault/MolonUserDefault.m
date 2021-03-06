//
//  MolonUserDefault.m
//  InventoryTool
//
//  Created by molon on 3/7/14.
//  Copyright (c) 2014 Molon. All rights reserved.
//

#import "MolonUserDefault.h"
#import "ClassProperties.h"


NSString * const kPrefixKeyOfUserDefault = @"com.molon.";
@implementation MolonUserDefault

+ (instancetype)shareInstance {
    static MolonUserDefault *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[[self class] alloc]init];
    });
    return _shareInstance;
}

- (void)initValues
{
    //这里需要继承做初始化赋值，即为默认值
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //赋默认值
        [self initValues];
        
        //获取属性
        NSDictionary *properties = [[ClassProperties shareInstance]getPropertiesOfClass:[self class] untilSuperClass:[MolonUserDefault class]];
        
        //遍历初始赋值
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        
        for (NSString *key in [properties allKeys]) {
            id object = [def objectForKey:[NSString stringWithFormat:@"%@%@",kPrefixKeyOfUserDefault,key]];
            if (object) {
                [self setValue:object forKey:key];
            }
            
            //对应添加KVO
            [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
        }
    }
    return self;
}

- (void)dealloc
{
    //获取属性
    NSDictionary *properties = [[ClassProperties shareInstance]getPropertiesOfClass:[self class]];
    for (NSString *key in [properties allKeys]) {
        //对应删除KVO
        [self removeObserver:self forKeyPath:key context:nil];
    }
}


#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
    
    if ([kind integerValue] == NSKeyValueChangeSetting) {
        id oldObject = [change objectForKey:NSKeyValueChangeOldKey];
        id newObject = [change objectForKey:NSKeyValueChangeNewKey];
        if (![oldObject isEqual:newObject]) {
            //写入userdefault
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSString *key = [NSString stringWithFormat:@"%@%@",kPrefixKeyOfUserDefault,keyPath];
            if (!newObject||[newObject isKindOfClass:[NSNull class]]) {
                [def removeObjectForKey:key];
            }else{
                [def setObject:newObject forKey:key];
            }
            [def synchronize];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

@end
