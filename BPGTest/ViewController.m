//
//  ViewController.m
//  BPGTest
//
//  Created by Alexander Skorulis on 9/02/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.
//

#import "ViewController.h"
#import <UIImage+WebP.h>

@interface ViewController () {
    UIImageView* _imageView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat quality = 0.9;
    
    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    UIImage* image1 = [UIImage imageNamed:@"image1.jpg"];
    UIImage* image2 = [UIImage imageNamed:@"image2.jpg"];
    UIImage* image3 = [UIImage imageNamed:@"image3.jpg"];
    
    NSArray* images = @[image1,image2,image3];
    NSMutableArray* jpegData = [[NSMutableArray alloc] init];
    NSInteger jpegTotalSize = 0;
    
    NSMutableArray* webPData = [[NSMutableArray alloc] init];
    NSInteger webPTotalSize = 0;
    
    NSTimeInterval jpegTime = CACurrentMediaTime();
    
    for(UIImage* i in images) {
        NSData* data = UIImageJPEGRepresentation(i, quality);
        jpegTotalSize += data.length;
        [jpegData addObject:data];
    }
    
    jpegTime = CACurrentMediaTime() - jpegTime;
    
    
    NSTimeInterval webpTime = CACurrentMediaTime();
    
    for(UIImage* i in images) {
        NSData* data = [UIImage imageToWebP:i quality:quality*100];
        webPTotalSize += data.length;
        [webPData addObject:data];
    }
    
    webpTime = CACurrentMediaTime() - webpTime;
    
    NSInteger saving = jpegTotalSize - webPTotalSize;
    CGFloat savingPct = (saving / (CGFloat)jpegTotalSize) * 100;
    
    NSLog(@"Jpeg size %ld",(long)jpegTotalSize);
    NSLog(@"WebP size %ld",(long)webPTotalSize);
    NSLog(@"Saved %ld bytes %f %%",(long)saving,savingPct);
    
    NSTimeInterval timeCost = webpTime - jpegTime;
    NSTimeInterval timeCostPct = (timeCost / jpegTime) * 100;
    
    NSLog(@"Jpeg encode time %f",jpegTime);
    NSLog(@"webp encode time %f",webpTime);
    NSLog(@"Time added %f %f %%",timeCost,timeCostPct);
    
    webpTime = CACurrentMediaTime();
    for(NSData* d in webPData) {
        UIImage* image = [UIImage imageWithWebPData:d];
        NSLog(@"Image size %@",NSStringFromCGSize(image.size));
    }
    webpTime = CACurrentMediaTime() - webpTime;
    
    jpegTime = CACurrentMediaTime();
    for(NSData* d in jpegData) {
        UIImage* image = [self forceJpegDecode:d];
        NSLog(@"Image size %@",NSStringFromCGSize(image.size));
    }
    jpegTime = CACurrentMediaTime() - jpegTime;
    
    NSLog(@"Jpeg decode time %f",jpegTime);
    NSLog(@"webp decode time %f",webpTime);
    
    timeCost = webpTime - jpegTime;
    timeCostPct = (timeCost / jpegTime) * 100;
    
    NSLog(@"Time added %f %f %%",timeCost,timeCostPct);
}

- (UIImage*) forceJpegDecode:(NSData*)data {
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRef newImage = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);

    const size_t width = CGImageGetWidth(newImage);
    const size_t height = CGImageGetHeight(newImage);
    
    const CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    const CGContextRef context = CGBitmapContextCreate(
                                                       NULL, /* Where to store the data. NULL = don’t care */
                                                       width, height, /* width & height */
                                                       8, width * 4, /* bits per component, bytes per row */
                                                       colorspace, kCGImageAlphaNoneSkipFirst);
    
    NSParameterAssert(context);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), newImage);
    CGImageRef drawnImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorspace);
    
    UIImage* image = [UIImage imageWithCGImage:drawnImage];
    
    CGDataProviderRelease(dataProvider);
    CGImageRelease(newImage);
    CGImageRelease(drawnImage);
    return image;
}

@end
