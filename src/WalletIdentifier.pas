unit WalletIdentifier;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Math, Masks;

type
  TWalletIdentifier = class(TObject)
  private
    FIsWallet: Boolean;
    FWalletName: String;
    procedure Detect(const WalletName: String);
    function GetBytesHex(const FilePath: String; Offset: Integer = 0): String;
  public
    property IsWallet: Boolean read FIsWallet;
    property WalletName: String read FWalletName;
    procedure Analyze(const FilePath: String);
    constructor Create;
  end;

implementation

constructor TWalletIdentifier.Create;
begin
  inherited Create;
  FIsWallet := false;
  FWalletName := '';
end;

procedure TWalletIdentifier.Detect(const WalletName: String);
begin
  FIsWallet := true;
  FWalletName := WalletName;
end;

function TWalletIdentifier.GetBytesHex(const FilePath: String; Offset: Integer = 0): String;
var
  Stream: TFileStream;
  StreamSize: Integer;
  Bytes: TBytes;
  I: Integer;
begin
  Bytes := nil;
  Result := '';

  Stream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyNone);
  try
    Stream.Seek(Offset, soFromBeginning);

    StreamSize := MaxIntValue([MinIntValue([256, Stream.Size - Stream.Position]), 0]);
    SetLength(Bytes, StreamSize);
    Stream.ReadBuffer(Pointer(Bytes)^, StreamSize);

    for I := 0 to Length(Bytes) - 1 do
      Result := Result + Bytes[I].ToHexString(2);
  finally
    Stream.Free;
  end;
end;

procedure TWalletIdentifier.Analyze(const FilePath: String);
var
  BytesHex, FileName: String;
begin
  FIsWallet := false;
  FWalletName := '';

  FileName := ExtractFileName(FilePath);
  BytesHex := GetBytesHex(FilePath);

  // BitcoinJ
  if (LeftStr(BytesHex, 48) = '0A166F72672E626974636F696E2E70726F64756374696F6E') then
    Detect('BitcoinJ') else

  // Multibit Classic .wallet.cipher file
  if (LeftStr(BytesHex, 14) = '6D656E646F7A61') then
    Detect('Multibit Classic') else

  // Multibit Classic encrypted .key file
  if (LeftStr(BytesHex, 20) = '553246736447566B5831') and (MatchesMask(FileName, '*.key')) then
    Detect('Multibit Classic') else

  // Multibit Classic unencrypted .key file
  if (LeftStr(BytesHex, 128) = '23204B45455020594F55522050524956415445204B455953205341464520210A2320416E796F6E652077686F2063616E207265616420746869732066696C6520') then
    Detect('Multibit Classic') else

  // Bitcoin Core
  if (LeftStr(BytesHex, 32) = '00000000010000000000000062310500')
  or (LeftStr(GetBytesHex(FilePath, 3952), 32) = '0000005A01071715150181177461626C') then
    Detect('Bitcoin Core') else

  // Electrum unencrypted wallet
  if (LeftStr(BytesHex, 62) = '7B0D0A20202020226163636F756E7473223A207B0D0A202020202020202022')
  or (LeftStr(BytesHex, 54) = '7B0D0A20202020226163636F756E74735F657870616E646564223A')
  or (LeftStr(BytesHex, 48) = '7B0D0A2020202022616464725F686973746F7279223A207B')
  or (LeftStr(BytesHex, 42) = '7B0A2020202022616464725F686973746F7279223A')
  or (LeftStr(BytesHex, 36) = '7B27616464725F686973746F7279273A207B') then
    Detect('Electrum') else

  // Electrum encrypted wallet
  if (LeftStr(BytesHex, 12) = '516B6C464D51') then
    Detect('Electrum') else

  // Multibit HD
  if (MatchesMask(FileName, 'mbhd*.wallet.aes'))
  or (MatchesMask(FileName, 'mbhd*.zip.aes')) then
    Detect('Multibit HD') else

  // Blockchain.com
  if (MatchesMask(FileName, '*wallet.aes.json')) then
    Detect('Blockchain.com') else

  // Bither
  if (LeftStr(GetBytesHex(FilePath, 320), 32) = '5F736565647368645F73656564730643') then
    Detect('Bither');
end;

end.

