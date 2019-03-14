//
//  NeedRSAEncodePack.c
//  WeChat
//
//  Created by ysh on 2019/1/29.
//  Copyright © 2019 ray. All rights reserved.
//

#include "NeedRSAEncodePack.h"
#include "defs.h"


signed __int64 sub_10325D650(signed int cgi)
{
    signed int cgi_1; // w8
    signed __int64 result; // x0
    unsigned int v3; // w8
    
    cgi_1 = cgi;
    result = 1LL;
    if ( cgi_1 <= 986 )
    {
        if ( cgi_1 == 443 || cgi_1 == 499 || cgi_1 == 694 )
            return result;
        return 0LL;
    }
    v3 = cgi_1 - 987;
    if ( v3 > 0xA || !((1 << v3) & 0x405) )
        return 0LL;
    return result;
}

signed __int64 sub_10325D554(signed int cgi)
{
    signed int cgi_1; // w8
    signed __int64 result; // x0
    
    cgi_1 = cgi;
    result = 1LL;
    if ( cgi_1 <= 615 )
    {
        if ( cgi_1 > 428 )
        {
            if ( (cgi_1 - 502) < 2 || cgi_1 == 429 )
                return result;
        }
        else if ( cgi_1 == 126 || cgi_1 == 145 || cgi_1 == 353 )
        {
            return result;
        }
        return 0LL;
    }
    if ( cgi_1 > 735 )
    {
        if ( ((cgi_1 - 915) > 0x10 || !((1 << (cgi_1 + 109)) & 0x18001)) && cgi_1 != 736 )
            return 0LL;
    }
    else if ( ((cgi_1 - 616) > 0x26 || !((1LL << (cgi_1 - 104)) & 0x4000000007LL)) && cgi_1 != 733 )
    {
        return 0LL;
    }
    return result;
}

int NeedRSAEncodePack(int cgi)
{
    signed int v1; // w19
    char v2; // w0
    int result; // x0
    
    v1 = cgi;
    v2 = sub_10325D650(cgi);
    if ( v1 == 381 || v2 & 1 )
        result = 1LL;
    else
        result = sub_10325D554(v1);
    return result;
}
