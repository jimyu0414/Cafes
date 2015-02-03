//
//  ViewController.m
//  Cafes
//
//  Created by yu on 30/01/2015.
//  Copyright (c) 2015 yu. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
{
    CLLocationManager *lcManager;
}
@end

@implementation ViewController
@synthesize coordinate;
@synthesize boundingMapRect;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.receivedData =[[NSMutableData alloc] init];
    self.venuesNear = [[NSMutableArray alloc] init];
    self.venuesFar = [[NSMutableArray alloc] init];
    //set button tag
    self.slideDownBtn.tag = 1;
    
    //get current location and its lat and lng
    [self updateCurrentLocation];
}


- (void)updateCurrentLocation {
    
    lcManager = [[CLLocationManager alloc] init];
    lcManager.delegate = self;
    lcManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([lcManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [lcManager requestWhenInUseAuthorization];
    }
    [lcManager startUpdatingLocation];
}


-(void)loadData
{
    NSString *searchAddress =[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=%@&client_secret=%@&v=20130815&ll=%@,%@&query=cafe",@"ACAO2JPKM1MXHQJCK45IIFKRFR2ZVL0QASMCBCG5NPJQWF2G",@"YZCKUYJ1WHUV2QICBXUBEILZI1DMPUIDP5SHV043O04FKBHL",self.latitude,self.longitude];
    NSURL *url = [NSURL URLWithString:searchAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

//here is for the connection protocol methods

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",[error description]);

}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //as it may receive response multiple times this is the little tick to handle the received data
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{

    //get all the json file
    NSDictionary *mainDictionary =[NSJSONSerialization JSONObjectWithData:self.receivedData options:NSJSONReadingMutableLeaves error:nil];
 /*
 // -----This block is for checking the json structure-----
    //Numbers of mainDictionary
    int count = [mainDictionary count];
    NSLog(@"Numbers of dictionaries： %d",count);
    
    //KEYs
    NSEnumerator * enumeratorKey = [mainDictionary keyEnumerator];
    
    for (NSObject *object in enumeratorKey) {
        NSLog(@"KEYs: %@",object);
    }
    
    //Values
    NSEnumerator * enumeratorValue = [mainDictionary objectEnumerator];
    
    for (NSObject *object in enumeratorValue) {
        NSLog(@"All values: %@",object);
    }
  */
    
    // get into reponses
    NSDictionary *responses = [mainDictionary objectForKey:@"response"];
    
    //get all venues from response
    NSArray *venues = [responses objectForKey:@"venues"];
     NSLog(@"Numbers of venues：%lu",(unsigned long)[venues count]);
    
    
    //extract venue info
    NSMutableArray *arrayForCollectingVenues = [[NSMutableArray alloc] init];
    for (NSDictionary *venue in venues) {
        Venue *anInstantVenue = [[Venue alloc] init];
        NSDictionary *contact = [venue objectForKey:@"contact"];
        NSDictionary *location = [venue objectForKey:@"location"];
        NSArray *addresses = [location objectForKey:@"formattedAddress"];
        NSString *joinedAddressString = [addresses componentsJoinedByString:@"\n"];

            anInstantVenue.venueID = [venue objectForKey:@"id"];
            anInstantVenue.name = [venue objectForKey:@"name"];
            anInstantVenue.contact = [contact objectForKey:@"formattedPhone"];
            anInstantVenue.lat = [location objectForKey:@"lat"];
            anInstantVenue.lng = [location objectForKey:@"lng"];
            anInstantVenue.distance = [location objectForKey:@"distance"];
            anInstantVenue.address = joinedAddressString;
            [arrayForCollectingVenues addObject:anInstantVenue];
    }
    
    //sort array
    [arrayForCollectingVenues sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]]];
    
    
    //making two arrays
    for (Venue *aVenue in arrayForCollectingVenues) {
        if ([aVenue.distance intValue] <= 1000) {
            [self.venuesNear addObject:aVenue];
           // NSLog(@"latutide is: %@",aVenue.lat);
           // NSLog(@"longtitude is: %@",aVenue.lng);
        }
        else
        {
            [self.venuesFar addObject:aVenue];
           // NSLog(@"long one is : %@",aVenue.distance);
        }
    }

    
    //as the data loading process running asynchronously so after the connection closed table view has to reload;
    [self.tableView reloadData];
    
    
}


//here are the location manager protocol methods
-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"Did updated to location: %@",newLocation);
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        self.longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        self.latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    NSLog(@"%@,%@",[self.latitude substringWithRange:NSMakeRange(0, 5)],[self.longitude substringWithRange:NSMakeRange(0, 5)]);
        [lcManager stopUpdatingLocation];
    [self loadData];
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location Dected fail with error: %@",error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Location Error" message:@"Failed to get current location, check Location Service on iphone setting and restart app please" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [errorAlert show];
}

