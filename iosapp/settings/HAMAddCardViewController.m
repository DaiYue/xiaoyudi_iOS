//
//  HAMAddCardPopoverViewController.m
//  iosapp
//
//  Created by Dai Yue on 13-12-6.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMAddCardViewController.h"
#import "HAMSettingsViewController.h"

@interface HAMAddCardViewController ()

@end

@implementation HAMAddCardViewController

@synthesize cardIndex_;
@synthesize config_;
@synthesize parentID_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss {
	[self.delegate addCardDismissed:self];
}

- (IBAction)addFromLibClicked:(UIButton *)sender{
	[self dismiss];
    [self.delegate enterLibAt:cardIndex_];
}

- (IBAction)createCardClicked:(UIButton *)sender{
    HAMCardEditorViewController* cardEditor = [[HAMCardEditorViewController alloc] initWithNibName:@"HAMCardEditorViewController" bundle:nil];
    //mainSettingsViewController.cardEditorViewController = cardEditor;
    
    cardEditor.delegate = self; // NOTE!!!
    cardEditor.addCardOnCreation = YES;
    cardEditor.parentID = parentID_;
    cardEditor.index = cardIndex_;
    cardEditor.config = config_;
	// ‘nil' indicates this is a new card
	cardEditor.categoryID = cardEditor.cardID = nil;
    
    cardEditor.modalPresentationStyle = UIModalPresentationCurrentContext;
    cardEditor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    // pretend the card editor is floating above the background view
    UIView *background = [self.delegate.view snapshotViewAfterScreenUpdates:NO];
    [cardEditor.view insertSubview:background atIndex:0];
    
    [self.delegate presentViewController:cardEditor animated:YES completion:NULL];
    
	[self dismiss];
}

- (void)cardEditorDidCancelEditing:(HAMCardEditorViewController *)cardEditor {
	[self.delegate dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cardEditorDidEndEditing:(HAMCardEditorViewController *)cardEditor {
	[self.delegate dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelClicked:(UIButton *)sender{
	[self dismiss];
}
@end
