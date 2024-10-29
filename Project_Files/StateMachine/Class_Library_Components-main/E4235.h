#ifndef E4235_H
#define E4235_H

#include <stdint.h>

extern int E4235_WhatAmI(void);
extern int E4235_KYBdeblock(int state);
extern void E4235_delaySec(int time);
extern void E4235_delayMili(int time);
extern void E4235_delayNano(int time);
extern void E4235_delayMicro(int time);
extern void E4235_delayCenti(int time);
extern void E4235_delayMin(int time);
extern int E4235_Write(int GPIO, int value);
extern int E4235_Read(int GPIO);
extern void E4235_Select(int GPIO, int value);
extern int E4235_PWM_SET(int GPIO, int FREQ, int DUTY);
extern int E4235_PWM_Enable(int GPIO, int enable);
extern uint16_t E4235_multiread(int[], int);
extern void E4235_multiwrite(int[], int, uint16_t);

#endif
