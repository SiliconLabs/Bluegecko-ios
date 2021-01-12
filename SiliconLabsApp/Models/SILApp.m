//
//  SILApp.m
//  SiliconLabsApp
//
//  Created by Colden Prime on 1/13/15.
//  Copyright (c) 2015 SiliconLabs. All rights reserved.
//

#import "SILApp.h"
#import "UIImage+SILImages.h"

@implementation SILApp

+ (NSArray *)demoApps {
    return @[
                [self healthThermometerApp],
                [self connectedLightningApp],
                [self rangeTestApp],
            ];
}

+ (NSArray *)developApps {
    return @[
                [self bluetoothBrowserApp],
                [self advertiserApp],
            ];
}

+ (SILApp *)connectedLightningApp {
    return [[SILApp alloc] initWithAppType:SILAppTypeConnectedLighting
                                     title:@"Connected Lighting"
                               description:@"Control a Dynamic Multiprotocol application of connected lights and switches."
                         showcasedProfiles:@{}
                                 imageName:SILImageNameHomeConnectedLighting];
}

+ (SILApp *)healthThermometerApp {
    return [[SILApp alloc] initWithAppType:SILAppTypeHealthThermometer
                                     title:@"Health Thermometer"
                               description:@"View readings from the health thermometer service."
                         showcasedProfiles:@{ @"HTP" : @"­Health Thermometer Profile" }
                                 imageName:SILImageNameHomeThermometer];
}

+ (SILApp *)bluetoothBeaconingApp {
    return [[SILApp alloc] initWithAppType:SILAppTypeRetailBeacon
                              title:@"Bluetooth Beaconing"
                        description:@"Identify and detect Apple iBeacons and Google EddyStone beacons."
                  showcasedProfiles:@{}
                          imageName:SILImageNameHomeHelp];
}

+ (SILApp *)bluetoothBrowserApp {
    return [[SILApp alloc] initWithAppType:SILAppBluetoothBrowser
                                     title:@"Browser"
                               description:@"View info about nearby devices and their properties."
                         showcasedProfiles:@{}
                                 imageName:SILImageNameHomeDebug];
}

+ (SILApp *)homekitApp {
    return [[SILApp alloc] initWithAppType:SILAppTypeHomeKitDebug
                                     title:@"HomeKit Browser"
                               description:@"View info about nearby HomeKit devices and their properties."
                         showcasedProfiles:@{}
                                 imageName:SILImageNameHomeKitDebug];
}

+ (SILApp *)rangeTestApp {
    return [[SILApp alloc] initWithAppType:SILAppTypeRangeTest
                                     title:@"Range Test"
                               description:@"Evaluate the link budget and range of EFR32."
                         showcasedProfiles:@{}
                                 imageName:SILImageNameHomeRangeTestDemo];
}

+ (SILApp *)advertiserApp {
    return [[SILApp alloc] initWithAppType:SILAppTypeAdvertiser
                                     title:@"Advertiser"
                               description:@"Utilize this device as a Bluetooth Low Energy peripheral."
                         showcasedProfiles:@{}
                                 imageName:SILImageNameHomeAdvertiser];
}

- (instancetype)initWithAppType:(SILAppType)appType
                           title:(NSString *)title
                     description:(NSString *)description
               showcasedProfiles:(NSDictionary *)showcasedProfiles
                       imageName:(NSString *)imageName {
    self = [super init];
    if (self) {
        self.appType = appType;
        self.title = title;
        self.appDescription = description;
        self.showcasedProfiles = showcasedProfiles;
        self.imageName = imageName;
    }
    return self;
}

@end