//here are the tableView protocol methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    switch (section) {
            
        case 0:
            
            return @"Shops within 1km";
            
        case 1:
            
            return @"Shops bit far";
            
        default:
            
            return @"Unknown";
            
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.venuesNear count];
        //[[self.locmanager.monitoredRegions allObjects] count];
    }
    else{
        return [self.venuesFar count];
    }

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    [cell.detailTextLabel setNumberOfLines:4];
    
    if (indexPath.section == 0) {
        Venue *venueNear = [self.venuesNear objectAtIndex:indexPath.row];
        cell.textLabel.text = venueNear.name;
        NSString *str=[[NSString alloc] initWithFormat:@"Distance: %@ %@", venueNear.distance,@"m"];
        NSString *newStr = [[NSString alloc] initWithFormat:@"%@ \n%@",str,venueNear.address];
        [cell.detailTextLabel setText:newStr];
        [cell.imageView setImage:[UIImage imageNamed:@"coffeelogo.png"]];
    }
    else{
        Venue *venueFar = [self.venuesFar objectAtIndex:indexPath.row];
        NSString *str=[[NSString alloc] initWithFormat:@"Distance: %@ %@", venueFar.distance,@"m"];
        NSString *newStr = [[NSString alloc] initWithFormat:@"%@ \n%@",str,venueFar.address];
        cell.textLabel.text = venueFar.name;
        cell.detailTextLabel.text = newStr;
    }
    return cell;
}

//to change the row height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//basic animation control
- (IBAction)slideDown:(id)sender {
    if (self.slideDownBtn.tag == 1) {
        //slide down the table view
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionTransitionCurlUp
                         animations:^{
                             self.tableView.frame = CGRectMake(0, 480, 320, 290);
                         } completion:^(BOOL finished) {
                             //create a map view
                             MKMapView * map = [[MKMapView alloc] initWithFrame:
                                                
                                                CGRectMake(0, 0, 320, 480)];
                             map.delegate = self;
                             [self.view insertSubview:map belowSubview:self.tableView];
                             
                             //show uer's current location
                             [map setShowsUserLocation:YES];
                             //get coords
                             CLLocation *userlocation = [lcManager location];
                             CLLocationCoordinate2D mylocation = [userlocation coordinate];
                             //define a zoom region
                             MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mylocation, 2500, 2500);
                             // show our location
                             [map setRegion:region animated:NO];
                             
                             //add a circle for 1 km
                             //CLLocationDistance fenceDistance = 1000;
                             MKCircle *circle = [MKCircle circleWithCenterCoordinate:region.center radius:1000];
                             [map addOverlay:circle];
                             //go through 2 loops and drop pins
                             for (Venue *venue in self.venuesNear) {
                                 MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                                 CLLocation *loc = [[CLLocation alloc] initWithLatitude:[venue.lat floatValue] longitude:[venue.lng floatValue]];
                                 [annotation setCoordinate:loc.coordinate];
                                 [annotation setTitle:venue.name];
                                 [annotation setSubtitle:venue.address];
                                 [map addAnnotation:annotation];
                             }
                             for (Venue *venuefar in self.venuesFar) {
                                 MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                                   CLLocation *loc = [[CLLocation alloc] initWithLatitude:[venuefar.lat floatValue] longitude:[venuefar.lng floatValue]];
                                 [annotation setCoordinate:loc.coordinate];
                                 [annotation setTitle:venuefar.name];
                                 [annotation setSubtitle:venuefar.contact];
                                 [map addAnnotation:annotation];
                             }
                             //change button tag and interface
                             [self.slideDownBtn setImage:[UIImage imageNamed:@"arrowup.png"] forState:UIControlStateNormal];
                             self.slideDownBtn.tag =2;
                         }];
    }
    else
    {
        //slide up the table view
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionTransitionCurlUp
                         animations:^{
                             self.tableView.frame = CGRectMake(0, 71, 320, 509);
                         } completion:^(BOOL finished) {
                             //change button function and interface
                             [self.slideDownBtn setImage:[UIImage imageNamed:@"arrowdown.png"] forState:UIControlStateNormal];
                             self.slideDownBtn.tag = 1;
                         }];
    }
   
}

//custom set up call out view for annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    annotationView.canShowCallout = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(5.0, 5.0, 40.0, 40.0);
    [button setImage:[UIImage imageNamed:@"phonelogo.png"] forState:UIControlStateNormal];
//    NSString *str = annotation.subtitle;
//    //trim the string
//    str = [str substringWithRange:NSMakeRange(1, str.length-1)];
    
    
    annotationView.rightCalloutAccessoryView = button;
    
    return annotationView;
    
}
//once the callout view tapped this method will get called
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSString *phoneNumber = view.annotation.subtitle;
    phoneNumber = [phoneNumber substringWithRange:NSMakeRange(1,phoneNumber.length-1)];
    NSString *st = [NSString stringWithFormat:@"tel:%@",phoneNumber];
    NSString *callNumber = [st stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callNumber]];
}


//implement the viewForOverlay delegate method...
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay] ;
    [circleView setFillColor:[UIColor lightGrayColor]];
    circleView.strokeColor = [UIColor redColor];
    circleView.lineWidth = 2;
    [circleView setAlpha:0.5];
    return circleView;
}

@end
