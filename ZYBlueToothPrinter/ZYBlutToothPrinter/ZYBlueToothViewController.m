//
//  ZYBlueToothViewController.m
//  ZYBlueToothPrinter
//
//  Created by zhangyi on 16/4/6.
//  Copyright © 2016年 zhangyi. All rights reserved.
//

#import "ZYBlueToothViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BlueTooth.h"
#define Printer169 @"49535343-FE7D-4AE5-8FA9-9FAFD205E455"
#define Printer200ServiceUUID @"E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"

@interface ZYBlueToothViewController ()<CBPeripheralDelegate,CBCentralManagerDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)CBCentralManager *centralmanager;
@property(nonatomic,strong)CBPeripheral     *cdCBPeripheral;
@property(nonatomic,strong)NSMutableArray   *peripheralData;
@property(nonatomic,strong)NSMutableArray   *perigheralArray;
@property(nonatomic,strong)UIButton         *button;

@property(nonatomic,strong)UITableView      *showtableview;

@property(nonatomic,strong)UILabel          *stateLabel;

@end

@implementation ZYBlueToothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeUserInterface];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.navigationItem.title = @"蓝牙打印小票";
    }
    return self;
}

- (void)initializeUserInterface
{
    self.view.backgroundColor = [UIColor whiteColor];
    BlueTooth * blueTooth = [BlueTooth shareBlueTooth];
    _centralmanager = ({
       CBCentralManager * manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
        manager.delegate = self;
        manager;
    });
    blueTooth.manager = _centralmanager;
    
    _peripheralData = [[NSMutableArray alloc] init];
    _perigheralArray = [[NSMutableArray alloc] init];
    
    _showtableview = ({
        UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:tableView];
        tableView;
    });
    
    _stateLabel = ({
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
        label.textColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"暂时没有发现蓝牙设备哦⊙ｏ⊙";
        label.center = self.view.center;
        [self.showtableview addSubview:label];
        label;
    });

}

- (void)viewDidAppear:(BOOL)animated
{
     [_centralmanager scanForPeripheralsWithServices:nil options:nil];
    
    NSLog(@"wocao -- %ld",_centralmanager.state);
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"wlegecao -- %ld",_centralmanager.state);
    [_centralmanager stopScan];
}

//扫描回调－－每扫描到一次都会回调
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"%@",advertisementData);
    if (![self.peripheralData containsObject:peripheral.identifier.UUIDString]) {
        [self.peripheralData addObject:peripheral.identifier.UUIDString];
        [self.perigheralArray addObject:peripheral];
        _stateLabel.hidden = YES;
        [_showtableview reloadData];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != 5) {
        UIAlertController  * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"手机蓝牙未打开，请打开手机蓝牙～" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:sureAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


//cell
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.peripheralData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
    cell.textLabel.text = ((CBPeripheral *)(self.perigheralArray[indexPath.row])).name;
    UIView *backview = [[UIView alloc]init];
    backview.backgroundColor = [UIColor lightGrayColor];
    [cell setBackgroundView:backview];
    [cell setBackgroundColor:[UIColor clearColor]];
    backview.layer.cornerRadius = 10.0;
    backview.layer.borderWidth = 1.0;
    
    return cell;
}

/*设置标题头的宽度*/
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    titleLabel.text = @"    请选择蓝牙打印机";
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    return titleLabel;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_centralmanager stopScan];
    [self.centralmanager connectPeripheral:self.perigheralArray[indexPath.row] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
}

//连接上回调－－但不能确定是否一定成功，还需要在里面多次重连（我没写－－）
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    self.cdCBPeripheral = peripheral;
    self.cdCBPeripheral.delegate = self;
    [peripheral discoverServices:nil];
    NSLog(@"已连接上");
}

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
    
    NSInteger length = _contentString.length;
    NSInteger PT_L = 50;
    for (int i = 0; i < length / 50 + 1; i ++) {
        NSRange range;
        range.length = PT_L;
        range.location = PT_L * i;
        if (PT_L * i + PT_L > length) {
            range.length = length - PT_L * i;
        }
        NSString * subString = [_contentString substringWithRange:range];
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

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error

{
    NSLog(@"what --- !!!");
    if (error) {
        NSLog(@"nimab -- %@",error.localizedDescription);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error

{
    NSLog(@"out you go!!!");
    NSLog(@"error -- %@",error.localizedDescription);
}

@end
