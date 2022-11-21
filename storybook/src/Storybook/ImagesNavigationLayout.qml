import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

ColumnLayout {
    id: root

    property alias count: indicator.count
    property alias currentIndex: indicator.currentIndex

    signal up
    signal left
    signal right

    RowLayout {
        Layout.alignment: Qt.AlignHCenter

        RoundButton {
            text: "⬅"
            enabled: root.currentIndex !== 0
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
