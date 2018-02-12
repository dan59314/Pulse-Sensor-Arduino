unit Main;

interface

{$IF defined(Win32) or defined(Win64)}
  {$DEFINE Windows}
{$ENDIF}


uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Math.Vectors,

  {$IFDEF Windows}
  System.Win.Registry, WinApi.Windows,
  {$ENDIF}
  {$IFDEF Android}
  Android.JNI.Toast,
  {$ENDIF}
  Math,


  {$IFDEF DelphiXE10_Up}
  FMX.ScrollBox,
  {$ENDIF}
  FMX.Forms, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.ComboEdit,
  FMX.Controls, FMX.Types, FMX.Layouts, FMX.ListBox, FMX.Memo, FMX.Graphics,
  FMX.Objects, FMX.TabControl,



  RenderBoxFMX,


  // /WebLib ----------------------------------------------
  OpenViewUrl,

  // RastLib -----------------------------------------------
  RastTypeDefine, RastManage,RastPaint, RastCanvasPaint,

  // M2dLib -------------------------------------------
  M2dTypeDefine, M2dGVariable,

  {$IFDEF Windows}
  WinComportManage,
  {$ENDIF}

  {$IFDEF Android}
  AndroidBlueToothManage,
  {$ENDIF}

  CrsFileTypeDefine,

  MscMessageDefine, StringManage, MscUtility, FMX.ScrollBox

  ;


const
  funcOutputPulse = 1;
  funcAveragePulse= 2;
  funcOneColorFadding =4;
  func4 = 8;
  func5 = 16;
  func6 = 32;
  func7 = 64;
  func8 = 128;

var
  gFunctions :byte = 0;


type
  PPulse=^TPulse;
  TPulse=record
    psValue:word;
    psTime:Cardinal;
  end;

  TPulseList=TList; //list of PPulse;

type
  TForm1 = class(TForm)
    TabControl1: TTabControl;
    Setting: TTabItem;
    Layout1: TLayout;
    btnDiscover: TButton;
    btnConnect: TButton;
    btnDisconnect: TButton;
    ListBox1: TListBox;
    Moniter: TTabItem;
    Layout2: TLayout;
    Layout3: TLayout;
    SpeedButton1: TSpeedButton;
    ckbxAutoScroll: TCheckBox;
    ckbxPulse: TCheckBox;
    ckbxAvgPulse: TCheckBox;
    ckbxOneClr: TCheckBox;
    loPulse: TLayout;
    Memo1: TMemo;
    lblRasVector: TLabel;
    pnlHeartBeat: TPanel;
    Layout7: TLayout;
    rbHeartBeat: TRenderBoxFmx;
    pnlPulse: TPanel;
    Layout6: TLayout;
    rbPulse: TRenderBoxFmx;
    lblPulse: TLabel;
    lblHeartBeat: TLabel;
    tkbarMinHeartBeat: TTrackBar;
    tkbarMaxHeartBeat: TTrackBar;
    tkbarMinPulse: TTrackBar;
    tkbarMaxPulse: TTrackBar;
    ckbxReceiveData: TCheckBox;
    ckbxUpdateMemo: TCheckBox;
    ckbxTrimPulse: TCheckBox;
    Splitter1: TSplitter;
    tkbarMsecPerPxl: TTrackBar;
    procedure lblRasVectorClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnDiscoverClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ckbxReceiveDataChange(Sender: TObject);
    procedure ckbxPulseChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure rbPulsePaint(Sender: TObject; Canvas: TCanvas);
    procedure rbHeartBeatPaint(Sender: TObject; Canvas: TCanvas);
    procedure FormResize(Sender: TObject);
    procedure tkbarMinHeartBeatChange(Sender: TObject);
    procedure tkbarMaxHeartBeatChange(Sender: TObject);
    procedure tkbarMinPulseChange(Sender: TObject);
    procedure tkbarMaxPulseChange(Sender: TObject);
    procedure tkbarMsecPerPxlChange(Sender: TObject);
  private
    {$IFDEF UsePolygon}
    FPulsePolyLine:TPolygon;
    {$ELSE}
    FWavePath:TPathData;
    FHeartBeatPath:TPathData;
    {$ENDIF}
    FMaxPulseCount: integer;
    FMaxHeartBeatCount: integer;
    FPulseScale,FHeartBeatScale: TFloat;
    FMaxPulse:word;
    FMinPulse:Word;
    FMinHeartBeat, FMaxHeartBeat:Word;
    FPulseList:TPulseList;
    FHeartBeatList:TPulseList;
    FMSecPerPixel:TFloat;
    FWaveHeadPixelSpace:TFloat; //integer;
    FStopSense:boolean;

    procedure SetMaxHeartBeatCount(const Value: integer);
    procedure SetMaxPulseCount(const Value: integer);
    procedure SetPulseScale(const Value: TFloat);
    procedure SetMaxHeartBeat(const Value: Word);
    procedure SetMaxPulse(const Value: Word);
    procedure SetMinHeartBeat(const Value: Word);
    procedure SetMinPulse(const Value: Word);
    { Private declarations }
  protected
    procedure CreateMembers;
    procedure InitialMembers;
    procedure ReleaseMembers;


    // 編輯 --------------------------------------------------------------
    procedure Add_Pulse(const pulseLst:TPulseList; maxCnt:integer; pulseVal:integer; pulseTime:Cardinal);
    procedure Clear_TPulseList(const pulseLst:TPulseList);

    function  Get_PulseTotoalMSec:Cardinal;
    procedure Process_PulseString(const sPulse:String);


    // 介面 -------------------------------------------------------------
    procedure RefreshInterface_Resize;

    // Event -----------------------------------------------------
    procedure ReceiveString_PC(Sender: TObject; const aStr:AnsiString);

  public
    { Public declarations }
    property MaxPulseCount:integer read FMaxPulseCount write SetMaxPulseCount;
    property MaxHeartBeatCount:integer read FMaxHeartBeatCount write SetMaxHeartBeatCount;
    property PulseScale:TFloat read FPulseScale write SetPulseScale;
    property MinPulse:Word read FMinPulse write SetMinPulse;
    property MaxPulse:Word read FMaxPulse write SetMaxPulse;
    property MinHeartBeat:Word read FMinHeartBeat write SetMinHeartBeat;
    property MaxHeartBeat:Word read FMaxHeartBeat write SetMaxHeartBeat;

  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}

