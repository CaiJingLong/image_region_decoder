#import "ImageRegionDecoderPlugin.h"

@implementation ImageRegionDecoderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    ImageRegionDecoderPlugin *plugin = [ImageRegionDecoderPlugin new];
    
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"image_region_decoder" binaryMessenger:registrar.messenger];
    [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        [plugin handleMethodCall:call result:result];
    }];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result{
    if([call.method isEqualToString:@"imageRect"]) {
        dispatch_queue_global_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSData *data = [call.arguments[@"image"] data];
            NSDictionary *rectDict = call.arguments[@"rect"];
            CGRect rect = [self convertToRect:rectDict];
            UIImage *image = [self getImage:data rect:rect];
            NSData *imageResult = UIImageJPEGRepresentation(image, 1);
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                result(imageResult);
            });
        });
    }else{
        result(FlutterMethodNotImplemented);
    }
}

-(CGRect) convertToRect:(NSDictionary*)dict{
    CGFloat left = [dict[@"l"] floatValue];
    CGFloat top = [dict[@"t"] floatValue];;
    CGFloat width = [dict[@"w"] floatValue];
    CGFloat height = [dict[@"h"] floatValue];
    
    return CGRectMake(left, top, width, height);
}

-(UIImage*) getImage:(NSData*)data rect:(CGRect)rect{
    UIImage *image = [UIImage imageWithData:data];
    
    CGImageRef cgImage = image.CGImage;
    
    CGImageRef partImage = CGImageCreateWithImageInRect(cgImage, rect);
    
    return [UIImage imageWithCGImage:partImage];
}

@end
