//
//  ViewController.m
//  Data
//
//  Created by wyzc on 2017/9/24.
//  Copyright © 2017年 wyzc. All rights reserved.
//

#import "ViewController.h"
#import "GDataDefines.h"
#import "GDataXMLNode.h"
#import "TFHpple.h"
#import "FMDB.h"
#import "Person.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSMutableString *GDatatext;
@property (nonatomic, copy) NSString *dbPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (![self isFileExist:@"Customer.sqlite"]) {
      [self createTable];
    }
}

-(BOOL) isFileExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    NSLog(@"这个文件已经存在：%@",result?@"是的":@"不存在");
    return result;
}

- (NSString *)dbPath{
    NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Customer.sqlite"];
    return dbPath;
}

- (void)createTable{
    //1.获得数据库文件的路径
    
    //2.获得数据库
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    
    //3.使用如下语句，如果打开失败，可能是权限不足或者资源不足。通常打开完操作操作后，需要调用 close 方法来关闭数据库。在和数据库交互 之前，数据库必须是打开的。如果资源或权限不足无法打开或创建数据库，都会导致打开失败。
    if ([db open])
    {
        //4.创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Customer (id integer PRIMARY KEY AUTOINCREMENT, userId integer NOT NULL, userStyle, userName, userNumber,mobile, startTime,memberIntegral);"];
        if (result)
        {
            NSLog(@"创建表成功");
        }
    }else{
        NSLog(@"打开失败");
    }
}

- (void)insertDataWith:(Person *)person{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    BOOL open = [db open];
    if (open) {
        //1.executeUpdate:不确定的参数用？来占位（后面参数必须是oc对象，；代表语句结束）
        BOOL res =  [db executeUpdate:@"INSERT INTO Customer (userId,userName,userStyle,userNumber,startTime,memberIntegral,mobile) VALUES (?,?,?,?,?,?,?);",person.userId,person.userName,person.userStyle,person.userNumber,person.startTime,person.memberIntegral,person.mobile];
//        BOOL res = [db executeUpdate:@"INSERT INTO Customer (userId, userStyle,userName,userNumber,mobile,startTime,memberIntegral) VALUES (?,?,?,?,?,?,?);",person.userId.integerValue,person.userStyle,person.userName,person.userNumber,person.mobile,person.startTime,person.memberIntegral.integerValue];
        if (res == NO) {
            NSLog(@"插入失败");
        }else{
            NSLog(@"插入成功");
        }
        [db close];
    }else{
        return;
    }
  
    
//    [self.db executeUpdate:@"INSERT INTO Customer (userId, userStyle,userName,userNumber,mobile,startTime,memberIntegral) VALUES (?,?,?,?,?,?,?);",@(person.userId.integerValue),person.userStyle,person.userName,person.userNumber,person.mobile,person.startTime,@(person.memberIntegral.integerValue)];
    
//    //2.executeUpdateWithForamat：不确定的参数用%@，%d等来占位 （参数为原始数据类型，执行语句不区分大小写）
//    [self.db executeUpdateWithForamat:@"insert into t_student (name,age) values (%@,%i);",name,age];
//
//    //3.参数是数组的使用方式
//    [self.db executeUpdate:@"INSERT INTO
//     t_student(name,age) VALUES  (?,?);"withArgumentsInArray:@[name,@(age                 )]];
}

- (IBAction)productData:(id)sender {
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"xml"];
//    NSData *data = [[NSData alloc]initWithContentsOfFile:path];
    NSData *data = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *array =[hpple searchWithXPathQuery:@"//div"];
    
    for (TFHppleElement *HppleElement in array) {
        NSArray *subArr = [HppleElement searchWithXPathQuery:@"//tr"];
        for (int j = 0; j < subArr.count; j++) {
            if (j==0) {
                continue;
            }
            TFHppleElement *trHppleElement = [subArr objectAtIndex:j];
            NSArray *array2 = [trHppleElement searchWithXPathQuery:@"//td"];
            Person *person = [[Person alloc] init];
            for (int i=0; i<array2.count; i++) {
                TFHppleElement *tdHppleElement = [array2 objectAtIndex:i];
                NSLog(@"**** %@",tdHppleElement.text);
                switch (i) {
                    case 0:
                        person.userId = tdHppleElement.text;
                        break;
                    case 1:
                        person.userStyle = tdHppleElement.text;
                        break;
                    case 2:
                        person.userName = tdHppleElement.text;
                        break;
                    case 3:
                        person.userNumber = tdHppleElement.text;
                        break;
                    case 4:
                        person.mobile = tdHppleElement.text;
                        break;
                    case 5:
                        person.startTime = tdHppleElement.text;
                        break;
                    case 6:
                        person.memberIntegral = tdHppleElement.text;
                        break;
                    default:
                        break;
                }
            }
            [self insertDataWith:person];
        }
        NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
    }

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
