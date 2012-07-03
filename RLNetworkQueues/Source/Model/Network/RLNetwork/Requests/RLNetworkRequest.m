/******************************************************************************
 * - Created 2012/05/11 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * <#SUMMARY INFORMATION#>
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

#import "RLNetworkRequest.h"
#import "RLConnection.h"

@interface RLNetworkRequest ()
@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) RLConnection *activeConnection;
@property (nonatomic, strong) RLConnectionManagerProgressHandlerBlockType progressHandler;
@property (nonatomic, strong) RLConnectionManagerSuccessHandlerBlockType successHandler;
@property (nonatomic, strong) RLConnectionManagerErrorHandlerBlockType errorHandler;
@end

@implementation RLNetworkRequest
#pragma mark ** Synthesis **

@synthesize urlRequest = _urlRequest;
@synthesize activeConnection = _activeConnection;
@synthesize progressHandler = _progressHandler;
@synthesize successHandler = _successHandler;
@synthesize errorHandler = _errorHandler;

#pragma mark ** Static Variables **

//*****************************************************************************
#pragma mark -
#pragma mark ** Lifecycle & Memory Management **

- (id)init;
{
    SHOULD_NEVER_GET_HERE;
    return nil;
}

- (id)initWithURLRequest:(NSURLRequest *)urlRequest
         progressHandler:(RLConnectionManagerProgressHandlerBlockType)outerProgressHandlerBlock
          successHandler:(RLConnectionManagerSuccessHandlerBlockType)outerSuccessHandlerBlock
            errorHandler:(RLConnectionManagerErrorHandlerBlockType)outerErrorHandlerBlock;
{
    self = [super init];
    if (self)
    {
        self.urlRequest = urlRequest;
        self.progressHandler = outerProgressHandlerBlock;
        self.successHandler = outerSuccessHandlerBlock;
        self.errorHandler = outerErrorHandlerBlock;
    }
    return self;
}

- (id)initWithGetRequestToURL:(NSURL *)url
                successHandler:(RLConnectionManagerSuccessHandlerBlockType)outerSuccessHandlerBlock
                  errorHandler:(RLConnectionManagerErrorHandlerBlockType)outerErrorHandlerBlock;
{
    NSMutableURLRequest *urlRequest = [RLConnection httpRequestWithURL:url
                                                            httpMethod:@"GET"
                                                                  data:nil
                                                          extraHeaders:nil];
    
    return [self initWithURLRequest:urlRequest 
                    progressHandler:nil 
                     successHandler:outerSuccessHandlerBlock 
                       errorHandler:outerErrorHandlerBlock];
}

- (id)initWithPostRequestToURL:(NSURL *)url
                          data:(NSData *)requestData
               progressHandler:(RLConnectionManagerProgressHandlerBlockType)outerProgressHandlerBlock
                successHandler:(RLConnectionManagerSuccessHandlerBlockType)outerSuccessHandlerBlock
                  errorHandler:(RLConnectionManagerErrorHandlerBlockType)outerErrorHandlerBlock;
{
    NSMutableURLRequest *urlRequest = [RLConnection httpRequestWithURL:url
                                                            httpMethod:@"POST"
                                                                  data:requestData
                                                          extraHeaders:nil];

    return [self initWithURLRequest:urlRequest 
                    progressHandler:outerProgressHandlerBlock 
                     successHandler:outerSuccessHandlerBlock 
                       errorHandler:outerErrorHandlerBlock];
}

- (id)initWithPutRequestToURL:(NSURL *)url
                         data:(NSData *)requestData
              progressHandler:(RLConnectionManagerProgressHandlerBlockType)outerProgressHandlerBlock
               successHandler:(RLConnectionManagerSuccessHandlerBlockType)outerSuccessHandlerBlock
                 errorHandler:(RLConnectionManagerErrorHandlerBlockType)outerErrorHandlerBlock;
{
    NSMutableURLRequest *urlRequest = [RLConnection httpRequestWithURL:url
                                                            httpMethod:@"PUT"
                                                                  data:requestData
                                                          extraHeaders:nil];
    
    return [self initWithURLRequest:urlRequest 
                    progressHandler:outerProgressHandlerBlock 
                     successHandler:outerSuccessHandlerBlock 
                       errorHandler:outerErrorHandlerBlock];
}

- (void)dealloc;
{
    
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Connection Methods **

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
            self.activeConnection = nil;
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
            self.activeConnection = nil;
			outerErrorHandlerBlock(request, error);
        };
	};
	
	// set "in-flight" status
    self.activeConnection = connection;
	
	// Launch the request
	[connection startHttpRequestWithURLRequest:urlRequest
                               progressHandler:progressHandler
								successHandler:successHandler
								  errorHandler:errorHandler];
}

//*****************************************************************************
#pragma mark -
#pragma mark ** RLRequestProtocol **

- (void)executeRequestWithCompetionHandler:(RLRequestProtocolCompletionHandlerBlockType)completionHandler
{
    // launch the request
   [self startURLRequest:self.urlRequest
                           progressHandler:self.progressHandler
                            successHandler:^(NSURLRequest *request, NSURLResponse *response, NSData *responseData) {
                                self.successHandler(request, response, responseData);
                                completionHandler(self);
                            } errorHandler:^(NSURLRequest *request, NSError *error) {
                                self.errorHandler(request, error);
                                completionHandler(self);
                            }];
}

- (void)cancelRequest;
{
    return;
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Accesssors **

@end
