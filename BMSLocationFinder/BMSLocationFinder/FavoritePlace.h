//
//  FavoritePlace.h
//  BMSLocationFinder
//
//  Created by Ashutosh on 04/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FavoritePlace : NSManagedObject

@property (nonatomic, retain) NSString * placeId;
@property (nonatomic, retain) NSString * placeImageUrl;
@property (nonatomic, retain) NSString * placeName;
@property (nonatomic, retain) NSString * placeImagePhotoReference;
@property (nonatomic, retain) NSNumber * placeLatitude;
@property (nonatomic, retain) NSNumber * placeLongitude;

@end
