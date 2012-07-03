/******************************************************************************
 * - Created 2012/05/11 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * <#SUMMARY INFORMATION#>
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

#import <Foundation/Foundation.h>
#import "RLRequestProtocol.h"

#pragma mark ** Constant Defines **

#pragma mark ** Protocols & Declarations **

@interface RLTestRequest : NSObject <RLRequestProtocol>
{

}

#pragma mark ** Designated Initializer **

- (id)initWithName:(NSString *)name
 completionHandler:(void (^)(NSString *name))completionHandler;

#pragma mark ** Properties **

#pragma mark ** Methods **

#pragma mark ** RLRequestProtocol Methods **

@end
