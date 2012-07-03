/******************************************************************************
 * - Created 2012/04/10 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * <#SUMMARY INFORMATION#>
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

#import "RLRequestQueueProtocol.h"

#pragma mark ** Constant Defines **

#pragma mark ** Protocols & Declarations **

/** 
 
 Classical FIFO request queue
 
 */
@interface RLFIFOQueue : NSObject <RLRequestQueueProtocol>

/** 
 Adds an object to the back of the queue.
 This value must not be nil.  Raises an NSInvalidArgumentException if anObject is nil.
 
 An object can only be added once.  adding an object that is already in the queue does nothing.
 
 O(1)
 */
- (void)enqueueObject:(id)object;

/** 
 Returns the next object from the head of the queue.
 If the queue is empty, returns nil.

 O(1)

 */
- (id)dequeueObject;

/** 
 
 Removes an object from the queue
 
 O(1)

 */
- (BOOL)removeObjectFromQueue:(id)object;

@end
