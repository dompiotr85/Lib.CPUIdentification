{===============================================================================

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

===============================================================================}

{-------------------------------------------------------------------------------
 Lib.CPUIdentification

 Small library designed to provide some basic parsed information (mainly CPU
 features) obtained by Processor Supplementary Instruction called CPUID on
 x86(-64) processors. Should be compatible with any Windows and Linux system
 running on x86(-64) architecture.

 Version 0.1.3

 Copyright (c) 2018-2021, Piotr Domañski

 Last change:
   11-01-2021

 Changelog:
   For detailed changelog and history please refer to this git repository:
     https://github.com/dompiotr85/Lib.CPUIdentification

 Contacts:
   Piotr Domañski (dom.piotr.85@gmail.com)

 Dependencies:
   - JEDI common files (https://github.com/project-jedi/jedi)
   - Lib.TypeDefinitions (https://github.com/dompiotr85/Lib.TypeDefinitions)
   - Lib.BasicClasses (https://github.com/dompiotr85/Lib.BasicClasses)

 Sources:
   - https://en.wikipedia.org/wiki/CPUID
   - http://sandpile.org/x86/cpuid.htm
   - Intel® 64 and IA-32 Architectures Software Developer’s Manual (September
     2016)
   - AMD CPUID Specification; Publication #25481 Revision 2.34 (September 2010)
-------------------------------------------------------------------------------}

{$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
/// <summary>
///   Small library designed to provide some basic parsed information (mainly
///   CPU features) obtained by Processor Supplementary Instruction called CPUID
///   on x86(-64) processors. Should be compatible with any Windows and Linux
///   system running on x86(-64) architecture.
/// </summary>
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
unit CPUIdentification;

{$INCLUDE jedi\jedi.inc}

{$IFDEF SUPPORTS_LEGACYIFEND}{$LEGACYIFEND ON}{$ENDIF}

{$IFDEF CID_PurePascal}
 {$DEFINE PurePascal}
{$ENDIF !CID_PurePascal}

{$IF DEFINED(CPUX86_64) OR DEFINED(CPUX64)}
 {$DEFINE x64}
{$ELSEIF DEFINED(CPU386)}
 {$DEFINE x86}
{$ELSE}
 {$MESSAGE FATAL 'Unsupported CPU!'}
{$IFEND}

{$IF DEFINED(WINDOWS) OR DEFINED(MSWINDOWS)}
 {$DEFINE Windows}
{$ELSEIF DEFINED(LINUX) AND DEFINED(FPC)}
 {$DEFINE Linux}
{$ELSE}
 {$MESSAGE FATAL 'Unsupported operating system!'}
{$IFEND}

{$IFDEF FPC}
 {.$MODE ObjFPC}
 {$INLINE ON}
 {$DEFINE CanInline}
 {$ASMMODE Intel}
 {$DEFINE FPC_DisableWarns}
 {$MACRO ON}
{$ELSE !FPC}
 {$IF CompilerVersion >= 17}  // Delphi 2005+
  {$DEFINE CanInline}
 {$ELSE}
  {$UNDEF CanInline}
 {$IFEND}
{$ENDIF !FPC}

{$H+}
{$M+}

{$IFDEF PurePascal}
 {$MESSAGE WARN 'This unit cannot be compiled without ASM!'}
{$ENDIF !PurePascal}

interface

uses
  {$IFDEF HAS_UNITSCOPE}System.SysUtils{$ELSE}SysUtils{$ENDIF},
  TypeDefinitions,
  BasicClasses;

{$IFDEF SUPPORTS_REGION}{$REGION 'CPUIdentification exceptions'}{$ENDIF}
type
  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   CPUIdentification exception used in this unit.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  ECIDException = class(Exception);

  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   CPUIdentification System Error exception.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  ECIDSystemError = class(ECIDException);

  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   CPUIdentification Index Out Of Bounds exception.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  ECIDIndexOutOfBounds = class(ECIDException);
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{- TCPUIdentification  - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'CPUIdentification types definition'}{$ENDIF}
type
 {$IFDEF SUPPORTS_REGION}{$REGION 'TCPUIDResult definition'}{$ENDIF}
  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   Pointer to <see cref="CPUIdentification|TCPUIDResult" /> record.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  PCPUIDResult = ^TCPUIDResult;

  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   Record that store EAX, EBX, ECX and EDX registries. It is used as a
  ///   result of CPUID call.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  TCPUIDResult = packed record
    EAX, EBX, ECX, EDX: UInt32;
  end;
 {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

 {$IFDEF SUPPORTS_REGION}{$REGION 'TCPUIDLeaf definition'}{$ENDIF}
  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   Pointer to <see cref="CPUIdentification|TCPUIDLeaf" />
  ///   record.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  PCPUIDLeaf = ^TCPUIDLeaf;

  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   Record describing single CPUID leaf and its sub-leafs.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  TCPUIDLeaf = record
    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   CPUID Leaf ID value.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ID: UInt32;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   CPUID leaf result value as
    ///   <see cref="CPUIdentification|TCPUIDResult" />.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    Data: TCPUIDResult;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Sub-leafs result values as dynamic array of
    ///   <see cref="CPUIdentification|TCPUIDResult" />.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SubLeafs: array of TCPUIDResult;
  end;

  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   List of CPUID leafs as dynamic array of
  ///   <see cref="CPUIdentification|TCPUIDLeaf" />.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  TCPUIDLeafs = array of TCPUIDLeaf;

const
  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   NullLeaf is <see cref="CPUIdentification|TCPUIDResult" /> constant that
  ///   hold 0 value for its all fields.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  NullLeaf: TCPUIDResult = (EAX: 0; EBX: 0; ECX: 0; EDX: 0);
 {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

type
 {$IFDEF SUPPORTS_REGION}{$REGION 'TCPUIDManufacturerID definition'}{$ENDIF}
  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   Enumeration of known CPUID manufacturer ID.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  TCPUIDManufacturerID = (
    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Other (unknown) manufacturer.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnOthers,

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Advanced Micro Devices.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnAMD,

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Centaur Technology.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnCentaur,

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Cyrix Corporation.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnCyrix,

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Intel Corporation.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnIntel,

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Transmeta Corporation.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnTransmeta,

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   National Semiconductor.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnNationalSemiconductor,

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   NexGen.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnNexGen,

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Rise Corporation.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnRise,

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Silicon Integrated Systems.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnSiS,

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   United Microelectronics Corporation.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnUMC,

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   VIA Technologies.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnVIA,

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Vortex.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    mnVortex);
 {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

 {$IFDEF SUPPORTS_REGION}{$REGION 'TCPUIDInfo_AdditionalInfo definition'}{$ENDIF}
  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   CPUID additional information record. It holds additional fields like
  ///   Brand ID, Cache Line Flush Size, Logical Processor Count and
  ///   Local APIC ID.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  TCPUIDInfo_AdditionalInfo = record
    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Brand ID.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    BrandID: Byte;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   CLFLUSH size.
    /// </summary>
    /// <remarks>
    ///   Size in bytes (raw data is in qwords).
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CacheLineFlushSize: Word;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Maximum number of addressable IDs for logical processors in this
    ///   physical package.
    /// </summary>
    /// <remarks>
    ///   HTT (see features) must be on, otherwise reserved.
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    LogicalProcessorCount: Byte;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Initial APIC ID.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    LocalAPICID: Byte;
  end;
 {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

 {$IFDEF SUPPORTS_REGION}{$REGION 'TCPUIDInfo_Features definition'}{$ENDIF}
  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   CPUID features record.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  TCPUIDInfo_Features = record
    {- Leaf 1, ECX register  - - - - - - - - - - - - - - - - - - - - - - - - - }

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///  [00] Streaming SIMD Extensions 3 Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSE3: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [01] Carryless Multiplication.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PCLMULQDQ: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [02] 64-bit Debug Store Area.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    DTES64: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [03] MONITOR and MWAIT Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MONITOR: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [04] CPL Qualified Debug Store.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    DS_CPL: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [05] Virtual Machine Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    VMX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [06] Safer Mode Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SMX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [07] Enhanced Intel SpeedStep® Technology.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    EIST: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [08] Thermal Monitor 2.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    TM2: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [09] Supplemental Streaming SIMD Extension 3 Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSSE3: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [10] L1 Context ID.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CNXT_ID: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [11] Silicon Debug interface.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SDBG: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [12] Fused Multiply Add.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    FMA: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [13] CMPXCHG16B Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CMPXCHG16B: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [14] Update Control (Can disable sending task priority messages).
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    xTPR: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [15] Perform & Debug Capability MSR.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PDCM: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [17] Process-context Identifiers.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PCID: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [18] Direct Cache Access.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    DCA: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [19] Streaming SIMD Extensions 4.1 Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSE4_1: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [20] Streaming SIMD Extensions 4.2 Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSE4_2: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [21] x2APIC Support.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    x2APIC: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [22] MOVBE Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MOVBE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [23] POPCNT Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    POPCNT: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [24] APIC supports one-shot operation using a TSC deadline value.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    TSC_Deadline: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [25] AES Instruction Set.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AES: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [26] XSAVE, XRESTOR, XSETBV, XGETBV Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    XSAVE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [27] XSAVE enabled by OS.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    OSXSAVE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [28] Advanced Vector Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [29] F16C (half-precision) FP Support.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    F16C: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [30] RDRAND (on-chip random number generator) Support.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    RDRAND: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [31] Running on a hypervisor (always 0 on a real CPU).
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    HYPERVISOR: Boolean;

    {- Leaf 1, EDX register  - - - - - - - - - - - - - - - - - - - - - - - - - }

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [00] x87 FPU on chip.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    FPU: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [01] Virtual-8086 Mode Enhancement.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    VME: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [02] Debugging Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    DE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [03] Page Size Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PSE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [04] Time Stamp Counter.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    TSC: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [05] RDMSR and WRMSR Support.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MSR: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [06] Physical Address Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PAE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [07] Machine Check Exception.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MCE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [08] CMPXCHG8B Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CX8: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [09] APIC on chip.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    APIC: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [11] SYSENTER and SYSEXIT Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SEP: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [12] Memory Type Range Registers.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MTRR: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [13] PTE Global Bit.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PGE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [14] Machine Check Architecture.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MCA: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [15] Conditional Move/Compare Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CMOV: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [16] Page Attribute Table.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PAT: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [17] Page Size Extension.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PSE_36: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [18] Processor Serial Number.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PSN: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [19] CLFLUSH Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CLFSH: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [21] Debug Store.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    DS: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [22] Thermal Monitor and Clock Control.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ACPI: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [23] MMX Technology.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MMX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [24] FXSAVE/FXRSTOR Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    FXSR: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [25] Streaming SIMD Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [26] Streaming SIMD Extensions 2.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSE2: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [27] Self Snoop.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SS: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [28] Hyper-Threading Technology.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    HTT: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [29] Thermal Monitor.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    TM: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [30] IA64 processor emulating x86.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    IA64: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [31] Pending Break Enable.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PBE: Boolean;

    {- Leaf 7:0, EBX register  - - - - - - - - - - - - - - - - - - - - - - - - }

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [00] RDFSBASE/RDGSBASE/WRFSBASE/WRGSBASE Support.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    FSGSBASE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [01] IA32_TSC_ADJUST MSR Support.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    TSC_ADJUST: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [02] Intel Software Guard Extensions (Intel SGX Extensions).
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SGX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [03] Bit Manipulation Instruction Set 1.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    BMI1: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [04] Transactional Sunchronization Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    HLE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [05] Advanced Vector Extensions 2.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX2: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [06] x87 FPU Data Pointer updated only on x87 exceptions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    FPDP: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [07] Supervisor-Mode Execution Prevention.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SMEP: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [08] Bit Manipulation Instruction Set 2.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    BMI2: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [09] Enhanced REP MOVSB/STOSB.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ERMS: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [10] INVPCID Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    INVPCID: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [11] Transactional Synchronization Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    RTM: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [12] Platform Quality of Service Monitoring.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PQM: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [13] FPU CS and FPU DS deprecated.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    FPCSDS: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [14] Intel MPX (Memory Protection Extensions).
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MPX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [15] Platform Quality of Service Enforcement.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PQE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [16] AVX-512 Foundation.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512F: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [17] AVX-512 Doubleword and Quadword Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512DQ: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [18] RDSEED Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    RDSEED: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [19] Intel ADX (Multi-Precision Add-Carry Instruction Extensions).
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ADX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [20] Supervisor Mode Access Prevention.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SMAP: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [21] AVX-512 Integer Fused Multiply-Add Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512IFMA: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [22] PCOMMIT Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PCOMMIT: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [23] CLFLUSHOPT Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CLFLUSHOPT: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [24] CLWB Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CLWB: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [25] Intel Processor Trace.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PT: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [26] AVX-512 Prefetch Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512PF: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [27] AVX-512 Exponential and Reciprocal Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512ER: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [28] AVX-512 Conflict Detection Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512CD: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [29] Intel SHA Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SHA: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///  [30] AVX-512 Byte and Word Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512BW: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [31] AVX-512 Vector Length Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512VL: Boolean;

    {- Leaf 7:0, ECX register  - - - - - - - - - - - - - - - - - - - - - - - - }

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [00] PREFETCHWT1 Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PREFETCHWT1: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [01] AVX-512 Vector Bit Manipulation Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512VBMI: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [02] User-Mode Instruction Prevention.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    UMIP: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [03] Memory Protection Keys for User-Mode Pages.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PKU: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [04] PKU enabled by OS.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    OSPKE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [07] ??? (http://sandpile.org/x86/cpuid.htm)
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CET: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [16] 5-level paging, CR4.VA57.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    VA57: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [17..21] The value of MAWAU (User MPX (Memory Protection Extensions)
    ///   address-width adjust) used by the BNDLDX and BNDSTX instructions in
    ///   64-bit mode.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MAWAU: Byte;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [22] Read Processor ID.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    RDPID: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [30] SGX Launch Configuration.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SGX_LC: Boolean;

    {- Leaf 7:0, EDX register  - - - - - - - - - - - - - - - - - - - - - - - - }

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [02] AVX-512 Neural Network Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512QVNNIW: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [03] AVX-512 Multiply Accumulation Single precision.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512QFMA: Boolean;
  end;
 {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

 {$IFDEF SUPPORTS_REGION}{$REGION 'TCPUIDInfo_ExtendedFeatures definition'}{$ENDIF}
  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   CPUID extended features record.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  TCPUIDInfo_ExtendedFeatures = record
    {- Leaf $80000001, ECX register  - - - - - - - - - - - - - - - - - - - - - }

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [00] LAHF/SAHF available in 64-bit mode.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AHF64: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [01] Hyperthreading not valid (HTT=1 indicated HTT(0) or CMP(1)).
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CMP: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [02] Secure Virtual Machine.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SVM: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [03] Extended APIC space.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    EAS: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [04] CR8 in 32-bit mode.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CR8D: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [05] Advanced bit manipulation (lzcnt and popcnt).
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    LZCNT: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [05] Equal to LZCNT.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ABM: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [06] Streaming SIMD Extensions 4a.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSE4A: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [07] Misaligned SSE mode.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MSSE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [08] PREFETCH and PREFETCHW Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    _3DNowP: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [09] OS Visible Workaround.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    OSVW: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [10] Instruction Based Sampling.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    IBS: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [11] XOP Instruction Set.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    XOP: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [12] SKINIT/STGI Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SKINIT: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [13] Watchdog timer.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    WDT: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [15] Light Weight Profiling.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    LWP: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [16] 4 operands fused multiply-add.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    FMA4: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [17] Translation Cache Extension.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    TCE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [19] NodeID MSR.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    NODEID: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [21] Trailing Bit Manipulation.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    TBM: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [22] Topology Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    TOPX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [23] Core Performance Counter Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PCX_CORE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [24] NB Performance Counter Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PCX_NB: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [26] Data Breakpoint Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    DBX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [27] Performance TSC.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PERFTSC: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [28] L2I Performance Counter Extensions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PCX_L2I: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [29] MONITORX/MWAITX Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MON: Boolean;

    {- Leaf $80000001, EDX register  - - - - - - - - - - - - - - - - - - - - - }

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [00] Onboard x87 FPU.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    FPU: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [01] Virtual Mode Extensions (VIF).
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    VME: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [02] Debugging Extensions (CR4 bit 3).
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    DE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [03] Page Size Extension.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PSE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [04] Time Stamp Counter.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    TSC: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [05] Model-Specific Registers.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MSR: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [06] Physical Address Extension.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PAE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [07] Machine Check Exception.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MCE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [08] CMPXCHG8 (compare-and-swap) Instruction.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CX8: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [09] Onboard Advanced Programmable Interrupt Controller.
    /// </summary>
    /// <remarks>
    ///   If the APIC has been disabled, then the APIC feature flag will read as
    ///   0.
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    APIC: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [11] SYSCALL and SYSRET Instructions.
    /// </summary>
    /// <remarks>
    ///   The AMD K6 processor, model 6, uses bit 10 to indicate SEP. Beggining
    ///   with model 7, bit 11 is used instead. Intel processors only report SEP
    ///   when CPUID is executed in PM64.
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SEP: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [12] Memory Type Range Registers.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MTRR: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [13] Page Global Enable bit in CR4.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PGE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [14] Machine check architecture.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MCA: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [15] Conditional Move and FCMOV Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CMOV: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [16] Page Attribute Table.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PAT: Boolean;

    (*
    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [16] ??? (http://sandpile.org/x86/cpuid.htm)
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    FCMOV: Boolean;
    *)

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [17] 36-bit Page Size Extension.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PSE36: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [19] Multiprocessor Capable.
    /// </summary>
    /// <remarks>
    ///   AMD K7 processors prior to CPUID=0662h may report 0 even if they are
    ///   MP-capable.
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MP: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [20] Execute Disable Bit available.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    NX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [22] Extended MMX (AMD specific, MMX-SSE and SSE-MEM).
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MMXExt: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [23] MMX Instructions.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MMX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [24] FXSAVE, FXRSTOR Instructions, CR4 bit 9.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    FXSR: Boolean;

    (*
    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [24] Extended MMX (Cyrix specific).
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MMXExt: Boolean;
    *)

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [25] FXSAVE/FXRSTOR Optimisations.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    FFXSR: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [26] 1-GByte Pages are available.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PG1G: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [27] RDTSCP and IA32_TSC_AUX are available.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    TSCP: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [29] AMD64/EM64T, Long Mode.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    LM: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [30] Extended 3DNow!
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    _3DNowExt: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   [31] 3DNow!
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    _3DNow: Boolean;
  end;
 {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

 {$IFDEF SUPPORTS_REGION}{$REGION 'TCPUIDInfo_SupportedExtensions definition'}{$ENDIF}
  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   CPUID supported extensions record.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  TCPUIDInfo_SupportedExtensions = record
    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   x87 FPU.
    /// </summary>
    /// <remarks>
    ///   Features.FPU
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    X87: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   x87 is emulated.
    /// </summary>
    /// <remarks>
    ///   CR0[EM:2]=1
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    EmulatedX87: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   MMX Technology.
    /// </summary>
    /// <remarks>
    ///   Features.MMX and CR0[EM:2]=0
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    MMX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Streaming SIMD Extensions.
    /// </summary>
    /// <remarks>
    ///   Features.SSE
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSE: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Streaming SIMD Extensions 2.
    /// </summary>
    /// <remarks>
    ///   Features.SSE2 and SSE.
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSE2: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Streaming SIMD Extensions 3.
    /// </summary>
    /// <remarks>
    ///   Features.SSE3 and SSE2.
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSE3: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Supplemental Streaming SIMD Extensions 3.
    /// </summary>
    /// <remarks>
    ///   Features.SSSE3 and SSE3.
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSSE3: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Streaming SIMD Extensions 4.1.
    /// </summary>
    /// <remarks>
    ///   Features.SSE4_1 and SSSE3
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSE4_1: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Streaming SIMD Extensions 4.2
    /// </summary>
    /// <remarks>
    ///   Features.SSE4_2 and SSE4_1
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SSE4_2: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   CRC32 Instruction.
    /// </summary>
    /// <remarks>
    ///   SSE4_2
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    CRC32: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   POPCNT Instruction.
    /// </summary>
    /// <remarks>
    ///   Features.POPCNT and SSE4_2
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    POPCNT: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   AES New Instructions.
    /// </summary>
    /// <remarks>
    ///   Features.AES and SSE2
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AES: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   PCLMULQDQ Instruction.
    /// </summary>
    /// <remarks>
    ///   Features.AES and SSE2
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    PCLMULQDQ: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Advanced Vector Extensions.
    /// </summary>
    /// <remarks>
    ///   Features.OSXSAVE -> XCR0[1..2]=11b and Features.AVX
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   16-bit Float Conversion Instructions.
    /// </summary>
    /// <remarks>
    ///   Features.F16C and AVX
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    F16C: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Fused-Multiply-Add Instructions.
    /// </summary>
    /// <remarks>
    ///   Features.FMA and AVX
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    FMA: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Advanced Vector Extensions 2.
    /// </summary>
    /// <remarks>
    ///   Features.AVX2 and AVX
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX2: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   AVX-512 Foundation Instructions.
    /// </summary>
    /// <remarks>
    ///   Features.OSXSAVE -> XCR0[1..2]=11b and XCR0[5..7]=111b and
    ///   Features.AVX512F
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512F: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   AVX-512 Exponential and Reciprocal Instructions.
    /// </summary>
    /// <remarks>
    ///   Features.AVX512ER and AVX512F
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512ER: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   AVX-512 Prefetch Instructions.
    /// </summary>
    /// <remarks>
    ///   Features.AVX512PF and AVX512F
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512PF: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   AVX-512 Conflict Detection Instructions.
    /// </summary>
    /// <remarks>
    ///   Features.AVX512CD and AVX512F
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512CD: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   AVX-512 Doubleword and Quadword Instructions.
    /// </summary>
    /// <remarks>
    ///   Features.AVX512DQ and AVX512F
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512DQ: Boolean;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   AVX-512 Byte and Word Instructions.
    /// </summary>
    /// <remarks>
    ///   Features.AVX512BW and AVX512F
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AVX512BW: Boolean;
  end;
 {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

 {$IFDEF SUPPORTS_REGION}{$REGION 'TCPUIDInfo definition'}{$ENDIF}
  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   CPUID information record.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  TCPUIDInfo = record
    {- Leaf 0x00000000 - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Manufacturer ID enumeration.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ManufacturerID: TCPUIDManufacturerID;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Manufacturer ID string.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ManufacturerIDString: String;

    {- Leaf 0x00000001 - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Processor type.
    /// </summary>
    /// <remarks>
    ///   It can holds this values:
    ///   <list type="bullet">
    ///     <item>
    ///       0 - Primary processor,
    ///     </item>
    ///     <item>
    ///       1 - Overdrive processor,
    ///     </item>
    ///     <item>
    ///       2 - Secondary processor (for MP),
    ///     </item>
    ///     <item>
    ///       3 - Reserved.
    ///     </item>
    ///   </list>
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ProcessorType: Byte;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Processor family.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ProcessorFamily: Byte;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Processor model.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ProcessorModel: Byte;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Processor stepping.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ProcessorStepping: Byte;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Additional information.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    AdditionalInfo: TCPUIDInfo_AdditionalInfo;

    {- Leaf 0x00000001 and 0x00000007  - - - - - - - - - - - - - - - - - - - - }

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Processor features.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ProcessorFeatures: TCPUIDInfo_Features;

    {- Leaf 0x80000001 - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Extended processor features.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    ExtendedProcessorFeatures: TCPUIDInfo_ExtendedFeatures;

    {- Leaf 0x80000002 - 0x80000004  - - - - - - - - - - - - - - - - - - - - - }

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Processor brand string.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    BrandString: String;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Some processor extensions whose full support can not (or should not)
    ///   be determined directly from processor features.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    SupportedExtensions: TCPUIDInfo_SupportedExtensions;
  end;
 {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

 {$IFDEF SUPPORTS_REGION}{$REGION 'TFreqInfo definition'}{$ENDIF}
  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   Processor frequency information.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  TFreqInfo = record
    RawFreq: Int64;
    NormFreq: Int64;
    InCycles: Int64;
    ExTicks: Int64;
  end;
 {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

  {- TCPUIdentification - class definition - - - - - - - - - - - - - - - - - - }
  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'TCPUIdentification - class definition'}{$ENDIF}
  {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
  /// <summary>
  ///   Basic class holding logic of the processor discovering. It allows to
  ///   discover details related to the processor using processor supplementary
  ///   instruction called CPUID. It can work for both x86 and x64
  ///   architectures.
  /// </summary>
  {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
  TCPUIdentification = class(TCustomObject)
  private
    FIncUnsuppLeafs: Boolean;
    FSupported: Boolean;
    FLeafs: TCPUIDLeafs;
    FInfo: TCPUIDInfo;
    FHighestStdLeaf: TCPUIDResult;

    function GetLeafCount: SizeUInt;
    function GetLeaf(Index: SizeUInt): TCPUIDLeaf;
  protected
    { Only for internal use. }
    procedure DeleteLeaf(Index: SizeUInt); virtual;
    procedure InitLeafs(Mask: UInt32); virtual;

    { Standard leafs. }
    procedure InitStdLeafs; virtual;

    procedure ProcessLeaf_0000_0000; virtual;
    procedure ProcessLeaf_0000_0001; virtual;
    procedure ProcessLeaf_0000_0002; virtual;
    procedure ProcessLeaf_0000_0004; virtual;
    procedure ProcessLeaf_0000_0007; virtual;
    procedure ProcessLeaf_0000_000B; virtual;
    procedure ProcessLeaf_0000_000D; virtual;
    procedure ProcessLeaf_0000_000F; virtual;
    procedure ProcessLeaf_0000_0010; virtual;
    procedure ProcessLeaf_0000_0012; virtual;
    procedure ProcessLeaf_0000_0014; virtual;
    procedure ProcessLeaf_0000_0017; virtual;

    { Intel Xeon Phi leafs. }
    procedure InitPhiLeafs; virtual;

    { Hypervisor leafs. }
    procedure InitHypLeafs; virtual;

    { Extended leafs. }
    procedure InitExtLeafs; virtual;

    procedure ProcessLeaf_8000_0001; virtual;
    procedure ProcessLeaf_8000_0002_to_8000_0004; virtual;
    procedure ProcessLeaf_8000_001D; virtual;

    { Transmeta leafs. }
    procedure InitTNMLeafs; virtual;

    { Centaur leafs. }
    procedure InitCNTLeafs; virtual;

    procedure InitSupportedExtensions; virtual;
    function EqualsToHighestStdLeaf(Leaf: TCPUIDResult): Boolean; virtual;

    class function SameLeafs(A, B: TCPUIDResult): Boolean; virtual;
  public
    constructor Create(DoInitialize: Boolean = True; IncUnsupportedLeafs: Boolean = True);
    destructor Destroy; override;

    procedure Initialize; virtual;
    procedure Finalize; virtual;
    function IndexOf(LeafID: UInt32): SizeInt; virtual;

    property Info: TCPUIDInfo read FInfo;
    property Leafs[Index: SizeUInt]: TCPUIDLeaf read GetLeaf; default;
    property IncludeUnsupportedLeafs: Boolean read FIncUnsuppLeafs write FIncUnsuppLeafs;
    property Supported: Boolean read FSupported;
    property Count: SizeUInt read GetLeafCount;
  end;
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

  {- TCPUIdentificationEx - class definition - - - - - - - - - - - - - - - - - }
  {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'TCPUIdentificationEx - class definition'}{$ENDIF}
  TCPUIdentificationEx = class(TCPUIdentification)
  private
    FProcessorID: SizeUInt;
    FPhysicalCoreCount: SizeUInt;
    FLogicalCoreCount: SizeUInt;
    FFrequencyInfo: TFreqInfo;
  protected
    class function SetThreadAffinity(ProcessorMask: PtrUInt): PtrUInt; virtual;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Returns total number of processors available to system including
    ///   logical hyperthreaded processors.
    /// </summary>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    function AvailableProcessorCount: SizeUInt;

    {$IFDEF SUPPORTS_REGION}{$REGION 'Documentation'}{$ENDIF}
    /// <summary>
    ///   Returns total number of processors available to system excluding
    ///   logical hyperthreaded processors.
    /// </summary>
    /// <remarks>
    ///   We only have to do significant work for Intel processors since they
    ///   are the only ones which implement hyperthreading. It's not 100% clear
    ///   wheter the hyperthreading bit (CPUID(1) -> EDX[28]) will be set for
    ///   processors with multiple cores but without hyperthreading. My reading
    ///   of the documentation is that it will be set but the code is
    ///   conservative and performs the APIC ID decoding if either:
    ///   <list type="bullet">
    ///     <item>
    ///       The hyperthreading bit is set, or
    ///     </item>
    ///     <item>
    ///       The processor reports >1 cores on the physical package.
    ///     </item>
    ///   </list>
    ///   If either of these conditions hold, then we proceed to read the
    ///   APIC ID for each logical processor recognised by the OS. This ID can
    ///   be decoded to the form (PACKAGE_ID, CORE_ID, LOGICAL_ID) where
    ///   PACKAGE_ID identifies the physical processor package, CORE_ID
    ///   identifies a physical core on that package and LOGICAL_ID identifies
    ///   a hyperthreaded processor on that core.
    ///   The job of this routine is therefore to count the number of unique
    ///   cores, that is the number of unique pairs (PACKAGE_ID, CORE_ID).
    ///   If the chip is not an Intel processor, or if it is Intel but doesn't
    //    have multiple logical processors on a physical package then the
    ///   routine simply returns AvailableProcessorCount.
    /// </remarks>
    {$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}
    function AvailableProcessorCoreCount: SizeUint;
  public
    class function ProcessorAvailable(ProcessorID: SizeUInt): Boolean; virtual;

    constructor Create(ProcessorID: SizeUInt = 0; DoInitialize: Boolean = True; IncUnsupportedLeafs: Boolean = True);

    procedure Initialize; override;

    property ProcessorID: SizeUInt read FProcessorID write FProcessorID;
    property PhysicalCoreCount: SizeUInt read FPhysicalCoreCount;
    property LogicalCoreCount: SizeUInt read FLogicalCoreCount;
    property FreqencyInfo: TFreqInfo read FFrequencyInfo;
  end;
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{- Main CPUID routines - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'General routines'}{$ENDIF}
function CPUIDSupported: LongBool; register; assembler;

procedure CPUID(Leaf, SubLeaf: UInt32; Result: Pointer); register; overload; assembler;
procedure CPUID(Leaf: UInt32; Result: Pointer); overload; {$IFDEF CanInline}inline;{$ENDIF}
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

implementation

uses
{$IFDEF Windows}
  {$IFDEF HAS_UNITSCOPE}Winapi.Windows{$ELSE}Windows{$ENDIF},
{$ELSE !Windows}
  baseunix,
  pthreads,
{$ENDIF !Windows}
{$IF NOT DEFINED(FPC) AND (CompilerVersion >= 20)}  { Delphi 2009+ }
  {$IFDEF HAS_UNITSCOPE}System.AnsiStrings{$ELSE}AnsiStrings{$ENDIF},
{$IFEND}
  {$IFDEF HAS_UNITSCOPE}System.Math{$ELSE}Math{$ENDIF},
  BasicClasses.Lists,
  CPUIdentification.Consts;

{$IFDEF FPC_DisableWarns}
 {$DEFINE FPCDWM}
 {$DEFINE W4055:={$WARN 4055 OFF}} { Conversion between ordinals and pointers is not portable. }
{$ENDIF}

{- Internal routines implementation  - - - - - - - - - - - - - - - - - - - - - }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Internal routines implementation'}{$ENDIF}
{$IFDEF Windows}
function GetProcessAffinityMask(hProcess: THandle; lpProcessAffinityMask, lpSystemAffinityMask: PPtrUInt): BOOL; stdcall; external kernel32;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function IsProcessorFeaturePresent(ProcessorFeature: DWORD): BOOL; stdcall; external kernel32;

 {$IF NOT DECLARED(PF_FLOATING_POINT_EMULATED)}
const
  PF_FLOATING_POINT_EMULATED = 1;
 {$IFEND}
{$ELSE !Windows}
function errno_ptr: pcInt; cdecl; external name '__errno_location';
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function pthread_getaffinity_np(thread: pthread_t; cpusetsize: size_t; cpuset: Pointer): cint; cdecl; external;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function pthread_setaffinity_np(thread: pthread_t; cpusetsize: size_t; cpuset: Pointer): cint; cdecl; external;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function sched_getaffinity(pid: pid_t; cpusetsize: size_t; mask: Pointer): cint; cdecl; external;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function getpid: pid_t; cdecl; external;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure RaiseError(ResultValue: cint; FuncName: String); {$IFDEF CanInline}inline;{$ENDIF}
begin
  if (ResultValue <> 0) then
    raise ECIDSystemError.CreateFmt(SSystemError, [FuncName, ResultValue]);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure RaiseErrorErrNo(ResultValue: cint; FuncName: String); {$IFDEF CanInline}inline;{$ENDIF}
begin
  if (ResultValue <> 0) then
    raise ECIDSystemError.CreateFmt(SSystemError, [FuncName, errno_ptr^]);
end;
{$ENDIF !Windows}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function GetBit(Value: UInt32; Bit: Int32): Boolean; overload; {$IFDEF CanInline}inline;{$ENDIF}
begin
  Result := ((Value shr Bit) and 1) <> 0;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function GetBit(Value: UInt64; Bit: Int32): Boolean; overload; {$IFDEF CanInline}inline;{$ENDIF}
begin
  Result := ((Value shr Bit) and 1) <> 0;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function SetBit(Value: UInt32; Bit: Int32): UInt32; {$IFDEF CanInline}inline;{$ENDIF}
begin
  Result := Value or (UInt32(1) shl Bit);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function GetBits(Value: UInt32; FromBit, ToBit: Int32): UInt32; {$IFDEF CanInline}inline;{$ENDIF}
begin
  Result := (Value and ($FFFFFFFF shr (31 - ToBit))) shr FromBit;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function GetCR0: NativeUInt; assembler; register;
asm
  { CR0 is not accessible in user mode (this function will cause exception).
    If anyone have any idea on how to read CR0 from normal program, let me
    know. }
{$IFDEF x64}
  DB        $0F, $20, $C0   { MOV       RAX, CR0 (problems in FPC before 3.0) }
{$ELSE !x64}
  MOV       EAX, CR0
{$ENDIF !x64}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function GetXCR0L: UInt32; assembler; register;
asm
  XOR       ECX,  ECX

  DB        $0F, $01, $D0 { XGETBV (XCR0.Low -> EAX (result), XCR0.Hi -> EDX) }
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function ReadTimeStampCounter: Int64; assembler;
asm
  DW        $310F
  { TSC in EDX:EAX }
{$IFDEF x64}
  SHL       RDX, 32
  OR        RAX, RDX
  { Result in RAX }
{$ENDIF !x64}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function RoundFrequency(const Frequency: Integer): Integer;
const
  NF: array[0..8] of Int32 = (0, 20, 33, 50, 60, 66, 80, 90, 100);
var
  Freq, RF: Int32;
  I: UInt8;
  Hi, Lo: UInt8;
begin
  RF := 0;
  Freq := Frequency mod 100;

  for I := 0 to 8 do
  begin
    if (Freq < NF[I]) then
    begin
      Hi := I;
      Lo := I - 1;

      if ((NF[Hi] - Freq) > (Freq - NF[Lo])) then
        RF := NF[Lo] - Freq
      else
        RF := NF[Hi] - Freq;

      Break;
    end;
  end;

  Result := Frequency + RF;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function GetCPUSpeed(var CpuSpeed: TFreqInfo): Boolean;
{$IFDEF UNIX}
begin
  { TODO: GetCPUSpeed: Solution for Linux. }
  Result := False;
end;
{$ENDIF !UNIX}

{$IFDEF MSWINDOWS}
var
  T0, T1: Int64;
  CountFreq: Int64;
  Freq, Freq2, Freq3, Total: Int64;
  TotalCycles, Cycles: Int64;
  Stamp0, Stamp1: Int64;
  TotalTicks, Ticks: Float64;
  Tries, Priority: Int32;
  Thread: THandle;
begin
  Stamp0 := 0;
  Stamp1 := 0;
  Freq := 0;
  Freq2 := 0;
  Freq3 := 0;
  Tries := 0;
  TotalCycles := 0;
  TotalTicks := 0;
  Total := 0;

  Thread := GetCurrentThread;
  CountFreq := 0;
  Result := QueryPerformanceFrequency(CountFreq);

  if (Result) then
  begin
    while ((Tries < 3) or ((Tries < 20) and ((Abs(3 * Freq - Total) > 3) or (Abs(3 * Freq2 - Total) > 3) or (Abs(3 * Freq3 - Total) > 3)))) do
    begin
      Inc(Tries);
      Freq3 := Freq2;
      Freq2 := Freq;
      T0 := 0;
      QueryPerformanceCounter(T0);
      T1 := T0;

      Priority := GetThreadPriority(Thread);

      if (Priority <> THREAD_PRIORITY_ERROR_RETURN) then
        SetThreadPriority(Thread, THREAD_PRIORITY_TIME_CRITICAL);

      try
        while (T1 - T0 < 50) do
        begin
          QueryPerformanceCounter(T1);
          Stamp0 := ReadTimeStampCounter;
        end;

        T0 := T1;

        while (T1 - T0 < 1000) do
        begin
          QueryPerformanceCounter(T1);
          Stamp1 := ReadTimeStampCounter;
        end;
      finally
        if (Priority <> THREAD_PRIORITY_ERROR_RETURN) then
          SetThreadPriority(Thread, Priority);
      end;

      Cycles := Stamp1 - Stamp0;
      Ticks := T1 - T0;
      Ticks := Ticks * 100000;

      { Avoid division by zero. }
      if (CountFreq = 0) then
        Ticks := High(Int64)
      else
        Ticks := Ticks / (CountFreq / 10);

      TotalTicks := TotalTicks + Ticks;
      TotalCycles := TotalCycles + Cycles;

      { Avoid division by zero. }
      if (IsZero(Ticks)) then
        Freq := High(Freq)
      else
        Freq := Round(Cycles / Ticks);

      Total := Freq + Freq2 + Freq3;
    end;

    { Avoid division by zero. }
    if (IsZero(TotalTicks)) then
    begin
      Freq3 := High(Freq3);
      Freq2 := High(Freq2);
      CpuSpeed.RawFreq := High(CpuSpeed.RawFreq);
    end else
      begin
        { Freq. in multiples of 10^5 Hz. }
        Freq3 := Round((TotalCycles *  10) / TotalTicks);
        { Freq. in multiples of 10^4 Hz. }
        Freq2 := Round((TotalCycles * 100) / TotalTicks);

        CpuSpeed.RawFreq := Round(TotalCycles / TotalTicks);
      end;

    CpuSpeed.NormFreq := CpuSpeed.RawFreq;

    if (Freq2 - (Freq3 * 10) >= 6) then
      Inc(Freq3);

    Freq := CpuSpeed.RawFreq * 10;
    if ((Freq3 - Freq) >= 6) then
      Inc(CpuSpeed.NormFreq);

    CpuSpeed.ExTicks := Round(TotalTicks);
    CpuSpeed.InCycles := TotalCycles;

    CpuSpeed.NormFreq := RoundFrequency(CpuSpeed.NormFreq);
    Result := True;
  end;
end;
{$ENDIF !MSWINDOWS}
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{- Main CPUID routines (ASM) implementation  - - - - - - - - - - - - - - - - - }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'Main CPUID routines (ASM) implementation'}{$ENDIF}
function CPUIDSupported: LongBool;
const
  EFLAGS_BitMask_ID = UInt32($00200000);
asm
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 Result is returned in EAX register (all modes)
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
{$IFDEF x64}
  { Save initial RFLAGS register value. }
  PUSHFQ

  { Save RFLAGS register value again for further use. }
  PUSHFQ
  { Invert ID bit in RFLAGS value stored on stack (bit #21) }
  XOR       qword ptr [RSP], EFLAGS_BitMask_ID
  { Load RFLAGS register from stack (with inverted ID bit). }
  POPFQ

  { Save RFLAGS register to stack (if ID bit can be changed, it is saved as
    inverted, otherwise it has its initial value). }
  PUSHFQ
  { Load saved RFLAGS value to EAX. }
  POP       RAX
  { Get whichever bit has changed in comparison with initial RFLAGS value. }
  XOR       RAX, qword ptr [RSP]
  { Check if ID bit has changed (if not => CPUID instruction not supported). }
  AND       RAX, EFLAGS_BitMask_ID

  { Restore initial RFLAGS value. }
  POPFQ
{$ELSE !x64}
  { Save initial EFLAGS register value. }
  PUSHFD

  { Save EFLAGS register value again for further use. }
  PUSHFD
  { Invert ID bit in EFLAGS value stored on stack (bit #21). }
  XOR       dword ptr [ESP], EFLAGS_BitMask_ID
  { Load EFLAGS register from stack (with inverted ID bit). }
  POPFD

  { Save EFLAGS register to stack (if ID bit can be changed, it is saved as
    inverted, otherwise it has its initial value). }
  PUSHFD
  { Load saved EFLAGS value to EAX. }
  POP       EAX
  { Get whichever bit has changed in comparison with initial EFLAGS value. }
  XOR       EAX, dword ptr [ESP]
  { Check if ID bit has changed (if not => CPUID instruction not supported). }
  AND       EAX, EFLAGS_BitMask_ID

  { Restore initial EFLAGS value. }
  POPFD
{$ENDIF !x64}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure CPUID(Leaf, SubLeaf: UInt32; Result: Pointer);
asm
{$IFDEF x64}
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  Register content on enter:

  Win64  Lin64

   ECX    EDI   Leaf of the CPUID info (parameter for CPUID instruction)
   EDX    ESI   SubLeaf of the CPUID info (valid only for some leafs)
    R8    RDX   Address of memory space (at least 16 bytes long) to which
                resulting data (registers EAX, EBX, ECX and EDX, in that order)
                will be copied
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

  { Save non-volatile registers. }
  PUSH      RBX

{$IFDEF Windows}
  { Code for Windows 64-bit. }

  { Move leaf and subleaf id to a proper register. }
  MOV       EAX, ECX
  MOV       ECX, EDX
{$ELSE !Windows}
  { Code for Linux 64-bit. }

  { Copy address of memory storage, so it is available for further use. }
  MOV       R8, RDX

  { Move leaf and subleaf id to a proper register. }
  MOV       EAX, EDI
  MOV       ECX, ESI
{$ENDIF !Windows}

  { Get the info. }
  CPUID

  { Copy resulting registers to a provided memory. }
  MOV       [R8], EAX
  MOV       [R8 + 4], EBX
  MOV       [R8 + 8], ECX
  MOV       [R8 + 12], EDX

  { Restore non-volatile registers. }
  POP       RBX
{$ELSE !x64}
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  Win32, Lin32

  Register content on enter:

    EAX - Leaf of the CPUID info (parameter for CPUID instruction)
    EDX - SubLeaf of the CPUID info (valid only for some leafs)
    ECX - Address of memory space (at least 16 bytes long) to which resulting
          data (registers EAX, EBX, ECX and EDX, in that order) will be copied
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

  { Save non-volatile registers. }
  PUSH      EDI
  PUSH      EBX

  { Copy address of memory storage, so it is available for further use. }
  MOV       EDI, ECX

  { Move subleaf number to ECX register where it is expected. }
  MOV       ECX, EDX

  { Get the info (EAX register already contains the leaf number). }
  CPUID

  { Copy resulting registers to a provided memory. }
  MOV       [EDI], EAX
  MOV       [EDI + 4], EBX
  MOV       [EDI + 8], ECX
  MOV       [EDI + 12], EDX

  { Restore non-volatile registers. }
  POP       EBX
  POP       EDI
{$ENDIF !x64}
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure CPUID(Leaf: UInt32; Result: Pointer);
begin
  CPUID(Leaf, 0, Result);
end;
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{- TCPUIdentification - class implementation - - - - - - - - - - - - - - - - - }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'TCPUIdentification - class implementation'}{$ENDIF}
type
  TManufacturersItem = record
    IDStr: String;
    ID: TCPUIDManufacturerID;
  end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

const
  Manufacturers: array[0..13] of TManufacturersItem = (
    (IDStr: 'AMDisbetter!'; ID: mnAMD),
    (IDStr: 'AuthenticAMD'; ID: mnAMD),
    (IDStr: 'CentaurHauls'; ID: mnCentaur),
    (IDStr: 'CyrixInstead'; ID: mnCyrix),
    (IDStr: 'GenuineIntel'; ID: mnIntel),
    (IDStr: 'TransmetaCPU'; ID: mnTransmeta),
    (IDStr: 'GenuineTMx86'; ID: mnTransmeta),
    (IDStr: 'Geode by NSC'; ID: mnNationalSemiconductor),
    (IDStr: 'NexGenDriven'; ID: mnNexGen),
    (IDStr: 'RiseRiseRise'; ID: mnRise),
    (IDStr: 'SiS SiS SiS '; ID: mnSiS),
    (IDStr: 'UMC UMC UMC '; ID: mnUMC),
    (IDStr: 'VIA VIA VIA '; ID: mnVIA),
    (IDStr: 'Vortex86 SoC'; ID: mnVortex));

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

constructor TCPUIdentification.Create(DoInitialize, IncUnsupportedLeafs: Boolean);
begin
  { (1) Call inherited code. }
  inherited Create;

  { (2) Set FIncUnsuppLeafs. }
  FIncUnsuppLeafs := IncUnsupportedLeafs;

  { (3) If initialization needed, call Initialize. }
  if (DoInitialize) then
    Initialize;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.DeleteLeaf(Index: SizeUInt);
var
  I: SizeUInt;
begin
  if (Index <= SizeUInt(High(FLeafs))) then
  begin
    for I := Index to Pred(High(FLeafs)) do
      FLeafs[I] := FLeafs[I + 1];

    SetLength(FLeafs, Length(FLeafs) - 1);
  end else
    raise ECIDIndexOutOfBounds.CreateFmt(SDeleteLeaf_IndexOutOfBounds, [Index]);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

destructor TCPUIdentification.Destroy;
begin
  { (1) Finalize. }
  Finalize;

  { (2) Call ingerited code. }
  inherited;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function TCPUIdentification.EqualsToHighestStdLeaf(Leaf: TCPUIDResult): Boolean;
begin
  Result := SameLeafs(Leaf, FHighestStdLeaf);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.Finalize;
begin
  SetLength(FLeafs, 0);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function TCPUIdentification.GetLeaf(Index: SizeUInt): TCPUIDLeaf;
begin
  if (Index <= SizeUInt(High(FLeafs))) then
    Result := FLeafs[Index]
  else
    raise ECIDIndexOutOfBounds.CreateFmt(SGetLeaf_IndexOutOfBounds, [Index]);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function TCPUIdentification.GetLeafCount: SizeUInt;
begin
  Result := Length(FLeafs);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function TCPUIdentification.IndexOf(LeafID: UInt32): SizeInt;
var
  I: SizeUInt;
begin
  Result := -1;

  for I := Low(FLeafs) to High(FLeafs) do
    if (FLeafs[I].ID = LeafID) then
    begin
      Result := I;
      Break;
    end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.InitCNTLeafs;
begin
  InitLeafs($C0000000);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.InitExtLeafs;
begin
  InitLeafs($80000000);

  { Process individual leafs. }
  ProcessLeaf_8000_0001;
  ProcessLeaf_8000_0002_to_8000_0004;
  ProcessLeaf_8000_001D;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.InitHypLeafs;

  procedure AddHypLeaf(ID: UInt32);
  var
    Temp: TCPUIDResult;
  begin
    CPUID(ID, Addr(Temp));

    if (not EqualsToHighestStdLeaf(Temp)) then
    begin
      SetLength(FLeafs, Length(FLeafs) + 1);

      FLeafs[High(FLeafs)].ID := ID;
      FLeafs[High(FLeafs)].Data := Temp;
    end;
  end;

begin
  if (FInfo.ProcessorFeatures.HYPERVISOR) then
  begin
    AddHypLeaf($40000000);
    AddHypLeaf($40000001);
    AddHypLeaf($40000002);
    AddHypLeaf($40000003);
    AddHypLeaf($40000004);
    AddHypLeaf($40000005);
    AddHypLeaf($40000006);
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.Initialize;
var
  I: SizeUInt;
begin
  { (1) Set length of FLeafs to 0. }
  SetLength(FLeafs, 0);

  { (2) Store CPUID support flag in FSupported. }
  FSupported := CPUIdentification.CPUIDSupported;

  { (3) If FSupported is True, initialize all leafs. }
  if (FSupported) then
  begin
    InitStdLeafs;
    InitPhiLeafs;
    InitHypLeafs;
    InitExtLeafs;
    InitTNMLeafs;
    InitCNTLeafs;
  end;

  { (4.1) If unsupported leafs should be included, then: }
  if (not FIncUnsuppLeafs) then
    { (4.2) Itterate throu all leafs (downward) and ... }
    for I := High(FLeafs) downto Low(FLeafs) do
      { (4.3) ... if current leaf data is equal to NullLeaf, then delete that
              leaf. }
      if (SameLeafs(FLeafs[I].Data, NullLeaf)) then
        DeleteLeaf(I);

  { (5) Initialize supported extensions. }
  InitSupportedExtensions;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.InitLeafs(Mask: UInt32);
var
  Temp: TCPUIDResult;
  Cnt, I: SizeUInt;
begin
  { Get leaf count. }
  CPUID(Mask, Addr(Temp));
  if (((Temp.EAX and $FFFF0000) = Mask) and (not EqualsToHighestStdLeaf(Temp))) then
  begin
    Cnt := Length(FLeafs);
    SetLength(FLeafs, Length(FLeafs) + Integer(Temp.EAX and not Mask) + 1);

    { Load all leafs. }
    for I := Cnt to High(FLeafs) do
    begin
      FLeafs[I].ID := UInt32(I - Cnt) or Mask;
      CPUID(FLeafs[I].ID, Addr(FLeafs[I].Data));
    end;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.InitPhiLeafs;
begin
  InitLeafs($20000000);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.InitStdLeafs;
begin
  InitLeafs($00000000);
  if (Length(FLeafs) > 0) then
    FHighestStdLeaf := FLeafs[High(FLeafs)].Data
  else
    FillChar(FHighestStdLeaf, SizeOf(FHighestStdLeaf), 0);

  { Process individual leafs. }
  ProcessLeaf_0000_0000;
  ProcessLeaf_0000_0001;
  ProcessLeaf_0000_0002;
  ProcessLeaf_0000_0004;
  ProcessLeaf_0000_0007;
  ProcessLeaf_0000_000B;
  ProcessLeaf_0000_000D;
  ProcessLeaf_0000_000F;
  ProcessLeaf_0000_0010;
  ProcessLeaf_0000_0012;
  ProcessLeaf_0000_0014;
  ProcessLeaf_0000_0017;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.InitSupportedExtensions;
begin
  with FInfo.SupportedExtensions do
  begin
    X87 := FInfo.ProcessorFeatures.FPU;

    {
    EmulatedX87 := GetBit(GetCR0, 2);

    Control registers CR0 is not accesible in user mode, let's use the OS.
    }
{$IFDEF Windows}
    EmulatedX87 := IsProcessorFeaturePresent(PF_FLOATING_POINT_EMULATED);
{$ELSE !Windows}
 {$IFDEF DebugMsgs}{$MESSAGE 'How to get whether FPU is emulated in linux?'}{$ENDIF}
    EmulatedX87 := False;
{$ENDIF !Windows}
    MMX := FInfo.ProcessorFeatures.MMX and not EmulatedX87;
    SSE := FInfo.ProcessorFeatures.SSE;
    SSE2 := FInfo.ProcessorFeatures.SSE2 and SSE;
    SSE3 := FInfo.ProcessorFeatures.SSE3 and SSE2;
    SSSE3 := FInfo.ProcessorFeatures.SSSE3 and SSE3;
    SSE4_1 := FInfo.ProcessorFeatures.SSE4_1 and SSSE3;
    SSE4_2 := FInfo.ProcessorFeatures.SSE4_2 and SSE4_1;
    CRC32 := FInfo.ProcessorFeatures.SSE4_2;
    POPCNT := FInfo.ProcessorFeatures.POPCNT and SSE4_2;
    AES := FInfo.ProcessorFeatures.AES and SSE2;
    PCLMULQDQ := FInfo.ProcessorFeatures.PCLMULQDQ and SSE2;

    if (FInfo.ProcessorFeatures.OSXSAVE) then
      AVX := (GetXCR0L and $6 = $6) and FInfo.ProcessorFeatures.AVX
    else
      AVX := False;

    F16C := FInfo.ProcessorFeatures.F16C and AVX;
    FMA := FInfo.ProcessorFeatures.FMA and AVX;
    AVX2 := FInfo.ProcessorFeatures.AVX2 and AVX;

    if (FInfo.ProcessorFeatures.OSXSAVE) then
      AVX512F := (GetXCR0L and $E6 = $E6) and FInfo.ProcessorFeatures.AVX512F
    else
      AVX512F := False;

    AVX512ER := FInfo.ProcessorFeatures.AVX512ER and AVX512F;
    AVX512PF := FInfo.ProcessorFeatures.AVX512PF and AVX512F;
    AVX512CD := FInfo.ProcessorFeatures.AVX512CD and AVX512F;
    AVX512DQ := FInfo.ProcessorFeatures.AVX512DQ and AVX512F;
    AVX512BW := FInfo.ProcessorFeatures.AVX512BW and AVX512F;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.InitTNMLeafs;
begin
  InitLeafs($80860000);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_0000_0000;
var
  Index: SizeInt;
  Str: AnsiString;
  I: SizeUInt;
begin
  Index := IndexOf($00000000);
  if (Index >= 0) then
  begin
    SetLength(Str, 12);
    Move(FLeafs[Index].Data.EBX, Pointer(PAnsiChar(Str))^, 4);

{$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
    Move(FLeafs[Index].Data.EDX, Pointer(PtrUInt(PAnsiChar(Str)) + 4)^, 4);
    Move(FLeafs[Index].Data.ECX, Pointer(PtrUInt(PAnsiChar(Str)) + 8)^, 4);
{$IFDEF FPCDWM}{$POP}{$ENDIF}

    FInfo.ManufacturerIDString := String(Str);
    FInfo.ManufacturerID := mnOthers;

    for I := Low(Manufacturers) to High(Manufacturers) do
      if (AnsiSameStr(Manufacturers[I].IDStr, FInfo.ManufacturerIDString)) then
        FInfo.ManufacturerID := Manufacturers[I].ID;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_0000_0001;
var
  Index: SizeInt;
begin
  Index := IndexOf($00000001);
  if (Index >= 0) then
  begin
    { Processor type. }
    FInfo.ProcessorType := GetBits(FLeafs[Index].Data.EAX, 12, 13);

    { Processor family. }
    if (GetBits(FLeafs[Index].Data.EAX, 8, 11) <> $F) then
      FInfo.ProcessorFamily := GetBits(FLeafs[Index].Data.EAX, 8, 11)
    else
      FInfo.ProcessorFamily := GetBits(FLeafs[Index].Data.EAX, 8, 11) + GetBits(FLeafs[Index].Data.EAX, 20, 27);

    { Processor model. }
    if (GetBits(FLeafs[Index].Data.EAX, 8, 11) in [$6, $F]) then
      FInfo.ProcessorModel := (GetBits(FLeafs[Index].Data.EAX, 16, 19) shl 4) + GetBits(FLeafs[Index].Data.EAX, 4, 7)
    else
      FInfo.ProcessorModel := GetBits(FLeafs[Index].Data.EAX, 4, 7);

    { Pocessor stepping. }
    FInfo.ProcessorStepping := GetBits(FLeafs[Index].Data.EAX, 0, 3);

    { Additional info. }
    FInfo.AdditionalInfo.BrandID := GetBits(FLeafs[Index].Data.EBX, 0, 7);
    FInfo.AdditionalInfo.CacheLineFlushSize := GetBits(FLeafs[Index].Data.EBX, 8, 15) * 8;
    FInfo.AdditionalInfo.LogicalProcessorCount := GetBits(FLeafs[Index].Data.EBX, 16, 23);
    FInfo.AdditionalInfo.LocalAPICID := GetBits(FLeafs[Index].Data.EBX, 24, 31);

    { Processor features. }
    with FInfo.ProcessorFeatures do
    begin
      { ECX register. }
      SSE3 := GetBit(FLeafs[Index].Data.ECX, 0);
      PCLMULQDQ := GetBit(FLeafs[Index].Data.ECX, 1);
      DTES64 := GetBit(FLeafs[Index].Data.ECX, 2);
      MONITOR := GetBit(FLeafs[Index].Data.ECX, 3);
      DS_CPL := GetBit(FLeafs[Index].Data.ECX, 4);
      VMX := GetBit(FLeafs[Index].Data.ECX, 5);
      SMX := GetBit(FLeafs[Index].Data.ECX, 6);
      EIST := GetBit(FLeafs[Index].Data.ECX, 7);
      TM2 := GetBit(FLeafs[Index].Data.ECX, 8);
      SSSE3 := GetBit(FLeafs[Index].Data.ECX, 9);
      CNXT_ID := GetBit(FLeafs[Index].Data.ECX, 10);
      SDBG := GetBit(FLeafs[Index].Data.ECX, 11);
      FMA := GetBit(FLeafs[Index].Data.ECX, 12);
      CMPXCHG16B := GetBit(FLeafs[Index].Data.ECX, 13);
      xTPR := GetBit(FLeafs[Index].Data.ECX, 14);
      PDCM := GetBit(FLeafs[Index].Data.ECX, 15);
      PCID := GetBit(FLeafs[Index].Data.ECX, 17);
      DCA := GetBit(FLeafs[Index].Data.ECX, 18);
      SSE4_1 := GetBit(FLeafs[Index].Data.ECX, 19);
      SSE4_2 := GetBit(FLeafs[Index].Data.ECX, 20);
      x2APIC := GetBit(FLeafs[Index].Data.ECX, 21);
      MOVBE := GetBit(FLeafs[Index].Data.ECX, 22);
      POPCNT := GetBit(FLeafs[Index].Data.ECX, 23);
      TSC_Deadline := GetBit(FLeafs[Index].Data.ECX, 24);
      AES := GetBit(FLeafs[Index].Data.ECX, 25);
      XSAVE := GetBit(FLeafs[Index].Data.ECX, 26);
      OSXSAVE := GetBit(FLeafs[Index].Data.ECX, 27);
      AVX := GetBit(FLeafs[Index].Data.ECX, 28);
      F16C := GetBit(FLeafs[Index].Data.ECX, 29);
      RDRAND := GetBit(FLeafs[Index].Data.ECX, 30);
      HYPERVISOR := GetBit(FLeafs[Index].Data.ECX, 31);

      { EDX register. }
      FPU := GetBit(FLeafs[Index].Data.EDX, 0);
      VME := GetBit(FLeafs[Index].Data.EDX, 1);
      DE := GetBit(FLeafs[Index].Data.EDX, 2);
      PSE := GetBit(FLeafs[Index].Data.EDX, 3);
      TSC := GetBit(FLeafs[Index].Data.EDX, 4);
      MSR := GetBit(FLeafs[Index].Data.EDX, 5);
      PAE := GetBit(FLeafs[Index].Data.EDX, 6);
      MCE := GetBit(FLeafs[Index].Data.EDX, 7);
      CX8 := GetBit(FLeafs[Index].Data.EDX, 8);
      APIC := GetBit(FLeafs[Index].Data.EDX, 9);
      SEP := GetBit(FLeafs[Index].Data.EDX, 11);
      MTRR := GetBit(FLeafs[Index].Data.EDX, 12);
      PGE := GetBit(FLeafs[Index].Data.EDX, 13);
      MCA := GetBit(FLeafs[Index].Data.EDX, 14);
      CMOV := GetBit(FLeafs[Index].Data.EDX, 15);
      PAT := GetBit(FLeafs[Index].Data.EDX, 16);
      PSE_36 := GetBit(FLeafs[Index].Data.EDX, 17);
      PSN := GetBit(FLeafs[Index].Data.EDX, 18);
      CLFSH := GetBit(FLeafs[Index].Data.EDX, 19);
      DS := GetBit(FLeafs[Index].Data.EDX, 21);
      ACPI := GetBit(FLeafs[Index].Data.EDX, 22);
      MMX := GetBit(FLeafs[Index].Data.EDX, 23);
      FXSR := GetBit(FLeafs[Index].Data.EDX, 24);
      SSE := GetBit(FLeafs[Index].Data.EDX, 25);
      SSE2 := GetBit(FLeafs[Index].Data.EDX, 26);
      SS := GetBit(FLeafs[Index].Data.EDX, 27);
      HTT := GetBit(FLeafs[Index].Data.EDX, 28);
      TM := GetBit(FLeafs[Index].Data.EDX, 29);
      IA64 := GetBit(FLeafs[Index].Data.EDX, 30);
      PBE := GetBit(FLeafs[Index].Data.EDX, 31);
    end;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_0000_0002;
var
  Index: SizeInt;
  I: SizeUInt;
begin
  { This whole function must be run on the same processor (core), otherwise
    results will be wrong. }
  Index := IndexOf($00000002);
  if (Index >= 0) then
    if (Byte(FLeafs[Index].Data.EAX) > 0) then
    begin
      SetLength(FLeafs[Index].SubLeafs, Byte(FLeafs[Index].Data.EAX));
      FLeafs[Index].SubLeafs[0] := FLeafs[Index].Data;
      for I := 1 to High(FLeafs[Index].SubLeafs) do
        CPUID(2, Addr(FLeafs[Index].SubLeafs[I]));
    end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_0000_0004;
var
  Index: SizeInt;
  Temp: TCPUIDResult;
begin
  Index := IndexOf($00000004);
  if (Index >= 0) then
  begin
    Temp := FLeafs[Index].Data;
    while (((Temp.EAX and $1F) <> 0) and (Length(FLeafs[Index].SubLeafs) <= 128)) do
    begin
      SetLength(FLeafs[Index].SubLeafs, Length(FLeafs[Index].SubLeafs) + 1);
      FLeafs[Index].SubLeafs[High(FLeafs[Index].SubLeafs)] := Temp;
      CPUID(4, UInt32(Length(FLeafs[Index].SubLeafs)), @Temp);
    end;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_0000_0007;
var
  Index: SizeInt;
  I: SizeUInt;
begin
  Index := IndexOf($00000007);
  if (Index >= 0) then
  begin
    { Get all subleafs. }
    SetLength(FLeafs[Index].SubLeafs, FLeafs[Index].Data.EAX + 1);

    for I := Low(FLeafs[Index].SubLeafs) to High(FLeafs[Index].SubLeafs) do
      CPUID(7, UInt32(I), Addr(FLeafs[Index].SubLeafs[i]));

    { Processor features. }
    with FInfo.ProcessorFeatures do
    begin
      { EBX register. }
      FSGSBASE := GetBit(FLeafs[Index].Data.EBX, 0);
      TSC_ADJUST := GetBit(FLeafs[Index].Data.EBX, 1);
      SGX := GetBit(FLeafs[Index].Data.EBX, 2);
      BMI1 := GetBit(FLeafs[Index].Data.EBX, 3);
      HLE := GetBit(FLeafs[Index].Data.EBX, 4);
      AVX2 := GetBit(FLeafs[Index].Data.EBX, 5);
      FPDP := GetBit(FLeafs[Index].Data.EBX, 6);
      SMEP := GetBit(FLeafs[Index].Data.EBX, 7);
      BMI2 := GetBit(FLeafs[Index].Data.EBX, 8);
      ERMS := GetBit(FLeafs[Index].Data.EBX, 9);
      INVPCID := GetBit(FLeafs[Index].Data.EBX, 10);
      RTM := GetBit(FLeafs[Index].Data.EBX, 11);
      PQM := GetBit(FLeafs[Index].Data.EBX, 12);
      FPCSDS := GetBit(FLeafs[Index].Data.EBX, 13);
      MPX := GetBit(FLeafs[Index].Data.EBX, 14);
      PQE := GetBit(FLeafs[Index].Data.EBX, 15);
      AVX512F := GetBit(FLeafs[Index].Data.EBX, 16);
      AVX512DQ := GetBit(FLeafs[Index].Data.EBX, 17);
      RDSEED := GetBit(FLeafs[Index].Data.EBX, 18);
      ADX := GetBit(FLeafs[Index].Data.EBX, 19);
      SMAP := GetBit(FLeafs[Index].Data.EBX, 20);
      AVX512IFMA := GetBit(FLeafs[Index].Data.EBX, 21);
      PCOMMIT := GetBit(FLeafs[Index].Data.EBX, 22);
      CLFLUSHOPT := GetBit(FLeafs[Index].Data.EBX, 23);
      CLWB := GetBit(FLeafs[Index].Data.EBX, 24);
      PT := GetBit(FLeafs[Index].Data.EBX, 25);
      AVX512PF := GetBit(FLeafs[Index].Data.EBX, 26);
      AVX512ER := GetBit(FLeafs[Index].Data.EBX, 27);
      AVX512CD := GetBit(FLeafs[Index].Data.EBX, 28);
      SHA := GetBit(FLeafs[Index].Data.EBX, 29);
      AVX512BW := GetBit(FLeafs[Index].Data.EBX, 30);
      AVX512VL := GetBit(FLeafs[Index].Data.EBX, 31);

      { ECX register. }
      PREFETCHWT1 := GetBit(FLeafs[Index].Data.ECX, 0);
      AVX512VBMI := GetBit(FLeafs[Index].Data.ECX, 1);
      UMIP := GetBit(FLeafs[Index].Data.ECX, 2);
      PKU := GetBit(FLeafs[Index].Data.ECX, 3);
      OSPKE := GetBit(FLeafs[Index].Data.ECX, 4);
      CET := GetBit(FLeafs[Index].Data.ECX, 7);
      VA57 := GetBit(FLeafs[Index].Data.ECX, 16);
      MAWAU := Byte(GetBits(FLeafs[Index].Data.ECX, 17, 21));
      RDPID := GetBit(FLeafs[Index].Data.ECX, 22);
      SGX_LC := GetBit(FLeafs[Index].Data.ECX, 30);

      { EDX register. }
      AVX512QVNNIW := GetBit(FLeafs[Index].Data.EDX, 2);
      AVX512QFMA := GetBit(FLeafs[Index].Data.EDX, 3);
    end;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_0000_000B;
var
  Index: SizeInt;
  Temp: TCPUIDResult;
begin
  Index := IndexOf($0000000B);
  if (Index >= 0) then
  begin
    Temp := FLeafs[Index].Data;
    while (GetBits(Temp.ECX, 8, 15) <> 0) do
    begin
      SetLength(FLeafs[Index].SubLeafs, Length(FLeafs[Index].SubLeafs) + 1);
      FLeafs[Index].SubLeafs[High(FLeafs[Index].SubLeafs)] := Temp;
      CPUID($B, UInt32(Length(FLeafs[Index].SubLeafs)), @Temp);
    end;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_0000_000D;
var
  Index: SizeInt;
  I: SizeUInt;
begin
  Index := IndexOf($0000000D);
  if (Index >= 0) then
  begin
    SetLength(FLeafs[Index].SubLeafs, 2);
    FLeafs[Index].SubLeafs[0] := FLeafs[Index].Data;
    CPUID($D, 1, Addr(FLeafs[Index].SubLeafs[1]));

    for I := 2 to 31 do
      if (GetBit(FLeafs[Index].SubLeafs[0].EAX, I) and GetBit(FLeafs[Index].SubLeafs[1].ECX, I)) then
      begin
        SetLength(FLeafs[Index].SubLeafs, Length(FLeafs[Index].SubLeafs) + 1);
        CPUID($D, UInt32(I), Addr(FLeafs[Index].SubLeafs[High(FLeafs[Index].SubLeafs)]));
      end;

    for I := 0 to 31 do
      if (GetBit(FLeafs[Index].SubLeafs[0].EDX, I) and GetBit(FLeafs[Index].SubLeafs[1].EDX, I)) then
      begin
        SetLength(FLeafs[Index].SubLeafs, Length(FLeafs[Index].SubLeafs) + 1);
        CPUID($D, UInt32(32 + I), Addr(FLeafs[Index].SubLeafs[High(FLeafs[Index].SubLeafs)]));
      end;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_0000_000F;
var
  Index: SizeInt;
  I: SizeUInt;
begin
  Index := IndexOf($0000000F);
  if (Index >= 0) then
  begin
    SetLength(FLeafs[Index].SubLeafs, 1);
    FLeafs[Index].SubLeafs[0] := FLeafs[Index].Data;

    for I := 1 to 31 do
      if (GetBit(FLeafs[Index].Data.EDX, I)) then
      begin
        SetLength(FLeafs[Index].SubLeafs, Length(FLeafs[Index].SubLeafs) + 1);
        CPUID($F, UInt32(I), Addr(FLeafs[Index].SubLeafs[High(FLeafs[Index].SubLeafs)]));
      end;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_0000_0010;
var
  Index: SizeInt;
  I: SizeUInt;
begin
  Index := IndexOf($00000010);
  if (Index >= 0) then
  begin
    SetLength(FLeafs[Index].SubLeafs, 1);
    FLeafs[Index].SubLeafs[0] := FLeafs[Index].Data;

    for I := 1 to 31 do
      if (GetBit(FLeafs[Index].Data.EBX, I)) then
      begin
        SetLength(FLeafs[Index].SubLeafs, Length(FLeafs[Index].SubLeafs) + 1);
        CPUID($10, UInt32(I), Addr(FLeafs[Index].SubLeafs[High(FLeafs[Index].SubLeafs)]));
      end;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_0000_0012;
var
  Index: SizeInt;
  I: SizeUInt;
begin
  Index := IndexOf($00000012);
  if (Index >= 0) then
  begin
    if (FInfo.ProcessorFeatures.SGX) then
    begin
      SetLength(FLeafs[Index].SubLeafs, 1);
      FLeafs[Index].SubLeafs[0] := FLeafs[Index].Data;

      for I := 0 to 31 do
        if (GetBit(FLeafs[Index].Data.EAX, I)) then
        begin
          SetLength(FLeafs[Index].SubLeafs, Length(FLeafs[Index].SubLeafs) + 1);
          CPUID($12, UInt32(I + 1), Addr(FLeafs[Index].SubLeafs[High(FLeafs[Index].SubLeafs)]));
        end;
    end else
      DeleteLeaf(Index);
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_0000_0014;
var
  Index: SizeInt;
  I: SizeUInt;
begin
  Index := IndexOf($00000014);
  if (Index >= 0) then
  begin
    SetLength(FLeafs[Index].SubLeafs, FLeafs[Index].Data.EAX + 1);

    for I := Low(FLeafs[Index].SubLeafs) to High(FLeafs[Index].SubLeafs) do
      CPUID($14, UInt32(I), Addr(FLeafs[Index].SubLeafs[I]));
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_0000_0017;
var
  Index: SizeInt;
  I: SizeUInt;
begin
  Index := IndexOf($00000017);
  if (Index >= 0) then
  begin
    if (FLeafs[Index].Data.EAX >= 3) then
    begin
      SetLength(FLeafs[Index].SubLeafs, FLeafs[Index].Data.EAX + 1);

      for I := Low(FLeafs[Index].SubLeafs) to High(FLeafs[Index].SubLeafs) do
        CPUID($17, UInt32(I), Addr(FLeafs[Index].SubLeafs[I]));
    end else
      DeleteLeaf(Index);
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_8000_0001;
var
  Index: SizeInt;
begin
  Index := IndexOf($80000001);
  if (Index >= 0) then
  begin
    { Extended processor features. }
    with FInfo.ExtendedProcessorFeatures do
    begin
      { ECX register. }
      AHF64 := GetBit(FLeafs[Index].Data.ECX, 0);
      CMP := GetBit(FLeafs[Index].Data.ECX, 1);
      SVM := GetBit(FLeafs[Index].Data.ECX, 2);
      EAS := GetBit(FLeafs[Index].Data.ECX, 3);
      CR8D := GetBit(FLeafs[Index].Data.ECX, 4);
      LZCNT := GetBit(FLeafs[Index].Data.ECX, 5);
      ABM := GetBit(FLeafs[Index].Data.ECX, 5);
      SSE4A := GetBit(FLeafs[Index].Data.ECX, 6);
      MSSE := GetBit(FLeafs[Index].Data.ECX, 7);
      _3DNowP := GetBit(FLeafs[Index].Data.ECX, 8);
      OSVW := GetBit(FLeafs[Index].Data.ECX, 9);
      IBS := GetBit(FLeafs[Index].Data.ECX, 10);
      XOP := GetBit(FLeafs[Index].Data.ECX, 11);
      SKINIT := GetBit(FLeafs[Index].Data.ECX, 12);
      WDT := GetBit(FLeafs[Index].Data.ECX, 13);
      LWP := GetBit(FLeafs[Index].Data.ECX, 15);
      FMA4 := GetBit(FLeafs[Index].Data.ECX, 16);
      TCE := GetBit(FLeafs[Index].Data.ECX, 17);
      NODEID := GetBit(FLeafs[Index].Data.ECX, 19);
      TBM := GetBit(FLeafs[Index].Data.ECX, 21);
      TOPX := GetBit(FLeafs[Index].Data.ECX, 22);
      PCX_CORE := GetBit(FLeafs[Index].Data.ECX, 23);
      PCX_NB := GetBit(FLeafs[Index].Data.ECX, 24);
      DBX := GetBit(FLeafs[Index].Data.ECX, 26);
      PERFTSC := GetBit(FLeafs[Index].Data.ECX, 27);
      PCX_L2I := GetBit(FLeafs[Index].Data.ECX, 28);
      MON := GetBit(FLeafs[Index].Data.ECX, 29);

      { EDX register. }
      FPU := GetBit(FLeafs[Index].Data.EDX, 0);
      VME := GetBit(FLeafs[Index].Data.EDX, 1);
      DE := GetBit(FLeafs[Index].Data.EDX, 2);
      PSE := GetBit(FLeafs[Index].Data.EDX, 3);
      TSC := GetBit(FLeafs[Index].Data.EDX, 4);
      MSR := GetBit(FLeafs[Index].Data.EDX, 5);
      PAE := GetBit(FLeafs[Index].Data.EDX, 6);
      MCE := GetBit(FLeafs[Index].Data.EDX, 7);
      CX8 := GetBit(FLeafs[Index].Data.EDX, 8);
      APIC := GetBit(FLeafs[Index].Data.EDX, 9);
      SEP := GetBit(FLeafs[Index].Data.EDX, 11);
      MTRR := GetBit(FLeafs[Index].Data.EDX, 12);
      PGE := GetBit(FLeafs[Index].Data.EDX, 13);
      MCA := GetBit(FLeafs[Index].Data.EDX, 14);
      CMOV := GetBit(FLeafs[Index].Data.EDX, 15);
      PAT := GetBit(FLeafs[Index].Data.EDX, 16);
      PSE36 := GetBit(FLeafs[Index].Data.EDX, 17);
      MP := GetBit(FLeafs[Index].Data.EDX, 19);
      NX := GetBit(FLeafs[Index].Data.EDX, 20);
      MMXExt := GetBit(FLeafs[Index].Data.EDX, 22);
      MMX := GetBit(FLeafs[Index].Data.EDX, 23);
      FXSR := GetBit(FLeafs[Index].Data.EDX, 24);
      FFXSR := GetBit(FLeafs[Index].Data.EDX, 25);
      PG1G := GetBit(FLeafs[Index].Data.EDX, 26);
      TSCP := GetBit(FLeafs[Index].Data.EDX, 27);
      LM := GetBit(FLeafs[Index].Data.EDX, 29);
      _3DNowExt := GetBit(FLeafs[Index].Data.EDX, 30);
      _3DNow := GetBit(FLeafs[Index].Data.EDX, 31);
    end;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_8000_0002_to_8000_0004;
var
  Str: AnsiString;
  I: SizeUInt;
  Index: SizeInt;
begin
  { Get brand string. }
  SetLength(Str, 48);
  for I := 0 to 2 do
  begin
    Index := IndexOf($80000002 + UInt32(i));
    if (Index >= 0) then
    begin
{$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
      Move(FLeafs[Index].Data.EAX, Pointer(PtrUInt(PAnsiChar(Str)) + PtrUInt(I * 16))^, 4);
      Move(FLeafs[Index].Data.EBX, Pointer(PtrUInt(PAnsiChar(Str)) + PtrUInt(I * 16) + 4)^, 4);
      Move(FLeafs[Index].Data.ECX, Pointer(PtrUInt(PAnsiChar(Str)) + PtrUInt(I * 16) + 8)^, 4);
      Move(FLeafs[Index].Data.EDX, Pointer(PtrUInt(PAnsiChar(Str)) + PtrUInt(I * 16) + 12)^, 4);
{$IFDEF FPCDWM}{$POP}{$ENDIF}
    end else
      begin
        FInfo.BrandString := '';
        Exit;
      end;
  end;

{$IF NOT DEFINED(FPC) AND (CompilerVersion >= 20)}
  SetLength(Str, {$IFDEF HAS_UNITSCOPE}System.AnsiStrings.StrLen(PAnsiChar(Str)){$ELSE}AnsiStrings.StrLen(PAnsiChar(Str)){$ENDIF});
{$ELSE}
  SetLength(Str, StrLen(PAnsiChar(Str)));
{$IFEND}

  FInfo.BrandString := Trim(String(Str));
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentification.ProcessLeaf_8000_001D;
var
  Index: SizeInt;
  Temp: TCPUIDResult;
begin
  Index := IndexOf($8000001D);
  if ((Index >= 0) and (FInfo.ExtendedProcessorFeatures.TOPX)) then
  begin
    Temp := FLeafs[Index].Data;
    while (GetBits(Temp.EAX, 0, 4) <> 0) do
    begin
      SetLength(FLeafs[Index].SubLeafs, Length(FLeafs[Index].SubLeafs) + 1);
      FLeafs[Index].SubLeafs[High(FLeafs[Index].SubLeafs)] := Temp;
      CPUID($8000001D, UInt32(Length(FLeafs[Index].SubLeafs)), @Temp);
    end;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

class function TCPUIdentification.SameLeafs(A, B: TCPUIDResult): Boolean;
begin
  Result := (A.EAX = B.EAX) and (A.EBX = B.EBX) and (A.ECX = B.ECX) and (A.EDX = B.EDX);
end;
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

{$IFDEF SUPPORTS_REGION}{$REGION 'TCPUIdentificationEx - class implementation'}{$ENDIF}
{$HINTS OFF}
{$WARNINGS OFF}
function TCPUIdentificationEx.AvailableProcessorCoreCount: SizeUInt;

  function GetMaxBasicCPUIDLeaf: NativeUInt;
  var
    Index: SizeInt;
  begin
    Index := IndexOf($00000000);
    if (Index >= 0) then
      Result := FLeafs[Index].Data.EAX
    else
      Result := 0;
  end;

  function ProcessorPackageSupportsLogicalProcessors: Boolean;
  begin
    Result := False;

    if (FInfo.ManufacturerID = TCPUIDManufacturerID.mnIntel) then
      Result := FInfo.ProcessorFeatures.HTT;
  end;

  function GetLogicalProcessorCountPerPackage: NativeUInt;
  begin
    Result := FInfo.AdditionalInfo.LogicalProcessorCount;
  end;

  function GetMaxCoresPerPackage: PtrUInt;
  var
    Index: SizeInt;
  begin
    if (GetMaxBasicCPUIDLeaf >= 4) then
    begin
      Index := IndexOf($00000004);
      if (Index >= 0) then
      begin
        if (Length(FLeafs[Index].SubLeafs) > 0) then
        begin
          Result := (FLeafs[Index].SubLeafs[0].EAX shr 26) + 1;
        end else
          Result := 1;
      end else
        Result := 1;
    end else
      Result := 1;
  end;

  function GetAPIC_ID: NativeUInt;
  var
    Tmp: TCPUIDResult;
  begin
    { Very important! We need to read current state of local APIC_ID because in
      further code we are switching thread affinity mask and state of APIC_ID is
      rescheduled by OS. }
    CPUID($00000001, Addr(Tmp));
    Result := Tmp.EBX shr 24;
  end;

var
  I: SizeUInt;
  PackCoreList: TIntegerList;
  ThreadHandle: THandle;
  LogicalProcessorCountPerPackage, MaxCoresPerPackage, LogicalPerCore,
  APIC_ID, PACKAGE_ID, CORE_ID, LOGICAL_ID, PACKAGE_CORE_ID,
  CORE_ID_MASK, CORE_ID_SHIFT, LOGICAL_ID_MASK, LOGICAL_ID_SHIFT,
  ProcessAffinityMask, SystemAffinityMask, ThreadAffinityMask, Mask: PtrUInt;
begin
  Result := 0;
  try
    { See Intel documentation (Y:IntelIA32_manuals) for details on logical
      processor topology. }
    if ({$IFDEF HAS_UNITSCOPE}System.SysUtils.Win32Platform{$ELSE}SysUtils.Win32Platform{$ENDIF} = VER_PLATFORM_WIN32_NT) then
	  begin
      MaxCoresPerPackage := GetMaxCoresPerPackage;
      if ((ProcessorPackageSupportsLogicalProcessors) or (MaxCoresPerPackage > 1)) then
	    begin
        LogicalProcessorCountPerPackage := GetLogicalProcessorCountPerPackage;
        LogicalPerCore :=
		      LogicalProcessorCountPerPackage div MaxCoresPerPackage;

        LOGICAL_ID_MASK := $FF;
        LOGICAL_ID_SHIFT := 0;

		    I := 1;
		    while (I < LogicalPerCore) do
		    begin
          I := I * 2;
          LOGICAL_ID_MASK := LOGICAL_ID_MASK shl 1;
          Inc(LOGICAL_ID_SHIFT);
        end;

		    CORE_ID_SHIFT := 0;

        if (MaxCoresPerPackage > 1) then
		    begin
          CORE_ID_MASK := LOGICAL_ID_MASK;
          I := 1;

          while (i < MaxCoresPerPackage) do
		      begin
            I := I * 2;
            CORE_ID_MASK := CORE_ID_MASK shl 1;
            Inc(CORE_ID_SHIFT);
          end;
        end else
            CORE_ID_MASK := $FF;

        LOGICAL_ID_MASK := not LOGICAL_ID_MASK;
        CORE_ID_MASK := not CORE_ID_MASK;

		    if (GetProcessAffinityMask(GetCurrentProcess, @ProcessAffinityMask, @SystemAffinityMask)) then
        begin
		      { Get the current thread affinity. }
          ThreadHandle := GetCurrentThread;
          ThreadAffinityMask := SetThreadAffinityMask(ThreadHandle, ProcessAffinityMask);
          if (ThreadAffinityMask <> 0) then
		      begin
            try
              PackCoreList := TIntegerList.Create;
              try
                for I := 0 to 31 do
                begin
                  Mask := 1 shl I;
                  if ((ProcessAffinityMask and Mask) <> 0) then
                  begin
                    if (SetThreadAffinityMask(ThreadHandle, Mask) <> 0) then
					          begin
					            { Allow OS to reschedule thread onto the selected
                        processor. }
                      Sleep(0);

					            APIC_ID := GetAPIC_ID;
                      LOGICAL_ID := APIC_ID and LOGICAL_ID_MASK;
                      CORE_ID :=
					              (APIC_ID and CORE_ID_MASK) shr LOGICAL_ID_SHIFT;
                      PACKAGE_ID :=
					              APIC_ID shr (LOGICAL_ID_SHIFT + CORE_ID_SHIFT);

                      { Mask out LOGICAL_ID. }
                      PACKAGE_CORE_ID :=
					              APIC_ID and (not LOGICAL_ID_MASK);

                      { Identifies the processor core - it’s not a value defined
                        by Intel, rather it’s defined by us! }
                      if (PackCoreList.IndexOf(PACKAGE_CORE_ID) = -1) then
					            begin
                        { Count the number of unique processor cores. }
                        PackCoreList.Add(PACKAGE_CORE_ID);
                      end;
                    end;
                  end;
                end;

                Result := PackCoreList.Count;
              finally
                FreeAndNil(PackCoreList);
              end;
            finally
              { Restore thread affinity. }
              SetThreadAffinityMask(ThreadHandle, ThreadAffinityMask);
            end;
          end;
        end;
      end;
    end;
  except
    { Some processors don’t support CPUID and so will raise exceptions when it
      is called. }
    ;
  end;

  if (Result = 0) then
  begin
    { If we haven’t modified Result above, then assume that all logical
      processors are true physical processor cores. }
    Result := AvailableProcessorCount;
  end;
end;
{$WARNINGS ON}
{$HINTS ON}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

function TCPUIdentificationEx.AvailableProcessorCount: SizeUInt;
var
  I: SizeUInt;
  ProcessAffinityMask, SystemAffinityMask, Mask: PtrUInt;
  SysInfo: TSystemInfo;
begin
  if (GetProcessAffinityMask(GetCurrentProcess, @ProcessAffinityMask, @SystemAffinityMask)) then
  begin
    Result := 0;

    for I := 0 to 31 do
    begin
      Mask := 1 shl I;

      if ((ProcessAffinityMask and Mask) <> 0) then
        Inc(Result);
    end;
  end else
    begin
      { Can’t get the affinity mask so we just report the total number of
        processors. }
      ZeroMemory(@SysInfo, SizeOf(SysInfo));
      GetSystemInfo(SysInfo);
      Result := SysInfo.dwNumberOfProcessors;
    end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

constructor TCPUIdentificationEx.Create(ProcessorID: SizeUInt; DoInitialize, IncUnsupportedLeafs: Boolean);
begin
  { (1) Call inherited code. }
  inherited Create(False, IncUnsupportedLeafs);

  { (2) Set FProcessorID. }
  FProcessorID := ProcessorID;

  { (3) Set FPhysicalCoreCount and FLogicalCoreCount to 0. }
  FPhysicalCoreCount := 0;
  FLogicalCoreCount := 0;

  { (4) If not initialized, initialize now. }
  if (DoInitialize) then
    Initialize;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure TCPUIdentificationEx.Initialize;
var
  OldProcessorMask: PtrUInt;
begin
  if (ProcessorAvailable(FProcessorID)) then
  begin
    OldProcessorMask := SetThreadAffinity(SetBit(0, FProcessorID));
    try
      inherited Initialize;
    finally
      SetThreadAffinity(OldProcessorMask);
    end;

    FPhysicalCoreCount := AvailableProcessorCoreCount;
    FLogicalCoreCount := AvailableProcessorCount;

    { If host CPU supports CPUID instructions... }
    if (FSupported) then
    begin
      { ... and if CPU have Time Stamp Counter feature... }
{$IFDEF MSWINDOWS}
      if (FInfo.ProcessorFeatures.TSC) then
        { ... determine CPU speed and store it in FFrequencyInfo. }
        if (not GetCPUSpeed(FFrequencyInfo)) then
          raise ECIDException.Create(SInitialize_CannotDetermineCPUSpeed);
{$ENDIF !MSWINDOWS}
    end;
  end else
    raise ECIDException.CreateFmt(SInitialize_LogicalProcessorNotAvailable, [fProcessorID]);
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

class function TCPUIdentificationEx.ProcessorAvailable(ProcessorID: SizeUInt): Boolean;
var
  ProcessAffinityMask: PtrUInt;
{$IFDEF Windows}
  SystemAffinityMask: PtrUInt;
begin
  if (ProcessorID < (SizeOf(PtrUInt) * 8)) then
  begin
    if (GetProcessAffinityMask(GetCurrentProcess, @ProcessAffinityMask, @SystemAffinityMask)) then
      Result := GetBit(ProcessAffinityMask,ProcessorID)
    else
      raise ECIDException.CreateFmt(SGetProcessAffinityMaskFailed, [GetLastError]);
  end else
    Result := False;
end;
{$ELSE !Windows}
begin
  if ((ProcessorID >= 0) and (ProcessorID < (SizeOf(PtrUInt) * 8))) then
  begin
    { sched_getaffinity called with process id (getpid) returns mask of main
      thread (process mask). }
    RaiseErrorErrNo(sched_getaffinity(getpid, SizeOf(ProcessAffinityMask), @ProcessAffinityMask), 'sched_getaffinity');
    Result := GetBit(ProcessAffinityMask, ProcessorID);
  end else
    Result := False;
end;
{$ENDIF !Windows}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

class function TCPUIdentificationEx.SetThreadAffinity(ProcessorMask: PtrUInt): PtrUInt;
begin
{$IFDEF Windows}
  Result := {$IFDEF HAS_UNITSCOPE}Winapi.Windows.SetThreadAffinityMask(GetCurrentThread, ProcessorMask);{$ELSE}SetThreadAffinityMask(GetCurrentThread, ProcessorMask);{$ENDIF}
{$ELSE !Windows}
  RaiseError(pthread_getaffinity_np(pthread_self, SizeOf(Result), @Result), 'pthread_getaffinity_np');
  RaiseError(pthread_setaffinity_np(pthread_self, SizeOf(ProcessorMask), @ProcessorMask), 'pthread_setaffinity_np');
{$ENDIF !Windows}
end;
{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

end.
