#import "MenuManager.h"
#import "DNode.h"


@interface MenuManager () {
    NSDictionary* _menu;   // root entry
    NSDictionary* _entry;  // curent entry
    NSDictionary* _config; // settings
}

@end

@implementation MenuManager

- (id) init
{
    self = [super init];
    if (self) {
        _menu  = nil;
        _entry = nil;
    }
    return self;
}

- (BOOL) load:(NSString*)jsonFile
{
    NSString* fpath = [[NSBundle mainBundle] pathForResource:@"menu" ofType:@"json"];
    
    NSError* error = nil;
    id sdata = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:fpath] options:0 error:&error];
    
    if (!error && [sdata isKindOfClass:[NSDictionary class]]) {
        
        _menu   = [MenuManager initSections:[(NSDictionary*)sdata valueForKey:@"menu"]];
        _config = [(NSDictionary*)sdata valueForKey:@"settings"];
        _entry  = _menu;
        return true;
    }
    
    if (error) {
        NSLog(@"Error: %@", error);
    }
    
    _menu = nil;
    return false;
}

+ (MenuManager*) inst
{
    static MenuManager* __mman = nil;
    
    if (!__mman) {
         __mman = [[MenuManager alloc] init];
        [__mman load:@"menu.json"];
    }
    
    return __mman;
}

+ (NSDictionary*) initSections:(NSDictionary*)dict
{
    NSMutableDictionary* mdict = [[NSMutableDictionary alloc] init];
    
    for (NSString* key in [dict allKeys]) {
        id obj = [dict valueForKey:key];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            obj = [MenuManager initSections:obj];
            [(NSDictionary*)obj setParent:mdict];
        }
        [mdict setValue:obj forKey:key];
    }
    
    return mdict;
}

/**
 * Available sections for curent entry
 */
- (NSArray*) sections
{
    if (!_entry) return [NSArray array];
    return [_entry allKeys];
}

- (NSDictionary*) upSection
{
    if (_entry.parent) {
        _entry = _entry.parent;
        return _entry;
    }
    return nil;
}

- (NSDictionary*) currentSection;
{
    return _entry;
}

/**
 * Select sections for curent entry
 */
- (id) selectSection:(NSString*)name
{
    if (!_entry) return nil;
    
    id obj = [_entry objectForKey:name];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        _entry = obj;
        return _entry;
    }
    
    return obj;
}

// Config conversion methods

- (long) configLong:(NSString*)name default:(long)value
{
    NSNumber* num = [_config valueForKey:name];
    return (num != nil ? [num longValue] : value);
}

- (BOOL) configBool:(NSString*)name default:(BOOL)value
{
    NSNumber* bval = [_config valueForKey:name];
    return (bval != nil ? [bval boolValue] : value);
}

- (NSString*) configString:(NSString*)name default:(NSString*)value
{
    NSString* str = [_config valueForKey:name];
    return (str != nil ? str : value);
}

@end
