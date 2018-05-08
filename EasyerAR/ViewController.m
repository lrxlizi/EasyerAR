//
//  ViewController.m
//  EasyerAR
//
//  Created by 栗子 on 2018/5/8.
//  Copyright © 2018年 http://www.cnblogs.com/Lrx-lizi/.     https://github.com/lrxlizi/. All rights reserved.
//

#import "ViewController.h"
#import "ARScanViewController.h"
#import "PopView.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *imageArr;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClicekd) forControlEvents:UIControlEventTouchUpInside];
    
    self.imageArr =  @[ @"http://f.qncdn.orunapp.com/image/2018/0508/20180508030730449_184.jpeg",
       @"http://f.qncdn.orunapp.com/image/2018/0424/20180424034610601_822.png",
                     @"http://f.qncdn.orunapp.com/image/2018/0427/20180427031112614_793.png"];
    
    
}

- (void)btnClicekd{
    ARScanViewController *ar = [ARScanViewController new];
    ar.arArray = [self arImage:self.imageArr];
    [self.navigationController pushViewController:ar animated:NO];
    
}


#pragma mark - 网络图片路径改为本地路径(若是本地图片直接用就行了)

-(NSArray *)arImage:(NSArray *)resourceImgArr{

    NSMutableArray *pathArr = [NSMutableArray array];
    if (resourceImgArr.count) {
    //AR扫描
        NSArray *template = resourceImgArr;
        if (template.count > 0)
        {
            for (int i = 0; i < template.count; i++)
            {
                NSString *path = [NSString stringWithFormat:@"%@",template[i]];
                path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                if (![pathArr containsObject:path])
                {
                    [pathArr addObject:path];
                }
            }
        }
    }
    
    NSMutableArray *picArrLast = [NSMutableArray array];
    for (NSString *urlStr in pathArr)
    {
        NSURL *url = [NSURL URLWithString:urlStr];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        if (![manager diskImageExistsForURL:url])
        {//图片没下载 添加下载队列
            [picArrLast addObject:urlStr];
        }
    }
    
    NSMutableArray *arArray = [NSMutableArray array];
    if (picArrLast.count == 0 && pathArr.count > 0)
    {//图片都下载好了
        for (NSString *path in pathArr) {
            NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:path]];
            if (cacheImageKey.length)
            {
                NSString *cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
                if (cacheImagePath.length)
                {
                    [arArray addObject:cacheImagePath];
                }
            }
        }
    }else
    {//图片未全部下载完成
        SDWebImagePrefetcher *magePre = [SDWebImagePrefetcher sharedImagePrefetcher];
        [magePre prefetchURLs:picArrLast progress:^(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls) {
        } completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
        }];
    }
    
    if (arArray.count != 0)
    {
        return arArray;
    }else
    {
        NSLog(@"资源错误");
    }
    return nil;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
