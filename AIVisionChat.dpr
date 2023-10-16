program AIVisionChat;

uses
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  uMainForm in 'uMainForm.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
