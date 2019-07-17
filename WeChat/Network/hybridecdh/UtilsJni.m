//
//  UtilsJni.m
//  WeChat
//
//  Created by ysh on 2019/7/1.
//  Copyright © 2019 ray. All rights reserved.
//

#import "UtilsJni.h"
#import "WCECDH.h"
#import "WC_SHA256.h"
#import "NSData+GenRandomData.h"
#import "NSData+Compression.h"
#import "WC_AesGcm128.h"
#import "WC_HKDF.h"
#import "Varint128.h"
#import "UtileJni.pbobjc.h"

#define LOCAL_PRIKEY @"0495BC6E5C1331AD172D0F35B1792C3CE63F91572ABD2DD6DF6DAC2D70195C3F6627CCA60307305D8495A8C38B4416C75021E823B6C97DFFE79C14CB7C3AF8A586"

@interface UtilsJni ()

@property(nonatomic, strong) NSData *prikey;
@property(nonatomic, strong) NSData *pubkey;

@property(nonatomic, strong) NSData *receivedHashData;
@property(nonatomic, strong) NSData *plainData;
@end

@implementation UtilsJni

- (instancetype)init {
    self  = [super init];
    if (self) {
        
        NSData *prikey = nil;
        NSData *pubkey = nil;
        
        if ([WCECDH GenEcdhWithNid:415 priKey:&prikey pubKeyData:&pubkey]) {
//            LogVerbose(@"HybridEcdhEncrypt prikey: %@, pubkey: %@", _prikey, _pubkey);
            self.prikey = prikey;
            self.pubkey = pubkey;
            //    _pubkey = [NSData dataWithHexString:@"0476CA71203D58826DFAD77D575CB19223E3DA62346D6B78072BD7A0EC8E669F610A6CDC22CDF2BF166924A84D976BA51011B5EF7BB24231EC5D20DDF8BEF07F9A"];
            //    _prikey = [NSData dataWithHexString:[@"30770201 01042035 422522D2 4F212272 ACFEBC00 CDE96C93 3F873418 7ECC5A96 1CF47D89 71C519A0 0A06082A 8648CE3D 030107A1 44034200 0476CA71 203D5882 6DFAD77D 575CB192 23E3DA62 346D6B78 072BD7A0 EC8E669F 610A6CDC 22CDF2BF 166924A8 4D976BA5 1011B5EF 7BB24231 EC5D20DD F8BEF07F 9A" stringByReplacingOccurrencesOfString:@" " withString:@""]];
        }
    }
    
    return self;
}


