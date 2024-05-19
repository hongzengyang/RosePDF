//
//  HZCropView.m
//  RosePDF
//
//  Created by THS on 2024/3/6.
//

#import "HZCropView.h"
#import "HZCommonHeader.h"

#define kInitPadding 20

#define kCropButtonSize 46
#define kLineWidth 2.0f
#define kCircleLineWidth 2.0f
#define kCircleFillWidth 12.0f

#define kCircleColor  hz_getColor(@"FFFFFF")

#define PATH_VIEW_HEIGHT 48
#define PATH_VIEW_MARGIN (4*4)

@interface HZCropView () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, strong) NSMutableArray *points;

@property (nonatomic, assign) CGRect orgBounds;
@property (nonatomic, assign) CGFloat cropButnScale;

@property (nonatomic, strong) CAShapeLayer *layerA;
@property (nonatomic, strong) CAShapeLayer *layerB;
@property (nonatomic, strong) CAShapeLayer *layerC;
@property (nonatomic, strong) CAShapeLayer *layerD;

@property (nonatomic, strong) CAShapeLayer *layerE;
@property (nonatomic, strong) CAShapeLayer *layerF;
@property (nonatomic, strong) CAShapeLayer *layerG;
@property (nonatomic, strong) CAShapeLayer *layerH;

@property (strong, nonatomic) UIView *pointD;//左上
@property (strong, nonatomic) UIView *pointC;//左下
@property (strong, nonatomic) UIView *pointB;//右下
@property (strong, nonatomic) UIView *pointA;//右上
@property (strong, nonatomic) UIView *pointE,*pointF,*pointG,*pointH;  //middle point
@property (nonatomic, strong) UIView *activePoint;

@end


@implementation HZCropView {
    CGPoint a;
    CGPoint b;
    CGPoint c;
    CGPoint d;
    
    BOOL middlePoint;
    int currentIndex;
    int k;
}

@synthesize pointD = _pointD;
@synthesize pointC = _pointC;
@synthesize pointB = _pointB;
@synthesize pointA = _pointA;
@synthesize insets = _insets;

- (id)initWithFrame:(CGRect)frame insets:(UIEdgeInsets)insets
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.orgBounds = self.bounds;
        self.cropButnScale = 1.0;
        
        _insets = insets;
        //INIT
        self.points=[[NSMutableArray alloc] init];
        _pointA=[[UIView alloc] init];
        _pointB=[[UIView alloc] init];
        _pointC=[[UIView alloc] init];
        _pointD=[[UIView alloc] init];

        //middle Points
        _pointE=[[UIView alloc] init];
        _pointF=[[UIView alloc] init];
        _pointG=[[UIView alloc] init];
        _pointH=[[UIView alloc] init];

        CGFloat width = [self cropButnWidth];
        CGPoint center = CGPointMake(width/2.0, width/2.0);
        
        self.layerA = [self circleLayerWithCenter:center];
        self.layerB = [self circleLayerWithCenter:center];
        self.layerC = [self circleLayerWithCenter:center];
        self.layerD = [self circleLayerWithCenter:center];
        
        [_pointA.layer addSublayer:_layerA];
        [_pointB.layer addSublayer:_layerB];
        [_pointC.layer addSublayer:_layerC];
        [_pointD.layer addSublayer:_layerD];
        
        [self addSubview:_pointA];
        [self addSubview:_pointB];
        [self addSubview:_pointC];
        [self addSubview:_pointD];
        
        
        //middle
        
        self.layerE = [self circleLayerWithCenter:center];
        self.layerF = [self circleLayerWithCenter:center];
        self.layerG = [self circleLayerWithCenter:center];
        self.layerH = [self circleLayerWithCenter:center];
        
        [_pointE.layer addSublayer:_layerE];
        [_pointF.layer addSublayer:_layerF];
        [_pointG.layer addSublayer:_layerG];
        [_pointH.layer addSublayer:_layerH];
        
        [self addSubview:_pointE];
        [self addSubview:_pointF];
        [self addSubview:_pointG];
        [self addSubview:_pointH];
        
        [self.points addObject:_pointD];
        [self.points addObject:_pointC];
        [self.points addObject:_pointB];
        [self.points addObject:_pointA];
        
        
        //middle
        [self.points addObject:_pointE];
        [self.points addObject:_pointF];
        [self.points addObject:_pointG];
        [self.points addObject:_pointH];
        
        [self setPoints];
        [self setClipsToBounds:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        [self setContentMode:UIViewContentModeRedraw];
        [self setButtons];
        self.exclusiveTouch = YES;
        
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        recognizer.delegate = self;
        recognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:recognizer];
    }
    
    return self;
}

