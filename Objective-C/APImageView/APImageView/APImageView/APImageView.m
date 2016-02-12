//
//  APImageView.m
//  APImageView
//
//  Created by Amit Priyadarshi on 09/02/16.
//  Copyright © 2016 AFAI. All rights reserved.
//

#import "APImageView.h"



@interface APImageView() {
    UILabel* lblErrorMsg;
}
- (void)didTap:(UIButton*)sender;
@end


@implementation APImageView
@synthesize uniqueIdentifire;
@synthesize tapDelegate;
@synthesize imageType;
@synthesize imageUrlString;
@synthesize defaultImage;
@synthesize errorImage;
@synthesize resourceNotAvailableImage;
@synthesize activity;
@synthesize localFileName;
static NSMutableSet* allActiveRequsetUrl;
static NSMutableDictionary *allActiveRequestURLAndObjects;

+ (void)clearBuffer {
    NSString* docDirectory = [CACHE_DIR stringByAppendingPathComponent:BaseBufferFolder];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:docDirectory])
    {
        [fm removeItemAtPath:docDirectory error:nil];
    }
}
+ (void)clearBufferOfImageType:(NSString*)type {
    NSString* docDirectory = [CACHE_DIR stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",BaseBufferFolder,type]];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:docDirectory])
    {
        [fm removeItemAtPath:docDirectory error:nil];
    }
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (!allActiveRequsetUrl) {
                allActiveRequsetUrl = [[NSMutableSet alloc] init];
            }
            if(!allActiveRequestURLAndObjects)
            {
                allActiveRequestURLAndObjects =[[NSMutableDictionary alloc] init];
            }
        });
        [self setContentMode:UIViewContentModeScaleAspectFit];
        
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activity setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        [activity setHidesWhenStopped:YES];
        [self addSubview:activity];
        
        NSFileManager* fm = [NSFileManager defaultManager];
        NSString* thumbDocPath;
        thumbDocPath = [CACHE_DIR stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",BaseBufferFolder,NoTypeFolder]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:thumbDocPath])
        {
            NSError* err = nil;
            [fm createDirectoryAtPath:thumbDocPath withIntermediateDirectories:YES attributes:nil error:&err];
            if (err)
                NSLog(@"%s:%@",__FUNCTION__,err);
        }
        self.defaultImage = nil;
        lblErrorMsg.hidden = YES;
    }
    return self;
}
- (void)layoutSubviews {
    activity.center = self.center;
    [lblErrorMsg setFrame:self.bounds];
}
- (void)didTap:(UIButton*)sender {
    if (self.tapDelegate && [self.tapDelegate respondsToSelector:@selector(didTapOnImageView:)]) {
        [self.tapDelegate didTapOnImageView:self];
    }
}
- (void)addTapReceiver {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height)];
    [button setAutoresizingMask:63];
    [self addSubview:button];
    [button addTarget:self action:@selector(didTap:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)setImageType:(NSString *)imageTyp {
    imageType = imageTyp;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* thumbDocPath;
    thumbDocPath = [CACHE_DIR stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",BaseBufferFolder,imageTyp]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:thumbDocPath])
    {
        NSError* err = nil;
        [fm createDirectoryAtPath:thumbDocPath withIntermediateDirectories:YES attributes:nil error:&err];
        if (err)
            NSLog(@"%s:%@",__FUNCTION__,err);
    }
}
- (void)imageDownloadedFromUrl:(NSString*)urlStr {
    if ([self.imageUrlString isEqualToString:urlStr]) {
        [allActiveRequsetUrl removeObject:urlStr];
        NSFileManager* fm = [NSFileManager defaultManager];
        NSString* localPath = [self cunstructLocalFilePath];
        if ([fm fileExistsAtPath:localPath]) {
            NSData* data = [NSData dataWithContentsOfFile:localPath];
            UIImage* image = nil;
            if ([data length] > 1000) {
                image = [UIImage imageWithContentsOfFile:localPath];
                lblErrorMsg.hidden = YES;
            }
            else
            {
                image = self.defaultImage;
                lblErrorMsg.hidden = NO;
                NSError* err = nil;
                [fm removeItemAtPath:localPath error:&err];
                if (err)
                    NSLog(@"%s:%@",__FUNCTION__,err);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                for(APImageView *view in [allActiveRequestURLAndObjects objectForKey:urlStr])
                {
                    [view setImage:image];
                    [view.activity performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
                }
                [allActiveRequestURLAndObjects removeObjectForKey:urlStr];
                
            });
            [activity performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
            self.imageUrlString = @"";
        }
    }
}
- (void)setImageFromUrl:(NSURL*)imageUrl {
    [self setImage:nil];
    NSString* imageUrlStr = [imageUrl absoluteString];
    if (!imageUrlStr || [imageUrlStr length] < 5) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:self.defaultImage];
            lblErrorMsg.hidden = NO;
        });
        self.imageUrlString = @"";
        return;
    }
    lblErrorMsg.hidden = YES;
    self.imageUrlString = imageUrlStr;
    NSString* localPath = [self cunstructLocalFilePath];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:localPath]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:[UIImage imageWithContentsOfFile:localPath]];
        });
        [activity performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        self.imageUrlString = @"";
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            activity.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f);
        });
        [activity performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
        if (![allActiveRequsetUrl containsObject:imageUrlStr]) {
            [allActiveRequsetUrl addObject:imageUrlStr];
            [allActiveRequestURLAndObjects setObject:[NSMutableArray arrayWithObject:self] forKey:imageUrlStr];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                NSData* data = [NSData dataWithContentsOfURL:imageUrl];
                if ([data length] > 1000) {
                    NSFileManager* fm = [NSFileManager defaultManager];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath])
                    {
                        NSError* err = nil;
                        [fm removeItemAtPath:localPath error:&err];
                        if (err)
                            NSLog(@"%s:%@",__FUNCTION__,err);
                    }
                    [fm createFileAtPath:localPath contents:data attributes:nil];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self imageDownloadedFromUrl:imageUrlStr];
                    });
                    lblErrorMsg.hidden = YES;
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setImage:self.defaultImage];
                        lblErrorMsg.hidden = NO;
                        [activity stopAnimating];
                    });
                    self.imageUrlString = @"";
                    [allActiveRequsetUrl removeObject:imageUrlStr];
                }
            });
        }
        else {
            NSMutableArray *arr =   [allActiveRequestURLAndObjects objectForKey:imageUrlStr];
            if(![arr containsObject:self])
                [arr addObject:self];
            [allActiveRequestURLAndObjects setObject:arr forKey:imageUrlStr];
            
        }
    }
}
- (void)setImageFromUrlString:(NSString*)urlString {
    NSURL* url = [NSURL URLWithString:urlString];
    [self setImageFromUrl:url];
}
- (void)setImageFromUrlString:(NSString*)urlString localFileName:(NSString*)localName {
    self.localFileName = localName;
    [self setImageFromUrlString:urlString];
}
- (void)setImageFromUrlString:(NSString*)urlString localFileName:(NSString*)localName forceUpdate:(BOOL)force {
    self.localFileName = localName;
    if (force) {
        NSString* localPath = [self cunstructLocalFilePath];
        NSFileManager* fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:localPath]) {
            [fm removeItemAtPath:localPath error:nil];
        }
    }
    [self setImageFromUrlString:urlString localFileName:localName];
}
- (NSString*)cunstructLocalFilePath {
    if (self.localFileName.length > 1) {
        return [NSString stringWithFormat:@"%@/%@/%@/%@",CACHE_DIR,BaseBufferFolder,
                (([self.imageType length])?self.imageType:NoTypeFolder),
                self.localFileName];
    }
    
    NSArray* pathComponents = [self.imageUrlString pathComponents];
    NSString* finalPath = nil;
    if ([pathComponents count] > 2) {
        NSArray* lastTwoObjects = [pathComponents subarrayWithRange:NSMakeRange([pathComponents count]-2,2)];
        finalPath = [NSString stringWithFormat:@"%@_%@",lastTwoObjects[0],lastTwoObjects[1]];
    }
    
    NSString* localPath = [NSString stringWithFormat:@"%@/%@/%@/%@",CACHE_DIR,BaseBufferFolder,
                           (([self.imageType length])?self.imageType:NoTypeFolder),
                           finalPath];
    return localPath;
}
@end
