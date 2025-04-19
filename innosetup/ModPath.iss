// ----------------------------------------------------------------------------
// �޸�˵����
// 1. �Ƴ�����modifypath����������Ϊ����ֱ�ӿ���
// 2. ������ Windows NT ·�������߼���Modern Windows��
// 3. �ṩ AddToPath �� RemoveFromPath �������ⲿ����
// ----------------------------------------------------------------------------

procedure AddToPath(Dir: string);
var
  oldPath: string;
  newPath: string;
  pathArr: TArrayOfString;
  i: Integer;
begin
  if not UsingWinNT() then
    Exit; // ��֧�� NT ϵͳ

  // ���·���Ƿ��Ѵ���
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', oldPath) then
    oldPath := '';

  // �ָ�·��Ϊ����
  oldPath := oldPath + ';';
  i := 0;
  while (Pos(';', oldPath) > 0) do begin
    SetArrayLength(pathArr, i + 1);
    pathArr[i] := Copy(oldPath, 1, Pos(';', oldPath) - 1);
    oldPath := Copy(oldPath, Pos(';', oldPath) + 1, Length(oldPath));
    
    // ����������Ѵ��ڵ�·��
    if (pathArr[i] = '') or (CompareText(pathArr[i], Dir) = 0) then
      SetArrayLength(pathArr, i)
    else
      i := i + 1;
  end;

  // �����·��
  SetArrayLength(pathArr, i + 1);
  pathArr[i] := Dir;

  // �ϲ�Ϊ��·���ַ���
  newPath := '';
  for i := 0 to GetArrayLength(pathArr) - 1 do
    newPath := newPath + pathArr[i] + ';';
  newPath := Copy(newPath, 1, Length(newPath) - 1); // �Ƴ�ĩβ�ֺ�

  // д��ע���
  RegWriteStringValue(
    HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path',
    newPath
  );
end;

procedure RemoveFromPath(Dir: string);
var
  oldPath: string;
  newPath: string;
  pathArr: TArrayOfString;
  i: Integer;
begin
  if not UsingWinNT() then
    Exit;

  // ��ȡ��ǰ·��
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', oldPath) then
    Exit;

  // �ָ����Ŀ��·��
  oldPath := oldPath + ';';
  i := 0;
  while (Pos(';', oldPath) > 0) do begin
    SetArrayLength(pathArr, i + 1);
    pathArr[i] := Copy(oldPath, 1, Pos(';', oldPath) - 1);
    oldPath := Copy(oldPath, Pos(';', oldPath) + 1, Length(oldPath));
    
    if (pathArr[i] <> '') and (CompareText(pathArr[i], Dir) <> 0) then
      i := i + 1
    else
      SetArrayLength(pathArr, i);
  end;

  // �ϲ���·��
  newPath := '';
  for i := 0 to GetArrayLength(pathArr) - 1 do
    newPath := newPath + pathArr[i] + ';';
  newPath := Copy(newPath, 1, Length(newPath) - 1);

  // ����ע���
  RegWriteStringValue(
    HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path',
    newPath
  );
end;