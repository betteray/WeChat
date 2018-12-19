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
#include <openssl/sha.h>

static bool GenEcdh(int nid, unsigned char *szPriKey, int *pLenPri, unsigned char *szPubKey, int *pLenPub);
static bool DoEcdh(int nid, unsigned char *szServerPubKey, int nLenServerPub, unsigned char *szLocalPriKey, int nLenLocalPri, unsigned char *szShareKey, int *pLenShareKey);

#define MD5_DIGEST_LENGTH 16
#define SHA256_DIGEST_LENGTH 32

static bool GenEcdh(int nid, unsigned char *szPriKey, int *pLenPri, unsigned char *szPubKey, int *pLenPub)
{
    if (!szPriKey || !pLenPri || !szPubKey || !pLenPub)
        return false;

    EC_KEY *ec_key = EC_KEY_new_by_curve_name(nid);
    if (!ec_key)
        return false;

    EC_KEY_set_asn1_flag(ec_key, 1);

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
    MD5_Final((unsigned char *) out, &ctx);

    *outlen = MD5_DIGEST_LENGTH;

    return out;
}

static void *KDF_SHA256(const void *in, size_t in_len, void *out, size_t *out_len)
{
    if ((!out_len) || (!in) || (!in_len) || *out_len < SHA256_DIGEST_LENGTH)
        return NULL;
    else
        *out_len = SHA256_DIGEST_LENGTH;

    return SHA256((const unsigned char *) in, in_len, (unsigned char *) out);
}

static bool DoEcdh(int nid, unsigned char *szServerPubKey, int nLenServerPub, unsigned char *szLocalPriKey, int nLenLocalPri, unsigned char *szShareKey, int *pLenShareKey)
{
    const unsigned char *public_material = (const unsigned char *) szServerPubKey;
    const unsigned char *private_material = (const unsigned char *) szLocalPriKey;

    EC_KEY *pub_ec_key = EC_KEY_new_by_curve_name(nid);
    if (!pub_ec_key)
        return false;
    pub_ec_key = o2i_ECPublicKey(&pub_ec_key, &public_material, nLenServerPub);
    if (!pub_ec_key)
        return false;

    EC_KEY *pri_ec_key = EC_KEY_new_by_curve_name(nid);
    if (!pri_ec_key)
        return false;
    pri_ec_key = d2i_ECPrivateKey(&pri_ec_key, &private_material, nLenLocalPri);
    if (!pri_ec_key)
        return false;

    if (MD5_DIGEST_LENGTH != ECDH_compute_key((void *) szShareKey, MD5_DIGEST_LENGTH, EC_KEY_get0_public_key(pub_ec_key), pri_ec_key, KDF_MD5))
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

+ (BOOL)GenEcdhWithNid:(int)nid priKey:(NSData **)pPriKeyData pubKeyData:(NSData **)pPubKeyData
{

    unsigned char priKey[2048];
    unsigned char pubKey[2048];

    int priLen = 0;
    int pubLen = 0;

    BOOL ret = GenEcdh(nid, priKey, &priLen, pubKey, &pubLen);
    if (ret)
    {
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
    const unsigned char *public_material = (const unsigned char *) szServerPubKey;
    const unsigned char *private_material = (const unsigned char *) szLocalPriKey;

    EC_KEY *pub_ec_key = EC_KEY_new_by_curve_name(nid);
    if (!pub_ec_key)
        return false;
    pub_ec_key = o2i_ECPublicKey(&pub_ec_key, &public_material, nLenServerPub);
    if (!pub_ec_key)
        return false;

    EC_KEY *pri_ec_key = EC_KEY_new_by_curve_name(nid);
    if (!pri_ec_key)
        return false;
    pri_ec_key = d2i_ECPrivateKey(&pri_ec_key, &private_material, nLenLocalPri);
    if (!pri_ec_key)
        return false;

    if (MD5_DIGEST_LENGTH != ECDH_compute_key((void *) szShareKey, MD5_DIGEST_LENGTH, EC_KEY_get0_public_key(pub_ec_key), pri_ec_key, KDF_MD5))
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

+ (NSData *)DoEcdh2:(int)nid
       ServerPubKey:(NSData *)serverPubKey
        LocalPriKey:(NSData *)localPriKey
{
    unsigned char buf[32] = {0};
    int sharedKeyLen = 0;

    const unsigned char *public_material = (const unsigned char *) [serverPubKey bytes];
    const unsigned char *private_material = (const unsigned char *) [localPriKey bytes];

    EC_KEY *pub_ec_key = EC_KEY_new_by_curve_name(nid);
    if (!pub_ec_key)
        return nil;
    pub_ec_key = o2i_ECPublicKey(&pub_ec_key, &public_material, [serverPubKey length]);
    if (!pub_ec_key)
        return nil;

    EC_KEY *pri_ec_key = EC_KEY_new_by_curve_name(nid);
    if (!pri_ec_key)
        return nil;
    pri_ec_key = d2i_ECPrivateKey(&pri_ec_key, &private_material, [localPriKey length]);
    if (!pri_ec_key)
        return nil;

    if (SHA256_DIGEST_LENGTH != ECDH_compute_key((void *) buf, SHA256_DIGEST_LENGTH, EC_KEY_get0_public_key(pub_ec_key), pri_ec_key, KDF_SHA256))
    {
        EC_KEY_free(pub_ec_key);
        EC_KEY_free(pri_ec_key);

        return nil;
    }

    sharedKeyLen = SHA256_DIGEST_LENGTH;

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

    return [NSData dataWithBytes:buf length:sharedKeyLen];
}

@end
