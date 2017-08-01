//
//  ViewController.m
//  苹果内购优化版
//
//  Created by lin on 2017/7/29.
//  Copyright © 2017年 qd. All rights reserved.
//

#import "ViewController.h"
#import "QDIAPManager.h"
#import "SVProgressHUD.h"
@interface ViewController ()<QDIAPManageDelegate,
UITableViewDataSource,
UITableViewDelegate>


@property (nonatomic,strong) UITableView    *tabV;

@property (nonatomic,strong) NSMutableArray *productArray;

@end

@implementation ViewController


-(NSMutableArray *)productArray{
    if(!_productArray){
        _productArray = [NSMutableArray array];
    }
    return _productArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupViews];
    
    //获取单例
    QDIAPManager *IAPTool = [QDIAPManager defaultTool];
    
    //设置代理
    IAPTool.delegate = self;
    
    //购买后，向苹果服务器验证一下购买结果。默认为YES。不建议关闭
    //IAPTool.CheckAfterPay = NO;
    
    [SVProgressHUD showWithStatus:@"向苹果询问哪些商品能够购买"];
    
    //向苹果询问哪些商品能够购买
    [IAPTool requestProductsWithProductArray:@[@"zhendian.org60",                                               @"zhendian.org300",
                                              @"zhendian.org600",
                                              @"zhendian.org1000"]];
  
}

#pragma mark --------QDIAPManageDelegate
//IAP工具已获得可购买的商品
-(void)IAPToolGotProducts:(NSMutableArray *)products {
    NSLog(@"GotProducts:%@",products);
    //    for (SKProduct *product in products){
    //        NSLog(@"localizedDescription:%@\nlocalizedTitle:%@\nprice:%@\npriceLocale:%@\nproductID:%@",
    //              product.localizedDescription,
    //              product.localizedTitle,
    //              product.price,
    //              product.priceLocale,
    //              product.productIdentifier);
    //        NSLog(@"--------------------------");
    //    }
    self.productArray = products;

    [self.tabV reloadData];
    
     [SVProgressHUD showSuccessWithStatus:@"成功获取到可购买的商品"];
    
}
//支付失败/取消
-(void)IAPToolCanceldWithProductID:(NSString *)productID {
    NSLog(@"取消或者失败:%@",productID);
    
     [SVProgressHUD showInfoWithStatus:@"购买失败"];
}
//支付成功了，并开始向苹果服务器进行验证（若CheckAfterPay为NO，则不会经过此步骤）
-(void)IAPToolBeginCheckingdWithProductID:(NSString *)productID {
    NSLog(@"支付成功:%@",productID);
    
     [SVProgressHUD showWithStatus:@"购买成功，正在验证购买"];
    
}
//商品被重复验证了
-(void)IAPToolCheckRedundantWithProductID:(NSString *)productID {
    NSLog(@"CheckRedundant:%@",productID);
    
     [SVProgressHUD showInfoWithStatus:@"重复验证了"];
    
}
//商品完全购买成功且验证成功了。（若CheckAfterPay为NO，则会在购买成功后直接触发此方法）
-(void)IAPToolBoughtProductSuccessedWithProductID:(NSString *)productID
                                          andInfo:(NSDictionary *)infoDic {
    
    NSLog(@"BoughtSuccessed:%@",productID);
    NSLog(@"successedInfo:%@",infoDic);
    
    [SVProgressHUD showSuccessWithStatus:@"商品购买成功"];
    
}
//商品购买成功了，但向苹果服务器验证失败了
//2种可能：
//1，设备越狱了，使用了插件，在虚假购买。
//2，验证的时候网络突然中断了。（一般极少出现，因为购买的时候是需要网络的）
-(void)IAPToolCheckFailedWithProductID:(NSString *)productID
                               andInfo:(NSData *)infoData {
    
    NSLog(@"CheckFailed:%@",productID);
    
     [SVProgressHUD showErrorWithStatus:@"验证失败了"];
    
}
//恢复了已购买的商品（仅限永久有效商品）
-(void)IAPToolRestoredProductID:(NSString *)productID {
    
    NSLog(@"Restored:%@",productID);
    
    [SVProgressHUD showSuccessWithStatus:@"成功恢复了商品（已打印）"];
    
}
//内购系统错误了
-(void)IAPToolSysWrong {
    NSLog(@"SysWrong");
    
     [SVProgressHUD showErrorWithStatus:@"内购系统出错"];
}


#pragma mark --------Functions
//初始化界面显示
-(void)setupViews{
    self.tabV = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tabV.delegate = self;
    self.tabV.dataSource = self;
    
    [self.view addSubview:self.tabV];
    
    //注册重用单元格
    [self.tabV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MyCell"];
    
    
}



//购买商品
-(void)BuyProduct:(SKProduct *)product{
    
    [SVProgressHUD showWithStatus:@"正在购买商品"];
    
    [[QDIAPManager defaultTool]buyProduct:product.productIdentifier];
}

#pragma mark --------UITableViewDataSource,UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.productArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 220;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //自动从重用队列中取得名称是MyCell的注册对象,如果没有，就会生成一个
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    
    //清除cell上的原有view
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
    SKProduct *product = self.productArray[indexPath.section];
    
    //cell的设置
    cell.textLabel.text = [NSString stringWithFormat:@"本地化商品描述:%@\n\n本地化商品标题:%@\n\n价格:%@\n\n商品ID:%@",
                           product.localizedDescription,
                           product.localizedTitle,
                           product.price,
                           product.productIdentifier];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tabV deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([SVProgressHUD isVisible] == YES) {
        
        NSLog(@"正在购买，不能点击");
        
        return;

        
    }else{
      
        
        [self BuyProduct:self.productArray[indexPath.row]];
    }
    
    
}


@end
