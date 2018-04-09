#import "DlibWrapper.h"
#import <UIKit/UIKit.h>

#include <dlib/image_processing.h>
#include <dlib/image_io.h>
#include <dlib/image_transforms/draw.h>
#include <MacTypes.h>

#define kYAddAxleNumber 10
#define kXAddAxleNumber 30


@interface DlibWrapper ()

@property (assign) BOOL prepared;
+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects;
@end
@implementation DlibWrapper {
    /**
     This object is a tool that takes in an image region containing some object and outputs a set of point locations that define the pose of the object. The classic example of this is human face pose prediction, where you take an image of a human face as input and are expected to identify the locations of important facial landmarks such as the corners of the mouth and eyes, tip of the nose, and so forth.
     */
    dlib::shape_predictor sp;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _prepared = NO;
    }
    return self;
}

// 预处理，加载face landmarking model
- (void)prepare {
    
    NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
//    NSString *modelFileFace = [[NSBundle mainBundle] pathForResource:@"face_track" ofType:@"dat"];
    std::string modelFileNameCString = [modelFileName UTF8String];

    
    // 内部应该是重载了>>运算符
    dlib::deserialize(modelFileNameCString) >> sp;
    
    // FIXME: test this stuff for memory leaks (cpp object destruction)
    self.prepared = YES;
}

