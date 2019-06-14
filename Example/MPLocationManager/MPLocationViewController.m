//
//  MPLocationViewController.m
//  MPLocationManager
//
//  Copyright © 2019 Mohak Parmar. All rights reserved.
//

#import "MPLocationViewController.h"

@interface MPLocationViewController ()<MPLocationDelegate, UITextFieldDelegate>

@property (nonatomic, retain) MPLocationObject *objLocation;

@end

@implementation MPLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;
    
    [MPLocationManager sharedInstance].delegate = self;
    [[MPLocationManager sharedInstance] checkLocationPermissionStatus];
    [[MPLocationManager sharedInstance] SetMaxAccuracy:kMPHorizontalAccuracyNear];
//    [[MPLocationManager sharedInstance] SetMaxUpdateTime:kMPUpdateTimeStale30Seconds];
    
    double i = [[MPLocationManager sharedInstance] getCurrentBatteryLife];
    NSLog(@"%f", i);
    
}

-(void)viewWillAppear:(BOOL)animated {
    [MPUtility setViewBorder:viewAccuracy colour:@"ABB4BD" alpha:1.0 radius:5 borderWidth:1];
    [MPUtility setViewBorder:viewUpdateTime colour:@"ABB4BD" alpha:1.0 radius:5 borderWidth:1];
    
    btnStartUpdatingLocation.layer.cornerRadius = btnStartUpdatingLocation.frame.size.height/2;
    btnStartUpdatingLocation.layer.masksToBounds = YES;
    
    [MPUtility SetImageTintColor:imgAccuracy color:@"D50200"];
    [MPUtility SetImageTintColor:imgUpdateTime color:@"D50200"];
}

-(void)SendLocation:(MPLocationObject *)location {
    NSLog(@"%@", location);
    
    btnGeoCoding.hidden = NO;
    
    _lblCurrentLocation.text = [NSString stringWithFormat:@"%@", location.MPLocation];
    
    _objLocation = [[MPLocationObject alloc] init];
    _objLocation = location;
    
    [self setLocationPin];
    [self zoomToLocation];
}

-(void)setLocationPin {
    [mapV removeAnnotations:mapV.annotations];
    MKCoordinateRegion mapRegion;
    mapRegion.center = _objLocation.MPLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
    [mapV setRegion:mapRegion animated: YES];
}

-(void)zoomToLocation {
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:_objLocation.MPLocation.coordinate];
    [mapV addAnnotation:annotation];
}

-(void)SendError:(MPLocationStatus)ErrorCode {
    switch (ErrorCode) {
        case MPLocationStatusTimedOut: {
            _lblCurrentLocation.text = @"Time Out";
            break;
        }
        case MPLocationStatusServicesNotDetermined: {
            _lblCurrentLocation.text = @"Awaiting for user permission.";
            break;
        }
        case MPLocationStatusServicesDenied: {
            _lblCurrentLocation.text = @"User denied the location permission.";
            break;
        }
        case MPLocationStatusServicesRestricted: {
            _lblCurrentLocation.text = @"Location services restricted by user.";
            break;
        }
        case MPLocationStatusServicesDisabled: {
            _lblCurrentLocation.text = @"Location services disable by user.";
            break;
        }
        case MPLocationStatusError: {
            _lblCurrentLocation.text = @"Gerring error while fetching location.";
            break;
        }
        case MPLocationStatusSuccess: {
            mapV.hidden = NO;
            _lblCurrentLocation.text = @"User has given the permission, waiting for next location.";
            break;
        }
        case MPLocationStatusTimerStart: {
            break;
        }
        case MPLocationStatusTimerStop: {
            lblCountDown.text = @"Enable Coundown";
            break;
        }
        case MPLocationStatusAddressFetched: {
            CLPlacemark *obj = [self.objLocation.MPPlaceMarks objectAtIndex:0];
            NSLog(@"%@", obj);
            break;
        }
        case MPLocationStatusErrorInAddressFetched: {
            lblCountDown.text = @"Error in fetching address. Please try again.";
            break;
        }
        case MPLocationStatusPause: {
            [btnStartUpdatingLocation setTitle:@"Start Updating Location" forState:YES];
            break;
        }
        default:
            break;
    }
}

