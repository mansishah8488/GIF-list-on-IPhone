//
//  GifViewController.h
//  GifImageDisplay
//
//  Created by Manasi Shah on 28/01/15.
//  Copyright (c) 2015 Manasi Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GifImageWebService.h"
#import "EGORefreshTableHeaderView.h"
#import "GifIMageModel.h"
#import "GifImageItemCell.h"

@interface GifViewController : UIViewController<UITextFieldDelegate,EGORefreshTableHeaderDelegate, UIScrollViewDelegate, UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray * arrayForGifImages;
    BOOL isLoadingPagination;
    BOOL isCommunicatingWithServer;
    NSInteger paginationOffset;
    NSInteger totalNoOfImages;
    NSInteger noOfImagesLoaded;
    BOOL isSearch;
        
    EGORefreshTableHeaderView *pullToRefreshTableView;
    BOOL reloadingTableView;
    
    GifImageWebService *gifImageWebService_obj;
}

//Search
@property (weak,nonatomic) IBOutlet UITextField *textFieldForSearch;
@property (nonatomic,weak) IBOutlet UIButton *buttonForSearch;
@property (assign, nonatomic) BOOL isSearch;


-(IBAction)fnForSearchButtonPressed:(id)sender;

//Pagination for table view
@property (assign, nonatomic) BOOL isLoadingPagination;
@property (assign, nonatomic) NSInteger paginationOffset;
@property (assign, nonatomic) NSInteger totalNoOfImages;
@property (assign, nonatomic) NSInteger noOfImagesLoaded;

//Pull to refresh table view
@property (strong, nonatomic) EGORefreshTableHeaderView *pullToRefreshTableView;
@property (assign, nonatomic) BOOL reloadingTableView;

@property (strong, nonatomic) NSMutableArray *arrayForGifImages;
@property (weak, nonatomic) IBOutlet UITableView *tableViewForGifImages;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView * activityIndicator;

//Server Communication
@property (assign, nonatomic) BOOL isCommunicatingWithServer;
- (void)completeServerContact:(NSMutableDictionary*)jsonResult;
- (void)serverContactFailedWithError:(NSError *)error;

@end
