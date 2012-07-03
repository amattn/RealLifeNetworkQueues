/******************************************************************************
 * - Created 2012/04/10 by Matt Nunogawa
 * - Copyright __MyCompanyName__ 2012. All rights reserved.
 * - License: <#LICENSE#>
 *
 * Set of convenient and useful utilities and macros.
 * Typically imported in the precompiled header (pch) file to 
 * ensure availability across the entire app.
 *
 * Created from templates: https://github.com/amattn/RealLifeXcode4Templates
 */

// Examples:

// Convenient macros that log the name, value and file location of an object or the method in which the macro appears.
#define LOG_OBJECT(object)  (NSLog(@"" #object @" %@ %@:%d", [object description], [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__));
#define LOG_METHOD          (NSLog(@"%@ %@:%d\n%@", NSStringFromSelector(_cmd), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, self))

// Useful, protective assertion macros
#define ASSERT_IS_CLASS(x, class)    NSAssert5([x isKindOfClass:class], @"\n\n    ****  Unexpected Assertion  **** \nReason: Expected class:%@ but got:%@\nAssertion in file:%s at line %i in Method %@", NSStringFromClass(class), x, __FILE__, __LINE__, NSStringFromSelector(_cmd))
#define SUBCLASSES_MUST_OVERRIDE     NSAssert2(FALSE, @"%@ Subclasses MUST override this method:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#define SHOULD_NEVER_GET_HERE        NSAssert4(FALSE, @"\n\n    ****  Should Never Get Here  **** \nAssertion in file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)



