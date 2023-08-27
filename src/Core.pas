unit Core;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

var
  AppPath, ReportsPath, AppVersion, WebsiteURL, ContactEmail, BTCDonationAddress: String;
  FormatSettings: TFormatSettings;

implementation

initialization
  AppPath := ExtractFilePath(ParamStr(0));
  ReportsPath := AppPath + 'reports\';
  AppVersion := '0.0.2';
  WebsiteURL := 'https://pascal-bergeron.com/en/posts/treasure-hunter/';
  ContactEmail := 'contact@pascal-bergeron.com';
  BTCDonationAddress := 'bc1qu3fqvvdf0zks5lxqmpjtukg03r29jqtd2x78mx';

  FormatSettings := DefaultFormatSettings;
  FormatSettings.ThousandSeparator := ',';

end.

