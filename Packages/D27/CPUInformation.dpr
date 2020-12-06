{===============================================================================

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

===============================================================================}

{$INCLUDE jedi\jedi.inc}

program CPUInformation;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  {$IFDEF HAS_UNITSCOPE}System.SysUtils{$ELSE}SysUtils{$ENDIF},
  CPUIdentification;

var
  CPUIdent: TCPUIdentificationEx;
  FeaturesStr, ExtendedFeaturesStr, SupportedFeaturesStr: String;

function BoolToYesNo(const Value: Boolean): String;
begin
  if (Value) then
    Result := 'Yes'
  else
    Result := 'No';
end;

begin
  try
    CPUIdent := TCPUIdentificationEx.Create(0);
    try
      Writeln;

      { Write basic CPU information. }
      Writeln('CPU Manufacturer: ' + CPUIdent.Info.ManufacturerIDString);
      Writeln('Brand ID: ' + CPUIdent.Info.AdditionalInfo.BrandID.ToString);
      Writeln('Brand: ' + CPUIdent.Info.BrandString);
      Writeln('Type: ' + CPUIdent.Info.ProcessorType.ToString);
      Writeln('Family: ' + CPUIdent.Info.ProcessorFamily.ToHexString(2) + 'h');
      Writeln('Model: ' + CPUIdent.Info.ProcessorModel.ToHexString(2) + 'h');
      Writeln(
        'Stepping: ' + CPUIdent.Info.ProcessorStepping.ToHexString(2) + 'h');

      { Write calculated CPU raw frequency. }
      Writeln(
        'Raw Frequeny: ' + CPUIdent.FreqencyInfo.RawFreq.ToString + ' Mhz');

      { Write CPU physical and logical cores. }
      Writeln('Physical Cores: ' + CPUIdent.PhysicalCoreCount.ToString);
      Writeln('Logical Cores: ' + CPUIdent.LogicalCoreCount.ToString);

      { Write CPU HTT and Hardware HTT support. }
      Writeln(
        'Hyper-Threading Technology: ' +
        BoolToYesNo(CPUIdent.Info.ProcessorFeatures.HTT));
      Writeln(
        'Hardware Hyper-Threading Technology: ' +
        BoolToYesNo(CPUIdent.PhysicalCoreCount <> CPUIdent.LogicalCoreCount));

      { Prepare CPU features string. }
      FeaturesStr := '';
      if (CPUIdent.Info.ProcessorFeatures.ACPI) then
        FeaturesStr := FeaturesStr + 'ACPI ';
      if (CPUIdent.Info.ProcessorFeatures.ADX) then
        FeaturesStr := FeaturesStr + 'ADX ';
      if (CPUIdent.Info.ProcessorFeatures.AES) then
        FeaturesStr := FeaturesStr + 'AES ';
      if (CPUIdent.Info.ProcessorFeatures.APIC) then
        FeaturesStr := FeaturesStr + 'APIC ';
      if (CPUIdent.Info.ProcessorFeatures.AVX) then
        FeaturesStr := FeaturesStr + 'AVX ';
      if (CPUIdent.Info.ProcessorFeatures.AVX2) then
        FeaturesStr := FeaturesStr + 'AVX2 ';
      if (CPUIdent.Info.ProcessorFeatures.AVX512BW) then
        FeaturesStr := FeaturesStr + 'AVX512BW ';
      if (CPUIdent.Info.ProcessorFeatures.AVX512CD) then
        FeaturesStr := FeaturesStr + 'AVX512CD ';
      if (CPUIdent.Info.ProcessorFeatures.AVX512DQ) then
        FeaturesStr := FeaturesStr + 'AVX512DQ ';
      if (CPUIdent.Info.ProcessorFeatures.AVX512ER) then
        FeaturesStr := FeaturesStr + 'AVX512ER ';
      if (CPUIdent.Info.ProcessorFeatures.AVX512F) then
        FeaturesStr := FeaturesStr + 'AVX512F ';
      if (CPUIdent.Info.ProcessorFeatures.AVX512IFMA) then
        FeaturesStr := FeaturesStr + 'AVX512IFMA ';
      if (CPUIdent.Info.ProcessorFeatures.AVX512PF) then
        FeaturesStr := FeaturesStr + 'AVX512PF ';
      if (CPUIdent.Info.ProcessorFeatures.AVX512QFMA) then
        FeaturesStr := FeaturesStr + 'AVX512QFMA ';
      if (CPUIdent.Info.ProcessorFeatures.AVX512QVNNIW) then
        FeaturesStr := FeaturesStr + 'AVX512QVNNIW ';
      if (CPUIdent.Info.ProcessorFeatures.AVX512VBMI) then
        FeaturesStr := FeaturesStr + 'AVX512VBMI ';
      if (CPUIdent.Info.ProcessorFeatures.AVX512VL) then
        FeaturesStr := FeaturesStr + 'AVX512VL ';
      if (CPUIdent.Info.ProcessorFeatures.BMI1) then
        FeaturesStr := FeaturesStr + 'BMI1 ';
      if (CPUIdent.Info.ProcessorFeatures.BMI2) then
        FeaturesStr := FeaturesStr + 'BMI2 ';
      if (CPUIdent.Info.ProcessorFeatures.CET) then
        FeaturesStr := FeaturesStr + 'CET ';
      if (CPUIdent.Info.ProcessorFeatures.CLFLUSHOPT) then
        FeaturesStr := FeaturesStr + 'CLFLUSHOPT ';
      if (CPUIdent.Info.ProcessorFeatures.CLFSH) then
        FeaturesStr := FeaturesStr + 'CLFSH ';
      if (CPUIdent.Info.ProcessorFeatures.CLWB) then
        FeaturesStr := FeaturesStr + 'CLWB ';
      if (CPUIdent.Info.ProcessorFeatures.CMOV) then
        FeaturesStr := FeaturesStr + 'CMOV ';
      if (CPUIdent.Info.ProcessorFeatures.CMPXCHG16B) then
        FeaturesStr := FeaturesStr + 'CMPXCHG16B ';
      if (CPUIdent.Info.ProcessorFeatures.CNXT_ID) then
        FeaturesStr := FeaturesStr + 'CNXT_ID ';
      if (CPUIdent.Info.ProcessorFeatures.CX8) then
        FeaturesStr := FeaturesStr + 'CX8 ';
      if (CPUIdent.Info.ProcessorFeatures.DCA) then
        FeaturesStr := FeaturesStr + 'DCA ';
      if (CPUIdent.Info.ProcessorFeatures.DE) then
        FeaturesStr := FeaturesStr + 'DE ';
      if (CPUIdent.Info.ProcessorFeatures.DS) then
        FeaturesStr := FeaturesStr + 'DS ';
      if (CPUIdent.Info.ProcessorFeatures.DS_CPL) then
        FeaturesStr := FeaturesStr + 'DS_CPL ';
      if (CPUIdent.Info.ProcessorFeatures.DTES64) then
        FeaturesStr := FeaturesStr + 'DTES64 ';
      if (CPUIdent.Info.ProcessorFeatures.EIST) then
        FeaturesStr := FeaturesStr + 'EIST ';
      if (CPUIdent.Info.ProcessorFeatures.ERMS) then
        FeaturesStr := FeaturesStr + 'ERMS ';
      if (CPUIdent.Info.ProcessorFeatures.F16C) then
        FeaturesStr := FeaturesStr + 'F16C ';
      if (CPUIdent.Info.ProcessorFeatures.FMA) then
        FeaturesStr := FeaturesStr + 'FMA ';
      if (CPUIdent.Info.ProcessorFeatures.FPCSDS) then
        FeaturesStr := FeaturesStr + 'FPCSDS ';
      if (CPUIdent.Info.ProcessorFeatures.FPDP) then
        FeaturesStr := FeaturesStr + 'FPDP ';
      if (CPUIdent.Info.ProcessorFeatures.FPU) then
        FeaturesStr := FeaturesStr + 'FPU ';
      if (CPUIdent.Info.ProcessorFeatures.FSGSBASE) then
        FeaturesStr := FeaturesStr + 'FSGSBASE ';
      if (CPUIdent.Info.ProcessorFeatures.FXSR) then
        FeaturesStr := FeaturesStr + 'FXSR ';
      if (CPUIdent.Info.ProcessorFeatures.HLE) then
        FeaturesStr := FeaturesStr + 'HLE ';
      if (CPUIdent.Info.ProcessorFeatures.HYPERVISOR) then
        FeaturesStr := FeaturesStr + 'HYPERVISOR ';
      if (CPUIdent.Info.ProcessorFeatures.IA64) then
        FeaturesStr := FeaturesStr + 'IA64 ';
      if (CPUIdent.Info.ProcessorFeatures.INVPCID) then
        FeaturesStr := FeaturesStr + 'INVPCID ';
      if (CPUIdent.Info.ProcessorFeatures.MCA) then
        FeaturesStr := FeaturesStr + 'MCA ';
      if (CPUIdent.Info.ProcessorFeatures.MCE) then
        FeaturesStr := FeaturesStr + 'MCE ';
      if (CPUIdent.Info.ProcessorFeatures.MMX) then
        FeaturesStr := FeaturesStr + 'MMX ';
      if (CPUIdent.Info.ProcessorFeatures.MONITOR) then
        FeaturesStr := FeaturesStr + 'MONITOR ';
      if (CPUIdent.Info.ProcessorFeatures.MOVBE) then
        FeaturesStr := FeaturesStr + 'MOVBE ';
      if (CPUIdent.Info.ProcessorFeatures.MPX) then
        FeaturesStr := FeaturesStr + 'MPX ';
      if (CPUIdent.Info.ProcessorFeatures.MSR) then
        FeaturesStr := FeaturesStr + 'MSR ';
      if (CPUIdent.Info.ProcessorFeatures.MTRR) then
        FeaturesStr := FeaturesStr + 'MTRR ';
      if (CPUIdent.Info.ProcessorFeatures.OSPKE) then
        FeaturesStr := FeaturesStr + 'OSPKE ';
      if (CPUIdent.Info.ProcessorFeatures.OSXSAVE) then
        FeaturesStr := FeaturesStr + 'OSXSAVE ';
      if (CPUIdent.Info.ProcessorFeatures.PAE) then
        FeaturesStr := FeaturesStr + 'PAE ';
      if (CPUIdent.Info.ProcessorFeatures.PAT) then
        FeaturesStr := FeaturesStr + 'PAT ';
      if (CPUIdent.Info.ProcessorFeatures.PBE) then
        FeaturesStr := FeaturesStr + 'PBE ';
      if (CPUIdent.Info.ProcessorFeatures.PCID) then
        FeaturesStr := FeaturesStr + 'PCID ';
      if (CPUIdent.Info.ProcessorFeatures.PCLMULQDQ) then
        FeaturesStr := FeaturesStr + 'PCLMULQDQ ';
      if (CPUIdent.Info.ProcessorFeatures.PCOMMIT) then
        FeaturesStr := FeaturesStr + 'PCOMMIT ';
      if (CPUIdent.Info.ProcessorFeatures.PDCM) then
        FeaturesStr := FeaturesStr + 'PDCM ';
      if (CPUIdent.Info.ProcessorFeatures.PGE) then
        FeaturesStr := FeaturesStr + 'PGE ';
      if (CPUIdent.Info.ProcessorFeatures.PKU) then
        FeaturesStr := FeaturesStr + 'PKU ';
      if (CPUIdent.Info.ProcessorFeatures.POPCNT) then
        FeaturesStr := FeaturesStr + 'POPCNT ';
      if (CPUIdent.Info.ProcessorFeatures.PQE) then
        FeaturesStr := FeaturesStr + 'PQE ';
      if (CPUIdent.Info.ProcessorFeatures.PQM) then
        FeaturesStr := FeaturesStr + 'PQM ';
      if (CPUIdent.Info.ProcessorFeatures.PREFETCHWT1) then
        FeaturesStr := FeaturesStr + 'PREFETCHWT1 ';
      if (CPUIdent.Info.ProcessorFeatures.PSE) then
        FeaturesStr := FeaturesStr + 'PSE ';
      if (CPUIdent.Info.ProcessorFeatures.PSE_36) then
        FeaturesStr := FeaturesStr + 'PSE_36 ';
      if (CPUIdent.Info.ProcessorFeatures.PSN) then
        FeaturesStr := FeaturesStr + 'PSN ';
      if (CPUIdent.Info.ProcessorFeatures.PT) then
        FeaturesStr := FeaturesStr + 'PT ';
      if (CPUIdent.Info.ProcessorFeatures.RDPID) then
        FeaturesStr := FeaturesStr + 'RDPID ';
      if (CPUIdent.Info.ProcessorFeatures.RDRAND) then
        FeaturesStr := FeaturesStr + 'RDRAND ';
      if (CPUIdent.Info.ProcessorFeatures.RDSEED) then
        FeaturesStr := FeaturesStr + 'RDSEED ';
      if (CPUIdent.Info.ProcessorFeatures.RTM) then
        FeaturesStr := FeaturesStr + 'RTM ';
      if (CPUIdent.Info.ProcessorFeatures.SDBG) then
        FeaturesStr := FeaturesStr + 'SDBG ';
      if (CPUIdent.Info.ProcessorFeatures.SEP) then
        FeaturesStr := FeaturesStr + 'SEP ';
      if (CPUIdent.Info.ProcessorFeatures.SGX) then
        FeaturesStr := FeaturesStr + 'SGX ';
      if (CPUIdent.Info.ProcessorFeatures.SGX_LC) then
        FeaturesStr := FeaturesStr + 'SGX_LC ';
      if (CPUIdent.Info.ProcessorFeatures.SHA) then
        FeaturesStr := FeaturesStr + 'SHA ';
      if (CPUIdent.Info.ProcessorFeatures.SMAP) then
        FeaturesStr := FeaturesStr + 'SMAP ';
      if (CPUIdent.Info.ProcessorFeatures.SMEP) then
        FeaturesStr := FeaturesStr + 'SMEP ';
      if (CPUIdent.Info.ProcessorFeatures.SMX) then
        FeaturesStr := FeaturesStr + 'SMX ';
      if (CPUIdent.Info.ProcessorFeatures.SS) then
        FeaturesStr := FeaturesStr + 'SS ';
      if (CPUIdent.Info.ProcessorFeatures.SSE) then
        FeaturesStr := FeaturesStr + 'SSE ';
      if (CPUIdent.Info.ProcessorFeatures.SSE2) then
        FeaturesStr := FeaturesStr + 'SSE2 ';
      if (CPUIdent.Info.ProcessorFeatures.SSE3) then
        FeaturesStr := FeaturesStr + 'SSE3 ';
      if (CPUIdent.Info.ProcessorFeatures.SSE4_1) then
        FeaturesStr := FeaturesStr + 'SSE4_1 ';
      if (CPUIdent.Info.ProcessorFeatures.SSE4_2) then
        FeaturesStr := FeaturesStr + 'SSE4_2 ';
      if (CPUIdent.Info.ProcessorFeatures.SSSE3) then
        FeaturesStr := FeaturesStr + 'SSSE3 ';
      if (CPUIdent.Info.ProcessorFeatures.TM) then
        FeaturesStr := FeaturesStr + 'TM ';
      if (CPUIdent.Info.ProcessorFeatures.TM2) then
        FeaturesStr := FeaturesStr + 'TM2 ';
      if (CPUIdent.Info.ProcessorFeatures.TSC) then
        FeaturesStr := FeaturesStr + 'TSC ';
      if (CPUIdent.Info.ProcessorFeatures.TSC_ADJUST) then
        FeaturesStr := FeaturesStr + 'TSC_ADJUST ';
      if (CPUIdent.Info.ProcessorFeatures.TSC_Deadline) then
        FeaturesStr := FeaturesStr + 'TSC_Deadline ';
      if (CPUIdent.Info.ProcessorFeatures.UMIP) then
        FeaturesStr := FeaturesStr + 'UMIP ';
      if (CPUIdent.Info.ProcessorFeatures.VA57) then
        FeaturesStr := FeaturesStr + 'VA57 ';
      if (CPUIdent.Info.ProcessorFeatures.VME) then
        FeaturesStr := FeaturesStr + 'VME ';
      if (CPUIdent.Info.ProcessorFeatures.VMX) then
        FeaturesStr := FeaturesStr + 'VMX ';
      if (CPUIdent.Info.ProcessorFeatures.x2APIC) then
        FeaturesStr := FeaturesStr + 'x2APIC ';
      if (CPUIdent.Info.ProcessorFeatures.XSAVE) then
        FeaturesStr := FeaturesStr + 'XSAVE ';
      if (CPUIdent.Info.ProcessorFeatures.xTPR) then
        FeaturesStr := FeaturesStr + 'xTPR ';

      { Write CPU features. }
      Writeln('Features: [' + Trim(FeaturesStr) + ']');

      { Prepare CPU extended features string. }
      ExtendedFeaturesStr := '';
      if (CPUIdent.Info.ExtendedProcessorFeatures.ABM) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'ABM ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.AHF64) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'AHF64 ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.APIC) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'APIC ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.CMOV) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'CMOV ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.CMP) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'CMP ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.CR8D) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'CR8D ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.CX8) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'CX8 ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.DBX) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'DBX ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.DE) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'DE ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.EAS) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'EAS ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.FFXSR) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'FFXSR ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.FMA4) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'FMA4 ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.FPU) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'FPU ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.FXSR) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'FXSR ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.IBS) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'IBS ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.LM) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'LM ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.LWP) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'LWP ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.LZCNT) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'LZCNT ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.MCA) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'MCA ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.MCE) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'MCE ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.MMX) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'MMX ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.MMXExt) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'MMXExt ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.MON) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'MON ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.MP) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'MP ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.MSR) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'MSR ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.MSSE) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'MSSE ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.MTRR) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'MTRR ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.NODEID) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'NODEID ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.NX) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'NX ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.OSVW) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'OSVW ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.PAE) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'PAE ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.PAT) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'PAT ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.PCX_CORE) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'PCX_CORE ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.PCX_L2I) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'PCX_L2I ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.PCX_NB) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'PCX_NB ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.PERFTSC) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'PERFTSC ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.PG1G) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'PG1G ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.PGE) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'PGE ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.PSE) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'PSE ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.PSE36) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'PSE36 ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.SEP) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'SEP ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.SKINIT) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'SKINIT ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.SSE4A) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'SSE4A ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.SVM) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'SVM ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.TBM) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'TBM ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.TCE) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'TCE ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.TOPX) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'TOPX ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.TSC) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'TSC ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.TSCP) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'TSCP ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.VME) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'VME ';
      if (CPUIdent.Info.ExtendedProcessorFeatures.WDT) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + 'WDT ';
      if (CPUIdent.Info.ExtendedProcessorFeatures._3DNow) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + '3DNow! ';
      if (CPUIdent.Info.ExtendedProcessorFeatures._3DNowExt) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + '3DNowExt ';
      if (CPUIdent.Info.ExtendedProcessorFeatures._3DNowP) then
        ExtendedFeaturesStr := ExtendedFeaturesStr + '3DNowP ';

      { Write CPU extended features. }
      Writeln('Extended features: [' + Trim(ExtendedFeaturesStr) + ']');

      { Prepare CPU supported features string. }
      SupportedFeaturesStr := '';
      if (CPUIdent.Info.SupportedExtensions.X87) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'x87 ';
      if (CPUIdent.Info.SupportedExtensions.EmulatedX87) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'Emulated_x87 ';
      if (CPUIdent.Info.SupportedExtensions.MMX) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'MMX ';
      if (CPUIdent.Info.SupportedExtensions.SSE) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'SSE ';
      if (CPUIdent.Info.SupportedExtensions.SSE2) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'SSE2 ';
      if (CPUIdent.Info.SupportedExtensions.SSE3) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'SSE3 ';
      if (CPUIdent.Info.SupportedExtensions.SSSE3) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'SSSE3 ';
      if (CPUIdent.Info.SupportedExtensions.SSE4_1) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'SSE4_1 ';
      if (CPUIdent.Info.SupportedExtensions.SSE4_2) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'SSE4_2 ';
      if (CPUIdent.Info.SupportedExtensions.CRC32) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'CRC32 ';
      if (CPUIdent.Info.SupportedExtensions.POPCNT) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'POPCNT ';
      if (CPUIdent.Info.SupportedExtensions.AES) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'AES ';
      if (CPUIdent.Info.SupportedExtensions.PCLMULQDQ) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'PCLMULQDQ ';
      if (CPUIdent.Info.SupportedExtensions.AVX) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'AVX ';
      if (CPUIdent.Info.SupportedExtensions.F16C) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'F16C ';
      if (CPUIdent.Info.SupportedExtensions.FMA) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'FMA ';
      if (CPUIdent.Info.SupportedExtensions.AVX2) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'AVX2 ';
      if (CPUIdent.Info.SupportedExtensions.AVX512F) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'AVX512F ';
      if (CPUIdent.Info.SupportedExtensions.AVX512ER) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'AVX512ER ';
      if (CPUIdent.Info.SupportedExtensions.AVX512PF) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'AVX512PF ';
      if (CPUIdent.Info.SupportedExtensions.AVX512CD) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'AVX512CD ';
      if (CPUIdent.Info.SupportedExtensions.AVX512DQ) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'AVX512DQ ';
      if (CPUIdent.Info.SupportedExtensions.AVX512BW) then
        SupportedFeaturesStr := SupportedFeaturesStr + 'AVX512BW ';

      { Write CPU supported features. }
      Writeln('Supported features: [' + Trim(SupportedFeaturesStr) + ']');

      Writeln;
    finally
      CPUIdent.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

