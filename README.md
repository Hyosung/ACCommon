ACViews
------
ACViews中是一些常用的UIView的子类，其中有（**ACTableViewCell**,**ACTextView**,**ACLargerImageView**）

### ACTableViewCell中添加如下新属性
    @property (nonatomic) BOOL showingSeparator;//是否显示分隔线，默认YES
    @property (nonatomic) ACSeparatorSpaces separatorSpace;//分隔线的左右两边的间距，默认左边15.0px,右边0.0px
    @property (nonatomic, strong) UIColor *separatorColor;//分隔线的颜色，默认gray的0.7

### ACTextView中添加如下新属性
    @property (nonatomic, strong) NSString *placeholder;//占位字符串
    @property (nonatomic, strong) UIColor *placeholderTextColor;//占位字符串颜色，默认gray的0.7
    
### ACLargerImageView用于显示大图，可做操作有捏图片缩放、双击图片缩放、长按保存相册
    @property (nonatomic) NSInteger currentSelectIndex;//当前选中的下标
    
    + (instancetype)largeImageViewWithImageURLStrings:(NSArray *) URLStrings;
    - (void)showWithView:(UIView *) view;//显示在指定view上
    - (void)show;//显示在window上
    - (void)hide;//隐藏
    
ACControls
------
ACControls中是一些常用的UIControls的子类，其中有（**ACTextField**）
### ACTextField中添加如下新属性
    @property (nonatomic, strong) UIColor *placeholderTextColor;//占位字符串颜色

ACAdditions常用类别
------
> 时间有限就暂不多介绍了

ACExternals常用第三方框架、第三方类
------
> 时间有限就暂不多介绍了

ACMacros.h常用宏定义
------
> 时间有限就暂不多介绍了

ACUtilitys.h常用方法的整理类
------
> 时间有限就暂不多介绍了

后面有时间再一一介绍，今天就这样了，睡了
======
