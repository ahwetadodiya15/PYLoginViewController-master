//
//  GrantAccessCell.h
//  PYLoginViewController
//
//  Created by Indresh on 22/01/15.
//  Copyright (c) 2015 Pyrus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrantAccessCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageViewAccount;
@property (strong, nonatomic) IBOutlet UILabel *labelAccount;
@property (strong, nonatomic) IBOutlet UILabel *labelDetail;
@property (strong, nonatomic) IBOutlet UIButton *buttonAdd;

@end
