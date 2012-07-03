/******************************************************************************
 * - Created 2012/05/09 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * <#SUMMARY INFORMATION#>
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

#import <SenTestingKit/SenTestingKit.h>
#import "RLRequestManager.h"
#import "RLTestRequest.h"

@interface RLRequestManager (test_only)
@property (nonatomic, strong, readonly) NSMutableOrderedSet *sortedPriorityKeys;
@property (nonatomic, strong, readonly) NSMutableDictionary *priorityQueueIdentifiers;
@property (nonatomic, strong, readonly) NSMutableDictionary *allQueues;
@property (nonatomic, strong, readonly) NSMutableDictionary *allQueuesMetadata;
@property (nonatomic, strong, readonly) NSMutableDictionary *requestLifecycleStateSets;
- (void)resetAndSetupRequestManager;
@end

@interface RLRequestManagerTestCase : SenTestCase
{
    // Most test cases don't need an explicit .h file.
    // However if you plan on having test cases that inherit from 
    // other test cases, you can extract this @interface into 
    // a .h file for other test cases to inherit from.
}
@property (nonatomic, strong) RLRequestManager *requestManager;
@end

@implementation RLRequestManagerTestCase

@synthesize requestManager = _requestManager;

- (void)setUp;
{
    self.requestManager = [RLRequestManager singleton];
}

- (void)tearDown;
{
    [self.requestManager resetAndSetupRequestManager];
}

- (void)makeWithIdentifier1547875676;
{
    [self.requestManager makeRequestQueueWithIdentifier:@"1547875676"
                                               priority:RLRequestQueueProtocolPriorityMedium
                                              queueType:RLRequestManagerQueueTypeInOrder
                                       maxInFlightCount:1];
}

- (void)makeWithZeroInFlightCount;
{
    [self.requestManager makeRequestQueueWithIdentifier:@"267650132"
                                               priority:RLRequestQueueProtocolPriorityMedium
                                              queueType:RLRequestManagerQueueTypeInOrder
                                       maxInFlightCount:0];
}

- (void)makeWithInvalidPriority;
{
    [self.requestManager makeRequestQueueWithIdentifier:@"638474141"
                                               priority:292342341324
                                              queueType:RLRequestManagerQueueTypeInOrder
                                       maxInFlightCount:1];
}

- (void)makeWithInvalidType;
{
    [self.requestManager makeRequestQueueWithIdentifier:@"1940017694"
                                               priority:RLRequestQueueProtocolPriorityMedium
                                              queueType:RLRequestManagerQueueTypeCount
                                       maxInFlightCount:1];
}

- (void)testMakeQueueAsserts;
{
    [self makeWithIdentifier1547875676];
    STAssertThrows([self makeWithIdentifier1547875676], @"Should throw exception here");
    STAssertThrows([self makeWithZeroInFlightCount], @"Should throw exception here");
    STAssertThrows([self makeWithInvalidType], @"Should throw exception here");
    STAssertNoThrow([self makeWithInvalidPriority], @"There is no such thing as an invalid priority");
}

- (void)testMakeQueue;
{
    NSUInteger expectedPriorityCount = 0;
    NSUInteger expectedTotalCount = 0;

    STAssertEquals([[self.requestManager allQueueIdentifiers] count], expectedPriorityCount, @"");
    
    [self.requestManager makeRequestQueueWithIdentifier:@"MedInOrder"
                                               priority:RLRequestQueueProtocolPriorityMedium
                                              queueType:RLRequestManagerQueueTypeInOrder
                                       maxInFlightCount:1];

    expectedPriorityCount = 1;
    expectedTotalCount = 1;
    STAssertEquals([[self.requestManager allQueueIdentifiers] count], expectedTotalCount, @"");
    STAssertEquals([[self.requestManager sortedPriorityKeys] count], expectedPriorityCount, @"");

    [self.requestManager makeRequestQueueWithIdentifier:@"LowInOrder1"
                                               priority:RLRequestQueueProtocolPriorityLow
                                              queueType:RLRequestManagerQueueTypeInOrder
                                       maxInFlightCount:1];
    expectedPriorityCount = 2;
    expectedTotalCount = 2;
    STAssertEquals([[self.requestManager allQueueIdentifiers] count], expectedTotalCount, @"");
    STAssertEquals([[self.requestManager sortedPriorityKeys] count], expectedPriorityCount, @"");
    [self.requestManager makeRequestQueueWithIdentifier:@"LowInOrder2"
                                               priority:RLRequestQueueProtocolPriorityLow
                                              queueType:RLRequestManagerQueueTypeInOrder
                                       maxInFlightCount:1];
    STAssertEquals([[self.requestManager sortedPriorityKeys] count], expectedPriorityCount, @"");
    [self.requestManager makeRequestQueueWithIdentifier:@"LowInOrder3"
                                               priority:RLRequestQueueProtocolPriorityLow
                                              queueType:RLRequestManagerQueueTypeInOrder
                                       maxInFlightCount:1];
    STAssertEquals([[self.requestManager sortedPriorityKeys] count], expectedPriorityCount, @"");
    [self.requestManager makeRequestQueueWithIdentifier:@"HighInOrder1"
                                               priority:RLRequestQueueProtocolPriorityHigh
                                              queueType:RLRequestManagerQueueTypeInOrder
                                       maxInFlightCount:1];
    expectedPriorityCount = 3;
    STAssertEquals([[self.requestManager sortedPriorityKeys] count], expectedPriorityCount, @"");
    [self.requestManager makeRequestQueueWithIdentifier:@"HighInOrder2"
                                               priority:RLRequestQueueProtocolPriorityHigh
                                              queueType:RLRequestManagerQueueTypeInOrder
                                       maxInFlightCount:1];
    STAssertEquals([[self.requestManager sortedPriorityKeys] count], expectedPriorityCount, @"");
        
    // we must check that our priorities are correct.
    
    __block id previousObj = nil;
    [self.requestManager.sortedPriorityKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (previousObj) {
            NSComparisonResult candidate = [previousObj compare:obj];
            NSComparisonResult expected = NSOrderedDescending;
            STAssertEquals(candidate, expected, @"897442111 Order is wrong!");
        }
        previousObj = obj;
    }];
    
    // check our internal state:
    expectedPriorityCount = 3;
    expectedTotalCount = 6;
    STAssertEquals([self.requestManager.priorityQueueIdentifiers count], expectedPriorityCount, @"");
    STAssertEquals([self.requestManager.allQueues count], expectedTotalCount, @"");
    STAssertEquals([self.requestManager.allQueuesMetadata count], expectedTotalCount, @"");
        
    [self.requestManager.priorityQueueIdentifiers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        STAssertTrue([key isKindOfClass:[NSNumber class]], @"893429043 wrong class for priorityQueueIdentifiers:key");
        STAssertTrue([obj isKindOfClass:[NSMutableOrderedSet class]], @"2323302547 wrong class for priorityQueueIdentifiers:obj");
        
        if ([key isEqual:[NSNumber numberWithInteger:RLRequestQueueProtocolPriorityHigh]]) {
            STAssertEquals([obj count], (NSUInteger) 2, @"");
            STAssertTrue([obj containsObject:@"HighInOrder1"], @"");
            STAssertTrue([obj containsObject:@"HighInOrder2"], @"");

        }
        if ([key isEqual:[NSNumber numberWithInteger:RLRequestQueueProtocolPriorityMedium]]) {
            STAssertEquals([obj count], (NSUInteger) 1, @"");
            STAssertTrue([obj containsObject:@"MedInOrder"], @"");
        }
        if ([key isEqual:[NSNumber numberWithInteger:RLRequestQueueProtocolPriorityLow]]) {
            STAssertEquals([obj count], (NSUInteger) 3, @"");
            STAssertTrue([obj containsObject:@"LowInOrder1"], @"");
            STAssertTrue([obj containsObject:@"LowInOrder2"], @"");
            STAssertTrue([obj containsObject:@"LowInOrder3"], @"");
        }
    }];
}

- (void)testFIFOQueue;
{
    LOG_METHOD;
    
    __block int _requestDone = 0;
    NSString *queueIdentifier = @"fifo";
    [self.requestManager makeRequestQueueWithIdentifier:queueIdentifier
                                               priority:RLRequestQueueProtocolPriorityMedium
                                              queueType:RLRequestManagerQueueTypeInOrder
                                       maxInFlightCount:1];
    
    NSUInteger expected;
    
    NSArray *expectedFinishOrder = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
    NSMutableArray *candidateFinishOrder = [NSMutableArray array];
    
    void (^completionHandler)(NSString *) = ^(NSString *name){
        STAssertEquals([self.requestManager.allQueues count], (NSUInteger)1, @"");
        NSLog(@"requestLifecycleStateSets %@", self.requestManager.requestLifecycleStateSets);
        STAssertEquals(self.requestManager.inflightRequestCount, (NSUInteger)1, @"1702374650");
        NSLog(@"simulate processing of network response");
        usleep(50000);  // simulate processing of network response
        _requestDone++;
        NSLog(@"finished w/ request name:%@", name);
        [candidateFinishOrder addObject:name];
    };
    
    [self.requestManager submitRequest:[[RLTestRequest alloc] initWithName:@"A" completionHandler:completionHandler] queueIdentifier:queueIdentifier];    
    [self.requestManager submitRequest:[[RLTestRequest alloc] initWithName:@"B" completionHandler:completionHandler] queueIdentifier:queueIdentifier];
    usleep(100);
    expected = 1;
    LOG_OBJECT(self.requestManager.requestLifecycleStateSets);
    STAssertEquals(self.requestManager.pendingRequestCount, expected, @"2110949328");
    
    [self.requestManager submitRequest:[[RLTestRequest alloc] initWithName:@"C" completionHandler:completionHandler] queueIdentifier:queueIdentifier];    
    expected = 2;
    LOG_OBJECT(self.requestManager.requestLifecycleStateSets);
    STAssertEquals(self.requestManager.pendingRequestCount, expected, @"560049321");
    
    NSLog(@"Waiting %@", NSStringFromSelector(_cmd));
    int i = 0;
    while (_requestDone < [expectedFinishOrder count] && i < 50) {
        NSLog(@"Waiting %@ i:%d", NSStringFromSelector(_cmd), i);
        usleep(100000);
        i++;
    }
    
    usleep(1000);
    expected = 0;
    STAssertTrue((i != 30), @"4191131667 waitingTimed out");
    STAssertEquals(self.requestManager.inflightRequestCount, expected, @"1731475519");
    STAssertEquals(self.requestManager.pendingRequestCount, expected, @"2201626090");
    
    STAssertEqualObjects(candidateFinishOrder, expectedFinishOrder, @"4266343417");
    NSLog(@"    END %@", NSStringFromSelector(_cmd));
}

- (void)testLIFOQueue;
{
    LOG_METHOD;
    
    __block int _requestDone = 0;
    NSString *queueIdentifier = @"lifo";
    [self.requestManager makeRequestQueueWithIdentifier:queueIdentifier
                                               priority:RLRequestQueueProtocolPriorityMedium
                                              queueType:RLRequestManagerQueueTypeMostRecent
                                       maxInFlightCount:1];
    
    NSUInteger expected;
    
    NSArray *expectedFinishOrder = [NSArray arrayWithObjects:@"A", @"D", @"C", @"B",nil];
    NSMutableArray *candidateFinishOrder = [NSMutableArray array];
    
    void (^completionHandler)(NSString *) = ^(NSString *name){
        STAssertEquals([self.requestManager.allQueues count], (NSUInteger)1, @"");
        NSLog(@"requestLifecycleStateSets %@", self.requestManager.requestLifecycleStateSets);
        STAssertEquals(self.requestManager.inflightRequestCount, (NSUInteger)1, @"3088908110");
        NSLog(@"simulate processing of network response");
        usleep(50000);  // simulate processing of network response
        _requestDone++;
        NSLog(@"finished w/ request name:%@", name);
        [candidateFinishOrder addObject:name];
    };
    
    [self.requestManager submitRequest:[[RLTestRequest alloc] initWithName:@"A" completionHandler:completionHandler] queueIdentifier:queueIdentifier];    
    usleep(100);
    [self.requestManager submitRequest:[[RLTestRequest alloc] initWithName:@"B" completionHandler:completionHandler] queueIdentifier:queueIdentifier];
    expected = 1;
    STAssertEquals(self.requestManager.pendingRequestCount, expected, @"2177253414");
    
    [self.requestManager submitRequest:[[RLTestRequest alloc] initWithName:@"C" completionHandler:completionHandler] queueIdentifier:queueIdentifier];    
    expected = 2;
    STAssertEquals(self.requestManager.pendingRequestCount, expected, @"1065769951");
    [self.requestManager submitRequest:[[RLTestRequest alloc] initWithName:@"D" completionHandler:completionHandler] queueIdentifier:queueIdentifier];    
    expected = 3;
    STAssertEquals(self.requestManager.pendingRequestCount, expected, @"3130917708");
    
    NSLog(@"Waiting %@", NSStringFromSelector(_cmd));
    int i = 0;
    while (_requestDone < [expectedFinishOrder count] && i < 30) {
        NSLog(@"Waiting %@ i:%d", NSStringFromSelector(_cmd), i);
        usleep(100000);
        i++;
    }
    
    usleep(1000);
    expected = 0;
    STAssertTrue((i != 30), @"2765637001 waitingTimed out");

    STAssertEquals(self.requestManager.inflightRequestCount, expected, @"1731475519");
    STAssertEquals(self.requestManager.pendingRequestCount, expected, @"2201626090");
    
    STAssertEqualObjects(candidateFinishOrder, expectedFinishOrder, @"4266343417");
    NSLog(@"    END %@", NSStringFromSelector(_cmd));
}

- (void)testLatestOnlyQueue;
{
    LOG_METHOD;
    
    __block int _requestDone = 0;
    NSString *queueIdentifier = @"latestOnly";
    [self.requestManager makeRequestQueueWithIdentifier:queueIdentifier
                                               priority:RLRequestQueueProtocolPriorityMedium
                                              queueType:RLRequestManagerQueueTypeLatestOnly
                                       maxInFlightCount:1];
    
    NSUInteger expected;
    
    NSArray *expectedFinishOrder = [NSArray arrayWithObjects:@"A", @"D",nil];
    NSMutableArray *candidateFinishOrder = [NSMutableArray array];
    
    void (^completionHandler)(NSString *) = ^(NSString *name){
        STAssertEquals([self.requestManager.allQueues count], (NSUInteger)1, @"");
        NSLog(@"requestLifecycleStateSets %@", self.requestManager.requestLifecycleStateSets);
        STAssertEquals(self.requestManager.inflightRequestCount, (NSUInteger)1, @"3088908110");
        NSLog(@"simulate processing of network response");
        usleep(50000);  // simulate processing of network response
        _requestDone++;
        NSLog(@"finished w/ request name:%@", name);
        [candidateFinishOrder addObject:name];
    };
    
    [self.requestManager submitRequest:[[RLTestRequest alloc] initWithName:@"A" completionHandler:completionHandler] queueIdentifier:queueIdentifier];    
    usleep(100);
    [self.requestManager submitRequest:[[RLTestRequest alloc] initWithName:@"B" completionHandler:completionHandler] queueIdentifier:queueIdentifier];
    expected = 1;
    STAssertEquals(self.requestManager.pendingRequestCount, expected, @"2177253414");
    [self.requestManager submitRequest:[[RLTestRequest alloc] initWithName:@"C" completionHandler:completionHandler] queueIdentifier:queueIdentifier];    
    expected = 1;
    STAssertEquals(self.requestManager.pendingRequestCount, expected, @"1065769951");
    [self.requestManager submitRequest:[[RLTestRequest alloc] initWithName:@"D" completionHandler:completionHandler] queueIdentifier:queueIdentifier];    
    expected = 1;
    STAssertEquals(self.requestManager.pendingRequestCount, expected, @"3130917708");
    
    NSLog(@"Waiting %@", NSStringFromSelector(_cmd));
    int i = 0;
    while (_requestDone < [expectedFinishOrder count] && i < 30) {
        NSLog(@"Waiting %@ i:%d", NSStringFromSelector(_cmd), i);
        usleep(100000);
        i++;
    }
    
    usleep(1000);
    expected = 0;
    STAssertTrue((i != 30), @"2765637001 waitingTimed out");
    
    STAssertEquals(self.requestManager.inflightRequestCount, expected, @"1731475519");
    STAssertEquals(self.requestManager.pendingRequestCount, expected, @"2201626090");
    
    STAssertEqualObjects(candidateFinishOrder, expectedFinishOrder, @"4266343417");
    NSLog(@"    END %@", NSStringFromSelector(_cmd));
}

- (void)testTestFramework;
{
//    STFail(@"uncomment to verify unit tests are being run");

    NSString *string1 = @"test";
    NSString *string2 = @"test";
    // Shouldn't use colons (:) in the STAssert... function messages.
    // Xcode will strip out everything before the colon.
    STAssertEqualObjects(string1, string2, @"FAILURE- %@ does not equal %@ ", string1, string2);

    NSUInteger uint_1 = 4;
    NSUInteger uint_2 = 4;
    STAssertEquals(uint_1, uint_2, @"FAILURE- %d does not equal %d", uint_1, uint_2);

}

@end
