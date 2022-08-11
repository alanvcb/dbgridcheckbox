unit DBGridCheckBoxXP;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Graphics, Grids, DBGrids, DB,
  DBCtrls, Math, ExtCtrls, StrUtils, VDBConsts, DBConsts,ImgList,Vcl.Dialogs;

type TCheckBoxStyle = (cbsOld, cbsXP,cbsSeven,cbsCustom);

//http://www.delphipages.com/forum/showthread.php?t=170968

type
  TCustomDBGridCheckBoxXP = class(TCustomDBGrid)
  private
    mDataFieldName: string;
    mShowGridLines: Boolean;
    mNextValue: Boolean;
    Desenha: Boolean;
    ImagemCHK   : TBitmap;
    ImagemNCHK  : TBitmap;
    mStyle: TCheckBoxStyle;
    mImages: TCustomImageList;
    mCheckedImageIndex,munCheckedImageIndex: TImageIndex;
    mCheckedValue,munCheckedValue: Variant;
    mAllChecked: Boolean;
    function FindPosItem(const item: String): Integer;
    procedure SetDataFieldName(const Value: string);
    procedure SetShowGridLines(AValue: Boolean);
    procedure UpdateDataCheck(MouseDown: Boolean);
    procedure SetNextValue(const Value: Boolean);
    procedure DrawCheck( ACanvas: TCanvas; const ARect: TRect; Checked:Boolean );
    procedure SetImages(const Value: TCustomImageList);
    procedure setCheckedImageIndex(const Value: TImageIndex);
    procedure setStyle(const Value: TCheckBoxStyle);
    procedure setunCheckedImageIndex(const Value: TImageIndex);
    function myTitleClick(Column: TColumn): Boolean;
    procedure TitleClick(Column: TColumn); override;
    procedure AfterConstruction; override;
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure DblClickCheck(Sender: TObject);
    property DataField: string read mDataFieldName write SetDataFieldName;
    property ShowGridLines: Boolean read mShowGridLines write SetShowGridLines;
    procedure DrawColumnCell(const Rect: TRect; DataCol: Integer;
      Column: TColumn; State: TGridDrawState); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    property ProximoValor: Boolean read mNextValue write SetNextValue;
    property CheckBoxStyle        : TCheckBoxStyle read mStyle write setStyle;
    property Images               : TCustomImageList read mImages write SetImages;
    property CheckedImageIndex    : TImageIndex read mCheckedImageIndex write setCheckedImageIndex default -1;
    property unCheckedImageIndex  : TImageIndex read munCheckedImageIndex write setunCheckedImageIndex default -1;
    property CheckedValue         : Variant read mCheckedValue write mCheckedValue;
    property unCheckedValue       : Variant read munCheckedValue write munCheckedValue;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
  end;

  TDBGridCheckBoxXP = class(TCustomDBGridCheckBoxXP)
  public
    property Canvas;
    property SelectedRows;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property Columns stored False; //StoreColumns;
    property Constraints;
    property Ctl3D;
    property DataSource;
    property DataField;
    property DefaultDrawing;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DrawingStyle;
    property Enabled;
    property FixedColor;
    property GradientEndColor;
    property GradientStartColor;
    property Font;
    property ImeMode;
    property ImeName;
    property Options;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TitleFont;
    property Touch;
    property Visible;
    property OnCellClick;
    property OnColEnter;
    property OnColExit;
    property OnColumnMoved;
    property OnDrawDataCell;  { obsolete }
    property OnDrawColumnCell;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditButtonClick;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDock;
    property OnStartDrag;
    property OnTitleClick;
    property CheckBoxStyle;
    property Images;
    property CheckedImageIndex;
    property unCheckedImageIndex;
    property CheckedValue;
    property unCheckedValue;
  end;

procedure Register;

implementation

var
  DrawBitmap: TBitmap;
  UserCount: Integer;

{$R DBGridCheckBoxXP.res}

procedure UsesBitmap;
begin
  if UserCount = 0 then
    DrawBitmap := TBitmap.Create;
  Inc(UserCount);
end;

procedure ReleaseBitmap;
begin
  Dec(UserCount);
  if UserCount = 0 then DrawBitmap.Free;
