program SmartFindFiles;

uses
  Vcl.Forms,
  ufmPrincipal in 'ufmPrincipal.pas' {fmPrincipal},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmPrincipal, fmPrincipal);
  Application.Run;
end.
