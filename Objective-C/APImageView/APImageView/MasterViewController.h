//
//  MasterViewController.h
//  APImageView
//
//  Created by Amit Priyadarshi on 09/02/16.
//  Copyright © 2016 AFAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end




@interface MasterViewController : UITableViewController <NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>


@end

