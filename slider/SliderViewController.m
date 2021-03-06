//
//  SliderViewController.m
//  Slider
//
//  Created by Monte Christopher Jeu on 5/10/15.
//  Copyright (c) 2015 Monte Jeu. All rights reserved.
//

#import "SliderViewController.h"
#import "SliderHelpViewController.h"
#import "Board.h"

@interface SliderViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *tileButtons;
@property (strong, nonatomic) IBOutlet UILabel *moves;
@property (strong, nonatomic) IBOutlet UILabel *solved;
@property (strong, nonatomic) IBOutlet UIView *sliderHelpView;
@property (strong, nonatomic) Board *board;
@property (strong, nonatomic) SliderHelpViewController *sliderHelpViewController;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;
@property (strong, nonatomic) IBOutlet UIImageView *sliderBackground;
@property (strong, nonatomic) IBOutlet UIButton *sliderBackButton;
@property (strong, nonatomic) IBOutlet UIButton *sliderResetButton;
@property (weak, nonatomic) IBOutlet UIButton *sliderHelpButton;
@property (weak, nonatomic) IBOutlet UILabel *highscoretext;
@property (weak, nonatomic) IBOutlet UIImageView *highscorebackground;
@property (strong, nonatomic) NSString *highscorefile;
@property (strong, nonatomic) NSString *solvedfile;
@property (strong, nonatomic) NSString *helpseenfile;

@end

@implementation SliderViewController

- (void) bannerViewDidLoadAd:(ADBannerView *)banner {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0];
    [banner setAlpha:1];
    [UIView commitAnimations];
    
}

- (void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0];
    [banner setAlpha:0];
    [UIView commitAnimations];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:self.board.helpsegue]) {
        self.sliderHelpViewController = [segue destinationViewController];
        self.sliderHelpViewController.board = self.board;
    }
}

- (IBAction)showHelpScreen:(id)sender {    
    [self.sliderHelpViewController loadImages];
    self.sliderHelpView.hidden = false;
    if (self.board.solved == true) {
        self.board = nil;
        [self updateButtons];
        [self updateLabels];
        self.highscorebackground.hidden=true;
        self.highscoretext.hidden=true;
        self.sliderHelpViewController.board = self.board;
    }
}

- (IBAction)resetBoard:(UIButton *)sender {
    self.board = nil;
    [self updateButtons];
    [self updateLabels];
    self.highscorebackground.hidden=true;
    self.highscoretext.hidden=true;
    self.sliderHelpViewController.board = self.board;
}

- (IBAction)moveTile:(UIButton *)sender {
    if(self.board.solved == true)
        return;
    
    if([self.board moveSlider:sender.currentTitle :self.level]) {
        [self updateButtons];
        [self updateLabels];
    }
}

- (void) updateButtons {
    NSInteger i = 0;
    for (UIButton *tileButton in self.tileButtons) {
        [tileButton setTitle:self.board.current[i] forState:UIControlStateNormal];
        NSString *image = [self.board tileImage:i];
        
        [tileButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:image ofType:@"png"]] forState:UIControlStateNormal];
        i++;
    }
}

- (Board *) board {
    if (!_board) {
        _board = [[Board alloc]initWithName:self.level];
        self.startTime = [NSDate timeIntervalSinceReferenceDate];
    }

    return _board;
}

- (void) setTileButtons:(NSArray *)tileButtons {
    _tileButtons = tileButtons;
    [self updateButtons];
}