-(CAShapeLayer *)circleLayerWithCenter:(CGPoint)center
{
//    CGFloat scale = [UIScreen mainScreen].scale;
    
    CAShapeLayer *layer = [CAShapeLayer new];
    //圆环的宽度
    layer.lineWidth = [self circleLineWidth];
    //圆环的颜色
    layer.strokeColor =hz_getColor(@"2B96FA").CGColor;
    //背景填充色
    layer.fillColor = kCircleColor.CGColor;
    
    //初始化一个路径
    UIBezierPath *path = [self bezierPathWithCenter:center];
    layer.path = [path CGPath];
    
    return layer;
}

- (UIBezierPath *)bezierPathWithCenter:(CGPoint)center
{
    return [UIBezierPath bezierPathWithArcCenter:center radius:[self circleFillWidth]/2.0 startAngle:(0) endAngle:2*M_PI clockwise:YES];
}

- (CGFloat)circleLineWidth
{
    return _cropButnScale*kCircleLineWidth;
}

- (CGFloat)circleFillWidth
{
    return _cropButnScale*kCircleFillWidth;
}

- (NSArray *)getPoints
{
    NSMutableArray *p = [NSMutableArray array];
    
    CGFloat width = [self cropButnWidth];
    for (uint i=0; i<self.points.count; i++)
    {
        UIView *v = [self.points objectAtIndex:i];
        CGPoint point = CGPointMake(v.frame.origin.x +width/2, v.frame.origin.y +width/2);
        [p addObject:[NSValue valueWithCGPoint:point]];
    }
    
    return p;
}


- (void) resetFrame
{
    self.orgBounds = self.bounds;
    [self setPoints];
    [self setNeedsDisplay];
    [self drawRect:self.bounds];
    
    [self setButtons];
}

- (CGPoint)coordinatesForPoint: (int)point withScaleFactor: (CGFloat)scaleFactor
{
    CGPoint tmp = CGPointMake(0, 0);
    
    switch (point) {
        case 1:
            tmp = CGPointMake((_pointA.frame.origin.x+15) / scaleFactor, (_pointA.frame.origin.y+15) / scaleFactor);
            break;
        case 2:
            tmp = CGPointMake((_pointB.frame.origin.x+15) / scaleFactor, (_pointB.frame.origin.y+15) / scaleFactor);
            break;
        case 3:
            tmp = CGPointMake((_pointC.frame.origin.x+15) / scaleFactor, (_pointC.frame.origin.y+15) / scaleFactor);
            break;
        case 4:
            tmp =  CGPointMake((_pointD.frame.origin.x+15) / scaleFactor, (_pointD.frame.origin.y+15) / scaleFactor);
            break;
    }
    
    //DDLogInfo(@"%@", NSStringFromCGPoint(tmp));
    
    return tmp;
}

- (UIImage *)squareButtonWithWidth:(int)width
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

- (void)setPoints
{
    a = CGPointMake(0 + _insets.left, self.bounds.size.height - _insets.bottom);
    b = CGPointMake(self.bounds.size.width - _insets.right, self.bounds.size.height - _insets.bottom);
    c = CGPointMake(self.bounds.size.width - _insets.right, 0 + _insets.top);
    d = CGPointMake(0 + _insets.left, 0 + _insets.top);
}

- (void)setButtons
{
    CGFloat width = [self cropButnWidth];
    [_pointD setFrame:CGRectMake(d.x - width / 2, d.y - width / 2, width, width)];
    [_pointC setFrame:CGRectMake(c.x - width / 2,c.y - width / 2, width, width)];
    [_pointB setFrame:CGRectMake(b.x - width / 2, b.y - width / 2, width, width)];
    [_pointA setFrame:CGRectMake(a.x - width / 2, a.y - width / 2, width, width)];
    
    [self cornerControlsMiddle];
}

- (void)bottomLeftCornerToCGPoint: (CGPoint)point
{
    a = point;
    [self needsRedraw];
}

- (void)bottomRightCornerToCGPoint: (CGPoint)point
{
    b = point;
    [self needsRedraw];
}

- (void)topRightCornerToCGPoint: (CGPoint)point
{
    c = point;
    [self needsRedraw];
}

- (void)topLeftCornerToCGPoint: (CGPoint)point
{
    d = point;
    [self needsRedraw];
}

- (void)needsRedraw
{
    
    [self setNeedsDisplay];
    [self setButtons];
    [self cornerControlsMiddle];
    [self drawRect:self.bounds];
}

