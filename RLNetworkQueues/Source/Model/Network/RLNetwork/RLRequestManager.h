/******************************************************************************
 * - Created 2012/05/09 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * <#SUMMARY INFORMATION#>
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

#import <Foundation/Foundation.h>
#import "RLRequestQueueProtocol.h"
#import "RLRequestProtocol.h"

#pragma mark ** Constant Defines **

#define GLOBAL_MAX_IN_FLIGHT_COUNT_DEFAULT_VALUE 4

#pragma mark ** Protocols & Declarations **

@interface RLRequestManager : NSObject
{

}

#pragma mark ** Singleton Accessors **
+ (RLRequestManager *)singleton;

#pragma mark ** Properties **

@property (nonatomic, strong, readonly) NSSet *allQueueIdentifiers;
@property (nonatomic, assign, readonly) NSUInteger pendingRequestCount;
@property (nonatomic, assign, readonly) NSUInteger inflightRequestCount;

/// Cannot be less than 1. defaults to GLOBAL_MAX_IN_FLIGHT_COUNT_DEFAULT_VALUE  
@property (nonatomic, assign) NSUInteger globalMaxInFlightCount;

/// defaults to a background queue
@property (nonatomic, strong) NSOperationQueue *operationQueue;

#pragma mark ** Queue Actions **

/**
 
 Before you can submit a request, you must create the request queue.

 If you create multiple queues with a given priority, a queue will be chosen round robin.
 
 maxInFlightCount must be at least 1.  while this value may be higher 
 than globalMaxInFlightCount, it is effectively clipped by globalMaxInFlightCount.
 
 Queues cannot be destroyed or modified after creation.  
 If you attempt to call this method with an existant identifier, an
 assertion will be thrown.
 
 Empty queues do not take up significant reqources.
 
 */

- (void)makeRequestQueueWithIdentifier:(NSString *)identifier
                              priority:(RLRequestQueueProtocolPriority)priority
                             queueType:(RLRequestManagerQueueType)queueType
                      maxInFlightCount:(NSUInteger)maxInFlightCount;
/**
 
 */
- (void)submitRequest:(NSObject <RLRequestProtocol> *)request
      queueIdentifier:(NSString *)identifier;

/** 
 
 Submits the request immediately, bypassing the queue system.
 
 Requests submitted via this method are not limited by globalMaxInFlightCount,
 but they do count against the limit.  Care must be taken as it is possible for
 excessive use of this method to effectively stall all queues.
 
 */

- (void)submitRequestImmediately:(NSObject <RLRequestProtocol> *)request;

#pragma mark ** Utilities **

/**
 Temporarily prevent any pending requests from being sent out.
 Any reqeusts currently in flight will continue to completion.
 */
- (void)pauseAllQueues;
- (void)pauseQueueWithIdentifier:(NSString *)identifier;

/**
 Does nothing unless one of the pause methods was called.
 */
- (void)resumeAllQueues;
- (void)resumeQueueWithIdentifier:(NSString *)identifier;

/**
 Destroy all pending requests.  
 All pending requests will have their error handlers called with the canceled argument set to YES
 Any reqeusts currently in flight will continue to completion.
 */
- (void)clearAllQueues;
- (void)clearQueueWithIdentifier:(NSString *)identifier;

@end