end;

{procedure DrawCheck( ACanvas: TCanvas; const ARect: TRect; Checked:Boolean );
var
  TempRect   : TRect;
  OrigRect   : TRect;
  Dimension  : Integer;
  OldColor   : TColor;
  OldPenWidth: Integer;
  OldPenColor: TColor;
  B          : TRect;
  DrawBitmap : TBitmap;
  ImagemXP   : TBitmap;
begin
  OrigRect := ARect;
  DrawBitmap := TBitmap.Create;
  ImagemXP   := TBitmap.Create;
  try
    DrawBitmap.Canvas.Brush.Color := ACanvas.Brush.Color;
    with DrawBitmap, OrigRect do
    begin
      Height := Max(Height, Bottom - Top);
      Width := Max(Width, Right - Left);
      B := Rect(0, 0, Right - Left, Bottom - Top);
    end;
    with DrawBitmap, OrigRect do ACanvas.CopyRect(OrigRect, Canvas, B);
    TempRect := OrigRect;
    TempRect.Top:=TempRect.Top+1;
    TempRect.Bottom:=TempRect.Bottom+1;
    with TempRect do
    begin
      Dimension := ACanvas.TextHeight('W');
      Top    := ((Bottom+Top)-Dimension) shr 1;
      Bottom := Top+Dimension;
      Left   := ((Left+Right)-Dimension) shr 1;
      Right  := Left+Dimension;
    end;
    If Checked then
      ImagemXP.Handle := LoadBitmap( , 'CHECKED')
    else
      ImagemXP.Handle := LoadBitmap(MyHandle, 'UNCHECKED');

    ACanvas.Draw(TempRect.Left + 1,TempRect.Top + 1, ImagemXP);
(*    Frame3d(ACanvas,TempRect,clBtnShadow,clBtnHighLight,1);
    Frame3d(ACanvas,TempRect,clBlack,clBlack,1);
    with ACanvas do
    begin
      OldColor    := Brush.Color;
      OldPenWidth := Pen.Width;
      OldPenColor := Pen.Color;
      Brush.Color := clWindow;
      FillRect(TempRect);
    end;
    if Checked then
    begin
      with ACanvas,TempRect do
      begin
        Pen.Color := clBlack;
        Pen.Width := 1;
        MoveTo( Left+1,Top+2 );
        LineTo( Right-2,Bottom-1);
        MoveTo( Left+1,Top+1);
        LineTo( Right-1,Bottom-1);
        MoveTo( Left+2,Top+1);
        LineTo( Right-1,Bottom-2);

        MoveTo( Left+1,Bottom-3);
        LineTo( Right-2,Top);
        MoveTo( Left+1,Bottom-2);
        LineTo( Right-1,Top);
        MoveTo( Left+2,Bottom-2);
        LineTo( Right-1,Top+1);
      end;
    end;
    ACanvas.Pen.Color  := OldPenColor;
    ACanvas.Pen.Width  := OldPenWidth;
    ACanvas.Brush.Color:= OldColor;  *)
  finally
    DrawBitmap.Free;
    ImagemXP.Free;
  end;
end;            }

procedure WriteText(ACanvas: TCanvas; ARect: TRect; DX, DY: Integer;
  const Text: string; Alignment: TAlignment; ARightToLeft: Boolean);
const
  AlignFlags : array [TAlignment] of Integer =
    ( DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_RIGHT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX );
  RTL: array [Boolean] of Integer = (0, DT_RTLREADING);
var
  B, R: TRect;
  Hold, Left: Integer;
  I: TColorRef;
