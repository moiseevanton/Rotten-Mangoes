//
//  Movie.h
//  Rotten Mangoes
//
//  Created by Anton Moiseev on 2016-05-23.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

@import UIKit;

@interface Movie : NSObject

@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) int year;
@property (strong, nonatomic) NSString *mpaaRating;
@property (assign, nonatomic) int runtime;
@property (strong, nonatomic) NSString *criticsConsensus;
@property (strong, nonatomic) NSDictionary *releaseDates;
@property (strong, nonatomic) NSDictionary *ratings;
@property (strong, nonatomic) NSString *synopsis;
@property (strong, nonatomic) NSDictionary *posters;
@property (strong, nonatomic) NSArray *abridgedCast;
@property (strong, nonatomic) NSDictionary *links;
@property (strong, nonatomic) UIImage *image;

@end
