//
//  BuildTourStopsViewController.m
//  Tours
//
//  Created by Mark Porcella on 6/14/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import "BuildTourStopsViewController.h"

@interface BuildTourStopsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *stops;

@end

@implementation BuildTourStopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];


}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    return cell;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.stops count];
}

@end
