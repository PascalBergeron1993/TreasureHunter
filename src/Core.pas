unit Core;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

var
  AppPath, ReportsPath, AppVersion, WebsiteURL, ExchangesURL, ContactEmail, BTCDonationAddress: String;
  FormatSettings: TFormatSettings;

implementation

initialization
  AppPath := ExtractFilePath(ParamStr(0));
  ReportsPath := IncludeTrailingPathDelimiter(AppPath + 'reports');
  AppVersion := '0.0.6';
  WebsiteURL := 'https://pascal-bergeron.com/en/posts/treasure-hunter/';
  ExchangesURL := 'https://pascal-bergeron.com/en/posts/exchanges-cryptocurencies/';
  ContactEmail := 'contact@pascal-bergeron.com';
  BTCDonationAddress := 'bc1qu3fqvvdf0zks5lxqmpjtukg03r29jqtd2x78mx';

  FormatSettings := DefaultFormatSettings;
  FormatSettings.ThousandSeparator := ',';

end.

