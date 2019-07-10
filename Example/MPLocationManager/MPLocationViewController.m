//
//  MPLocationViewController.m
//  MPLocationManager
//
//  Copyright © 2019 Mohak Parmar. All rights reserved.
//

#import "MPLocationViewController.h"
#import "WSManager.h"

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
    [[MPLocationManager sharedInstance] SetMaxUpdateTime:kMPUpdateTimeStale30Seconds];
    [[MPLocationManager sharedInstance] setPausesLocationUpdatesAutomatically:NO];
    
    double i = [[MPLocationManager sharedInstance] getCurrentBatteryLife];
    NSLog(@"%f", i);
    
    if (![[[NSUserDefaults standardUserDefaults]  valueForKey:@"name"] isKindOfClass:[NSString class]]) {
        [self showEmployeeCodeAlerr];
    }
    
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
    
   // btnGeoCoding.hidden = NO;
    
    _lblCurrentLocation.text = [NSString stringWithFormat:@"%@", location.MPLocation];
    
    _objLocation = [[MPLocationObject alloc] init];
    _objLocation = location;
    
    [self WSForUpdateLocation];
    
    [self setLocationPin];
    [self zoomToLocation];
}

-(void)setLocationPin {
    [mapV removeAnnotations:mapV.annotations];
    MKCoordinateRegion mapRegion;
    mapRegion.center = _objLocation.MPLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.001;
    mapRegion.span.longitudeDelta = 0.001;
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
    
    if ([CLLocationManager locationServicesEnabled]){
        
        NSLog(@"Location Services Enabled");
        
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Location Permission Denied" message:@"To re-enable, please go to Settings and turn on Location Service for this app." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Setting" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }];
            UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"No, thanks" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

            }];
            [alert addAction:yesButton];
            [alert addAction:noButton];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            if ([btnStartUpdatingLocation.currentTitle isEqualToString:@"Start Updating Location"]) {
                [[MPLocationManager sharedInstance] StartUpdatingLocation:self];
                [btnStartUpdatingLocation setTitle:@"Stop Updating Location" forState:UIControlStateNormal];
            } else {
                [[MPLocationManager sharedInstance] StopUpdatingLocation];
                [btnStartUpdatingLocation setTitle:@"Start Updating Location" forState:UIControlStateNormal];
            }
        }
    } else {
        if ([btnStartUpdatingLocation.currentTitle isEqualToString:@"Start Updating Location"]) {
            [[MPLocationManager sharedInstance] StartUpdatingLocation:self];
            [btnStartUpdatingLocation setTitle:@"Stop Updating Location" forState:UIControlStateNormal];
        } else {
            [[MPLocationManager sharedInstance] StopUpdatingLocation];
            [btnStartUpdatingLocation setTitle:@"Start Updating Location" forState:UIControlStateNormal];
        }
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

-(void)WSForUpdateLocation {
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL *url = [NSURL URLWithString:@"http://204.141.208.30:82/api/Tracking"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"name"] forKey:@"EmployeeCode"];
    [dict setValue:[NSString stringWithFormat:@"%f", _objLocation.MPLocation.coordinate.latitude] forKey:@"Latitude"];
    [dict setValue:[NSString stringWithFormat:@"%f", _objLocation.MPLocation.coordinate.longitude] forKey:@"Longitude"];
    [dict setValue:[NSString stringWithFormat:@"%f", _objLocation.MPLocation.speed] forKey:@"Speed"];
    [dict setValue:[NSString stringWithFormat:@"%f", _objLocation.battery] forKey:@"Battery"];
    [dict setValue:[NSString stringWithFormat:@"%ld", (long)_objLocation.MPAccuracy] forKey:@"Accuracy"];
   
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];

    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *postLength=[NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:data];
    
    //Create task
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //Handle your response here
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@",responseDict);
    }];
    [dataTask resume];
}

-(void)showEmployeeCodeAlerr {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"EMPLOYEE CODE"
                                                                              message: @"Please enter your employee code"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Employee Code";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
  
    [alertController addAction:[UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        if ([namefield.text isEqualToString:@""]) {
            [self showEmployeeCodeAlerr];
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:namefield.text forKey:@"name"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end



