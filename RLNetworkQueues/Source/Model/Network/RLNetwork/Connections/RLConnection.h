/*********************************************************************
 *	\file RLConnection.h
 *	\author Matt Nunogawa, @amattn
 *	\date 2010/10/04
 *	\class RLConnection
 *	\brief Part of RLNetwork, http://github.com/amattn/RLNetwork
 *	\details
 *
 *	\abstract CLASS_ABSTRACT 
 *	\copyright Copyright Matt Nunogawa 2010-2011. All rights reserved.
 */

#import <Foundation/Foundation.h>

#pragma mark ** Constant Defines **

#pragma mark ** Protocols & Declarations **

typedef void (^RLConnectionProgressHandlerBlockType)(NSURLRequest *request, NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);
typedef void (^RLConnectionSuccessHandlerBlockType)(NSURLRequest *request, NSURLResponse *response, NSData *data);
typedef void (^RLConnectionErrorHandlerBlockType)(NSURLRequest *request, NSURLResponse *response, NSError *error);

@interface RLConnection : NSObject
{
	
}

#pragma mark ** Properties **

@property (nonatomic, strong, readonly) NSDate *requestTime;
@property (nonatomic, strong, readonly) NSDate *responseTime;
@property (nonatomic, assign, readonly) NSInteger totalBytesWritten; // PUT or POST only

#pragma mark ** Methods **

+ (NSMutableURLRequest *)httpRequestWithURL:(NSURL *)url
								 httpMethod:(NSString *)httpMethod // GET, PUT or POST
									   data:(NSData *)bodyData
							   extraHeaders:(NSDictionary *)extraHeaders;

// progressHandler is only valid for POST and PUT
- (void)startHttpRequestWithURLRequest:(NSURLRequest *)urlRequest
                       progressHandler:(RLConnectionProgressHandlerBlockType)progressHandlerBlock
						successHandler:(RLConnectionSuccessHandlerBlockType)successHandlerBlock
						  errorHandler:(RLConnectionErrorHandlerBlockType)errorHandlerBlock;

@end