- (void)drawRect:(CGRect)rect;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        CGContextSetLineWidth(context, kLineWidth);//线的宽度
        UIColor *aColor = hz_getColorWithAlpha(@"2B96FA", 0.2);//blue蓝色
        aColor = [UIColor clearColor];
        CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
        aColor = hz_getColor(@"2B96FA");
        CGContextSetStrokeColorWithColor(context, aColor.CGColor);//线框颜色
        
        CGFloat width = [self cropButnWidth]/2.0;
        
        CGContextMoveToPoint(context, _pointA.frame.origin.x+width, _pointA.frame.origin.y+width);
        CGContextAddLineToPoint(context, _pointB.frame.origin.x+width, _pointB.frame.origin.y+width);
        CGContextAddLineToPoint(context, _pointC.frame.origin.x+width, _pointC.frame.origin.y+width);
        CGContextAddLineToPoint(context, _pointD.frame.origin.x+width, _pointD.frame.origin.y+width);
        
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
}

#pragma  mark Condition For Valid Rect

-(double)checkForNeighbouringPoints:(int)index{
    NSArray *points=[self getPoints];
    CGPoint p1;
    CGPoint p2 ;
    CGPoint p3;
    //    DDLogInfo(@"%d",index);
    
//    CGRect bounds = self.bounds;
    
    for (int i=0; i<points.count; i++) {
        switch (i) {
            case 0:{
                
                p1 = [[points objectAtIndex:0] CGPointValue];
                p2 = [[points objectAtIndex:1] CGPointValue];
                p3 = [[points objectAtIndex:3] CGPointValue];
                
            }
                break;
            case 1:{
                p1 = [[points objectAtIndex:1] CGPointValue];
                p2 = [[points objectAtIndex:2] CGPointValue];
                p3 = [[points objectAtIndex:0] CGPointValue];
                
            }
                break;
            case 2:{
                p1 = [[points objectAtIndex:2] CGPointValue];
                p2 = [[points objectAtIndex:3] CGPointValue];
                p3 = [[points objectAtIndex:1] CGPointValue];
                
            }
                break;
                
            default:{
                p1 = [[points objectAtIndex:3] CGPointValue];
                p2 = [[points objectAtIndex:0] CGPointValue];
                p3 = [[points objectAtIndex:2] CGPointValue];
                
            }
                break;
        }
        
        CGFloat distance = [HZCropView distanceBetween:p1 And:p2];
        
        if ([HZCropView isDistanceOverLimit:distance])
        {
            return 1;
        }
        else
        {
            distance = [HZCropView distanceBetween:p1 And:p3];
            if ([HZCropView isDistanceOverLimit:distance])
            {
                return 1;
            }
        }
        
        CGPoint ab=CGPointMake( p2.x - p1.x, p2.y - p1.y );
        CGPoint cb=CGPointMake( p2.x - p3.x, p2.y - p3.y );
        float dot = (ab.x * cb.x + ab.y * cb.y); // dot product
        float cross = (ab.x * cb.y - ab.y * cb.x); // cross product
        
        float alpha = atan2(cross, dot);

        if((-1*(float) floor(alpha * 180. / 3.14 + 0.5))<0)
        {
            return -1*(float) floor(alpha * 180. / 3.14 + 0.5);
        }
        
//        if (!CGRectContainsPoint(bounds, p1) || !CGRectContainsPoint(bounds, p2) || !CGRectContainsPoint(bounds, p3))
//        {
//            return 1;
//        }
    }
    return 0;
    
}

+(BOOL)isDistanceOverLimit:(CGFloat)distance
{
    return NO;
    BOOL flag =  (distance - (PATH_VIEW_HEIGHT + PATH_VIEW_MARGIN) < 0.00001);
    return flag;
}

-(void)swapTwoPoints
{
    if(k==2){
//        DDLogInfo(@"Swicth  2");
        if([self checkForHorizontalIntersection]){
            CGRect temp0=[[self.points objectAtIndex:0] frame];
            CGRect temp3=[[self.points objectAtIndex:3] frame];
            
            [[self.points objectAtIndex:0] setFrame:temp3];
            [[self.points objectAtIndex:3] setFrame:temp0];
            [self checkangle:0];
            [self cornerControlsMiddle];
            [self setNeedsDisplay];
        }
        if ([self checkForVerticalIntersection]) {
            CGRect temp0=[[self.points objectAtIndex:2] frame];
            CGRect temp3=[[self.points objectAtIndex:3] frame];
            
            [[self.points objectAtIndex:2] setFrame:temp3];
            [[self.points objectAtIndex:3] setFrame:temp0];
            [self checkangle:0];
            [self cornerControlsMiddle];
            [self setNeedsDisplay];
        }
        
        
    }
    else{
        
//        DDLogInfo(@"Swicth More then 2");
        CGRect temp2=[[self.points objectAtIndex:2] frame];
        CGRect temp0=[[self.points objectAtIndex:0] frame];
        
        [[self.points objectAtIndex:0] setFrame:temp2];
        [[self.points objectAtIndex:2] setFrame:temp0];
        [self cornerControlsMiddle];
        [self setNeedsDisplay];
        
    }
    
}

