//
//  RingProgressView.m
//  RingProgressView
//
//  Created by xiaominfc on 3/11/15.
//  Copyright (c) 2015 fc. All rights reserved.
//

#import "RingProgressView.h"


#define CIRCLEWIDTH 80.0f

#define HALFCIRCLEWIDTH (CIRCLEWIDTH / 2)

#define LINELENGHT 100.0f

#define HALFLINELEGHT (LINELENGHT / 2)

#define PAINTWIDTH 10.0f

#define FULLLENGTH (LINELENGTH * 2 + CIRCLEWIDTH * M_PI)

#define PADDINGLEFT 10.0f
#define PADDINGTOP  10.0f

#define THUMBWIDTH 24.0f


#define BACKGROUNDCOLOR @"#5f5f5f"




@interface TouchThumb : NSObject

@property(strong)UIImage *thumbImage;
@property()CGPoint point;
@property()float progress;

-(void)draw:(CGContextRef)currentContext;

-(void)updatePoint:(float)x : (float)y;

@end
@implementation TouchThumb


-(id)init{
    self = [super init];
    if(self){
        self.thumbImage = [UIImage imageNamed:@"time_horizhon_thumb_image"];
    }
    return self;
}

-(void)draw:(CGContextRef)currentContext
{
    CGFloat left = self.point.x - THUMBWIDTH / 2;
    CGFloat top = self.point.y - THUMBWIDTH / 2;
    [self.thumbImage drawInRect:CGRectMake(left, top, THUMBWIDTH, THUMBWIDTH)];
}


-(void)updatePoint:(float)x :(float)y
{
    self.point = CGPointMake(x, y);
}

-(BOOL)containPoint:(CGPoint)point
{
    CGFloat width = sqrt(pow(self.point.x - point.x, 2) + pow(self.point.y - point.y, 2));
    if(width < THUMBWIDTH / 2){
        return YES;
    }
    
    return NO;
}

@end



@interface RingProgressView()

@property() CGRect leftRect;
@property() CGRect rightRect;
@property(strong)TouchThumb *startTouchThumb;
@property(strong)TouchThumb *mTouchThumb;
@property() CGPoint lastPoint;
@property() BOOL isMoving;
+(CGFloat)getOtherSide:(CGFloat)side;

@end


@implementation RingProgressView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSLog(@"init");
        float leftSidePadding = PAINTWIDTH + PADDINGLEFT;
        float topSidePadding = PAINTWIDTH + PADDINGTOP;
        self.leftRect = CGRectMake(leftSidePadding,topSidePadding,CIRCLEWIDTH,CIRCLEWIDTH);
        self.rightRect = CGRectMake(leftSidePadding + LINELENGHT,topSidePadding,CIRCLEWIDTH,CIRCLEWIDTH);
        self.startTouchThumb = [[TouchThumb alloc] init];
        self.startTouchThumb.point = CGPointMake((HALFCIRCLEWIDTH + HALFLINELEGHT), 0);
        self.isMoving = NO;
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self drawBackgroudPath];
    [self drawThumbs];
    
    NSLog(@"%f",HALFCIRCLEWIDTH);
}

-(void)drawThumbs{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    CGContextTranslateCTM(currentContext, self.leftRect.origin.x + HALFCIRCLEWIDTH + HALFLINELEGHT, self.leftRect.origin.y + HALFCIRCLEWIDTH);
    [self.startTouchThumb draw:currentContext];
    CGContextRestoreGState(currentContext);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if(touches.count == 1) {
        self.lastPoint = [self touchPoint:touches];
        CGPoint convertPoint = CGPointMake(self.lastPoint.x - (self.leftRect.origin.x + HALFCIRCLEWIDTH + HALFLINELEGHT), self.lastPoint.y - (self.leftRect.origin.y + HALFCIRCLEWIDTH));
        if([self.startTouchThumb containPoint:convertPoint] && !self.isMoving) {
            self.mTouchThumb = self.startTouchThumb;
            self.isMoving = YES;
        }
    }
}


