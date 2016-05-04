//
//  ViewController.m
//  Runtime
//
//  Created by yulm on 16/3/2.
//  Copyright © 2016年 fengbangshou. All rights reserved.
//

#import "ViewController.h"
#import "ClassMeta.h"
#import <objc/runtime.h>
#import "TapView.h"
#import "VaList.h"
#import "TestViewController.h"
#import "UIViewController+LoadingView.h"

@interface ViewController ()<UITextViewDelegate>
{
    NSString *a;
    NSString *b;
    UILabel *l;
    UITextView *tv;
    UIScrollView *sc;
    UITextField *tf;
}

@property (weak, nonatomic) IBOutlet UIView *navV;

@property (nonatomic, copy)NSString *aaa;
@property (nonatomic, assign) CGFloat t;
@end

@implementation ViewController

+(void)load {
    SEL log1 = @selector(log1);
    SEL log2 = @selector(log2);
    
    Method m1 = class_getInstanceMethod([self class], log1);
    Method m2 = class_getInstanceMethod([self class], log2);
    
    BOOL isAdd = class_addMethod(self, log1, method_getImplementation(m2), method_getTypeEncoding(m2));
    if (isAdd) {
        class_replaceMethod(self, log2, method_getImplementation(m1), method_getTypeEncoding(m1));
    } else {
        method_exchangeImplementations(m1, m2);
    }
//    method_setImplementation(m2, method_getImplementation(m1));
}

-(void)log1 {
    NSLog(@"1111");
    if (class_isMetaClass([NSObject superclass])) {
        NSLog(@"aa");
    } else {
        Class cls =  objc_getMetaClass(class_getName([NSObject class]));
        NSLog(@"nsobject's meta class is %s",class_getName(cls));
    }
    
    
    Ivar string = class_getInstanceVariable([ViewController class], "a");
    if (string != NULL) {
        NSLog(@"instance variable %s",ivar_getName(string));
    }
    
    unsigned int count = 0;
    
    objc_property_t *properties = class_copyPropertyList([ViewController class], &count);
    for (int i = 0; i < count; i ++) {
        objc_property_t property = properties[i];
        NSLog(@"property's name is %s", property_getName(property));
    }
    free(properties);
    
    Method *methods = class_copyMethodList([ViewController class], &count);
    for (int i = 0; i < count; i ++) {
        Method m = methods[i];
        NSLog(@"method's signature is %@\n%s", NSStringFromSelector(method_getName(m)),method_getName(m));
    }
    free(methods);
    
    
}

- (void)copyIvar {
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([ViewController class], &count);
    for (int i = 0; i < count; i ++) {
        Ivar ivar = ivars[i];
        NSLog(@"instance variable's name is %s at index %d", ivar_getName(ivar), i);
        const char *charType = ivar_getTypeEncoding(ivar);
        NSLog(@"charType:%s", charType);
        NSString *type = [NSString stringWithUTF8String:charType];
        NSLog(@"type:%@", type);
        
    }
    free(ivars);
}

- (void)addClass {
    //创建新类和元类
    Class cls = objc_allocateClassPair(ViewController.class, "SubMeta", 0);
    SEL selector = NSSelectorFromString(@"subLog");
    
    //获取self的实现
    Method m0 = class_getInstanceMethod([self class], @selector(log1));
    IMP imp = method_getImplementation(m0);
    
    //给新类添加实现
    class_addMethod(cls, selector, imp, "v@:");
    
    //将添加方法的实现替换成log3的方法实现
    class_replaceMethod(cls, selector, class_getMethodImplementation([self class], @selector(log3)), "v@:");
    
    //获取新类的实现
    IMP imp_sublog = class_getMethodImplementation(cls, selector);
//    Method m = class_getInstanceMethod(cls, selector);
//    method_setImplementation(m, imp);
    
    //注册新创建的类
    objc_registerClassPair(cls);
    
    id instance = [[cls alloc]init];
    void (*func1)(id, SEL) = (void *)[cls methodForSelector:selector];
    
    //创建函数指针指向方法实现
    void (*func)(id, SEL) = (void *)imp_sublog;
//    [instance performSelector:selector];
    func(cls, selector);
    [instance performSelector:@selector(log1)];
    
}

