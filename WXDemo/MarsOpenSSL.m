//
//  MarsOpenSSL.m
//  WXDemo
//
//  Created by ray on 2018/9/17.
//  Copyright © 2018 ray. All rights reserved.
//

#import "MarsOpenSSL.h"
#include <openssl/rsa.h>
#include <openssl/rsa.h>
#include <openssl/pem.h>

enum
{
    CRYPT_OK = 0,
    CRYPT_ERR_INVALID_KEY_N = 1,
    CRYPT_ERR_INVALID_KEY_E = 2,
    CRYPT_ERR_ENCRYPT_WITH_RSA_PUBKEY = 3,
    CRYPT_ERR_DECRYPT_WITH_RSA_PRIVKEY = 4,
    CRYPT_ERR_NO_MEMORY = 5,
    CRYPT_ERR_ENCRYPT_WITH_DES_KEY = 6,
    CRYPT_ERR_DECRYPT_WITH_DES_KEY = 7,
    CRYPT_ERR_INVALID_PARAM = 8,
    CRYPT_ERR_LOAD_RSA_PRIVATE_KEY = 9,
};

static int rsa_public_encrypt(const unsigned char* pInput, unsigned int uiInputLen
                       , unsigned char** ppOutput, unsigned int* uiOutputLen
                       , const char* pPublicKeyN, const char* pPublicKeyE)
{
    RSA* encrypt_rsa;
    int finalLen = 0;
    int i = 0;
    int ret;
    int rsa_len;
    if(pInput == NULL || uiOutputLen == NULL
       || pPublicKeyN == NULL || pPublicKeyE == NULL
       || uiInputLen == 0 || ppOutput == NULL)
        return CRYPT_ERR_INVALID_PARAM;
    
    // assume the byte strings are sent over the network
    encrypt_rsa = RSA_new();
    if(encrypt_rsa == NULL) {
        return CRYPT_ERR_NO_MEMORY;
    }
    
    ret = CRYPT_OK;
    if(BN_hex2bn(&encrypt_rsa->n, pPublicKeyN) == 0)
    {
        ret = CRYPT_ERR_INVALID_KEY_N;
        goto END;
    }
    if(BN_hex2bn(&encrypt_rsa->e, pPublicKeyE) == 0)
    {
        ret = CRYPT_ERR_INVALID_KEY_E;
        goto END;
    }
    
    // alloc encrypt_string
    
    rsa_len = RSA_size(encrypt_rsa);
    if((int)uiInputLen >= rsa_len - 12) {
        int blockCnt = (uiInputLen / (rsa_len - 12)) + (((uiInputLen % (rsa_len - 12)) == 0) ? 0 : 1);
        finalLen = blockCnt * rsa_len;
        *ppOutput = (unsigned char*)calloc(finalLen, sizeof(unsigned char));
        if(*ppOutput == NULL) {
            ret = CRYPT_ERR_NO_MEMORY;
            goto END;
        }
        
        
        for(; i < blockCnt; ++i) {
            int blockSize = rsa_len - 12;
            if(i == blockCnt - 1) blockSize = uiInputLen - i * blockSize;
            
            if(RSA_public_encrypt(blockSize, (pInput + i * (rsa_len - 12)), (*ppOutput + i * rsa_len), encrypt_rsa, RSA_PKCS1_PADDING) < 0) {
                ret = CRYPT_ERR_ENCRYPT_WITH_RSA_PUBKEY;
                goto END;
            }
        }
        *uiOutputLen = finalLen;
    } else {
        *ppOutput = (unsigned char*)calloc(rsa_len, sizeof(unsigned char));
        if (*ppOutput == NULL) {
            ret = CRYPT_ERR_NO_MEMORY;
            goto END;
        }
        
        // encrypt (return the size of the encrypted data)
        // note that if RSA_PKCS1_OAEP_PADDING is used,
        // flen must be < RSA_size - 41
        if(RSA_public_encrypt(uiInputLen,
                              pInput, *ppOutput, encrypt_rsa, RSA_PKCS1_PADDING) < 0) {
            ret = CRYPT_ERR_ENCRYPT_WITH_RSA_PUBKEY;
            goto END;
        }
        *uiOutputLen = rsa_len;
    }
    
END:
    if(CRYPT_OK != ret) {
        if(*ppOutput != NULL) {
            free(*ppOutput);
            ppOutput = NULL;
        }
    }
    RSA_free(encrypt_rsa);
    return ret;
}

