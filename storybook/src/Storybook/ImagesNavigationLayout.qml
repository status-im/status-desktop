import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    property alias count: indicator.count
    property alias currentIndex: indicator.currentIndex

    signal moveUp
    signal moveLeft
    signal moveRight

    RowLayout {
        Layout.alignment: Qt.AlignHCenter

        RoundButton {
            text: "⬅"
            enabled: root.currentIndex !== 0 && root.currentIndex !== -1
            onClicked: root.left()
        }
        RoundButton {
            text: "⬆"
            onClicked: root.up()
        }
        RoundButton {
            text: "➡"
            enabled: root.currentIndex !== root.count - 1
            onClicked: root.right()
        }
    }

    PageIndicator {
        id: indicator

        Layout.alignment: Qt.AlignHCenter

        interactive: true
    }
}
