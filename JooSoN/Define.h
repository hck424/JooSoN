//
//  Define.h
//  JooSoN
//
//  Created by 김학철 on 2020/09/18.
//  Copyright © 2020 김학철. All rights reserved.
//

#ifndef Define_h
#define Define_h

typedef enum : NSInteger {
    MapCellActionDefault = 0,
    MapCellActionNfc,
    MapCellActionNavi,
    MapCellActionSave,
    MapCellActionShare,
    MapCellActionPhone
} MapCellAction;
typedef enum : NSInteger {
    BottomPopupTypeMapSearch = 0,
} BottomPopupType;

#endif /* Define_h */
