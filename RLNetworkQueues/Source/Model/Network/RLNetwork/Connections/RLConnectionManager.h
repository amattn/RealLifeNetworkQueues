/*********************************************************************
 *	\file RLNetworkManager.h
 *	\author Matt Nunogawa, @amattn
 *	\date 2010/10/04
 *	\class RLNetworkManager
 *	\brief Part of RLNetwork, http://github.com/amattn/RLNetwork
 *	\details
 *
 *	\abstract CLASS_ABSTRACT 
 *	\copyright Copyright Matt Nunogawa 2010-2011. All rights reserved.
 */

#import <Foundation/Foundation.h>

#pragma mark ** Constant Defines **

#pragma mark ** Protocols & Declarations **

typedef void (^RLConnectionManagerSuccessHandlerBlockType)(NSURLRequest *request, NSURLResponse *response, NSData *responseData);
typedef void (^RLConnectionManagerProgressHandlerBlockType)(NSURLRequest *request, NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);
typedef void (^RLConnectionManagerErrorHandlerBlockType)(NSURLRequest *request, NSError *error);

@interface RLConnectionManager : NSObject
{
	
}

#pragma mark ** Singleton Accessors **
+ (RLConnectionManager *)singleton;

#pragma mark ** Properties **
@property (nonatomic, readonly) NSUInteger activeConnectionsCount;

#pragma mark ** Generic Request **

- (void)startURLRequest:(NSURLRequest *)urlRequest
        progressHandler:(RLConnectionManagerProgressHandlerBlockType)outerProgressHandler
         successHandler:(RLConnectionManagerSuccessHandlerBlockType)outerSuccessHandlerBlock
           errorHandler:(RLConnectionManagerErrorHandlerBlockType)outerErrorHandlerBlock;



@end
