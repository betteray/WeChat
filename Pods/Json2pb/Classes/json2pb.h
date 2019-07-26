//
//  json2pb.h
//  xcaller
//
//  Created by rannger on 2017/8/30.
//  Copyright © 2017年 rannger. All rights reserved.
//

#import <Protobuf/GPBMessage.h>

@interface GPBMessage (JSON)
/**
 * Initializes an instance by parsing the data. This method should be sent to
 * the generated message class that the data should be interpreted as. If
 * there is an error the method returns nil and the error is returned in
 * errorPtr (when provided).

 * @param data The JSON data to parse.
 * @return An initialized instance of the generated class.
 */
- (instancetype)initWithJson:(NSData*)data;
/**
 *Serializes the message to an NSData.
 *
 *@return The JSON representation of the message.
 */
- (NSData*)toJson;
/**
 * Serializes the message to an JSON Object (NSArray,NSNumber,NSNull,NSDictionary).
 *
 * @return The JSON representation of the message.
 */
- (id)jsonObject;
@end
