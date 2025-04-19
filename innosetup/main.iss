; 脚本由 Inno Setup 脚本向导 生成！
; 有关创建 Inno Setup 脚本文件的详细资料请查阅帮助文档！

#define MyAppName "fullscreen-reminder"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "shingyu (StarEdge Studio)"
#define MyAppURL "https://www.shingyu.cn/"
#define MyAppExeName "fullscreen-reminder.exe"

[Setup]
; 注: AppId的值为单独标识该应用程序。
; 不要为其他安装程序使用相同的AppId值。
; (若要生成新的 GUID，可在菜单中点击 "工具|生成 GUID"。)
AppId={{94514541-D16D-4679-B754-C50C16C9A564}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={commonpf64}\{#MyAppName}
DisableDirPage=yes
DisableProgramGroupPage=yes
LicenseFile=D:\Projects\Python\fullscreen-reminder\LICENSE
; 以下行取消注释，以在非管理安装模式下运行（仅为当前用户安装）。
;PrivilegesRequired=lowest
OutputDir=D:\Projects\Python\fullscreen-reminder\main.dist
OutputBaseFilename=fullscreen-reminder-setup
Compression=lzma
SignTool=signtool
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "chinesesimp"; MessagesFile: "compiler:Default.isl"
Name: "english"; MessagesFile: "compiler:Languages\English.isl"

[Files]
Source: "D:\Projects\Python\fullscreen-reminder\main.dist\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Projects\Python\fullscreen-reminder\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Projects\Python\fullscreen-reminder\innosetup\cert.cer"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Projects\Python\fullscreen-reminder\main.dist\_ctypes.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Projects\Python\fullscreen-reminder\main.dist\libffi-8.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Projects\Python\fullscreen-reminder\main.dist\python3.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Projects\Python\fullscreen-reminder\main.dist\python38.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Projects\Python\fullscreen-reminder\main.dist\qt5core.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Projects\Python\fullscreen-reminder\main.dist\qt5gui.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Projects\Python\fullscreen-reminder\main.dist\qt5widgets.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Projects\Python\fullscreen-reminder\assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "D:\Projects\Python\fullscreen-reminder\main.dist\PyQt5\*"; DestDir: "{app}\PyQt5"; Flags: ignoreversion recursesubdirs createallsubdirs
; 注意: 不要在任何共享系统文件上使用“Flags: ignoreversion”

[Code]
function ModPathDir(): TArrayOfString;
	var
	Dir:	TArrayOfString;
	begin
	setArrayLength(Dir, 1)
	Dir[0] := ExpandConstant('{app}');
	Result := Dir;
end;
// 引入 ModPath.iss 脚本（需提前下载）
#include "ModPath.iss"

var
  CertPage: TWizardPage;  // 自定义证书安装提示页面

// 初始化向导时跳过提示页面（如果是静默安装）
procedure InitializeWizard;
begin
    CertPage := CreateOutputMsgPage(
      wpInfoBefore,
      '安装CA证书',
      '安全提示',
      '本程序需要安装 StarEdge Studio Root CA 证书以确保功能完整。' + #13#10 +
      'StarEdge Studio 向您承诺：' + #13#10 +
      '  1. 我们绝不会向任何非我们所有/已验证的域名/实体签发证书。' + #13#10 +
      '  2. 我们绝不会滥用此证书。' + #13#10 +
      '点击“下一步”继续安装。' + #13#10 
    );
end;


// 安装完成后执行证书导入和添加 PATH
procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    // 1. 安装证书到系统根存储（不弹成功提示）
    if Exec(
      'certutil.exe',
      '-f -addstore Root "' + ExpandConstant('{app}\cert.cer') + '"',
      '', SW_HIDE, ewWaitUntilTerminated, ResultCode
    ) then
    begin
      // 仅在非静默模式且失败时弹窗
      if ResultCode <> 0 then
        MsgBox('证书安装失败！错误代码：' + IntToStr(ResultCode), mbError, MB_OK)
      else if not WizardSilent then
        ;
    end;

    // 2. 添加 PATH（无提示）
    if CurStep = ssPostInstall then begin
    // 添加路径
    AddToPath(ExpandConstant('{app}'));
    // 刷新环境变量（可选）
    //RefreshEnvironment;
    end;
  end;
end;

// 卸载时移除 PATH
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then begin
    // 移除路径
    RemoveFromPath(ExpandConstant('{app}'));
    // 刷新环境变量（可选）
    //RefreshEnvironment;
  end;
end;

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

