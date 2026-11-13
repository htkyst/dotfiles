"""Optional Qt GPU smoke test: python tests/render.py OUTPUT_DIRECTORY.

Requires PySide6 6.8+. Runs Book.qml independently of the Quickshell window.
QT_QPA_PLATFORM=offscreen permits headless rendering when a GPU is available.
"""
import os
import sys
from pathlib import Path

from PySide6.QtCore import QUrl, QPoint, QPointF, Qt, qInstallMessageHandler
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


def wait_for_landing():
    # Hidden native windows can throttle animation delivery; wait for state.
    for _ in range(100):
        QTest.qWait(50)
        if not book.property("turning"):
            return
    raise AssertionError("Page did not finish landing")


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
    wait_for_landing()
    assert not book.property("turning")
    assert book.property("progress") == 0.0

bookmark = book.findChild(type(book), "bookmark")
assert bookmark is not None


def bookmark_center():
    return QPoint(round(bookmark.x() + bookmark.width() / 2),
                  round(bookmark.y() + bookmark.height() / 2))


def turn(direction):
    start, end = (1320, 300) if direction == 1 else (210, 1230)
    QTest.mousePress(view, Qt.LeftButton, Qt.NoModifier, pos(start, 600))
    QTest.mouseMove(view, pos(end, 600), 20)
    QTest.mouseRelease(view, Qt.LeftButton, Qt.NoModifier, pos(end, 600))
    wait_for_landing()


assert book.property("currentPage") == 1
turn(-1)
assert book.property("currentPage") == 1
for page in range(2, 9):
    turn(1)
    assert book.property("currentPage") == page
turn(1)
assert book.property("currentPage") == 8

# Exercise the picker in a second native Qt window. The Linux-only PanelWindow
# hosting/Wayland layer order must additionally be checked on Quickshell.
picker_view = QQuickView()
if os.environ.get("BOOK_TEST_HIDDEN"):
    picker_view.setFlags(Qt.Tool | Qt.FramelessWindowHint)
    picker_view.setOpacity(0)
picker_view.setResizeMode(QQuickView.SizeRootObjectToView)
picker_view.resize(1060, 740)
picker_view.setSource(QUrl.fromLocalFile(str(Path(__file__).resolve().parents[1] / "PagePicker.qml")))
assert not picker_view.errors()
picker = picker_view.rootObject()
picker.setProperty("pageImages", ["assets/siori.png"] * 8)


def show_picker():
    picker.setProperty("currentPage", book.property("currentPage"))
    book.setEnabled(False)
    picker_view.show()


def dismiss_picker():
    picker_view.hide()
    book.setEnabled(True)


def select_page(page):
    dismiss_picker()
    book.openPage(page)


book.pickerRequested.connect(show_picker)
picker.pageSelected.connect(select_page)
picker.closeRequested.connect(dismiss_picker)


def find_card(item, name):
    # Repeater delegates belong to the visual tree, not necessarily the QObject tree.
    if item.objectName() == name:
        return item
    for child in item.childItems():
        result = find_card(child, name)
        if result is not None:
            return result
    return None


for page in range(1, 9):
    QTest.mouseClick(view, Qt.LeftButton, Qt.NoModifier, bookmark_center())
    QTest.qWait(100)
    assert picker_view.isVisible()
    card = find_card(picker, "pageCard" + str(page))
    assert card is not None
    center = card.mapToScene(QPointF(card.width() / 2, card.height() / 2)).toPoint()
    if page == 1:
        frame = picker_view.grabWindow()
        assert not frame.isNull()
        assert frame.save(str(output / "page_picker.png"))
    QTest.mouseClick(picker_view, Qt.LeftButton, Qt.NoModifier, center)
    assert not picker_view.isVisible()
    assert book.property("currentPage") == page

# Closing the picker without choosing preserves the current page.
QTest.mouseClick(view, Qt.LeftButton, Qt.NoModifier, bookmark_center())
QTest.qWait(100)
QTest.keyClick(picker_view, Qt.Key_Escape)
assert not picker_view.isVisible()
assert book.property("currentPage") == 8

# Opening the picker cancels an in-flight turn; its completion cannot later
# overwrite the selected destination.
QTest.mousePress(view, Qt.LeftButton, Qt.NoModifier, pos(210, 600))
QTest.mouseMove(view, pos(1230, 600), 20)
QTest.mouseRelease(view, Qt.LeftButton, Qt.NoModifier, pos(1230, 600))
QTest.mouseClick(view, Qt.LeftButton, Qt.NoModifier, bookmark_center())
assert not book.property("turning")
card = find_card(picker, "pageCard3")
QTest.mouseClick(picker_view, Qt.LeftButton, Qt.NoModifier,
                 card.mapToScene(QPointF(card.width() / 2, card.height() / 2)).toPoint())
QTest.qWait(600)
assert book.property("currentPage") == 3
capture("page_selected")

# The bookmark rail stays outside the entire book image at different sizes.
for width, height in ((1280, 800), (640, 800), (1920, 1080)):
    view.resize(width, height)
    QTest.qWait(50)
    assert bookmark.x() >= book.property("bookX") + 1536 * book.property("bookScale") + 23
    assert bookmark.x() + bookmark.width() <= book.width()
picker_view.close()

errors = [m for m in messages if any(s in m.lower() for s in (
    "error", "failed", "cannot", "not found", "unable", "referenceerror"))]
assert not errors, errors
print("PASS: GPU frames, page limits 1-8, all 8 picker selections, picker dismiss, interrupted turn, non-overlapping bookmark rail; no Qt errors")
view.close()
