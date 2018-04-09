
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>
@interface DlibWrapper : NSObject

- (instancetype)init;
- (void)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects atCurrentView:(UIView *)currentView drawTopLayer:(CAShapeLayer *)topLayer drawBottomLayer:(CAShapeLayer *)bottomLayer;
- (void)prepare;
- (UIImage *)convertSampleBufferToImage:(CMSampleBufferRef)sampleBuffer ;
@end
