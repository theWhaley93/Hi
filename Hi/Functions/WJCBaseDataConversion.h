//
//  WJCBaseDataConversion.h
//  
//
//  Created by apple on 2018/2/11.
//  Copyright © 2018年 apple. All rights reserved.
//

#ifndef WJCBaseDataConversion_h
#define WJCBaseDataConversion_h

#include <stdio.h>
#include <MacTypes.h>

void uint16ToAscii(uint16_t w, Byte *c);
void byteToAscii(Byte w, Byte * c);
uint16_t asciiToUint16(Byte *c);
uint32_t asciiToUint32(Byte *c);
Byte asciiToByte(Byte *c);
Byte makeCheckCode(Byte * rbuf);
Boolean checkBcc(Byte * rbuf);
Boolean checkOfflineChannelBcc(Byte * rbuf,int length);


#endif /* WJCBaseDataConversion_h */
