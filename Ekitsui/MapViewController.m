//
//  MapViewController.m
//  TestTwitter
//
//  Created by yoshimura on 2013/11/07.
//  Copyright (c) 2013年 セラフ. All rights reserved.
//

#import "MapViewController.h"
#import "CustomAnnotation.h"
#import "TwitterViewController.h"


@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) CLLocationManager *lm;
@property NSString* selectStationName;

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *_path = [[NSBundle mainBundle] pathForResource:@"Station" ofType:@"plist"];
	NSArray *_array = [NSArray arrayWithContentsOfFile:_path];
    
    for (int i = 0; i < [_array count]; i++) {

        NSDictionary *_dict = [_array objectAtIndex:i];
        NSArray *_array2 = [_dict objectForKey:@"line"];
        
        if (_array2 == nil){
            continue;
        }
        
        for (int j=0;j<[_array2 count];j++) {
            
            NSDictionary *_dict2 = [_array2 objectAtIndex:j];
            NSString *_line_name = [_dict2 objectForKey:@"line_name"];
            NSArray *_array3 = [_dict2 objectForKey:@"station"];
            
            if (_array3 == nil){
                continue;
            }
            
            for (int k=0;k<[_array3 count];k++) {
                
                NSDictionary *_dict3 = [_array3 objectAtIndex:k];
                
//                MKPointAnnotation* pin = [[MKPointAnnotation alloc] init];
//                pin.coordinate = CLLocationCoordinate2DMake([[_dict3 objectForKey:@"lat"] floatValue],[[_dict3 objectForKey:@"lon"] floatValue]);
//                [self.mapView addAnnotation:pin];
  
                CustomAnnotation *_pin =
                    [[CustomAnnotation alloc]
                      initWithLocationCoordinate:CLLocationCoordinate2DMake([[_dict3 objectForKey:@"lat"] floatValue],[[_dict3 objectForKey:@"lon"] floatValue])
                                                                                           title:[_dict3 objectForKey:@"station_name"]
                                                                                        subtitle:_line_name];
                [self.mapView addAnnotation:_pin];
                
                
            }
        }
    }
    

    self.lm = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]){ // 位置情報が取得可能か
        self.lm.delegate = self;
        
        //self.lm.distanceFilter = 100.0;
        //self.lm.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        
        [self.lm startUpdatingLocation]; // 位置取得開始
    } else {
        NSLog(@"ロケーションサービスを利用できません");
    }



}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    [manager stopUpdatingLocation];
    
    // 緯度経度取得の確認のため。
    NSLog(@"緯度:%fと経度%f", [newLocation coordinate].latitude,
          [newLocation coordinate].longitude);
    
    CLLocationCoordinate2D coordinate = newLocation.coordinate;

//    SimpleAnnotation* annotation = [[[SimpleAnnotation alloc] init] autorelease];
//    annotation.location = newLocation;
//    [self.mapview addAnnotation:annotation];

    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
//    CLLocationCoordinate2D centerCoordinate = location.coordinate;
    MKCoordinateRegion coordinateRegion =
    MKCoordinateRegionMake(coordinate, span);
    [self.mapView setRegion:coordinateRegion animated:YES];
/*
    
//    [self displayLocation];
    // 取得した座標を中心に地図を表示
    MKCoordinateRegion zoom = self.mapview.region;
    // どのくらいの範囲までズームするか。※値が小さいほどズームします
    zoom.span.latitudeDelta = 0.00001;
    zoom.span.longitudeDelta = 0.00001;
    // ズームする
    [self.mapview setRegion:zoom animated: YES];
    // 動きをつけながら表示
    [self.mapview setCenterCoordinate:coordinate animated:YES];
*/
    // ラベルに書き出す
/*    [locationlabel setText:[NSString stringWithFormat:
                            @"緯度:%.2f 経度:%.2f 方位:%.0f",
                            coordinate.latitude,
                            coordinate.longitude,
                            0]]; // 方位はシュミレータだと取得できなかったので、また今度。
*/
    
 }

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog([error localizedDescription]);
}


-(MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
	// 現在地表示なら nil を返す
	if (annotation == mapView.userLocation) {
		return nil;
	}
    
 	MKPinAnnotationView *annotationView;
	NSString* identifier = @"Pin";
 	annotationView = (MKPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
 	if(nil == annotationView) {
 		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] ;
 	}

//    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"test"];
    
	[annotationView setPinColor:MKPinAnnotationColorGreen];
	[annotationView setCanShowCallout:YES];
	[annotationView setAnimatesDrop:YES];
	[annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];

    
    // annotationView.image = [UIImage imageNamed:@"location.png"];
///	annotationView.canShowCallout = YES;
//	annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//	annotationView.annotation = annotation;
  
	return annotationView;
}

- (void) mapView:(MKMapView*)_mapView annotationView:(MKAnnotationView*)annotationView calloutAccessoryControlTapped:(UIControl*)control {
    // タップしたときの処理
    // annotationView.annotation でどのアノテーションか判定可能
    self.selectStationName = [[annotationView annotation] title];
    
    [self performSegueWithIdentifier:@"next TwitterViewController" sender:self];
    
//    NSLog([[annotationView annotation] title]);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Segueの特定
    if ( [[segue identifier] isEqualToString:@"next TwitterViewController"] ) {
        
        TwitterViewController *nextViewController = [segue destinationViewController];
        //ここで遷移先ビューのクラスの変数receiveStringに値を渡している
        nextViewController.receiveString = self.selectStationName;
    }
}

@end