begin
  I := ColorToRGB(ACanvas.Brush.Color);
  if GetNearestColor(ACanvas.Handle, I) = I then
  begin                       { Use ExtTextOut for solid colors }
    { In BiDi, because we changed the window origin, the text that does not
      change alignment, actually gets its alignment changed. }
    if (ACanvas.CanvasOrientation = coRightToLeft) and (not ARightToLeft) then
      ChangeBiDiModeAlignment(Alignment);
    case Alignment of
      taLeftJustify:
        Left := ARect.Left + DX;
      taRightJustify:
        Left := ARect.Right - ACanvas.TextWidth(Text) - 3;
    else { taCenter }
      Left := ARect.Left + (ARect.Right - ARect.Left) shr 1
        - (ACanvas.TextWidth(Text) shr 1);
    end;
    ACanvas.TextRect(ARect, Left, ARect.Top + DY, Text);
  end
  else
  begin                  { Use FillRect and Drawtext for dithered colors }
    DrawBitmap.Canvas.Lock;
    try
      with DrawBitmap, ARect do { Use offscreen bitmap to eliminate flicker and }
      begin                     { brush origin tics in painting / scrolling.    }
        Width := Max(Width, Right - Left);
        Height := Max(Height, Bottom - Top);
        R := Rect(DX, DY, Right - Left - 1, Bottom - Top - 1);
        B := Rect(0, 0, Right - Left, Bottom - Top);
      end;
      with DrawBitmap.Canvas do
      begin
        Font := ACanvas.Font;
        Font.Color := ACanvas.Font.Color;
        Brush := ACanvas.Brush;
        Brush.Style := bsSolid;
        FillRect(B);
        SetBkMode(Handle, TRANSPARENT);
        if (ACanvas.CanvasOrientation = coRightToLeft) then
          ChangeBiDiModeAlignment(Alignment);
        DrawText(Handle, PChar(Text), Length(Text), R,
          AlignFlags[Alignment] or RTL[ARightToLeft]);
      end;
      if (ACanvas.CanvasOrientation = coRightToLeft) then
      begin
        Hold := ARect.Left;
        ARect.Left := ARect.Right;
        ARect.Right := Hold;
      end;
      ACanvas.CopyRect(ARect, DrawBitmap.Canvas, B);
    finally
      DrawBitmap.Canvas.Unlock;
    end;
  end;
end;

{ TCustomDBGridCheckBoxXP }

procedure TCustomDBGridCheckBoxXP.AfterConstruction;
begin
  inherited AfterConstruction;
end;

constructor TCustomDBGridCheckBoxXP.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ReadOnly := True;
  mAllChecked := False;
  ShowGridLines := True;
  Options := [dgTitles, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection,dgTitleClick];
  OnDblClick := DblClickCheck;
  ProximoValor := True;
  Desenha := True;
  ImagemCHK := TBitmap.Create;
  ImagemNCHK := TBitmap.Create;
  Images := nil;
  mStyle := cbsXP;
  mCheckedValue := 'S';
  munCheckedValue := 'N';
  mCheckedImageIndex := -1;
  munCheckedImageIndex := -1;
end;

destructor TCustomDBGridCheckBoxXP.Destroy;
begin
  inherited Destroy;
  FreeAndNil(ImagemCHK);
  FreeAndNil(ImagemNCHK);
  Images := nil;
end;

function TCustomDBGridCheckBoxXP.FindPosItem(const Item: String): Integer;
var
  I: Integer;
begin
  for I := 0 to Columns.Count - 1 do
  begin
    if Columns.Items[I].FieldName = Item then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure TCustomDBGridCheckBoxXP.DblClickCheck(Sender: TObject);
begin
  UpdateDataCheck(True);
end;

procedure TCustomDBGridCheckBoxXP.DrawCell(ACol, ARow: Longint;
  ARect: TRect; AState: TGridDrawState);
var
  L_Col: Integer;
begin
  if dgIndicator in Options then
    L_Col := ACol - 1
  else
    L_Col := ACol;

  inherited;
  if (L_Col > -1) and (ARow = 0) and (Columns[L_Col].FieldName = Self.DataField ) and (gdFixed in AState) then
  begin
    DrawCheck(Canvas,ARect,mAllChecked);
      //FImagelist.Draw(Canvas,ARect.Right - 18, ARect.Bottom - 18,0); // would cause more flickering
  end;
end;

procedure TCustomDBGridCheckBoxXP.DrawCheck(ACanvas: TCanvas; const ARect: TRect; Checked: Boolean);
var
  TempRect   : TRect;
  OrigRect   : TRect;
  Dimension  : Integer;
  OldColor   : TColor;
  OldPenWidth: Integer;
  OldPenColor: TColor;
  B          : TRect;