procedure TForm1.Add_Pulse(const pulseLst:TPulseList; maxCnt:integer; pulseVal: integer; pulseTime: Cardinal);
var
  pPs:PPulse;
begin
  if (nil=pulseLst) then exit;
  
  if (pulseLst.Count>=maxCnt) then
  begin
    Dispose( PPulse(pulseLst[0]));
    pulseLst[0] := nil;
    pulseLst.Delete(0);
  end;

  new(pPs);
  pPs^.psValue := pulseVal;
  pPs^.psTime := pulseTime;

  pulseLst.Add(pPs);
end;

procedure TForm1.btnConnectClick(Sender: TObject);
var
  aId:integer;
  blIsConnect:boolean;
begin

  blIsConnect:=false;

  {$IFDEF Android}
    {$IFDEF WifiUdp}
    IdUdpClient1.Host := edIp.Text; // '192.168.3.29'; //
    IdUdpClient1.Port :=  StrToInt(edPort.Text); //8087;
    DoToast( format('%s ( %s )...',[gVerbTypeName[vbConnect], edIp.Text ]) );
    loPins.Enabled := true;
    {$ENDIF}
    {$IFDEF BlueTooth}
    aId := ListBox1.ItemIndex;
    if (aId<0) or (aId>=Listbox1.Items.Count) then exit;

    with AndroidBlueToothManager do
    begin
      //DisConnect;

      if (aId>=0) and (aId<BlueToothDevices.Count) then
      if Connect_TBlueToothDevice( PBlueToothDevice(BlueToothDevices[aId])^) then
      begin
        DoToast('Connected.');
        blIsConnect:=true;
      end
      else
       ;
    end;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF Windows}
  WinComportManager.CloseComport;

  aId := ListBox1.ItemIndex;
  if (aId<0) or (aId>=Listbox1.Items.Count) then exit;

  if WinComportManager.OpenComport(StrToInt(ListBox1.Items[aId])) then
  begin
    blIsConnect := true;
    WinComportManager.SetupCOMPort(115200, 30, 30); // timeOut 不能設太大，否則會拖慢程式
    DoToast('Connected.');
  end
  else
  begin
    DoToast('Not Connected');
  end;
  {$ENDIF}

  ckbxReceiveData.IsChecked := blIsConnect;
  if (blIsConnect) then
  begin
    {ckbxPulse.IsChecked := blIsConnect;
    Sleep(50);
    ckbxPulseChange(ckbxPulse);
    Sleep(100);  }
  end;
