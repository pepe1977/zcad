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
unit uzcfdimstyles;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TDimStylesForm }

  TDimStylesForm = class(TForm)
    Label1: TLabel;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  DimStylesForm: TDimStylesForm;

implementation

{$R *.lfm}

end.
