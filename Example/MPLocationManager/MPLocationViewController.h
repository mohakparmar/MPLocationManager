//
//  MPLocationViewController.h
//  MPLocationManager
//
//  Created by Hemant Agrawal on 05/06/19.
//  Copyright © 2019 Mohak Parmar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileObject.h"
#import <MapKit/MapKit.h>
#import "WSManager.h"

@interface MPLocationViewController : UIViewController
{
    
    
    IBOutlet UIView *viewAccuracy;
    IBOutlet UIImageView *imgAccuracy;
    IBOutlet UITextField *txtAccuracy;

    IBOutlet UIView *viewUpdateTime;
    IBOutlet UIImageView *imgUpdateTime;
    IBOutlet UITextField *txtUpdateTime;
    
    __weak IBOutlet MKMapView *mapV;
    
    __weak IBOutlet UISwitch *switchCountdown;
    __weak IBOutlet UILabel *lblCountDown;
    
    __weak IBOutlet UISwitch *switchForceSend;
    __weak IBOutlet UILabel *lblForceSendLocation;
    
    __weak IBOutlet UISwitch *switchBackgroundLocation;
    __weak IBOutlet UILabel *lblBackgroundLocation;
    
    __weak IBOutlet UISwitch *switchBackgroundLocationIndicator;
    __weak IBOutlet UILabel *lblBackgroundLocationIndicator;
    
    __weak IBOutlet UIButton *btnStartUpdatingLocation;
    
    __weak IBOutlet UIButton *btnGeoCoding;
    
}
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentLocation;

- (IBAction)btnAccuracyInfoClick:(id)sender;
- (IBAction)btnTimeInfoClick:(id)sender;

- (IBAction)switchCountdownChange:(id)sender;
- (IBAction)switchForceSendClick:(id)sender;
- (IBAction)switchBackgroundLocationUpdateClick:(id)sender;
- (IBAction)switchBackgroundLocationIndicatorClick:(id)sender;

- (IBAction)btnStartUpdatingLocationClick:(id)sender;
- (IBAction)btnGeoCodingClick:(id)sender;

-(void)startUpdate;

@end

