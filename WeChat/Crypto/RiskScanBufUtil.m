//
//  RiskScanBufUtil.m
//  WeChat
//
//  Created by ray on 2019/10/18.
//  Copyright © 2019 ray. All rights reserved.
//

#import "RiskScanBufUtil.h"
#import "FSOpenSSL.h"

@implementation RiskScanBufUtil

+ (NSData *)getKey {

    int arr[] = {-36, -46, -45, -77, -22, -10, 47, -77, -72, -69, -32, 25, 21, -21, -6, -75, -71, 31, -39, -49, -49};
    char str[] = "http://pmir.3g.qq.com";
    for (int i = 0; i < strlen(str); i++) {
        str[i] = str[i] + arr[i];
    }
    
    return [NSData dataWithBytes:str length:strlen(str)];
}

static void a(Byte bArr[], int bArrLen, int iArr[], int iArrLen) {
    int length = bArrLen >> 2;
    int i = 0;
    int i2 = 0;
    while (i < length) {
        int i3 = i2 + 1;
        iArr[i] = bArr[i2] & 255;
        int i4 = i3 + 1;
        iArr[i] = ((bArr[i3] & 255) << 8) | iArr[i];
        int i5 = i4 + 1;
        iArr[i] = iArr[i] | ((bArr[i4] & 255) << 16);
        iArr[i] = iArr[i] | ((bArr[i5] & 255) << 24);
        i++;
        i2 = i5 + 1;
    }
    if (i2 < bArrLen) {
        int i6 = i2 + 1;
        iArr[i] = bArr[i2] & 255;
        int i7 = 8;
        while (i6 < bArrLen) {
            iArr[i] = iArr[i] | ((bArr[i6] & 255) << i7);
            i6++;
            i7 += 8;
        }
    }
}

static void a2(int iArr[], int iArrLen, int i, Byte bArr[], int bArrLen) {
    int length = bArrLen >> 2;
    if (length > i) {
        length = i;
    }
    int i2 = 0;
    int i3 = 0;
    while (i2 < length) {
        int i4 = i3 + 1;
        bArr[i3] = (Byte) (iArr[i2] & 255);
        int i5 = i4 + 1;
        bArr[i4] = (Byte) (( (unsigned int) iArr[i2] >> 8) & 255);
        int i6 = i5 + 1;
        bArr[i5] = (Byte) (( (unsigned int) iArr[i2] >> 16) & 255);
        i3 = i6 + 1;
        bArr[i6] = (Byte) (( (unsigned int) iArr[i2] >> 24) & 255);
        i2++;
    }
    if (i > length && i3 < bArrLen) {
        int i7 = i3 + 1;
        bArr[i3] = (Byte) (iArr[i2] & 255);
        int i8 = 8;
        while (i8 <= 24 && i7 < bArrLen) {
            bArr[i7] = (Byte) (((unsigned int) iArr[i2] >> i8) & 255);
            i8 += 8;
            i7++;
        }
    }
}

