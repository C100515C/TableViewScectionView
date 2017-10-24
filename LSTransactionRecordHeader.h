//
//  LSTransactionRecordType.h
//  JianChu
//
//  Created by CC on 2017/10/19.
//  Copyright © 2017年 历成栋. All rights reserved.
//

#ifndef LSTransactionRecordType_h
#define LSTransactionRecordType_h

/**
 "type":2,                //类型：Number  必有字段  备注：交易类型 类型(1:下单 2:充值 3:平台返利,4推荐用户消费返利,5退款,6提现)

 */
typedef NS_ENUM(NSInteger,LSTransactionRecordType){
    LSTransactionRecord_Order = 1,//订单 消费
    LSTransactionRecord_Pay,//充值
    LSTransactionRecord_Platform,//平台返利
    LSTransactionRecord_UserConsumerRebates,//客户消费分润
    LSTransactionRecord_Refund,//退款
    LSTransactionRecord_Withdrawal//提现
    
};

#endif /* LSTransactionRecordType_h */
