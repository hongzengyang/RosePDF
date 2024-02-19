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


typedef NS_ENUM(NSUInteger, HZPDFSize) {
    HZPDFSize_auto = 0,
    HZPDFSize_A4,
    HZPDFSize_A3,
};


#endif /* HZProjectDefine_h */
