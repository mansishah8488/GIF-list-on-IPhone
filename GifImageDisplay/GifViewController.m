//
//  GifViewController.m
//  GifImageDisplay
//
//  Created by Manasi Shah on 28/01/15.
//  Copyright (c) 2015 Manasi Shah. All rights reserved.
//

#import "GifViewController.h"

#define kDefault_Number_Of_Sections 1

// Base URL for searching Gif Images uisng GIPHY-API
#define GIPHY_API_SEARCH_URL @"http://api.giphy.com/v1/gifs/search"

// Base URL for displaying the trending Gifs
#define GIPHY_API_TRENDING_URL @"http://api.giphy.com/v1/gifs/trending"


#define API_KEY @"dc6zaTOxFJmzC"  //GIPGY-API public key available
#define IMAGE_LOAD_LIMIT 25;  // Image load limit


@interface GifViewController ()

@end

@implementation GifViewController

@synthesize arrayForGifImages,paginationOffset,isCommunicatingWithServer,isLoadingPagination,totalNoOfImages,reloadingTableView,pullToRefreshTableView,noOfImagesLoaded,isSearch;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        arrayForGifImages = [[NSMutableArray alloc] init];
        isLoadingPagination = NO;
        paginationOffset = 0;
        totalNoOfImages = 0;
        noOfImagesLoaded =0;
        isCommunicatingWithServer = NO;
        isSearch = NO;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Observing  in NoInternetConnection notification on receiving the notification from the GifImageWebservice class
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fnToStopActivityIndicator:) name:@"NoInternetConnection" object:nil];
    self.tableViewForGifImages.scrollsToTop = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    paginationOffset = 0;
    noOfImagesLoaded = 0;
    if (pullToRefreshTableView == nil)
    {
        pullToRefreshTableView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableViewForGifImages.bounds.size.height, self.view.frame.size.width, self.tableViewForGifImages.bounds.size.height)];
        pullToRefreshTableView.delegate = self;
        [self.tableViewForGifImages addSubview:pullToRefreshTableView];
    }
    
    [self fnToGetTrendingImages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action Methods
-(IBAction)fnForSearchButtonPressed:(id)sender
{
    [self.textFieldForSearch resignFirstResponder];
    if(self.textFieldForSearch.text.length == 0)
    {
        [self showAlertMessage:@"Please enter text to search" alertViewTitle:@"Error"];
    }else
    {
        if(arrayForGifImages.count >0)
        {
            [self scrollToTop];
        }
        
        isLoadingPagination =NO;
        paginationOffset = 0;
        noOfImagesLoaded = 0;
        [self fnToGetGifImages];
    }
}

#pragma mark - Custom methods

-(void) showAlertMessage:(NSString *)errMsg alertViewTitle:(NSString *)tiltle
{
    
    UIAlertView *errorAlertView=[[UIAlertView alloc]initWithTitle:tiltle message:errMsg  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [errorAlertView show];
}


#pragma mark - UITextField Delegate Methods
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if(self.textFieldForSearch.text.length == 0)
    {
        [self showAlertMessage:@"Please enter text to search" alertViewTitle:@"Error"];
    }else
    {
        if(arrayForGifImages.count >0)
        {
            [self scrollToTop];
        }
        
        isLoadingPagination =NO;
        paginationOffset = 0;
        noOfImagesLoaded = 0;
        [self fnToGetGifImages];
    }
    [theTextField resignFirstResponder];
    return YES;
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    self.reloadingTableView = YES;
}

- (void)doneLoadingTableViewData
{
    //  model should call this when its done loading
    self.reloadingTableView = NO;
    [pullToRefreshTableView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableViewForGifImages];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullToRefreshTableView egoRefreshScrollViewDidScroll:scrollView];
}

/*Function to implement the Load more Gif images functionality
 It checks is the scrollView did end dragging
*/
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullToRefreshTableView egoRefreshScrollViewDidEndDragging:scrollView];
    
    // UITableView only moves in one direction, y axis
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    // Change 10.0 to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 10.0)
    {
        NSInteger totalNoOfAvailableImages = totalNoOfImages - noOfImagesLoaded;
        paginationOffset++;
        if(totalNoOfAvailableImages > [arrayForGifImages count])
        {
            if(isLoadingPagination == NO)
            {
                NSLog(@"Load more");
                
                if(arrayForGifImages.count > 0)
                {
                    isLoadingPagination = YES;
                    [self performSelector:@selector(fnToGetGifImages) withObject:nil afterDelay:0.1];
                }
            }
            else
            {
                NSLog(@"Loading more feeds in progress");
            }
        }
        else
        {
            NSLog(@"No more feeds");
        }
    }
}

