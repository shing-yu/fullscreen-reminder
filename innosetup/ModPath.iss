// ----------------------------------------------------------------------------
// 修改说明：
// 1. 移除任务（modifypath）依赖，改为代码直接控制
// 2. 仅保留 Windows NT 路径处理逻辑（Modern Windows）
// 3. 提供 AddToPath 和 RemoveFromPath 函数供外部调用
// ----------------------------------------------------------------------------

procedure AddToPath(Dir: string);
var
  oldPath: string;
  newPath: string;
  pathArr: TArrayOfString;
  i: Integer;
begin
  if not UsingWinNT() then
    Exit; // 仅支持 NT 系统

  // 检查路径是否已存在
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', oldPath) then
    oldPath := '';

  // 分割路径为数组
  oldPath := oldPath + ';';
  i := 0;
  while (Pos(';', oldPath) > 0) do begin
    SetArrayLength(pathArr, i + 1);
    pathArr[i] := Copy(oldPath, 1, Pos(';', oldPath) - 1);
    oldPath := Copy(oldPath, Pos(';', oldPath) + 1, Length(oldPath));
    
    // 跳过空项和已存在的路径
    if (pathArr[i] = '') or (CompareText(pathArr[i], Dir) = 0) then
      SetArrayLength(pathArr, i)
    else
      i := i + 1;
  end;

  // 添加新路径
  SetArrayLength(pathArr, i + 1);
  pathArr[i] := Dir;

  // 合并为新路径字符串
  newPath := '';
  for i := 0 to GetArrayLength(pathArr) - 1 do
    newPath := newPath + pathArr[i] + ';';
  newPath := Copy(newPath, 1, Length(newPath) - 1); // 移除末尾分号

  // 写入注册表
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

  // 获取当前路径
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', oldPath) then
    Exit;

  // 分割并过滤目标路径
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

  // 合并新路径
  newPath := '';
  for i := 0 to GetArrayLength(pathArr) - 1 do
    newPath := newPath + pathArr[i] + ';';
  newPath := Copy(newPath, 1, Length(newPath) - 1);

  // 更新注册表
  RegWriteStringValue(
    HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path',
    newPath
  );
end;