/*********************************************************************
 *	\file RLNetworkManager.m
 *	\author Matt Nunogawa, @amattn
 *	\date 2010/10/04
 *	\class RLNetworkManager
 *	\brief Part of RLNetwork, http://github.com/amattn/RLNetwork
 *	\details
 *
 *	\abstract CLASS_ABSTRACT
 *	\copyright Copyright Matt Nunogawa 2010-2011. All rights reserved.
 */

#import "RLConnectionManager.h"
#import "RLConnection.h"

@interface RLConnectionManager ()
@property (nonatomic, retain) NSMutableSet *activeConnections;
@end

@implementation RLConnectionManager

#pragma mark ** Synthesis **
@synthesize activeConnections = _activeConnections;

#pragma mark ** Static Variables **
static RLConnectionManager *__sharedRLNetworkManager = nil;

#pragma mark ** Singleton **
+ (RLConnectionManager *)singleton;
{
    static dispatch_once_t createSingletonPredicate;
    dispatch_once(&createSingletonPredicate, ^
    {
        __sharedRLNetworkManager = [[RLConnectionManager alloc] init];
    });
    return __sharedRLNetworkManager;
}

/*********************************************************************/
#pragma mark -
#pragma mark ** Lifecyle & Memory Management **

- (id)init;
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}

/*********************************************************************/
#pragma mark -
#pragma mark ** Utilities **

/*********************************************************************/
#pragma mark -
#pragma mark ** Basic Request Method **

- (void)startURLRequest:(NSURLRequest *)urlRequest
        progressHandler:(RLConnectionManagerProgressHandlerBlockType)outerProgressHandler
         successHandler:(RLConnectionManagerSuccessHandlerBlockType)outerSuccessHandlerBlock
           errorHandler:(RLConnectionManagerErrorHandlerBlockType)outerErrorHandlerBlock;
{
	RLConnection *connection = [[RLConnection alloc] init];

    // Progress is used to track progress of POST and PUT requests
    RLConnectionManagerProgressHandlerBlockType progressHandler = nil;
    if ([urlRequest.HTTPMethod isEqualToString:@"POST"] || [urlRequest.HTTPMethod isEqualToString:@"PUT"])
    {
		if (outerProgressHandler)
        {
            progressHandler = ^(NSURLRequest *request, NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite)
            {
                outerProgressHandler(request, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
            };
        }
    }

	// If we succeed, do this
    RLConnectionSuccessHandlerBlockType successHandler = nil;
    if (outerSuccessHandlerBlock)
    {
        successHandler = ^(NSURLRequest *request, NSURLResponse *response, NSData *responseData)
        {
            //remove this connection from "in-flight" status
            [self.activeConnections removeObject:connection];
            outerSuccessHandlerBlock(request, response, responseData);
        };
    }
	
    
	// If we fail, do this
	RLConnectionErrorHandlerBlockType errorHandler = nil;
    if (outerErrorHandlerBlock)
	{
        errorHandler = ^(NSURLRequest *request, NSURLResponse *response, NSError *error)
        {
            //remove this connection from "in-flight" status
            [self.activeConnections removeObject:connection];
			outerErrorHandlerBlock(request, error);
        };
	};
	
	// remember which requests are "in-flight"
	[self.activeConnections addObject:connection];
	
	// Launch the request
	[connection startHttpRequestWithURLRequest:urlRequest
                               progressHandler:progressHandler
								successHandler:successHandler
								  errorHandler:errorHandler];
}

/*********************************************************************/
#pragma mark -
#pragma mark ** Accesssors **

- (NSMutableSet *)activeConnections;
{
	// Lazy load
	if (_activeConnections == nil)
		_activeConnections = [NSMutableSet set];
	
	return _activeConnections;
}

- (NSUInteger)activeConnectionsCount;
{
	return [self.activeConnections count];
}

@end
