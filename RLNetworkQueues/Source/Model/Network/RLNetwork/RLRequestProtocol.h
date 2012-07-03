/******************************************************************************
 * - Created 2012/05/09 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * <#SUMMARY INFORMATION#>
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark ** Constant Defines **

#pragma mark -
#pragma mark ** Declarations **

//@protocol RLRequestProtocol;
//typedef void (^RLRequestProtocolLifecycleChangeHandlerBlockType)(__weak NSObject <RLRequestProtocol> *requestObject, RLRequestLifecyleState previousState, RLRequestLifecyleState currentState);
//
//#pragma mark -
//#pragma mark ** RLRequestProtocol **
//@protocol RLRequestProtocol <NSObject>
//
//#pragma mark ** Properties **
//
//@property (nonatomic, copy) RLRequestProtocolLifecycleChangeHandlerBlockType lifecycleStateChangeHandler;
//
//@property (nonatomic, assign, readonly) RLRequestLifecyleState currentLifecyleState;
//
//#pragma mark ** Methods **
//
//- (void)markRequestSubmitted;
//- (void)executeRequest;
//
//@optional
//- (void)cancelRequest;
//
//@end

@protocol RLRequestProtocol;
typedef void (^RLRequestProtocolCompletionHandlerBlockType)(__weak NSObject <RLRequestProtocol> *requestObject);

#pragma mark -
#pragma mark ** RLRequestProtocol **
@protocol RLRequestProtocol <NSObject>

#pragma mark ** Properties **

#pragma mark ** Methods **

/** 
 Executes request and waits for protocol implementer to call `completionHandler(self)`.
 Protocol implementer MUST call `completionHandler(self)` when the request is finished processing or the request will stall the queue.
 */
- (void)executeRequestWithCompetionHandler:(RLRequestProtocolCompletionHandlerBlockType)completionHandler;

@optional

/**
 This method is called when the request is canceled by Request Manager.
 */
- (void)cancelRequest;

@end