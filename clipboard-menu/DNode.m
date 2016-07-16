#import "DNode.h"
#import <objc/runtime.h>


@implementation NSDictionary (Node)

- (NSDictionary*) parent
{
    return objc_getAssociatedObject(self, @selector(parent));
}

- (void) setParent: (NSDictionary*)parent
{
    objc_setAssociatedObject(self, @selector(parent), parent, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
