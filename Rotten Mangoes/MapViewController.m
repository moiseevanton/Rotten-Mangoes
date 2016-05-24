//
//  MapViewController.m
//  Rotten Mangoes
//
//  Created by Anton Moiseev on 2016-05-24.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

#import "MapViewController.h"
@import MapKit;
@import CoreLocation;

@interface MapViewController () <CLLocationManagerDelegate,MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *myMapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL shouldZoomToUserLocation;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSArray *theatres;
- (void)downloadTheatresWithString:(NSString *)string;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myMapView.delegate = self;
    self.shouldZoomToUserLocation = YES;
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 10;
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationMangerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    } else if (status == kCLAuthorizationStatusDenied) {
        NSLog(@"User didn't let me use his/her location");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error getting location: %@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D userCoordinate = location.coordinate;
    NSLog(@"lat: %f lng: %f", userCoordinate.latitude, userCoordinate.longitude);
    
    if (self.shouldZoomToUserLocation) {
        MKCoordinateRegion userRegion = MKCoordinateRegionMake(userCoordinate, MKCoordinateSpanMake(0.005, 0.005));
        [self.myMapView setRegion:userRegion animated:YES];
        self.shouldZoomToUserLocation = NO;
    }
    self.myMapView.showsUserLocation = YES;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark = placemarks[0];
        self.postalCode = placemark.postalCode;
        NSLog(@"Reverse geocode: %@", placemark);
        NSLog(@"%@", self.postalCode);
        NSString *newPostalCode = [self.postalCode stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSString *newMovieTitle = [self.theMovie.title stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSString *stringURL = [@"http://lighthouse-movie-showtimes.herokuapp.com/theatres.json?" stringByAppendingFormat:@"address=%@&movie=%@", newPostalCode, newMovieTitle];
        [self downloadTheatresWithString:stringURL];
    }];
}

- (void)downloadTheatresWithString:(NSString *)string {
    // download the data (theatres)
    
    NSURL *theatresURL = [NSURL URLWithString:string];
    NSURLRequest *apiRequest = [NSURLRequest requestWithURL:theatresURL];
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *apiTask = [sharedSession dataTaskWithRequest:apiRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            NSError *jsonError;
            NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (!jsonError) {
                NSArray *theatresData = parsedData[@"theatres"];
                NSLog(@"%@", theatresData);
                
                NSMutableArray *theatresArray = [NSMutableArray new];
                for (NSDictionary *theatreDict in theatresData) {
                    Theatre *newTheatre = [Theatre new];
                    newTheatre.title = theatreDict[@"name"];
                    newTheatre.address = theatreDict[@"address"];
                    newTheatre.coordinate = CLLocationCoordinate2DMake([theatreDict[@"lat"] doubleValue], [theatreDict[@"lng"] doubleValue]);
                    
                    [theatresArray addObject:newTheatre];
                }
                
                self.theatres = theatresArray;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.myMapView addAnnotations:self.theatres];
                });

            }
        }
    }];
    [apiTask resume];
}

#pragma mark MKMapViewDelegate

// if I want to have custom pins ( couldn't find a nice movie pin image :[ )

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    
//    if (annotation == mapView.userLocation) {
//        return nil;
//    }
//    
//    MKAnnotationView *theatrePin = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Theatre"];
//    if (!theatrePin) {
//        theatrePin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Theatre"];
//        
//    }
//    return theatrePin;
//}

@end