-(void)checkangle:(int)index{
    NSArray *points=[self getPoints];
    CGPoint p1;
    CGPoint p2 ;
    CGPoint p3;
    
//    DDLogInfo(@"%d",index);
    k=0;
    
    for (int i=0; i<points.count; i++) {
        switch (i) {
            case 0:{
                
                p1 = [[points objectAtIndex:0] CGPointValue];
                p2 = [[points objectAtIndex:1] CGPointValue];
                p3 = [[points objectAtIndex:3] CGPointValue];
                
            }
                break;
            case 1:{
                p1 = [[points objectAtIndex:1] CGPointValue];
                p2 = [[points objectAtIndex:2] CGPointValue];
                p3 = [[points objectAtIndex:0] CGPointValue];
                
            }
                break;
            case 2:{
                p1 = [[points objectAtIndex:2] CGPointValue];
                p2 = [[points objectAtIndex:3] CGPointValue];
                p3 = [[points objectAtIndex:1] CGPointValue];
                
            }
                break;
                
            default:{
                p1 = [[points objectAtIndex:3] CGPointValue];
                p2 = [[points objectAtIndex:0] CGPointValue];
                p3 = [[points objectAtIndex:2] CGPointValue];
                
            }
                break;
        }
        
        
        CGPoint ab=CGPointMake( p2.x - p1.x, p2.y - p1.y );
        CGPoint cb=CGPointMake( p2.x - p3.x, p2.y - p3.y );
        float dot = (ab.x * cb.x + ab.y * cb.y); // dot product
        float cross = (ab.x * cb.y - ab.y * cb.x); // cross product
        
        float alpha = atan2(cross, dot);
        
        
        if((-1*(float) floor(alpha * 180. / 3.14 + 0.5))<0){
            ++k;
            
        }
        
    }

    if(k>=2){
        
        [self swapTwoPoints];
        
    }
    
}

-(BOOL)checkForHorizontalIntersection
{
    CGLine line1 = CGLineMake(CGPointMake([[self.points objectAtIndex:0] frame].origin.x, [[self.points objectAtIndex:0] frame].origin.y), CGPointMake([[self.points objectAtIndex:1] frame].origin.x, [[self.points objectAtIndex:1] frame].origin.y));
    
    CGLine line2 = CGLineMake(CGPointMake([[self.points objectAtIndex:2] frame].origin.x, [[self.points objectAtIndex:2] frame].origin.y), CGPointMake([[self.points objectAtIndex:3] frame].origin.x, [[self.points objectAtIndex:3] frame].origin.y));
    
    
    //    DDLogInfo(@"Horizontal%f %f",CGLinesIntersectAtPoint(line1, line2).x,CGLinesIntersectAtPoint(line1, line2).y);
    
    CGPoint temp=CGLinesIntersectAtPoint(line1, line2);
    if(temp.x!=INFINITY  && temp.y!=INFINITY){
        return YES;
    }
    
    return NO;
    
    
}

-(BOOL)checkForVerticalIntersection{
    CGLine line3 = CGLineMake(CGPointMake([[self.points objectAtIndex:0] frame].origin.x, [[self.points objectAtIndex:0] frame].origin.y), CGPointMake([[self.points objectAtIndex:3] frame].origin.x, [[self.points objectAtIndex:3] frame].origin.y));
    
    CGLine line4 = CGLineMake(CGPointMake([[self.points objectAtIndex:2] frame].origin.x, [[self.points objectAtIndex:2] frame].origin.y), CGPointMake([[self.points objectAtIndex:1] frame].origin.x, [[self.points objectAtIndex:1] frame].origin.y));
    
    //     DDLogInfo(@"Verical %f %f",CGLinesIntersectAtPoint(line3, line4).x,CGLinesIntersectAtPoint(line3, line4).y);
    
    CGPoint temp=CGLinesIntersectAtPoint(line3, line4);
    if(temp.x!=INFINITY  && temp.y!=INFINITY){
        return YES;
    }
    
    return NO;
}

#pragma mark - Support methods


