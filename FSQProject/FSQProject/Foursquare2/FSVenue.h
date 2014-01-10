//
//  VenueAnnotation.h
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface FSLocation : NSObject {
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,strong)NSNumber *distance;
@property (nonatomic,strong)NSString *address;

@end


@interface FSContact : NSObject

@property (nonatomic,strong)NSString *phone;
@property (nonatomic,strong)NSString *link;

@end


@interface FSVenue : NSObject<MKAnnotation>

@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *venueId;
@property (nonatomic,strong)NSString *categories;
@property (nonatomic,strong)NSString *categorieIconUrl;
@property (nonatomic,strong)FSLocation *location;
@property (nonatomic,strong)FSContact *contact;


@end
