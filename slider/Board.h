//
//  Board.h
//  Slider
//
//  Created by Monte Jeu on 9/28/13.
//  Copyright (c) 2013 Monte Jeu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tile.h"

@interface Board : NSObject

@property (nonatomic) NSInteger block_one;
@property (nonatomic) NSInteger block_two;
@property (nonatomic) NSInteger transport_one;
@property (nonatomic) NSInteger transport_two;
@property (strong,nonatomic) NSMutableArray *current;
@property (nonatomic) NSInteger moves;
@property (nonatomic) NSInteger solvability;

@property (nonatomic) NSString *background_image;
@property (nonatomic) NSString *highscorefile;
@property (nonatomic) NSString *solvedfile;
@property (nonatomic) NSString *helpseenfile;
@property (nonatomic) NSString *helpsegue;
@property (nonatomic) NSString *helptextbackground;
@property (nonatomic) NSMutableArray *helptextimages;
@property (nonatomic) NSString *helptext;
@property (nonatomic) NSInteger helptextfontsize;

- (void) addTile:(Tile *)tile;
- (BOOL) moveSlider:(NSString *) tile :(NSString *)level;
- (BOOL) moveSliderBasic:(NSString *) tile;
- (BOOL) moveSliderPlus:(NSString *) tile;
- (BOOL) moveSliderNext:(NSString *) tile;
- (BOOL) moveSliderFinal:(NSString *) tile;
- (BOOL) solvable;
- (BOOL) solved;
- (id) initWithName:(NSString *) level;
+ (NSArray *) validValues;
+ (NSArray *) validMoves;
+ (NSDictionary *) invalidblock;
- (NSString *) tileImage:(NSInteger) value;

@end
