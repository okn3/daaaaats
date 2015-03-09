//
//  ViewController.h
//  daaaaats
//
//  Created by 奥野遼 on 2015/03/07.
//  Copyright (c) 2015年 奥野遼. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController

@property(readwrite)CFURLRef soundURL;
@property(readonly)SystemSoundID soundID;

@end

