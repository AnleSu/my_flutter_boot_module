//
//  UCARLoadingViewProtocol.h
//  UCARUIKit
//
//  Created by linux on 28/02/2018.
//

#ifndef UCARLoadingViewProtocol_h
#define UCARLoadingViewProtocol_h

#import <Foundation/Foundation.h>

@protocol UCARLoadingViewProtocol <NSObject>

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end

#endif /* UCARLoadingViewProtocol_h */