- (void)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects atCurrentView:(UIView *)currentView drawTopLayer:(CAShapeLayer *)topLayer drawBottomLayer:(CAShapeLayer *)bottomLayer {
    
    if (!self.prepared) {
        [self prepare];
    }
    
    // <>使用函数模板，类似于泛型。类比Stack<int>和Stack<string>
    dlib::array2d<dlib::bgr_pixel> img;
    
    // MARK: magic
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
    //添加这个判断 防止后续过渡释放crash
    if(strlen(baseBuffer) == 0) return;
    // set_size expects rows, cols format
    img.set_size(height, width);
    
    // copy samplebuffer image data into dlib image format
    img.reset();
    long position = 0;
    while (img.move_next()) {
        dlib::bgr_pixel& pixel = img.element();

        // assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        char b = baseBuffer[bufferLocation];
        char g = baseBuffer[bufferLocation + 1];
        char r = baseBuffer[bufferLocation + 2];
        //        we do not need this
        //        char a = baseBuffer[bufferLocation + 3];
        
        dlib::bgr_pixel newpixel(b, g, r);
        pixel = newpixel;
        
        position++;
    }
    
    // unlock buffer again until we need it again
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
    // convert the face bounds list to dlib format
    std::vector<dlib::rectangle> convertedRectangles = [DlibWrapper convertCGRectValueArray:rects];
    


    dlib::point p48;
    dlib::point p49;
    dlib::point p50;
    dlib::point p51;
    dlib::point p52;
    dlib::point p53;
    dlib::point p54;
    dlib::point p55;
    dlib::point p56;
    dlib::point p57;
    dlib::point p58;
    dlib::point p59;
    dlib::point p60;
    dlib::point p61;
    dlib::point p62;
    dlib::point p63;
    dlib::point p64;
    dlib::point p65;
    dlib::point p66;
    dlib::point p67;
    // for every detected face
    // convertedRectangles包含检测到人脸的个数
    for (unsigned long j = 0; j < convertedRectangles.size(); ++j)
    {
        dlib::rectangle oneFaceRect = convertedRectangles[j];
        
        // detect all landmarks
        // 初始化人脸检测
        dlib::full_object_detection shape = sp(img, oneFaceRect);
        
        // and draw them into the image (samplebuffer)
        // num_parts:检测到特征点的个数
        unsigned long nums =  shape.num_parts();
//        NSLog(@"nums:%ld",nums);   输出68个点
//        dlib::point p_front = shape.part(48);
//        dlib::point p_back = shape.part(48);
       
        //描绘嘴唇的点
        for (unsigned long k = 48; k < nums; k++) {
            // 依次获取特征点
//            p_back = p_front;
            dlib::point p = shape.part(k);
//            p_front = p;
            //画线
//            draw_line(img,p_back,p_front,dlib::rgb_pixel(0, 255, 0));
//            // 在img上画点，参数分别是imge、点坐标、点的半径、点的像素(颜色)
//            draw_solid_circle(img, p, 6, dlib::rgb_pixel(255, 255, 0));
//            printf("x:%ld,y:%ld,img:%ld\n",p.x(),p.y(),img.size());
            //记录区域点
            switch (k) {
                case 48:
                    p48 = p;
                    break;
                case 49:
                    p49 = p;
                    break;
                case 50:
                    p50 = p;
                    break;
                case 51:
                    p51 = p;
                    break;
                case 52:
                    p52 = p;
                    break;
                case 53:
                    p53 = p;
                    break;
                case 54:
                    p54 = p;
                    break;
                case 55:
                    p55 = p;
                    break;
                case 56:
                    p56 = p;
                    break;
                case 57:
                    p57 = p;
                    break;
                case 58:
                    p58 = p;
                    break;
                case 59:
                    p59 = p;
                    break;
                case 60:
                    p60 = p;
                    break;
                case 61:
                    p61 = p;
                    break;
                case 62:
                    p62 = p;
                    break;
                case 63:
                    p63 = p;
                    break;
                case 64:
                    p64 = p;
                    break;
                case 65:
                    p65 = p;
                    break;
                case 66:
                    p66 = p;
                    break;
                case 67:
                    p67 = p;
                    break;
                default:
                    break;
            }
            
            
        }
 
    

    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //生成path
        CGMutablePathRef topPath = CGPathCreateMutable();
        CGPoint orginPoint = CGPointMake((p48.x() + kXAddAxleNumber)/2 , (p48.y() + kYAddAxleNumber)/2);
        CGPathMoveToPoint(topPath, NULL, orginPoint.x, orginPoint.y);
        [self addLineToPoint:p49 atPath:topPath];
        [self addLineToPoint:p50 atPath:topPath];
        [self addLineToPoint:p51 atPath:topPath];
        [self addLineToPoint:p52 atPath:topPath];
        [self addLineToPoint:p53 atPath:topPath];
        [self addLineToPoint:p54 atPath:topPath];
        [self addLineToPoint:p64 atPath:topPath];
        [self addLineToPoint:p63 atPath:topPath];
        [self addLineToPoint:p62 atPath:topPath];
        [self addLineToPoint:p61 atPath:topPath];
        [self addLineToPoint:p60 atPath:topPath];
        [self addLineToPoint:p48 atPath:topPath];

        topLayer.path = topPath;
        [currentView.layer addSublayer:topLayer];
        
        
        //生成path
        CGMutablePathRef bottomPath = CGPathCreateMutable();
        CGPoint bottomOrginPoint = CGPointMake(p48.x()/2 + kXAddAxleNumber, (p48.y() + kYAddAxleNumber)/2);
        CGPathMoveToPoint(bottomPath, NULL, bottomOrginPoint.x, bottomOrginPoint.y);
//        [self addLineToPoint:p60 satPath:bottomPath];
        [self addLineToPoint:p67 atPath:bottomPath];
        [self addLineToPoint:p66 atPath:bottomPath];
        [self addLineToPoint:p65 atPath:bottomPath];
        [self addLineToPoint:p64 atPath:bottomPath];
        [self addLineToPoint:p54 atPath:bottomPath];
        [self addLineToPoint:p55 atPath:bottomPath];
        [self addLineToPoint:p56 atPath:bottomPath];
        [self addLineToPoint:p57 atPath:bottomPath];
        [self addLineToPoint:p58 atPath:bottomPath];
        [self addLineToPoint:p59 atPath:bottomPath];
        [self addLineToPoint:p48 atPath:bottomPath];
        
        bottomLayer.path = bottomPath;
        [currentView.layer addSublayer:bottomLayer];
        
        
        
    });
    