static int rsa_public_decrypt(const unsigned char* pInput, unsigned int uiInputLen
                       , unsigned char** ppOutput, unsigned int* uiOutputLen
                       , const char* pPublicKeyN, const char* pPublicKeyE)
{
    RSA* decrypt_rsa;
    int i = 0;
    int ret = 0;
    int ret_size = 0;
    int iKeySize = 0;
    int iPlainSize = 0;
    unsigned char *pcPlainBuf = NULL;
    if(pInput == NULL || uiOutputLen == NULL
       || pPublicKeyN == NULL || pPublicKeyE == NULL
       || uiInputLen == 0 || ppOutput == NULL)
        return CRYPT_ERR_INVALID_PARAM;
    
    // assume the byte strings are sent over the network
    decrypt_rsa = RSA_new();
    if(decrypt_rsa == NULL) {
        return CRYPT_ERR_NO_MEMORY;
    }
    
    ret = CRYPT_OK;
    if(BN_hex2bn(&decrypt_rsa->n, pPublicKeyN) == 0)
    {
        ret = CRYPT_ERR_INVALID_KEY_N;
        goto END;
    }
    if(BN_hex2bn(&decrypt_rsa->e, pPublicKeyE) == 0)
    {
        ret = CRYPT_ERR_INVALID_KEY_E;
        goto END;
    }
    
    // alloc encrypt_string
    iKeySize = RSA_size(decrypt_rsa);
    
    // decrypt
    pcPlainBuf = (unsigned char *)OPENSSL_malloc( uiInputLen );
    
    if (uiInputLen > (unsigned int)iKeySize)
    {
        int iBlockCnt = uiInputLen / iKeySize;
        int iPos = 0;
        
        for (i = 0; i < iBlockCnt; ++i)
        {
            ret_size = RSA_public_decrypt( iKeySize, pInput + i * iKeySize, pcPlainBuf + iPos, decrypt_rsa, RSA_PKCS1_PADDING );
            if (ret_size < 1)
            {
                ret =  CRYPT_ERR_DECRYPT_WITH_RSA_PRIVKEY;
                goto END;
            }
            iPos += ret_size;
        }
        
        iPlainSize = iPos;
    }
    else
    {
        ret_size = RSA_public_decrypt( iKeySize, pInput, pcPlainBuf, decrypt_rsa, RSA_PKCS1_PADDING);
        
        if (ret_size < 1)
        {
            ret = CRYPT_ERR_DECRYPT_WITH_RSA_PRIVKEY;
            goto END;
        }
        
        iPlainSize = ret_size;
    }
    
END:
    RSA_free(decrypt_rsa);
    
    if(CRYPT_OK != ret)
    {
        OPENSSL_free(pcPlainBuf);
    }
    else
    {
        *ppOutput = pcPlainBuf;
        *uiOutputLen = iPlainSize;
    }
    
    return ret;
}

/////
static int rsa_private_decrypt(unsigned char** _out, unsigned int* _outlen,  const unsigned char* _in, unsigned int _inlen, RSA* _key)
{
    if(!_in || !_key || _inlen < 8 || _inlen % 8 != 0) { return __LINE__; }
    
    int ret = 0;
    
    // load priv key
    RSA *Rsa = _key;
    if (!Rsa) { return __LINE__; }
    unsigned int iKeySize = (unsigned int)RSA_size(Rsa);
    
    // decrypt
    unsigned char *pcPlainBuf = (unsigned char*)calloc(_inlen, sizeof(unsigned char));
    if (!pcPlainBuf) { return __LINE__; }
    int iPlainSize = 0;
    if (_inlen > (unsigned int)iKeySize)
    {
        unsigned int iBlockCnt = _inlen / iKeySize;
        
        unsigned int iPos = 0;
        unsigned int i = 0;
        for (i = 0; i < iBlockCnt; ++i)
        {
            unsigned int iBlockSize = 0;
            ret = RSA_private_decrypt( iKeySize, (const unsigned char*)_in + i * iKeySize, pcPlainBuf + iPos, Rsa, RSA_PKCS1_PADDING );
            if (ret < 1)
            {
                free(pcPlainBuf);
                return __LINE__;
                
            }
            iPos += ret;
        }
        
        iPlainSize = iPos;
    }
    else
    {
        ret = RSA_private_decrypt( iKeySize,  (const unsigned char*)_in, pcPlainBuf, Rsa, RSA_PKCS1_PADDING);
        
        if (ret < 1)
        {
            free(pcPlainBuf);
            return __LINE__;
        }
        
        iPlainSize = ret;
    }
    
    *_out =  pcPlainBuf;
    *_outlen = (unsigned int)iPlainSize;
    
    return 0;
}


/////////

typedef enum {
    kBufNotEnough,
    kOK,
    
} GenRsaKeyResult;

typedef enum{
    kKey512Bits = 512,
    kKey1024Bits= 1024,
    kKey2048Bits= 2048,
}RSAKeyBits;