+(CGFloat)distanceBetween:(CGPoint)first And:(CGPoint)last{
    CGFloat xDist = (last.x - first.x);
    if(xDist<0) xDist=xDist*-1;
    CGFloat yDist = (last.y - first.y);
    if(yDist<0) yDist=yDist*-1;
    return sqrt((xDist * xDist) + (yDist * yDist));
}

-(void)findPointAtLocation:(CGPoint)location{
    self.activePoint.backgroundColor = [UIColor clearColor];
    self.activePoint = nil;
    CGFloat smallestDistance = INFINITY;
    int i=0;
    for (UIView *point in self.points)
    {
        
        CGRect extentedFrame = CGRectInset(point.frame, -20, -20);
        
        //        DDLogInfo(@"For Point %d Location%f %f and Point %f %f",i,location.x,location.y,point.frame.origin.x,point.frame.origin.y);
        if (CGRectContainsPoint(extentedFrame, location))
        {
            CGFloat distanceToThis = [HZCropView distanceBetween:point.frame.origin And:location];
//            DDLogInfo(@"Distance%f",distanceToThis);
            if(distanceToThis<smallestDistance){
                self.activePoint = point;
                
                smallestDistance = distanceToThis;
                currentIndex=i;
                
                if(i==4 || i==5 || i==6 || i==7){
                    middlePoint=YES;
                }
                else{
                    middlePoint=NO;
                }
            }
        }
        i++;
    }
    
//    DDLogInfo(@"Active Point%@",self.activePoint);
    
}

- (void)moveActivePointToLocation:(CGPoint)locationPoint offset:(CGPoint)offset
{
    //    DDLogInfo(@"location: %f,%f", locationPoint.x, locationPoint.y);
    CGFloat newX = locationPoint.x;
    CGFloat newY = locationPoint.y;
    
    //cap off possible values
    if(newX<_orgBounds.origin.x){
        newX=_orgBounds.origin.x;
    }else if(newX>_orgBounds.size.width){
        newX = _orgBounds.size.width;
    }
    if(newY<_orgBounds.origin.y){
        newY=_orgBounds.origin.y;
    }else if(newY>_orgBounds.size.height){
        newY = _orgBounds.size.height;
    }
    
    locationPoint = CGPointMake(newX, newY);
    
    if (self.activePoint && !middlePoint)
    {
        CGRect orgFrame = self.activePoint.frame;
        CGFloat width = [self cropButnWidth];
        
        self.activePoint.frame = CGRectMake(locationPoint.x -width/2, locationPoint.y -width/2, width, width);
        
        if ([self checkForNeighbouringPoints:currentIndex])
        {
            self.activePoint.frame = orgFrame;
            return;
        }
        
        [self cornerControlsMiddle];
    }
    else
    {
        [self movePointsForMiddle:locationPoint offset:offset];
        
        if([self checkForNeighbouringPoints:currentIndex])
        {
            [self movePointsForMiddle:CGPointMake(locationPoint.x - offset.x, locationPoint.y - offset.y) offset:CGPointMake(-offset.x, -offset.y)];
            return;
        }
    }
    
    if ([_delegate respondsToSelector:@selector(viewingAtPoint:)])
    {
        [_delegate viewingAtPoint:self.activePoint.center];
    }
    
    [self setNeedsDisplay];
}

//Corner Touch
-(void)cornerControlsMiddle
{
    CGFloat width = [self cropButnWidth];
    self.pointH.frame=CGRectMake((self.pointA.frame.origin.x+self.pointD.frame.origin.x)/2, (self.pointA.frame.origin.y+self.pointD.frame.origin.y)/2, width, width);
    self.pointE.frame=CGRectMake((self.pointA.frame.origin.x+self.pointB.frame.origin.x)/2, (self.pointA.frame.origin.y+self.pointB.frame.origin.y)/2, width, width);
    self.pointF.frame=CGRectMake((self.pointB.frame.origin.x+self.pointC.frame.origin.x)/2, (self.pointB.frame.origin.y+self.pointC.frame.origin.y)/2, width, width);
    self.pointG.frame=CGRectMake((self.pointC.frame.origin.x+self.pointD.frame.origin.x)/2, (self.pointC.frame.origin.y+self.pointD.frame.origin.y)/2, width, width);
    
//    CGFloat a1 = angleBetweenPoints(self.pointB.center,self.pointC.center);
//    CGFloat a2 = angleBetweenPoints(self.pointA.center,self.pointB.center);
//    CGFloat a3 = angleBetweenPoints(self.pointA.center,self.pointD.center);
//    CGFloat a4 = angleBetweenPoints(self.pointC.center,self.pointD.center);

//    [self.pointF updateDragViewWithDegree:a1];
//    [self.pointE updateDragViewWithDegree:a2];
//    [self.pointH updateDragViewWithDegree:a3];
//    [self.pointG updateDragViewWithDegree:a4];
}