//    NSLog(@"topView.frame:%@",NSStringFromCGRect(topView.frame));
    // lets put everything back where it belongs
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // copy dlib image data back into samplebuffer
    img.reset();
    position = 0;
    while (img.move_next()) {
        dlib::bgr_pixel& pixel = img.element();
        
        // assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        baseBuffer[bufferLocation] = pixel.blue;
        baseBuffer[bufferLocation + 1] = pixel.green;
        baseBuffer[bufferLocation + 2] = pixel.red;
        //        we do not need this
        //        char a = baseBuffer[bufferLocation + 3];
        
        position++;
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}
- (void)addLineToPoint:(dlib::point )toPoint atPath:(CGMutablePathRef )path{
    CGPathAddLineToPoint(path, NULL, (toPoint.x() + kXAddAxleNumber )/2, (toPoint.y() + kYAddAxleNumber)/2);
}

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects {
    // vector是一个有序列化得容器，完全看成数组
    std::vector<dlib::rectangle> myConvertedRects;
    for (NSValue *rectValue in rects) {
        CGRect rect = [rectValue CGRectValue];
        long left = rect.origin.x - 10;
        long top = rect.origin.y - 10;
        long right = left + rect.size.width + 10;
        long bottom = top + rect.size.height + 10;
        dlib::rectangle dlibRect(left, top, right, bottom);

        // 追加元素
        myConvertedRects.push_back(dlibRect);
    }
    return myConvertedRects;
}
//sampleBuffer 转 UIImage
-(UIImage *)convertSampleBufferToImage:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef buffer;
    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    uint8_t *base;
    size_t width, height, bytesPerRow;
    base = (uint8_t *)CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    CGColorSpaceRef colorSpace;
    CGContextRef cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef cgImage;
    UIImage *image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    return image;
}
////记录区域点
//switch (k) {
//    case 48:
//        p48 = p;
//        break;
//    case 49:
//        p49 = p;
//        break;
//    case 50:
//        p50 = p;
//        break;
//    case 51:
//        p51 = p;
//        break;
//    case 52:
//        p52 = p;
//        break;
//    case 53:
//        p53 = p;
//        break;
//    case 54:
//        p54 = p;
//        break;
//    case 55:
//        p55 = p;
//        break;
//    case 56:
//        p56 = p;
//        break;
//    case 57:
//        p57 = p;
//        break;
//    case 58:
//        p58 = p;
//        break;
//    case 59:
//        p59 = p;
//        break;
//    case 60:
//        p60 = p;
//        break;
//    case 61:
//        p61 = p;
//        break;
//    case 62:
//        p62 = p;
//        break;
//    case 63:
//        p63 = p;
//        break;
//    case 64:
//        p64 = p;
//        break;
//    case 65:
//        p65 = p;
//        break;
//    case 66:
//        p66 = p;
//        break;
//    default:
//        break;
//}
/*
 dispatch_async(dispatch_get_main_queue(), ^{
 
 //        topView.frame = CGRectMake(p48.x()/2, p51.y()/2, p64.x()/2-p48.x()/2, p62.y()/2-p51.y()/2);
 //        bottomView.frame = CGRectMake(p48.x()/2, p48.x()/2, p64.x()/2-p48.x()/2, p57.y()/2-p66.y()/2);
 //        [currentView addSubview:topView];
 //        [currentView addSubview:bottomView];
 //            //生成path
 //            CGMutablePathRef path = CGPathCreateMutable();
 //            CGPoint orginPoint = CGPointMake(p48.x(), p48.y());
 //            CGPathMoveToPoint(path, NULL, orginPoint.x, orginPoint.y);
 //            [self addLineToPoint:p49 atPath:path];
 //            [self addLineToPoint:p50 atPath:path];
 //            [self addLineToPoint:p51 atPath:path];
 //            [self addLineToPoint:p52 atPath:path];
 //            [self addLineToPoint:p53 atPath:path];
 //            [self addLineToPoint:p54 atPath:path];
 //            [self addLineToPoint:p64 atPath:path];
 //            [self addLineToPoint:p65 atPath:path];
 //            [self addLineToPoint:p62 atPath:path];
 //            [self addLineToPoint:p61 atPath:path];
 //            [self addLineToPoint:p60 atPath:path];
 //            [self addLineToPoint:p48 atPath:path];
 //
 //            CAShapeLayer *maskLayer= [CAShapeLayer layer];
 //            maskLayer.frame = CGRectMake(200, 200, 100, 100);
 //            maskLayer.path=path;
 //            maskLayer.fillColor=[UIColor blackColor].CGColor;//填充色
 //            maskLayer.strokeColor=[UIColor redColor].CGColor;
 //
 //            [currentView.layer addSublayer:maskLayer];
 
 
 });
 */

@end
