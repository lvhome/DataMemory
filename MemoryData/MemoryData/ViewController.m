//
//  ViewController.m
//  DataMemory
//
//  Created by mac on 2018/10/24.
//  Copyright © 2018年 MAC. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#define LvPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"lvData.plist"]
#define LPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"lData.plist"]
#define LhPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"lhData.plist"]
#import "CoreDataViewController.h"
#import "LHKeyChain.h"
@interface ViewController ()
{
    //db是数据库的缩写
    sqlite3 * db;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"沙盒路径---%@",NSHomeDirectory());
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSLog(@"Documents---%@",document);
    NSLog(@"tmp---%@",NSTemporaryDirectory());
    NSLog(@"Library-----%@",NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0]);
    //NSUserDefaults
    UIButton * defaultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    defaultBtn.frame = CGRectMake(10, 80, 80, 80);
    [defaultBtn setTitle:@"default" forState:UIControlStateNormal];
    defaultBtn.backgroundColor = [UIColor redColor];
    [defaultBtn addTarget:self action:@selector(setDefault) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:defaultBtn];
    
    UIButton * delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    delBtn.frame = CGRectMake(200, 80, 80, 80);
    delBtn.backgroundColor = [UIColor redColor];
    [delBtn setTitle:@"清空" forState:UIControlStateNormal];
    [delBtn addTarget:self action:@selector(delDefault) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:delBtn];
    
    //文件
    NSDictionary *dic = @{@"A":@"123"};
    NSArray * arr = @[@"Q",@"123"];
    NSString * string = @"aaaaaaaa";
    [dic writeToFile:LvPath atomically:YES];
    [arr writeToFile:LPath atomically:YES];
    [string writeToFile:LhPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    UIButton * fileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    fileBtn.frame = CGRectMake(10, 180, 80, 80);
    [fileBtn setTitle:@"file" forState:UIControlStateNormal];
    fileBtn.backgroundColor = [UIColor redColor];
    [fileBtn addTarget:self action:@selector(setFile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fileBtn];
    
    //归档
    [self createArchiver];
    //数据库
    [self createSqlite];
    UIButton * insertBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    insertBtn.frame = CGRectMake(10, 270, 80, 80);
    [insertBtn setTitle:@"insert" forState:UIControlStateNormal];
    insertBtn.backgroundColor = [UIColor redColor];
    [insertBtn addTarget:self action:@selector(createSqliteInsert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:insertBtn];
    
    UIButton * selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(200, 270, 80, 80);
    [selectBtn setTitle:@"select" forState:UIControlStateNormal];
    selectBtn.backgroundColor = [UIColor redColor];
    [selectBtn addTarget:self action:@selector(createSqliteSelect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectBtn];
    
    UIButton * delSBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    delSBtn.frame = CGRectMake(10, 370, 80, 80);
    [delSBtn setTitle:@"del" forState:UIControlStateNormal];
    delSBtn.backgroundColor = [UIColor redColor];
    [delSBtn addTarget:self action:@selector(createSqliteDel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:delSBtn];
    
    UIButton * changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeBtn.frame = CGRectMake(200, 370, 80, 80);
    [changeBtn setTitle:@"change" forState:UIControlStateNormal];
    changeBtn.backgroundColor = [UIColor redColor];
    [changeBtn addTarget:self action:@selector(createSqliteChange) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeBtn];
    
    //跳转coreData
    UIButton * coreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    coreBtn.frame = CGRectMake(200, 370 + 100, 80, 80);
    [coreBtn setTitle:@"coreBtn" forState:UIControlStateNormal];
    coreBtn.backgroundColor = [UIColor redColor];
    [coreBtn addTarget:self action:@selector(createCoreData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:coreBtn];
}


//数据库
- (void)createSqlite {
    
    //这里面定义一个数据库存放路径，并获取到
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString * dbPath = [document stringByAppendingPathComponent:@"demo.sqlite"];
    //因为sqlite是c语言 所以下面需要将OC字符串转换为c语言的字符串
    const char * cdbPath = dbPath.UTF8String;
    //下面打开数据库 (如果数据库存在的话，会直接打开，反之数据库不存在的话，会自动创建数据库文文件)
    int result = sqlite3_open(cdbPath, &db);
    if (result == SQLITE_OK) {
        NSLog(@"成功打开数据库");
        //数据库 现在有了，接下来创建表
        const char * sql = "create table if not exists t_demo (id integer PRIMARY KEY AUTOINCREMENT,title text not null, content text not null)";
        char * errorMsg = NULL;
        result = sqlite3_exec(db, sql, NULL, NULL, &errorMsg);
        if (result == SQLITE_OK) {
            NSLog(@"表创建成功");
        } else {
            NSLog(@"表创建失败 %s",errorMsg);
            printf("创表失败---%s----%s---%d",errorMsg,__FILE__,__LINE__);
        }
    } else {
        NSLog(@"数据库打开失败");
    }
    
}
//数据库插入数据
- (void)createSqliteInsert {
    for (int i=0; i<8; i++) {
        //1.拼接SQL语句
        NSString * title = [NSString stringWithFormat:@"title--%d",i];
        NSString * contet = [NSString stringWithFormat:@"content--%d",i];
        NSString *sql=[NSString stringWithFormat:@"INSERT INTO t_demo (title,content) VALUES ('%@','%@');",title,contet];
        //2.执行SQL语句
        char *errmsg=NULL;
        sqlite3_exec(db, sql.UTF8String, NULL, NULL, &errmsg);
        if (errmsg) {//如果有错误信息
            NSLog(@"插入数据失败--%s",errmsg);
        }else
        {
            NSLog(@"插入数据成功----%@",title);
        }
    }
}

//数据库修改数据
- (void)createSqliteChange {
    //1.拼接SQL语句
    NSString * title = [NSString stringWithFormat:@"title--12"];
    NSString * contet = [NSString stringWithFormat:@"content--13"];
    NSString *sql=[NSString stringWithFormat:@"UPDATE t_demo set title =  '%@',content = '%@' where id = 2;",title,contet];
    //2.执行SQL语句
    char *errmsg=NULL;
    sqlite3_exec(db, sql.UTF8String, NULL, NULL, &errmsg);
    if (errmsg) {//如果有错误信息
        NSLog(@"更新数据失败--%s",errmsg);
    }else
    {
        NSLog(@"更新数据成功----%@",title);
    }
}

//数据库查询数据
- (void)createSqliteSelect {
    const char *sql="SELECT id,title,content FROM t_demo;";
    sqlite3_stmt *stmt=NULL;
    //进行查询前的准备工作
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL)==SQLITE_OK) {//SQL语句没有问题
        NSLog(@"查询语句没有问题");
        //每调用一次sqlite3_step函数，stmt就会指向下一条记录
        while (sqlite3_step(stmt)==SQLITE_ROW) {//找到一条记录
            //取出数据
            //(1)取出第0列字段的值（int类型的值）
            int ID = sqlite3_column_int(stmt, 0);
            //(2)取出第1列字段的值（text类型的值）
            const unsigned char * title = sqlite3_column_text(stmt, 1);
            //(3)取出第2列字段的值（int类型的值）
            const unsigned char * content = sqlite3_column_text(stmt, 2);
            //            NSLog(@"%d %s %d",ID,name,age);
            printf("%d %s %s\n",ID,title,content);
        }
    }else
    {
        NSLog(@"查询语句有问题");
    }
}



//数据库删除数据
- (void)createSqliteDel {
    //1.拼接SQL语句
    NSString *sql=[NSString stringWithFormat:@"DELETE from  t_demo  where id = 2;"];
    //2.执行SQL语句
    char *errmsg=NULL;
    sqlite3_exec(db, sql.UTF8String, NULL, NULL, &errmsg);
    if (errmsg) {//如果有错误信息
        NSLog(@"删除数据失败--%s",errmsg);
    }else
    {
        NSLog(@"删除数据成功");
    }
}



//归档
- (void)createArchiver {
    UIButton * archBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    archBtn.frame = CGRectMake(200, 180, 80, 80);
    [archBtn setTitle:@"file" forState:UIControlStateNormal];
    archBtn.backgroundColor = [UIColor redColor];
    [archBtn addTarget:self action:@selector(setArchiver) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:archBtn];
    
}

- (void)setArchiver {
    NSString *IDFV = [LHKeyChain load:@"IDFV"];
    if ([IDFV isEqualToString:@""] || !IDFV) {
        IDFV = [UIDevice currentDevice].identifierForVendor.UUIDString;
        [LHKeyChain save:@"IDFV" data:IDFV];
    }
    NSLog(@"archiver---%@",[LHKeyChain load:@"IDFV"]);
    [LHKeyChain deleteKeyData:@"IDFV"];
    NSLog(@"archiver---%@",[LHKeyChain load:@"IDFV"]);
}


- (void)setFile {
    NSArray * arr = [NSArray arrayWithContentsOfFile:LPath];
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:LvPath];
    NSString * string = [NSString stringWithContentsOfFile:LhPath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"file :arr--%@ dict---%@  string--%@",arr,dic,string);
}

- (void)setDefault {
    //可以存储 字典 数组 字符等系统自带的数据类型，自定义的对象无法存储
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setObject:@"aaaaaa" forKey:@"DEFAULT"];
    [def synchronize];
    NSLog(@"default ---- %@",[def objectForKey:@"DEFAULT"]);
}

- (void)delDefault {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DEFAULT"];
    NSLog(@"清空了default ---- %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DEFAULT"]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//coreData
- (void)createCoreData {
    CoreDataViewController * coreData = [[CoreDataViewController alloc] init];
    [self.navigationController pushViewController:coreData animated:YES];
}



@end

