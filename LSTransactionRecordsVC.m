//
//  LSTransactionRecordsVC.m
//  JianChu
//
//  Created by CC on 2017/10/18.
//  Copyright © 2017年 历成栋. All rights reserved.
//

#import "LSTransactionRecordsVC.h"
#import "LSTransactionRecordManager.h"
#import "LSTransactionRecordCell.h"
#import "SelectTimeSheet.h"

static NSString *const SectionHeader = @"SectionHeader";
static const NSInteger SectionHeaderTitleTag = 55;
static const NSInteger SectionHeaderSubTitleTag = 66;
static const NSInteger SectionHeaderDateBtnTag = 77;

@interface LSTransactionRecordsVC ()<UITableViewDelegate,UITableViewDataSource>{
    CGFloat _oldY;
    BOOL _isUpScroll;
    BOOL _isFirstLoad;
    NSInteger _currentSection;
}
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (nonatomic,strong) LSTransactionRecordManager *manager;

/**
 时间选择按钮背景 section header
 */
@property (nonatomic,strong) UIView *tmpSectionHeader;
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) SelectTimeSheet *dateSelect;

@end

@implementation LSTransactionRecordsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTable];
    
//    [self getData];
    
    [self initMJ];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];
}

#pragma mark -data
/**
 页面请求失败  点击 提示图重新请求 调用方法 子类 重写此方法实现
 */
-(void)networkReset{
    [self getData];
}


#pragma mark - data
-(void)initMJ{
    __weak typeof(self) weakself = self;
    
    [self tableFooterMJLoadWith:^(BOOL refresh) {
        weakself.manager.transactionReq.page = [NSString stringWithFormat:@"%d",weakself.manager.transactionReq.page.intValue+1];
        
        [weakself getData];
        
    } andTable:self.myTable];
    
    [self tableHeaderMJRefreshWith:^(BOOL refresh) {
        weakself.manager.transactionReq.page = @"1";
        weakself.manager.transactionReq.monthDate = nil;
        [weakself getData];
        
    } andTable:self.myTable];
}

-(void)getData{
    __weak typeof(self) weakself = self;
    if (self.type.integerValue==1) {
        weakself.manager.transactionReq.type = self.type;
    }
    [self.manager getListDataWith:^{
        [weakself.myTable reloadData];
        _isFirstLoad = NO;

    }];
}

#pragma mark - get
-(LSTransactionRecordManager*)manager{
    
    if (_manager==nil) {
        _manager = [[LSTransactionRecordManager alloc] init];
    }
    return _manager;
}

-(SelectTimeSheet *)dateSelect{
    if (_dateSelect==nil) {
        __weak typeof(self) weakself = self;

        SelectTimeSheet *sheet = [[SelectTimeSheet alloc]initWithTitle:@"日期" delegate:nil sheetType:sheetType_picker];

        sheet.datePicker.datePickerMode = UIDatePickerModeDate;//UIDatePickerModeDateAndTime;//UIDatePickerModeDate;
        _dateSelect = sheet;
        _dateSelect.myBlock = ^(SelectTimeSheet * mySheet) {
            NSDate *selectedDate = mySheet.datePicker.date;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSString *destDateString = nil;
            
            // 为日期格式器设置格式字符串
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];//YYYY-MM-HH HH：MM：SS  yyyy-MM-dd HH:mm
            destDateString = [dateFormatter stringFromDate:selectedDate];
            NSLog(@"%@",destDateString);
            weakself.manager.transactionReq.monthDate = destDateString;
            weakself.manager.transactionReq.page = @"1";
            [weakself getData];
        };
    }
    return _dateSelect;
}

