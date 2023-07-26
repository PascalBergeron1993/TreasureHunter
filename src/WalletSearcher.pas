unit WalletSearcher;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, WalletIdentifier, Core, Dialogs, Forms, LCLIntf, LCLType, ComCtrls;

type
  TFoundWallet = record
    WalletName: String;
    FilePath: String;
  end;
  TFoundWallets = array of TFoundWallet;

  TWalletSearcher = class(TThread)
  private
    FWalletIdentifier: TWalletIdentifier;
    FSearchRecursively: Boolean;
    FCurrentReport, FSearchPath: String;
    FFoundWallets: TFoundWallets;
    FFilesScanned: Int64;
    FDebugLog: TextFile;
    FScanTime: TDateTime;
    procedure AnalyzeFile(FileIterator: TFileIterator);
    procedure CreateReport;
    procedure FinalizeSearch;
  public
    property FoundWallets: TFoundWallets read FFoundWallets;
    property FilesScanned: Int64 read FFilesScanned;
    constructor Create(const SearchPath: String; SearchRecursively: Boolean);
    destructor Destroy; override;
    procedure Execute; override;
  end;

implementation

uses
  Main;

constructor TWalletSearcher.Create(const SearchPath: String; SearchRecursively: Boolean);
begin
  inherited Create(false);
  FreeOnTerminate := true;
  FScanTime := Now;

  FSearchPath := SearchPath;
  FSearchRecursively := SearchRecursively;

  FWalletIdentifier := TWalletIdentifier.Create;

  FCurrentReport := ReportsPath + FormatDateTime('yyyy-mm-dd hh-nn-ss.zzz', Now) + '\';
  CreateDir(FCurrentReport);

  AssignFile(FDebugLog, FCurrentReport + 'debug.txt');
  Rewrite(FDebugLog);
end;

destructor TWalletSearcher.Destroy;
begin
  FWalletIdentifier.Free;
  inherited Destroy;
end;

procedure TWalletSearcher.FinalizeSearch;
begin
  MainForm.StatusBarUpdaterTimer(nil);

  MainForm.LaunchSearch.Visible := true;
  MainForm.StopSearch.Visible := false;
  MainForm.StopSearch.Enabled := true;
  MainForm.SearchRecursively.Enabled := true;
  MainForm.SelectPath.Enabled := true;
  MainForm.SearchPath.Enabled := true;
  MainForm.ProgressBar.Style := pbstNormal;

  Application.MessageBox(PChar(FormatFloat('#,##0', Length(FoundWallets), FormatSettings) + ' potential wallets have been found.' +
    sLineBreak +  sLineBreak + 'The search report will now open in a new window. ' + sLineBreak +  sLineBreak +
    'In the future, you can view all reports by clicking on "Open reports folder" in the main menu.'), 'Search complete', MB_ICONINFORMATION);
  OpenDocument(FCurrentReport + 'report.txt');
end;

procedure TWalletSearcher.AnalyzeFile(FileIterator: TFileIterator);
begin
  if (Terminated) then
  begin
    FileIterator.Stop;
    Exit;
  end;

  Inc(FFilesScanned);

  try
    FWalletIdentifier.Analyze(FileIterator.FileName);
  except
    on E : Exception do
      WriteLn(FDebugLog, '[' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + '] Cannot analyze ' + FileIterator.FileName + ' - ' + E.Message);
  end;

  if (FWalletIdentifier.IsWallet) then
  begin
    SetLength(FFoundWallets, Length(FFoundWallets) + 1);
    FFoundWallets[Length(FFoundWallets) - 1].WalletName := FWalletIdentifier.WalletName;
    FFoundWallets[Length(FFoundWallets) - 1].FilePath := FileIterator.FileName;
  end;
end;

procedure TWalletSearcher.CreateReport;
var
  ReportFile: TextFile;
  I: Integer;
begin
  AssignFile(ReportFile, FCurrentReport + 'report.txt');
  Rewrite(ReportFile);

  WriteLn(ReportFile, 'TREASURE HUNTER');
  WriteLn(ReportFile, '-----------------------------------');
  WriteLn(ReportFile, 'Treasure Hunter is an application created by Pascal Bergeron that allows people');
  WriteLn(ReportFile, 'to scan their storage devices for the presence of Bitcoin wallets. It can');
  WriteLn(ReportFile, 'detect many types of wallets even if they were renamed or moved elsewhere');
  WriteLn(ReportFile, 'in an attempt to hide them. You can find more information at ' + WebsiteURL);
  WriteLn(ReportFile, '');

  WriteLn(ReportFile, 'INFORMATION');
  WriteLn(ReportFile, '-----------------------------------');
  WriteLn(ReportFile, 'Software version: ' + AppVersion);
  WriteLn(ReportFile, 'Debug log path: ' + FCurrentReport + 'debug.txt');
  WriteLn(ReportFile, 'Search path: ' + FSearchPath);
  WriteLn(ReportFile, 'Scan launched at: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', FScanTime));
  WriteLn(ReportFile, 'Scan ended at: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
  WriteLn(ReportFile, 'Scan stopped by force: ' + BoolToStr(Terminated, 'yes', 'no'));
  WriteLn(ReportFile, '');

  WriteLn(ReportFile, 'FILES FLAGGED AS POTENTIAL WALLETS');
  WriteLn(ReportFile, '-----------------------------------');
  if (Length(FFoundWallets) = 0) then
    WriteLn(ReportFile, 'Nothing found');
  for I := 0 to Length(FFoundWallets) - 1 do
    WriteLn(ReportFile, '[' + FFoundWallets[I].WalletName + '] ' + FFoundWallets[I].FilePath);
  WriteLn(ReportFile, '');

  WriteLn(ReportFile, 'DO YOU NEED PROFESSIONAL HELP?');
  WriteLn(ReportFile, '-----------------------------------');
  WriteLn(ReportFile, 'I offer many crypto services such as transferring funds from an old wallet');
  WriteLn(ReportFile, 'to a new one, claiming forked coins or cracking a wallet whose password has');
  WriteLn(ReportFile, 'been lost. If you are interested, send an email to ' + ContactEmail);
  WriteLn(ReportFile, '');

  WriteLn(ReportFile, 'WAS MY SOFTWARE USEFUL?');
  WriteLn(ReportFile, '-----------------------------------');
  WriteLn(ReportFile, 'If you don''t need my professional help, consider making a donation to');
  WriteLn(ReportFile, 'the following Bitcoin address: ' + BTCDonationAddress);

  CloseFile(ReportFile);
end;

procedure TWalletSearcher.Execute;
var
  FileSearcher: TFileSearcher;
begin
  FileSearcher := TFileSearcher.Create;
  FileSearcher.OnFileFound := @AnalyzeFile;
  FileSearcher.Search(FSearchPath, '*', FSearchRecursively);
  FileSearcher.Free;

  CreateReport;
  CloseFile(FDebugLog);

  Synchronize(@FinalizeSearch);
end;

end.

