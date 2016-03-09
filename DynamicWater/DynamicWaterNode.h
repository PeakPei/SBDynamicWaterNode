//
//  DynamicWaterNode.h
//  DynamicWater
//
//  Created by Steve Barnegren on 07/03/2016.
//  Copyright © 2016 Steve Barnegren. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface DynamicWaterNode : SKNode

@property float surfaceHeight;
@property (nonatomic) float tension;
@property (nonatomic) float damping;
@property float spread;

#pragma mark - Init
/** 
 Designated Initialiser.
 @param width The width of the water
 @param numJoints The number of joints used to simulate the waves. More joints will result in a smoother wave curve, fewer joints will look more jagged, but may may improve performance.
 @param surfaceHeight the height of the water's surface
 @param fillColour The colour of the water
 */
-(instancetype)initWithWidth:(float)width numJoints:(NSInteger)numJoints surfaceHeight:(float)surfaceHeight fillColour:(UIColor*)fillColour;

#pragma mark - Set Defaults
/** Reset simulation variables to defaults */
-(void)setDefaultValues;

#pragma mark - Update
/**
 Step the time of the simulation
 @param dt: delta time since last update
 */
-(void)update:(CFTimeInterval)dt;


#pragma mark - Splash
/**
 Make a splash (width will be 0)
 @param xLocation The X location to make the splash at
 @param force The force of the splash
 */
-(void)splashAtX:(float)xLocation force:(CGFloat)force;
/**
 Make a splash
 @param xLocation The X location to make the splash at
 @param force The force of the splash
 @param width the width of the splash
 */
-(void)splashAtX:(float)xLocation force:(CGFloat)force width:(float)width;

#pragma mark - Render
/**
 Render the water. Only call this once per frame. You can still call update to update the simulation multiple times per frame (eg. fixed time-step).
 */
-(void)render;

@end
