//
//  CoreDataViewController.m
//  DataMemory
//
//  Created by 祥云创想 on 2018/10/25.
//  Copyright © 2018年 MAC. All rights reserved.
//

#import "CoreDataViewController.h"
#import <CoreData/CoreData.h>
#import "LHModel.h"
@interface CoreDataViewController ()
/**
 * 上下文  容器
 * 存放的是 所有从数据库中取出的转换成OC对象
 */
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

/* 读取解析 .momd文件中的内容 */
@property (strong, nonatomic) NSManagedObjectModel * managedObjectModel;

/* 连接的类，处理数据库数据和OC数据底层的相互转换 */
@property (strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@end

@implementation CoreDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"%@",self.managedObjectContext);
    
    
    //插入一条数据 （往LHModel表中插入一条数据）
    //NSEntityDescription 实体类
    //EntityForName 实体名称（表名）
    LHModel * model = [NSEntityDescription insertNewObjectForEntityForName:@"LHModel1" inManagedObjectContext:self.managedObjectContext];
    //赋值
    model.title = @"缓存1";
    model.content = @"缓存1内容";
    //同步操作  把context中的数据同步到数据库中
    [self saveContext];
    
    
    // 查询数据
    // 创建查询请求
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"LHModel1"];
    // Context 执行请求（执行查询操作） 数组中存放的是oc类的对象（People类的对象）
    NSArray * array = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (LHModel *lhModel in array)
    {
        NSLog(@"%@",lhModel.title);
    }
    
    
    //查询特定条件数据
    NSFetchRequest * request1 = [NSFetchRequest fetchRequestWithEntityName:@"LHModel1"];
    //使用谓词指定查询的判定条件
    NSString * title = @"缓存1";
//    NSString *predStr = [NSString stringWithFormat:@"%@ AND (%@ CONTAINS \"%@\")", kPredicateStr_MovieItem_MoviesInCatalog, titleForSearch, title];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF.title == '%@'",title]];
    //关联判定条件
    [request1 setPredicate:predicate];
    //执行查询操作
    NSArray * array2 = [self.managedObjectContext executeFetchRequest:request1 error:nil];
    for (LHModel * lhModel in array2)
    {
        NSLog(@"%@",lhModel.title);
    }
    
    //更改数据
    //获取出要修改的数据
    LHModel * lhModel = [array lastObject];
    //修改属性
    lhModel.title = @"缓存2";
    lhModel.content  = @"缓存2内容";
    //同步数据
    [self saveContext];
    
    
    //删除数据
    LHModel * lhModel1 = [array lastObject];
    [self.managedObjectContext deleteObject:lhModel1];
    //同步数据
    [self saveContext];
}

//managedObjectModel 属性的getter方法
- (NSManagedObjectModel *)managedObjectModel
{
    
    if (_managedObjectModel != nil) return _managedObjectModel;
    //.xcdatamodeld文件 编译之后变成.momd文件  （.mom文件）
    NSURL * modelURL = [[NSBundle mainBundle] URLForResource:@"MemoryData" withExtension:@"momd"];
    
    //把文件的内容读取到managedObjectModel中
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

//Coordinator 调度者负责数据库的操作 创建数据库 打开数据 增删改查数据
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) return _persistentStoreCoordinator;
    // 设置数据库存放的路径
    NSURL * storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"MemoryData.sqlite"];

    //根据model创建了persistentStoreCoordinator
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    
    
    NSError * error = nil;
    
    //如果没有得到数据库
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"错误信息: %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

//容器类 存放OC的对象
-(NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)  return _managedObjectContext;
    
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
    if (!coordinator)
    {
        return nil;
    }
    
   /* 创建context对象 NSManagedObjectContext 实例提供一个线程。我们需要将这个 init 方法替换成 -initWithConcurrency: 方法。这个方法配置了 NSManagedObjectContext 实例化所在的线程。
    这就意味着我们要确定在哪个线程上实例化我们的 NSManagedObjectContext ，主线程，还是另外创建一个后台线程。我们可以选择的参数有：

    NSPrivateQueueConcurrencyType
    NSMainQueueConcurrencyType
    在这里，我把它配置成在主线程上进行实例化（一般选择主线程就可以）*/
    
  
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    //让context和coordinator关联   context可以对数据进行增删改查功能
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

-(void)saveContext
{
    NSManagedObjectContext * managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        NSError * error = nil;
        // hasChanges 判断数据是否更改
        // sava 同步数据库中的数据
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"错误信息: %@, %@", error, [error userInfo]);
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
