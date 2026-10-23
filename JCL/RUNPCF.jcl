//PCFRUN  JOB ,NOTIFY=&SYSUID,
// MSGCLASS=H,MSGLEVEL=(1,1),REGION=144M
//*****************************************************************
//* LICENSED MATERIALS - PROPERTY OF IBM
//* "RESTRICTED MATERIALS OF IBM"
//* (C) COPYRIGHT IBM CORPORATION 2026. ALL RIGHTS RESERVED
//*
//*  US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
//*  OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
//*  CONTRACT WITH IBM CORPORATION
//*
//*****************************************************************
//*
//* RUN PCFDEMO - ASSUMES LOAD MODULE ALREADY EXISTS IN LOAD LIBRARY
//*
//*****************************************************************
//    SET HLQ='RAFAELT'                       *TSO USER ID
//    SET RUNLIB='IDZEE.ZEE.SFELLOAD'         *EDT RUNTIME LOADLIB
//*
//***************************
//*                         *
//*  RUN PCFDEMO            *
//*                         *
//***************************
//RUNPCF   EXEC PGM=PCFDEMO
//STEPLIB  DD DISP=SHR,DSN=&HLQ..SAMPLE.LOAD
//         DD DISP=SHR,DSN=&RUNLIB
//BZUCFG   DD DISP=SHR,DSN=&HLQ..TAZ.EDT.EQACFG
//BZUPLAY  DD DISP=SHR,DSN=&HLQ..TAZ.EDT.RECORD
//CEEOPTS  DD *
TEST(,,,DBRMUI:*)
ENVAR("BZU_PLAYBACK=RECORD")
/*
//SYSOUT   DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//*