#pragma mark - EGORefreshTableHeaderDelegate Methods 
//Function to handle pull to Refresh functionality
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    if(isCommunicatingWithServer == NO)
    {
        paginationOffset = 0;
        noOfImagesLoaded = 0;
        isLoadingPagination = NO;
        self.textFieldForSearch.text = @"";
        [self.textFieldForSearch resignFirstResponder];
        [self performSelector:@selector(fnToGetTrendingImages) withObject:nil afterDelay:0.1];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return self.reloadingTableView; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date]; // should return date data source was last changed
}

#pragma mark - UITableView DataSource & Delegate Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kDefault_Number_Of_Sections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayForGifImages.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    //Setting the height of the cell dynamically based on the height of the gifImage
    GifIMageModel *gifImageItem = [arrayForGifImages objectAtIndex:indexPath.row];
    height = [gifImageItem.height integerValue] + 10;
    
    return  height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        
        static NSString *CellIdentifier = @"GifImageItemCellIdentifier";
        GifImageItemCell *cell = (GifImageItemCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        GifIMageModel *gifImageItem = [arrayForGifImages objectAtIndex:indexPath.row];
        if (cell == nil)
        {
            cell=[[GifImageItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"GifImageItemCell" owner:self options:nil];
            cell = [xib objectAtIndex:0];
            cell.currentImageObject = gifImageItem;
            
            
        }
        
        cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x,cell.imageView.frame.origin.y,cell.imageView.frame.size.width,[gifImageItem.height integerValue]);
        
        cell.view.frame = CGRectMake(cell.view.frame.origin.x ,cell.view.frame.origin.y,cell.view.frame.size.width,[gifImageItem.height integerValue]);
        
        if(gifImageItem.fixed_width_url != nil && ![gifImageItem.fixed_width_url isEqualToString:@""])
        {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:gifImageItem.fixed_width_url]];
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
                    cell.imageView.animatedImage = animatedImage;
                }];
            }] resume];
        }
 
        return cell;
    }
    @catch (NSException *exception) {
        [self showAlertMessage:@"Something went wrong! Please try again later" alertViewTitle:@"Error"];
    }
    @finally {
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row selected");
    [self.textFieldForSearch resignFirstResponder];
}

