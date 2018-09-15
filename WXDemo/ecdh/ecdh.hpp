//
//  ecdh.hpp
//  ECDH
//
//  Created by ray on 2018/8/3.
//  Copyright © 2018 ray. All rights reserved.
//

#ifndef ecdh_hpp
#define ecdh_hpp

bool GenEcdh(int nid, unsigned char *szPriKey, int *pLenPri, unsigned char *szPubKey, int *pLenPub);
bool DoEcdh(int nid, unsigned char * szServerPubKey, int nLenServerPub, unsigned char * szLocalPriKey, int nLenLocalPri, unsigned char * szShareKey, int *pLenShareKey);

#endif /* ecdh_hpp */
