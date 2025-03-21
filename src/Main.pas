unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  LCLType, Menus, ExtCtrls, FileUtil, Core, LCLIntf, Buttons, WalletSearcher;

type

  { TMainForm }

  TMainForm = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    SellBitcoins: TMenuItem;
    ProgressBar: TProgressBar;
    WalletsFoundLabel: TLabel;
    FilesScannedLabel: TLabel;
    ActionsPanel: TPanel;
    Panel1: TPanel;
    StopSearch: TButton;
    MainMenu: TMainMenu;
    OpenReportsFolder: TMenuItem;
    VisitWebsite: TMenuItem;
    Notebook1: TNotebook;
    SearchRecursively: TCheckBox;
    SelectPath: TButton;
    LaunchSearch: TButton;
    SearchPath: TEdit;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    StatusBarUpdater: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure SellBitcoinsClick(Sender: TObject);
    procedure StatusBarUpdaterTimer(Sender: TObject);
    procedure SelectPathClick(Sender: TObject);
    procedure OpenReportsFolderClick(Sender: TObject);
    procedure VisitWebsiteClick(Sender: TObject);
    procedure LaunchSearchClick(Sender: TObject);
    procedure StopSearchClick(Sender: TObject);
  private
    WalletSearcher: TWalletSearcher;
    FoundWallets, FilesScanned: Int64;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  StatusBarUpdaterTimer(nil);
end;

procedure TMainForm.SellBitcoinsClick(Sender: TObject);
begin
  OpenURL(ExchangesURL);
end;

procedure TMainForm.StatusBarUpdaterTimer(Sender: TObject);
begin
  if (WalletSearcher <> nil) and (not(WalletSearcher.Finished)) then
  begin
    FilesScanned := WalletSearcher.FilesScanned;
    FoundWallets := Length(WalletSearcher.FoundWallets);
  end;

  FilesScannedLabel.Caption := 'Files scanned: ' + FormatFloat('#,##0', FilesScanned, FormatSettings);
  WalletsFoundLabel.Caption := 'Wallets found: ' + FormatFloat('#,##0', FoundWallets, FormatSettings);
end;

procedure TMainForm.SelectPathClick(Sender: TObject);
begin
  if (SelectDirectoryDialog.Execute) then
  begin
    SearchPath.Text := SelectDirectoryDialog.FileName;
    LaunchSearch.Enabled := true;
  end;
end;

procedure TMainForm.OpenReportsFolderClick(Sender: TObject);
begin
  if (not(DirectoryExists(ReportsPath))) then
    CreateDir(ReportsPath);
  OpenDocument(ReportsPath);
end;

procedure TMainForm.VisitWebsiteClick(Sender: TObject);
begin
  OpenURL(WebsiteURL);
end;

procedure TMainForm.LaunchSearchClick(Sender: TObject);
begin
  if (not(DirectoryExists(SearchPath.Text))) then
  begin
    Application.MessageBox('The specified path cannot be opened. Make sure it exists and it''s not in use.',
      'Unable to launch search', MB_ICONERROR);
    Exit;
  end;

  if (not(DirectoryExists(ReportsPath))) then
    CreateDir(ReportsPath);

  LaunchSearch.Enabled := false;
  StopSearch.Enabled := true;
  SearchRecursively.Enabled := false;
  SelectPath.Enabled := false;
  SearchPath.Enabled := false;
  ProgressBar.Style := pbstMarquee;

  WalletSearcher := TWalletSearcher.Create(SearchPath.Text, SearchRecursively.Checked);
  StatusBarUpdaterTimer(nil);
end;

procedure TMainForm.StopSearchClick(Sender: TObject);
begin
  StopSearch.Enabled := false;

  WalletSearcher.Terminate;
end;

end.

