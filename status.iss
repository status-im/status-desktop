#define   Name       "Status"
#define   Publisher  "Status.im"
#define   URL        "https://status.im"
#define   ExeName    "Status.exe"
#define   IcoName    "status.ico"

[Setup]

; Generated from Tools -> Generate GUID
AppId={{F3E2EDB6-78E8-4539-9C8B-A78F059D8647}}

AppName={#Name}
AppVersion={#Version}
AppPublisher={#Publisher}
AppPublisherURL={#URL}
AppSupportURL={#URL}
AppUpdatesURL={#URL}
DefaultDirName={localappdata}\{#Name}App
UsePreviousAppDir=no
PrivilegesRequired=lowest
WizardStyle=modern
UninstallDisplayIcon={app}\{#ExeName}
DefaultGroupName={#Name}
CloseApplications=yes

; output dir for installer
OutputBaseFileName={#BaseName}

; Icon file
SetupIconFile=resources\{#IcoName}

; Compression (default is lzma2/max)
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "it"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"
Name: "nl"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "pt_BR"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "fr"; MessagesFile: "compiler:Languages\French.isl"
Name: "ua"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Files]

; Path to exe on 
Source: {#ExeName}; DestDir: "{app}"; Flags: ignoreversion

; Resources
Source: "bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs

Source: "resources\*"; DestDir: "{app}\resources"; Flags: ignoreversion recursesubdirs createallsubdirs

Source: "vendor\*"; DestDir: "{app}\vendor"; Flags: ignoreversion recursesubdirs createallsubdirs

[Tasks]
Name: desktopicon; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:";

[Icons]
Name: "{group}\{#Name}"; Filename: "{app}\{#ExeName}"; WorkingDir: "{app}"
Name: "{group}\Uninstall {#Name}"; Filename: "{uninstallexe}"
Name: "{userdesktop}\{#Name}"; Filename: "{app}\{#ExeName}"; IconFilename: "{app}\resources\{#IcoName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#ExeName}"; Description: {cm:LaunchProgram,{#Name}}; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
Type: files; Name: "{userdesktop}\{#Name}"
Type: files; Name: "{commondesktop}\{#Name}"

[Registry]
Root: HKCU; Subkey: "Software\Classes\status-im"; ValueType: "string"; ValueData: "URL:status-im protocol"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\status-im"; ValueType: "string"; ValueName: "URL Protocol"; ValueData: ""
Root: HKCU; Subkey: "Software\Classes\status-im\DefaultIcon"; ValueType: "string"; ValueData: "{app}\Status.exe,1"
Root: HKCU; Subkey: "Software\Classes\status-im\shell\open\command"; ValueType: "string"; ValueData: """{app}\Status.exe"" ""--url=""%1"""

[Code]
function IsAppRunning(const FileName : string): Boolean;
var
  FSWbemLocator: Variant;
  FWMIService: Variant;
  FWbemObjectSet: Variant;
begin
  Result := false;
  FSWbemLocator := CreateOleObject('WBEMScripting.SWBEMLocator');
  FWMIService := FSWbemLocator.ConnectServer('', 'root\CIMV2', '', '');
  FWbemObjectSet := FWMIService.ExecQuery(Format('SELECT Name FROM Win32_Process Where Name="%s"',[FileName]));
  Result := (FWbemObjectSet.Count > 0);
  FWbemObjectSet := Unassigned;
  FWMIService := Unassigned;
  FSWbemLocator := Unassigned;
end;

function InitializeUninstall(): Boolean;
var
  ErrorCode: Integer;
begin
  Result := true;
  if IsAppRunning('{#ExeName}') then
  begin
    if MsgBox('Status application is still running. Do you want to terminate the app?', mbConfirmation, MB_YESNO or MB_DEFBUTTON1) = IDYES
    then
      ShellExec('', ExpandConstant('{sys}\taskkill.exe'),'/f /im {#ExeName}', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode)
    else
      Result := false;
  end
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    if DirExists(ExpandConstant('{localappdata}\Status')) then 
      if MsgBox('Do you want to delete application data?', mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES
      then
        DelTree(ExpandConstant('{localappdata}\Status'), True, True, True);
  end;
end;