begin
  OrigRect := ARect;
  DrawBitmap := TBitmap.Create;

  try
    SetBkMode(Handle, TRANSPARENT);
    DrawBitmap.Canvas.Brush.Color := ACanvas.Brush.Color;
    with DrawBitmap, OrigRect do
    begin
      Height := Max(Height, Bottom - Top);
      Width := Max(Width, Right - Left);
      B := Rect(0, 0, Right - Left, Bottom - Top);
    end;
    with DrawBitmap, OrigRect do ACanvas.CopyRect(OrigRect, Canvas, B);
    TempRect := OrigRect;
    TempRect.Top:=TempRect.Top+1;
    TempRect.Bottom:=TempRect.Bottom+1;

    Dimension := ACanvas.TextHeight('W');

    if (TempRect.Bottom + TempRect.Top) < Dimension then
      Exit;

    TempRect.Top    := ((TempRect.Bottom + TempRect.Top) - Dimension) shr 1;
    TempRect.Bottom := TempRect.Top + Dimension;

    if (TempRect.Left + TempRect.Right) < Dimension then
      Exit;

    TempRect.Left   := ((TempRect.Left + TempRect.Right) - Dimension) shr 1;
    TempRect.Right  := TempRect.Left + Dimension;

    if Desenha then
    begin
      Frame3d(ACanvas,TempRect,clBtnShadow,clBtnHighLight,1);
      Frame3d(ACanvas,TempRect,clBlack,clBlack,1);
      with ACanvas do
      begin
        OldColor    := Brush.Color;
        OldPenWidth := Pen.Width;
        OldPenColor := Pen.Color;
        Brush.Color := clWindow;
        FillRect(TempRect);
      end;
      if Checked then
      begin
        with ACanvas,TempRect do
        begin
          Pen.Color := clBlack;
          Pen.Width := 1;
          MoveTo( Left+1,Top+2 );
          LineTo( Right-2,Bottom-1);
          MoveTo( Left+1,Top+1);
          LineTo( Right-1,Bottom-1);
          MoveTo( Left+2,Top+1);
          LineTo( Right-1,Bottom-2);

          MoveTo( Left+1,Bottom-3);
          LineTo( Right-2,Top);
          MoveTo( Left+1,Bottom-2);
          LineTo( Right-1,Top);
          MoveTo( Left+2,Bottom-2);
          LineTo( Right-1,Top+1);
        end;
      end;
      ACanvas.Pen.Color  := OldPenColor;
      ACanvas.Pen.Width  := OldPenWidth;
      ACanvas.Brush.Color:= OldColor;
    end
    else
    begin
      if Checked then
        ACanvas.Draw(TempRect.Left + 1,TempRect.Top + 1, ImagemCHK)
      else
        ACanvas.Draw(TempRect.Left + 1,TempRect.Top + 1, ImagemNCHK);
    end;

  finally
    DrawBitmap.Free;
  end;
end;

