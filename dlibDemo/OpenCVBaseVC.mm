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

//** img */
@property(nonatomic, strong) UIImageView *imagev;



@end

@implementation OpenCVBaseVC

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
}
- (void)setTpye:(NSInteger)type{
    _type = type;
    if (type == 1) {
        [self gpuImageVideo];
    }else{
        [self dlibVideo];
    }
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
    [self outputMethod];
    [self.wrapper prepare];

}
- (void)dlibVideo{
    self.layer = [[AVSampleBufferDisplayLayer alloc] init];
    self.layer.frame = self.view.frame;
    [self.view.layer addSublayer:self.layer];
    
    
//
//    self.imagev=[[UIImageView alloc] init];
//    self.imagev.frame=CGRectMake(0, 300, 300, 200);
//    self.imagev.backgroundColor=[UIColor orangeColor];
    
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
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc]init];
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
    
    
    
    
////    //创建预览图层
//    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
//    //设置layer大小
//    CGFloat layerW = self.view.bounds.size.width - 40;
//    previewLayer.frame = CGRectMake(20, 70, layerW, layerW);
//    //视频大小根据frame大小自动调整
//    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    [self.view.layer addSublayer:previewLayer];
//    self.previewLayer = previewLayer;
    
    
    
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
        NSLog(@"value:%@",value);
        [boundsArray addObject:value];
    }
//    CMSampleBufferRef上面描人脸特征点
    [self.wrapper doWorkOnSampleBuffer:sampleBuffer inRects:boundsArray];
  
    
    // 通过sampleBuffer得到图片
//    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
//    NSData *mData = UIImageJPEGRepresentation(image, 0.5);
//    //这里的mData是NSData对象，后面的0.5代表生成的图片质量
//    //在主线程中执行才会把图片显示出来
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.imagev setImage:[UIImage imageWithData:mData]];
//    });
//    [self.view addSubview:self.imagev];
//    NSLog(@"output,mdata:%@",image);
    
    
    //CMSampleBufferRef 美颜
    [self.layer enqueueSampleBuffer:sampleBuffer];


}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    self.currentMetadata = [NSMutableArray arrayWithArray:metadataObjects];
}

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    AVCaptureOutput *output = (AVCaptureOutput *)[self.videoCamera valueForKey:@"videoOutput"];
    AVCaptureConnection *connection = self.videoCamera.videoCaptureConnection;
    NSMutableArray *boundsArray = [NSMutableArray array];
    for (AVMetadataObject *faceObject in self.currentMetadata) {
        AVMetadataObject *convertedObject = [output
 transformedMetadataObjectForMetadataObject:faceObject connection:connection];
        NSValue *value = [NSValue valueWithCGRect:convertedObject.bounds];
        [boundsArray addObject:value];
    }
    
    
    if (boundsArray.count > 0) {
        [self.wrapper doWorkOnSampleBuffer:sampleBuffer inRects:boundsArray];
    }
}

// 把buffer流生成图片
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
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
@end
