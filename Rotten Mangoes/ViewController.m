//
//  ViewController.m
//  Rotten Mangoes
//
//  Created by Anton Moiseev on 2016-05-23.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

#import "ViewController.h"
#import "Movie.h"
#import "CustomCell.h"
#import "DetailViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSArray *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    NSURL *rottenTomatoesURL = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apikey=h8ym7ry7kkur36j7ku482y9z&page_limit=50"];
    NSURLRequest *apiRequest = [NSURLRequest requestWithURL:rottenTomatoesURL];
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *apiTask = [sharedSession dataTaskWithRequest:apiRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            NSError *jsonError;
            NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (!jsonError) {
                NSArray *moviesData = parsedData[@"movies"];
            
                NSMutableArray *moviesArray = [NSMutableArray new];
            
                for (NSDictionary *movieDict in moviesData) {
                    Movie *newMovie = [Movie new];
                    newMovie.title = movieDict[@"title"];
                    newMovie.year = [movieDict[@"year"] intValue];
                    newMovie.mpaaRating = movieDict[@"mpaa_rating"];
                    newMovie.runtime = [movieDict[@"runtime"] intValue];
                    newMovie.criticsConsensus = movieDict[@"critics_consensus"];
                    newMovie.releaseDates = movieDict[@"release_dates"];
                    newMovie.ratings = movieDict[@"ratings"];
                    newMovie.synopsis = movieDict[@"synopsis"];
                    newMovie.posters = movieDict[@"posters"];
                    newMovie.abridgedCast = movieDict[@"abridged_cast"];
                    newMovie.links = movieDict[@"links"];
                
                    [moviesArray addObject:newMovie];
                }
            
                self.data = moviesArray;
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            } else {
                NSLog(@"Error parsing JSON: %@", [jsonError localizedDescription]);
            }
        } else {
            NSLog(@"%@", [error localizedDescription]);
        }
        
    }];
    
    [apiTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ourCell" forIndexPath:indexPath];
    
    Movie *movie = self.data[indexPath.item];
    if (!movie.image) {
        NSData *theData = [NSData dataWithContentsOfURL: [NSURL URLWithString:movie.posters[@"detailed"]]];
        UIImage *poster = [UIImage imageWithData:theData];
        movie.image = poster;
    }
    
    cell.title.numberOfLines = 0;
    cell.title.adjustsFontSizeToFitWidth = YES;
    cell.title.text = movie.title;
    [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    cell.imageView.image = movie.image;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showDetails"]) {
        NSArray *array = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = array[0];
        DetailViewController *dvc = segue.destinationViewController;
        dvc.movie = self.data[indexPath.item];
        
    }
    
}

@end
