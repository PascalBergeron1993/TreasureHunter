unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  LCLType, Menus, ExtCtrls, FileUtil, Core, LCLIntf, WalletSearcher;

type

  { TMainForm }

  TMainForm = class(TForm)
    ProgressBar: TProgressBar;
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
    StatusBar: TStatusBar;
    StatusBarUpdater: TTimer;
    procedure FormCreate(Sender: TObject);
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

procedure TMainForm.StatusBarUpdaterTimer(Sender: TObject);
begin
  if (WalletSearcher <> nil) and (not(WalletSearcher.Finished)) then
  begin
    FoundWallets := Length(WalletSearcher.FoundWallets);
    FilesScanned := WalletSearcher.FilesScanned;
  end;

  StatusBar.Panels[1].Text := FormatFloat('#,##0', FoundWallets, FormatSettings);
  StatusBar.Panels[3].Text := FormatFloat('#,##0', FilesScanned, FormatSettings);
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
  OpenDocument(WebsiteURL);
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

  LaunchSearch.Visible := false;
  StopSearch.Visible := true;
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

