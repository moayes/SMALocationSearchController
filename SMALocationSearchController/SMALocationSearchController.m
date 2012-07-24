//
//  SMALocationSearchController.m
//  SMALocationSearchController
//
//  Created by Soheil M. Azarpour on 7/23/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
// 


#import "SMALocationSearchController.h"
#import <AFNetworking/AFNetworking.h>
#import "StringHelper.h"
#import "JSONKit.h"


@interface SMALocationSearchController ()
@property (nonatomic, assign) IBOutlet UISearchBar *locationSearchBar;
@property (nonatomic, retain) NSMutableArray *suggestions;
@property (assign) BOOL dirty;
@property (assign) BOOL loading;
- (void)loadSearchSuggestions;
@end


@implementation SMALocationSearchController
@synthesize locationSearchBar = _locationSearchBar;
@synthesize delegate = _delegate;
@synthesize suggestions = _suggestions;
@synthesize dirty = _dirty;
@synthesize loading = _loading;


#pragma mark -
#pragma mark - Life cycle


- (void)dealloc {
    [_suggestions release];
    [super dealloc];
}


- (void)viewDidLoad {
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)] autorelease];
    
    self.title = NSLocalizedString(@"Search a location", @"Search a location");
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated {
    if (!self.suggestions.count) {
        [self.locationSearchBar becomeFirstResponder];
    }
    [super viewDidAppear:animated];
}


- (void)viewDidUnload {
    [self setSuggestions:nil];
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate controllerDismissed:self];
    }];
}


#pragma mark -
#pragma mark - 


- (void) loadSearchSuggestions {
	
    self.loading = YES;
	NSString* query = self.searchDisplayController.searchBar.text;
    // You could limit the search to a region (e.g. a country) by appending more text to the query
	// example: query = [NSString stringWithFormat:@"%@, Spain", text];
	NSString *urlEncode = [query urlEncode];
	NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&hl=%@&oe=UTF8", urlEncode, [[NSLocale currentLocale] localeIdentifier]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray* sug = [[NSMutableArray alloc] init];
        
        NSArray* placemarks = [JSON objectForKey:@"Placemark"];
        
        for (NSDictionary* placemark in placemarks) {
            NSString* address = [placemark objectForKey:@"address"];
            
            NSDictionary* point = [placemark objectForKey:@"Point"];
            NSArray* coordinates = [point objectForKey:@"coordinates"];
            NSNumber* lon = [coordinates objectAtIndex:0];
            NSNumber* lat = [coordinates objectAtIndex:1];
            
            MKPointAnnotation* place = [[MKPointAnnotation alloc] init];
            place.title = address;
            CLLocationCoordinate2D c = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
            place.coordinate = c;
            [sug addObject:place];
            [place release];
        }
        
        self.suggestions = sug;
        [sug release];
        
        [self.searchDisplayController.searchResultsTableView reloadData];
        self.loading = NO;
        
        if (self.dirty) {
            self.dirty = NO;
            [self loadSearchSuggestions];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        self.loading = NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }];
    [operation start];  
}


#pragma mark -
#pragma mark - UISearchBar delegate


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if ([searchText length] > 2) {
		if (self.loading) {
			self.dirty = YES;
		} 
        else {
			[self loadSearchSuggestions];
		}
	}
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	return NO;
}


#pragma mark -
#pragma mark - UITableView methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.suggestions.count;
}


- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *kCellIdentifier = @"Cell Identifier";
	UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:kCellIdentifier];
	
    if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.font = [UIFont systemFontOfSize:13.0];
		cell.textLabel.numberOfLines = 0;
	}
	
	MKPointAnnotation *suggestion = [self.suggestions objectAtIndex:indexPath.row];
	cell.textLabel.text = suggestion.title;
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [self.searchDisplayController setActive:NO animated:YES];
	MKPointAnnotation *suggestion = [self.suggestions objectAtIndex:indexPath.row];
    [self.delegate controller:self didFinishWithLocation:suggestion];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate controllerDismissed:self];
    }];
}


@end
