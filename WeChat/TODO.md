zt, [Jul 26, 2019 at 10:44:39 AM]:
长连接：
心跳：6
消息通知：24
初始化：27
同步消息：121
账号登录：253
自动登录：254
通知服务器消息已接收：1000000190

- 账号登录：/cgi-bin/micromsg-bin/manualauth
- 初始化：/cgi-bin/micromsg-bin/newinit
- 消息同步：/cgi-bin/micromsg-bin/newsync

- 发送消息：/cgi-bin/micromsg-bin/newsendmsg

- 朋友圈：
    发布：/cgi-bin/micromsg-bin/mmsnspost
    删除：/cgi-bin/micromsg-bin/mmsnsobjectop
    评论：/cgi-bin/micromsg-bin/mmsnscomment
    列表：/cgi-bin/micromsg-bin/mmsnsuserpage

- 群：
    成员列表：/cgi-bin/micromsg-bin/getchatroommemberdetail
    详情：/cgi-bin/micromsg-bin/getcontact
    修改群名：/cgi-bin/micromsg-bin/oplog
    开启免打扰：/cgi-bin/micromsg-bin/oplog
    保存到通讯录：/cgi-bin/micromsg-bin/oplog
    退群：/cgi-bin/micromsg-bin/oplog
    加人：/cgi-bin/micromsg-bin/addchatroommember
    邀请：/cgi-bin/micromsg-bin/invitechatroommember
    踢人：/cgi-bin/micromsg-bin/delchatroommember
    转移群主：/cgi-bin/micromsg-bin/transferchatroomowner
    自动入群获取最终链接：/cgi-bin/micromsg-bin/geta8key

- 红包：
    接受：/cgi-bin/mmpay-bin/receivewxhb
    打开：/cgi-bin/mmpay-bin/openwxhb
    详情：/cgi-bin/mmpay-bin/qrydetailwxhb

- 转账：
    确认：/cgi-bin/mmpay-bin/transferoperation
    详情：/cgi-bin/mmpay-bin/transferquery

- 密码：
    第一步校验：/cgi-bin/micromsg-bin/newverifypasswd
    第二步修改：/cgi-bin/micromsg-bin/newsetpasswd

- 通讯录：
    上传：/cgi-bin/micromsg-bin/uploadmcontact
    新好友列表：/cgi-bin/micromsg-bin/getmfriend

- 好友：
    自动通过：/cgi-bin/micromsg-bin/verifyuser
    回复文字：/cgi-bin/micromsg-bin/verifyuser
    添加好友：/cgi-bin/micromsg-bin/verifyuser
    设置备注：/cgi-bin/micromsg-bin/oplog
    搜索：/cgi-bin/micromsg-bin/searchcontact
    扫一扫获取中间参数：/cgi-bin/micromsg-bin/geta8key
    详情：/cgi-bin/micromsg-bin/getcontact

<UnifyAuthResponse 0x60000072dea0>: {
BaseResponse {
Ret: -100
ErrMsg {
String: "<e>\n<ShowType>1</ShowType>\n<Content><![CDATA[登录出现错误，请你重新登录。]]></Content>\n<Url><![CDATA[]]></Url>\n<DispSec>30</DispSec>\n<Title><![CDATA[]]></Title>\n<Action>4</Action>\n<DelayConnSec>0</DelayConnSec>\n<Countdown>0</Countdown>\n<Ok><![CDATA[]]></Ok>\n<Cancel><![CDATA[]]></Cancel>\n</e>\n"


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
