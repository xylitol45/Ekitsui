//
//  CustomAnnotation.m
//  TestTwitter
//
//  Created by セラフ on 2013/11/08.
//  Copyright (c) 2013年 セラフ. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation
@synthesize coordinate;
@synthesize annotationTitle;
@synthesize annotationSubtitle;

- (NSString *)title {
    return annotationTitle;
}

- (NSString *)subtitle {
    return annotationSubtitle;
}

- (id)initWithLocationCoordinate:(CLLocationCoordinate2D) _coordinate
                           title:(NSString *)_annotationTitle subtitle:(NSString *)_annotationSubtitle {
    coordinate = _coordinate;
    self.annotationTitle = _annotationTitle;
    self.annotationSubtitle = _annotationSubtitle;
    return self;
}

//- (void) dealloc {
//    [annotationTitle release];
//    [annotationSubtitle release];
//    [super dealloc];
//}

@end