unit ufmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, Vcl.Grids,
  Vcl.DBGrids, JvExDBGrids, JvDBGrid, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.ExtDlgs, Vcl.Imaging.pngimage,
  Vcl.WinXCtrls, Vcl.Buttons, Vcl.FileCtrl, System.ImageList, Vcl.ImgList;

type
  TfmPrincipal = class(TForm)
    dsText: TDataSource;
    dsResto: TDataSource;
    spMenu: TSplitView;
    pnPrincipal: TPanel;
    JvDBGrid1: TJvDBGrid;
    memResto: TFDMemTable;
    memRestoxml: TStringField;
    memText: TFDMemTable;
    memTextcampo: TStringField;
    pn1: TPanel;
    lb1: TLabel;
    edCaminhoLista: TEdit;
    btText: TButton;
    pnBottom: TPanel;
    JvDBGrid2: TJvDBGrid;
    pnFind: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    edProcuraArquivo: TEdit;
    edCopiaArquivo: TEdit;
    btProcura: TButton;
    pnFooter: TPanel;
    pnTitle: TPanel;
    imMenu: TImage;
    btBuscarLista: TButton;
    OpenTextFileDialog1: TOpenTextFileDialog;
    btBuscaPastaProcura: TButton;
    btBuscaPastaCopia: TButton;
    pnSum: TPanel;
    lbSumFinded: TLabel;
    lbSumNotFinded: TLabel;
    pnSumList: TPanel;
    lbSumList: TLabel;
    pnMenu: TPanel;
    imLogo: TImage;
    pnMenuSair: TPanel;
    btMenuSair: TSpeedButton;
    pnMenuSobre: TPanel;
    btMenuSobre: TSpeedButton;
    shpMenu: TShape;
    ilPrincipal: TImageList;
    procedure btTextClick(Sender: TObject);
    procedure btProcuraClick(Sender: TObject);
    procedure imMenuClick(Sender: TObject);
    procedure btMenuSairClick(Sender: TObject);
    procedure btBuscarListaClick(Sender: TObject);
    procedure btBuscaPastaProcuraClick(Sender: TObject);
    procedure btBuscaPastaCopiaClick(Sender: TObject);
    procedure btMenuSobreClick(Sender: TObject);
  private
    function SelectADirectory(Title: string): string;
    procedure BuscarListaDeArquivos;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmPrincipal: TfmPrincipal;

implementation

{$R *.dfm}

function TfmPrincipal.SelectADirectory(Title : string) : string;
var
  Pasta : String;
begin
  SelectDirectory(Title, '', Pasta);

  if (Trim(Pasta) <> '') then
    if (Pasta[Length(Pasta)] <> '\') then
      Pasta := Pasta + '\';

  Result := Pasta;
end;

procedure TfmPrincipal.BuscarListaDeArquivos;
begin
  if OpenTextFileDialog1.Execute then
    edCaminhoLista.Text := OpenTextFileDialog1.FileName;
end;

procedure TfmPrincipal.btBuscaPastaCopiaClick(Sender: TObject);
begin
  edCopiaArquivo.Text := SelectADirectory('Selecione a pasta onde deseja copiar o(s) arquivo(s).');
end;

procedure TfmPrincipal.btBuscaPastaProcuraClick(Sender: TObject);
begin
  edProcuraArquivo.Text := SelectADirectory('Selecione a pasta que deseja procurar o(s) arquivo(s).');
end;

procedure TfmPrincipal.btBuscarListaClick(Sender: TObject);
begin
  BuscarListaDeArquivos;
end;

procedure TfmPrincipal.btMenuSairClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfmPrincipal.btMenuSobreClick(Sender: TObject);
begin
  ShowMessage('Smart Find Files - Versão : 1.0' + sLineBreak + 'Desenvolvido by Igor Faustino e Vagner Oliveira.');
end;

procedure TfmPrincipal.btProcuraClick(Sender: TObject);
var
  arquivo, pastaProjetoCaminho: String;
  contadorEncontrados: Integer;
begin

  if Trim(edProcuraArquivo.Text) = EmptyStr then
  begin
    raise Exception.Create('Erro! Por gentileza selecione antes a pasta que deseja procurar o(s) arquivo(s).');
  end;

  if Trim(edCopiaArquivo.Text) = EmptyStr then
  begin
    raise Exception.Create('Erro! Por gentileza selecione antes a pasta onde deseja copiar o(s) arquivo(s).');
  end;

  contadorEncontrados := 0;

  pastaProjetoCaminho := edCopiaArquivo.Text;
  if not DirectoryExists(pastaProjetoCaminho) then
    CreateDir(pastaProjetoCaminho);

  memResto.EmptyDataSet;

  memText.First;
  while not memText.Eof do
  begin
    arquivo := Trim(edProcuraArquivo.Text) + '\' + memText.FieldByName('xml').AsString;
    if FileExists(arquivo) then
    begin
      CopyFile(PChar(arquivo), PChar(pastaProjetoCaminho + '\' + StringReplace(memText.FieldByName('xml').AsString, 'AD', 'CFe', [rfreplaceAll])), False);
      Inc(contadorEncontrados);
    end
    else
    begin
      memResto.Append;
      memResto.FieldByName('xml').AsString := memText.FieldByName('xml').AsString;
      memResto.Post;
    end;
    memText.Next;
  end;

  lbSumFinded.Caption := 'Total de arquivos copiados: ' + contadorEncontrados.ToString;
  lbSumNotFinded.Caption := 'Total de arquivos não encontrados: ' + memResto.RecordCount.ToString;
end;

procedure TfmPrincipal.btTextClick(Sender: TObject);
var
  i: Integer;
  list: TStringList;
begin

  if Trim(edCaminhoLista.Text) = EmptyStr then
  begin
    raise Exception.Create('Erro! Por gentileza selecione antes o arquivo da lista que deseja carregar.');
  end;

  list := TStringList.Create;
  try

    memText.EmptyDataSet;
    edCaminhoLista.Text := Trim(edCaminhoLista.Text);
    list.LoadFromFile(edCaminhoLista.Text);
    for i := 0 to Pred(list.Count) do
    begin
      memText.Append;
      memText.FieldByName('xml').AsString := 'AD' + list.Strings[I] + '.xml';
      memText.Post;
    end;

    lbSumList.Caption := 'Total de arquivos a serem encontrados: ' + memText.RecordCount.ToString;

  finally
    list.Free;
  end;
end;

procedure TfmPrincipal.imMenuClick(Sender: TObject);
begin
  if spMenu.Opened then
  begin
    spMenu.Close;
  end
  else
  begin
    spMenu.Open;
  end;
end;

end.
