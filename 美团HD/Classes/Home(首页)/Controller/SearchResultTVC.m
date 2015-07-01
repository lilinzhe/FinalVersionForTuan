//
//  SearchResultTVC.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "SearchResultTVC.h"
#import "MetadataModel.h"
#import "MTConst.h"

@interface SearchResultTVC ()

@property(nonatomic,strong)NSArray *cities;
@property(nonatomic,strong)NSArray *resultCities;

@end

@implementation SearchResultTVC

-(NSArray *)cities{
    if (_cities==nil) {
        _cities=[MetadataModel shared].citiesModels;
    }
    return _cities;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)setSearchText:(NSString *)searchText{
    
    _searchText=searchText.lowercaseString;
    
//    //通过遍历数组，返回符合的结果
//    [self.resultCities removeAllObjects];
//    for (CityModel *city in self.cities) {
//        if ([city.name containsString:searchText]||[city.pinYin.uppercaseString containsString:searchText.uppercaseString]||[city.pinYinHead.uppercaseString containsString:searchText.uppercaseString]) {
//            [self.resultCities addObject:city];
//        }
//    }
    
    //通过谓词 过滤出结果
    NSPredicate *predicare=[NSPredicate predicateWithFormat:@"name contains %@ or pinYin contains %@ or pinYinHead contains %@",_searchText,_searchText,_searchText];
    self.resultCities=[self.cities filteredArrayUsingPredicate:predicare];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.resultCities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text=[self.resultCities[indexPath.row] name];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [NSString stringWithFormat:@"搜索结果共计%ld个",self.resultCities.count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CityModel *city=self.resultCities[indexPath.row];
    //发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:CityDidChangeNotification object:nil userInfo:@{SelectCityName:city.name}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