- (void)viewDidLoad
{
    self.highscorefile = self.board.highscorefile;
    self.solvedfile = self.board.solvedfile;
    self.helpseenfile = self.board.helpseenfile;
    
    NSString *mydata = [self helpseenFilePath];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:mydata];
    if (!fileExists) {
        [values writeToFile:[self helpseenFilePath] atomically:YES];
        [self.sliderHelpViewController loadImages];
        self.sliderHelpView.hidden = false;
    }
    
    [self updateLabels];
    self.sliderBackground.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:self.board.background_image ofType:@"png"]];
    [self.sliderBackButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:@"back" ofType:@"png"]] forState:UIControlStateNormal];
    [self.sliderResetButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:@"reset" ofType:@"png"]] forState:UIControlStateNormal];
    [self.sliderHelpButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:@"help" ofType:@"png"]] forState:UIControlStateNormal];
    [self updateButtons];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void) updateLabels {
    self.moves.text = [NSString stringWithFormat: @"Moves: %ld", (long)self.board.moves];
    NSInteger solveTime;
    
    if ([self.board solved] == TRUE) {
        NSMutableArray *values;
        NSString *mydata = [self solvedFilePath];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:mydata];
        values = [[NSMutableArray alloc] init];
        [values addObject:[NSNumber numberWithInt:0]];
        
        if (!fileExists) {
            [values writeToFile:[self solvedFilePath] atomically:YES];
        }
        
        self.endTime = [NSDate timeIntervalSinceReferenceDate];
        solveTime = self.endTime - self.startTime;
        if (solveTime >= 9999) {
            solveTime = 9999;
        }
        if (solveTime == 9999) {
            self.solved.text = @"Solved!";
        } else {
            self.solved.text = [NSString stringWithFormat: @"Solved in %ld seconds!", (long)solveTime];
        }
        mydata = [self saveFilePath];
        
        fileExists = [[NSFileManager defaultManager] fileExistsAtPath:mydata];
        BOOL datavalid=true;
        NSInteger i;
        NSInteger tempnum;
        NSNumber *num;
        NSInteger time = solveTime;
        NSInteger newtime = -1;
        NSInteger newmove = -1;
        
        if (fileExists) {
            values = [[NSMutableArray alloc] initWithContentsOfFile:mydata];
        } else {
            datavalid=false;
        }
        
        
        if ([values count] != 6) {
            datavalid=false;
        } else {
            for (i=0; i<6; i++) {
                if (![[values objectAtIndex:i]isKindOfClass: [NSNumber class]]  ) {
                    datavalid=false;
                } else {
                    num = [values objectAtIndex:i];
                    if ([num intValue] < 1 || [num intValue] > 9999) {
                        datavalid=false;
                    }
                    
                }
            }
        }
        if (datavalid==false)
        {
            values = [[NSMutableArray alloc] init];
            for (i=0; i<6; i++) {
                [values addObject:[NSNumber numberWithInt:9999]];
            }
        }
        
        
        for (i=0; i<3; i++ ) {
            num = [values objectAtIndex:i];
            if (time < [num intValue]) {
                tempnum = [num intValue];
                [values replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:(int)time]];
                time = tempnum;
                if( newtime == -1) {
                    newtime = i;
                }
            }
        }
        
        NSInteger moves = self.board.moves;
        if (moves > 9999) {
            moves = 9999;
        }
        
        for (i=3; i<6; i++) {
            num = [values objectAtIndex:i];
            if (moves < [num intValue]) {
                tempnum = [num intValue];
                [values replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:(int)moves]];
                moves = tempnum;
                if( newmove == -1) {
                    newmove = i;
                }
            }
        }
        [values writeToFile:[self saveFilePath] atomically:YES];
        
        for (i=0; i<3; i++) {
            num = [values objectAtIndex:i];
            if ([num intValue] == 9999) {
                [values replaceObjectAtIndex:i withObject:@""];
            } else {
                if ( newtime != i) {
                    [values replaceObjectAtIndex:i withObject:[NSString stringWithFormat: @" %@ seconds", num]];
                } else {
                    [values replaceObjectAtIndex:i withObject:[NSString stringWithFormat: @"*%@ seconds*", num]];
                }
                
            }
        }
        for (i=3; i<6; i++) {
            num = [values objectAtIndex:i];
            if ([num intValue] == 9999) {
                [values replaceObjectAtIndex:i withObject:@""];
            } else {
                if ( newmove != i) {
                    [values replaceObjectAtIndex:i withObject:[NSString stringWithFormat: @" %@ moves", num]];
                } else {
                    [values replaceObjectAtIndex:i withObject:[NSString stringWithFormat: @"*%@ moves*", num]];
                }
            }
        }
        self.highscoretext.text = [NSString stringWithFormat: @"Fastest Times:\n   %@\n   %@\n   %@\nLeast turns:\n   %@\n   %@\n   %@",
                                   [values objectAtIndex:0],
                                   [values objectAtIndex:1],
                                   [values objectAtIndex:2],
                                   [values objectAtIndex:3],
                                   [values objectAtIndex:4],
                                   [values objectAtIndex:5]];
        self.highscorebackground.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:@"highscorebackground" ofType:@"png"]];
        self.highscorebackground.hidden=false;
        self.highscoretext.hidden=false;
        
    } else {
        self.solved.text = @"";
    }
}

- (NSString *) saveFilePath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [[path objectAtIndex:0] stringByAppendingPathComponent:self.highscorefile];
}

- (NSString *) solvedFilePath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [[path objectAtIndex:0] stringByAppendingPathComponent:self.solvedfile];
}

- (NSString *) helpseenFilePath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [[path objectAtIndex:0] stringByAppendingPathComponent:self.helpseenfile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end