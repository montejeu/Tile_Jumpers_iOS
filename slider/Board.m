//
//  Board.m
//  Slider
//
//  Created by Monte Jeu on 9/28/13.
//  Copyright (c) 2013 Monte Jeu. All rights reserved.
//

#import "Board.h"

@interface Board()
@property (strong, nonatomic) NSMutableArray *tiles;
@end

@implementation Board


- (NSString *) tileImage:(NSInteger) value {
    if (value == self.block_one) {
        return @"tile_3";
    }
    if (value == self.block_two) {
        return @"tile_3";
    }
    if (value == self.transport_one) {
        return @"tile_2";
    }
    if (value == self.transport_two) {
        return @"tile_2";
    }
    return @"tile_1";
}

- (BOOL) moveSlider:(NSString *)tile :(NSString *)level {
    if ([level isEqualToString:@"Final"]) {
        return[self moveSliderFinal:tile];
    } else if ([level isEqualToString:@"Plus"]) {
        return [self moveSliderPlus:tile];
    } else if ([level isEqualToString:@"Next"]) {
        return [self moveSliderNext:tile];
    } else if ([level isEqualToString:@"Basic"]) {
        return[self moveSliderBasic:tile];
    }
    return false;
}

- (BOOL) moveSliderBasic:(NSString *) tile {
    BOOL validMove = false;
    NSInteger i;
    NSInteger j;
    
    if ( ![tile isEqualToString: [Board validValues][0]]) {
        i = [self.current indexOfObject:tile];
        j = [self.current indexOfObject:[Board validValues][0]];
        
        if ([[Board validMoves][i] containsObject:@(j) ]) {
            validMove = true;
        }
    }
    
    if ( validMove == true ) {
        self.moves++;
        
        self.current[j] = self.current[i];
        self.current[i] = [Board validValues][0];
    }
    return validMove;
}

- (BOOL) moveSliderPlus:(NSString *) tile {
    BOOL validMove = false;
    
    if ( [tile isEqualToString: self.current[self.transport_one]] ) {
        self.current[self.transport_one] = self.current[self.transport_two];
        self.current[self.transport_two] = tile;
        self.moves++;
        validMove = true;
    } else if ([tile isEqualToString: self.current[self.transport_two]]) {
        self.current[self.transport_two] = self.current[self.transport_one];
        self.current[self.transport_one] = tile;
        self.moves++;
        validMove = true;
    } else {
        validMove = [self moveSliderBasic:tile];
    }
    if(validMove == true) {
        [self getTransports];
    }
    return validMove;
}

- (BOOL) moveSliderNext:(NSString *) tile {
    BOOL validMove = false;
    
    if (!([tile isEqualToString: self.current[self.block_one]] || [tile isEqualToString: self.current[self.block_two]])) {
        validMove = [self moveSliderBasic:tile];
    }
    if(validMove == true) {
        [self getBlocks];
    }
    return validMove;
}

- (BOOL) moveSliderFinal:(NSString *) tile {
    BOOL validMove = false;
    
    if (!([tile isEqualToString: self.current[self.block_one]] || [tile isEqualToString: self.current[self.block_two]])) {
        validMove = [self moveSliderPlus:tile];
    }
    if(validMove == true) {
        [self getBlocks];
    }
    return validMove;
   
}

+ (NSArray *) validValues {
    static NSArray *validValues = nil;
    if (!validValues)
        validValues = @[@"  ",@" 1",@" 2",@" 3",@" 4",@" 5",@" 6",@" 7",@" 8",@" 9",@"10",@"11",@"12",@"13",@"14",@"15"];
    return validValues;
}

+ (NSArray *) validMoves {
    static NSArray *validMoves = nil;
    if(!validMoves)
        validMoves = @[
                       @[@1, @4],      @[@0, @2, @5],       @[@1, @3, @6],       @[@2, @7],
                       @[@0, @5, @8],  @[@1, @4, @6, @9],   @[@2, @5, @7, @10],  @[@3, @6, @11],
                       @[@4, @9, @12], @[@5, @8, @10, @13], @[@6, @9, @11, @14], @[@7, @10, @15],
                       @[@8, @13],     @[@9, @12, @14],     @[@10, @13, @15],    @[@11, @14]
                       ];
    return validMoves;
}