//Function for scrolling the tableview to top
-(void) scrollToTop
{
    if ([self numberOfSectionsInTableView:self.tableViewForGifImages] > 0)
    {
        NSIndexPath* top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
        [self.tableViewForGifImages scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}



#pragma mark - Server Communication

//Function to stop activity indicator on no internet connection notification
-(void) fnToStopActivityIndicator:(NSNotification *) notification
{
    [self.textFieldForSearch resignFirstResponder];
     self.textFieldForSearch.text = @"";
    [self HideActivityIndicator];
}

//Function to hide activity Indicator
-(void)HideActivityIndicator
{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden=YES;
}

//Function to Show activityIndicator
-(void)ShowActivityIndicator
{
    self.activityIndicator.hidden=NO;
    [self.activityIndicator startAnimating];
}

//Function handle server contact failure
- (void)serverContactFailedWithError:(NSError *)error
{
    isCommunicatingWithServer = NO;
    
    [self.activityIndicator stopAnimating];
}

//Function to get Trending Images initially

- (void) fnToGetTrendingImages{
    
    
    if(isCommunicatingWithServer == NO)
    {
        paginationOffset =0;
        noOfImagesLoaded =0;
        isLoadingPagination=NO;
        isSearch = NO;
        
        isCommunicatingWithServer = YES;
        [self ShowActivityIndicator];
        
        if (gifImageWebService_obj == nil) {
            gifImageWebService_obj = [[GifImageWebService alloc] init:self];
        }
        
        isCommunicatingWithServer = YES;
        
        [gifImageWebService_obj connectToServer:GIPHY_API_TRENDING_URL andQueryString: @"" andKeyString:API_KEY limit:0 offset:0 isSearch:NO];
        
    }
}

//Function to fetch gif images for a particular search query
- (void) fnToGetGifImages{
    
    if(isCommunicatingWithServer == NO)
    {
        isSearch = YES;
        isCommunicatingWithServer = YES;
        [self ShowActivityIndicator];
        
        if (gifImageWebService_obj == nil) {
            gifImageWebService_obj = [[GifImageWebService alloc] init:self];
        }
        
        NSString *queryString = self.textFieldForSearch.text;
        
        //Tokenising the query string to check for whitespaces
        NSArray *arrayOfSearchTokens = [queryString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        queryString = @"";
        if(arrayOfSearchTokens.count >1)
        {
            for (int i=0; i<arrayOfSearchTokens.count; i++) {
                if(i==arrayOfSearchTokens.count - 1)
                {
                    queryString = [queryString stringByAppendingString:[arrayOfSearchTokens objectAtIndex:i]];
                }else
                {
                    queryString = [[queryString stringByAppendingString:[arrayOfSearchTokens objectAtIndex:i]] stringByAppendingString:@"+"];
                }
            }
        }else{
            queryString = self.textFieldForSearch.text;
        }
        
        isCommunicatingWithServer = YES;
        
        NSInteger limit = IMAGE_LOAD_LIMIT;
        NSInteger offset = paginationOffset;
        
        [gifImageWebService_obj connectToServer:GIPHY_API_SEARCH_URL andQueryString: queryString andKeyString:API_KEY limit: limit offset:offset isSearch:YES];
        
    }
}

//Function to handle the JSON result retrieved using GET method
- (void)completeServerContact:(NSMutableDictionary*)jsonResult
{
    [self.activityIndicator stopAnimating];
    isCommunicatingWithServer = NO;
    
    @try {
        if(jsonResult)
        {
            //JSON parsing and creation of model object
            
            //NSLog(@"JSON Result: %@", jsonResult);
            
            NSDictionary * metaDictionary = [[NSDictionary alloc] init];
            metaDictionary = [jsonResult objectForKey:@"meta"];
            
            if([[metaDictionary objectForKey:@"status"] integerValue] == 200 && [[metaDictionary objectForKey:@"msg"] isEqualToString:@"OK"])
            {
                NSArray *imagesArray = (NSArray *)[jsonResult objectForKey:@"data"];
                if(imagesArray.count >0)
                {
                    NSDictionary * paginationDictionary = [[NSDictionary alloc] init];
                    paginationDictionary = [jsonResult objectForKey:@"pagination"];
                    totalNoOfImages = [[paginationDictionary objectForKey:@"total_count"] integerValue];
                    noOfImagesLoaded = noOfImagesLoaded + IMAGE_LOAD_LIMIT;
                    paginationOffset = [[paginationDictionary objectForKey:@"offset"] integerValue];
                    
                    if(isSearch == YES)
                    {
                        noOfImagesLoaded = noOfImagesLoaded + IMAGE_LOAD_LIMIT;
                        isSearch = NO;
                    }
                    
                    if(isLoadingPagination == NO)
                    {
                        [arrayForGifImages removeAllObjects];
                    }
                    isLoadingPagination = NO;
                    for(NSDictionary *dictionary in imagesArray)
                    {
                        //NSLog(@"URL: %@",[[[dictionary objectForKey:@"images"] objectForKey:@"fixed_width"] objectForKey:@"url"]);
                        
                        //Constructing the GifImageModel using the json data
                        GifIMageModel *gifImageItemDictionary = [[GifIMageModel alloc] initWithURL:[[[dictionary objectForKey:@"images"] objectForKey:@"fixed_width"] valueForKey:@"url"] height:[[[dictionary objectForKey:@"images"] objectForKey:@"fixed_width"] valueForKey:@"height"]];
                        [arrayForGifImages addObject:gifImageItemDictionary];
                    }
                    [self.tableViewForGifImages reloadData];
                    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.1];
                    
                }else
                {
                    [self showAlertMessage:[NSString stringWithFormat:@"0 GIFs found for %@",self.textFieldForSearch.text] alertViewTitle:@"Error"];
                }
                //Checking for no data found error when the url is bad
            }else if([[metaDictionary objectForKey:@"status"] integerValue] == 404)
            {
                [self showAlertMessage:@"No data found" alertViewTitle:@"Error"];
            }else if([[metaDictionary objectForKey:@"status"] integerValue] == 403)
            {
                [self showAlertMessage:@"Invalid search query!" alertViewTitle:@"Error"];
            }else
                [self showAlertMessage:@"Something went wrong! Please try again later" alertViewTitle:@"Error"];
        }
    }
    @catch (NSException *exception) {
        [self showAlertMessage:@"Something went wrong! Please try again later" alertViewTitle:@"Error"];
    }
    @finally {
        
    }
}

@end