-(CGPoint)touchPoint:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch  locationInView:self];
    return point;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if(self.isMoving) {
        CGPoint nowPoint = [self touchPoint:touches];
        [self updateTouchThumbByOffsetX:(nowPoint.x - self.lastPoint.x) withOffsetY:(nowPoint.y - self.lastPoint.y)];
        [self setNeedsDisplay];
        
//        if(abs(self.mTouchThumb.point.y) == HALFCIRCLEWIDTH) {
//            self.lastPoint = nowPoint;
////           self.lastPoint = CGPointMake(self.mTouchThumb.point.x + (self.leftRect.origin.x + HALFCIRCLEWIDTH + HALFLINELEGHT) , self.mTouchThumb.point.y + (self.leftRect.origin.y + HALFCIRCLEWIDTH));
//        }else {
//            self.lastPoint = nowPoint;
//        }
        self.lastPoint = nowPoint;
    }
    
    
   
    NSLog(@"moved");
}

-(void)resetAll{
    self.isMoving = NO;
    self.mTouchThumb = nil;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self resetAll];
}


-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self resetAll];
}


+(CGFloat)getOtherSide:(CGFloat)side{
    return (int) sqrt(pow(CIRCLEWIDTH / 2, 2) - pow(side, 2));
}


-(void)updateTouchThumbByOffsetX:(CGFloat)offsetX withOffsetY:(CGFloat)offsetY
{
    CGFloat newX = self.mTouchThumb.point.x  + offsetX;
    CGFloat newY = 0;
    
    if(self.mTouchThumb.point.x >= -(HALFLINELEGHT + HALFCIRCLEWIDTH / 2) && self.mTouchThumb.point.x <= (HALFLINELEGHT + HALFCIRCLEWIDTH / 2)){
        if (newX >= -LINELENGHT / 2 && newX < LINELENGHT / 2) {
            if (self.mTouchThumb.point.y > 0) {
                newY = HALFCIRCLEWIDTH;
            } else {
                newY = -HALFCIRCLEWIDTH;
            }
            
        } else {
            CGFloat tmp = [RingProgressView getOtherSide:(abs(newX) - LINELENGHT / 2)];
            
            if (self.mTouchThumb.point.y < 0) {
                newY = -tmp;
            } else {
                newY = tmp;
            }
        }
    }else {
        newY = self.mTouchThumb.point.y + offsetY;
        CGFloat tmp = [RingProgressView getOtherSide:(newY)];
        if (self.mTouchThumb.point.x < 0) {
            newX = -(tmp + LINELENGHT / 2);
        } else {
            newX = (tmp + LINELENGHT / 2);
        }
    }
    self.mTouchThumb.point = CGPointMake(newX, newY);
    
}




-(void)drawBackgroudPath{
    
    [[RingProgressView colorWithHexString:BACKGROUNDCOLOR]set];
    
    /* Get the current graphics context */
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    /* Set the width for the lines */
    CGContextSetLineWidth(currentContext,PAINTWIDTH);

    CGContextAddArc(currentContext, self.leftRect.origin.x + self.leftRect.size.width / 2, self.leftRect.origin.y + self.leftRect.size.height / 2, HALFCIRCLEWIDTH, M_PI / 2.0 , M_PI * 3.0 / 2.0 , 0);
    
    
    CGContextAddArc(currentContext, self.rightRect.origin.x + self.rightRect.size.width / 2, self.rightRect.origin.y + self.rightRect.size.height / 2, HALFCIRCLEWIDTH, - M_PI / 2.0 , M_PI / 2.0 , 0);
    
    
    CGContextMoveToPoint(currentContext, self.leftRect.origin.x + self.leftRect.size.width / 2, self.leftRect.origin.y + self.leftRect.size.height );
    
    CGContextAddLineToPoint(currentContext, self.rightRect.origin.x + self.rightRect.size.width / 2, self.rightRect.origin.y + self.rightRect.size.height);
    
    CGContextStrokePath(currentContext);
    
}



+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if (!([cString length] == 6 || [cString length] == 8))
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *aString = @"FF";
    //a
    
    if([cString length] == 8)
    {
        aString = [cString substringWithRange:range];
        range.location = range.location + 2;
    }
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = range.location + 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = range.location + 2;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int a,r, g, b;
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:((float) a / 255.0f)];
}

@end