end;

procedure TForm1.btnDisconnectClick(Sender: TObject);
begin
  {$IFDEF Android}
    {$IFDEF WifiUdp}
    IdUdpClient1.d
    {$ENDIF}
    {$IFDEF BlueTooth}
    with AndroidBlueToothManager do
    begin
      DisConnect;
    end;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF Windows}
  WinComportManager.CloseComport;
  {$ENDIF}
end;

procedure TForm1.btnDiscoverClick(Sender: TObject);

var
  s1:string;
  strs:TStringList;
  i: Integer;
begin
  //



  ListBox1.Items.Clear;

  {$IFDEF Android}
  with AndroidBlueToothManager do
  begin
    if Discover_Devices() then
    for i := 0 to BlueToothDevices.Count-1 do
    with PBlueToothDevice(BlueToothDevices[i])^ do
    begin
      ListBox1.Items.Add(btDeviceName);
    end;

    if ListBox1.Items.Count>0 then
      DoToast( format('%s %s a Device!',[
         gAdverbTypeName[avPlease], gVerbTypeName[vbConnect]
            ]));
  end;
  {$ENDIF}

  {$IFDEF Windows}
  try
    strs:=TStringList.Create;

    WinComportManager.EnumComPorts(strs);

    {$IFDEF Debug}
    s1:='';
    for i := 0 to strs.Count-1 do
      s1:=s1+strs[i]+#13;
    //ShowMessage(s1);
    {$ENDIF}

    if strs.Count>0 then
    begin
      ListBox1.Items.Clear;
      for i := 0 to strs.Count-1 do
        ListBox1.Items.Add( copy(strs[i],4, length(strs[i])-3));

      ListBox1.ItemIndex := 0;
    end;

  finally
    strs.Free;
  end;
  {$ENDIF}

end;



procedure TForm1.ReceiveString_PC(Sender: TObject; const aStr:AnsiString);
begin
  if (aStr<>'') then
  begin

    Process_PulseString(aStr);

    if ckbxUpdateMemo.IsChecked then
    begin
      if Memo1.Lines.Count>5000 then Memo1.Lines.Clear;

      Memo1.Lines.Add(aStr);
       // Memo1.ScrollTo();
      if ckbxAutoScroll.IsChecked then
        Memo1.GoToTextEnd;
    end;
  end;
end;

procedure TForm1.ckbxPulseChange(Sender: TObject);
var
  shlNum:integer;
  func :Byte;
begin
{$IFDEF Windows}
  with TCheckBox(Sender) do
  begin
    shlNum := Tag;
    func := 1 shl shlNum;

    if IsChecked then
      gFunctions := gFunctions or func
    else
      gFunctions := gFunctions and (not func);

    WinComportManager.SendText( format('FN,%d',[gFunctions]));

    if isChecked then
    begin
      if not ckbxReceiveData.IsChecked then
      begin
        ckbxReceiveData.IsChecked := true;
        ckbxReceiveDataChange(ckbxReceiveData);
      end;
      Self.TabControl1.TabIndex := 1;
    end;
  end;
{$ENDIF}
end;

procedure TForm1.ckbxReceiveDataChange(Sender: TObject);
begin
{$IFDEF Windows}
  if ckbxReceiveData.IsChecked then
    WinComportManager.OnReadString := Self.ReceiveString_PC
  else
    WinComportManager.OnReadString := nil;
{$ENDIF}

end;

procedure TForm1.Clear_TPulseList(const pulseLst: TPulseList);
var
  i:integer;