- (NSData *)HybridEcdhEncrypt:(NSData *)plainData {
    _plainData = plainData;
    NSData *localPriKey = [NSData dataWithHexString:LOCAL_PRIKEY];
    NSData *ecdhResult = [WCECDH DoEcdh2:415 ServerPubKey:localPriKey LocalPriKey:_prikey];
    
//    LogVerbose(@"ecdhResult: %@", ecdhResult);
    
    NSData *hashData = [NSData dataWithHexString:@"31"]; //1
    hashData = [hashData addDataAtTail:[NSData dataWithHexString:@"343135"]]; //415
    hashData = [hashData addDataAtTail:_pubkey];
    
    NSData *hashDataResult = [WC_SHA256 sha256:hashData];
    
//    LogVerbose(@"hashDataResult: %@", hashDataResult);

    NSData *ikmData = [NSData GenRandomDataWithSize:32]; //random
//    ikmData = [NSData dataWithHexString:@"D2CA9AD2F718E30EFA580984C2B3BFAD538A2986B424499897C44C00E99426AA"];
    NSData *compressedData = [ikmData dataByDeflating];
    
//    LogVerbose(@"compressedData: %@", compressedData);

    NSData *ivData = [NSData dataWithHexString:[@"63612D5D FA042DD1 877F70B9" stringByReplacingOccurrencesOfString:@" " withString:@""]];  // ？
    NSData *encryptedData = [WC_AesGcm128 aes192gcmEncrypt:compressedData aad:hashDataResult key:[ecdhResult subdataWithRange:NSMakeRange(0, 24)] ivec:ivData];

//    LogVerbose(@"encryptedData: %@", encryptedData);

    NSData *saltData = [NSData dataWithHexString:[@"73656375 72697479 2068646B 66206578 70616E64" stringByReplacingOccurrencesOfString:@" " withString:@""]]; //固定字符串: security hdkf expand
    unsigned char okm[56];
    [WC_HKDF HKDF_salt:(unsigned char *)[saltData bytes] salt_len:[saltData length] ikm:(const unsigned char *)[ikmData bytes] ikm_len:[ikmData length] info:(const unsigned char *)[hashDataResult bytes] info_len:[hashDataResult length] okm:okm okm_len:56];
    NSData *hkdfData = [NSData dataWithBytes:okm length:56];
    
    _receivedHashData = [hkdfData subdataWithRange:NSMakeRange(24, [hkdfData length] - 24)];
    
//    LogVerbose(@"WC_HKDF result: %@", hkdfData);
    
    
    
    // ============= part 2, protobuf 加密 =============
    
    NSData *hashData2 = [NSData dataWithHexString:@"31"]; //1
    hashData2 = [hashData2 addDataAtTail:[NSData dataWithHexString:@"343135"]]; //415
    hashData2 = [hashData2 addDataAtTail:_pubkey];
    hashData2 = [hashData2 addDataAtTail:encryptedData];

    NSData *hashDataResult2 = [WC_SHA256 sha256:hashData2];
    
//    plainData = [NSData dataWithHexString:@"0AAE010A1408101210E41CB3DF63FB163DCF77E18C433556EF124208C905123D0839123904ED695D2E3E0D67091C88D9BC472F6BA5B0F45614124A53D94C654827E2F41096BD833291F3F063FD8B88BCC706B6E464AF9A9CADA5B1EBDA1A0E2B38363135353235323535323532222063363363656462636139343862306562383861333864356333343239393866302A20633633636564626361393438623065623838613338643563333432393938663012C30C0A2A0A0010001A104162303965363630653865343863320020B48680B8022A0A616E64726F69642D3237300112280A0408001200120C0A0012001A002204080012001A040A0012002204080012002A040800120030001A0F383637393832303230383937383430229B083C736F6674747970653E3C6C63746D6F633E303C2F6C63746D6F633E3C6C6576656C3E313C2F6C6576656C3E3C6B313E30203C2F6B313E3C6B323E616E676C65722D30332E38373C2F6B323E3C6B333E382E312E303C2F6B333E3C6B343E3836373938323032303839373834303C2F6B343E3C6B353E3C2F6B353E3C6B363E3C2F6B363E3C6B373E663465646364346364323331666632643C2F6B373E3C6B383E435648374E31354231343030323938313C2F6B383E3C6B393E4E657875732036503C2F6B393E3C6B31303E383C2F6B31303E3C6B31313E5175616C636F6D6D20546563686E6F6C6F676965732C20496E63204D534D383939343C2F6B31313E3C6B31323E3C2F6B31323E3C6B31333E3C2F6B31333E3C6B31343E30323A30303A30303A30303A30303A30303C2F6B31343E3C6B31353E30323A30303A30303A30303A30303A30303C2F6B31353E3C6B31363E68616C66207468756D6220666173746D756C74207666702065647370206E656F6E20766670763320746C73207666707634206964697661206964697674206576747374726D2061657320706D756C6C207368613120736861322063726333323C2F6B31363E3C6B31383E31386338363766303731376161363762326162373334373530356261303765643C2F6B31383E3C6B32313E4F70656E5772743C2F6B32313E3C6B32323E3C2F6B32323E3C6B32343E30323A30303A30303A30303A30303A30303C2F6B32343E3C6B32363E303C2F6B32363E3C6B33303E2671756F743B4F70656E5772742671756F743B3C2F6B33303E3C6B33333E636F6D2E74656E63656E742E6D6D3C2F6B33333E3C6B33343E676F6F676C652F616E676C65722F616E676C65723A382E312E302F4F504D372E3138313230352E3030312F353038303138303A757365722F72656C656173652D6B6579733C2F6B33343E3C6B33353E616E676C65723C2F6B33353E3C6B33363E616E676C65722D30332E37393C2F6B33363E3C6B33373E676F6F676C653C2F6B33373E3C6B33383E616E676C65723C2F6B33383E3C6B33393E616E676C65723C2F6B33393E3C6B34303E616E676C65723C2F6B34303E3C6B34313E303C2F6B34313E3C6B34323E4875617765693C2F6B34323E3C6B34333E6E756C6C3C2F6B34333E3C6B34343E303C2F6B34343E3C6B34353E3C2F6B34353E3C6B34363E3C2F6B34363E3C6B34373E776966693C2F6B34373E3C6B34383E3836373938323032303839373834303C2F6B34383E3C6B34393E2F646174612F757365722F302F636F6D2E74656E63656E742E6D6D2F3C2F6B34393E3C6B35323E303C2F6B35323E3C6B35333E303C2F6B35333E3C6B35373E313430303C2F6B35373E3C6B35383E3C2F6B35383E3C6B35393E333C2F6B35393E3C6B36303E3C2F6B36303E3C6B36313E747275653C2F6B36313E3C2F736F6674747970653E2800321E416230396536363065386534386332655F313536313639323430373533373A203138633836376630373137616136376232616237333437353035626130376564420F4875617765692D4E657875732036504AA4023C646576696365696E666F3E3C4D414E554641435455524552206E616D653D22487561776569223E3C4D4F44454C206E616D653D224E65787573203650223E3C56455253494F4E5F52454C45415345206E616D653D22382E312E30223E3C56455253494F4E5F494E4352454D454E54414C206E616D653D2263623438393866313830223E3C444953504C4159206E616D653D226C696E656167655F616E676C65722D75736572646562756720382E312E30204F504D372E3138313230352E3030312063623438393866313830223E3C2F444953504C41593E3C2F56455253494F4E5F494E4352454D454E54414C3E3C2F56455253494F4E5F52454C454153453E3C2F4D4F44454C3E3C2F4D414E5546414354555245523E3C2F646576696365696E666F3E52057A685F434E5A04382E3030680070007A06676F6F676C658201134E6578757320365061726D656162692D7637618A010A616E64726F69642D3237920100B00101"];
    
    NSData *compressedData2 = [plainData dataByDeflating];

    NSData *ivData2 = [NSData dataWithHexString:[@"57BC4BC5 C31C7C67 5C3F794B" stringByReplacingOccurrencesOfString:@" " withString:@""]]; // ？
    NSData *aad = [hkdfData subdataWithRange:NSMakeRange(0, 24)];
    NSData *encryptedData2 = [WC_AesGcm128 aes192gcmEncrypt:compressedData2 aad:hashDataResult2 key:aad ivec:ivData2];

//    LogVerbose(@"encryptedData2: %@", [encryptedData2 hexDump]);
    
    UtileJniSendPackage *package = [UtileJniSendPackage new];
    package.tag1 = 1;
    UtileJniECDHKey *ecdhKey = [UtileJniECDHKey new];
    ecdhKey.nid = 415;
    ecdhKey.key = _pubkey;
    package.ecdhkey = ecdhKey;
    package.tag4 = [NSData data];
    package.data1 = encryptedData;
    package.data2 = encryptedData2;
    
//    LogVerbose(@"%@", package);

    return [package data];
}

