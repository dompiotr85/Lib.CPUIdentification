{===============================================================================

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

===============================================================================}
unit CPUIdentification.Consts;

interface

resourcestring
  SDeleteLeaf_IndexOutOfBounds =
    'TCPUIdentification.DeleteLeaf: Index (%d) out of bounds!';
  SGetLeaf_IndexOutOfBounds =
    'TCPUIdentifacation.GetLeaf: Index (%d) out of bounds!';
  SInitialize_CannotDetermineCPUSpeed =
    'TCPUIdentificationEx.Initialize: Can not determine CPU speed!';
  SInitialize_LogicalProcessorNotAvailable =
    'TCPUIdentificationEx.Initialize: Logical processor #%d not available!';
  SGetProcessAffinityMaskFailed =
    'GetProcessAffinityMask failed with error 0x%.8x!';

implementation

end.
