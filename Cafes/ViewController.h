//
//  ViewController.h
//  Cafes
//
//  Created by yu on 30/01/2015.
//  Copyright (c) 2015 yu. All rights reserved.
//
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Venue.h"

@interface ViewController : UIViewController<NSURLConnectionDelegate,NSURLConnectionDataDelegate,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate,MKOverlay>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

//data received from the response
@property NSMutableData *receivedData;

//for passing the lat and lng value to the api to find shops nearby
@property NSString *latitude;
@property NSString *longitude;

//two arrays for the table view for each section
@property NSMutableArray *venuesNear;
@property NSMutableArray *venuesFar;
//to slide down the table view
- (IBAction)slideDown:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *slideDownBtn;
@end

