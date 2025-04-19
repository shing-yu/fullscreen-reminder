import sys
import argparse

import pyautogui
from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QVBoxLayout
from PyQt5.QtCore import Qt, QTimer, QPropertyAnimation
from PyQt5.QtGui import QFont, QLinearGradient, QPainter, QColor, QFontDatabase


# noinspection PyPep8Naming,PyAttributeOutsideInit
class FullScreenReminder(QWidget):
    def __init__(self, text, tip, duration_seconds=60):
        super().__init__()
        self.duration = duration_seconds
        self.remaining = self.duration
        self.title_text = text
        self.tip_text = tip
        self.load_fonts()
        self.setCursor(Qt.BlankCursor)  # 隐藏鼠标光标
        self.initUI()
        self.start_timer()
        self.setWindowOpacity(0)  # 初始完全透明

    @staticmethod
    def load_fonts():
        """加载字体"""
        ali_font = "assets/AlimamaFangYuanTiVF-Thin.ttf"
        jet_font = "assets/JetBrainsMono-ExtraBold.ttf"
        QFontDatabase.addApplicationFont(ali_font)
        QFontDatabase.addApplicationFont(jet_font)


    def initUI(self):
        # 窗口属性设置
        self.setWindowFlags(
            Qt.WindowStaysOnTopHint |
            Qt.FramelessWindowHint |
            Qt.X11BypassWindowManagerHint
        )
        self.showFullScreen()

        # 字体配置
        title_font = QFont("AlimamaFangYuanTiVF", 72)
        text_font = QFont("AlimamaFangYuanTiVF", 24)
        timer_font = QFont("JetBrains Mono ExtraBold", 180)

        # 界面元素
        layout = QVBoxLayout()
        layout.setContentsMargins(50, 100, 50, 100)

        self.title_label = QLabel(self.title_text)
        self.title_label.setFont(title_font)
        self.title_label.setAlignment(Qt.AlignCenter)
        self.title_label.setStyleSheet("color: #ffffff;")

        self.timer_label = QLabel()
        self.timer_label.setFont(timer_font)
        self.timer_label.setAlignment(Qt.AlignCenter)
        self.timer_label.setStyleSheet("color: rgba(255,255,255,0.9);")

        self.tip_label = QLabel(self.tip_text)
        self.tip_label.setFont(text_font)
        self.tip_label.setAlignment(Qt.AlignCenter)
        self.tip_label.setStyleSheet("color: rgba(255,255,255,0.8);")


        layout.addWidget(self.title_label)
        layout.addWidget(self.timer_label)
        layout.addWidget(self.tip_label)
        self.setLayout(layout)

        self.update_timer()

    def paintEvent(self, event):
        """绘制渐变背景"""
        painter = QPainter(self)
        gradient = QLinearGradient(0, 0, self.width(), self.height())
        gradient.setColorAt(0, QColor("#83a4d4"))  # 浅蓝
        gradient.setColorAt(1, QColor("#b6fbff"))  # 淡青
        painter.fillRect(self.rect(), gradient)

    def showEvent(self, event):
        """淡入动画"""
        self.animation = QPropertyAnimation(self, b"windowOpacity")
        self.animation.setDuration(800)
        self.animation.setStartValue(0)
        self.animation.setEndValue(1)
        self.animation.start()
        self.animation.finished.connect(self.after_show) # type: ignore

    @staticmethod
    def after_show():
        """使系统静音"""
        pyautogui.press('volumemute')

    def start_timer(self):
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_countdown)  # type: ignore
        self.timer.start(1000)

    def update_countdown(self):
        self.remaining -= 1
        if self.remaining <= 0:
            self.close()
        self.update_timer()

    def update_timer(self):
        minutes, seconds = divmod(self.remaining, 60)
        self.timer_label.setText(f"{minutes:02d}:{seconds:02d}")

    def keyPressEvent(self, event):
        if event.key() != Qt.Key_Escape:
            super().keyPressEvent(event)

    @staticmethod
    def before_close():
        """恢复系统音量"""
        pyautogui.press('volumemute')

    def closeEvent(self, event):
        if self.remaining <= 0:
            self.before_close()
            event.accept()
        else:
            event.ignore()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='健康提醒小工具')
    parser.add_argument('-x','--text', type=str, default='💧喝水时间到！', 
                      help='主显示文本（默认：💧喝水时间到！）')
    parser.add_argument('-i','--tip', type=str, default='倒计时结束后自动关闭',
                      help='提示文本（默认：倒计时结束后自动关闭）')
    parser.add_argument('-t','--time', type=int, default=10,
                      help='倒计时时长（秒，默认：10）')
    args = parser.parse_args()

    app = QApplication(sys.argv)
    window = FullScreenReminder(
        text=args.text,
        tip=args.tip,
        duration_seconds=args.time
    )
    sys.exit(app.exec_())