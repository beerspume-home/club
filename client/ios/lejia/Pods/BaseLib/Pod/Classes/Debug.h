//
//  Debug.h
//  BaseLib
//
//  Created by Sean Shi on 15/10/24.
//  Copyright © 2015年 车友会. All rights reserved.
//

#ifndef BaseLib_Debug_h
#define BaseLib_Debug_h

//调试模式日志输出
#ifdef DEBUG
#define debugLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define debugLog(format, ...)
#endif


#endif /* Debug_h */
