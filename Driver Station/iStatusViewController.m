//
//  iStatusViewController.m
//  Driver Station
//
//  Created by Connor on 3/26/14.
//  Copyright (c) 2014 Connor Christie. All rights reserved.
//

#import "iStatusViewController.h"

#import "AppDelegate.h"
#import "ControlTableViewCell.h"
#import "iMainViewController.h"

#import <objc/message.h>

static short AUTONOMOUS_BIT = 0x50;
static short TELEOP_BIT     = 0x40;

@interface iStatusViewController ()
{
    AppDelegate *delegate;
}

@end

@implementation iStatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    delegate = [[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    } else if (section == 1)
    {
        return 4;
    } else if (section == 2)
    {
        return 1;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Robot Info";
    } else if (section == 1)
    {
        return @"Robot Status";
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section)
    {
        case 0:
        {
            if (indexPath.row == 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Team Number"];
                
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", delegate.teamNumber];
            }
            
            break;
        }
        case 1:
            if (indexPath.row == 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Info"];
                
                int currentTime = ((iMainViewController *) delegate.mainController).currentTime;
                
                cell.textLabel.text = @"Time";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%i:%02d", currentTime / 60, currentTime % 60];
            } else if (indexPath.row == 1)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Info"];
                
                struct RobotDataPacket *data = [((iMainViewController *) delegate.mainController) getInputPacket];
                
                if (delegate.state == RobotNotConnected)
                {
                    data->batteryVolts = 0;
                    data->batteryMV    = 0;
                }
                
                cell.textLabel.text = @"Battery";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2X.%.2XV", data->batteryVolts,  data->batteryMV];
            } else if (indexPath.row == 2)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Info"];
                
                cell.textLabel.text = @"Status";
                
                cell.detailTextLabel.textColor = [UIColor grayColor];
                
                switch (delegate.state)
                {
                    case RobotNotConnected:
                        cell.detailTextLabel.text = @"Not Connected";
                        
                        break;
                    case RobotWatchdogNotFed:
                        cell.detailTextLabel.text = @"Watchdog Not Fed";
                        
                        break;
                    case RobotDisabled:
                        cell.detailTextLabel.text = @"Disabled";
                        
                        cell.detailTextLabel.textColor = [UIColor redColor];
                        
                        break;
                    case RobotEnabled:
                        cell.detailTextLabel.text = @"Enabled";
                        
                        cell.detailTextLabel.textColor = [UIColor colorWithRed:0 green:207 / 255.0f blue:65 / 255.0f alpha:1];
                        
                        break;
                    case RobotAutonomous:
                        cell.detailTextLabel.text = @"Autonomous";
                        
                        break;
                }
            }/* else if (indexPath.row == 3)
              {
              cell = [tableView dequeueReusableCellWithIdentifier:@"Info"];
              
              cell.textLabel.text = @"Bluetooth";
              cell.detailTextLabel.text = ((MainViewController *)delegate.mainController).blueConnected ? @"Connected" : @"Not Connected";
              } */else if (indexPath.row == 3)
              {
                  cell = [tableView dequeueReusableCellWithIdentifier:@"Alliance"];
                  
                  cell.selectionStyle = UITableViewCellSelectionStyleNone;
                  
                  UISegmentedControl *color = (UISegmentedControl *) [cell viewWithTag:1];
                  UISegmentedControl *index = (UISegmentedControl *) [cell viewWithTag:2];
                  
                  if (color.selectedSegmentIndex == 0)
                  {
                      [color setTintColor:[UIColor redColor]];
                  } else
                  {
                      [color setTintColor:[UIColor blueColor]];
                  }
                  
                  ((iMainViewController *) delegate.mainController).teamColor = color.selectedSegmentIndex;
                  ((iMainViewController *) delegate.mainController).teamIndex = index.selectedSegmentIndex;
              }
            
            break;
        case 2:
            if (delegate.state == RobotNotConnected)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Not Connected"];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Control"];
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                
                UILabel *textLabel = (UILabel *) [cell viewWithTag:2];
                UISegmentedControl *control = (UISegmentedControl *) [cell viewWithTag:1];
                
                [control addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
                
                if (delegate.state == RobotDisabled)
                {
                    textLabel.text = @"Enable";
                    textLabel.textColor = [UIColor colorWithRed:0 green:207 / 255.0f blue:65 / 255.0f alpha:1];
                    
                    cell.backgroundColor = [UIColor whiteColor];
                } else if (delegate.state == RobotEnabled || delegate.state == RobotWatchdogNotFed || delegate.state == RobotAutonomous)
                {
                    textLabel.text = @"Disable";
                    textLabel.textColor = [UIColor redColor];
                    
                    cell.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.2];
                }
            }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.section == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edit Team Number" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        UITextField *field = [alert textFieldAtIndex:0];
        
        field.text = [NSString stringWithFormat:@"%i", delegate.teamNumber];
        
        [alert show];
    } else if (indexPath.section == 2)
    {
        [((iMainViewController *) delegate.mainController) changeControl:delegate.state == RobotDisabled];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 5)
    {
        if (buttonIndex == 0)
        {
            //Cancel click
            
            struct FRCCommonControlData *data = [((iMainViewController *) delegate.mainController) getOutputPacket];
            
            data->control = TELEOP_BIT;
            
            UIView *control = (UISegmentedControl *) [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] viewWithTag:1];
            
            if ([control class] == [UISegmentedControl class])
            {
                ((UISegmentedControl *) control).selectedSegmentIndex = 1;
            }
        } else
        {
            ((iMainViewController *) delegate.mainController).autoTime = [[alertView textFieldAtIndex:0].text intValue];
        }
    } else if (buttonIndex == 1)
    {
        UITextField *field = [alertView textFieldAtIndex:0];
        
        if ([field.text intValue] != delegate.teamNumber)
        {
            delegate.teamNumber = [field.text intValue];
            
            [((iMainViewController *) delegate.mainController) changeTeam];
        }
    }
}

- (void)segmentChanged:(id)sender
{
    int index = [self controlIndex];
    
    if (delegate.state != RobotNotConnected)
    {
        [((iMainViewController *) delegate.mainController) changeControl:false];
        
        struct FRCCommonControlData *data = [((iMainViewController *) delegate.mainController) getOutputPacket];
        
        if (index == 0)
        {
            data->control = AUTONOMOUS_BIT;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Autonomous Time" message:@"Please put in how many seconds you would like autonomous to stop after, 0 for infinite." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
            
            alert.tag = 5;
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            
            [alert show];
        } else
        {
            data->control = TELEOP_BIT;
        }
    }
}

- (int)controlIndex
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    
    if ([cell isKindOfClass:[ControlTableViewCell class]])
    {
        return (int) ((ControlTableViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]]).control.selectedSegmentIndex;
    }
    
    return 0;
}

@end
