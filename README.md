# Fullscreen Reminder

好看的全屏提醒工具，可用于定时提醒、喝水、休息等场景。  
基于PyQt5开发，主要支持Windows平台，其他平台未经测试。
可加入Path后被其他程序调用或独立使用。

## 核心特性

- **沉浸式美观设计/配色方案**
  拥有十分漂亮的界面，和优雅的渐变配色方案，可修改代码实现自定义配色
- **强制展示机制**  
  窗口置顶、无边框设计，禁用系统快捷键(Alt+F4/Esc)
- **UIAccess权限**  
  在Windows上，可实现最高等级的置顶窗口，甚至在锁屏状态下也能展示
- **动态效果优化**  
  800ms淡入动画，缓解视觉冲击
- **高可定制性**  
  开放式代码结构，支持修改字体/布局/交互逻辑
  
## 安装使用

到[releases](https://github.com/shing-yu/fullscreen-reminder/releases)页面下载最新版本的安装程序，安装完成后，打开终端运行`fullscreen-reminder`

参数列表：

| 参数 | 类型 | 默认值 | 说明                |
|----------|------|--------|---------------------|
| -t  | int  | 10     | 倒计时时长（秒）    |
| -x  | str  | 💧喝水时间到   | 主显示文本  |
| -i  | str  | 倒计时结束后自动关闭   | 提示文本  |

推荐通过任务计划程序或其他程序调用本程序。

## 开发

### 环境要求
- Python 3.8+
- PyQt5 5.15+

```bash
uv sync
```
或

```bash
pip install -r requirements.txt
```

### 界面定制
编辑 `main.py` 中的以下参数：

```python
# 渐变配色方案
gradient_colors = [
    (0.0, "#83a4d4"),   # 起始颜色
    (1.0, "#b6fbff")    # 结束颜色
]
```

### 生成可执行文件
```bash
nuitka --standalone --enable-plugin=pyqt5 --remove-output --windows-console-mode=disable --assume-yes-for-downloads --windows-uac-admin --windows-uac-uiaccess main.py
```
或
```bash
pyinstaller --onefile --noconsole --uac-admin --uac-uiaccess main.py
```

若要启用UIAccess权限，你需要使用`signtool`签名生成的可执行文件，并将其放置在`C:\Program Files`等受信目录下。

`innosetup`目录下提供了使用Inno Setup打包的示例脚本，你可以根据需要进行修改。

## 许可证
MIT License