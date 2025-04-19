; �ű��� Inno Setup �ű��� ���ɣ�
; �йش��� Inno Setup �ű��ļ�����ϸ��������İ����ĵ���

#define MyAppName "fullscreen-reminder"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "shingyu (StarEdge Studio)"
#define MyAppURL "https://www.shingyu.cn/"
#define MyAppExeName "fullscreen-reminder.exe"

[Setup]
; ע: AppId��ֵΪ������ʶ��Ӧ�ó���
; ��ҪΪ������װ����ʹ����ͬ��AppIdֵ��
; (��Ҫ�����µ� GUID�����ڲ˵��е�� "����|���� GUID"��)
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
; ������ȡ��ע�ͣ����ڷǹ���װģʽ�����У���Ϊ��ǰ�û���װ����
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
; ע��: ��Ҫ���κι���ϵͳ�ļ���ʹ�á�Flags: ignoreversion��

[Code]
function ModPathDir(): TArrayOfString;
	var
	Dir:	TArrayOfString;
	begin
	setArrayLength(Dir, 1)
	Dir[0] := ExpandConstant('{app}');
	Result := Dir;
end;
// ���� ModPath.iss �ű�������ǰ���أ�
#include "ModPath.iss"

var
  CertPage: TWizardPage;  // �Զ���֤�鰲װ��ʾҳ��

// ��ʼ����ʱ������ʾҳ�棨����Ǿ�Ĭ��װ��
procedure InitializeWizard;
begin
    CertPage := CreateOutputMsgPage(
      wpInfoBefore,
      '��װCA֤��',
      '��ȫ��ʾ',
      '��������Ҫ��װ StarEdge Studio Root CA ֤����ȷ������������' + #13#10 +
      'StarEdge Studio ������ŵ��' + #13#10 +
      '  1. ���Ǿ��������κη���������/����֤������/ʵ��ǩ��֤�顣' + #13#10 +
      '  2. ���Ǿ��������ô�֤�顣' + #13#10 +
      '�������һ����������װ��' + #13#10 
    );
end;


// ��װ��ɺ�ִ��֤�鵼������ PATH
procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    // 1. ��װ֤�鵽ϵͳ���洢�������ɹ���ʾ��
    if Exec(
      'certutil.exe',
      '-f -addstore Root "' + ExpandConstant('{app}\cert.cer') + '"',
      '', SW_HIDE, ewWaitUntilTerminated, ResultCode
    ) then
    begin
      // ���ڷǾ�Ĭģʽ��ʧ��ʱ����
      if ResultCode <> 0 then
        MsgBox('֤�鰲װʧ�ܣ�������룺' + IntToStr(ResultCode), mbError, MB_OK)
      else if not WizardSilent then
        ;
    end;

    // 2. ��� PATH������ʾ��
    if CurStep = ssPostInstall then begin
    // ���·��
    AddToPath(ExpandConstant('{app}'));
    // ˢ�»�����������ѡ��
    //RefreshEnvironment;
    end;
  end;
end;

// ж��ʱ�Ƴ� PATH
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then begin
    // �Ƴ�·��
    RemoveFromPath(ExpandConstant('{app}'));
    // ˢ�»�����������ѡ��
    //RefreshEnvironment;
  end;
end;

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

