//
//  mmpack.h
//  Pack
//
//  Created by ray on 2019/1/27.
//  Copyright © 2019 ray. All rights reserved.
//

#ifndef mmpack_h
#define mmpack_h

#include "defs.h"
#include "autobuffer.h"

//a7=0
//a8=0

//
//a13=0
void ** EncodeRSAPack(AutoBuffer *out, __int64 serilizedData, __int64 dataLen, __int64 certN, __int64 certE, __int64 certVersion, const char *a7, unsigned int a8, unsigned int uin, const char *deviceID, unsigned int cgi, unsigned int clientVersion, unsigned __int8 a13);

#endif /* mmpack_h */
