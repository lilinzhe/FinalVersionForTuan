//
//  MTHomeDropdownView.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "HomeDropdownView.h"

@interface HomeDropdownView()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableV;
@property(nonatomic,strong) NSArray *subTitles;
@property (weak, nonatomic) IBOutlet UITableView *subTableV;
@property(nonatomic,strong)HomeDropdownModel *selectHomeDropdownModel;


@end

@implementation HomeDropdownView

+(instancetype)dropdownView{
    return [[[NSBundle mainBundle]loadNibNamed:@"HomeDropdownView" owner:nil options:nil]lastObject];
}

-(void)awakeFromNib{
    //设置不随父控件的变化而伸缩
    self.autoresizingMask=UIViewAutoresizingNone;
}

-(void)setHomeDropdownModels:(NSArray *)homeDropdownModels{
    _homeDropdownModels=homeDropdownModels;
    [self.mainTableV reloadData];
    self.subTitles=nil;
}

-(void)setSubTitles:(NSArray *)subTitles{
    _subTitles=subTitles;
    [self.subTableV reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView==self.mainTableV) {
        return self.homeDropdownModels.count;
    }else{
        return self.subTitles.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell;
    
    if (tableView==self.mainTableV) {
        
        cell=[tableView dequeueReusableCellWithIdentifier:@"main"];
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"main"];
            cell.backgroundView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_dropdown_leftpart"]];
            cell.selectedBackgroundView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_dropdown_left_selected"]];
        }
        HomeDropdownModel *homeDropdownModel=self.homeDropdownModels[indexPath.row];
        cell.textLabel.text=homeDropdownModel.title;
        
        if (homeDropdownModel.imageName) {
            cell.imageView.image=[UIImage imageNamed:homeDropdownModel.imageName];
        }        
        
        if (homeDropdownModel.subTitles.count) {
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
        
        
    }else{
        
        cell=[tableView dequeueReusableCellWithIdentifier:@"sub"];
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sub"];
            cell.backgroundView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_dropdown_rightpart"]];
            cell.selectedBackgroundView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_dropdown_right_selected"]];
        }
        cell.textLabel.text=self.subTitles[indexPath.row];
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{    
    
    if (tableView==self.mainTableV) {
        
        //获取当前选中的model
        self.selectHomeDropdownModel=self.homeDropdownModels[indexPath.row];
        
        //获取子表数据
        self.subTitles=self.selectHomeDropdownModel.subTitles;
        
        //如果没有子数据，就发出通知
        if (self.subTitles.count==0) {
            [self.delegate homeDropdownModel:self.selectHomeDropdownModel SubTitle:@"全部"];
        }
        
    }else{

        [self.delegate homeDropdownModel:self.selectHomeDropdownModel SubTitle:self.subTitles[indexPath.row]];
        
    }
    
}

@end
