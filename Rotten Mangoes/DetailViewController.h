//
//  DetailViewController.h
//  Rotten Mangoes
//
//  Created by Anton Moiseev on 2016-05-23.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

@interface DetailViewController : UIViewController

@property Movie *movie;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *runtimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewsLabel;

@end
