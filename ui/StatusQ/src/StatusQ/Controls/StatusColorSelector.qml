import QtQuick 2.13
import QtQuick.Controls 2.13
import StatusQ.Controls 0.1

StatusComboBox {
    id: root

    label: qsTr("Color")

    control.popup.horizontalPadding: 0

    contentItem: null

    control.background: Rectangle {
        implicitWidth: 448
        radius: 8
        color: root.control.currentValue
    }

    delegate: StatusItemDelegate {
        width: parent.width
        background: Rectangle {
            width: parent.width
            implicitHeight: 52
            color: modelData
        }
    }
}

