//
//  UCARPopSelectView.m
//  UCARUIKit
//
//  Created by linux on 29/01/2018.
//

#import "UCARPopSelectView.h"
#import <Masonry/Masonry.h>

@interface UCARPopSelectCell: UITableViewCell

@end

@implementation UCARPopSelectCell

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateConstraints
{
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.equalTo(@16);
        make.left.equalTo(self.contentView.mas_left);
        make.width.equalTo(@16);
    }];
    
    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.left.equalTo(self.contentView.mas_left).offset(26);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    [super updateConstraints];
}

@end

@interface UCARPopSelectView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, strong) NSArray<NSDictionary *> *selections;

@property (nonatomic, copy) void(^selectedBlock)(NSInteger index);

@property (nonatomic, strong) NSDictionary *textAttrDict;

@end

@implementation UCARPopSelectView

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.scrollEnabled = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.sectionHeaderHeight = 0.1;
        _tableView.sectionFooterHeight = 0.1;
        [_tableView registerClass:[UCARPopSelectCell class] forCellReuseIdentifier:@"UCARPopSelectCell"];
    }
    return _tableView;
}

- (instancetype)initWithSelections:(NSArray<NSDictionary *> *)selections pointTarget:(UIView *)targetView inView:(UIView *)containerView withSelectedBlock:(void (^)(NSInteger index))selectedBlock;
{
    return [self initWithSelections:selections pointTarget:targetView pointPosition:UCARPopTipViewAnchorPointPositionBoundary inView:containerView withSelectedBlock:selectedBlock];
}


- (instancetype)initWithSelections:(NSArray<NSDictionary *> *)selections pointTarget:(UIView *)targetView pointPosition:(UCARPopTipViewAnchorPointPosition)pointPosition inView:(UIView *)containerView withSelectedBlock:(void (^)(NSInteger index))selectedBlock
{
    self = [super initWithContainerView:containerView];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.backView addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.tableView];
        
        self.cellHeight = 60;
        
        self.selections = selections;
        self.selectedBlock = selectedBlock;
        
        self.textAttrDict = @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: UCAR_ColorFromHexString(@"#333333")};
        
        CGFloat maxWidth = [self maxWidthOfText];
        CGFloat height = self.cellHeight * self.selections.count;
        self.tableView.frame = CGRectMake(0, 0, maxWidth, height);
        
        [self.tableView reloadData];
        
        [self layoutContentView:self.tableView pointTarget:targetView pointPosition:pointPosition inView:containerView];
    }
    return self;
}

- (CGFloat)maxWidthOfText
{
    CGFloat maxWidth = 0;
    for (NSDictionary *dict in _selections) {
        NSString *title = dict[@"title"];
        CGFloat width = ceil([title sizeWithAttributes:self.textAttrDict].width);
        if (dict[@"image"]) {
            width += 26;
        }
        if (width > maxWidth ) {
            maxWidth = width;
        }
    }
    return maxWidth;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.selections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UCARPopSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UCARPopSelectCell" forIndexPath:indexPath];
    NSDictionary *config = self.selections[indexPath.row];
    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:config[@"title"] attributes:self.textAttrDict];
    cell.imageView.image = config[@"image"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedBlock(indexPath.row);
    [self hide];
}

- (void)show
{
//    {
//        [self animationShow];
//        return;
//    }
    
    self.alpha = 0.0;
    self.backView.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
        self.backView.alpha = 1.0;
    }];
}

- (void)hide
{
//    {
//        [self animationDisappear];
//        return;
//    }
    
    //播放动画
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            [self.backView removeFromSuperview];
        }
    }];
}


// 动画显示
- (void)animationShow {
    //初始弹出视图的很小的状态
    self.contentView.transform = CGAffineTransformMakeScale(0.000001, 0.000001);
    [UIView animateWithDuration:1.425f delay:0 usingSpringWithDamping:0.3f initialSpringVelocity:0.1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        // 恢复原尺寸
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

// 动画隐藏
- (void)animationDisappear {
    [UIView animateWithDuration:.35 animations:^{
        self.contentView.transform = CGAffineTransformMakeScale(0.000001, 0.000001);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)dealloc
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

@end
