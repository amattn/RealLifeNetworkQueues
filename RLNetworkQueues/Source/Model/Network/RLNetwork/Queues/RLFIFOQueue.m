/******************************************************************************
 * - Created 2012/04/10 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * <#SUMMARY INFORMATION#>
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

#import "RLFIFOQueue.h"

@interface RLFIFOQueue ()
@property (nonatomic, strong) NSMutableOrderedSet *internalOrderedSet;
@end

@implementation RLFIFOQueue
#pragma mark ** Synthesis **

@synthesize internalOrderedSet = _internalOrderedSet;

#pragma mark ** Static Variables **

//*****************************************************************************
#pragma mark -
#pragma mark ** Lifecycle & Memory Management **

- (id)init;
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

- (void)dealloc;
{
    
}

+ (id)queue;
{
    return [[RLFIFOQueue alloc] init];
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Utilities **

//*****************************************************************************
#pragma mark -
#pragma mark ** RLRequestQueueProtocol Methods **

- (NSUInteger)count;
{
    return [self.internalOrderedSet count];
}

- (void)enqueueObject:(id)object;
{
    @synchronized(self) {
        [self.internalOrderedSet addObject:object];
    }
}

- (id)dequeueObject;
{
    @synchronized(self) {
        if ([self.internalOrderedSet count] == 0)
            return nil;

        __autoreleasing id objectToReturn = [self.internalOrderedSet firstObject];
        [self.internalOrderedSet removeObjectAtIndex:0];
        return objectToReturn;
    }
}

- (BOOL)removeObjectFromQueue:(id)object;
{
    @synchronized(self)
    {
        if ([self.internalOrderedSet containsObject:object])
        {
            [self.internalOrderedSet removeObject:object];
            return YES;
        } else
        {
            return NO;
        }
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Accesssors **

- (NSMutableOrderedSet *)internalOrderedSet;
{
    @synchronized(self)
    {
        if (_internalOrderedSet == nil) {
            _internalOrderedSet = [[NSMutableOrderedSet alloc] init];
        }
    }

    return _internalOrderedSet;
}

- (NSString *)description;
{
    NSMutableString *stringToReturn = [[super description] mutableCopy];
    [stringToReturn appendFormat:@" %@", [self.internalOrderedSet description]];
    return stringToReturn;
}

@end
