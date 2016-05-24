//
//  Theatre.h
//  Rotten Mangoes
//
//  Created by Anton Moiseev on 2016-05-24.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface Theatre : NSObject <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *address;
@property (assign, nonatomic) CLLocationDistance distance;

@end