procedure TCustomDBGridCheckBoxXP.DrawColumnCell(const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Value: string;
begin
  Value := '';
  if Assigned(Column.Field) then
    Value := Column.Field.DisplayText;
  //Drawcell
  if Assigned(Column.Field) and (Column.Field.FieldName = DataField) then
  begin
    DrawCheck(Canvas, Rect, Value = mCheckedValue );
  end
  else
  begin
    WriteText(Canvas, Rect, 2, 2, Value, Column.Alignment,
      UseRightToLeftAlignmentForField(Column.Field, Column.Alignment));
    inherited;
  end;

end;

procedure TCustomDBGridCheckBoxXP.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Char(Key) = #32 then
    UpdateDataCheck(False);
  inherited;
end;

function TCustomDBGridCheckBoxXP.myTitleClick(Column: TColumn): Boolean;
var ds: TDataSet;
rec: Integer;
begin
  Result := False;
  if Column.Field.FieldName = DataField then
  begin
    try
      Result := True;
      ds := DataLink.DataSet;
      ds.DisableControls;
      rec := ds.RecNo;
      mAllChecked := not mAllChecked;

      ds.First;
      while not ds.Eof do
      begin
        ds.Edit;

        if mAllChecked then
          ds.FieldByName(Self.DataField).Value := mCheckedValue
        else
          ds.FieldByName(Self.DataField).Value := munCheckedValue;

        ds.Post;
        ds.Next;
      end;
     finally
      ds.RecNo := rec;
      ds.EnableControls;
    end;
  end;
end;

procedure TCustomDBGridCheckBoxXP.setCheckedImageIndex(
  const Value: TImageIndex);
begin
  mCheckedImageIndex  := Value;
  if (Value <> -1)  and (mStyle = cbsCustom) and assigned(mImages) then
  begin
    mImages.Draw(ImagemCHK.Canvas,0,0,Value);
  end;
end;

procedure TCustomDBGridCheckBoxXP.SetShowGridLines(AValue: Boolean);
begin
  if mShowGridLines <> AValue then
  begin
    mShowGridLines := AValue;
    if AValue then
      Options := Options + [dgRowLines, dgColLines]
    else
      Options := Options - [dgRowLines, dgColLines];
  end;
end;

procedure TCustomDBGridCheckBoxXP.setStyle(const Value: TCheckBoxStyle);
begin
  try
    mStyle := Value;
    Desenha := False;
    case mStyle of
      cbsOld: Desenha := True;
      cbsXP : begin
                ImagemCHK.LoadFromResourceName(HInstance,'XP_CHECKED');
                ImagemNCHK.LoadFromResourceName(HInstance,'XP_UNCHECKED');
              end;

      cbsSeven: begin
                  ImagemCHK.LoadFromResourceName(HInstance,'SV_CHECKED');
                  ImagemNCHK.LoadFromResourceName(HInstance,'SV_UNCHECKED');
                end;
    end;
  except
    Desenha := True;
  end;
end;

procedure TCustomDBGridCheckBoxXP.setunCheckedImageIndex(
  const Value: TImageIndex);
begin
  munCheckedImageIndex := Value;
  if (Value <> -1)  and (mStyle = cbsCustom) and assigned(mImages) then
  begin
    mImages.Draw(ImagemNCHK.Canvas,0,0,Value);
  end;
end;

procedure TCustomDBGridCheckBoxXP.TitleClick(Column: TColumn);
begin
  if not myTitleClick(Column) then
    inherited;
end;

procedure TCustomDBGridCheckBoxXP.SetDataFieldName(const Value: string);
begin
  if mDataFieldName <> Value then
  begin
    mDataFieldName := Value;
    Repaint;
  end;
end;

procedure TCustomDBGridCheckBoxXP.SetImages(const Value: TCustomImageList);
begin
  if Value <> mImages then
  begin
    mImages := Value;
  end
end;

procedure TCustomDBGridCheckBoxXP.UpdateDataCheck(MouseDown: Boolean);
var
  Index: Integer;
  str: string;
begin
  if DataLink.DataSet.IsEmpty then
    Exit;
  if DataLink.Active and not DataLink.DataSet.FieldByName(DataField).ReadOnly then
  begin
    Index := FindPosItem(DataField);
    if Index <> -1 then
    begin
      DataLink.Modified;
      if not (DataLink.DataSet.State in [dsEdit, dsInsert]) then
        DataLink.Edit;

      case DataLink.DataSet.FieldByName(DataField).FieldKind of
        fkData         : str := 'fkData';
        fkCalculated   : str := 'fkCalculated';
        fkLookup       : str := 'fkLookup';
        fkInternalCalc : str := 'fkInternalCalc';
        fkAggregate    : str := 'fkAggregate';
      end;

      if (Columns.Items[Index].Field.Value = mCheckedValue) then
        DataLink.DataSet.FieldByName(DataField).Value := munCheckedValue
      else
        DataLink.DataSet.FieldByName(DataField).Value := mCheckedValue;

      if MouseDown then
      begin
        DataLink.DataSet.Post
      end
      else if (not MouseDown) and (ProximoValor)  then
      begin
        DataLink.DataSet.Next;
      end;
    end;
  end;
end;

procedure TCustomDBGridCheckBoxXP.SetNextValue(const Value: Boolean);
begin
  mNextValue := Value;
end;

procedure Register;
begin
  RegisterComponents('Data Controls', [TDBGridCheckBoxXP]);
end;

end.
