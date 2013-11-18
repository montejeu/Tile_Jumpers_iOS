//
//  SliderViewController.m
//  Slider
//
//  Created by Monte Jeu on 9/27/13.
//  Copyright (c) 2013 Monte Jeu. All rights reserved.
//

#import "SliderViewController.h"
#import "Board.h"

@interface SliderViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *tileButtons;
@property (strong, nonatomic) IBOutlet UILabel *moves;
@property (strong, nonatomic) IBOutlet UILabel *solved;
@property (strong, nonatomic) Board *board;
@end

@implementation SliderViewController

- (IBAction)unwindToSliderViewController:(UIStoryboardSegue *)unwindSegue
{

}

- (IBAction)resetBoard:(UIButton *)sender {
    self.board = nil;
    int i = 0;
    for (UIButton *tileButton in self.tileButtons) {
        [tileButton setTitle:[Board validValues][0] forState:UIControlStateSelected];
        [tileButton setTitle:[Board validValues][0] forState:UIControlStateNormal];
        
        [tileButton setTitle:self.board.current[i] forState:UIControlStateSelected];
        [tileButton setTitle:self.board.current[i] forState:UIControlStateNormal];
        i++;
    }
    [self updateLabels];
}

- (IBAction)moveTile:(UIButton *)sender {
    if(self.board.solved == true)
        return;
    
    if([self.board moveSliderBasic: sender.currentTitle]) {
        NSInteger i=0;
        for (UIButton *tileButton in self.tileButtons) {
            [tileButton setTitle:self.board.current[i] forState:UIControlStateSelected];
            [tileButton setTitle:self.board.current[i] forState:UIControlStateNormal];
            i++;
        }
        [self updateLabels];
    }
}

- (Board *) board {
    if (!_board)
       _board = [[Board alloc]init];
    
    return _board;
}

- (void) setTileButtons:(NSArray *)tileButtons {
    int i = 0;

    _tileButtons = tileButtons;
    for (UIButton *tileButton in tileButtons) {
        [tileButton setTitle:self.board.current[i] forState:UIControlStateSelected];
        [tileButton setTitle:self.board.current[i] forState:UIControlStateNormal];
        i++;
    }
    
    
}


- (void)viewDidLoad
{
    [self updateLabels];

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIScreen mainScreen]bounds].size.height == 568.0) {
        
    }
    
}

- (void) updateLabels {
    self.moves.text = [NSString stringWithFormat: @"Moves: %d", self.board.moves];
    
    if ([self.board solved] == TRUE)
        self.solved.text = @"Solved!";
    else
        self.solved.text = @"";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
