/*********************************************************************
 *	\file RLConnection.m
 *	\author Matt Nunogawa, @amattn
 *	\date 2010/10/04
 *	\class RLConnection
 *	\brief Part of RLNetwork, http://github.com/amattn/RLNetwork
 *	\details
 *
 *	\abstract CLASS_ABSTRACT
 *	\copyright Copyright Matt Nunogawa 2010-2011. All rights reserved.
 */

#import "RLConnection.h"

#define DEFAULT_TIMEOUT 300

@interface RLConnection ()
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) NSURLResponse *urlResponse;
@property (nonatomic, copy) RLConnectionProgressHandlerBlockType progressHandler;
@property (nonatomic, copy) RLConnectionSuccessHandlerBlockType sucesssHandler;
@property (nonatomic, copy) RLConnectionErrorHandlerBlockType errorHandler;
@property (nonatomic, strong, readwrite) NSDate *requestTime;
@property (nonatomic, strong, readwrite) NSDate *responseTime;
@end

@implementation RLConnection
#pragma mark ** Synthesis **

@synthesize receivedData = _receivedData;
@synthesize connection = _connection;
@synthesize urlRequest = _urlRequest;
@synthesize urlResponse = _urlResponse;
@synthesize progressHandler = _progressHandler;
@synthesize sucesssHandler = _sucesssHandler;
@synthesize errorHandler = _errorHandler;
@synthesize requestTime = _requestTime;
@synthesize responseTime = _responseTime;
@synthesize totalBytesWritten = _totalBytesWritten;

/*********************************************************************/
#pragma mark -
#pragma mark ** Lifecycle & Memory Mangement **

// none, ARC will take care of everything for us

- (void)dealloc
{
    LOG_METHOD;
}

/*********************************************************************/
#pragma mark -
#pragma mark ** Actions **

+ (NSMutableURLRequest *)httpRequestWithURL:(NSURL *)url
								 httpMethod:(NSString *)httpMethod // GET, PUT or POST
									   data:(NSData *)bodyData
							   extraHeaders:(NSDictionary *)extraHeaders;
{
	NSMutableURLRequest *urlRequest;
	urlRequest = [[NSMutableURLRequest alloc] initWithURL:url
											  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
										  timeoutInterval:DEFAULT_TIMEOUT];
	[urlRequest setHTTPMethod:httpMethod];
	[urlRequest setHTTPShouldHandleCookies:NO];
	if (bodyData)
		[urlRequest setHTTPBody:bodyData];
	if (extraHeaders)
		[urlRequest setAllHTTPHeaderFields:extraHeaders];
	return urlRequest;
}

- (void)startHttpRequestWithURLRequest:(NSURLRequest *)urlRequest
                       progressHandler:(RLConnectionProgressHandlerBlockType)progressHandlerBlock
						successHandler:(RLConnectionSuccessHandlerBlockType)successHandlerBlock
						  errorHandler:(RLConnectionErrorHandlerBlockType)errorHandlerBlock;
{
    void (^launchRequest)() = ^{        
        self.urlRequest = urlRequest;
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self startImmediately:NO];
        
        if (connection)
        {
            self.requestTime = [NSDate date];
            self.connection = connection;
            self.receivedData = [NSMutableData data];
            self.progressHandler = progressHandlerBlock;
            self.sucesssHandler = successHandlerBlock;
            self.errorHandler = errorHandlerBlock;
            
            [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            [connection start];
        }
        else 
        {
            errorHandlerBlock(self.urlRequest, nil, nil);
        }
    };
    
    if (dispatch_get_main_queue() == dispatch_get_current_queue()) {
        launchRequest();
    } else {
        dispatch_async(dispatch_get_main_queue(), launchRequest);
    }
}

- (void)cleanup;
{
    // This is kind of redundant with ARC.
	self.receivedData = nil;
	self.urlRequest = nil;
	self.urlResponse = nil;
	self.connection = nil;
	self.progressHandler = nil;
	self.sucesssHandler = nil;
	self.errorHandler = nil;
}

/*********************************************************************/
#pragma mark -
#pragma mark ** NSURLConnectionDelegate Methods **

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.urlResponse = response;
	self.responseTime = [NSDate date];
	[self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (self.progressHandler)
    {
        __weak NSURLRequest *weakRequest = self.urlRequest;
        self.progressHandler(weakRequest, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (self.errorHandler)
    {
        __weak NSURLRequest *weakRequest = self.urlRequest;
        __weak NSURLResponse *weakResponse = self.urlResponse;
		self.errorHandler(weakRequest, weakResponse, error);
    }
	[self cleanup];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (self.sucesssHandler)
    {
        __weak NSURLRequest *weakRequest = self.urlRequest;
        __weak NSURLResponse *weakResponse = self.urlResponse;
        __weak NSData *weakData = self.receivedData;
		self.sucesssHandler(weakRequest, weakResponse, weakData);
    }
	[self cleanup];
}


// Customize here if necessary
// - (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
// {
// 	return cachedResponse;
// }

// Customize here if necessary
// - (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
// {
// 	return NO;
// }

/*********************************************************************/
#pragma mark -
#pragma mark ** Accesssors **


@end