begin
  if (nil=pulseLst) then exit;

  for i := 0 to pulseLst.Count-1 do
    Dispose( PPulse(pulseLst[i]));

  pulseLst.Clear;


end;

procedure TForm1.CreateMembers;
begin
  FPulseList := TPulseList.Create;
  FHeartBeatList := TPulseList.Create;

  {$IFDEF UsePolygon}
  Setlength(FPulsePolyLine, 0);
  {$ELSE}
  FWavePath:=TPathData.Create;
  FHeartBeatPath:=TPathData.Create;
  {$ENDIF}
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  CreateMembers;
  InitialMembers;

  btnDiscoverClick(Sender);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  ReleaseMembers;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
   RefreshInterface_Resize;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  i:integer;
begin
  TabControl1.TabIndex := 0;


  {$if defined(Android)}
  for i := 0 to Listbox1.Items.Count-1 do
  if Pos('HC05_RasVector', ListBox1.Items[i])>0 then
  begin
    ListBox1.ItemIndex := i;
    btnConnectClick(btnConnect);
    break;
  end;
  {$ELSE if defined(Windows)}
  if (ListBox1.Items.Count>0) then
  begin
    ListBox1.ItemIndex := 0;
    btnConnectClick(btnConnect);
  end;
  //ckbxPulseChange(Sender);
  {$ENDIF}

  RefreshInterface_Resize;

end;

function TForm1.Get_PulseTotoalMSec: Cardinal;
var
  i:integer;
begin
  result:=0;
  if (nil=FPulseList) or (FPulseList.Count<=0) then exit;

  result := FMaxPulseCount*50;

  {for i := 0 to FPulseList.Count-1 do
  with PPulse( FPulseList[i] )^ do
  begin
    result := result + psTime;
  end;  }
end;

procedure TForm1.InitialMembers;
begin
  MaxPulseCount := 100;
  MaxHeartBeatCount := 100;

  MinPulse:=300;
  MaxPulse:=700;
  MinHeartBeat:=10;
  MaxHeartBeat:=200;

  PulseScale :=  (FMaxPulse-FMinPulse)/rbPulse.Height;
  FHeartBeatScale := (FMaxHeartBeat-FMinHeartBeat)/rbHeartBeat.Height;

  FMSecPerPixel := 50;
  FWaveHeadPixelSpace:=rbPulse.Width/5;


end;

procedure TForm1.lblRasVectorClick(Sender: TObject);
begin

  OpenViewUrl.OpenURL(cRasVectorWeb);
end;

procedure TForm1.Process_PulseString(const sPulse: String);
var
  s256:T256Strings;
  incNum:integer;
begin

  if (''=sPulse) then exit;

  StringManager.GetT256Strings(sPulse, ',', incNum, s256);


  if SameText('B', s256[0])  and (incNum>=3) then // HeartBeat, // B, HeartBeat,time
  begin
    lblHeartBeat.Text := s256[1];
    Self.Add_Pulse(FHeartBeatList, 60, StrToInt(s256[1]), StrToInt('$'+s256[2]) );
    rbHeartBeat.Refresh;
  end
  else if SameText('S', s256[0]) and (incNum>=3) then // S,pulse,time
  begin
    lblPulse.Text := s256[1];
    Self.Add_Pulse(FPulseList, FMaxPulseCount, StrToInt(s256[1]), StrToInt('$'+s256[2]) );
    rbPulse.Refresh;
  end;
end;