- (NSData *)HybridEcdhDecrypt:(NSData *)encryptedData {
    
//    encryptedData = [NSData dataWithHexString:@"0A46089F031241049191E66A644598F7CF60A3A0EA98F8278D9D741B9FA8A9959FBB1AEFCD0CCA67646210C82AE8BC0C6F050C873C6B2E9CD8B4E5636DD8DFA08A2F47E1A2E2070310011ADA0492C5F510894BFDFBBCD29AE91164E390C8936E452DCDA40F88B86ABDAE5F5807D1480D96424960B37A95A2BB63845AFF22FE8D0DB076F07BB857E914B9FF599E23EB18FB70346E3BB46A8634F174218A512843A7BC5D5BF4EABEC13F9D4777182F14F51EF3D70AD4FB73C02BA6B3EF7B2B832005AE84225F88343C9630B7BD1EB83A5FD3B001CFA00C5FA37C979544103D4B3931B9A8B6B0BBA21C901F67203494240A44A82159F549DB4D1281BB23436BF02D5360F0C5DBCD3B5D1C0FF8ED7CD314DA8841703D45900C51C0BF332DB25ED5E361C56DD24299D827E6A359BAE1A94330DDEA222897F371E66A8B2F203B551CE0B92AC370EAF9A0C85A7AC9D66C9858C8333A22DF25D5004ABB33A86B2CBEF3D4F58AAA067BBD8F235FCF267ECD83E5F08AFC9442567DA33BAEA7838718AF5919545B46DBC02E4233DC2AF519C6ADA300D0FFC4DED52871B438F9FC0BECF24D49C3591E95DB2C3539ED7793DD2CCD4F48A36776EB111BC3DFBAE0FF81F0B6323BCE32B005F4B30010CA327AE72620ED68B8650D8715A6CA4BA586365071255DF15EEA5700D5182C3B48D34195101BA350458D4F753B3E4C7B044B9E6B0BF9CCB45F2C486D688C63D27DDCE5982DB6D21C436968C11B455CFCA0F6568312D41902BB727723A084F89DCF19D4CA2148EA280A4431D13D43433665D0E8D4EA6461318600091C8F7DB20DAB3302CB48F69FE0C6AB5C55B9B8038E92D53D1259EA086D52AAF594467E4402B5A499D04BF34CE81250A92C6521F296D6BCF18EF837CF32AC59A9765390638D0A975C87E7969A911B36702CF02AA9DAF9DE3348C993B5F79DC7B2B599D6F42247304502206944A131B0D867533220128E21612E1D1DBD31D2C3D9167923F5F564217EC4D202210098EAAD95050C74CCAD6213E34CD8FB6C5BCF38D921CD2CEB11CACC7710CBF024"];
    
    UtileJniReceivePackage *package = [[UtileJniReceivePackage alloc] initWithData:encryptedData error:nil];
    
//    LogVerbose(@"%@", package);
    
    /////
    // ecdh
//    NSData *prikey = [NSData dataWithHexString:@"049191E66A644598F7CF60A3A0EA98F8278D9D741B9FA8A9959FBB1AEFCD0CCA67646210C82AE8BC0C6F050C873C6B2E9CD8B4E5636DD8DFA08A2F47E1A2E20703"];
//    NSData *pubkey = [NSData dataWithHexString:@"307702010104206BA4EDF6A9A0352110471F8A121819A40D8FE8729FC2E3F036E9871A625C077AA00A06082A8648CE3D030107A144034200047AB24C6402691DBC858628D7627FE85847EAB293EDBCE7B44541478F8D87CF34ACC51530BF402C0B987BEDE880291507C916369E5E22BD5F809FCE89298F4D56"];
    
    NSData *ecdhResult = [WCECDH DoEcdh2:package.ecdhkey.nid ServerPubKey:package.ecdhkey.key LocalPriKey:_prikey];
//    NSData *ecdhResult = [WCECDH DoEcdh2:package.ecdhkey.nid ServerPubKey:prikey LocalPriKey:pubkey];

//    LogVerbose(@"ecdhResult: %@", ecdhResult);

    //////
    // hash256
    
//    NSData *hashData = [NSData dataWithHexString:@"3FEE84EA0EA6AAF2FF4EE7CB9D2AAF1EECA63C45951570ED331AB1D1BF4ACDA3"];
//    hashData = [hashData addDataAtTail:[NSData dataWithHexString:@"0AAE010A1408101210C976EC201154555866F4AC71613B9E77124208C905123D08391239043340E79050FFD7F5B426A2344D216590F7CBB9AF720A0F8EAD9650894B1D43507009600E7A5D938CB91EFEAD3BA50CBD1EFF66C8F84DCFC81A0E2B38363135353130383532313231222037333863386637613431653231616635353461636466313330383736353362352A20373338633866376134316532316166353534616364663133303837363533623512C30C0A2A0A0010001A104162303965363630653865343863320020B48680B8022A0A616E64726F69642D3237300112280A0408001200120C0A0012001A002204080012001A040A0012002204080012002A040800120030001A0F383637393832303230383937383430229B083C736F6674747970653E3C6C63746D6F633E303C2F6C63746D6F633E3C6C6576656C3E313C2F6C6576656C3E3C6B313E30203C2F6B313E3C6B323E616E676C65722D30332E38373C2F6B323E3C6B333E382E312E303C2F6B333E3C6B343E3836373938323032303839373834303C2F6B343E3C6B353E3C2F6B353E3C6B363E3C2F6B363E3C6B373E663465646364346364323331666632643C2F6B373E3C6B383E435648374E31354231343030323938313C2F6B383E3C6B393E4E657875732036503C2F6B393E3C6B31303E383C2F6B31303E3C6B31313E5175616C636F6D6D20546563686E6F6C6F676965732C20496E63204D534D383939343C2F6B31313E3C6B31323E3C2F6B31323E3C6B31333E3C2F6B31333E3C6B31343E30323A30303A30303A30303A30303A30303C2F6B31343E3C6B31353E30323A30303A30303A30303A30303A30303C2F6B31353E3C6B31363E68616C66207468756D6220666173746D756C74207666702065647370206E656F6E20766670763320746C73207666707634206964697661206964697674206576747374726D2061657320706D756C6C207368613120736861322063726333323C2F6B31363E3C6B31383E31386338363766303731376161363762326162373334373530356261303765643C2F6B31383E3C6B32313E4F70656E5772743C2F6B32313E3C6B32323E3C2F6B32323E3C6B32343E30323A30303A30303A30303A30303A30303C2F6B32343E3C6B32363E303C2F6B32363E3C6B33303E2671756F743B4F70656E5772742671756F743B3C2F6B33303E3C6B33333E636F6D2E74656E63656E742E6D6D3C2F6B33333E3C6B33343E676F6F676C652F616E676C65722F616E676C65723A382E312E302F4F504D372E3138313230352E3030312F353038303138303A757365722F72656C656173652D6B6579733C2F6B33343E3C6B33353E616E676C65723C2F6B33353E3C6B33363E616E676C65722D30332E37393C2F6B33363E3C6B33373E676F6F676C653C2F6B33373E3C6B33383E616E676C65723C2F6B33383E3C6B33393E616E676C65723C2F6B33393E3C6B34303E616E676C65723C2F6B34303E3C6B34313E303C2F6B34313E3C6B34323E4875617765693C2F6B34323E3C6B34333E6E756C6C3C2F6B34333E3C6B34343E303C2F6B34343E3C6B34353E3C2F6B34353E3C6B34363E3C2F6B34363E3C6B34373E776966693C2F6B34373E3C6B34383E3836373938323032303839373834303C2F6B34383E3C6B34393E2F646174612F757365722F302F636F6D2E74656E63656E742E6D6D2F3C2F6B34393E3C6B35323E303C2F6B35323E3C6B35333E303C2F6B35333E3C6B35373E313430303C2F6B35373E3C6B35383E3C2F6B35383E3C6B35393E333C2F6B35393E3C6B36303E3C2F6B36303E3C6B36313E747275653C2F6B36313E3C2F736F6674747970653E2800321E416230396536363065386534386332655F313536313938373434393233363A203138633836376630373137616136376232616237333437353035626130376564420F4875617765692D4E657875732036504AA4023C646576696365696E666F3E3C4D414E554641435455524552206E616D653D22487561776569223E3C4D4F44454C206E616D653D224E65787573203650223E3C56455253494F4E5F52454C45415345206E616D653D22382E312E30223E3C56455253494F4E5F494E4352454D454E54414C206E616D653D2263623438393866313830223E3C444953504C4159206E616D653D226C696E656167655F616E676C65722D75736572646562756720382E312E30204F504D372E3138313230352E3030312063623438393866313830223E3C2F444953504C41593E3C2F56455253494F4E5F494E4352454D454E54414C3E3C2F56455253494F4E5F52454C454153453E3C2F4D4F44454C3E3C2F4D414E5546414354555245523E3C2F646576696365696E666F3E52057A685F434E5A04382E3030680070007A06676F6F676C658201134E6578757320365061726D656162692D7637618A010A616E64726F69642D3237920100B00101"]];
//    hashData = [hashData addDataAtTail:[NSData dataWithHexString:@"343135"]];
//    hashData = [hashData addDataAtTail:[NSData dataWithHexString:@"049191E66A644598F7CF60A3A0EA98F8278D9D741B9FA8A9959FBB1AEFCD0CCA67646210C82AE8BC0C6F050C873C6B2E9CD8B4E5636DD8DFA08A2F47E1A2E20703"]];
//    hashData = [hashData addDataAtTail:[NSData dataWithHexString:@"31"]];
    
    _receivedHashData = [_receivedHashData addDataAtTail:_plainData];
    _receivedHashData = [_receivedHashData addDataAtTail:[NSData dataWithHexString:@"343135"]];
    _receivedHashData = [_receivedHashData addDataAtTail:package.ecdhkey.key];
    _receivedHashData = [_receivedHashData addDataAtTail:[NSData dataWithHexString:@"31"]];

    NSData *hashDataResult = [WC_SHA256 sha256:_receivedHashData];

//    LogVerbose(@"hashDataResult: %@", hashDataResult);

    /////
    
    NSData *ivData = [package.tag3 subdataWithRange:NSMakeRange([package.tag3 length] - 28, 12)];
//    NSData *encrypedData = [NSData dataWithHexString:@"0E67A1B3EC8BF7A12210FDAE39A8DBD549A4F2CB947243EDD23F1CEB428C3152A2E816994CAFF3EF25F0A8AEFD0E189645EE89D0CFC56AB9A53617C12ED8291EEDD7A143EF4CF06749561DE0605B813B67F445B4F3DBA2EB2670BC09B0CFE89C03E5E911B263CCEF79BCA1283F57F84430B379D23E5823C9BE3FEECB813909AD0BD7F1AA83093691421F28DAC980159211D89C9A4CFBD84B100782F35B4D4905255B565D39DD8D8178AB585807C58CA4969F262A081310252E1BCBAE19135EDA31725D4FAE4BA629DFC36D35100484D5D05EB8199D1057ACB55693972AA9F79067C4172C7442DB2C55414D75716A969B71F1B2ED1CC7971B1326F7222A5FA85B86A27480DA8EA7F736D4E1BA55535CD1F06931F9BCEFFAD19F484FCBF79325B49D507613D8619CDB96E488AE7329BE3D1F651391A77787601CA6D0B78DBA25C024639BF8C6D55BFD2F98BEEEC378B2E0D423CE793A3EEF031E1C100F7BD71046452ECA50D47D3C8F5C4BF9165F6A83583E2E9BD2F94533A0CA6805A208BBD567AD5F2D2E529D21F1925285A0EB1E2BB7D1915100EBF8B76D8BE97D6A262E16F0CB14B7D3B73F02197DB1876699AF2AC8A8BBAA3087"];

    NSData *encrypedData = [package.tag3 subdataWithRange:NSMakeRange(0, [package.tag3 length]-28)];
    NSData *plainData = [WC_AesGcm128 aes192gcmDecrypt:encrypedData
                                                   aad:hashDataResult
                                                   key:[ecdhResult subdataWithRange:NSMakeRange(0, 24)]
                                                  ivec:ivData];

//    LogVerbose(@"%@", plainData);
    
    NSData *protofubData = [plainData dataByInflatingWithError:nil];

//    LogVerbose(@"protofubData: %@", protofubData);

    return protofubData;
}

@end
