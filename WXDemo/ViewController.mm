//
//  ViewController.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ViewController.h"
#import "WeChatClient.h"
#import "Mm.pbobjc.h"
#import "Constants.h"
#import "NSData+Util.h"
#import "FSOpenSSL.h"
#import "CgiWrap.h"
#import "NSData+PackUtil.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECDH.h"
#import "MarsOpenSSL.h"
#import "NSData+AES.h"
#import <Protobuf/GPBCodedOutputStream.h>
#import "NSData+Util.h"

#import "WX_AesGcm128.h"
#import "WX_SHA256.h"
#import "WX_HKDF.h"

#import "ShortLinKWithMMTLSTest.h"

#include <zlib.h>
#include <string.h>

#define TICK_INTERVAL 1



@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *wxid;
@property (weak, nonatomic) IBOutlet UILabel *alias;
@property (weak, nonatomic) IBOutlet UILabel *nickname;

@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *qrcodeTimerLabel;
@property (nonatomic, strong) NSTimer *qrcodeCheckTimer;

@property (nonatomic, strong) NSData *nofityKey;
@property (nonatomic, assign) NSInteger clientMsgId;

@property (nonatomic, assign) NSData *clientCheckData;
@end

bool str_startswith(const char *str, const char *starts) {
    return (str == strstr(str, starts));
}

bool str_endwith(const char *str, const char *end) {
    return ((str + strlen(str) - strlen(end)) == strstr(str, end));
}

bool str_contains(const char *str, const char *sub) {
    return (NULL != strstr(str, sub));
}

char *str_replace(const char *string, const char *substr, const char *replacement )
{
    char *tok    = NULL;
    char *newstr = NULL;
    char *oldstr = NULL;
    
    /* if either substr or replacement is NULL, duplicate string a let caller handle it */
    if ( substr == NULL || replacement == NULL )
        return strdup (string);
    
    newstr = strdup (string);
    while ( (tok = strstr( newstr, substr)))
    {
        oldstr = newstr;
        newstr = malloc (strlen ( oldstr ) - strlen ( substr ) + strlen ( replacement ) + 1 );
        /*failed to alloc mem, free old string and return NULL */
        if (newstr == NULL)
        {
            free (oldstr);
            return NULL;
        }
        memcpy ( newstr, oldstr, tok - oldstr );
        memcpy ( newstr + (tok - oldstr), replacement, strlen ( replacement ) );
        memcpy ( newstr + (tok - oldstr) + strlen( replacement ), tok + strlen ( substr ), strlen ( oldstr ) - strlen ( substr ) - ( tok - oldstr ) );
        memset ( newstr + strlen ( oldstr ) - strlen ( substr ) + strlen ( replacement ) , 0, 1 );
        
        free(oldstr);
    }
    
    return newstr;
}

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _clientMsgId = 1;

//    [ShortLinKWithMMTLSTest test];
    
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8080/"];
    NSMutableURLRequest *newGetDNSReq = [NSMutableURLRequest requestWithURL:url];
    newGetDNSReq.HTTPMethod = @"GET";
    newGetDNSReq.timeoutInterval = 5;
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:newGetDNSReq
                                                             completionHandler:^(NSData *_Nullable data,
                                                                                 NSURLResponse *_Nullable response,
                                                                                 NSError *_Nullable error) {
                                                                 DLog(@"ClientCheckData", data);
                                                                 [WXUserDefault saveClientCheckData:data];
                                                             }];

    [task resume];
    
    [self updateUserActivity];
}