+ (NSDictionary *) invalidblock {
    static NSDictionary *invalidblock = nil;
    if(!invalidblock)
        invalidblock = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:0], @[@1, @4],
                        [NSNumber numberWithInt:3], @[@2, @7],
                        [NSNumber numberWithInt:12], @[@8, @13],
                        [NSNumber numberWithInt:15], @[@11, @14], nil];
    return invalidblock;
}

- (NSMutableArray *) tiles {
    if (!_tiles) _tiles = [[NSMutableArray alloc]init];
    return _tiles;
}

- (NSMutableArray *) current {
    if (!_current) _current = [[NSMutableArray alloc]init];
    return _current;
}

- (void)addTile:(Tile *)tile {
    [self.tiles addObject:tile];
}

- (Tile *) getRandomTile {
    Tile *randomTile;
    if (self.tiles.count) {
        unsigned index = arc4random() % self.tiles.count;
        randomTile = self.tiles[index];
        [self.tiles removeObjectAtIndex:index];
    }
    return randomTile;
}

- (BOOL) solved {
    NSInteger i;
    
    for (i = 0; i < 15; i++) {
        if (![self.current[i] isEqual: [Board validValues][i+1] ] )
            return FALSE;
    }
    return TRUE;
}

- (BOOL) solvable {
    NSMutableArray *tile;
    NSInteger inversions=0;
    NSInteger j= 16;
    NSInteger i;
    NSInteger x;
    NSInteger y;
    
    tile = [[NSMutableArray alloc] init];
   
    [tile addObject:@"-1"];
    for(i = 0; i < 16; i++) {
        [tile addObject:self.current[i]];
    }
    
    for(i = 1; i < 17; i++) {
        if([tile[i] isEqual: [Board validValues][0]]) {
            j = i;
        }
    }
    if(j != 16) {
        if(j < 13) {
            for(; j < 13; j = j + 4) {
                [tile replaceObjectAtIndex:j withObject: tile[j + 4]];
                [tile replaceObjectAtIndex:j + 4 withObject:[Board validValues][0]];
            }
        }
        for(; j < 16; j++) {
            [tile replaceObjectAtIndex:j withObject: tile[j + 1]];
            [tile replaceObjectAtIndex:j + 1 withObject:[Board validValues][0]];
        }
    }
    for(x = 1; x < 16; x++) {
        for(y = x + 1; y < 16; y++) {
            if(tile[x] > tile[y]) {
                inversions++;
            }
        }
    }
    
    [tile removeAllObjects];
                              
    if(inversions % 2 == 0) {
        return TRUE;
    } else {
        return FALSE;
    }
    
}

-(void) getTransports
{
    self.transport_one = arc4random() % 16;
    self.transport_two = arc4random() % 16;
    
    while (self.current[self.transport_one] == [Board validValues][0]) {
        self.transport_one = arc4random() % 16;
    }
    while (self.current[self.transport_two] == [Board validValues][0] || self.transport_one == self.transport_two ) {
        self.transport_two = arc4random() % 16;
    }
}

-(void) getBlocks
{
    self.block_one = arc4random() % 16;
    self.block_two = arc4random() % 16;

    bool validboard = false;
    
    while (!validboard) {
        validboard = true;


        
        if(self.transport_one == -1) {
            if ( (self.block_one == 1 && self.block_two == 4) || (self.block_one == 4 && self.block_two == 1 ) ) {
                if (self.current[0] == [Board validValues][0]) {
                    validboard = false;
                }
            }
            
            if ( (self.block_one == 2 && self.block_two == 7 ) || (self.block_one == 7 && self.block_two == 2 ) ){
                if (self.current[3] == [Board validValues][0]) {
                    validboard = false;
                }
            }
            
            if ( (self.block_one == 8 && self.block_two == 13 ) || (self.block_one == 13 && self.block_two == 8 ) ){
                if (self.current[12] == [Board validValues][0]) {
                    validboard = false;
                }
            }
            
            if ( (self.block_one == 11 && self.block_two == 14 ) || (self.block_one == 14 && self.block_two == 11 ) ){
                if (self.current[15] == [Board validValues][0]) {
                    validboard = false;
                }
            }
        }

        if(self.block_one == self.transport_one || self.block_one == self.transport_two) {
            validboard = false;
        }
        
        if(self.block_two == self.transport_one || self.block_two == self.transport_two) {
            validboard = false;
        }
        
        if(self.current[self.block_one] == self.current[self.block_two]) {
            validboard = false;
        }
        
        if(self.current[self.block_two] == [Board validValues][0]) {
            validboard = false;
        }
        
        if(self.current[self.block_one] == [Board validValues][0]) {
            validboard = false;
        }

        if(validboard == false) {
            self.block_one = arc4random() % 16;
            self.block_two = arc4random() % 16;
        }
    }
    
}

