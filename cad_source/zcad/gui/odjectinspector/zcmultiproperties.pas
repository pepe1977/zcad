{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit zcmultiproperties;
{$INCLUDE def.inc}

interface
uses
  shared,intftranslations,gdbase,gdbasetypes,log,
  usimplegenerics,varmandef,Varman,garrayutils;
type
  TObjID2Counter=TMyMapCounter<TObjID,LessObjID>;
  TObjIDVector=TMyVector<TObjID>;

  TMultiProperty=class;
  TMultiPropertyCategory=(MPCGeneral,MPCGeometry,MPCMisc,MPCSummary);
  TChangedData=record
                     PEntity,
                     PGetDataInEtity:GDBPointer;
                     PSetDataInEtity:GDBPointer;
               end;

  TBeforeIterateProc=function(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
  TAfterIterateProc=procedure(piteratedata:GDBPointer;mp:TMultiProperty);
  TEntChangeProc=procedure(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
  TEntIterateProc=procedure(pvd:pvardesk;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
  TMultiPropertyDataForObjects=record
                                     GetValueOffset,SetValueOffset:GDBInteger;
                                     EntIterateProc:TEntIterateProc;
                                     EntChangeProc:TEntChangeProc;
                               end;
  TObjID2MultiPropertyProcs=GKey2DataMap <TObjID,TMultiPropertyDataForObjects,LessObjID>;
  TMultiProperty=class
                       MPName:GDBString;
                       MPUserName:GDBString;
                       MPType:PUserTypeDescriptor;
                       MPCategory:TMultiPropertyCategory;
                       MPObjectsData:TObjID2MultiPropertyProcs;
                       usecounter:SizeUInt;
                       sortedid:integer;
                       BeforeIterateProc:TBeforeIterateProc;
                       AfterIterateProc:TAfterIterateProc;
                       PIiterateData:GDBPointer;
                       constructor create(_name:GDBString;_sortedid:integer;ptm:PUserTypeDescriptor;_Category:TMultiPropertyCategory;bip:TBeforeIterateProc;aip:TAfterIterateProc;eip:TEntIterateProc);
                 end;
  TMyGDBString2TMultiPropertyDictionary=TMyGDBStringDictionary<TMultiProperty>;

  TMultiPropertyCompare=class
     class function c(a,b:TMultiProperty):boolean;inline;
  end;

  TMultiPropertyVector=TMyVector<TMultiProperty>;
  TMultiPropertyVectorSort=TOrderingArrayUtils<TMultiPropertyVector,TMultiProperty,TMultiPropertyCompare> ;

  TMultiPropertiesManager=class
                               MultiPropertyDictionary:TMyGDBString2TMultiPropertyDictionary;
                               MultiPropertyVector:TMultiPropertyVector;
                               constructor create;
                               destructor destroy;override;
                               procedure reorder(oldsortedid,sortedid:integer;id:TObjID);
                               procedure RegisterMultiproperty(name:GDBString;username:GDBString;var sortedid:integer;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;GetVO,SetVO:GDBInteger;bip:TBeforeIterateProc;aip:TAfterIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc);
                               procedure RegisterFirstMultiproperty(name:GDBString;username:GDBString;var sortedid:integer;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;GetVO,SetVO:GDBInteger;bip:TBeforeIterateProc;aip:TAfterIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc);
                               procedure sort;
                          end;
var
  MultiPropertiesManager:TMultiPropertiesManager;
implementation
class function TMultiPropertyCompare.c(a,b:TMultiProperty):boolean;
begin
  c:=a.sortedid<b.sortedid;
end;
procedure TMultiPropertiesManager.sort;
var
  MultiPropertyVectorSort:TMultiPropertyVectorSort;
begin
     MultiPropertyVectorSort:=TMultiPropertyVectorSort.Create;
     MultiPropertyVectorSort.Sort(MultiPropertyVector,MultiPropertyVector.Size);
end;
procedure TMultiPropertiesManager.RegisterFirstMultiproperty(name:GDBString;username:GDBString;var sortedid:integer;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;GetVO,SetVO:GDBInteger;bip:TBeforeIterateProc;aip:TAfterIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc);
begin
     sortedid:=1;
     RegisterMultiproperty(name,username,sortedid,ptm,category,id,GetVO,SetVO,bip,aip,eip,ECP);
end;
procedure TMultiPropertiesManager.reorder(oldsortedid,sortedid:integer;id:TObjID);
var
   i,addvalue:integer;
   mp:TMultiPropertyDataForObjects;
begin
     addvalue:=sortedid-oldsortedid;
     for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
     if not MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(id,mp)  then
     if MultiPropertiesManager.MultiPropertyVector[i].sortedid>=oldsortedid then
                                                                                inc(MultiPropertiesManager.MultiPropertyVector[i].sortedid,addvalue);
end;

procedure TMultiPropertiesManager.RegisterMultiproperty(name:GDBString;username:GDBString;var sortedid:integer;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;GetVO,SetVO:GDBInteger;bip:TBeforeIterateProc;aip:TAfterIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc);
var
   mp:TMultiProperty;
   mpdfo:TMultiPropertyDataForObjects;
begin
     username:=InterfaceTranslate('oimultiproperty_'+name+'~',username);
     if MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(name,mp) then
                                                        begin
                                                             if mp.MPCategory<>category then
                                                                                            shared.FatalError('Category error in "'+name+'" multiproperty');
                                                             mp.BeforeIterateProc:=bip;
                                                             mp.AfterIterateProc:=aip;
                                                             mpdfo.EntIterateProc:=eip;
                                                             mpdfo.EntChangeProc:=ecp;
                                                             mpdfo.GetValueOffset:=GetVO;
                                                             mpdfo.SetValueOffset:=SetVO;
                                                             mp.MPUserName:=username;
                                                             if mp.sortedid>=sortedid then
                                                                                         sortedid:=mp.sortedid
                                                                                     else
                                                                                         begin
                                                                                          reorder(mp.sortedid,sortedid,id);
                                                                                          //shared.HistoryOutStr('Something wrong in multipropertys sorting "'+name+'"');
                                                                                         end;
                                                             mp.MPObjectsData.RegisterKey(id,mpdfo);
                                                        end
                                                    else
                                                        begin
                                                             mp:=TMultiProperty.create(name,sortedid,ptm,category,bip,aip,eip);
                                                             mpdfo.EntIterateProc:=eip;
                                                             mpdfo.EntChangeProc:=ecp;
                                                             mpdfo.GetValueOffset:=GetVO;
                                                             mpdfo.SetValueOffset:=SetVO;
                                                             mp.MPUserName:=username;
                                                             mp.MPObjectsData.RegisterKey(id,mpdfo);
                                                             MultiPropertiesManager.MultiPropertyDictionary.insert(name,mp);
                                                             MultiPropertiesManager.MultiPropertyVector.PushBack(mp);
                                                        end;
   inc(sortedid);
end;
constructor TMultiProperty.create;
begin
     MPName:=_name;
     MPType:=ptm;
     MPCategory:=_category;
     sortedid:=_sortedid;
     self.AfterIterateProc:=aip;
     self.BeforeIterateProc:=bip;
     MPObjectsData:=TObjID2MultiPropertyProcs.create;
end;
constructor TMultiPropertiesManager.create;
begin
     MultiPropertyDictionary:=TMyGDBString2TMultiPropertyDictionary.create;
     MultiPropertyVector:=TMultiPropertyVector.Create;
end;
destructor TMultiPropertiesManager.destroy;
begin
     MultiPropertyDictionary.Free;
     MultiPropertyVector.Free;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('zcmultiproperties.initialization');{$ENDIF}
  MultiPropertiesManager:=TMultiPropertiesManager.Create;
finalization
  MultiPropertiesManager.Free;
end.