#define radiansToDegrees(x) (180.0*(x) / M_PI)

CGFloat angleBetweenPoints(CGPoint first, CGPoint second)
{
    CGFloat height = second.y - first.y;
    CGFloat width = first.x - second.x;
    CGFloat rads = atan(height/width);
    CGFloat ang = radiansToDegrees(rads);
    
    return -(M_PI*(ang/180.0) + 0.5*M_PI);
}

//Middle Touch
- (void)movePointsForMiddle:(CGPoint)locationPoint offset:(CGPoint)offset
{
    CGFloat width = [self cropButnWidth];
    switch (currentIndex)
    {
        case 4:
        {
            CGFloat axOffset = [self xOffsetWithPointX:self.pointD.frame.origin pointY:self.pointA.frame.origin yOffset:offset.y];
            CGFloat bxOffset = [self xOffsetWithPointX:self.pointC.frame.origin pointY:self.pointB.frame.origin yOffset:offset.y];

            self.pointA.frame=CGRectMake(fmaxf(self.pointA.frame.origin.x + axOffset, -(width-kLineWidth)/2), fminf(self.pointA.frame.origin.y + offset.y, _orgBounds.size.height-(width+kLineWidth)/2), width, width);
            self.pointB.frame=CGRectMake(fminf(self.pointB.frame.origin.x + bxOffset, _orgBounds.size.width-(width+kLineWidth)/2), fminf(self.pointB.frame.origin.y + offset.y, _orgBounds.size.height-(width+kLineWidth)/2), width, width);
        }
            
            break;
            
        case 5:
        {
            CGFloat byOffset = [self yOffsetWithPointX:self.pointA.frame.origin pointY:self.pointB.frame.origin xOffset:offset.x];
            CGFloat cyOffset = [self yOffsetWithPointX:self.pointD.frame.origin pointY:self.pointC.frame.origin xOffset:offset.x];
            
            self.pointB.frame=CGRectMake(fminf(self.pointB.frame.origin.x + offset.x, _orgBounds.size.width-(width+kLineWidth)/2), fminf(self.pointB.frame.origin.y + byOffset, _orgBounds.size.height+(width-kLineWidth)/2), width, width);
            self.pointC.frame=CGRectMake(fminf(self.pointC.frame.origin.x + offset.x, _orgBounds.size.width-(width+kLineWidth)/2), fmaxf(self.pointC.frame.origin.y + cyOffset, -(width-kLineWidth)/2), width, width);
        }
            break;
        case 6:
        {
            CGFloat cxOffset = [self xOffsetWithPointX:self.pointB.frame.origin pointY:self.pointC.frame.origin yOffset:offset.y];
            CGFloat dxOffset = [self xOffsetWithPointX:self.pointA.frame.origin pointY:self.pointD.frame.origin yOffset:offset.y];
            
            self.pointC.frame=CGRectMake(fminf(self.pointC.frame.origin.x + cxOffset, _orgBounds.size.width-(width+kLineWidth)/2), fmaxf(self.pointC.frame.origin.y + offset.y, -(width-kLineWidth)/2), width, width);
            self.pointD.frame=CGRectMake(fmaxf(self.pointD.frame.origin.x + dxOffset, -(width-kLineWidth)/2), fmaxf(self.pointD.frame.origin.y + offset.y, -(width-kLineWidth)/2), width, width);
        }
            break;
        case 7:
        {
            CGFloat ayOffset = [self yOffsetWithPointX:self.pointB.frame.origin pointY:self.pointA.frame.origin xOffset:offset.x];
            CGFloat dyOffset = [self yOffsetWithPointX:self.pointC.frame.origin pointY:self.pointD.frame.origin xOffset:offset.x];
            
            self.pointA.frame=CGRectMake(fmaxf(self.pointA.frame.origin.x + offset.x, -(width-kLineWidth)/2), fminf(self.pointA.frame.origin.y + ayOffset, _orgBounds.size.height+(width-kLineWidth)/2), width, width);
            self.pointD.frame=CGRectMake(fmaxf(self.pointD.frame.origin.x + offset.x, -(width-kLineWidth)/2), fmaxf(self.pointD.frame.origin.y + dyOffset, -(width-kLineWidth)/2), width, width);
        }
            break;
        default:
            break;
    }
    [self cornerControlsMiddle];
}

-(CGFloat)xOffsetWithPointX:(CGPoint)pointX pointY:(CGPoint)pointY yOffset:(CGFloat)yOffset
{
    CGFloat xOffset = 0;
    
    CGFloat tmp = pointY.y - pointX.y;
    if (tmp != 0)
    {
        xOffset = yOffset*(pointY.x - pointX.x)/tmp;
    }
    
    return xOffset;
}

