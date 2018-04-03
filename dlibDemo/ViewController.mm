//
//  ViewController.m
//  dlibDemo
//
//  Created by MisterBooo on 2018/3/28.
//  Copyright © 2018年 MisterBooo. All rights reserved.
//

#import "ViewController.h"
#include <dlib/image_processing.h>
#include <dlib/image_io.h>
#import "OpenCVBaseVC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)gpuVideo:(id)sender {
    OpenCVBaseVC *vc = [[OpenCVBaseVC alloc] initWithType:1];
    vc.title = @"GPU";
    [self.navigationController pushViewController:vc animated:YES];

}
- (IBAction)dlibVideo:(id)sender {
    OpenCVBaseVC *vc = [[OpenCVBaseVC alloc] initWithType:0];
    vc.title = @"Dlib";
    [self.navigationController pushViewController:vc animated:YES];
}



@end
