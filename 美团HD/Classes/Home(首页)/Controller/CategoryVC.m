
//分类控制器，显示分类列表

#import "CategoryVC.h"
#import "HomeDropdownView.h"
#import "MetadataModel.h"
#import "MTConst.h"

@interface CategoryVC ()<HomeDropdownViewDelegate>

@end

@implementation CategoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //下拉界面
    HomeDropdownView *dropdownView=[HomeDropdownView dropdownView];
    
    dropdownView.delegate=self;
    
    //传数据
    NSArray *categories=[MetadataModel shared].categoryModels;
    for (CategoryModel *category in categories) {
        category.title=category.name;
        category.imageName=category.small_icon;
        category.subTitles=category.subcategories;
    }
    dropdownView.homeDropdownModels=categories;
    
    //设置view
    self.view=dropdownView;
    
    //设置在popover时，在父视图中的大小
    self.preferredContentSize=self.view.size;
}

#pragma mark - HomeDropdownViewDelegate
//发出通知
-(void)homeDropdownModel:(HomeDropdownModel *)homeDropdownModel SubTitle:(NSString *)subTitle{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CategoryDidChangeNotification object:nil userInfo:@{Selectcategory:(CategoryModel *)homeDropdownModel,SelectsubCategory:subTitle}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
