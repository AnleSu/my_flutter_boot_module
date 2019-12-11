//
//  UCarLiveModel.h
//  UCarLive
//
//  Created by huyujin on 16/10/11.
//  Copyright © 2016年 UCarInc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCarLiveModel : NSObject

/**
 有源比对时，数据源人脸照片与待验证人脸照的比对结果,此字段只在接口被成功调用时返回。
     result_faceid对象包含如下字段：
         "confidence"：比对结果的置信度，Float类型，取值［0，100］，数字越大表示两张照片越可能是同一个人。
         “thresholds”：一组用于参考的置信度阈值，Object类型，包含三个字段，均为Float类型、取值［0，100］：
         “1e-3”：误识率为千分之一的置信度阈值；
         “1e-4”：误识率为万分之一的置信度阈值；
         “1e-5”：误识率为十万分之一的置信度阈值;
         “1e-6”：误识率为百万分之一的置信度阈值。
         请注意：阈值不是静态的，每次比对返回的阈值不保证相同，所以没有持久化保存阈值的必要，更不要将当前调用返回的confidence与之前调用返回的阈值比较。
         关于阈值选择，以下建议仅供参考：
         阈值选择主要参考两个因素：业务对安全的要求和对用户体验的要求。严格的阈值对应更高的安全度，但是比对通过率会下降，因此更容易出现用户比对多次才通过的情况，用户体验会有影响；较松的阈值带来一次通过率会提升，用户体验更好，但是出现非同一个人的概率会增大，安全性会有影响。请按业务需求偏好慎重选择。
         “1e-3”阈值是较松的阈值。如果confidence低于“1e-3”阈值，我们不建议认为是同一个人；如果仅高于“1e-3”阈值，勉强可以认为是同一个人。这个阈值主要针对对安全性要求较低的场景（比如在分项业务有独立密码保护的情况下刷脸登陆app），或者原则上安全性要求高、但在一个具体流程里如果发生安全事故后果不严重的场景（比如“转账”场景安全性要求高、但是当前转账的金额很小）
         “1e-5”、“1e－6”阈值都是较严格的阈值，一般来说置信度大于“1e-5”阈值就可以相当明确是同一个人。我们建议使用“1e-5”到关键的、高安全级别业务场景中，比如大额度的借款或者转账。“1e-6”则更加严格，适用于比较极端的场景。
         “1e-4”阈值的严格程度介于上述两项之间。
 */
@property (nonatomic, strong) NSDictionary *result_faceid;

/**
 验证结果，如果接口调用成功，则判断confidence大于"1e-5"阈值的为true，否则为false；如果接口调用失败，则为false。
 */
@property (nonatomic, assign) BOOL verify_result;


/** 业务请求失败时返回此字段 */
@property (nonatomic, copy) NSString *error_message;


/** 身份证正面URL（公司内网图片服务器） */
@property (nonatomic, copy) NSString *image1_url;

/** 人脸照片URL（公司内网图片服务器）*/
@property (nonatomic, copy) NSString *image2_url;

- (id)initWithDict:(NSDictionary *)dict;

@end
