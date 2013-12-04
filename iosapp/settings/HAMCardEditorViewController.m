//
//  HAMCardEditorViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCardEditorViewController.h"

@interface HAMCardEditorViewController ()

@property NSString *imagePath;
@property NSString *tempImagePath;

@end

@interface UIImagePickerController(NoRotation)
- (BOOL)shouldAutorotate;
@end

@implementation UIImagePickerController(NoRotation)

- (BOOL)shouldAutorotate {
	return NO;
}

@end

@implementation HAMCardEditorViewController

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
	
	// fit into the popover
	self.preferredContentSize = self.view.frame.size;
	
	// initialize the temporary card
	if (self.cardID) { // editing card
		self.tempCard = [self.config card:self.cardID];
	}
	else { // creating card
		self.tempCard = [[HAMCard alloc] initNewCard]; // get a UUID
		[self.config newCardWithID:self.tempCard.UUID name:nil type:1 audio:nil image:nil]; // type 1 indicates a card
		self.tempCard.type = 1; // this statement can be removed
		self.tempCard.isRemovable_ = YES;
	}
	
	self.imagePath = [NSString stringWithFormat:@"%@.jpg", self.tempCard.UUID];
	self.tempImagePath = [NSString stringWithFormat:@"%@-temp.jpg", self.tempCard.UUID];
	// update the view accordingly
	if (self.cardID) { // editing card
		// copy the existing image file to the temporary
		// FIXME: *elegant* error handling
		NSFileManager *manager = [NSFileManager defaultManager];
		[manager copyItemAtPath:[HAMFileTools filePath:self.imagePath] toPath:[HAMFileTools filePath:self.tempImagePath] error:nil];
		
		self.tempCard.image.localPath = self.tempImagePath; // point to the temporary file
		self.imageView.image = [UIImage imageWithContentsOfFile:[HAMFileTools filePath:self.tempCard.image.localPath]];
	}
	else { // new card
		// don't allow deletion when creating a card
		self.deleteCardButton.hidden = YES;
		// must specify card name and image before saving
		self.finishButton.enabled = NO;
		// must specify card name and image before recording
		self.recordButton.enabled = NO;
	}
	
	// detect if camera is available
	if (! [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		self.shootImageButton.enabled = NO;
	
	// this won't change in the lifetime of the current view
	self.categoryIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
	
	HAMCard *category = [self.config card:self.categoryID];
	self.categoryNameLabel.text = category.name;
	
	self.cardNameLabel.text = self.tempCard.name;
	
	// initialize the recorder
	self.recorder = [[HAMRecorderViewController alloc] initWithNibName:@"HAMRecorderViewController" bundle:nil];
	self.recorder.config = self.config;
	self.recorder.tempCard = self.tempCard;
	self.recorder.categoryID = self.categoryID;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.tempCard.name = nil;
	
	if (! self.cardID) { // creating card
		if (! [textField.text isEqualToString:@""]) {
			self.tempCard.name = textField.text;
		}
	}
	else { // editing card
		NSString *oldCardName = [self.config card:self.cardID].name;
		if ([textField.text isEqualToString:@""])
			textField.text = oldCardName;
		else if (! [textField.text isEqualToString:oldCardName]) {
			self.tempCard.name = textField.text;
		}
	}
	
	// update the card name if it's changed
	self.cardNameLabel.text = self.tempCard.name ? self.tempCard.name : self.cardNameLabel.text;
	
	// can save new card now
	self.finishButton.enabled = (self.tempCard.name && self.tempCard.image) ? YES : NO;
	self.recordButton.enabled = self.finishButton.enabled;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return  NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	// disable finish button while editing
	self.finishButton.enabled = NO;
}

- (IBAction)recordButtonTapped:(id)sender {
	self.recorder.popover = self.popover; // !!!
	[self.navigationController pushViewController:self.recorder animated:YES];
}

- (IBAction)shootImageButtonPressed:(id)sender {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	[self presentViewController:imagePicker animated:YES completion:NULL];
}

- (IBAction)pickImageButtonPressed:(id)sender {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	[self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	UIImage *tempImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	HAMImageCropperViewController *imageCropper = [[HAMImageCropperViewController alloc] initWithNibName:@"HAMImageCropperViewController" bundle:nil];
	imageCropper.image = tempImage;
	imageCropper.delegate = self;
	
	[picker pushViewController:imageCropper animated:YES];
}

- (void)imageCropper:(HAMImageCropperViewController *)imageCropper didFinishCroppingWithImage:(UIImage *)croppedImage {
	
	self.imageView.image = croppedImage; // update the displaying
	
	// save the image to a temporary file
	BOOL success = [UIImageJPEGRepresentation(croppedImage, 1.0) writeToFile:[HAMFileTools filePath:self.tempImagePath] atomically:YES];
	if (!success) { // something wrong
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法选取图片" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
		return; //cannot create new card
	}
	else {
		if (! self.tempCard.image)
			self.tempCard.image = [[HAMResource alloc] initWithPath:self.tempImagePath];
	}
	
	// can save new card now
	if (self.tempCard.name) {
		self.finishButton.enabled = YES;
		self.recordButton.enabled = YES;
	}
}

- (IBAction)cancelButtonTapped:(id)sender {
	if (! self.cardID) // cancel card creation
		[self.config deleteCard:self.tempCard.UUID];
	
	[self.popover dismissPopoverAnimated:YES];
}

- (IBAction)finishButtonTapped:(id)sender {
		
	NSFileManager *manager = [NSFileManager defaultManager];
	// copy and then delete the temporary image file
	BOOL success = YES;
	// must delete the original file before writing new data to it
	if ([manager fileExistsAtPath:[HAMFileTools filePath:self.imagePath]])
		success = success && [manager removeItemAtPath:[HAMFileTools filePath:self.imagePath] error:nil];
	success = success && [manager moveItemAtPath:[HAMFileTools filePath:self.tempImagePath] toPath:[HAMFileTools filePath:self.imagePath] error:nil];
	if (! success) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法保存图片" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	self.tempCard.image.localPath = self.imagePath;
	[self.config updateCard:self.tempCard name:self.tempCard.name audio:self.tempCard.audio.localPath image:self.tempCard.image.localPath];
	
	if (! self.cardID) { // if this is a new card, then insert it into a category
		NSInteger numChildren = [self.config childrenCardIDOfCat:self.categoryID].count;
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:self.tempCard.UUID animation:ROOM_ANIMATION_NONE];
		[self.config updateRoomOfCat:self.categoryID with:room atIndex:numChildren];
	}
	
	[self.popover dismissPopoverAnimated:YES];
	[self.delegate cardEditorDidEndEditing:self]; // inform the grid view to refresh
}

- (IBAction)chooseCategoryButtonPressed:(id)sender {
	UITableViewController *tableViewController = [[UITableViewController alloc] init];
	tableViewController.tableView.dataSource = self;
	tableViewController.tableView.delegate = self;
	[tableViewController.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableCell"];
	
	 self.popoverForCategories = [[UIPopoverController alloc] initWithContentViewController:tableViewController];
	[self.popoverForCategories presentPopoverFromRect:self.chooseCategoryButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.categoryIDs.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
	NSString *categoryID = self.categoryIDs[indexPath.row];
	HAMCard *category = [self.config card:categoryID];
	
	cell.textLabel.text = category.name;
	return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.categoryID = self.categoryIDs[indexPath.row];
	HAMCard *category = [self.config card:self.categoryID];
	self.categoryNameLabel.text = category.name;
}

- (IBAction)deleteCardButtonTapped:(id)sender {
	[self.config deleteCard:self.cardID];
	[self.popover dismissPopoverAnimated:YES];
	[self.delegate cardEditorDidEndEditing:self]; // inform the grid view to refresh
}

@end
