unit uMainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Layouts, FMX.Controls.Presentation, FMX.Effects, FMX.Edit,
  System.Math, REST.Types, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  REST.Response.Adapter, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, FMX.TabControl, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.TextLayout, FireDAC.Stan.StorageBin, FMX.ListBox, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.DBScope;

type
  TMainForm = class(TForm)
    VSB: TVertScrollBox;
    Layout1: TLayout;
    GenerateButton: TButton;
    Image1: TImage;
    MaterialOxfordBlueSB: TStyleBook;
    ToolBar1: TToolBar;
    ShadowEffect4: TShadowEffect;
    Label1: TLabel;
    PromptEdit: TEdit;
    Image2: TImage;
    SourceImage: TImageControl;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    FDMemTable1: TFDMemTable;
    RESTClient2: TRESTClient;
    RESTRequest2: TRESTRequest;
    RESTResponse2: TRESTResponse;
    RESTResponseDataSetAdapter2: TRESTResponseDataSetAdapter;
    FDMemTable2: TFDMemTable;
    APIKeyEdit: TEdit;
    APIKeyButton: TButton;
    StatusBar1: TStatusBar;
    ProgressBar: TProgressBar;
    Layout2: TLayout;
    Layout3: TLayout;
    ImageEdit: TEdit;
    OpenButton: TButton;
    OpenDialog: TOpenDialog;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    XrayMemo: TMemo;
    TemplateMemo: TMemo;
    Timer1: TTimer;
    Timer2: TTimer;
    Splitter1: TSplitter;
    ModelsMT: TFDMemTable;
    VersionEdit: TComboBox;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    ModelLabel: TLabel;
    LinkPropertyToFieldText: TLinkPropertyToField;
    procedure OpenButtonClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure GenerateButtonClick(Sender: TObject);
    procedure APIKeyButtonClick(Sender: TObject);

  private
    { Private declarations }
    FCurrentMessage: TText;
    procedure LResized(Sender: TObject);
  public
    { Public declarations }
    procedure AddMessage(const AText: String; AAlignLayout: TAlignLayout; ACalloutPosition: TCalloutPosition);
    procedure FriendMessage(const S: String);
    procedure YourMessage(const S: String);
    procedure LabelPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    function MemoryStreamToBase64(const MemoryStream: TMemoryStream): string;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  System.NetEncoding, System.Net.Mime, System.JSON, System.Generics.Collections,
  System.IOUtils;

function JSONQuote(const AValue: string): string;
var
  JSONStr: TJSONString;
begin
  JSONStr := TJSONString.Create(AValue);
  try
    Result := JSONStr.ToJSON;
  finally
    JSONStr.Free;
  end;
end;

function TMainForm.MemoryStreamToBase64(const MemoryStream: TMemoryStream): string;
var
  OutputStringStream: TStringStream;
  Base64Encoder: TBase64Encoding;
  MimeType: string;