- (void)updateUserActivity
{
    NSData *st = [NSData dataWithHexString:@"3C73743E3C49734D6F726B4C6F634F70656E3E303C2F49734D6F726B4C6F634F70656E3E3C4D73674C6576656C3E313C2F4D73674C6576656C3E3C4973446267436F6E6E65637465643E303C2F4973446267436F6E6E65637465643E3C506B6748617368333E31386338363766303731376161363762326162373334373530356261303765643C2F506B6748617368333E3C526174696F46775665723E4D534D3839363050524F5F42505F32333235352E3134302E39332E3030523C2F526174696F46775665723E3C4F7352656C5665723E362E302E313C2F4F7352656C5665723E3C494D45493E3939303030323934303135313637313C2F494D45493E3C416E64726F696449443E353463633835303832373137386663353C2F416E64726F696449443E3C50686F6E6553657269616C3E543031373530305533433C2F50686F6E6553657269616C3E3C50686F6E654D6F64656C3E4D6F746F20583C2F50686F6E654D6F64656C3E3C437075436F7265436F756E743E323C2F437075436F7265436F756E743E3C43707548573E6D736D3839363064743C2F43707548573E3C43707546656174757265733E7377702068616C66207468756D6220666173746D756C74207666702065647370206E656F6E20766670763320746C732076667076343C2F43707546656174757265733E3C53656C664D41433E66383A66313A62363A63663A33363A37333C2F53656C664D41433E3C535349443E55434647524F55503C2F535349443E3C42535349443E37303A66393A36643A63623A35313A30303C2F42535349443E3C5370496E666F3E3C2F5370496E666F3E3C41504E496E666F3E2671756F743B55434647524F55502671756F743B3C2F41504E496E666F3E3C4275696C6446503E6D6F746F726F6C612F67686F73745F7573632F67686F73743A352E312F4C504132332E31322D32312D312F313A757365722F72656C656173652D6B6579733C2F4275696C6446503E3C4275696C64426F6172643E4D534D383936303C2F4275696C64426F6172643E3C4275696C64426F6F746C6F616465723E3078333042453C2F4275696C64426F6F746C6F616465723E3C4275696C644272616E643E6D6F746F726F6C613C2F4275696C644272616E643E3C4275696C644465766963653E67686F73745F7573633C2F4275696C644465766963653E3C4275696C6448573E71636F6D3C2F4275696C6448573E3C4275696C6450726F647563743E6C696E656167655F67686F73743C2F4275696C6450726F647563743E3C4D616E7566616374757265723E6D6F746F726F6C613C2F4D616E7566616374757265723E3C50686F6E654E756D3E3C2F50686F6E654E756D3E3C4E6574547970653E776966693C2F4E6574547970653E3C497351656D75456E763E313C2F497351656D75456E763E3C486173447570506B673E303C2F486173447570506B673E3C48617351696B75536861646F773E303C2F48617351696B75536861646F773E3C506B674E616D653E636F6D2E74656E63656E742E6D6D3C2F506B674E616D653E3C4170704E616D653E262332343439343B262332303434393B3C2F4170704E616D653E3C44617461526F6F743E2F646174612F757365722F302F636F6D2E74656E63656E742E6D6D3C2F44617461526F6F743E3C456E7472616E6365436C6173734C6F616465724E616D653E64616C76696B2E73797374656D2E50617468436C6173734C6F616465723C2F456E7472616E6365436C6173734C6F616465724E616D653E3C456E76426974733E3133353231313333313C2F456E76426974733E3C456E61626C65644163636573736962696C697479536572766963654964733E3C2F456E61626C65644163636573736962696C697479536572766963654964733E3C4163636573736962696C697479436C69636B436F756E743E303C2F4163636573736962696C697479436C69636B436F756E743E3C41504B4C656164696E674D44353E63643131353962333733313733643033656336386165323839333033316463343C2F41504B4C656164696E674D44353E3C436C69656E7456657273696F6E3E307832363037303333333C2F436C69656E7456657273696F6E3E3C57585461673E30313731303863372D303162622D343533642D623064642D6333636665633361373432323C2F57585461673E3C436C69656E7449503E31302E31322E38362E3235303C2F436C69656E7449503E3C4C616E67756167653E7A685F434E3C2F4C616E67756167653E3C4973496E43616C6C696E673E303C2F4973496E43616C6C696E673E3C497353657453637265656E4C6F636B3E313C2F497353657453637265656E4C6F636B3E3C4E65696768626F7242535349444C6973743E33633A31353A63323A62393A65653A61342C37303A66393A36643A63623A35313A30302C37303A66393A36643A63623A35313A31302C37303A66393A36643A63623A35313A30312C37303A66393A36643A63623A35313A30323C2F4E65696768626F7242535349444C6973743E3C4973576966694F70656E3E313C2F4973576966694F70656E3E3C48617358706F736564537461636B54726163653E313C2F48617358706F736564537461636B54726163653E3C58706F736564486F6F6B65644D6574686F64733E7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6361286A6176612E6C616E672E4F626A6563742C6A6176612E6C616E672E436C617373266C743B3F2667743B292C7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E626328696E742C62797465262339313B262339333B2C696E742C696E742C636F6D2E74656E63656E742E6D6D2E706F696E746572732E50496E74292C7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E616828292C7075626C6963206A6176612E6C616E672E537472696E67206A6176612E696F2E42756666657265645265616465722E726561644C696E652829207468726F7773206A6176612E696F2E494F457863657074696F6E2C7072697661746520737461746963206E61746976652062797465262339313B262339333B20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E62612862797465262339313B262339333B2C696E742C696E74292C7072697661746520737461746963206E61746976652062797465262339313B262339333B20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6262286A6176612E6C616E672E537472696E672C62797465262339313B262339333B2C696E742C696E74292C7072697661746520737461746963206E617469766520766F696420636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6463286A6176612E6C616E672E537472696E67292C7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6264286A6176612E6C616E672E537472696E672C62797465262339313B262339333B2C696E742C696E742C636F6D2E74656E63656E742E6D6D2E706F696E746572732E50496E74292C7072697661746520737461746963206E61746976652062797465262339313B262339333B20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E616628696E74292C7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6469286A6176612E6C616E672E537472696E67292C7075626C69632073746174696320766F696420636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D736724632E61286A6176612E6C616E672E537472696E672C616E64726F69642E766965772E4D6F74696F6E4576656E74292C7072697661746520737461746963206E61746976652062797465262339313B262339333B20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E616528292C616E64726F69642E636F6E74656E742E7265732E5479706564417272617928616E64726F69642E636F6E74656E742E7265732E5265736F75726365732C696E74262339313B262339333B2C696E74262339313B262339333B2C696E74292C7072697661746520737461746963206E617469766520766F696420636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6466286A6176612E6C616E672E537472696E672C6A6176612E6C616E672E537472696E67292C7075626C696320616E64726F69642E636F6E74656E742E706D2E5061636B616765496E666F20616E64726F69642E6170702E4170706C69636174696F6E5061636B6167654D616E616765722E6765745061636B616765496E666F286A6176612E6C616E672E537472696E672C696E7429207468726F777320616E64726F69642E636F6E74656E742E706D2E5061636B6167654D616E61676572244E616D654E6F74466F756E64457863657074696F6E2C7072697661746520737461746963206E61746976652062797465262339313B262339333B20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E616128696E74292C7072697661746520737461746963206E6174697665206A6176612E6C616E672E537472696E6720636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E626528292C616E64726F69642E636F6E74656E742E7265732E5265736F757263657320616E64726F69642E6170702E5265736F75726365734D616E616765722E676574546F704C6576656C5265736F7572636573286A6176612E6C616E672E537472696E672C6A6176612E6C616E672E537472696E67262339313B262339333B2C6A6176612E6C616E672E537472696E67262339313B262339333B2C6A6176612E6C616E672E537472696E67262339313B262339333B2C696E742C6A6176612E6C616E672E537472696E672C616E64726F69642E636F6E74656E742E7265732E436F6E66696775726174696F6E2C616E64726F69642E636F6E74656E742E7265732E436F6D7061746962696C697479496E666F2C616E64726F69642E636F6E74656E742E436F6E746578742C626F6F6C65616E292C7075626C696320616E64726F69642E636F6E74656E742E706D2E4170706C69636174696F6E496E666F20616E64726F69642E6170702E4170706C69636174696F6E5061636B6167654D616E616765722E6765744170706C69636174696F6E496E666F286A6176612E6C616E672E537472696E672C696E7429207468726F777320616E64726F69642E636F6E74656E742E706D2E5061636B6167654D616E61676572244E616D654E6F74466F756E64457863657074696F6E2C7075626C696320616E64726F69642E766965772E5669657720616E64726F69642E766965772E4C61796F7574496E666C617465722E696E666C617465286F72672E786D6C70756C6C2E76312E586D6C50756C6C5061727365722C616E64726F69642E766965772E5669657747726F75702C626F6F6C65616E292C7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6268286A6176612E6C616E672E537472696E672C62797465262339313B262339333B2C696E742C696E742C636F6D2E74656E63656E742E6D6D2E706F696E746572732E50496E742C636F6D2E74656E63656E742E6D6D2E706F696E746572732E50496E742C636F6D2E74656E63656E742E6D6D2E706F696E746572732E50427974654172726179292C7075626C69632066696E616C20626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E61682E762E6128696E742C62797465262339313B262339333B2C62797465262339313B262339333B292C7072697661746520766F696420616E64726F69642E766965772E4C61796F7574496E666C617465722E7061727365496E636C756465286F72672E786D6C70756C6C2E76312E586D6C50756C6C5061727365722C616E64726F69642E636F6E74656E742E436F6E746578742C616E64726F69642E766965772E566965772C616E64726F69642E7574696C2E41747472696275746553657429207468726F7773206F72672E786D6C70756C6C2E76312E586D6C50756C6C506172736572457863657074696F6E2C6A6176612E696F2E494F457863657074696F6E2C7075626C696320616E64726F69642E636F6E74656E742E7265732E5265736F757263657320616E64726F69642E6170702E5265736F75726365734D616E616765722E676574546F704C6576656C5468656D65645265736F7572636573286A6176612E6C616E672E537472696E672C696E742C6A6176612E6C616E672E537472696E672C6A6176612E6C616E672E537472696E672C616E64726F69642E636F6E74656E742E7265732E436F6D7061746962696C697479496E666F2C626F6F6C65616E292C7072697661746520737461746963206E61746976652062797465262339313B262339333B20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6465286A6176612E6C616E672E537472696E67292C7075626C69632073746174696320616E64726F69642E6170702E416374697669747954687265616420616E64726F69642E6170702E41637469766974795468726561642E73797374656D4D61696E28292C7072697661746520737461746963206E617469766520766F696420636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6468286A6176612E6C616E672E537472696E67292C7075626C6963206A6176612E7574696C2E4C697374266C743B616E64726F69642E6170702E41637469766974794D616E616765722452756E6E696E6753657276696365496E666F2667743B20616E64726F69642E6170702E41637469766974794D616E616765722E67657452756E6E696E67536572766963657328696E7429207468726F7773206A6176612E6C616E672E5365637572697479457863657074696F6E2C7075626C696320636F6D2E74656E63656E742E6D6D2E62762E6120636F6D2E74656E63656E742E6D6D2E62762E612E61482862797465262339313B262339333B292C7072697661746520737461746963206E617469766520766F696420636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6461286A6176612E6C616E672E537472696E67292C7075626C6963206A6176612E6C616E672E537461636B5472616365456C656D656E74262339313B262339333B206A6176612E6C616E672E5468726F7761626C652E676574537461636B547261636528292C7075626C696320616E64726F69642E636F6E74656E742E7265732E5265736F75726365734B6579286A6176612E6C616E672E537472696E672C696E742C616E64726F69642E636F6E74656E742E7265732E436F6E66696775726174696F6E2C666C6F61742C626F6F6C65616E2C616E64726F69642E636F6E74656E742E7265732E5468656D65436F6E666967292C7075626C6963206A6176612E7574696C2E4C697374266C743B616E64726F69642E6170702E41637469766974794D616E616765722452756E6E696E6741707050726F63657373496E666F2667743B20616E64726F69642E6170702E41637469766974794D616E616765722E67657452756E6E696E6741707050726F63657373657328292C7075626C6963206A6176612E7574696C2E4C697374266C743B616E64726F69642E636F6E74656E742E706D2E5061636B616765496E666F2667743B20616E64726F69642E6170702E4170706C69636174696F6E5061636B6167654D616E616765722E676574496E7374616C6C65645061636B6167657328696E74292C7072697661746520737461746963206E61746976652062797465262339313B262339333B20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E646A286A6176612E6C616E672E537472696E67292C7072697661746520737461746963206E61746976652062797465262339313B262339333B20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E616728696E74292C7072697661746520737461746963206E6174697665206A6176612E6C616E672E537472696E6720636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E626628696E74292C7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6362286A6176612E6C616E672E4F626A656374292C7072697661746520737461746963206E6174697665206A6176612E6C616E672E537472696E6720636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6164286A6176612E6C616E672E537472696E672C626F6F6C65616E292C7075626C6963206A6176612E7574696C2E4C697374266C743B616E64726F69642E636F6E74656E742E706D2E4170706C69636174696F6E496E666F2667743B20616E64726F69642E6170702E4170706C69636174696F6E5061636B6167654D616E616765722E676574496E7374616C6C65644170706C69636174696F6E7328696E74292C7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E616928292C7075626C696320636F6D2E74656E63656E742E6D6D2E61682E7528636F6D2E74656E63656E742E6D6D2E6E6574776F726B2E712C636F6D2E74656E63656E742E6D6D2E73646B2E706C6174666F726D746F6F6C732E6168292C7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E626728696E742C62797465262339313B262339333B2C696E742C696E742C636F6D2E74656E63656E742E6D6D2E706F696E746572732E50496E742C636F6D2E74656E63656E742E6D6D2E706F696E746572732E50496E742C636F6D2E74656E63656E742E6D6D2E706F696E746572732E50427974654172726179292C7075626C69632062797465262339313B262339333B20636F6D2E74656E63656E742E6D6D2E62762E612E746F42797465417272617928292C7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E616A28292C7075626C69632073746174696320626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D736724642E62286A6176612E6C616E672E4F626A6563742C6A6176612E6C616E672E436C617373266C743B3F2667743B292C7075626C69632066696E616C20766F696420636F6D2E74656E63656E742E6D6D2E706C7567696E2E736563696E666F7265706F72742E632E6F28696E742C62797465262339313B262339333B292C7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6464286A6176612E6C616E672E537472696E67292C7072697661746520737461746963206E617469766520766F696420636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E6462286A6176612E6C616E672E537472696E67292C7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E616328292C7075626C6963206A6176612E7574696C2E4C697374266C743B616E64726F69642E6170702E41637469766974794D616E616765722452756E6E696E675461736B496E666F2667743B20616E64726F69642E6170702E41637469766974794D616E616765722E67657452756E6E696E675461736B7328696E7429207468726F7773206A6176612E6C616E672E5365637572697479457863657074696F6E2C7072697661746520737461746963206E617469766520626F6F6C65616E20636F6D2E74656E63656E742E6D6D2E706C7567696E2E6E6F726D73672E4E6F726D7367244A32434272696467652E616B28293C2F58706F736564486F6F6B65644D6574686F64733E3C4973414442537769746368456E61626C65643E313C2F4973414442537769746368456E61626C65643E3C497352756E6E696E6742794D6F6E6B65793E303C2F497352756E6E696E6742794D6F6E6B65793E3C417070496E737472756D656E746174696F6E436C6173734E616D653E636F6D2E74656E63656E742E6D6D2E73706C6173682E6C3C2F417070496E737472756D656E746174696F6E436C6173734E616D653E3C414D5342696E646572436C6173734E616D653E616E64726F69642E6F732E42696E64657250726F78793C2F414D5342696E646572436C6173734E616D653E3C414D5353696E676C65746F6E436C6173734E616D653E616E64726F69642E6170702E41637469766974794D616E6167657250726F78793C2F414D5353696E676C65746F6E436C6173734E616D653E3C2F73743E3C63636463633E313335373536303932303C2F63636463633E3C63636474733E313534323230353330353C2F63636474733E0E"];
    [self compress:(Bytef *)[st bytes] len:(uLong)[st length]];
}

