//
//  HAMNodeSelectorViewController.h
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMViewTool.h"
#import "HAMConfig.h"
#import "HAMCardGridViewController.h"
#import "HAMCategoryEditorViewController.h"
#import "HAMGridCell.h"
#import "HAMGridViewController.h"

@interface HAMCategoryGridViewController : HAMGridViewController <UICollectionViewDataSource, UICollectionViewDelegate, HAMGridCellDelegate, UIActionSheetDelegate, HAMCategoryEditorViewControllerDelegate, HAMCardEditorViewControllerDelegate>
{
}

@property (weak, nonatomic) HAMConfig* config;
@property NSString* parentID;
// 1	 - edit
// other - replace
@property NSInteger index;
@property HAMGridCellMode cellMode;
@property (strong, nonatomic) NSArray *categoryIDs;

@end