#pragma mark - table
-(void)initTable{
    
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    self.myTable.tableFooterView = [[UIView alloc] init];

    [self.myTable registerNib:[UINib nibWithNibName:@"LSTransactionRecordCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:LSTransactionRecordCell_id];
    [self.myTable registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:SectionHeader];
    _isFirstLoad = YES;
    
    
//    self.topView = [self createTopView];
//    self.topView.hidden = YES;
//    [self.view addSubview:self.topView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.manager.teamListArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.manager getRowWith:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self.manager getRowHeightWith:indexPath];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LSTransactionRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:LSTransactionRecordCell_id];
    if (cell==nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LSTransactionRecordCell" owner:nil options:nil] firstObject];
    }
    [self.manager setCellWith:cell andIndex:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.manager changeCellItemOpenStatusWith:indexPath andOpen:![self.manager getCellItemOpenStatusWith:indexPath]];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeader];
    if (view==nil) {
//        view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
        
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:SectionHeader];
        view.backgroundColor = RGB(234,234,234,1);
        view.frame = CGRectMake(0, 0, ScreenWidth, 20);
    }
    
    UILabel *title = [view viewWithTag:SectionHeaderTitleTag];
    if (title==nil) {
        title = [BHQuickControl createLabelWithFrame:CGRectMake(11, 5, ScreenWidth-50, 20) font:14 textColor:RGB(51,51,51,1) text:@""];
        [view addSubview:title];
        title.tag = SectionHeaderTitleTag;
    }
    
    UILabel *subtitle = [view viewWithTag:SectionHeaderSubTitleTag];
    if (subtitle==nil) {
        subtitle = [BHQuickControl createLabelWithFrame:CGRectMake(11, 30, ScreenWidth-50, 20) font:12 textColor:RGB(153,153,153,1) text:@""];
        [view addSubview:subtitle];
        subtitle.tag = SectionHeaderSubTitleTag;
    }
    
    LSTransactionRecordGroup *group = [self.manager getGroupModelWith:section];
    title.text = group.title;
    subtitle.text = group.content;
    
    UIButton *btn = [view viewWithTag:SectionHeaderDateBtnTag];
    if (btn==nil) {
        btn = [BHQuickControl createButtonWithFrame:CGRectMake(ScreenWidth-30, 15, 22, 20) title:@"" titleColor:[UIColor whiteColor] font:14 image:[UIImage imageNamed:@"date_button"] target:self method:@selector(dateSelected:)];
        [view addSubview:btn];
        btn.tag = SectionHeaderDateBtnTag;
    }
   
    return view;
   
}

-(UIView*)createTopView{
    if (self.topView!=nil) {
        UILabel *subtitle = [self.topView viewWithTag:SectionHeaderSubTitleTag];
        UILabel *title = [self.topView viewWithTag:SectionHeaderTitleTag];
        LSTransactionRecordGroup *group = [self.manager getGroupModelWith:_currentSection];
        title.text = group.title;
        subtitle.text = group.content;
        
        return self.topView;
    }
    
    UIView *view = nil;
    if (view==nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
        
//        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:SectionHeader];
        view.backgroundColor = RGB(234,234,234,1);
        view.frame = CGRectMake(0, 0, ScreenWidth, 20);
    }
    
    UILabel *title = [view viewWithTag:SectionHeaderTitleTag];
    if (title==nil) {
        title = [BHQuickControl createLabelWithFrame:CGRectMake(11, 5, ScreenWidth-50, 20) font:14 textColor:RGB(51,51,51,1) text:@""];
        [view addSubview:title];
        title.tag = SectionHeaderTitleTag;
    }
    
    UILabel *subtitle = [view viewWithTag:SectionHeaderSubTitleTag];
    if (subtitle==nil) {
        subtitle = [BHQuickControl createLabelWithFrame:CGRectMake(11, 30, ScreenWidth-50, 20) font:12 textColor:RGB(153,153,153,1) text:@""];
        [view addSubview:subtitle];
        subtitle.tag = SectionHeaderSubTitleTag;
    }
    
//    LSTransactionRecordGroup *group = [self.manager getGroupModelWith:_currentSection];
//    title.text = group.title;
//    subtitle.text = group.content;
    
    UIButton *btn = [view viewWithTag:SectionHeaderDateBtnTag];
    if (btn==nil) {
        btn = [BHQuickControl createButtonWithFrame:CGRectMake(ScreenWidth-30, 15, 22, 20) title:@"" titleColor:[UIColor whiteColor] font:14 image:[UIImage imageNamed:@"date_button"] target:self method:@selector(dateSelected:)];
        [view addSubview:btn];
        btn.tag = SectionHeaderDateBtnTag;
    }
    self.topView = view;
    return view;
}