static GenRsaKeyResult generate_rsa_key_pair(char* _pem_public_key_buf, const size_t _public_key_buf_len,
                                      char* _pem_private_key_buf, const size_t _private_key_buf_len, RSAKeyBits _key_bits) {
    
    GenRsaKeyResult ret = kOK;
    /* 产生RSA密钥 */
    RSA *rsa = RSA_generate_key(_key_bits, RSA_F4, NULL, NULL);
    
    /* 提取私钥 */
    BIO* bio_private = BIO_new(BIO_s_mem());
    PEM_write_bio_RSAPrivateKey(bio_private, rsa, NULL, NULL, 0, NULL, NULL);
    int private_key_len = BIO_pending(bio_private);
    char* pem_private_key = (char*)calloc(private_key_len+1, 1);
    BIO_read(bio_private, pem_private_key, private_key_len);
    //xdebug2(TSF"pem_private_key=%_, pem key len=%_",pem_private_key, strlen(pem_private_key));
    
    /* 提取公钥 */
    unsigned char *n_b = (unsigned char *) calloc(RSA_size(rsa),
                                                  sizeof(unsigned char));
    unsigned char *e_b = (unsigned char *) calloc(RSA_size(rsa),
                                                  sizeof(unsigned char));
    
    int n_size = BN_bn2bin(rsa->n, n_b);
    int b_size = BN_bn2bin(rsa->e, e_b);
    
    RSA *pubrsa = RSA_new();
    pubrsa->n = BN_bin2bn(n_b, n_size, NULL);
    pubrsa->e = BN_bin2bn(e_b, b_size, NULL);
    
    
    BIO* bio_public = BIO_new(BIO_s_mem());
    PEM_write_bio_RSA_PUBKEY(bio_public, pubrsa);
    int public_key_len = BIO_pending(bio_public);
    char *pem_public_key = (char*)calloc(public_key_len+1, 1);
    BIO_read(bio_public, pem_public_key, public_key_len);
    
    if (_public_key_buf_len<strlen(pem_public_key)
        || _private_key_buf_len<strlen((const char*)&pem_private_key)) {
        ret = kBufNotEnough;
        goto err;
    }
    memcpy(_pem_private_key_buf, pem_private_key, strlen(pem_private_key));
    memcpy(_pem_public_key_buf, pem_public_key, strlen(pem_public_key));
    
err:
    if (n_b!=NULL) {
        free(n_b);
    }
    if (e_b!=NULL) {
        free(e_b);
    }
    if (pem_public_key!=NULL) {
        free(pem_public_key);
    }
    if (pem_private_key!=NULL) {
        free(pem_private_key);
    }
    BIO_free(bio_private);
    BIO_free(bio_public);
    RSA_free(rsa);
    RSA_free(pubrsa);
    return ret;
    
}

static GenRsaKeyResult generate_rsa_key_pair_2048(char* _pem_public_key_buf, const size_t _public_key_buf_len,
                                           char* _pem_private_key_buf, const size_t _private_key_buf_len) {
    return generate_rsa_key_pair(_pem_public_key_buf, _public_key_buf_len, _pem_private_key_buf, _private_key_buf_len, kKey2048Bits);
}

static GenRsaKeyResult generate_rsa_key_pair_1024(char* _pem_public_key_buf, const size_t _public_key_buf_len,
                                                  char* _pem_private_key_buf, const size_t _private_key_buf_len) {
    return generate_rsa_key_pair(_pem_public_key_buf, _public_key_buf_len, _pem_private_key_buf, _private_key_buf_len, kKey1024Bits);
}

@implementation MarsOpenSSL

+ (NSData *)RSA_PUB_EncryptData:(NSData *)data modulus:(NSString *)modules exponent:(NSString *)exponent
{
    unsigned char * output;
    unsigned int outputLen;
    int ret = rsa_public_encrypt([data bytes], (unsigned int)[data length], &output, &outputLen, [modules UTF8String], [exponent UTF8String]);
    if (ret == CRYPT_OK) {
        return [NSData dataWithBytes:output length:outputLen];
    }
    
    return nil;
}

+ (BOOL)genRSAKeyPairPubKey:(NSString **)rsaPubKey priKey:(NSString **)rsaPriKey
{
    char pubKeyBuf[2048] = {0};
    char priKeyBuf[2028] = {0};
    GenRsaKeyResult ret = generate_rsa_key_pair_1024(pubKeyBuf, 2048, priKeyBuf, 2048);
    if (ret == kOK) {
        *rsaPubKey = [NSString stringWithCString:pubKeyBuf encoding:NSUTF8StringEncoding];
        *rsaPriKey = [NSString stringWithCString:priKeyBuf encoding:NSUTF8StringEncoding];
        return YES;
    }
    
    return NO;
}

@end