- (void)block {
    /*
     返回类型 ^(blockName)(参数) = ^返回类型（参数列表){//代码}
     */
    void (^myBlock)() = ^{
        NSLog(@"1");
    };
    
    TapView *tapV = [[TapView alloc] initWithFrame:CGRectMake(20, 20, 80, 80)];
    tapV.backgroundColor = [UIColor orangeColor];
    [tapV setTapActionWithBlock:myBlock];
    [self.view addSubview:tapV];
    
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(log3) object:@"log"];
    [thread start];
    
    [NSThread detachNewThreadSelector:@selector(log3) toTarget:self withObject:@"log3"];
    
}

-(void)log2 {
    NSLog(@"2222");
}

-(void)log3 {
    NSThread *thread = [NSThread currentThread];
    NSLog(@"current thread:%@ is mainTherad :%d", thread, [thread isMainThread] );
    NSLog(@"333");
    
    dispatch_queue_t queue = dispatch_queue_create("aaa", DISPATCH_QUEUE_SERIAL);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        NSLog(@"1");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"2");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"3");
    });
    dispatch_group_notify(group, queue, ^{
        NSLog(@"end");
    });
    
    
    
}

- (void)concurrent {
    //自定义并行队列
    dispatch_queue_t queue = dispatch_queue_create("bbb", DISPATCH_QUEUE_CONCURRENT);
    //分组
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        NSLog(@"1");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"2");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"5");
    });
    
    //组内所有任务都完成后发通知
    dispatch_group_notify(group, queue, ^{
        NSLog(@"end");
    });
    
    //之前的并发任务都完成了才执行下面的任务
    dispatch_barrier_async(queue, ^{
        NSLog(@"1,2,5 done");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"3");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"4");
    });
    
    //documents目录，用于存储不可再生数据文件，
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    //library目录，用于存储设置或者状态信息分library/caches和library/preferences
    NSArray *paths1 = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path1 = [paths1 objectAtIndex:0];
    
    //caches目录，存放使用缓存目录
    NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path2 = [paths2 objectAtIndex:0];
    
    //临时目录
    NSString *tmpDir = NSTemporaryDirectory();
    NSLog(@"document:%@\nlibrary:%@\ncaches:%@\ntmp:%@", path,path1,path2,tmpDir);
    
}

-(void)directM {
    Class meta = NSClassFromString(@"ClassMeta");
    SEL selector = NSSelectorFromString(@"ex_registerClassPair");
    void (*func)(id, SEL) = (void *)[meta methodForSelector:selector];
    IMP i = class_getMethodImplementation(meta, selector);
//    func(meta, selector);
    NSLog(@"end");
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [ClassMeta ex_registerClassPair];
//    [self log1];
//    [self log2];
//    [self directM];
//    [self addClass];
//    [self block];
//    [self concurrent];
    
//    SEL sel = sel_registerName("concurrent");
//    void (*func)(id, SEL) = (void *)[self methodForSelector:sel];
//    func(self, sel);
//    char * re = method_copyReturnType(class_getInstanceMethod(self.class, sel));
//    NSLog(@"re:%s", re);
//    const char *sname = sel_getName(sel);
//    NSLog(@"name:%s", sname);
//    free(re);
    
    const char * propertiesKey = "propertiesKey";
    id plist = objc_getAssociatedObject(self, propertiesKey);
    NSLog(@"arr:%@", plist);
//    [self testRecursiveLock];
    
//    [VaList arrWithObjs:@1, @2, @3, nil];
//    [[VaList new] testArr];
//    [self copyIvar];
//    [self conditionLock];
    
//    [self addBtn];
//    [self addTextViewAndLabel];
//    [self addScrollView];
//    [self addTextField];
//    [self addImageV];
    [self btnCenter:0];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - btn,img
- (IBAction)loading:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [self showLoadingView];
    } else {
        [self hideLoadingView];
    }
}

