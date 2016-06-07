//
//  BlueTooth.m
//  ZYBlueToothPrinter
//
//  Created by zhangyi on 16/4/6.
//  Copyright © 2016年 zhangyi. All rights reserved.
//

#import "BlueTooth.h"
#import "ZYBlueToothViewController.h"
#define Printer200ServiceUUID @"E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"

@interface BlueTooth () <CBPeripheralDelegate,CBCentralManagerDelegate>

@property(nonatomic,strong)CBCentralManager     *centralmanager;
@property(nonatomic,strong)CBPeripheral         *cdCBPeripheral;
@property(nonatomic,strong)NSMutableArray       *peripheralData;
@property(nonatomic,strong)NSMutableArray       *perigheralArray;
@property(nonatomic,strong)NSString             *resultString;
@end

@implementation BlueTooth

+ (BlueTooth *)shareBlueTooth
{
    static  BlueTooth * _blueTooth = nil;
    if (!_blueTooth) {
        _blueTooth = [[BlueTooth alloc] init];
    }
    return _blueTooth;
}

- (void)printStringWithContent:(NSString *)string
{
    _resultString = string;
    BlueTooth * blueTooth = [BlueTooth shareBlueTooth];

    if (blueTooth.peripheral && blueTooth.manager.state == 5 && blueTooth.peripheral.state == 2) {
        blueTooth.manager.delegate = self;
        [blueTooth.manager connectPeripheral:blueTooth.peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }else{
        ZYBlueToothViewController * blueToothVC = [[ZYBlueToothViewController alloc] init];
        blueToothVC.contentString = _resultString;
        [((UIViewController *)_parentVC).navigationController pushViewController:blueToothVC animated:YES];
    }
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != 5) {
         UIAlertController  * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"手机蓝牙未打开，请打开手机蓝牙～" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:sureAction];
        [(UIViewController *)_parentVC presentViewController:alertController animated:YES completion:nil];
    }
}

//连接上回调－－但不能确定是否一定成功，还需要在里面多次重连（我没写－－）
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    NSLog(@"已连接上");
}

#pragma mark -- <CBCentralManagerDelegate>
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"didDicoverService");
    if (error) {
        NSLog(@"连接服务:%@ 发生错误:%@",peripheral.name,[error localizedDescription]);
        return;
    }
    for (CBService* service in  peripheral.services) {
//        NSLog(@"扫描到的serviceUUID:%@",service.UUID);
        //这里其实三个服务都可以做打印，但是我只选择了其中一个
        if ([service.UUID isEqual:[CBUUID UUIDWithString:Printer200ServiceUUID]]) {
            //扫描特征
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

//返回的蓝牙特征值通知通过代理实现
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSStringEncoding gbk = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    
    BlueTooth * blueTooth = [BlueTooth shareBlueTooth];
    
    NSInteger length = _resultString.length;
    NSInteger PT_L = 50;
    for (int i = 0; i < length / 50 + 1; i ++) {
        NSRange range;
        range.length = PT_L;
        range.location = PT_L * i;
        if (PT_L * i + PT_L > length) {
            range.length = length - PT_L * i;
        }
        NSString * subString = [_resultString substringWithRange:range];
        NSData *cmdData = [subString dataUsingEncoding:gbk];
        
        if (range.location < length) {
            for (CBCharacteristic * characteristic in service.characteristics) {
                blueTooth.peripheral = peripheral;
                blueTooth.characteristic = characteristic;
                [peripheral writeValue:cmdData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }
        }
    }
}

#pragma mark -- <CBPeripheralDelegate>
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"what --- !!!");
    if (error) {
        NSLog(@"nimab -- %@",error.localizedDescription);
    }
}
@end
