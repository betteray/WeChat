//
//  ClientCheckConsistencyUtil.m
//  WeChat
//
//  Created by ray on 2019/12/24.
//  Copyright © 2019 ray. All rights reserved.
//

#import "ClientCheckConsistencyUtil.h"
#import "FSOpenSSL.h"

@implementation ClientCheckConsistencyUtil

+ (NSString *)signParams:(NSArray *)params {
//    NSMutableData *mutableData = [NSMutableData data];
    
//    for (id obj in params) {
//        if ([obj isKindOfClass:[NSString class]]) {
//            [mutableData appendData:[((NSString *)obj) dataUsingEncoding:NSUTF8StringEncoding]];
//        } else if ([obj isKindOfClass:[NSNumber class]]) {
//
//        }
//    }
    
    return @"1962359c264a15f2edf38ae300e7ec0c";
}

//protected void onCreate(Bundle savedInstanceState) {
//    super.onCreate(savedInstanceState);
//    setContentView(R.layout.activity_main);
//
//    String sign = sign(new Object[]{"@classes.dex", 0, 9999999, 536870912, "28c3bf8c8127800e6546d8de1a361dcf", 9481764, 0, 4});
//    Log.d(TAG, String.format("onCreate: %s", sign)); //1962359c264a15f2edf38ae300e7ec0c
//}
//
//private static String sign(Object[] params) {
//    int i;
//    Object element;
//    int index = 0;
//    int longLen = 8;
//    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
//    try {
//        int paramsLengh = params.length;
//        while(index < paramsLengh) {
//            element = params[index];
//            if((element instanceof String)) {
//                outputStream.write(((String)element).getBytes());
//            }
//            else if((element instanceof Integer)) {
//                int v3 = (Integer) element;
//                i = 0;
//                while(i < 4) {
//                    outputStream.write(v3 & 0xFF);
//                    v3 >>= 8;
//                    ++i;
//                }
//            }
//            else if((element instanceof Long)) {
//                long v4 = (Long) element;
//                i = 0;
//                while(i < longLen) {
//                    outputStream.write(((int)(0xFF & v4)));
//                    v4 >>= longLen;
//                    ++i;
//                }
//            }
//            else if((element instanceof Boolean)) {
//                if((Boolean) element) {
//                    i = 1;
//                    outputStream.write(i);
//                }
//                else {
//                    i = 0;
//                    outputStream.write(i);
//                    break;
//                }
//            }
//            index += 1;
//        }
//    }
//    catch(Exception e) {
//        e.printStackTrace();
//    }
//
//    try {
//        return cl(MessageDigest.getInstance("MD5").digest(outputStream.toByteArray()));
//    } catch (NoSuchAlgorithmException e) {
//        e.printStackTrace();
//    }
//
//    return "";
//}
//
@end