-(CGFloat)yOffsetWithPointX:(CGPoint)pointX pointY:(CGPoint)pointY xOffset:(CGFloat)xOffset
{
    CGFloat yOffset = 0;
    
    CGFloat tmp = pointY.x - pointX.x;
    if (tmp != 0)
    {
        yOffset = xOffset*(pointY.y - pointX.y)/tmp;
    }
    
    return yOffset;
}

#pragma mark -

CGPoint orgnalPoint;

#if 1

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (void)panGestureRecognizer:(UITapGestureRecognizer *)tapGesture
{
    switch (tapGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            orgnalPoint = [tapGesture locationInView:self];
            
            if ([_delegate respondsToSelector:@selector(touchsBegan)])
            {
                [_delegate touchsBegan];
            }
            
            [self findPointAtLocation:orgnalPoint];
            self.activePoint.layer.sublayers.firstObject.hidden = YES;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint currentPoint = [tapGesture locationInView:self];
            
            CGRect bounds = _orgBounds;
            CGFloat width = [self cropButnWidth];
            
            currentPoint.x = MIN(bounds.size.width+width/2.0, currentPoint.x);
            currentPoint.x = MAX(-width/2.0, currentPoint.x);

            currentPoint.y = MIN(bounds.size.height+width/2.0, currentPoint.y);
            currentPoint.y = MAX(-width/2.0, currentPoint.y);
            
            [self moveActivePointToLocation:currentPoint offset:CGPointMake(currentPoint.x - orgnalPoint.x, currentPoint.y - orgnalPoint.y)];
            orgnalPoint = currentPoint;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            orgnalPoint = CGPointZero;
            self.activePoint.layer.sublayers.firstObject.hidden = NO;
            self.activePoint = nil;
            [self checkangle:0];
            
            if ([_delegate respondsToSelector:@selector(stopViewing)])
            {
                [_delegate stopViewing];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            if ([_delegate respondsToSelector:@selector(touchsCancelled)])
            {
                [_delegate touchsCancelled];
            }
        }
            break;
        default:
            break;
    }
}
#else

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    orgnalPoint = [touch locationInView:self];
    
    if ([_delegate respondsToSelector:@selector(touchsBegan)])
    {
        [_delegate touchsBegan];
    }
    
    [self findPointAtLocation:orgnalPoint];
    self.activePoint.layer.sublayers.firstObject.hidden = YES;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    CGRect bounds = self.bounds;
    
    currentPoint.x = MIN(bounds.size.width, currentPoint.x);
    currentPoint.x = MAX(0, currentPoint.x);

    currentPoint.y = MIN(bounds.size.height, currentPoint.y);
    currentPoint.y = MAX(0, currentPoint.y);

    [self moveActivePointToLocation:currentPoint offset:CGPointMake(currentPoint.x - orgnalPoint.x, currentPoint.y - orgnalPoint.y)];
    orgnalPoint = currentPoint;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
    
    if ([_delegate respondsToSelector:@selector(touchsCancelled)])
    {
        [_delegate touchsCancelled];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    orgnalPoint = CGPointZero;
    self.activePoint.layer.sublayers.firstObject.hidden = NO;
    self.activePoint = nil;
    [self checkangle:0];
    
    if ([_delegate respondsToSelector:@selector(stopViewing)])
    {
        [_delegate stopViewing];
    }
}
#endif

#pragma mark -
-(NSArray *)cornerPoints
{
    CGSize size = self.frame.size;
    NSMutableArray *array = nil;
    
    if ((_pointD.center.x < 0.5) && (_pointD.center.y < 0.5) && (size.width - _pointC.center.x < 0.5)  && (_pointC.center.y < 0.5) && (size.width - _pointB.center.x < 0.5) && (size.height - _pointB.center.y < 0.5 ) && (_pointA.center.x < 0.5) && (size.height - _pointA.center.y < 0.5))
    {
        return array;
    }
    else
    {
        array = [[NSMutableArray alloc] initWithCapacity:4];
        [array addObject:@(_pointD.center)];
        [array addObject:@(_pointA.center)];
        [array addObject:@(_pointB.center)];
        [array addObject:@(_pointC.center)];
    }
    return array;
}

