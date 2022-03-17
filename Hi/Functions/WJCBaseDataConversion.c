//
//  WJCBaseDataConversion.c
//  
//
//  Created by apple on 2018/2/11.
//  Copyright © 2018年 apple. All rights reserved.
//

#include "WJCBaseDataConversion.h"


/****************************************************************/
/*change word  to ASCII                                            */
/****************************************************************/
void uint16ToAscii(uint16_t w, Byte *c){
    uint16_t tb;
    
    tb = (w &0x0F) + 0x30;
    if (tb > 0x39) tb+=7;
    c[1] = tb;
    
    tb = ((w >> 4)&0x0F) + 0x30;
    if (tb > 0x39) tb+=7;
    c[0] = tb;
    
    tb = ((w >> 8)&0x0F) + 0x30;
    if (tb > 0x39) tb+=7;
    c[3] = tb;
    
    tb =((w >> 12)&0x0F)+ 0x30;
    if (tb > 0x39) tb+=7;
    c[2] = tb;
}


/****************************************************************/
/*change byte  to ASCII                                            */
/****************************************************************/
void byteToAscii(Byte w, Byte * c){
    Byte tb;
    
    tb = ((w >> 4)&0x0F) + 0x30;
    if (tb > 0x39) tb+=7;
    c[0] = tb;
    
    tb = (w & 0x0F) + 0x30;
    if (tb > 0x39) tb+=7;
    c[1] = tb;
}

/****************************************************************/
/*change ASCII to byte                                            */
/****************************************************************/
Byte asciiToByte(Byte *c)
{
    Byte temp,tp;
    
    temp = c[0] - 0x30;
    if(temp > 0x10)
        temp -= 7;
    
    tp = temp << 4;
    
    temp = c[1] -0x30;
    if(temp > 0x10)
        temp -= 7;
    tp = tp|temp;
    return(tp);
    
}
/****************************************************************/
/*change ASCII to u16                                            */
/****************************************************************/
uint16_t asciiToUint16(Byte *c)
{
    uint16_t temp,tp;
    
    temp = c[0] - 0x30;
    if(temp > 9)
        temp -= 7;
    tp = temp << 4;
    
    temp = c[1] - 0x30;
    if(temp > 9)
        temp -= 7;
    tp = tp|temp;
    
    temp = c[2] - 0x30;
    if(temp > 9)
        temp -= 7;
    tp = tp|(temp<<12);
    
    temp = c[3] - 0x30;
    if(temp > 9)
        temp -= 7;
    tp = tp|(temp<<8);
    return(tp);
}
/****************************************************************/
/*change ASCII to u32                                            */
/****************************************************************/
uint32_t asciiToUint32(Byte *c)
{
    uint32_t temp,tp;
    
    temp = c[0] - 0x30;
    if(temp > 9)
        temp -= 7;
    tp = temp << 4;
    
    temp = c[1] - 0x30;
    if(temp > 9)
        temp -= 7;
    tp = tp|temp;
    
    temp = c[2] - 0x30;
    if(temp > 9)
        temp -= 7;
    tp = tp|(temp<<12);
    
    temp = c[3] - 0x30;
    if(temp > 9)
        temp -= 7;
    tp = tp|(temp<<8);
    
    temp = c[4] - 0x30;
    if(temp > 9)
        temp -= 7;
    tp = tp|(temp<<20);
    
    temp = c[5] - 0x30;
    if(temp > 9)
        temp -= 7;
    tp = tp|(temp<<16);
    
    temp = c[6] - 0x30;
    if(temp > 9)
        temp -= 7;
    tp = tp|(temp<<28);
    
    temp = c[7] - 0x30;
    if(temp > 9)
        temp -= 7;
    tp = tp|(temp<<24);
    return(tp);
}
/****************************************************************/
/*make check code                                                */
/****************************************************************/
Byte makeCheckCode(Byte * rbuf){
    Byte bcc,t;
    t = 1;
    bcc = 0;
    while (1){
        bcc = bcc + (rbuf[t] & 0x00FF);
        if (rbuf[t] == 0x03) break;
        t++;
        if (t>200) break;
    }
    bcc &= 0x00FF;
    //if (bcc < 0x20) bcc += 0x20;
    return (bcc);
}

/****************************************************************/
/*check the check code                                            */
/****************************************************************/
Boolean checkBcc(Byte * rbuf){
    Byte bcc,local_temp;
    int t;
    t = 1;
    bcc = 0;
    while (1){
        bcc = bcc + rbuf[t];
        if(t>1){
            if (rbuf[t] == 0x03) break;
            if(rbuf[t]>0x46||(rbuf[t]>0x39&&rbuf[t]<0x41))
                return(1);
        }
        t++;
        if (t>1000) return (1);
    }
    local_temp = asciiToByte(&rbuf[t+1]);
    bcc &= 0x00FF;
    if (local_temp == bcc) return(0);  /* BCC ist ok */
    return (1);
}
/****************************************************************/
/*check offline channel check code                                            */
/****************************************************************/
Boolean checkOfflineChannelBcc(Byte * rbuf,int length){
    int sum = 0;
    for (int i=0; i<length-2; i++) {
        sum += rbuf[i];
    }
    Byte sumCheck1 = sum & 0x00FF;
    Byte sumCheck2 = (sum >> 8) & 0x00FF;
    if ((rbuf[length-2] == sumCheck1) && (rbuf[length-1] == sumCheck2)) {
        return 1;
    } else {
        return 0;
    }
    
}