procedure TForm1.rbHeartBeatPaint(Sender: TObject; Canvas: TCanvas);

  function subHeartBeatToXY(HeartBeat:word; dMSec:Cardinal):TPointF;
  begin
    result.X := (rbHeartBeat.Width-FWaveHeadPixelSpace) - dMSec/FMSecPerPixel/5;
    result.Y := rbHeartBeat.Height-(HeartBeat-FMinHeartBeat)/FHeartBeatScale;
  end;

  procedure subPaint_HeartBeat;
  const
    clNoMrX = $FF0000FF;
    cCenterRad=5;
    cHeartBeatBandW = 3;
  var
    HeartBeatT0:Cardinal;
    shftXY,dtmXY:TPoint;
    cnvXY,priCnvXY,cnvXY0:tPointF;
    cnvW2:integer;
    bkupMtx:TMatrix;
    tmpRect,aRect:TRectF;
    incId, i: integer;
  begin

     if (nil=FHeartBeatList) then exit;
     if FHeartBeatList.Count<1 then exit;


    try
      FWavePath.Clear;
      FHeartBeatPath.Clear;

      // 畫出目前 rbMainView 視匡 --------------------------------------------------
      with Canvas do
      begin
        //BeginScene;   已於 TRederBoxFMx.Paint() 內設定
        //bkupMtx:=Matrix;
        //SetMatrix(AbsoluteMatrix); 已於 TRederBoxFMx.Paint() 內設定

        Stroke.Color := $FF00FFFF;
        Stroke.Kind := pmXor; //pmMerge; // pmOr;
        Stroke.Dash := psDash;
        Fill.Color := clNoMrX;
        Fill.Kind := bsSolid;

        with PPulse(FHeartBeatList.Last)^ do
        begin
          HeartBeatT0 := psTime;
        end;

        incId:=0;
        for i := FHeartBeatList.Count-1 downto 0 do
        with PPulse(FHeartBeatList[i])^ do
        begin
          cnvXY := subHeartBeatToXY(psValue, HeartBeatT0-psTime);
                   
          if (cnvXY.X<0) then
            break;
            
        {$IFDEF UsePolygon}
          FPulsePolyLine[incId] := cnvXY;
          inc(incId);
        {$ELSE}
          if (i=FHeartBeatList.Count-1) then
          begin
            cnvXY0 := cnvXY;

            FWavePath.MoveTo(PointF(cnvXY.X+cHeartBeatBandW, rbHeartBeat.Height-1) );
            FWavePath.LineTo(cnvXY);
            FWavePath.LineTo(PointF(cnvXY.X-cHeartBeatBandW, rbHeartBeat.Height-1) );

            FHeartBeatPath.MoveTo(cnvXY);
          end
          else
          begin
            FWavePath.LineTo(PointF(cnvXY.X+cHeartBeatBandW, rbHeartBeat.Height-1) );
            FWavePath.LineTo(cnvXY);
            FWavePath.LineTo(PointF(cnvXY.X-cHeartBeatBandW, rbHeartBeat.Height-1) );

            FHeartBeatPath.LineTo(cnvXY);
          end;
        {$ENDIF}

        end;


        {$IFDEF UsePolygon}
        Fill.Kind := bsClear;
        DrawPolygon(FPulsePolyLine,1);
        {$ELSE}
        Stroke.Color := $FF00FFFF;
        Canvas.DrawPath(FWavePath, 0.5);

        Stroke.Color := $FF00FF00;
        Canvas.DrawPath(FHeartBeatPath, 1);
        {$ENDIF}

        aRect := RectF(cnvXY0.X-cCenterRad, cnvXY0.Y-cCenterRad,
          cnvXY0.X+cCenterRad, cnvXY0.Y+cCenterRad);
        Canvas.FillEllipse(aRect, 1.0);

        //Canvas.SetMatrix(BkupMtx);
        //Canvas.EndScene();
      end;
    finally
      FWavePath.Clear;
      FHeartBeatPath.Clear;
    end;

  end;
begin
  if TabControl1.TabIndex<>1 then exit;

  //
  RastCanvasPainter.FillCanvas(Canvas, round(rbHeartBeat.Width), round(rbHeartBeat.Height), rbHeartBeat.Color );

  subPaint_HeartBeat;
end;

