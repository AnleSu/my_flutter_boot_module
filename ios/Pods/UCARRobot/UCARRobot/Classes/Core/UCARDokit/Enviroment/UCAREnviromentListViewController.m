//
//  UCAREnviromentListViewController.m
//  UCARRobot
//
//  Created by suzhiqiu on 2019/7/2.
//

#import "UCAREnviromentListViewController.h"
#import "UCAREnvironmentManager.h"
#import "UCAREnviromentModel.h"

@interface UCAREnviromentListViewController ()<UITableViewDelegate,UITableViewDataSource>
    
    
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,copy) NSArray *dataArray;

@end

@implementation UCAREnviromentListViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self prepareData];
}

- (BOOL)needBigTitleView{
    return YES;
}

- (void)prepareUI{
    self.title = DoraemonLocalizedString(@"切换环境");
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.bigTitleView.doraemon_bottom, self.view.doraemon_width, self.view.doraemon_height-self.bigTitleView.doraemon_bottom) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 0.;
    self.tableView.estimatedSectionFooterHeight = 0.;
    self.tableView.estimatedSectionHeaderHeight = 0.;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.doraemon_width, 0.1)];
    [self.view addSubview:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEnviroment) name:UCAREnvironmentEndChangeNotification object:nil];
}
    
- (void)prepareData{
    self.dataArray = [[UCAREnvironmentManager shareManager].envArray copy];
    [self updateEnviroment];
}

-(void)updateEnviroment{
    UCAREnviromentModel * curEnvModel = [UCAREnvironmentManager currentEnviroment];
    if(!curEnvModel){
        return;
    }
    for (UCAREnviromentModel *model in self.dataArray) {
        if ([model.name isEqualToString:curEnvModel.name]) {
            model.isOpen = YES;
        }else {
            model.isOpen = NO;
        }
    }
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
/*高度*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]  initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
    }
   UCAREnviromentModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.isOpen){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@",model.desc,model.name];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UCAREnviromentModel *model = [self.dataArray objectAtIndex:indexPath.row];
    NSDictionary *userInfo = @{@"Environment":model};
    [[NSNotificationCenter defaultCenter] postNotificationName:UCAREnvironmentDidChangeNotification object:nil userInfo:userInfo];
}


@end
