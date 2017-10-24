//
//  LSTransactionRecordsVC.h
//  JianChu
//
//  Created by CC on 2017/10/18.
//  Copyright © 2017年 历成栋. All rights reserved.
//

#import "ZBRreshViewController.h"

@interface LSTransactionRecordsVC : ZBRreshViewController

/**
 type有值的时候1为查询分润 为空查询所有交易记录

 */
@property (nonatomic,copy) NSString *type;
@end
