{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zcontainers;

interface

uses
  UGDBOpenArray, UGDBOpenArrayOfByte, UGDBOpenArrayOfData, 
  UGDBOpenArrayOfObjects, UGDBOpenArrayOfPObjects, UGDBOpenArrayOfPointer, 
  UGDBOpenArrayOfTObjLinkRecord, UGDBStringArray, UGDBTree, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zcontainers', @Register);
end.