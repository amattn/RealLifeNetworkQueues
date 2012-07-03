/******************************************************************************
 * - Created 2012/05/08 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * <#SUMMARY INFORMATION#>
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark ** Constant Defines **

typedef enum {
    // This may be customized to your liking.
    // Higher integer values are considered higher priority.
    // This enum is for typing and convenience, all NSInteger values are considered valid priorities.
    RLRequestQueueProtocolPriorityLow = -2,
    RLRequestQueueProtocolPriorityMedium = 0,
    RLRequestQueueProtocolPriorityHigh = 2,
} RLRequestQueueProtocolPriority;

typedef enum {
    /**
     
     RLRequestManagerQueueTypeInOrder is a FIFO request queue
     
     maxInFlightCount for this type must be 1 or more.
     
     if maxInFlightCount is 1, then all requests will be execute to completion (including any completion or error handlers)
     if maxInFlightCount is greater than 1, the requests are initiated in fifo order, but no specific
     completion order is guarunteed.
     
     */
    
    RLRequestManagerQueueTypeInOrder = 0,
    
    /**
     
     RLRequestManagerQueueTypeMostRecent is a LIFO request queue
     This is often used when requesting things like images for a table view
     typically you want the most recently submitted out on the wire, but 
     all the previous requests should be filled at some point.
     
     maxInFlightCount for this type must be 1 or more.
     
     */
    
    RLRequestManagerQueueTypeMostRecent,
    
    /**
     
     RLRequestManagerQueueTypeLatestOnly will discard any requests except for:
     
     1. any request in-flight
     2. the most recently submitted 
     
     Typically used when you have a UI element that is constantly updating, 
     but only want the most recent actually submitted over the network
     
     maxInFlightCount for this type must be 1
     
     */
    
    RLRequestManagerQueueTypeLatestOnly,
    
    /// For internal use
    RLRequestManagerQueueTypeCount,
    /// For internal use
    RLRequestManagerQueueTypeInvalid
} RLRequestManagerQueueType;



#pragma mark -
#pragma mark ** RLRequestQueueProtocol **
@protocol RLRequestQueueProtocol <NSObject>

#pragma mark ** Properties **

/** 
 Returns the number of objects currently in the queue.
 */
@property (nonatomic, assign, readonly) NSUInteger count;

#pragma mark ** Methods **

+ (id)queue; // designated Initializer

/** 
 Adds an object to the back of the queue.
 This value must not be nil.  Raises an NSInvalidArgumentException if anObject is nil.
 
 An object can only be added once.  adding an object that is already in the queue does nothing.
 */
- (void)enqueueObject:(id)object;

/** 
 Returns the next object from the head of the queue.
 If the queue is empty, returns nil.
 
 O(1)

 */
- (id)dequeueObject;

/**
 
 returns YES if object was removed
 returns NO if object wasn't found in queue.
 
 O(1)
 
 */
- (BOOL)removeObjectFromQueue:(id)object;


@end