-(void)dateSelected:(UIButton*)sender{
    NSLog(@"date");
    [self.dateSelect showInView:self.view];

}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    NSLog(@"willDisplayHeaderView显示第%ld组",(long)section);
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect=[view convertRect: view.bounds toView:window];
    CGFloat y = rect.origin.y;
//    if (self.isLoading) {
//        return;
//    }
    if (y<=64) {
        [self changeDateBtnWith:view andHide:NO];
        NSInteger next1 = (section+1)>=self.manager.teamListArr.count?section:section+1;
        if (next1!=section) {
            UIView *view1 = [tableView headerViewForSection:next1];
            [self changeDateBtnWith:view1 andHide:YES];

        }

    }else{
        [self changeDateBtnWith:view andHide:YES];

    }
//    if(!_isUpScroll && (_currentSection - section) == 1){
    
        //最上面组头（不一定是第一个组头，指最近刚被顶出去的组头）又被拉回来
//        _currentSection = section;
//        UIView *view0 = [tableView headerViewForSection:_currentSection];
//        [self changeDateBtnWith:view0 andHide:NO];
//        UIView *view1 = [tableView headerViewForSection:_currentSection+1];
//        [self changeDateBtnWith:view1 andHide:YES];
//        NSLog(@"willDisplayHeaderView显示第%ld组",(long)_currentSection);
//    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section{
    NSLog(@"didEndDisplayingHeaderView显示第%ld组",(long)section);
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect=[view convertRect: view.bounds toView:window];
    CGFloat y = rect.origin.y;
//    if (self.isLoading) {
//        return;
//    }
    if (y<=64) {
        [self changeDateBtnWith:view andHide:YES];
        NSInteger next1 = (section+1)>=self.manager.teamListArr.count?section:section+1;
        if (next1!=section) {
            UIView *view1 = [tableView headerViewForSection:next1];
            [self changeDateBtnWith:view1 andHide:NO];
            
        }
    }else{
        [self changeDateBtnWith:view andHide:YES];
    }
    
//    if(!_isFirstLoad && _isUpScroll){
//
//        _currentSection = section + 1;
        //最上面的组头被顶出去
//        UIView *view0 = [tableView headerViewForSection:section];
//        [self changeDateBtnWith:view0 andHide:YES];
//        UIView *view1 = [self.myTable headerViewForSection:_currentSection];
//        [self changeDateBtnWith:view1 andHide:NO];
        
//        NSLog(@"didEndDisplayingHeaderView显示第%ld组",(long)_currentSection);
//    }
    
}

-(void)changeDateBtnWith:(UIView *)backview andHide:(BOOL)hide{
    UIButton *btn = [backview viewWithTag:SectionHeaderDateBtnTag];
    btn.hidden = hide;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ([scrollView isEqual: self.myTable]) {
        
        if (self.myTable.contentOffset.y > _oldY) {
            
            // 上滑
            _isUpScroll = YES;
            
//            NSLog(@"上滑");
        }else{
            
            // 下滑
            _isUpScroll = NO;
//            NSLog(@"下滑");
            
        }
        _isFirstLoad = NO;
        
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    // 获取开始拖拽时tableview偏移量
    _oldY = self.myTable.contentOffset.y;
    
}


@end
