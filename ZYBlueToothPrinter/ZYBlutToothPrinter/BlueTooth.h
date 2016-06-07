//
//  BlueTooth.h
//  ZYBlueToothPrinter
//
//  Created by zhangyi on 16/4/6.
//  Copyright © 2016年 zhangyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

@interface BlueTooth : NSObject

+ (BlueTooth *)shareBlueTooth;
//
@property (strong, nonatomic) CBCharacteristic * characteristic;
@property (strong, nonatomic) CBPeripheral     * peripheral;
@property (strong, nonatomic) CBCentralManager * manager;

@property (assign, nonatomic) id               parentVC;

- (void)printStringWithContent:(NSString *)string;

@end
