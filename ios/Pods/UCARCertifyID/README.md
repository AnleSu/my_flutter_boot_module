# UCARCertifyID

> 无车车生活 认证模块

其中包括
1. 身份证认证 - `UCARCIDCardManager`

  * 拍照 - 正面

    ```
      - (void)idCard_FrontImageWithViewController:(UIViewController *)viewController
                                          success:(void(^)(UIImage *model))finish
                                          failure:(void(^)(UCARCIDCardError errorType))error;
    ```

  * 拍照 - 反面

    ```
      - (void)readIDCardInfoWithFrontSide:(id)front
                                 backSide:(id)back
                               isVerified:(BOOL)isVerified
                                  success:(void (^)(UCarIDCardDetailModel *idCardDetail))success
                                  failure:(void (^)(int code, NSString *msg))failure;
    ```

  * 读取和验证身份证信息接口

    ```
     - (void)driverLicenseResult:(UCARCIDDrivingLicenseModel *)dlModel
                        memberId:(NSNumber *)memberId
                      memberName:(NSString *)memberName
                         success:(void(^)(UCARCIDDriverLicenseResultModel *model))success
                         failure:(void(^)(NSDictionary *response, NSError *error))failure;
    ```

  * 验证姓名和身份证号接口

    ```
      - (void)verifyIDCardInfoWithName:(NSString *)name
                              idNumber:(NSString *)idNumber
                               success:(void (^)(BOOL isVerified))success
                               failure:(void (^)(int code, NSString *msg))failure;
    ```

2. 驾照认证 - `UCARCDeviceLicenseManager`

  * 上传驾照

    ```
    - (void)uploadDriverLicenseWithFrontImage:(UIImage *)frontImage
                                    backImage:(UIImage *)backImage
                                     memberId:(NSNumber *)memberId
                                      success:(void(^)(UCARCIDDrivingLicenseModel *model))success
                                      failure:(void(^)(NSDictionary *response, NSError *error))failure;
      ```

  * 驾照认证结果

    ```
     - (void)driverLicenseResult:(UCARCIDDrivingLicenseModel *)dlModel
                        memberId:(NSNumber *)memberId
                      memberName:(NSString *)memberName
                         success:(void(^)(UCARCIDDriverLicenseResultModel *model))success
                         failure:(void(^)(NSDictionary *response, NSError *error))failure;
    ```

3. 人脸认证 - `UCARCFaceIdManager`

  * 活体认证

    ```
      - (void)faceIdWithViewController:(UIViewController *)viewController
                              isRandom:(BOOL)isRandom
                               actions:(NSArray *)actions;
    ```

  * 人脸识别接口

    ```
      - (void)verifyFaceWithFaceImage:(UIImage *)faceImage
                                 name:(NSString *)name
                             idNumber:(NSString *)idNumber
                              success:(void (^)(UCarLiveModel *liveModel))success
                              failure:(void (^)(int code, NSString *msg))failure;
    ```

  * 身份证和人脸对比接口

    ```
      - (void)verifyWithIDCardFace:(id)idCardFace
                          liveFace:(id)liveFace
                           success:(void (^)(UCarLiveModel *liveModel))success
                           failure:(void (^)(int code, NSString *msg))failure;
    ```

4. 识别使用相机 - `UCACCIDCemeraManager`

具体使用方式见Example项目。
相机使用见驾照认证Demo `DriverDetectViewController`

身份认证和人脸识别使用了SDK，驾照使用的是MAPI。
