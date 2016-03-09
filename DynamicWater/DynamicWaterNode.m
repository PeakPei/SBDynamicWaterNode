//
//  DynamicWaterNode.m
//  DynamicWater
//
//  Created by Steve Barnegren on 07/03/2016.
//  Copyright © 2016 Steve Barnegren. All rights reserved.
//

#import "DynamicWaterNode.h"

//**********************************************
#pragma mark - ***** WaterJoint *****
//**********************************************

@interface WaterJoint : NSObject

@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat velocity;
@property (nonatomic) CGFloat damping;
@property (nonatomic) CGFloat tension;
@end

@implementation WaterJoint

-(instancetype)init{
    
    if (self = [super init]) {
        self.position = CGPointZero;
        self.velocity = 0;
        self.damping = 0;
        self.tension = 0;
    }
        return self;
}

-(void)setYPosition:(float)yPos{
    self.position = CGPointMake(self.position.x, yPos);
}

- (void)update:(NSTimeInterval)dt {
    
    CGFloat y = self.position.y;
    CGFloat acceleration = (-self.tension * y) - (self.velocity * self.damping);

    self.position = CGPointMake(self.position.x, self.position.y + (self.velocity * 60 * dt));
    self.velocity += acceleration * dt;
}

@end

//**********************************************
#pragma mark - ***** DynamicWaterNode *****
//**********************************************

@interface DynamicWaterNode ()
@property (nonatomic, strong) NSArray<WaterJoint*> *joints;
@property (nonatomic, strong) SKShapeNode *shapeNode;
@property float width;

@property CGPathRef path;

@end


@implementation DynamicWaterNode

#pragma mark - LifeCycle

-(instancetype)initWithWidth:(float)width numJoints:(NSInteger)numJoints surfaceHeight:(float)surfaceHeight fillColour:(UIColor*)fillColour{
    
    self = [super init];
    if (!self) { return nil; }
    
    // Init Properties
    self.surfaceHeight = surfaceHeight;
    self.width = width;
    
    // Shape Node
    self.shapeNode = [[SKShapeNode alloc]init];
    self.shapeNode.fillColor = fillColour;
    [self addChild:self.shapeNode];
    
    // Create joints
    NSMutableArray *mutableJoints = [[NSMutableArray alloc]initWithCapacity:numJoints];
    for (NSInteger i = 0; i < numJoints; i++) {
        WaterJoint *joint = [[WaterJoint alloc]init];
        CGPoint position;
        position.x = -(width/2) + ((width/(numJoints-1)) * i);
        position.y = 0;
        joint.position = position;
        [mutableJoints addObject:joint];
    }
    self.joints = [NSArray arrayWithArray:mutableJoints];
    
    // Set default simulation variables
    [self setDefaultValues];
   
    return self;
}

-(void)dealloc{
    CGPathRelease(self.path);
}

#pragma mark - Simulation Variables

-(void)setDefaultValues{
    self.tension = 1.8;
    self.damping = 2.4;
    self.spread = 9;
}

-(void)setTension:(float)tension{
    _tension = tension;
    for (WaterJoint *joint in self.joints) {
        joint.tension = tension;
    }
}

-(void)setDamping:(float)damping{
    _damping = damping;
    for (WaterJoint *joint in self.joints) {
        joint.damping = damping;
    }
}

#pragma mark - Splash

-(void)splashAtX:(float)xLocation force:(CGFloat)force{
    [self splashAtX:xLocation force:force width:0];
}

-(void)splashAtX:(float)xLocation force:(CGFloat)force width:(float)width{

    xLocation -= self.width/2;
    
    CGFloat shortestDistance = CGFLOAT_MAX;
    WaterJoint *closestJoint;
    
    for (WaterJoint *joint in self.joints) {
    
        CGFloat distance = fabs(joint.position.x - xLocation);
        if (distance < shortestDistance) {
            shortestDistance = distance;
            closestJoint = joint;
        }
    }
    
    closestJoint.velocity = -force;
    
    for (WaterJoint *joint in self.joints) {
        CGFloat distance = fabs(joint.position.x - closestJoint.position.x);
        if (distance < width) {
            joint.velocity = distance / width * -force;
        }
    }
    
}


#pragma mark - Update

-(void)update:(CFTimeInterval)dt{
    
    
    for (WaterJoint *joint in self.joints) {
        [joint update:dt];
    }
    
    float leftDeltas[self.joints.count];
    float rightDeltas[self.joints.count];
    
    for (NSInteger pass = 0; pass < 1; pass++) {
        
        for (NSInteger i = 0; i < self.joints.count; i++) {
            
            WaterJoint *currentJoint = self.joints[i];
            
            if (i > 0) {
                WaterJoint *previousJoint = self.joints[i-1];
                leftDeltas[i] = self.spread * (currentJoint.position.y - previousJoint.position.y);
                previousJoint.velocity += leftDeltas[i] * dt;
            }
            if (i < self.joints.count-1) {
                WaterJoint *nextJoint = self.joints[i+1];
                rightDeltas[i] = self.spread * (currentJoint.position.y - nextJoint.position.y);
                nextJoint.velocity += rightDeltas[i] * dt;
            }
        }
        
        for (NSInteger i = 0; i < self.joints.count; i++) {
            
            if (i > 0) {
                WaterJoint *previousJoint = self.joints[i-1];
                [previousJoint setYPosition:previousJoint.position.y + leftDeltas[i] * dt];
            }
            if (i < self.joints.count - 1) {
                WaterJoint *nextJoint = self.joints[i+1];
                [nextJoint setYPosition:nextJoint.position.y + rightDeltas[i] * dt];
            }
            
        }

    }
        
}

#pragma mark - Render

-(void)render{
    
    CGPathRelease(self.path);
    self.path = [self pathFromJoints:self.joints];
    
    [self.shapeNode setPath:self.path];
}

- (CGPathRef)pathFromJoints:(NSArray*)joints {
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    NSInteger index = 0;
    for (WaterJoint *joint in self.joints) {
        
        if (index == 0) {
            CGPathMoveToPoint(path,
                              nil,
                              joint.position.x,
                              joint.position.y + self.surfaceHeight);
        }
        else{
            CGPathAddLineToPoint(path,
                                 nil,
                                 joint.position.x,
                                 joint.position.y + self.surfaceHeight);
        }
        
        index++;
    }
    
    // Bottom Right
    CGPathAddLineToPoint(path,
                         nil,
                         self.width/2,
                         0);
    
    // Bottom Left
    CGPathAddLineToPoint(path,
                         nil,
                         -self.width/2,
                         0);
    
    CGPathCloseSubpath(path);

    
    return path;
}


@end
