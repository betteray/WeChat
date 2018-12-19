//
//  ECDHUtil.h
//  WXDemo
//
//  Created by ray on 2018/9/15.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECDH : NSObject

+ (BOOL)GenEcdhWithNid:(int)nid priKey:(NSData **)pPriKeyData pubKeyData:(NSData **)pPubKeyData;

+ (bool)DoEcdh:(int)nid
szServerPubKey:(unsigned char *)szServerPubKey
 nLenServerPub:(int)nLenServerPub
 szLocalPriKey:(unsigned char *)szLocalPriKey
  nLenLocalPri:(int)nLenLocalPri
    szShareKey:(unsigned char *)szShareKey
  pLenShareKey:(int *)pLenShareKey;

+ (NSData *)DoEcdh2:(int)nid
       ServerPubKey:(NSData *)serverPubKey
        LocalPriKey:(NSData *)localPriKey;

@end
