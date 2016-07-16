#import <Foundation/Foundation.h>


@interface MenuManager : NSObject 

+ (MenuManager*) inst;

- (BOOL) load:(NSString*)jsonFile;

- (NSArray*) sections;
- (NSDictionary*) upSection;

- (NSDictionary*) currentSection;
- (id) selectSection:(NSString*)name;

- (long) configLong:(NSString*)name default:(long)value;
- (BOOL) configBool:(NSString*)name default:(BOOL)value;
- (NSString*) configString:(NSString*)name default:(NSString*)value;

@end
