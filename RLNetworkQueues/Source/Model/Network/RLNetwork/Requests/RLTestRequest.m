/******************************************************************************
 * - Created 2012/05/11 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * <#SUMMARY INFORMATION#>
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

#import "RLTestRequest.h"

@interface RLTestRequest ()
@property (nonatomic, copy) void (^completionHandler)(NSString *name);
@property (nonatomic, strong) NSString *name;
@end

@implementation RLTestRequest
#pragma mark ** Synthesis **

@synthesize completionHandler = _completionHandler;
@synthesize name = _name;

#pragma mark ** Static Variables **

//*****************************************************************************
#pragma mark -
#pragma mark ** Lifecycle & Memory Management **

- (id)initWithName:(NSString *)name
 completionHandler:(void (^)(NSString *name))completionHandler;
{
    self = [super init];
    if (self)
    {
        self.completionHandler = completionHandler;
        self.name = name;
    }
    return self;
}

- (void)dealloc;
{
    
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Utilities **

//*****************************************************************************
#pragma mark -
#pragma mark ** RLRequestProtocol **

- (void)executeRequestWithCompetionHandler:(RLRequestProtocolCompletionHandlerBlockType)completionHandler;
{
    usleep(100000);
    self.completionHandler(self.name);
    completionHandler(self);
}

- (void)cancelRequest;
{
    return;
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Accesssors **

@end
