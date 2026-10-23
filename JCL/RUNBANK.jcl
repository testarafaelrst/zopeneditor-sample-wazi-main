//BANKTRXR JOB ,NOTIFY=&SYSUID,
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
//* RUN BANKTRX - ASSUMES LOAD MODULE ALREADY EXISTS IN LOAD LIBRARY
//*
//*****************************************************************
//    SET HLQ='RAFAELT'                       *TSO USER ID
//*
//***************************
//*                         *
//*  RUN BANKTRX            *
//*                         *
//***************************
//RUNBANK  EXEC PGM=BANKTRX
//STEPLIB  DD DISP=SHR,DSN=&HLQ..SAMPLE.LOAD
//SYSOUT   DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//*
