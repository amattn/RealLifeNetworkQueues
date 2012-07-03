/******************************************************************************
 * - Created 2012/05/09 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * <#SUMMARY INFORMATION#>
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

#import "RLRequestManager.h"
#import "RLFIFOQueue.h"
#import "RLLIFOQueue.h"

// simple container class for convenience.
@interface RLRequestQueueMetadata : NSObject
@property (nonatomic, assign) RLRequestQueueProtocolPriority priority;
@property (nonatomic, assign) RLRequestManagerQueueType queueType;
@property (nonatomic, assign) NSUInteger maxInFlightCount;
@property (nonatomic, strong, readonly) NSMutableOrderedSet *inFlightRequestObjects;
@end
@implementation RLRequestQueueMetadata
@synthesize priority = _priority;
@synthesize queueType = _queueType;
@synthesize maxInFlightCount = _maxInFlightCount;
@synthesize inFlightRequestObjects = _inFlightRequestObjects;
- (NSMutableOrderedSet *)inFlightRequestObjects;
{
	if (_inFlightRequestObjects == nil) { _inFlightRequestObjects = [NSMutableOrderedSet orderedSet];}
	return _inFlightRequestObjects;
}
@end

typedef enum {
    RLRequestLifecyleStateCreation = 0,
    RLRequestLifecyleStateSubmitted,
    RLRequestLifecyleStateInFlight,
    RLRequestLifecyleStateCompleted,
    RLRequestLifecyleStateCount,
    RLRequestLifecyleStateInvalid
} RLRequestLifecyleState;

// copy this interface into your test case to get access to test only utiliites
@interface RLRequestManager (test_only)
@property (nonatomic, strong, readonly) NSMutableOrderedSet *sortedPriorityKeys;
@property (nonatomic, strong, readonly) NSMutableDictionary *priorityQueueIdentifiers;
@property (nonatomic, strong, readonly) NSMutableDictionary *allQueues;
@property (nonatomic, strong, readonly) NSMutableDictionary *allQueuesMetadata;
@property (nonatomic, strong, readonly) NSMutableDictionary *requestLifecycleStateSets;
- (void)resetAndSetupRequestManager;
@end


@interface RLRequestManager ()

// array of keys, always sorted
@property (nonatomic, strong, readonly) NSMutableOrderedSet *sortedPriorityKeys;
// Dictionary of OrderedSets of QueueIdentifiers
@property (nonatomic, strong, readonly) NSMutableDictionary *priorityQueueIdentifiers;
// key is identifier, value is the actual queue
@property (nonatomic, strong, readonly) NSMutableDictionary *allQueues;
// key is identifier, value is RLRequestQueueMetadata
@property (nonatomic, strong, readonly) NSMutableDictionary *allQueuesMetadata;
// key is NSNumber of RLRequestLifecyleState, value is NSMutableSet
@property (nonatomic, strong, readonly) NSMutableDictionary *requestLifecycleStateSets;

@end

@implementation RLRequestManager

#pragma mark ** Synthesis **

@synthesize globalMaxInFlightCount = _globalMaxInFlightCount;
@synthesize operationQueue = _operationQueue;

@synthesize sortedPriorityKeys = _sortedPriorityKeys;
@synthesize priorityQueueIdentifiers = _priorityQueueIdentifiers;
@synthesize allQueues = _allQueues;
@synthesize allQueuesMetadata = _allQueuesMetadata;
@synthesize requestLifecycleStateSets = _requestLifecycleStateSets;

#pragma mark ** Static Variables **

static RLRequestManager *__sharedRLRequestManager = nil;

#pragma mark ** Singleton **

+ (RLRequestManager *)singleton;
{
    static dispatch_once_t singletonCreationToken;
    dispatch_once(&singletonCreationToken, ^
    {
        __sharedRLRequestManager = [[RLRequestManager alloc] init];
    });
    return __sharedRLRequestManager;
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Lifecyle Methods **

- (id)init;
{
    self = [super init];
    if (self)
    {
        [self resetAndSetupRequestManager];
}
    return self;
}

- (void)dealloc;
{
    
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Queue Actions **

- (void)makeRequestQueueWithIdentifier:(NSString *)identifier
                              priority:(RLRequestQueueProtocolPriority)priority
                             queueType:(RLRequestManagerQueueType)queueType
                      maxInFlightCount:(NSUInteger)maxInFlightCount;
{
    @synchronized(self)
    {
        if (maxInFlightCount < 1)
        {
            NSAssert(NO, @"AssertionID: 2217910689 ERROR attempting to make request queue with maxInFlightCount < 1");
            return;
        }
        if ([self.allQueues objectForKey:identifier] != nil)
        {
            NSAssert(NO, @"AssertionID: 4116123645 ERROR attempting to make request queue with duplicate identifier");
            return;
        }
        if (queueType >= RLRequestManagerQueueTypeCount)
        {
            NSAssert(NO, @"AssertionID: 1255467764 ERROR attempting to make request queue with invalid queueType");
            return;
        }
        
        // Not the fastest way to keep a perma-sorted collection, but this limits
        // our dependancies and makeRequestQueue... shouldn't be called that often
        // if that assumption changes, revisit this.
        NSNumber *priorityKey = [NSNumber numberWithInteger:priority];
        if ([self.sortedPriorityKeys containsObject:priorityKey] == NO) {
            [self.sortedPriorityKeys addObject:priorityKey];
            [self.sortedPriorityKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj2 compare:obj1];
            }];
            [self.priorityQueueIdentifiers setObject:[NSMutableOrderedSet orderedSet] forKey:priorityKey];
        }
        NSMutableOrderedSet *identifiers = [self orderedSetOfIdentifiersForPriority:priority];
        [identifiers addObject:identifier];
        
        NSObject <RLRequestQueueProtocol> *newQueue;
        Class queueClass = nil;
        switch (queueType) {
            case RLRequestManagerQueueTypeInOrder:
            case RLRequestManagerQueueTypeLatestOnly:
                queueClass = [RLFIFOQueue class];
                break;
            case RLRequestManagerQueueTypeMostRecent:
                queueClass = [RLLIFOQueue class];                
                // if we don't use default:, the compiler will warn us.  Yay!
            case RLRequestManagerQueueTypeCount:
            case RLRequestManagerQueueTypeInvalid:
                break;
        }
            
        if (queueClass)
        {
            newQueue = [queueClass queue];
        }
        else
        {
            NSAssert(NO,@"AssertionID: 1619184543 queueType does not define queue class");
        }
        
        [self.allQueues setObject:newQueue forKey:identifier];
        RLRequestQueueMetadata *metadata = [self metadataForQueueIdentifier:identifier];
        metadata.queueType = queueType;
        metadata.maxInFlightCount = maxInFlightCount;
    }
}

- (void)submitRequest:(NSObject <RLRequestProtocol> *)requestObject
      queueIdentifier:(NSString *)identifier;
{
    @synchronized (self)
    {
        NSObject <RLRequestQueueProtocol> *queue = [self.allQueues objectForKey:identifier];
        RLRequestManagerQueueType queueType = [self metadataForQueueIdentifier:identifier].queueType;
        
        if (queueType == RLRequestManagerQueueTypeLatestOnly)
        {
            // special handling here
            id requestObjectToCancel = [queue dequeueObject];
            if (requestObjectToCancel)
            {
                if ([requestObjectToCancel respondsToSelector:@selector(cancelRequest)])
                    [requestObjectToCancel performSelector:@selector(cancelRequest)];
                [self setLifecycleState:RLRequestLifecyleStateCompleted forRequestObject:requestObjectToCancel inQueueWithIdentifier:identifier];
            }
        }

        [queue enqueueObject:requestObject];
        [self setLifecycleState:RLRequestLifecyleStateSubmitted forRequestObject:requestObject inQueueWithIdentifier:identifier];
    }
}

- (void)submitRequestImmediately:(NSObject <RLRequestProtocol> *)requestObject;
{
    [self executeRequestObject:requestObject inQueueWithIdentifier:nil];
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Public Utilities **

- (void)pauseAllQueues;
{
    
}

- (void)pauseQueueWithIdentifier:(NSString *)identifier;
{
    
}

- (void)resumeAllQueues;
{
    
}
- (void)resumeQueueWithIdentifier:(NSString *)identifier;
{
    
}

- (void)clearAllQueues;
{
    
}

- (void)clearQueueWithIdentifier:(NSString *)identifier;
{
    
}


//*****************************************************************************
#pragma mark -
#pragma mark ** Request Management **

- (BOOL)executeNextRequestIfPossibleForQueueIdentifier:(NSString *)identifier;
{
    @synchronized(self) {
        NSObject <RLRequestQueueProtocol> *queue = [self.allQueues objectForKey:identifier];
        NSUInteger currentPendingInQueueCount = queue.count;
        
        if (currentPendingInQueueCount != 0) {
            RLRequestQueueMetadata *metadata = [self metadataForQueueIdentifier:identifier];
            NSUInteger maxInFlightCount = metadata.maxInFlightCount;
            NSUInteger currentInFlightInQueueCount = [metadata.inFlightRequestObjects count];
//            NSLog(@"currentInFlightInQueueCount:%d maxQueueCount:%d", currentInFlightInQueueCount, maxInFlightCount);
            if (currentInFlightInQueueCount < maxInFlightCount) {
                NSLog(@"executing block");
                NSObject <RLRequestProtocol> *requestObject = [queue dequeueObject];
                [self executeRequestObject:requestObject
                     inQueueWithIdentifier:identifier];
                return YES;
            }
        }
        return NO;
    }
}

- (void)executeNextRequestIfPossible;
{
    @synchronized(self) {
        if (self.inflightRequestCount > self.globalMaxInFlightCount)
            return;
        
        // iterate through our priorities:
        [self.priorityQueueIdentifiers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSMutableOrderedSet *orderedSetOfQueueIdentifiers = obj;
            
            [orderedSetOfQueueIdentifiers enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger idx, BOOL *stop) {
                *stop = [self executeNextRequestIfPossibleForQueueIdentifier:identifier];
            }];
        }];
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Internal Utilities **

- (RLRequestQueueMetadata *)metadataForQueueIdentifier:(NSString *)identifier;
{
    RLRequestQueueMetadata *metadata = [self.allQueuesMetadata objectForKey:identifier];
    if (metadata == nil) {
        metadata = [[RLRequestQueueMetadata alloc] init];
        [self.allQueuesMetadata setObject:metadata forKey:identifier];
    }
    return metadata;
}

- (void)setLifecycleState:(RLRequestLifecyleState)lifecycleState
         forRequestObject:(NSObject <RLRequestProtocol> *)requestObject
    inQueueWithIdentifier:(NSString *)identifier;
{
    NSAssert(requestObject != nil, @"Assert ID:2068301675");
    @synchronized (self.requestLifecycleStateSets)
    {
        // Add to the global lifecycle state sets
        [self.requestLifecycleStateSets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            NSMutableSet *requestObjects = obj;
            if ([key integerValue] == lifecycleState) {
                [requestObjects addObject:requestObject];
            } else {
                [requestObjects removeObject:requestObject];
            }
        }];
        
        // Add to the queue based lifecycle state sets
        NSMutableOrderedSet *inFlightRequestObjects = nil;
        if (identifier) {
            inFlightRequestObjects = [self metadataForQueueIdentifier:identifier].inFlightRequestObjects;
            NSAssert(inFlightRequestObjects, @"AssertID: 2469638324, should never be nil");
            if (lifecycleState == RLRequestLifecyleStateInFlight) {
                [inFlightRequestObjects addObject:requestObject];
            } else {
                LOG_OBJECT(@"[queueInFlightSet removeObject:requestObject];");
                [inFlightRequestObjects removeObject:requestObject];
            }
        }
    }
    
    if (lifecycleState == RLRequestLifecyleStateCompleted
        || lifecycleState == RLRequestLifecyleStateSubmitted) {
        [self executeNextRequestIfPossible];
    }
}

- (NSMutableOrderedSet *)orderedSetOfIdentifiersForPriority:(RLRequestQueueProtocolPriority)priority;
{
    NSNumber *priorityKey = [NSNumber numberWithInteger:priority];
    return [self.priorityQueueIdentifiers objectForKey:priorityKey];
}

- (void)executeRequestObject:(NSObject <RLRequestProtocol> *)requestObject
       inQueueWithIdentifier:(NSString *)identifier;
{
    @synchronized (self)
    {
        [self setLifecycleState:RLRequestLifecyleStateInFlight 
               forRequestObject:requestObject
          inQueueWithIdentifier:identifier];
        
        void (^requestComplete)() = ^() {
            [self setLifecycleState:RLRequestLifecyleStateCompleted 
                   forRequestObject:requestObject
              inQueueWithIdentifier:identifier];
        };

        [self.operationQueue addOperationWithBlock:^{
            [requestObject executeRequestWithCompetionHandler:^(NSObject<RLRequestProtocol> *__weak weakRequestObject) {
                requestComplete();
            }];
        }];

    }
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Test Only Utilities **

- (void)resetAndSetupRequestManager;
{
    self.globalMaxInFlightCount = GLOBAL_MAX_IN_FLIGHT_COUNT_DEFAULT_VALUE;
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    _sortedPriorityKeys = [[NSMutableOrderedSet alloc] init];
    _priorityQueueIdentifiers = [[NSMutableDictionary alloc] init];
    _allQueues = [[NSMutableDictionary alloc] init];
    _allQueuesMetadata = [[NSMutableDictionary alloc] init];
    _requestLifecycleStateSets = [[NSMutableDictionary alloc] init];
    for (RLRequestLifecyleState i = RLRequestLifecyleStateCreation; i < RLRequestLifecyleStateCount; i++)
    {
        [_requestLifecycleStateSets setObject:[NSMutableSet set] forKey:[NSNumber numberWithInteger:i]];
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Public Accesssors **
     
- (NSUInteger)pendingRequestCount;
{
    NSMutableSet *set = [self.requestLifecycleStateSets objectForKey:[NSNumber numberWithInteger:RLRequestLifecyleStateSubmitted]];
    return [set count];
}
- (NSUInteger)inflightRequestCount;
{
    NSMutableSet *set = [self.requestLifecycleStateSets objectForKey:[NSNumber numberWithInteger:RLRequestLifecyleStateInFlight]];
    return [set count];
}

- (void)setGlobalMaxInFlightCount:(NSUInteger)newValue;
{
    NSAssert((newValue >= 1), @"AssertID:483897661 globalMaxInFlightCount must be greater than 0");
    
    _globalMaxInFlightCount = newValue;
}

- (NSSet *)allQueueIdentifiers;
{
    return [NSSet setWithArray:self.allQueues.allKeys];
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Internal Accesssors **

@end
