/******************************************************************************
 * - Created 2012/05/11 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * <#SUMMARY INFORMATION#>
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

#import "RLRequestProtocol.h"
#import "RLConnectionManager.h"

#pragma mark ** Constant Defines **

#pragma mark ** Protocols & Declarations **

@interface RLNetworkRequest : NSObject <RLRequestProtocol>

#pragma mark ** Designated Initializer **

- (id)initWithURLRequest:(NSURLRequest *)urlRequest
         progressHandler:(RLConnectionManagerProgressHandlerBlockType)outerProgressHandlerBlock
          successHandler:(RLConnectionManagerSuccessHandlerBlockType)outerSuccessHandlerBlock
            errorHandler:(RLConnectionManagerErrorHandlerBlockType)outerErrorHandlerBlock;

#pragma mark ** Convenience Initializer **

- (id)initWithGetRequestToURL:(NSURL *)url
               successHandler:(RLConnectionManagerSuccessHandlerBlockType)successHandlerBlock
                 errorHandler:(RLConnectionManagerErrorHandlerBlockType)errorHandlerBlock;

- (id)initWithPostRequestToURL:(NSURL *)url
                          data:(NSData *)requestData
               progressHandler:(RLConnectionManagerProgressHandlerBlockType)progressHandlerBlock
                successHandler:(RLConnectionManagerSuccessHandlerBlockType)successHandlerBlock
                  errorHandler:(RLConnectionManagerErrorHandlerBlockType)errorHandlerBlock;

- (id)initWithPutRequestToURL:(NSURL *)url
                         data:(NSData *)requestData
              progressHandler:(RLConnectionManagerProgressHandlerBlockType)progressHandlerBlock
               successHandler:(RLConnectionManagerSuccessHandlerBlockType)successHandlerBlock
                 errorHandler:(RLConnectionManagerErrorHandlerBlockType)errorHandlerBlock;

#pragma mark ** Properties **

#pragma mark ** Methods **

@end
