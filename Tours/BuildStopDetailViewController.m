
#import <MapKit/MapKit.h>
#import "BuildStopDetailViewController.h"
#import "StopPhotoCollectionViewCell.h"
#import "BuildStopLocationViewController.h"
#import "BuildStopPhotosViewController.h"
#import "Photo.h"
#import "Stop.h"
#import "StopPointAnnotation.h"

static NSString *reuseIdentifier = @"PhotoCell";

@interface BuildStopDetailViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property UIImageView *imageView;
@property UIView *blackView;
@property UIButton *setLocationButton;
@property UIButton *addLocationButton;
@property NSArray *photos;

@property BOOL didSetupSetLocationButton;

@end

@implementation BuildStopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setInitialCollectionViewLayout];

    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButtonPressed)];

    self.navigationItem.rightBarButtonItem = cancelBarButton;


    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;

    [self.titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];

    // change to designables:
    self.summaryTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.summaryTextView.layer.borderWidth = 0.5;
    self.summaryTextView.layer.cornerRadius = 7;
}

- (void)viewWillAppear:(BOOL)animated {

    [self updateViews];
    [self checkIfLocationSetAndEnableSaveButton];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];


}

-(void) checkIfLocationSetAndEnableSaveButton {
    if (!self.stop.location) {

        self.navigationItem.leftBarButtonItem.enabled = NO;
        [self.navigationItem.leftBarButtonItem setTitle:@"Set Location to Save"];
        [self setupAddLocationButton];
    } else {

        if (!self.didSetupSetLocationButton) {

            [self setupSetLocationButton];
            self.didSetupSetLocationButton = YES;
        }
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [self.navigationItem.leftBarButtonItem setTitle:@"Save Stop"];
        [self placeAnnotationViewOnMapForStopLocation];
    }


}

- (void)setupAddLocationButton {

    CGSize addLocationButtonSize = self.mapView.bounds.size;
    self.addLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, addLocationButtonSize.width, addLocationButtonSize.height)];
    [self.addLocationButton setTitle:@"Set Location" forState:UIControlStateNormal];
    [self.addLocationButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:.5]];

    [self.addLocationButton addTarget:self action:@selector(performSetLocationSegue:) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.addLocationButton];
}


- (void)setupSetLocationButton {

    CGFloat setLocationButtonWidth = self.view.layer.bounds.size.width / 5;
    NSLog(@"%f, %f", self.mapView.viewForBaselineLayout.bounds.size.width, self.mapView.viewForBaselineLayout.bounds.size.height);

    CGFloat setLocationButtonHeight = CGRectGetMaxY(self.mapView.frame) - CGRectGetMinY(self.mapView.frame);

    self.setLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.layer.bounds.size.width - setLocationButtonWidth, self.mapView.bounds.origin.y, setLocationButtonWidth, setLocationButtonHeight)];
    [self.setLocationButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:.5]];
    self.setLocationButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.setLocationButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.setLocationButton setTitle:@"Edit\nLocation" forState:UIControlStateNormal];

    [self.setLocationButton addTarget:self action:@selector(performSetLocationSegue:) forControlEvents:UIControlEventTouchUpInside];

    [self.mapView addSubview:self.setLocationButton];
}

- (void)performSetLocationSegue:(UIButton *)sender {

    if (sender == self.addLocationButton) {
        [self.addLocationButton removeFromSuperview];
    }
    [self performSegueWithIdentifier:@"setLocation" sender:self];
}

- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender {

    self.navigationItem.leftBarButtonItem.enabled = NO;

    [self.stop saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (IBAction)onCancelButtonPressed {


    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"setLocation"]) {

        BuildStopLocationViewController *destinationVC = (BuildStopLocationViewController *)[segue.destinationViewController topViewController];
        destinationVC.stop = self.stop;
    }
    else if ([segue.identifier isEqualToString:@"editPhotos"]) {

        BuildStopPhotosViewController *destinationVC = (BuildStopPhotosViewController *)[segue.destinationViewController topViewController];
        destinationVC.stop = self.stop;
    }
}

- (void)textFieldDidChange:(UITextField *)sender {
    self.stop.title = [sender text];
}

- (void)textViewDidChange:(UITextView *)sender {
    self.stop.summary = [sender text];
}


- (void)updateViews {

    self.titleTextField.text = self.stop.title;
    self.summaryTextView.text = self.stop.summary;

    PFQuery *query = [Photo query];
    [query whereKey:@"stop" equalTo:self.stop];
    [query orderByAscending:@"order"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {

        self.photos = photos;
        [self.collectionView reloadData];
    }];
}


- (void)placeAnnotationViewOnMapForStopLocation {

    [self.mapView removeAnnotations:self.mapView.annotations];

    CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:self.stop.location.latitude longitude:self.stop.location.longitude];
    StopPointAnnotation *stopAnnotation = [[StopPointAnnotation alloc] initWithLocation:stopLocation forStop:self.stop];

    stopAnnotation.title = @" ";

    [self.mapView addAnnotation:stopAnnotation];
    [self zoomToRegionAroundAnnotation];
}


- (void)zoomToRegionAroundAnnotation {

    CLLocationCoordinate2D stopCLLocationCoordinate2D = CLLocationCoordinate2DMake(self.stop.location.latitude + 0.002, self.stop.location.longitude);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(stopCLLocationCoordinate2D, 10000, 10000);
    [self.mapView setRegion:coordinateRegion animated:NO];
}


- (void)setInitialCollectionViewLayout {

    [self.collectionView registerClass:[StopPhotoCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    self.collectionView.layer.borderWidth = 1.0;
    CGFloat collectionWidth = self.collectionView.layer.bounds.size.height; //(self.view.bounds.size.width / 3) - 1;

    /**** new size ****/
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(collectionWidth, collectionWidth);
    [flowLayout setMinimumInteritemSpacing:1.0f];
    [flowLayout setMinimumLineSpacing:1.0f];
    [self.collectionView setCollectionViewLayout:flowLayout];

}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    StopPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];

    Photo *photo = self.photos[indexPath.row];
    cell.imageView.file = photo.image;

    [cell.imageView loadInBackground];

    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    StopPhotoCollectionViewCell *cell = [[StopPhotoCollectionViewCell alloc] init];
    cell = (StopPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.image = cell.imageView.image;
    self.imageView.frame = CGRectMake(self.view.center.x, self.view.center.y, 0, 0);

    CGFloat imageSize = self.view.bounds.size.width;
    CGFloat originx = self.view.center.x - (imageSize / 2);
    CGFloat originy = self.view.center.y - (imageSize / 2);

    self.blackView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.blackView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    [self.view addSubview:self.blackView];

    [UIView animateWithDuration:.5 animations:^{

        [self.view addSubview:self.imageView];
        self.imageView.frame = CGRectMake(originx, originy, imageSize, imageSize);
        [self.view bringSubviewToFront:self.imageView];

    } completion:^(BOOL finished) {

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(onViewTapped)];

        [self.imageView addGestureRecognizer:tap];
        [self.blackView addGestureRecognizer:tap];
    }];
}


- (void)onViewTapped {

    [UIView animateWithDuration:0.1 animations:^{

        self.imageView.frame = CGRectMake(self.view.center.x, self.view.center.y, 1, 1);
        self.blackView.frame = CGRectMake(self.view.center.x, self.view.center.y, 1, 1);

    } completion:^(BOOL finished) {

        [self.imageView removeFromSuperview];
        [self.blackView removeFromSuperview];
    }];
}


-(void)dismissKeyboard {
    [self.view endEditing:YES];
    //[self.titleTextField resignFirstResponder];
}

@end



