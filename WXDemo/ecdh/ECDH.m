//
//  ECDHUtil.m
//  WXDemo
//
//  Created by ray on 2018/9/15.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ECDH.h"

#include <openssl/aes.h>
#include <openssl/rsa.h>
#include <openssl/ec.h>
#include <openssl/ecdh.h>
#include <openssl/md5.h>

static bool GenEcdh(int nid, unsigned char *szPriKey, int *pLenPri, unsigned char *szPubKey, int *pLenPub);
static bool DoEcdh(int nid, unsigned char * szServerPubKey, int nLenServerPub, unsigned char * szLocalPriKey, int nLenLocalPri, unsigned char * szShareKey, int *pLenShareKey);

#define MD5_DIGEST_LENGTH 16

static bool GenEcdh(int nid, unsigned char *szPriKey, int *pLenPri, unsigned char *szPubKey, int *pLenPub)
{
    if (!szPriKey || !pLenPri || !szPubKey || !pLenPub)        return false;
    
    EC_KEY *ec_key = EC_KEY_new_by_curve_name(nid);
    if (!ec_key) return false;
    
    int ret = EC_KEY_generate_key(ec_key);
    if (1 != ret)
    {
        EC_KEY_free(ec_key);
        ec_key = NULL;
        return false;
    }
    int nLenPub = i2o_ECPublicKey(ec_key, NULL);
    unsigned char *pub_key_buf = NULL;
    ret = i2o_ECPublicKey(ec_key, &pub_key_buf);
    if (!ret)
    {
        EC_KEY_free(ec_key);
        ec_key = NULL;
        return false;
    }
    memcpy(szPubKey, pub_key_buf, nLenPub);
    *pLenPub = nLenPub;
    
    int nLenPri = i2d_ECPrivateKey(ec_key, NULL);
    unsigned char *pri_key_buf = NULL;
    ret = i2d_ECPrivateKey(ec_key, &pri_key_buf);
    if (!ret)
    {
        EC_KEY_free(ec_key);
        ec_key = NULL;
        return false;
    }
    memcpy(szPriKey, pri_key_buf, nLenPri);
    *pLenPri = nLenPri;
    
    if (ec_key)
    {
        EC_KEY_free(ec_key);
        ec_key = NULL;
    }
    if (pub_key_buf)
    {
        OPENSSL_free(pub_key_buf);
    }
    if (pri_key_buf)
    {
        OPENSSL_free(pri_key_buf);
    }
    
    
    return true;
}


static void *KDF_MD5(const void *in, size_t inlen, void *out, size_t *outlen)
{
    MD5_CTX ctx;
    MD5_Init(&ctx);
    MD5_Update(&ctx, in, inlen);
    MD5_Final((unsigned char*)out, &ctx);
    
    *outlen = MD5_DIGEST_LENGTH;
    
    return out;
}

static bool DoEcdh(int nid, unsigned char * szServerPubKey, int nLenServerPub, unsigned char * szLocalPriKey, int nLenLocalPri, unsigned char * szShareKey, int *pLenShareKey)
{
    const unsigned char *public_material = (const unsigned char *)szServerPubKey;
    const unsigned char *private_material = (const unsigned char *)szLocalPriKey;
    
    EC_KEY *pub_ec_key = EC_KEY_new_by_curve_name(nid);
    if (!pub_ec_key)    return false;
    pub_ec_key = o2i_ECPublicKey(&pub_ec_key, &public_material, nLenServerPub);
    if (!pub_ec_key)    return false;
    
    EC_KEY *pri_ec_key = EC_KEY_new_by_curve_name(nid);
    if (!pri_ec_key)    return false;
    pri_ec_key = d2i_ECPrivateKey(&pri_ec_key, &private_material, nLenLocalPri);
    if (!pri_ec_key) return false;
    
    if (MD5_DIGEST_LENGTH != ECDH_compute_key((void *)szShareKey, MD5_DIGEST_LENGTH, EC_KEY_get0_public_key(pub_ec_key), pri_ec_key, KDF_MD5))
    {
        EC_KEY_free(pub_ec_key);
        EC_KEY_free(pri_ec_key);
        
        return false;
    }
    
    *pLenShareKey = MD5_DIGEST_LENGTH;
    
    if (pub_ec_key)
    {
        EC_KEY_free(pub_ec_key);
        pub_ec_key = NULL;
    }
    
    if (pri_ec_key)
    {
        EC_KEY_free(pri_ec_key);
        pri_ec_key = NULL;
    }
    
    return true;
}

@implementation ECDH

+ (BOOL)GenEcdh:(NSData **)pPriKeyData pubKeyData:(NSData **)pPubKeyData {
    int nid = 713;
    
    unsigned char priKey[2048];
    unsigned char pubKey[2048];
    
    int priLen = 0;
    int pubLen = 0;
    
    BOOL ret = GenEcdh(nid, priKey, &priLen, pubKey, &pubLen);
    if (ret) {
        *pPriKeyData = [[NSData alloc] initWithBytes:priKey length:priLen];
        *pPubKeyData = [[NSData alloc] initWithBytes:pubKey length:pubLen];
        return YES;
    }
    
    return NO;
}


+ (bool)DoEcdh:(int)nid
szServerPubKey:(unsigned char *)szServerPubKey
 nLenServerPub:(int)nLenServerPub
 szLocalPriKey:(unsigned char *)szLocalPriKey
  nLenLocalPri:(int)nLenLocalPri
    szShareKey:(unsigned char *)szShareKey
  pLenShareKey:(int *)pLenShareKey
{
    const unsigned char *public_material = (const unsigned char *)szServerPubKey;
    const unsigned char *private_material = (const unsigned char *)szLocalPriKey;
    
    EC_KEY *pub_ec_key = EC_KEY_new_by_curve_name(nid);
    if (!pub_ec_key)    return false;
    pub_ec_key = o2i_ECPublicKey(&pub_ec_key, &public_material, nLenServerPub);
    if (!pub_ec_key)    return false;
    
    EC_KEY *pri_ec_key = EC_KEY_new_by_curve_name(nid);
    if (!pri_ec_key)    return false;
    pri_ec_key = d2i_ECPrivateKey(&pri_ec_key, &private_material, nLenLocalPri);
    if (!pri_ec_key) return false;
    
    if (MD5_DIGEST_LENGTH != ECDH_compute_key((void *)szShareKey, MD5_DIGEST_LENGTH, EC_KEY_get0_public_key(pub_ec_key), pri_ec_key, KDF_MD5))
    {
        EC_KEY_free(pub_ec_key);
        EC_KEY_free(pri_ec_key);
        
        return false;
    }
    
    *pLenShareKey = MD5_DIGEST_LENGTH;
    
    if (pub_ec_key)
    {
        EC_KEY_free(pub_ec_key);
        pub_ec_key = NULL;
    }
    
    if (pri_ec_key)
    {
        EC_KEY_free(pri_ec_key);
        pri_ec_key = NULL;
    }
    
    return true;
}

@end