procedure TForm1.rbPulsePaint(Sender: TObject; Canvas: TCanvas);
  function subPulseToXY(pulse:word; dMSec:Cardinal):TPointF;
  begin
    result.X := (rbPulse.Width-FWaveHeadPixelSpace) - dMSec/FMSecPerPixel;
    result.Y := rbPulse.Height - (pulse-FMinPulse)/FPulseScale;

    if ckbxTrimPulse.isChecked then
    begin
      result.Y := Math.Max(result.Y, 100);
      result.Y := Math.Min(result.Y, rbPulse.Height-100);
    end;
  end;

  procedure subPaint_Pulse;
  const
    clNoMrX = $FF0000FF;
    cCenterRad=5;
  var
    pulseT0:Cardinal;
    shftXY,dtmXY:TPoint;
    cnvXY,priCnvXY,cnvXY0:tPointF;
    cnvW2:integer;
    bkupMtx:TMatrix;
    tmpRect,aRect:TRectF;
    incId, i: integer;
  begin

     if (nil=FPulseList) then exit;
     if FPulseList.Count<2 then exit;
     

    try
      FWavePath.Clear;

      // 畫出目前 rbMainView 視匡 --------------------------------------------------
      with Canvas do
      begin
        //BeginScene;   已於 TRederBoxFMx.Paint() 內設定
        //bkupMtx:=Matrix;
        //SetMatrix(AbsoluteMatrix); 已於 TRederBoxFMx.Paint() 內設定

        Stroke.Color := $FFA0A0A0;
        Stroke.Kind := pmXor; //pmMerge; // pmOr;
        Stroke.Dash := psDash;
        Fill.Color := clNoMrX;
        Fill.Kind := bsSolid;

        with PPulse(FPulseList.Last)^ do
        begin
          pulseT0 := psTime;
        end;

        incId:=0;
        for i := FPulseList.Count-1 downto 0 do
        with PPulse(FPulseList[i])^ do
        begin
          cnvXY := subPulseToXY(psValue, pulseT0-psTime);
                  
          if (cnvXY.X<0.0) then
            break;

        {$IFDEF UsePolygon}
          FPulsePolyLine[incId] := cnvXY;
          inc(incId);
        {$ELSE}
          if (i=FPulseList.Count-1) then
          begin
            cnvXY0:=cnvXY;
            FWavePath.MoveTo(cnvXY)
          end
          else
            FWavePath.LineTo(cnvXY);
        {$ENDIF}


        end;


        {$IFDEF UsePolygon}
        Fill.Kind := bsClear;
        DrawPolygon(FPulsePolyLine,1);
        {$ELSE}
        Canvas.DrawPath(FWavePath, 1);
        {$ENDIF}

        aRect := RectF(cnvXY0.X-cCenterRad, cnvXY0.Y-cCenterRad,
          cnvXY0.X+cCenterRad, cnvXY0.Y+cCenterRad);
        Canvas.FillEllipse(aRect, 1.0);

        //Canvas.SetMatrix(BkupMtx);
        //Canvas.EndScene();
      end;
    finally
      FWavePath.Clear;
    end;

  end;
begin

  if TabControl1.TabIndex<>1 then exit;
    //
  RastCanvasPainter.FillCanvas(Canvas, round(rbPulse.Width), round(rbPulse.Height), rbPulse.Color );

  subPaint_Pulse;
end;

procedure TForm1.RefreshInterface_Resize;
  procedure subRefreshInterface_Horizontal;
  var
    aSize:Single;
  begin
    aSize:=Self.Width / 2 ;
    pnlHeartBeat.Width := aSize;
    pnlHeartBeat.Align := TAlignLayOut.Left;
    splitter1.Align :=   TAlignLayOut.Left;
  end;
  procedure subRefreshInterface_Vertical;
  var
    aSize:Single;
  begin
    aSize := Self.Height / 2;
    pnlHeartBeat.Height := aSize;
    pnlHeartBeat.Align := TAlignLayOut.Top;
    splitter1.Align :=   TAlignLayOut.Top;
  end;
  procedure subUpdate_Variables;
  begin
    FPulseScale := (FMaxPulse-FMinPulse)/rbPulse.Height;
    FHeartBeatScale := (FMaxHeartBeat-FMinHeartBeat)/rbHeartBeat.Height;
    FMSecPerPixel := Math.Max(10, Get_PulseTotoalMSec  /rbPulse.Width);
    FWaveHeadPixelSpace := rbPulse.Width/5;
  end;
begin

  splitter1.Align := TAlignLayOut.None;
  pnlHeartBeat.Align := TAlignLayOut.None;
  TabControl1.Align := TAlignLayout.None;

  if (Self.width<Self.Height) then
    subRefreshInterface_Vertical
  else
    subRefreshInterface_Horizontal;

  TabControl1.Align := TAlignLayout.Client;

  subUpdate_Variables;
