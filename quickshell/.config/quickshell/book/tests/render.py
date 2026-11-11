"""Optional Qt GPU smoke test: python tests/render.py OUTPUT_DIRECTORY.

Requires PySide6 6.8+. Runs Book.qml independently of the Quickshell window.
QT_QPA_PLATFORM=offscreen permits headless rendering when a GPU is available.
"""
import os
import sys
from pathlib import Path

from PySide6.QtCore import QUrl, QPoint, Qt, qInstallMessageHandler
from PySide6.QtGui import QGuiApplication, QColor
from PySide6.QtQuick import QQuickView, QSGRendererInterface
from PySide6.QtTest import QTest

output = Path(sys.argv[1])
output.mkdir(parents=True, exist_ok=True)
messages = []


def log(kind, context, message):
    messages.append(message)
    print(message)


qInstallMessageHandler(log)
app = QGuiApplication([])
view = QQuickView()
view.setColor(QColor("#211b14"))
if os.environ.get("BOOK_TEST_HIDDEN"):
    view.setFlags(Qt.Tool | Qt.FramelessWindowHint)
    view.setOpacity(0)
view.setResizeMode(QQuickView.SizeRootObjectToView)
view.resize(1060, 740)
view.setSource(QUrl.fromLocalFile(str(Path(__file__).resolve().parents[1] / "Book.qml")))
assert not view.errors(), view.errors()
view.show()
QTest.qWait(300)
assert view.rendererInterface().graphicsApi() != QSGRendererInterface.Software, "ShaderEffect requires a GPU backend"
book = view.rootObject()


def capture(name):
    view.update()
    QTest.qWait(100)
    frame = view.grabWindow()
    assert not frame.isNull(), "GPU capture unavailable"
    assert frame.save(str(output / (name + ".png")))
    return frame


idle = capture("idle")
for direction in (1, -1):
    book.setProperty("direction", direction)
    book.setProperty("turning", True)
    for progress in (0.0, 0.25, 0.5, 0.75, 1.0):
        book.setProperty("progress", progress)
        frame = capture(f"page_{direction}_{progress}")
        if progress in (0.25, 0.5, 0.75):
            assert frame != idle, "Shader produced no visible change"
    book.setProperty("progress", 0.4)
    still = capture(f"hold_{direction}")
    QTest.qWait(200)
    assert view.grabWindow() == still, "Page moved without pointer input"

book.setProperty("turning", False)
book.setProperty("progress", 0.0)
scale = book.property("bookScale")
bx, by = book.property("bookX"), book.property("bookY")


def pos(x, y):
    return QPoint(round(bx + x * scale), round(by + y * scale))


for direction, start, end in ((1, 1320, 300), (-1, 210, 1230)):
    QTest.mousePress(view, Qt.LeftButton, Qt.NoModifier, pos(start, 500))
    QTest.mouseMove(view, pos((start + end) / 2, 540), 20)
    QTest.qWait(50)
    progress = book.property("progress")
    assert 0.3 < progress < 0.5, progress
    QTest.qWait(100)
    assert book.property("progress") == progress
    QTest.mouseMove(view, pos(end, 500), 20)
    assert book.property("progress") > 0.5
    QTest.mouseRelease(view, Qt.LeftButton, Qt.NoModifier, pos(end, 500))
    QTest.qWait(600)
    assert not book.property("turning")
    assert book.property("progress") == 0.0

errors = [m for m in messages if any(s in m.lower() for s in (
    "error", "failed", "cannot", "not found", "unable", "referenceerror"))]
assert not errors, errors
print("PASS: GPU frames, both directions, frozen drag, release and repeat; no Qt errors")
view.close()