-(void)setCornerPoints:(NSArray *)points
{
    NSArray *checkedArray = nil;
    if ([points isKindOfClass:[NSArray class]] && points.count == 4)
    {
        checkedArray = points;
    }
    else
    {
        CGSize size = _orgBounds.size;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:4];
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(0, size.height)]];
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(size.width, size.height)]];
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(size.width, 0)]];
        checkedArray = array;
    }
    if (checkedArray)
    {
        if ([HZCropView isCornerPointsValidate:checkedArray])
        {
            _pointD.center = [checkedArray[0] CGPointValue];
            _pointA.center = [checkedArray[1] CGPointValue];
            _pointB.center = [checkedArray[2] CGPointValue];
            _pointC.center = [checkedArray[3] CGPointValue];
            
            [self cornerControlsMiddle];
            [self setNeedsDisplay];
        }
    }
}

+(BOOL)isCornerPointsValidate:(NSArray *)points
{
    __block BOOL containNAN = NO;
    [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = [obj CGPointValue];
        if (isnan(point.x) || isnan(point.y)) {
            containNAN = YES;
        }
    }];
    if (containNAN) {
        return NO;
    }
    
    CGFloat distance = [self distanceBetween:[points[0] CGPointValue] And:[points[1] CGPointValue]];
    
    if ([self isDistanceOverLimit:distance])
    {
        return NO;
    }
    
    distance = [self distanceBetween:[points[0] CGPointValue] And:[points[3] CGPointValue]];
    
    if ([self isDistanceOverLimit:distance])
    {
        return NO;
    }
    
    distance = [self distanceBetween:[points[1] CGPointValue] And:[points[2] CGPointValue]];
    
    if ([self isDistanceOverLimit:distance])
    {
        return NO;
    }
    
    distance = [self distanceBetween:[points[1] CGPointValue] And:[points[3] CGPointValue]];
    
    if ([self isDistanceOverLimit:distance])
    {
        return NO;
    }
    
    return YES;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = NO;
    
    for (NSInteger index = 0; index < _points.count; index ++)
    {
        UIView *cornerView = _points[index];
        
        CGPoint insidePoint = [self convertPoint:point toView:cornerView];
        
        if (CGRectContainsPoint(cornerView.bounds, insidePoint))
        {
            inside = YES;
            break;
        }
    }
    
    return inside;
}

-(void)hideCornerPoints
{
    _pointA.hidden = YES;
    _pointB.hidden = YES;
    _pointC.hidden = YES;
    _pointD.hidden = YES;
    _pointE.hidden = YES;
    _pointF.hidden = YES;
    _pointG.hidden = YES;
    _pointH.hidden = YES;
}

-(void)showCornerPoints
{
    _pointA.hidden = NO;
    _pointB.hidden = NO;
    _pointC.hidden = NO;
    _pointD.hidden = NO;
    _pointE.hidden = NO;
    _pointF.hidden = NO;
    _pointG.hidden = NO;
    _pointH.hidden = NO;
}

#pragma mark -

- (void)changePointsScale:(CGFloat)scale
{
    if (_cropButnScale != scale)
    {
        self.cropButnScale = scale;
        CGFloat width = [self cropButnWidth];
        CGPoint centerD = _pointD.center;
        CGPoint centerA = _pointA.center;
        CGPoint centerB = _pointB.center;
        CGPoint centerC = _pointC.center;
        
        _pointD.frame = CGRectMake(centerD.x-width/2.0, centerD.y-width/2.0, width, width);
        _pointA.frame = CGRectMake(centerA.x-width/2.0, centerA.y-width/2.0, width, width);
        _pointB.frame = CGRectMake(centerB.x-width/2.0, centerB.y-width/2.0, width, width);
        _pointC.frame = CGRectMake(centerC.x-width/2.0, centerC.y-width/2.0, width, width);
        
        CGFloat lineWidth = [self circleLineWidth];
        _layerA.lineWidth = lineWidth;
        _layerB.lineWidth = lineWidth;
        _layerC.lineWidth = lineWidth;
        _layerD.lineWidth = lineWidth;
        _layerE.lineWidth = lineWidth;
        _layerF.lineWidth = lineWidth;
        _layerG.lineWidth = lineWidth;
        _layerH.lineWidth = lineWidth;
        
        UIBezierPath *path = [self bezierPathWithCenter:CGPointMake(width/2.0, width/2.0)];
        _layerA.path = [path CGPath];
        _layerB.path = [path CGPath];
        _layerC.path = [path CGPath];
        _layerD.path = [path CGPath];
        _layerE.path = [path CGPath];
        _layerF.path = [path CGPath];
        _layerG.path = [path CGPath];
        _layerH.path = [path CGPath];
        
        [self cornerControlsMiddle];
        [self setNeedsDisplay];
    }
}

- (CGFloat)cropButnWidth
{
    return _cropButnScale * kCropButtonSize;
}

@end

