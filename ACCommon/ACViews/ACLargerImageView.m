//
//  ACLargerImageView.m
//  ACCommon
//
//  Created by i云 on 14-6-23.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import "ACLargerImageView.h"

@interface ACLargerImageView () <UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) NSArray *URLStrings;

@end

@implementation ACLargerImageView

+ (instancetype)largeImageViewWithImageURLStrings:(NSArray *)URLStrings {
    __autoreleasing ACLargerImageView *slImageView = [[ACLargerImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT) andURLStrings:URLStrings];
    return slImageView;
}

- (id)initWithFrame:(CGRect)frame andURLStrings:(NSArray *) URLStrings {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.URLStrings = URLStrings;
        [self setupView];
        [self setupGesture];
        [self loadURLStrings];
    }
    return self;
}

- (void)tapEvent:(UITapGestureRecognizer *) gesture {
    [self hide];
}

- (void)doubleEvent:(UITapGestureRecognizer *) gesture {
    UIScrollView *scrollView = (UIScrollView *)[self.contentView viewWithTag:500 + _currentSelectIndex];
    
    if (scrollView) {
        UIImageView *imageView = [scrollView.subviews firstObject];
        if (imageView) {
            
            CGPoint point = [gesture locationInView:imageView];
            
            CGRect rect = CGRectMake((SCREEN_WIDTH - imageView.image.size.width) / 2.0,
                                     (SCREEN_HEIGHT - imageView.image.size.height) / 2.0,
                                     imageView.image.size.width,
                                     imageView.image.size.height);
            
            if (CGRectContainsPoint(rect, point)) {
                
                CGFloat scale = scrollView.minimumZoomScale;
                if (scrollView.zoomScale < scrollView.maximumZoomScale) {
                    scale = scrollView.maximumZoomScale;
                }
                
                CGRect zoomRect = [self zoomRectForScale:scale withCenter:point andZoomView:imageView];
                [scrollView zoomToRect:zoomRect animated:YES];
            }
        }
    }
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center andZoomView:(UIView *) view {
    CGRect zoomRect;
    zoomRect.size.height = view.frame.size.height / scale;
    zoomRect.size.width  = view.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (void)longEvent:(UITapGestureRecognizer *) gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        UIActionSheet *actionView = [[UIActionSheet alloc] initWithTitle:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"保存到相册", nil];
        [actionView showInView:self];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!buttonIndex) {
        UIImageView *imageView = [[self.contentView viewWithTag:500 + _currentSelectIndex].subviews firstObject];
        if (imageView.image) {
            [imageView.image savePhotosAlbum];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"图片正在加载中"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void)setupGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [self addGestureRecognizer:tapGesture];
    self.tapGesture = tapGesture;
    
    UITapGestureRecognizer *doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleEvent:)];
    doubleGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleGesture];
    self.doubleGesture = doubleGesture;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longEvent:)];
    [self addGestureRecognizer:longPressGesture];
    self.longPressGesture = longPressGesture;
    
    [tapGesture requireGestureRecognizerToFail:doubleGesture];
}

- (void)setupView {
    UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
    contentView.delegate = self;
    contentView.bouncesZoom = NO;
    contentView.pagingEnabled = YES;
    contentView.showsVerticalScrollIndicator = NO;
    contentView.showsHorizontalScrollIndicator = NO;
    [self addSubview:contentView];
    self.contentView = contentView;
}

- (void)loadURLStrings {
    if (self.URLStrings && [self.URLStrings count]) {
        for (NSInteger i = 0; i < [self.URLStrings count]; i++) {
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.width * i, 0.0, self.width, self.height)];
            scrollView.tag = 500 + i;
            scrollView.bounces = NO;
            scrollView.delegate = self;
            scrollView.minimumZoomScale = 1.0;
            scrollView.maximumZoomScale = 3.0;
            scrollView.multipleTouchEnabled = YES;
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.showsHorizontalScrollIndicator = NO;
            
            UIImageView *contentItemView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
            contentItemView.contentMode = UIViewContentModeCenter;
            contentItemView.tag = 400;
            
            __weak UIImageView *weakRef = contentItemView;
            [contentItemView setImageWithURL:[NSURL URLWithString:self.URLStrings[i]]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
             {
                 if (!error && image) {
                     
                     UIImage *newImage = [ACUtilitys resizedFixedImageWithImage:image size:weakRef.frame.size];
                     weakRef.image = newImage;
                 }
             }];
            
            [scrollView addSubview:contentItemView];
            
            [self.contentView addSubview:scrollView];
        }
        
        self.contentView.contentSize = CGSizeMake(self.width * [self.URLStrings count], 0.0);
        [self selectContentItem];
    }
}

- (void)revertPreviousView {
    UIScrollView *scrollView = (UIScrollView *)[self.contentView viewWithTag:500 + _currentSelectIndex];
    if (scrollView) {
        scrollView.zoomScale = 1.0;
    }
}

- (void)setCurrentSelectIndex:(NSInteger)currentSelectIndex {
    if (_currentSelectIndex != currentSelectIndex) {
        _currentSelectIndex = currentSelectIndex;
        [self selectContentItem];
    }
}

- (void)selectContentItem {
    [self.contentView setContentOffset:CGPointMake(self.width * self.currentSelectIndex, 0.0) animated:YES];
}

- (void)showWithView:(UIView *)view {
    self.alpha = 0.0;
    [view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    }completion:^(BOOL finished) {
        [APP_SHARE setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}

- (void)show {
    [self showWithView:[ACUtilitys currentRootViewController].view.window];
}

- (void)hide {
    [APP_SHARE setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self revertPreviousView];
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.contentView) {
        NSInteger tempIndex = scrollView.contentOffset.x / self.width;
        
        if (tempIndex != _currentSelectIndex) {
            [self revertPreviousView];
            _currentSelectIndex = tempIndex;
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIView *currentView = [scrollView viewWithTag:400];
    return currentView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    UIView *currentView = [scrollView viewWithTag:400];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0.0;
    
    currentView.center = CGPointMake(scrollView.contentSize.width / 2 + offsetX, scrollView.contentSize.height / 2 + offsetY);
}


@end