end;

procedure TForm1.ReleaseMembers;
begin
  Self.Clear_TPulseList(FPulseList);
  FPulseList.Free;

  Self.Clear_TPulseList(FHeartBeatList);
  FHeartBeatList.Free;

  {$IFDEF UsePolygon}
  Setlength(FPulsePolyLine, 0);
  {$ELSE}
  FWavePath.Clear;
  FWavePath.Free;
  FHeartBeatPath.Clear;
  FHeartBeatPath.Free;
  {$ENDIF}
end;

procedure TForm1.SetMaxHeartBeat(const Value: Word);
begin
  FMaxHeartBeat := Value;
  FHeartBeatScale := (FMaxHeartBeat-FMinHeartBeat)/rbHeartBeat.Height;
  rbHeartBeat.Refresh;

  try
    FStopSense := true;
    tkbarMaxHeartBeat.Value := FMaxHeartBeat;
  finally
    FStopSense := false;
  end;
end;

procedure TForm1.SetMaxHeartBeatCount(const Value: integer);
begin
  FMaxHeartBeatCount := Value;
end;

procedure TForm1.SetMaxPulse(const Value: Word);
begin
  FMaxPulse := Value;
  FPulseScale := (FMaxPulse-FMinPulse)/rbPulse.Height;
  rbPulse.Refresh;

  try
    FStopSense := true;
    tkbarMaxPulse.Value := FMaxPulse;
  finally
    FStopSense := false;
  end;
end;

procedure TForm1.SetMaxPulseCount(const Value: integer);
var
  i:integer;
begin
  FMaxPulseCount := Math.Max(1, Math.Min(Value, 65535));

  i:=0;
  while (FPulseList.Count>FMaxPulseCount) do
  begin
    Dispose(PPulse(FPulseList[0]));
    FPulseList.Delete(0);
  end;


  {$IFDEF UsePolygon}
  Setlength(FPulsePolyLine, FMaxPulseCount);
  {$ELSE}
  {$ENDIF}

  FMSecPerPixel := Math.Max(10, Get_PulseTotoalMSec  /rbPulse.Width);
end;

procedure TForm1.SetMinHeartBeat(const Value: Word);
begin
  FMinHeartBeat := Value;
  FHeartBeatScale := (FMaxHeartBeat-FMinHeartBeat)/rbHeartBeat.Height;
  rbHeartBeat.Refresh;

  try
    FStopSense := true;
    tkbarMinHeartBeat.Value := FMinHeartBeat;
  finally
    FStopSense := false;
  end;
end;

procedure TForm1.SetMinPulse(const Value: Word);
begin
  FMinPulse := Value;
  FPulseScale := (FMaxPulse-FMinPulse)/rbPulse.Height;
  rbPulse.Refresh;

  try
    FStopSense := true;
    tkbarMinPulse.Value := FMinPulse;
  finally
    FStopSense := false;
  end;
end;

procedure TForm1.SetPulseScale(const Value: TFloat);
begin
  FPulseScale := Value;
  rbPulse.Refresh;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TForm1.tkbarMaxHeartBeatChange(Sender: TObject);
begin

  if (FStopSense) then exit;

  MaxHeartBeat := round(tkbarMaxHeartBeat.Value);
end;

procedure TForm1.tkbarMaxPulseChange(Sender: TObject);
begin
  if (FStopSense) then exit;
  
  MaxPulse := round(tkbarMaxPulse.Value);
end;

procedure TForm1.tkbarMinHeartBeatChange(Sender: TObject);
begin
  if (FStopSense) then exit;

  MinHeartBeat := round(tkbarMinHeartBeat.Value);
end;

procedure TForm1.tkbarMinPulseChange(Sender: TObject);
begin
  if (FStopSense) then exit;

  MinPulse := round(tkbarMinPulse.Value);
end;

procedure TForm1.tkbarMsecPerPxlChange(Sender: TObject);
begin
//
  FMSecPerPixel := tkbarMSecPerPxl.Value;
end;

end.
