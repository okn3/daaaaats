//
//  ViewController.m
//  daaaaats
//
//  Created by 奥野遼 on 2015/03/07.
//  Copyright (c) 2015年 奥野遼. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *score_board;
@property (weak, nonatomic) IBOutlet UILabel *score_1;
@property (weak, nonatomic) IBOutlet UILabel *score_2;
@property (weak, nonatomic) IBOutlet UILabel *score_3;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *score_guide;

- (IBAction)resetGame:(UIButton *)sender;

@end

@implementation ViewController

SystemSoundID soundID_other;
SystemSoundID soundID_other1;
SystemSoundID soundID_other2;
SystemSoundID soundID_other3;
SystemSoundID soundID_other4;
SystemSoundID soundID_tin;
SystemSoundID soundID_end;

bool soundSet_o1 = false;

int roundCount = 1;
int dartsCount = 0;
int score = 0;
int score_sum;
int score_total;
int luck;



- (void)viewDidLoad {
    [super viewDidLoad];
    //フォント指定
    _score_board.font = [UIFont fontWithName:@"DBLCDTempBlack" size:100.0];
    _score_1.font = [UIFont fontWithName:@"DBLCDTempBlack" size:20.0];
    _score_2.font = [UIFont fontWithName:@"DBLCDTempBlack" size:20.0];
    _score_3.font = [UIFont fontWithName:@"DBLCDTempBlack" size:20.0];

  
    //加速度センサーを定義
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    //更新間隔を設定
    accelerometer.updateInterval = 0.1;
    //デリゲートを selfに指定
    accelerometer.delegate = self;
    
    //BGM設定
    NSURL* other = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                           pathForResource:@"decision26" ofType:@"mp3"]];
    NSURL* other1 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                            pathForResource:@"darts_normal" ofType:@"mp3"]];
    NSURL* other2 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                            pathForResource:@"single_bull" ofType:@"mp3"]];
    NSURL* other3 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                            pathForResource:@"change" ofType:@"mp3"]];
    NSURL* other4 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                            pathForResource:@"throw" ofType:@"mp3"]];
    NSURL* other5 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                            pathForResource:@"tin1" ofType:@"mp3"]];
    NSURL* other6 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                            pathForResource:@"decision18" ofType:@"mp3"]];
    //効果音登録
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)other, &soundID_other);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)other1, &soundID_other1);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)other2, &soundID_other2);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)other3, &soundID_other3);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)other4, &soundID_other4);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)other5, &soundID_tin);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)other6, &soundID_end);
    
    //再生
    AudioServicesPlaySystemSound(soundID_other);
    
    //スタートの表示
    _score_board.text = @"00";
    _score_guide.text = @"Game Start";
    
}

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration {
    //傾き度合いをラベルに表示
//    NSLog(@"x=%f", acceleration.x);
//    NSLog(@"y=%f", acceleration.y);
//    NSLog(@"z=%f", acceleration.z);
    NSMutableArray *score_array = [NSMutableArray array];

            //ダーツゲーム
            if (acceleration.y < -0.3){
                soundSet_o1 = true;
                _score_board.text = @"";
                //乱数調整
                luck = (int)arc4random_uniform(10)+1;
//                NSLog(@"%d",luck);
            }else if(acceleration.y > 0.3 && soundSet_o1 == true){
                AudioServicesPlaySystemSound(soundID_other4);
                [NSThread sleepForTimeInterval:0.8];
                AudioServicesPlaySystemSound(soundID_other1);
                
                //得点計算
                if (acceleration.z < 0.08 && acceleration.z > -0.08){
                    AudioServicesPlaySystemSound(soundID_other2);
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    score = 25;
                    _score_guide.text = @"Bull!!";
                }else if(acceleration.z <= 0.5 && acceleration.z >= -0.5) {
//                    score = (1 - fabs(acceleration.z)) * 100/5; //素直に計算(10~19)
                    score = (int)arc4random_uniform(20)+1;
                }else{
                    score = 0;
                    AudioServicesPlaySystemSound(soundID_tin);
                }
                
                //タブル・トリプル
                if (luck ==1 && score == 25){
                        score = 50;
                    _score_guide.text = @"It's miracle!";
                }else if(luck == 1){
                    score *= 3;
                     _score_guide.text = @"Triple!";
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }else if(luck == 2 && score != 25){
                    score *=2;
                     _score_guide.text = @"Double!";
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }else if(luck == 10 && score != 25){
                    AudioServicesPlaySystemSound(soundID_tin);
                    score = 0;
                    _score_guide.text = @"Oh...";
                }else if(score != 25) {
                    _score_guide.text = @"good!";
                }
                
                _score_board.text = [NSString stringWithFormat:@"%d ", score];
                NSLog(@"score:%d",score);
                NSLog(@"count:%d",dartsCount);
                [score_array addObject:@(score)];
                
                score_sum += score;
                soundSet_o1 = false;
                dartsCount++;
                _progress.progress = 0.3333 * dartsCount;
                
                //合計
                if (dartsCount == 3) {
                    sleep(1);
                    score_total += score_sum;
                    AudioServicesPlaySystemSound(1311);
                    AudioServicesPlaySystemSound(soundID_other3);
                    NSLog(@"score_sum:%d",score_sum);
                    if (score_sum > 60) {
                        _score_guide.text = @"(*^v^)/ < Great!";
                    }else if (score_sum >40 ){
                        _score_guide.text = @"(・∀・)< good";
                    }else{
                        _score_guide.text = @"(*_*)< bad..";
                    }
                    switch (roundCount) {
                        case 1:
                            _score_1.text = [NSString stringWithFormat:@"%d. %d",roundCount, score_sum ];
                            break;
                        case 2:
                            _score_2.text = [NSString stringWithFormat:@"%d. %d",roundCount, score_sum ];
                            break;
                        case 3:
                            _score_3.text = [NSString stringWithFormat:@"%d. %d",roundCount, score_sum ];
                            break;
                    }
                    sleep(2);
                    roundCount++;
                    dartsCount = 0;
                    score_sum = 0;

                    //終了処理
                    if (roundCount == 4) {
                        AudioServicesPlaySystemSound(soundID_end);
                        _score_board.text = [NSString stringWithFormat:@"%d",score_total];
                        _score_guide.text = @"Reslut score";
                        roundCount = 1;
                        score_total = 0;
                    }
                    
                }
            }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resetGame:(UIButton *)sender {
//    [self accelerometer:(UIAccelerometer *)accelerometer didAccelerate:
    NSLog(@"reset");
}
@end
