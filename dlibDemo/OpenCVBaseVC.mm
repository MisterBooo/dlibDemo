//
//  OpenCVBaseVC.m
//  OpenCVDemo
//
//  Created by PacteraLF on 2017/7/11.
//  Copyright © 2017年 PacteraLF. All rights reserved.
//

#import "OpenCVBaseVC.h"
#import "DlibWrapper.h"
#import "GPUImage.h"
#import "GPUImageBeautifyFilter.h"
#import <objc/runtime.h>
@interface OpenCVBaseVC ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate,GPUImageVideoCameraDelegate>

//当前视频会话
@property (nonatomic, strong) AVCaptureSession *session;
//摄像头前面输入
@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraInput;
//摄像头前面输入
@property (nonatomic, strong) AVCaptureDeviceInput *backCameraInput;
//** metadata */
@property(nonatomic, strong) NSMutableArray *currentMetadata;

//是否是前置摄像头,默认是no
@property (nonatomic, assign) BOOL isDevicePositionFront;

//** dlib */
@property(nonatomic, strong) DlibWrapper *wrapper;

//** layer */
@property(nonatomic, strong) AVSampleBufferDisplayLayer *layer;

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;
//** 滤镜 */
@property(nonatomic, strong) GPUImageBeautifyFilter *beautifyFilter;

//**嘴唇 topLayer */
@property(nonatomic, strong) CAShapeLayer *topLayer;

//**嘴唇 bottomLayer */
@property(nonatomic, strong) CAShapeLayer *bottomLayer;
//** 嘴唇颜色 */
@property(nonatomic, strong) UIColor *lipColor;
//**颜色选择 View */
@property (weak, nonatomic) IBOutlet UIView *colorView;

@property (weak, nonatomic) IBOutlet UIButton *purpleButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIButton *yellowButton;


@end

@implementation OpenCVBaseVC
- (IBAction)purpleButtonClick:(id)sender {
    [self p_setLipColor:[UIColor purpleColor]];
}
- (IBAction)redButtonClick:(id)sender {
    [self p_setLipColor:[UIColor redColor]];
}
- (IBAction)yellowClick:(id)sender {
    [self p_setLipColor:[UIColor yellowColor]];
}



- (instancetype)initWithType:(NSInteger )type{
    if (self = [super init]) {
        if (type == 1) {
            [self gpuImageVideo];
        }else{
            [self dlibVideo];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.wrapper = [[DlibWrapper alloc] init];
    self.currentMetadata = [NSMutableArray array];
    [self dlibVideo];
    [self.view bringSubviewToFront:self.colorView];
    
}
- (void)setTpye:(NSInteger)type{
    _type = type;
    if (type == 1) {
        [self gpuImageVideo];
    }else{
        [self dlibVideo];
    }
}
- (void)p_setLipColor:(UIColor *)lipColor{
    _bottomLayer.fillColor = lipColor.CGColor;//填充色
    _bottomLayer.strokeColor = lipColor.CGColor;
    _topLayer.fillColor = lipColor.CGColor;//填充色
    _topLayer.strokeColor = lipColor.CGColor;
}


- (void)gpuImageVideo{
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    self.filterView.center = self.view.center;
    
    [self.view addSubview:self.filterView];
    [self.videoCamera addTarget:self.filterView];
    [self.videoCamera startCameraCapture];
    
    [self.videoCamera removeAllTargets];
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    [self.videoCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:self.filterView];
    self.beautifyFilter = beautifyFilter;
    [self metaOutputMethod];
//    [self outputMethod];
    [self.wrapper prepare];



}
- (void)dlibVideo{
    self.layer = [[AVSampleBufferDisplayLayer alloc] init];
    self.layer.frame = self.view.frame;
    [self.view.layer addSublayer:self.layer];
    
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    self.filterView.center = self.view.center;
    [self.view addSubview:self.filterView];
    
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    self.beautifyFilter = beautifyFilter;
    
    
   // 设置视频格式
    [self initVideoSet];
}

- (void)metaOutputMethod{
    
    AVCaptureMetadataOutput *metaOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metaOutputQueue = dispatch_queue_create("metaOutput", DISPATCH_QUEUE_SERIAL);
    [metaOutput setMetadataObjectsDelegate:self queue:metaOutputQueue];
    if ([self.videoCamera.captureSession canAddOutput:metaOutput]) {
        [self.videoCamera.captureSession addOutput:metaOutput];
    }
    metaOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
}
- (void)outputMethod{
    //设置输出的代理
    AVCaptureVideoDataOutput *output = (AVCaptureVideoDataOutput *)[self.videoCamera valueForKey:@"videoOutput"];
    dispatch_queue_t videoQueue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
    [output setSampleBufferDelegate:self queue:videoQueue];
    if ([self.videoCamera.captureSession canAddOutput:output]) {
        [self.videoCamera.captureSession addOutput:output];
    }
}

#pragma mark - 视频初始化设置
-(void)initVideoSet{
    //创建一个Session会话，控制输入输出流
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    //设置视频质量
//    session.sessionPreset = AVCaptureSessionPresetMedium;
    self.session = session;
    
    //选择输入设备,默认是后置摄像头
    AVCaptureDeviceInput *input = self.frontCameraInput;
    //设置视频输出流
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc]init];
    //设置输出的代理
    dispatch_queue_t videoQueue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
    [output setSampleBufferDelegate:self queue:videoQueue];
    
    
    AVCaptureMetadataOutput *metaOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metaOutputQueue = dispatch_queue_create("metaOutput", DISPATCH_QUEUE_SERIAL);
    [metaOutput setMetadataObjectsDelegate:self queue:metaOutputQueue];
    
    //将输入输出添加到会话，连接
    if ([session canAddInput:input]) {
        [session addInput:input];
    }
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
    if ([session canAddOutput:metaOutput]) {
        [session addOutput:metaOutput];
    }
    [session commitConfiguration];
    
    
    //设置输出格式
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],                                   kCVPixelBufferPixelFormatTypeKey,nil];
    output.videoSettings = settings;
    
    metaOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
    [self.wrapper prepare];
    
    //启动session
    [session startRunning];
    
    
}
#pragma mark - 获取视频帧，处理视频
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    //确定人脸方向
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    connection.videoMirrored = YES;
    NSMutableArray *boundsArray = [NSMutableArray array];
    for (AVMetadataObject *faceObject in self.currentMetadata) {
        AVMetadataObject *convertedObject = [output transformedMetadataObjectForMetadataObject:faceObject connection:connection];
        NSValue *value = [NSValue valueWithCGRect:convertedObject.bounds];
        [boundsArray addObject:value];
    }
    //CMSampleBufferRef上面描人脸特征点
    [self.wrapper doWorkOnSampleBuffer:sampleBuffer inRects:boundsArray atCurrentView:self.view drawTopLayer:self.topLayer drawBottomLayer:self.bottomLayer];
    // 转换UIImage
    UIImage *image = [self.wrapper convertSampleBufferToImage:sampleBuffer];
    if (image.size.width > 0 && image.size.height > 0) {
        // 创建图片源
        GPUImagePicture *picture = [[GPUImagePicture alloc]initWithImage:image];
        [picture addTarget:self.beautifyFilter];
        [self.beautifyFilter addTarget:self.filterView];

        dispatch_sync(dispatch_get_main_queue(), ^{
            [picture processImage];
        });
    }
}


- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    self.currentMetadata = [NSMutableArray arrayWithArray:metadataObjects];
}

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    AVCaptureVideoDataOutput *output = (AVCaptureVideoDataOutput *)[self.videoCamera valueForKey:@"videoOutput"];
    AVCaptureConnection *connection =  [self.videoCamera videoCaptureConnection];
    NSMutableArray *boundsArray = [NSMutableArray array];
    for (AVMetadataObject *faceObject in self.currentMetadata) {
        AVMetadataObject *convertedObject = [output
 transformedMetadataObjectForMetadataObject:faceObject connection:connection];
        NSValue *value = [NSValue valueWithCGRect:convertedObject.bounds];
        [boundsArray addObject:value];
    }
//    if (boundsArray.count > 0) {
//        [self.wrapper doWorkOnSampleBuffer:sampleBuffer inRects:boundsArray];
//    }
}



#pragma mark - 摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput {
    if (_frontCameraInput == nil) {
        NSError *error;
//        AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        AVCaptureDevice *device = self.videoCamera.inputCamera;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
        if (error) {
            NSLog(@"前置摄像头获取失败");
        }
    }
    self.isDevicePositionFront = YES;
    return _frontCameraInput;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ){
            return device;
        }
    return nil;
}
- (GPUImageVideoCamera *)videoCamera{
    if (!_videoCamera) {
        self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
        self.videoCamera.delegate = self;
        self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    }
    return _videoCamera;
}

-(CAShapeLayer *)topLayer{
    if (!_topLayer) {
        _topLayer = [CAShapeLayer layer];
        _topLayer.fillColor=[UIColor clearColor].CGColor;//填充色
        _topLayer.strokeColor=[UIColor clearColor].CGColor;
        [self.view.layer addSublayer:_topLayer];
    }
    return _topLayer;
}
- (CAShapeLayer *)bottomLayer{
    if (!_bottomLayer) {
        _bottomLayer = [CAShapeLayer layer];
        _bottomLayer.fillColor=[UIColor clearColor].CGColor;//填充色
        _bottomLayer.strokeColor=[UIColor clearColor].CGColor;
        [self.view.layer addSublayer:_bottomLayer];
    }
    return _bottomLayer;
}


@end
