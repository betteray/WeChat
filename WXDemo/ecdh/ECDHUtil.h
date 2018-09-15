//
//  ECDHUtil.h
//  WXDemo
//
//  Created by ray on 2018/9/15.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECDHUtil : NSObject

//bool GenEcdh(int nid, unsigned char *szPriKey, int *pLenPri, unsigned char *szPubKey, int *pLenPub);
//bool DoEcdh(int nid, unsigned char * szServerPubKey, int nLenServerPub, unsigned char * szLocalPriKey, int nLenLocalPri, unsigned char * szShareKey, int *pLenShareKey);


+ (bool)GenEcdh:(int)nid  szPriKey:(unsigned char *)szPriKey pLenPri:(int *)pLenPri szPubKey:( unsigned char *)szPubKey  pLenPub:(int *)pLenPub;
+ (bool)DoEcdh:(int)nid szServerPubKey:(unsigned char *)szServerPubKey nLenServerPub:(int) nLenServerPub szLocalPriKey:(unsigned char *)szLocalPriKey nLenLocalPri:(int) nLenLocalPri szShareKey:(unsigned char *)szShareKey:(int *)pLenShareKey;

@end