- (id)init {
    self = [super init];
    if (self) {
        int MAX_SOLVIBILITY = 2;
        self.solvability = MAX_SOLVIBILITY;
        while (self.solvability >= MAX_SOLVIBILITY) {
            self.solvability = 0;
            
            if(self) {
                for ( int i=0; i < 16; i++) {
                    Tile *tile = [[Tile alloc] init];
                    tile.value = i;
                    [self addTile:tile];
                }
            }
            
            for ( int i=0; i < 16; i++) {
                Tile *tile = self.getRandomTile;
                [self.current addObject:[Board validValues][tile.value]];
            }
            
            if(!self.solvable) {
                if(self.current[0] == [Board validValues][0] || self.current[1] == [Board validValues][0]) {
                    NSString *temp = self.current[3];
                    [self.current replaceObjectAtIndex:3 withObject:self.current[4]];
                    [self.current replaceObjectAtIndex:4 withObject:temp];
                } else {
                    NSString *temp = self.current[0];
                    [self.current replaceObjectAtIndex:0 withObject:self.current[1]];
                    [self.current replaceObjectAtIndex:1 withObject:temp];
                    
                }
            }
            
            for (int i=0; i<15; i++) {
                if (self.current[i]==[Board validValues][i+1]) {
                    self.solvability++;
                }
            }
            
            if (self.solvability >= MAX_SOLVIBILITY) {
                [self.current removeAllObjects];
                [self.tiles removeAllObjects];
            }
        }
    }
    self.moves = 0;
    self.block_one = -1;
    self.block_two = -1;
    self.transport_one = -1;
    self.transport_two = -1;
    return self;
}

//        _board = [[Board alloc]initWithName:true block:true];

