
<UnifyAuthResponse 0x60000072dea0>: {
BaseResponse {
Ret: -100
ErrMsg {
String: "<e>\n<ShowType>1</ShowType>\n<Content><![CDATA[登录出现错误，请你重新登录。]]></Content>\n<Url><![CDATA[]]></Url>\n<DispSec>30</DispSec>\n<Title><![CDATA[]]></Title>\n<Action>4</Action>\n<DelayConnSec>0</DelayConnSec>\n<Countdown>0</Countdown>\n<Ok><![CDATA[]]></Ok>\n<Cancel><![CDATA[]]></Cancel>\n</e>\n"
}
}
UnifyAuthSectFlag: 0
AuthSectResp {
Uin: 0
SvrPubECDHKey {
Nid: 0
Key {
iLen: 0
}
}
SessionKey {
iLen: 0
}
AutoAuthKey {
iLen: 0
}
WTLoginRspBuffFlag: 0
WTLoginRspBuff {
iLen: 0
}
WTLoginImgRespInfo {
KSid {
iLen: 0
}
ImgBuf {
iLen: 0
}
}
WxVerifyCodeRespInfo {
VerifyBuff {
iLen: 0
}
}
CliDBEncryptKey {
iLen: 0
}
CliDBEncryptInfo {
iLen: 0
}
A2Key {
iLen: 0
}
ShowStyle {
KeyCount: 0
}
NewVersion: 0
UpdateFlag: 0
AuthResultFlag: 0
serverTime: 0
# --- Unknown fields ---
21: 0
23: "\010\000"
24: "\010\000"
}
AcctSectResp {
BindUin: 0
Status: 0
PluginFlag: 0
RegType: 0
SafeDevice: 0
PushMailStatus: 0
}
NetworkSectResp {
NewHostList {
Count: 0
}
NetworkControl {
MinNoopInterval: 0
MaxNoopInterval: 0
TypingInterval: 0
NoopIntervalTime: 0
}
BuiltinIPList {
LongConnectIPCount: 0
ShortConnectIPCount: 0
Seq: 0
}
}
# --- Unknown fields ---
6: "\010\000"
}

MM_BOTTLE_ERR_UNKNOWNTYPE = 15,
MM_BOTTLE_COUNT_ERR = 16,
MM_BOTTLE_NOTEXIT = 17,
MM_BOTTLE_UINNOTMATCH = 18,
MM_BOTTLE_PICKCOUNTINVALID = 19,
MMSNS_RET_SPAM = 201,
MMSNS_RET_BAN = 202,
MMSNS_RET_PRIVACY = 203,
MMSNS_RET_COMMENT_HAVE_LIKE = 204,
MMSNS_RET_COMMENT_NOT_ALLOW = 205,
MMSNS_RET_CLIENTID_EXIST = 206,
MMSNS_RET_ISALL = 207,
MMSNS_RET_COMMENT_PRIVACY = 208,
MM_ERR_SHORTVIDEO_CANCEL = 1000000
