/******************************************************************************
 * - Created 2012/04/10 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * <#SUMMARY INFORMATION#>
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

#import <SenTestingKit/SenTestingKit.h>
#import "RLFIFOQueue.h"

// @interface <#MyClass#> (test_only)
//
// You can declare methods here that are normally internal only by you want to 
// expose for testing
// - (id)internalProcessorMethod:(id)object;
// @end

@interface RLFIFOQueueTestCase : SenTestCase
{
    // Most test cases don't need an explicit .h file.
    // However if you plan on having test cases that inherit from 
    // other test cases, you can extract this @interface into 
    // a .h file for other test cases to inherit from.

}
@property (nonatomic, strong) RLFIFOQueue *queue;
@end

@implementation RLFIFOQueueTestCase
@synthesize queue = _queue;

- (void)setUp;
{
    self.queue = [[RLFIFOQueue alloc] init];
}

- (void)tearDown;
{
    self.queue = nil;
}

- (void)testLength;
{
    [self.queue enqueueObject:@"Hi"];
    NSUInteger expected;
    expected = 1;
    STAssertEquals([self.queue count], expected, @"FAILURE- expected %d, but got %d", expected, [self.queue count]);
    [self.queue enqueueObject:@"Hi"];
    expected = 1;
    STAssertEquals([self.queue count], expected, @"FAILURE- expected %d, but got %d", expected, [self.queue count]);
    [self.queue enqueueObject:@"Hi2"];
    expected = 2;
    STAssertEquals([self.queue count], expected, @"FAILURE- expected %d, but got %d", expected, [self.queue count]);
    [self.queue enqueueObject:@"Hi3"];
    expected = 3;
    STAssertEquals([self.queue count], expected, @"FAILURE- expected %d, but got %d", expected, [self.queue count]);
    
    [self.queue dequeueObject];
    expected = 2;
    STAssertEquals([self.queue count], expected, @"FAILURE- expected %d, but got %d", expected, [self.queue count]);
    [self.queue dequeueObject];
    expected = 1;
    STAssertEquals([self.queue count], expected, @"FAILURE- expected %d, but got %d", expected, [self.queue count]);
    [self.queue dequeueObject];
    expected = 0;
    STAssertEquals([self.queue count], expected, @"FAILURE- expected %d, but got %d", expected, [self.queue count]);
    [self.queue dequeueObject];
    expected = 0;
    STAssertEquals([self.queue count], expected, @"FAILURE- expected %d, but got %d", expected, [self.queue count]);
    [self.queue dequeueObject];
    expected = 0;
    STAssertEquals([self.queue count], expected, @"FAILURE- expected %d, but got %d", expected, [self.queue count]);
}

- (void)testDequeue;
{
    id candidate;
    id expected;
    
    candidate = [self.queue dequeueObject];
    STAssertNil(candidate, @"FAILURE- expected nil, got %@", candidate);
    
    [self.queue enqueueObject:@"Hi"];
    [self.queue enqueueObject:@"Hi"];
    [self.queue enqueueObject:@"Hi3"];
    [self.queue enqueueObject:@"Hi4"];
    [self.queue enqueueObject:[NSNumber numberWithInt:1]];
    [self.queue enqueueObject:[NSNull null]];
    
    candidate = [self.queue dequeueObject];
    expected = @"Hi";
    STAssertEqualObjects(candidate, expected, @"FAILURE- expected %@, but got %@", expected, candidate);
    candidate = [self.queue dequeueObject];
    expected = @"Hi3";
    STAssertEqualObjects(candidate, expected, @"FAILURE- expected %@, but got %@", expected, candidate);
    
    [self.queue enqueueObject:@"Surprise"];    
    
    candidate = [self.queue dequeueObject];
    expected = @"Hi4";
    STAssertEqualObjects(candidate, expected, @"FAILURE- expected %@, but got %@", expected, candidate);
    candidate = [self.queue dequeueObject];
    expected = [NSNumber numberWithInt:1];
    STAssertEqualObjects(candidate, expected, @"FAILURE- expected %@, but got %@", expected, candidate);
    candidate = [self.queue dequeueObject];
    expected = [NSNull null];
    STAssertEqualObjects(candidate, expected, @"FAILURE- expected %@, but got %@", expected, candidate);
    candidate = [self.queue dequeueObject];
    expected = @"Surprise";
    STAssertEqualObjects(candidate, expected, @"FAILURE- expected %@, but got %@", expected, candidate);
    candidate = [self.queue dequeueObject];
    STAssertNil(candidate, @"FAILURE- expected nil, got %@", candidate);
    candidate = [self.queue dequeueObject];
    STAssertNil(candidate, @"FAILURE- expected nil, got %@", candidate);
    candidate = [self.queue dequeueObject];
    STAssertNil(candidate, @"FAILURE- expected nil, got %@", candidate);
    candidate = [self.queue dequeueObject];
    STAssertNil(candidate, @"FAILURE- expected nil, got %@", candidate);
    
}

- (void)testRemoveFromQueue;
{
    id candidate;
    id expected;
    NSUInteger expectedCount;
    
    candidate = [self.queue dequeueObject];
    STAssertNil(candidate, @"FAILURE- expected nil, got %@", candidate);
    
    [self.queue enqueueObject:@"Hi"];
    [self.queue enqueueObject:@"Hi"];
    [self.queue enqueueObject:@"Hi3"];
    [self.queue enqueueObject:@"Hi4"];
    [self.queue enqueueObject:[NSNumber numberWithInt:1]];
    [self.queue enqueueObject:[NSNumber numberWithInt:1]];
    [self.queue enqueueObject:[NSNull null]];
    
    
    [self.queue removeObjectFromQueue:[NSNull null]];
    expectedCount = 4;
    STAssertEquals([self.queue count], expectedCount, @"FAILURE- expected %d, but got %d", expectedCount, [self.queue count]);
    [self.queue removeObjectFromQueue:[NSNull null]];
    expectedCount = 4;
    STAssertEquals([self.queue count], expectedCount, @"FAILURE- expected %d, but got %d", expectedCount, [self.queue count]);
    [self.queue removeObjectFromQueue:@"Hi"];
    expectedCount = 3;
    STAssertEquals([self.queue count], expectedCount, @"FAILURE- expected %d, but got %d", expectedCount, [self.queue count]);
    
    candidate = [self.queue dequeueObject];
    expected = @"Hi3";
    STAssertEqualObjects(candidate, expected, @"FAILURE- expected %@, but got %@", expected, candidate);
    
    [self.queue removeObjectFromQueue:[NSNumber numberWithInt:1]];
    expectedCount = 1;
    STAssertEquals([self.queue count], expectedCount, @"FAILURE- expected %d, but got %d", expectedCount, [self.queue count]);
    
    candidate = [self.queue dequeueObject];
    expected = @"Hi4";
    STAssertEqualObjects(candidate, expected, @"FAILURE- expected %@, but got %@", expected, candidate);
    expectedCount = 0;
    STAssertEquals([self.queue count], expectedCount, @"FAILURE- expected %d, but got %d", expectedCount, [self.queue count]);
    
    [self.queue removeObjectFromQueue:[NSNumber numberWithInt:1]];
    expectedCount = 0;
    STAssertEquals([self.queue count], expectedCount, @"FAILURE- expected %d, but got %d", expectedCount, [self.queue count]);
    [self.queue removeObjectFromQueue:[NSNumber numberWithInt:1]];
    expectedCount = 0;
    STAssertEquals([self.queue count], expectedCount, @"FAILURE- expected %d, but got %d", expectedCount, [self.queue count]);
    [self.queue removeObjectFromQueue:[NSNumber numberWithInt:1]];
    expectedCount = 0;
    STAssertEquals([self.queue count], expectedCount, @"FAILURE- expected %d, but got %d", expectedCount, [self.queue count]);
}


- (void)testTestFramework;
{
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