//
//  ACLargerImageView.m
//  ACCommon
//
//  Created by i云 on 14-6-23.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "ACLargerImageView.h"

static NSString *kLargerImageViewReuseIdentifier = @"kLargerImageViewReuseIdentifier";

@interface ACLargerCell : UICollectionViewCell <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *cellScrollView;
@property (nonatomic, strong) UIImageView *cellImageView;

@end

@implementation ACLargerCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.cellScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        self.cellScrollView.bounces = NO;
        self.cellScrollView.delegate = self;
        self.cellScrollView.minimumZoomScale = 1.0;
        self.cellScrollView.maximumZoomScale = 3.0;
        self.cellScrollView.multipleTouchEnabled = YES;
        self.cellScrollView.showsVerticalScrollIndicator = NO;
        self.cellScrollView.showsHorizontalScrollIndicator = NO;
        
        self.cellImageView = [[UIImageView alloc] initWithFrame:self.cellScrollView.bounds];
        self.cellImageView.contentMode = UIViewContentModeCenter;
        
        [self.cellScrollView addSubview:self.cellImageView];
        [self.contentView addSubview:self.cellScrollView];
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.cellImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    UIView *currentView = self.cellImageView;
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0.0;
    
    currentView.center = CGPointMake(scrollView.contentSize.width / 2 + offsetX, scrollView.contentSize.height / 2 + offsetY);
}

@end

@interface ACLargerImageView () <UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic, strong) UICollectionView *contentView;
@property (nonatomic, strong) NSArray *imgURLs;

@end

@implementation ACLargerImageView

+ (instancetype)largeImageViewWithImageURLs:(NSArray *)imgURLs {
    __autoreleasing ACLargerImageView *slImageView = [[ACLargerImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)) andURLStrings:imgURLs];
    return slImageView;
}

- (id)initWithFrame:(CGRect)frame andURLStrings:(NSArray *) URLStrings {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.imgURLs = URLStrings;
        
        [self setupView];
        [self setupGesture];
        [self selectContentItem];
    }
    return self;
}

- (void)tapEvent:(UITapGestureRecognizer *) gesture {
    [self hide];
}

- (void)doubleEvent:(UITapGestureRecognizer *) gesture {
    
    ACLargerCell *cell = (ACLargerCell *)[self.contentView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentSelectIndex inSection:0]];
    
    CGPoint point = [gesture locationInView:cell.cellImageView];
    
    CGRect rect = CGRectMake(
                             (CGRectGetWidth([UIScreen mainScreen].bounds) - cell.cellImageView.image.size.width) / 2.0,
                             (CGRectGetHeight([UIScreen mainScreen].bounds) - cell.cellImageView.image.size.height) / 2.0,
                             cell.cellImageView.image.size.width,
                             cell.cellImageView.image.size.height
                             );
    
    if (CGRectContainsPoint(rect, point)) {
        
        CGFloat scale = cell.cellScrollView.minimumZoomScale;
        if (cell.cellScrollView.zoomScale < cell.cellScrollView.maximumZoomScale) {
            scale = cell.cellScrollView.maximumZoomScale;
        }
        
        CGRect zoomRect = [self zoomRectForScale:scale withCenter:point andZoomView:cell.cellImageView];
        [cell.cellScrollView zoomToRect:zoomRect animated:YES];
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
        ACLargerCell *cell = (ACLargerCell *)[self.contentView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentSelectIndex inSection:0]];
        UIImageView *imageView = cell.cellImageView;
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
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = self.bounds.size;
    flowLayout.minimumInteritemSpacing = 0.0;
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *contentView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    contentView.delegate = self;
    contentView.dataSource = self;
    contentView.bouncesZoom = NO;
    contentView.pagingEnabled = YES;
    contentView.showsVerticalScrollIndicator = NO;
    contentView.showsHorizontalScrollIndicator = NO;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    [self.contentView registerClass:[ACLargerCell class] forCellWithReuseIdentifier:kLargerImageViewReuseIdentifier];
}

- (void)revertPreviousView {
    ACLargerCell *cell = (ACLargerCell *)[self.contentView dequeueReusableCellWithReuseIdentifier:kLargerImageViewReuseIdentifier forIndexPath:[NSIndexPath indexPathForItem:_currentSelectIndex inSection:0]];
    UIScrollView *scrollView = cell.cellScrollView;
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
    [self.contentView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds) * self.currentSelectIndex, 0.0) animated:YES];
}

- (void)showWithView:(UIView *)view {
    self.alpha = 0.0;
    [view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    }completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}

- (void)show {
    [self showWithView:[ACUtilitys currentRootViewController].view.window];
}

- (void)hide {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self revertPreviousView];
    }];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ACLargerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLargerImageViewReuseIdentifier forIndexPath:indexPath];
    
    __weak UIImageView *weakRef = cell.cellImageView;
    [cell.cellImageView setImageWithURL:[NSURL URLWithString:self.imgURLs[indexPath.row]]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         if (!error && image) {
             
             UIImage *newImage = [ACUtilitys resizedFixedImageWithImage:image size:weakRef.frame.size];
             weakRef.image = newImage;
         }
     }];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imgURLs count];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
   
    if (scrollView == self.contentView) {
        NSInteger tempIndex = scrollView.contentOffset.x / CGRectGetWidth(self.bounds);
        if (tempIndex != _currentSelectIndex) {
            [self revertPreviousView];
            _currentSelectIndex = tempIndex;
        }
    }
}

@end