- (void)btnCenter:(CGFloat)spacing {
    CGSize imageSize = _centerBtn.imageView.frame.size;
    CGSize titleSize = _centerBtn.titleLabel.frame.size;
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    // raise the image and push it right to center it
    _centerBtn.imageEdgeInsets = UIEdgeInsetsMake(
                                            - (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    
    // lower the text and push it left to center it
    _centerBtn.titleEdgeInsets = UIEdgeInsetsMake(
                                            0.0, - imageSize.width, - (totalHeight - titleSize.height), 0.0);
    _centerBtn.backgroundColor = [UIColor lightGrayColor];
}

- (void)addImageV {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"b" ofType:@"jpg"];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    self.view.layer.contents = (id)img.CGImage;
    
    UIApplication *app = [UIApplication sharedApplication];
    UIView *statusBar = (UIView *)[app valueForKey:@"_statusBar"];
    if (statusBar) {
        _navV.layer.mask = statusBar.layer;
    }
}

#pragma mark - UITextField

- (void)addTextField {
    tf = [[UITextField alloc]initWithFrame:CGRectMake(50, 200, 200, 30)];
    tf.placeholder = @"input sth";
    tf.layer.borderColor = [UIColor orangeColor].CGColor;
    tf.layer.borderWidth = 1.f;
    tf.returnKeyType = UIReturnKeyContinue;
    [self.view addSubview:tf];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(50, 240, 100, 30);
    [btn setTitle:@"Touch Me" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    btn.layer.borderWidth = 1.f;
    btn.layer.borderColor = [UIColor cyanColor].CGColor;
    [btn addTarget:self action:@selector(touchMe:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide) name:UIKeyboardDidHideNotification object:nil];
    
}

- (void)keyboardShow{
    NSLog(@"keyboard show");
}

- (void)keyboardHide{
    NSLog(@"keyboard hide");
}

- (void)touchMe:(id)sender {
    tf.returnKeyType = UIReturnKeySend;
    if ([tf isFirstResponder]) {
        [tf resignFirstResponder];
    }
    [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
}


#pragma mark -  srcollview

- (void)addScrollView {
    sc = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 300)];
    sc.backgroundColor = [UIColor lightGrayColor];
    sc.contentSize = CGSizeMake(self.view.frame.size.width * 2, 300);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSC:)];
    
    [self.view addSubview:sc];
}

- (void)tapSC:(id)sender {
    NSLog(@"tap");
}

#pragma mark - UITextViewDelegate

-(void)textViewDidChange:(UITextView *)textView {
    l.text = textView.text;
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[UILabel class]]) {
        UILabel *label = object;
        NSLog(@"l:%@", label.text);
    } else if ([object isKindOfClass:[UITextView class]]) {
        UITextView *textV = object;
//        NSLog(@"tv:%@", textV.text);
    }
    
}

#pragma mark - add view

- (void)addTextViewAndLabel {
    tv = [[UITextView alloc]initWithFrame:CGRectMake(20, 200, 300, 40)];
    tv.layer.borderWidth = 1.f;
    tv.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:tv];
    
    l = [[UILabel alloc]initWithFrame:CGRectMake(tv.frame.origin.x, tv.frame.origin.y + tv.frame.size.height + 10, tv.frame.size.width, 30)];
    [self.view addSubview:l];
    tv.delegate = self;
    [tv addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [l addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)addBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    btn.frame = CGRectMake(200, 200, 50, 50);
    btn.backgroundColor = [UIColor grayColor];
    [btn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)tap:(id)sender {
    [self presentViewController:[TestViewController new] animated:YES completion:nil];
}

#pragma mark - NSRecursiveLock

- (void)testRecursiveLock {
    /*
     如果使用NSLock,会死锁
    NSLock *lock = [NSLock new];
     *** -[NSLock lock]: deadlock (<NSLock: 0x7fee38ea8bd0> '(null)')
     *** Break on _NSLockError() to debug.
     */
    NSRecursiveLock *lock = [NSRecursiveLock new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^RecursiveMethod)(NSInteger);
        RecursiveMethod = ^(NSInteger value) {
            [lock lock];
            if (value > 0) {
                NSLog(@"value = %@", @(value));
                sleep(1);
                RecursiveMethod(value - 1);
            };
            [lock unlock];
        };
        RecursiveMethod(5);
    });
}

- (void)conditionLock {
    NSConditionLock *conLock = [NSConditionLock new];
    
    //此线程中加锁使用lock，不需要条件，就顺利锁住，但是在unlock中使用了一个整形的条件，它可以开启其他线程中正在等待这把钥匙的临界地，
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < 4; i ++) {
            [conLock lock];
            NSLog(@"thread1:%ld", i);
            sleep(1);
            [conLock unlockWithCondition:i];
        }
    });
    //此线程中需要一把标识为2的钥匙，当线程1循环到最后一次时，才打开此线程中的阻塞
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [conLock lockWhenCondition:2];
        NSLog(@"thread2");
        [conLock unlock];
    });
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"will appear");
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"did appear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