begin
  MemoryStream.Position := 0;
  OutputStringStream := TStringStream.Create('', TEncoding.ASCII);
  try
    Base64Encoder := TBase64Encoding.Create;
    try
      Base64Encoder.Encode(MemoryStream, OutputStringStream);
      MimeType := 'image/png';
      Result := 'data:' + MimeType + ';base64,' + OutputStringStream.DataString.Replace(#13#10,'');
    finally
      Base64Encoder.Free;
    end;
  finally
    OutputStringStream.Free;
  end;
end;

procedure TMainForm.OpenButtonClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    ImageEdit.Text := OpenDialog.FileName;
    SourceImage.Bitmap.LoadFromFile(ImageEdit.Text);
  end;
end;

function ParseJSONStrArray(const JSONStr: String): TArray<String>;
var
  JSONArray: TJSONArray;
  I: Integer;
begin
  JSONArray := TJSONObject.ParseJSONValue(JSONStr) as TJSONArray;
  try
    SetLength(Result, JSONArray.Count);
    for I := 0 to JSONArray.Count - 1 do
      Result[I] := JSONArray.Items[I].Value;
  finally
    JSONArray.Free;
  end;
end;

function IsJSONArray(const s: string): Boolean;
var
  JSONValue: TJSONValue;
begin
  Result := False;
  try
    JSONValue := TJSONObject.ParseJSONValue(s);
    try
      if JSONValue is TJSONArray then
        Result := True;
    finally
      JSONValue.Free;
    end;
  except
    on E: EJSONException do
      // Do nothing; Result remains False
  end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  RestRequest2.Params[0].Value := 'Token ' + APIKeyEdit.Text;
  RESTRequest2.Execute;

  var F := FDMemTable2.FindField('status');
  if F<>nil then
  begin
    if F.AsWideString='processing' then
    begin
      XrayMemo.Lines.Append('GET Request');
      XrayMemo.Lines.Append('URL:');
      XrayMemo.Lines.Append(RestClient2.BaseURL+'/'+RESTRequest2.Resource+#13#10);

      XrayMemo.Lines.Append('Response');
      XrayMemo.Lines.Append(RESTResponse2.Content+#13#10);

      if FDMemTable2.FindField('output')<>nil then
      begin
        var LResponse := '';

        if IsJSONArray(FDMemTable2.FieldByName('output').AsWideString) then
        begin
          var OutputArray := ParseJSONStrArray(FDMemTable2.FieldByName('output').AsWideString);

          for var I := 0 to High(OutputArray) do
          begin
            LResponse := LResponse+OutputArray[I];
          end;
        end
        else
          LResponse := FDMemTable2.FieldByName('output').AsWideString;

        FriendMessage(LResponse);
      end;

    end
    else
    if F.AsWideString='succeeded' then
    begin
      Timer1.Enabled := False;
      XrayMemo.Lines.Append('GET Request');
      XrayMemo.Lines.Append('URL:');
      XrayMemo.Lines.Append(RestClient2.BaseURL+'/'+RESTRequest2.Resource+#13#10);

      XrayMemo.Lines.Append('Response');
      XrayMemo.Lines.Append(RESTResponse2.Content+#13#10);

      var LResponse := '';

      if IsJSONArray(FDMemTable2.FieldByName('output').AsWideString) then
      begin
        var OutputArray := ParseJSONStrArray(FDMemTable2.FieldByName('output').AsWideString);

        for var I := 0 to High(OutputArray) do
        begin
          LResponse := LResponse+OutputArray[I];
        end;
      end
      else
        LResponse := FDMemTable2.FieldByName('output').AsWideString;

      FriendMessage(LResponse);
      FCurrentMessage := nil;

      ProgressBar.Visible := False;
      GenerateButton.Enabled := True;

    end
    else
    if F.AsWideString='failed' then
    begin
      Timer1.Enabled := False;

      XrayMemo.Lines.Append('GET Request');
      XrayMemo.Lines.Append('URL:');
      XrayMemo.Lines.Append(RestClient2.BaseURL+'/'+RESTRequest2.Resource+#13#10);

      XrayMemo.Lines.Append('Response');
      XrayMemo.Lines.Append(RESTResponse2.Content+#13#10);

      ProgressBar.Visible := False;
      GenerateButton.Enabled := True;
      ShowMessage(FDMemTable2.FieldByName('error').AsWideString);
    end;
  end;
end;

procedure TMainForm.Timer2Timer(Sender: TObject);
begin
    if ProgressBar.Value=ProgressBar.Max then
      ProgressBar.Value := ProgressBar.Min
    else
      ProgressBar.Value := ProgressBar.Value+5;
end;

procedure TMainForm.LResized(Sender: TObject);
begin
  TCalloutRectangle(TText(Sender).Parent).Height := TText(Sender).Height + TText(Sender).Margins.Top + TText(Sender).Margins.Bottom + TCalloutRectangle(TText(Sender).Parent).Margins.Top + TCalloutRectangle(TText(Sender).Parent).Margins.Bottom;
    if (TCalloutRectangle(TText(Sender).Parent).Height<75) then TCalloutRectangle(TText(Sender).Parent).Height := 75;
end;

procedure TMainForm.AddMessage(const AText: String; AAlignLayout: TAlignLayout; ACalloutPosition: TCalloutPosition);
var
CR: TCalloutRectangle;
L: TText;
TmpImg: TCircle;
TmpLayout: TLayout;
begin
  CR := TCalloutRectangle.Create(Self);
  CR.Parent := VSB;
  CR.Align := TAlignLayout.Top;
  CR.CalloutPosition := ACalloutPosition;
  CR.Margins.Top := 10;
  CR.Margins.Bottom := 10;
  CR.Margins.Left := 5;
  if (ACalloutPosition=TCalloutPosition.Left) then
    CR.Margins.Right := CR.Margins.Right + 25;
  if (ACalloutPosition=TCalloutPosition.Right) then
    CR.Margins.Left := CR.Margins.Left + 25;
  CR.Height := 75;
  CR.XRadius := 25;
  CR.YRadius := CR.XRadius;
  CR.Position.Y := 999999;
  CR.Fill.Kind := TBrushKind.None;
  CR.Stroke.Color := TAlphaColorRec.DkGray;

  L := TText.Create(Self);
  L.TextSettings.FontColor := TAlphaColorRec.White;
  L.Parent := CR;
  //L.Align := TAlignLayout.Client;
  L.Text := AText;
  L.Margins.Top := 10;
  L.Margins.Right := 15;
  L.Margins.Left := 5;
  L.Width := CR.Width-20;

  L.WordWrap := True;
  L.AutoSize := True;
 // L.OnPaint := LabelPaint;

  FCurrentMessage := L;


  CR.Height := L.Height + L.Margins.Top + L.Margins.Bottom + CR.Margins.Top + CR.Margins.Bottom;
  if (CR.Height<75) then CR.Height := 75;

  L.Align := TAlignLayout.Client;
  L.OnResized := LResized;

  TmpLayout := TLayout.Create(Self);
  TmpLayout.Parent := CR;
  TmpLayout.Align := AAlignLayout;
  TmpLayout.Width := 75;


  TmpImg := TCircle.Create(Self);
  TmpImg.Parent := TmpLayout;
  TmpImg.Align := TAlignLayout.Top;
  TmpImg.Fill.Kind := TBrushKind.Bitmap;
  TmpImg.Stroke.Kind := TBrushKind.None;
  case AAlignLayout of
    TAlignLayout.Left: TmpImg.Fill.Bitmap.Bitmap.Assign(Image1.Bitmap);
    TAlignLayout.Right: TmpImg.Fill.Bitmap.Bitmap.Assign(Image2.Bitmap);
  end;
  TmpImg.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
  TmpImg.Width := 75;
  TmpImg.Margins.Left := 15;
  TmpImg.Margins.Right := 15;
  TmpImg.Margins.Top := 15;
  TmpImg.Margins.Bottom := 15;

  VSB.ScrollBy(0,-95);
end;

procedure TMainForm.APIKeyButtonClick(Sender: TObject);
begin
  APIKeyEdit.Visible := not APIKeyEdit.Visible;
end;

procedure TMainForm.FriendMessage(const S: String);
begin
  if FCurrentMessage<>nil then
    FCurrentMessage.Text := S
  else
    AddMessage(S, TAlignLayout.Left, TCalloutPosition.Left);
end;

procedure TMainForm.YourMessage(const S: String);
begin
  AddMessage(S, TAlignLayout.Right, TCalloutPosition.Right);
end;

procedure TMainForm.GenerateButtonClick(Sender: TObject);
begin

  if APIKeyEdit.Text='' then
  begin
    ShowMessage('Enter a Replicate.com API key.');
    Exit;
  end;

  // fuyu-8b needs a file loaded
  if ModelLabel.Text='42f23bc876570a46f5a90737086fbc4c3f79dd11753a28eaa39544dd391815e9' then
  begin
    if ImageEdit.Text='' then
    begin
      ShowMessage('Load a file from disk or URL for this model.');
      Exit;
    end;
  end;


  YourMessage(PromptEdit.Text);
  FCurrentMessage := nil;

  ProgressBar.Value := 0;
  ProgressBar.Visible := True;
  GenerateButton.Enabled := False;

  Application.ProcessMessages;

  var LSourceStream := TMemoryStream.Create;
  if ImageEdit.Text.Substring(0,4)<>'http' then
  begin
    if ImageEdit.Text<>'' then
    begin
      LSourceStream.LoadFromFile(ImageEdit.Text);
    end
    else
      SourceImage.Bitmap.SaveToStream(LSourceStream);
  end;

  var LPrompt := '"prompt":';
  var LImage := '"image":';
  // blip-2 uses "question" instead of "prompt"
  if ModelLabel.Text='9109553e37d266369f2750e407ab95649c63eb8e13f13b1f3983ff0feb2f9ef7' then
    LPrompt :=  '"question":';
  // these models need img instead of image
  if ((ModelLabel.Text='c4c54e3c8c97cd50c2d2fec9be3b6065563ccf7d43787fb99f84151b867178fe') OR (ModelLabel.Text='51a43c9d00dfd92276b2511b509fcb3ad82e221f6a9e5806c54e69803e291d6b')) then
    LImage := '"img":';

  RestRequest1.Params[0].Value := 'Token ' + APIKeyEdit.Text;
  RestRequest1.Params[1].Value := TemplateMemo.Lines.Text.Replace('%prompt%',JSONQuote(PromptEdit.Text))
  .Replace('%base64%','"'+MemoryStreamToBase64(LSourceStream)+'"')
  .Replace('"prompt":',LPrompt)
  .Replace('"image":',LImage)
  .Replace('%model%',JSONQuote(ModelLabel.Text));

  XrayMemo.Lines.Append('POST Request');
  XrayMemo.Lines.Append('URL:');
  XrayMemo.Lines.Append(RestClient1.BaseURL+#13#10);
  XrayMemo.Lines.Append('Payload:');
  XrayMemo.Lines.Append(TemplateMemo.Lines.Text.Replace('%prompt%',JSONQuote(PromptEdit.Text))
  .Replace('%base64%','"'+'...'+'"')
  .Replace('"prompt":',LPrompt)
  .Replace('"image":',LImage)
  .Replace('%model%',JSONQuote(ModelLabel.Text)));
  XrayMemo.Lines.Append('');

  RESTRequest1.Execute;

  LSourceStream.Free;

  XrayMemo.Lines.Append('Response:');
  XrayMemo.Lines.Append(RESTResponse1.Content);
  XrayMemo.Lines.Append('');

  var F := FDMemTable1.FindField('status');
  if F<>nil then
  begin
    if F.AsWideString='starting' then
    begin
      RESTRequest2.Resource := FDMemTable1.FieldByName('id').AsWideString;

      Timer1.Enabled := True;
    end
    else
    begin
      ProgressBar.Visible := False;
      GenerateButton.Enabled := True;
      ShowMessage(F.AsWideString);
    end;
  end;

end;

procedure TMainForm.LabelPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
 // if TLabel(Sender).Tag=0 then
 //   begin
 //     TCalloutRectangle(TLabel(Sender).Parent).Height := Max(TLabel(Sender).Height,75);
 //     TLabel(Sender).Tag := 1;
 //   end;
end;

end.
