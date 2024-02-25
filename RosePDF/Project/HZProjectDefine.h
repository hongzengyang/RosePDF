//
//  HZProjectDefine.h
//  RosePDF
//
//  Created by THS on 2024/2/4.
//

#ifndef HZProjectDefine_h
#define HZProjectDefine_h

#define Default_folderId    @"root"
#define Tmp_project_prefix  @"tmp"

#define HZLibraryCachePath  [((NSArray *)NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)) firstObject]
#define HZLibraryPath [HZLibraryCachePath stringByReplacingOccurrencesOfString:@"/Caches" withString:@""]
#define OCR_FOLDER_NAME             @"ocr"


typedef NS_ENUM(NSUInteger, HZPDFMargin) {
    HZPDFMargin_none,
    HZPDFMargin_normal,
};

typedef NS_ENUM(NSUInteger, HZPDFQuality) {
    HZPDFQuality_100,
    HZPDFQuality_75,
    HZPDFQuality_50,
    HZPDFQuality_25
};

typedef NS_ENUM(NSUInteger, HZPDFSize) {
    HZPDFSize_autoFit,
    HZPDFSize_A3,
    HZPDFSize_A4,
    HZPDFSize_A5,
    HZPDFSize_B4,
    HZPDFSize_B5,
    HZPDFSize_Executive,
    HZPDFSize_Legal,
    HZPDFSize_Letter,
};


#endif /* HZProjectDefine_h */