- (void)compress:(Bytef *)source len:(uLong)sourceLen
{
    if (sourceLen>0x2000) {
        if (str_startswith(source, "<st>")) {
            char *str = malloc(sourceLen + 1);
            memset(str, 0, sourceLen+1);
            memcpy(str, source, sourceLen);
            printf("%s", str);
            
            std::string s;
        }
    }
}

- (IBAction)checkresUpdate:(id)sender
{
    CheckResUpdateRequest_ResID_SubTypeVector *crs = [CheckResUpdateRequest_ResID_SubTypeVector new];
    crs.subType = 1;
    crs.keyVersion = 0;
    crs.resVersion = 473;
    crs.eid = 0;
    
    CheckResUpdateRequest_ResID *resID = [CheckResUpdateRequest_ResID new];
    resID.type = 37;
    resID.subTypeVectorArray = [@[crs] mutableCopy];
    
    CheckResUpdateRequest *request = [[CheckResUpdateRequest alloc] init];
    request.resIdArray = [@[resID] mutableCopy];
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 180;
    cgiWrap.cmdId = 0;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = NO;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/encryptchecktinkerupdate";
//    cgiWrap.responseClass = [GetLoginQRCodeResponse class];
    
    [[WeChatClient sharedClient] postRequest:cgiWrap success:^(id  _Nullable response) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (IBAction)getQRCode
{
    NSLog(@"扫描成功");
    [self.qrcodeCheckTimer invalidate];
    self.qrcodeCheckTimer = nil;

    GetLoginQRCodeRequest *request = [GetLoginQRCodeRequest new];

    SKBuiltinBuffer *buffer = [SKBuiltinBuffer new];
    [buffer setILen:(int32_t)[[WeChatClient sharedClient].sessionKey length]];
    [buffer setBuffer:[WeChatClient sharedClient].sessionKey];
    [request setRandomEncryKey:buffer];

    [request setDeviceName:DEVICEN_NAME];
    [request setExtDevLoginType:0];
    [request setOpcode:0];
    [request setHardwareExtra:0];
    [request setUserName:nil];
    [request setSoftType:nil];
    SKBuiltinBuffer *pubKey = [SKBuiltinBuffer new];
    pubKey.buffer = [WeChatClient sharedClient].pubKey;
    [pubKey setILen:(int32_t)[[WeChatClient sharedClient].pubKey length]];
    [request setMsgContextPubKey:pubKey];

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 502;
    cgiWrap.cmdId = 232;
    cgiWrap.request = request;
    cgiWrap.responseClass = [GetLoginQRCodeResponse class];

    [WeChatClient startRequest:cgiWrap
        success:^(GPBMessage *_Nullable response) {
            NSLog(@"%@", response);
            GetLoginQRCodeResponse *resp = (GetLoginQRCodeResponse *) response;

            if (resp)
            {
                self.nofityKey = resp.notifyKey.buffer;
                self.qrcodeImageView.image = [UIImage imageWithData:[[resp qrcode] buffer]];
                self.qrcodeTimerLabel.text = [NSString stringWithFormat:@"%d", resp.expiredTime];
                self.qrcodeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:TICK_INTERVAL target:self selector:@selector(tick:) userInfo:resp repeats:YES];
            }

        }
        failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
}

- (void)tick:(NSTimer *)timer
{
    [self updateUI];

    CheckLoginQRCodeRequest *request = [CheckLoginQRCodeRequest new];

    SKBuiltinBuffer *buffer = [SKBuiltinBuffer new];
    [buffer setILen:16];
    [buffer setBuffer:[WeChatClient sharedClient].sessionKey];
    [request setRandomEncryKey:buffer];

    request.uuid = ((GetLoginQRCodeResponse *) [timer userInfo]).uuid;
    request.timeStamp = [[NSDate date] timeIntervalSince1970];
    request.opcode = 0;

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 503;
    cgiWrap.cmdId = 233;
    cgiWrap.request = request;
    cgiWrap.responseClass = [CheckLoginQRCodeResponse class];

    [WeChatClient startRequest:cgiWrap
        success:^(GPBMessage *_Nullable response) {
            CheckLoginQRCodeResponse *resp = (CheckLoginQRCodeResponse *) response;
            if (resp.baseResponse.ret == 0)
            {
                NSData *notifyProtobufData = [[resp.notifyPkg.notifyData buffer] aesDecryptWithKey:self.nofityKey];
                NotifyMsg *msg = [NotifyMsg parseFromData:notifyProtobufData error:nil];
                if (![msg.avatar isEqualToString:@""])
                {
                    NSLog(@"扫描成功: %@", msg);
                    self.qrcodeTimerLabel.text = msg.nickName;
                    [self.qrcodeImageView sd_setImageWithURL:[NSURL URLWithString:msg.avatar]];
                }

                if (![msg.wxnewpass isEqualToString:@""])
                { //ManualAuth

                    [self mannualAtuhLoginWithWxid:msg.wxid newPassword:msg.wxnewpass];
                }

                if (msg.state == 0 || msg.state == 1)
                {
                    NSLog(@"继续检查确认登陆。");
                }
            }

        }
        failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
}

- (void)updateUI
{
    NSInteger remainTime = [_qrcodeTimerLabel.text integerValue] - TICK_INTERVAL;
    if (remainTime <= 0)
    {
        self.qrcodeTimerLabel.text = @"二维码已过期";
    }
    else
    {
        self.qrcodeTimerLabel.text = [NSString stringWithFormat:@"%d", (int) remainTime];
    }
}

- (IBAction)SendMsg
{
    SKBuiltinString_t *toUserName = [SKBuiltinString_t new];
    toUserName.string = @"rowhongwei";

    MicroMsgRequestNew *mmRequestNew = [MicroMsgRequestNew new];
    mmRequestNew.toUserName = toUserName;
    mmRequestNew.content = @"hello";
    mmRequestNew.type = 1;
    mmRequestNew.createTime = [[NSDate date] timeIntervalSince1970];
    mmRequestNew.clientMsgId = [[NSDate date] timeIntervalSince1970] + arc4random(); //_clientMsgId++;
                                                                                     //    mmRequestNew.msgSource = @""; // <msgsource></msgsource>

    SendMsgRequestNew *request = [SendMsgRequestNew new];

    [request setListArray:[NSMutableArray arrayWithObject:mmRequestNew]];
    request.count = (int32_t)[[NSMutableArray arrayWithObject:mmRequestNew] count];

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 237;
    cgiWrap.cgi = 522;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = NO;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/newsendmsg";
    cgiWrap.responseClass = [MicroMsgResponseNew class];

//    [WeChatClient startRequest:cgiWrap
//        success:^(id _Nullable response) {
//            NSLog(@"%@", response);
//
//        }
//        failure:^(NSError *error) {
//            NSLog(@"%@", error);
//        }];
    
    [[WeChatClient sharedClient] postRequest:cgiWrap success:^(id  _Nullable response) {

    } failure:^(NSError *error) {

    }];
}

- (IBAction)ManualAuth
{
    NSData *priKeyData = nil;
    NSData *pubKeyData = nil;

    BOOL ret = [ECDH GenEcdhWithNid:713 priKey:&priKeyData pubKeyData:&pubKeyData];
    if (ret)
    {
        //        NSLog(@"+[ECDH GenEcdh:pubKeyData:] %@, PubKey: %@.", priKeyData, pubKeyData);
    }

    ManualAuthAccountRequest_AesKey *aesKey = [ManualAuthAccountRequest_AesKey new];
    aesKey.len = (int32_t)[[WeChatClient sharedClient].sessionKey length];
    aesKey.key = [WeChatClient sharedClient].sessionKey;

    ManualAuthAccountRequest_Ecdh_EcdhKey *ecdhKey = [ManualAuthAccountRequest_Ecdh_EcdhKey new];
    ecdhKey.len = (int32_t)[pubKeyData length];
    ecdhKey.key = pubKeyData;

    ManualAuthAccountRequest_Ecdh *ecdh = [ManualAuthAccountRequest_Ecdh new];
    ecdh.nid = 713;
    ecdh.ecdhKey = ecdhKey;

    ManualAuthAccountRequest *accountReqeust = [ManualAuthAccountRequest new];
    accountReqeust.aes = aesKey;
    accountReqeust.ecdh = ecdh;
    accountReqeust.pwd = @"a4e1442774cc2eda89feb8ae66a33c8b";
    accountReqeust.userName = @"+8613520806231";

    ManualAuthDeviceRequest_BaseAuthReqInfo *baseReqInfo = [ManualAuthDeviceRequest_BaseAuthReqInfo new];
    //TODO: ?第一次登陆没有数据，后续登陆会取一个数据。
    //    baseReqInfo.cliDbencryptInfo = [NSData data];
    baseReqInfo.authReqFlag = @"";

    ManualAuthDeviceRequest *deviceRequest = [ManualAuthDeviceRequest new];
    deviceRequest.baseReqInfo = baseReqInfo;
    deviceRequest.imei = IMEI;
    deviceRequest.softType = SOFT_TYPE;
    deviceRequest.builtinIpseq = 0;
    deviceRequest.clientSeqId = CLIENT_SEQ_ID;
    deviceRequest.deviceName = DEVICEN_NAME;
    deviceRequest.deviceType = DEVICE_TYPE;
    deviceRequest.language = LANGUAGE;
    deviceRequest.timeZone = TIME_ZONE;
    deviceRequest.channel = CHANEL;
    deviceRequest.timeStamp = [[NSDate date] timeIntervalSince1970];
    deviceRequest.deviceBrand = DEVICE_BRAND;
    deviceRequest.realCountry = REAL_COUNTRY;
    deviceRequest.bundleId = BUNDLE_ID;
    deviceRequest.adSource = AD_SOURCE; //iMac 不需要
    deviceRequest.iphoneVer = IPHONE_VER;
    deviceRequest.inputType = 2;
    deviceRequest.ostype = OS_TYPE;

    //iMac 暂时不需要

    if ([[WXUserDefault getClientCheckData] length] <= 0)
    {
        [self showHUDWithText:@"Make Sure ClientCheckData not nil."];
        return;
    }
    else
    {
        [self showHUDWithText:@"CLinetCheckData has worked."];
    }

    SKBuiltinBuffer *clientCheckData = [SKBuiltinBuffer new];
    clientCheckData.iLen = (int) [[WXUserDefault getClientCheckData] length];
    clientCheckData.buffer = [WXUserDefault getClientCheckData];
    deviceRequest.clientCheckData = clientCheckData;

    ManualAuthRequest *authRequest = [ManualAuthRequest new];
    authRequest.aesReqData = deviceRequest;
    authRequest.rsaReqData = accountReqeust;

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 701;
    cgiWrap.cmdId = 253;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/manualauth";
    cgiWrap.request = authRequest;
    cgiWrap.responseClass = [ManualAuthResponse class];
    cgiWrap.needSetBaseRequest = NO;


    [[WeChatClient sharedClient] manualAuth:cgiWrap
                                    success:^(GPBMessage *_Nullable response) {
                                        ManualAuthResponse *resp = (ManualAuthResponse *) response;
                                        NSLog(@"登陆响应: %@", resp);

                                        NSLog(@"登陆响应 Code: %d, msg: %@", resp.result.code, resp.result.errMsg.msg);
                                        switch (resp.result.code)
                                        {
                                            case -301:
                                            { //需要重定向
                                                if (resp.dns.ip.longlinkIpCnt > 0)
                                                {
                                                    NSString *longlinkIp = [[resp.dns.ip.longlinkArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                                                    [[WeChatClient sharedClient] restartUsingIpAddress:longlinkIp];
                                                }
                                            }
                                            break;
                                            case 0:
                                            { //成功，停止检查二维码
                                                //                [self.qrcodeCheckTimer invalidate];
                                                //                self.qrcodeCheckTimer = nil;
                                                self.qrcodeTimerLabel.text = @"登陆成功";

                                                int32_t uin = resp.authParam.uin;
                                                [WeChatClient sharedClient].uin = uin;

                                                int32_t nid = resp.authParam.ecdh.nid;
                                                int32_t ecdhKeyLen = resp.authParam.ecdh.ecdhKey.len;
                                                NSData *ecdhKey = resp.authParam.ecdh.ecdhKey.key;

                                                unsigned char szSharedKey[2048];
                                                int szSharedKeyLen = 0;

                                                BOOL ret = [ECDH DoEcdh:nid
                                                         szServerPubKey:(unsigned char *) [ecdhKey bytes]
                                                          nLenServerPub:ecdhKeyLen
                                                          szLocalPriKey:(unsigned char *) [priKeyData bytes]
                                                           nLenLocalPri:(int) [priKeyData length]
                                                             szShareKey:szSharedKey
                                                           pLenShareKey:&szSharedKeyLen];

                                                if (ret)
                                                {
                                                    NSData *checkEcdhKey = [NSData dataWithBytes:szSharedKey length:szSharedKeyLen];
                                                    [WeChatClient sharedClient].sessionKey = [FSOpenSSL aesDecryptData:resp.authParam.session.key key:checkEcdhKey];
                                                    [WeChatClient sharedClient].checkEcdhKey = checkEcdhKey;

                                                    NSLog(@"登陆成功: SessionKey: %@, uin: %d, wxid: %@, NickName: %@, alias: %@",
                                                          [WeChatClient sharedClient].sessionKey,
                                                          uin, resp.accountInfo.wxId,
                                                          resp.accountInfo.nickName,
                                                          resp.accountInfo.alias);

                                                    [WeChatClient sharedClient].shortLinkUrl = [[resp.dns.ip.shortlinkArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];

                                                    self.wxid.text = resp.accountInfo.wxId;
                                                    self.alias.text = resp.accountInfo.alias;
                                                    self.nickname.text = resp.accountInfo.nickName;

                                                    [WXUserDefault saveUIN:uin];
                                                    [WXUserDefault saveWXID:resp.accountInfo.wxId];
                                                    [WXUserDefault saveNikeName:resp.accountInfo.nickName];
                                                    [WXUserDefault saveAlias:resp.accountInfo.alias];

//                                                    [[WeChatClient sharedClient] readDataManually];
                                                }
                                            }
                                            break;
                                            default:
                                                break;
                                        }
                                    }
                                    failure:^(NSError *error){

                                    }];
}

- (void)mannualAtuhLoginWithWxid:(NSString *)wxid newPassword:(NSString *)password
{
    NSData *priKeyData = nil;
    NSData *pubKeyData = nil;
    BOOL ret = [ECDH GenEcdhWithNid:713 priKey:&priKeyData pubKeyData:&pubKeyData];
    if (ret)
    {
        //        NSLog(@"+[ECDH GenEcdh:pubKeyData:] %@, PubKey: %@.", priKeyData, pubKeyData);
    }

    ManualAuthAccountRequest_AesKey *aesKey = [ManualAuthAccountRequest_AesKey new];
    aesKey.len = (int32_t)[[WeChatClient sharedClient].sessionKey length];
    aesKey.key = [WeChatClient sharedClient].sessionKey;

    ManualAuthAccountRequest_Ecdh_EcdhKey *ecdhKey = [ManualAuthAccountRequest_Ecdh_EcdhKey new];
    ecdhKey.len = (int32_t)[pubKeyData length];
    ecdhKey.key = pubKeyData;

    ManualAuthAccountRequest_Ecdh *ecdh = [ManualAuthAccountRequest_Ecdh new];
    ecdh.nid = 713;
    ecdh.ecdhKey = ecdhKey;

    ManualAuthAccountRequest *accountReqeust = [ManualAuthAccountRequest new];
    accountReqeust.aes = aesKey;
    accountReqeust.ecdh = ecdh;
    accountReqeust.pwd = password;
    accountReqeust.userName = wxid;

    ManualAuthDeviceRequest_BaseAuthReqInfo *baseReqInfo = [ManualAuthDeviceRequest_BaseAuthReqInfo new];
    //TODO: ?第一次登陆没有数据，后续登陆会取一个数据。
    //    baseReqInfo.cliDbencryptInfo = [NSData data];
    //    baseReqInfo.authReqFlag = @"";

    ManualAuthDeviceRequest *deviceRequest = [ManualAuthDeviceRequest new];
    deviceRequest.baseReqInfo = baseReqInfo;
    deviceRequest.imei = @"dd09ae95fe48164451be954cd1871cb7";
    //    deviceRequest.softType = @"<softtype><k3>11.4.1</k3><k9>iPad</k9><k10>2</k10><k19>68ADE338-AA19-433E-BA2A-3D6DF3C787D5</k19><k20>AAA7AE28-7620-431D-8B4C-7FB4F67AA45E</k20><k22>(null)</k22><k33>微信</k33><k47>1</k47><k50>0</k50><k51>com.tencent.xin</k51><k54>iPad4,4</k54><k61>2</k61></softtype>";
    deviceRequest.builtinIpseq = 0;
    deviceRequest.clientSeqId = @""; //[NSString stringWithFormat:@"%@-%d", @"dd09ae95fe48164451be954cd1871cb7", (int)[[NSDate date] timeIntervalSince1970]];
    deviceRequest.deviceName = DEVICEN_NAME;
    deviceRequest.deviceType = @"iMac18,2";
    deviceRequest.language = @"zh_CN";
    deviceRequest.timeZone = @"8.00";
    deviceRequest.channel = 0;
    deviceRequest.timeStamp = [[NSDate date] timeIntervalSince1970];
    deviceRequest.deviceBrand = @"Apple";
    deviceRequest.realCountry = @"CN";
    deviceRequest.bundleId = @"com.tencent.xinWeChat";
    //    deviceRequest.adSource = @""; //iMac 不需要
    deviceRequest.iphoneVer = @"iMac18,2";
    deviceRequest.inputType = 2;
    deviceRequest.ostype = @"Version 10.13.6 (Build 17G65)";

    //iMac 暂时不需要
    //    SKBuiltinBuffer *clientCheckData = [SKBuiltinBuffer new];
    //    clientCheckData.iLen = 0;
    //    clientCheckData.buffer = [NSData data];
    //    deviceRequest.clientCheckData = clientCheckData;

    ManualAuthRequest *authRequest = [ManualAuthRequest new];
    authRequest.aesReqData = deviceRequest;
    authRequest.rsaReqData = accountReqeust;

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 701;
    cgiWrap.cmdId = 253;
    cgiWrap.request = authRequest;
    cgiWrap.responseClass = [ManualAuthResponse class];

    [[WeChatClient sharedClient] manualAuth:cgiWrap
                                    success:^(GPBMessage *_Nullable response) {
                                        ManualAuthResponse *resp = (ManualAuthResponse *) response;

                                        NSLog(@"登陆响应 Code: %d, msg: %@", resp.result.code, resp.result.errMsg.msg);
                                        switch (resp.result.code)
                                        {
                                            case -301:
                                            { //需要重定向
                                                if (resp.dns.ip.longlinkIpCnt > 0)
                                                {
                                                    NSString *longlinkIp = [[resp.dns.ip.longlinkArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                                                    [[WeChatClient sharedClient] restartUsingIpAddress:longlinkIp];
                                                }
                                            }
                                            break;
                                            case 0:
                                            { //成功，停止检查二维码
                                                [self.qrcodeCheckTimer invalidate];
                                                self.qrcodeCheckTimer = nil;
                                                self.qrcodeTimerLabel.text = @"登陆成功";

                                                int32_t uin = resp.authParam.uin;
                                                [WeChatClient sharedClient].uin = uin;

                                                int32_t nid = resp.authParam.ecdh.nid;
                                                int32_t ecdhKeyLen = resp.authParam.ecdh.ecdhKey.len;
                                                NSData *ecdhKey = resp.authParam.ecdh.ecdhKey.key;

                                                unsigned char szSharedKey[2048];
                                                int szSharedKeyLen = 0;

                                                BOOL ret = [ECDH DoEcdh:nid
                                                         szServerPubKey:(unsigned char *) [ecdhKey bytes]
                                                          nLenServerPub:ecdhKeyLen
                                                          szLocalPriKey:(unsigned char *) [priKeyData bytes]
                                                           nLenLocalPri:(int) [priKeyData length]
                                                             szShareKey:szSharedKey
                                                           pLenShareKey:&szSharedKeyLen];

                                                if (ret)
                                                {
                                                    NSData *checkEcdhKey = [NSData dataWithBytes:szSharedKey length:szSharedKeyLen];
                                                    [WeChatClient sharedClient].sessionKey = [FSOpenSSL aesDecryptData:resp.authParam.session.key key:checkEcdhKey];
                                                    [WeChatClient sharedClient].checkEcdhKey = checkEcdhKey;

                                                    NSLog(@"登陆成功: SessionKey: %@, uin: %d, wxid: %@, NickName: %@, alias: %@",
                                                          [WeChatClient sharedClient].sessionKey,
                                                          uin, resp.accountInfo.wxId,
                                                          resp.accountInfo.nickName,
                                                          resp.accountInfo.alias);

                                                    [WeChatClient sharedClient].shortLinkUrl = [[resp.dns.ip.shortlinkArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                                                }
                                            }
                                            break;
                                            default:
                                                break;
                                        }
                                    }
                                    failure:^(NSError *error){

                                    }];
}

@end