-(id)initWithName:(NSString *) level {
    bool transport;
    bool block;
    
    
    self.helpsegue = @"sliderHelpSegue";

    if ([level isEqualToString:@"Final"]) {
        self.background_image = @"back4_s";
        self.highscorefile = @"sliderfinal.plist";
        self.solvedfile = @"sliderfinalsolved.plist";
        self.helpseenfile = @"sliderfinalhelp.plist";
        self.helptextbackground = @"sliderhelptextbackground";
        self.helptextimages = [[NSMutableArray alloc] init];
        [self.helptextimages addObject:@"sliderfinalhelp1"];
        [self.helptextimages addObject:@"sliderfinalhelp2"];
        self.helptext = @"Brown tiles may block the next move and force red bordered tiles to be used!\n\nDouble the obstacles, double the fun!";
        
        transport = true;
        block = true;
    } else if ([level isEqualToString:@"Plus"]) {
        self.background_image = @"back2_s";
        self.highscorefile = @"sliderplus.plist";
        self.solvedfile = @"sliderplussolved.plist";
        self.helpseenfile = @"sliderplushelp.plist";
        self.helptextbackground = @"sliderhelptextbackground";
        self.helptextimages = [[NSMutableArray alloc] init];
        [self.helptextimages addObject:@"sliderplushelp1"];
        [self.helptextimages addObject:@"sliderplushelp2"];
        [self.helptextimages addObject:@"sliderplushelp1"];
        [self.helptextimages addObject:@"sliderplushelp2"];
        [self.helptextimages addObject:@"sliderplushelp1"];
        [self.helptextimages addObject:@"sliderplushelp2"];
        [self.helptextimages addObject:@"sliderplushelp3"];
        [self.helptextimages addObject:@"sliderplushelp4"];
        [self.helptextimages addObject:@"sliderplushelp3"];
        [self.helptextimages addObject:@"sliderplushelp4"];
        [self.helptextimages addObject:@"sliderplushelp3"];
        [self.helptextimages addObject:@"sliderplushelp4"];
        self.helptext = @"It may be neccessary to swap red bordered tiles to solve the board.\n\nAvoid touching the red bordered tiles on accident!";
        
            transport = true;
            block = false;
    } else if ([level isEqualToString:@"Next"]) {
        self.background_image = @"back3_s";
        self.highscorefile = @"slidernext.plist";
        self.solvedfile = @"slidernextsolved.plist";
        self.helpseenfile = @"slidernexthelp.plist";
        self.helptextbackground = @"sliderhelptextbackground";
        self.helptextimages = [[NSMutableArray alloc] init];
        [self.helptextimages addObject:@"slidernexthelp1"];
        self.helptext = @"Just like red bordered tiles, brown tiles may cause extra moves and extra time to solve the puzzle.\n\nFind another path to move!";
        
        transport = false;
        block = true;
    } else if ([level isEqualToString:@"Basic"]) {
        self.background_image = @"back1_s";
        self.highscorefile = @"sliderbasic.plist";
        self.solvedfile = @"sliderbasicsolved.plist";
        self.helpseenfile = @"sliderbasichelp.plist";
        self.helptextbackground = @"sliderhelptextbackground";
        self.helptextimages = [[NSMutableArray alloc] init];
        [self.helptextimages addObject:@"sliderhelp1"];
        [self.helptextimages addObject:@"sliderhelp2"];
        [self.helptextimages addObject:@"sliderhelp1"];
        [self.helptextimages addObject:@"sliderhelp2"];
        [self.helptextimages addObject:@"sliderhelp1"];
        [self.helptextimages addObject:@"sliderhelp2"];
        [self.helptextimages addObject:@"sliderhelp3"];
        [self.helptextimages addObject:@"sliderhelp4"];
        [self.helptextimages addObject:@"sliderhelp3"];
        [self.helptextimages addObject:@"sliderhelp4"];
        self.helptext = @"Move the numbers so they are in ascending order and the empty tile is last.\n\n\nBeat the current high scores!";
        
        transport = false;
        block = false;
    }
    
    self = [super init];
    self.block_one = -1;
    self.block_two = -1;
    self.transport_one = -1;
    self.transport_two = -1;
    if (self) {
        int MAX_SOLVIBILITY = 2;
        self.solvability = MAX_SOLVIBILITY;
        while (self.solvability >= MAX_SOLVIBILITY) {
            self.solvability = 0;
            
            if(self) {
                for ( int i=0; i < 16; i++) {
                    Tile *tile = [[Tile alloc] init];
                    tile.value = i;
                    [self addTile:tile];
                }
            }
            
            for ( int i=0; i < 16; i++) {
                Tile *tile = self.getRandomTile;
                [self.current addObject:[Board validValues][tile.value]];
            }
            
            if(transport != true) {
                if(!self.solvable) {
                    if(self.current[0] == [Board validValues][0] || self.current[1] == [Board validValues][0]) {
                        NSString *temp = self.current[3];
                        [self.current replaceObjectAtIndex:3 withObject:self.current[4]];
                        [self.current replaceObjectAtIndex:4 withObject:temp];
                    } else {
                        NSString *temp = self.current[0];
                        [self.current replaceObjectAtIndex:0 withObject:self.current[1]];
                        [self.current replaceObjectAtIndex:1 withObject:temp];
                        
                    }
                }
            }
            
            if (transport == true) {
                [self getTransports];
            }
            
            if (block == true) {
                [self getBlocks];
            }
            
            for (int i=0; i<15; i++) {
                if (self.current[i]==[Board validValues][i+1]) {
                    self.solvability++;
                }
                
            }
            if (self.solvability >= MAX_SOLVIBILITY) {
                [self.current removeAllObjects];
                [self.tiles removeAllObjects];
            }
        }
    }
    self.moves = 0;
    return self;
}

@end
