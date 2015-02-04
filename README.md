# Cafes
- Better test this app by Xcode and run on the real device
- Written with Object-c .
- Get user’s current Latitude and longitude via CLLocationManager
- Send HTTP request  with current-location for FourSquare API and parse the json file asynchronously.
- Basic interfaces 
e.g 
IUTableView : to show the shops near user’s current location.
 MapView : graphically show user’s locations and shops nenear by.

———————Extra Features———---

ability to call coffee shop

————things to need to be refined next version———
* Code structure needs to be improved such as adding more isolation functions for better testing.
* Call out MKAnnotationView can be customised to show the shops pictures as FourSquare API do  provide the image links for some shops
* validate the phone number 
* use shared Application to pass the address and open Apple/Google map for navigation

————Key functions—————

//get current location
- (void)updateCurrentLocation

//connect Foursquare API to get data

- (void)loadData

//Parse data and save into 2 arrays with “Venue” type

- (void)connectionDidFinishLoading:(NSURLConnection *)connection

//sort main array

- [arrayForCollectingVenues sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]]];

//Button slider to slide table view down and up and create map view and associated views programatically

- (IBAction)slideDown:(id)sender


--------Screen Shots--------

![Alt text](https://cloud.githubusercontent.com/assets/7435852/6040283/18e65d74-acc4-11e4-9755-be5baa136404.jpg "Optional title")

![Alt text](https://cloud.githubusercontent.com/assets/7435852/6040282/18300b78-acc4-11e4-949a-17b86e9d715a.jpg "Optional title")
