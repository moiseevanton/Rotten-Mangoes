//
//  DetailViewController.m
//  Rotten Mangoes
//
//  Created by Anton Moiseev on 2016-05-23.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (strong, nonatomic) NSMutableArray *reviewsArray;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.reviewsArray = [NSMutableArray new];
    
    NSLog(@"%@", self.movie.links[@"reviews"]);
    
    NSString *stringURL = [self.movie.links[@"reviews"] stringByAppendingString:@"?apikey=h8ym7ry7kkur36j7ku482y9z"];
    NSLog(@"%@", stringURL);
    NSURL *reviewsURL = [NSURL URLWithString:stringURL];
    NSURLRequest *apiRequest = [NSURLRequest requestWithURL:reviewsURL];
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *apiTask = [sharedSession dataTaskWithRequest:apiRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"%@", data);
        
        if (!error) {
            NSError *jsonError;
            NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (!jsonError) {
                NSMutableArray *reviewsData = parsedData[@"reviews"];
                
                if (reviewsData.count >= 3) {
                    for (int i = 0; i < 3; i++) {
                        [self.reviewsArray addObject:reviewsData[i]];
                    }
                } else {
                    self.reviewsArray = reviewsData;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self configureView];
                });
            } else {
                NSLog(@"Error parsing JSON: %@", [jsonError localizedDescription]);
            }
        } else {
            NSLog(@"%@", [error localizedDescription]);
        }
        
    }];
    
    [apiTask resume];
    
//    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView {
    
    if (self.movie) {
        self.titleLabel.text = self.movie.title;
        self.yearLabel.text = [NSString stringWithFormat:@"Year: %d", self.movie.year];
        self.runtimeLabel.text = [NSString stringWithFormat:@"Runtime: %d min", self.movie.runtime];
        self.synopsisLabel.numberOfLines = 0;
        self.synopsisLabel.text = [NSString stringWithFormat:@"Synopsis:\n%@", self.movie.synopsis];
        self.reviewsLabel.numberOfLines = 0;
        NSMutableString *reviewsString = [NSMutableString new];
        int i = 1;
        for (NSDictionary *reviewDict in self.reviewsArray) {
            if (reviewDict[@"original_score"]) {
                [reviewsString appendString:[NSString stringWithFormat:@"Review #%d\n\nCritic:%@\nDate:%@\nOriginal Score:%@\nFreshness:%@\nPublication:%@\nQuote:%@\n\n\n", i, reviewDict[@"critic"], reviewDict[@"date"], reviewDict[@"original_score"], reviewDict[@"freshness"], reviewDict[@"publication"], reviewDict[@"quote"]]];
            } else {
              [reviewsString appendString:[NSString stringWithFormat:@"Review #%d\n\nCritic:%@\nDate:%@\nOriginal Score:no score\nFreshness:%@\nPublication:%@\nQuote:%@\n\n\n", i,reviewDict[@"critic"], reviewDict[@"date"], reviewDict[@"freshness"], reviewDict[@"publication"], reviewDict[@"quote"]]];
            }
            i ++;
        }
        self.reviewsLabel.text = reviewsString;
    }
    
}

@end