+ (NSData *)encrypt:(NSData *)data key:(NSData *)key {
    NSData *md5 = [FSOpenSSL md5FromData:key];
    Byte * v2 = (Byte *) md5.bytes;
    if(data == nil || v2 == NULL || data.length == 0) {
    }
    else {
        int dataLen = (int) data.length;
        int v0 = dataLen % 4 == 0 ? ( (unsigned int) dataLen >> 2) + 1 : ( (unsigned int) dataLen >> 2) + 2;
        int vo_copy = v0;
        int *v4 = calloc(v0, sizeof(int));
        char *buf = (char *) data.bytes;
        a((unsigned char *) buf, (int) data.length, v4, v0);
        v4[v0 - 1] = (int) data.length;
        unsigned int md5Len = (unsigned int) md5.length;
        v0 = md5Len % 4 == 0 ? md5Len >> 2 : ( md5Len >> 2) + 1;
        if(v0 < 4) {
            v0 = 4;
        }

        int * v5 = calloc(v0, sizeof(int));
        int v1;
        for(v1 = 0; v1 < v0; ++v1) {
            v5[v1] = 0;
        }

        a(v2, md5Len, v5, v0);
        int v6 = vo_copy - 1;
        int v3 = v4[v6];
        v0 = 52 / (v6 + 1) + 6;
        int v2_1 = 0;
        while(true) {
            v1 = v0 - 1;
            if(v0 <= 0) {
                break;
            }

            v2_1 += -1640531527;
            int v7 = (unsigned int)v2_1 >> 2 & 3;
            for(v0 = 0; v0 < v6; ++v0) {
                v3 = ((v3 ^ v5[(v0 & 3) ^ v7]) + (v4[v0 + 1] ^ v2_1) ^ ((unsigned int) v3 >> 5 ^ v4[v0 + 1] << 2) + ((unsigned int) v4[v0 + 1] >> 3 ^ v3 << 4)) + v4[v0];
                v4[v0] = v3;
            }


            v3 = v4[v6] + ((v5[(v0 & 3) ^ v7] ^ v3) + (v4[0] ^ v2_1) ^ ((unsigned int) v3 >> 5 ^ v4[0] << 2) + ((unsigned int) v4[0] >> 3 ^ v3 << 4));
            v4[v6] = v3;
            v0 = v1;
        }

        Byte *result = calloc(vo_copy << 2, sizeof(Byte));
        a2(v4, vo_copy << 2, vo_copy << 2, result, vo_copy << 2);
        
        return [[NSData alloc] initWithBytes:result length:vo_copy << 2 ];
    }
    return nil;
}

+ (NSData *)decrypt:(NSData *)ciphertext key:(NSData *)key {
    NSData *md5 = [FSOpenSSL md5FromData:key];    
    if (ciphertext == nil || md5 == nil || ciphertext.length == 0) {
        return ciphertext;
    } else if (ciphertext.length % 4 != 0 || ciphertext.length < 8) {
        return nil;
    } else {
        int iArrLen = (int) ciphertext.length >> 2;
        int * iArr = calloc(iArrLen, sizeof(int));
        char *buf = (char *) ciphertext.bytes;
        a((unsigned char *) buf, (int) ciphertext.length, iArr, iArrLen);
        int length = (int) md5.length % 4 == 0 ? (int) md5.length >> 2 : ( (int) md5.length >> 2) + 1;
        if (length < 4) {
            length = 4;
        }
        int * iArr2 = calloc(length, sizeof(int));
        for (int i = 0; i < length; i++) {
            iArr2[i] = 0;
        }
        char *buf2 = (char *) md5.bytes;
        a((unsigned char *) buf2, (int) md5.length, iArr2, length);
        int length2 = iArrLen - 1;
        int i2 = iArr[0];
        for (int i3 = ((52 / (length2 + 1)) + 6) * -1640531527; i3 != 0; i3 -= -1640531527) {
            int i4 = ((unsigned int) i3 >> 2) & 3;
            int i5 = length2;
            while (i5 > 0) {
                int i6 = iArr[i5 - 1];
                i2 = iArr[i5] - (((i2 ^ i3) + (i6 ^ iArr2[(i5 & 3) ^ i4])) ^ ((( (unsigned int) i6 >> 5) ^ (i2 << 2)) + (( (unsigned int) i2 >> 3) ^ (i6 << 4))));
                iArr[i5] = i2;
                i5--;
            }
            int i7 = iArr[length2];
            i2 = iArr[0] - (((iArr2[(i5 & 3) ^ i4] ^ i7) + (i2 ^ i3)) ^ ((( (unsigned int) i7 >> 5) ^ (i2 << 2)) + (( (unsigned int) i2 >> 3) ^ (i7 << 4))));
            iArr[0] = i2;
        }
        int i8 = iArr[length2];
        if (i8 < 0 || i8 > ((iArrLen - 1) << 2)) {
            return nil;
        }
        Byte * bArr3 = calloc(i8, sizeof(Byte));
        a2(iArr, iArrLen, (int) iArrLen - 1, bArr3, i8);
        
        return [[NSData alloc] initWithBytes:bArr3 length:i8];
    }
}



@end
