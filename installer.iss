#define MyAppName "WooRack Print Agent"
#define MyAppVersion "1.0.1"
#define MyAppPublisher "WooRack"
#define MyAppExeName "WooRackPrintService.exe"
#define MyServiceName "WooRackPrintAgent"

[Setup]
AppId={{8F6E3D7A-4A51-4B8A-9D2E-5C3A8B1E4F01}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\WooRackPrintAgent
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=.\Output
OutputBaseFilename=WooRackPrintAgent-Setup-{#MyAppVersion}
SetupIconFile=assets\woorack-print-agent.ico
UninstallDisplayIcon={app}\service\{#MyAppExeName}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"

[Files]
Source: ".\publish\service\*"; DestDir: "{app}\service"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: ".\publish\gui\*"; DestDir: "{app}\config"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "assets\woorack-print-agent.ico"; DestDir: "{app}\assets"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\config\WooRackPrintConfig.exe"; WorkingDir: "{app}\config"; IconFilename: "{app}\assets\woorack-print-agent.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\config\WooRackPrintConfig.exe"; WorkingDir: "{app}\config"; IconFilename: "{app}\assets\woorack-print-agent.ico"; Tasks: desktopicon

[Dirs]
Name: "{commonappdata}\WooRackPrintAgent"; Permissions: users-modify



[Tasks]
Name: "desktopicon"; Description: "Opret en genvej på skrivebordet"; GroupDescription: "Ekstra genveje:"; Flags: unchecked

[Run]
; Stop og fjern evt. ældre service før opdatering, og start frisk service bagefter
Filename: "sc.exe"; Parameters: "stop {#MyServiceName}"; Flags: runhidden; StatusMsg: "Stopper eksisterende service..."
Filename: "sc.exe"; Parameters: "create {#MyServiceName} binPath= ""{app}\service\{#MyAppExeName}"" start= auto DisplayName= ""{#MyAppName}"""; Flags: runhidden; StatusMsg: "Opretter Windows-service..."
Filename: "sc.exe"; Parameters: "start {#MyServiceName}"; Flags: runhidden; StatusMsg: "Starter {#MyAppName}..."

[UninstallRun]
Filename: "sc.exe"; Parameters: "stop {#MyServiceName}"; Flags: runhidden
Filename: "sc.exe"; Parameters: "delete {#MyServiceName}"; Flags: runhidden