-(void)sendTimerCount:(NSString *)str_count_down {
    lblCountDown.text = [NSString stringWithFormat:@"Next location update in : %@", str_count_down];
}

- (IBAction)btnAccuracyInfoClick:(id)sender {
    [self presentViewController:[MPUtility showAlertWithTitleAndMessage:@"Accuracy Information" message:@"To Set Accuracy you want for location"] animated:YES completion:nil];
}

- (IBAction)btnTimeInfoClick:(id)sender {
    [self presentViewController:[MPUtility showAlertWithTitleAndMessage:@"Time Information" message:@"To Set location update time it will fire delegate method in your set times"] animated:YES completion:nil];
}

- (IBAction)switchCountdownChange:(id)sender {
    [[MPLocationManager sharedInstance] enableCoundown:switchCountdown.isOn?YES:NO];
}

- (IBAction)switchForceSendClick:(id)sender {
    [[MPLocationManager sharedInstance] enableForceSend:switchForceSend.isOn?YES:NO];
}

- (IBAction)switchBackgroundLocationUpdateClick:(id)sender {
    [[MPLocationManager sharedInstance] setBackgroundLocationUpdate:switchBackgroundLocation.isOn?YES:NO];
}

- (IBAction)switchBackgroundLocationIndicatorClick:(id)sender {
    [[MPLocationManager sharedInstance] setShowsBackgroundLocationIndicator:switchBackgroundLocationIndicator.isOn?YES:NO];
}

- (IBAction)btnStartUpdatingLocationClick:(id)sender {
    if ([btnStartUpdatingLocation.currentTitle isEqualToString:@"Start Updating Location"]) {
        [[MPLocationManager sharedInstance] StartUpdatingLocation:self];
        [btnStartUpdatingLocation setTitle:@"Stop Updating Location" forState:UIControlStateNormal];
    } else {
        [[MPLocationManager sharedInstance] StopUpdatingLocation];
        [btnStartUpdatingLocation setTitle:@"Start Updating Location" forState:UIControlStateNormal];
    }
}

- (IBAction)btnGeoCodingClick:(id)sender {
    if (self.objLocation.MPLocation) {
        [[MPLocationManager sharedInstance] getAddress:self.objLocation];
    } else {
        [self presentViewController:[MPUtility showAlertWithTitleAndMessage:@"Error" message:@"Please update the location object in order to fetch the address."] animated:YES completion:nil];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    if (textField == txtAccuracy) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Very Far" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[MPLocationManager sharedInstance] SetMaxAccuracy:MPLocationAccuracyVeryFar];
            self->txtAccuracy.text = @"Very Far";
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Far" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[MPLocationManager sharedInstance] SetMaxAccuracy:MPLocationAccuracyFar];
            self->txtAccuracy.text = @"Far";
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Moderate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[MPLocationManager sharedInstance] SetMaxAccuracy:MPLocationAccuracyModerate];
            self->txtAccuracy.text = @"Moderate";
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Near" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[MPLocationManager sharedInstance] SetMaxAccuracy:MPLocationAccuracyNear];
            self->txtAccuracy.text = @"Near";
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Very Near" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[MPLocationManager sharedInstance] SetMaxAccuracy:MPLocationAccuracyVeryNear];
            self->txtAccuracy.text = @"Very Near";
        }]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    } else if (textField == txtUpdateTime) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"5 Seconds" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[MPLocationManager sharedInstance] SetMaxUpdateTime:MPLocationUpdateTime5Seconds];
            self->txtUpdateTime.text = @"5 Seconds";
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"30 Seconds" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[MPLocationManager sharedInstance] SetMaxUpdateTime:MPLocationUpdateTime30Seconds];
            self->txtUpdateTime.text = @"30 Seconds";
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"1 Minute" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[MPLocationManager sharedInstance] SetMaxUpdateTime:MPLocationUpdateTime1Minutes];
            self->txtUpdateTime.text = @"1 Minute";
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"5 Minutes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[MPLocationManager sharedInstance] SetMaxUpdateTime:MPLocationUpdateTime5Minutes];
            self->txtUpdateTime.text = @"5 Minutes";
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"10 Minutes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[MPLocationManager sharedInstance] SetMaxUpdateTime:MPLocationUpdateTime10Minutes];
            self->txtUpdateTime.text = @"10 Minutes";
        }]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

@end



