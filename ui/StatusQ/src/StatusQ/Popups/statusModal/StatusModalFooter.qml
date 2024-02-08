import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1


Rectangle {
    id: root

    property list<Item> leftButtons
    property list<StatusBaseButton> rightButtons
    property bool showFooter: true

    radius: 8

    color: Theme.palette.statusModal.backgroundColor

    onLeftButtonsChanged: {
        for (let idx in leftButtons) {
            leftButtons[idx].parent = leftButtonsLayout
            leftButtons[idx].Layout.fillWidth
                    = Qt.binding(() => root.width < root.implicitWidth)
        }
    }

    onRightButtonsChanged: {
        for (let idx in rightButtons) {
            rightButtons[idx].parent = rightButtonsLayout
            rightButtons[idx].Layout.fillWidth
                    = Qt.binding(() => root.width < root.implicitWidth)
        }
    }

    implicitWidth: rootLayout.implicitWidth + rootLayout.anchors.leftMargin
                   + rootLayout.anchors.rightMargin
    implicitHeight: rootLayout.implicitHeight + 30

    RowLayout {
        id: rootLayout
        spacing: 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 18

        RowLayout {
            id: leftButtonsLayout
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            visible: root.showFooter

            spacing: 16
        }

        Item {
            Layout.fillWidth: true
            Layout.minimumWidth: 16
        }

        RowLayout {
            id: rightButtonsLayout
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            visible: root.showFooter

            spacing: 16
        }
    }

    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: parent.radius
        color: parent.color

        StatusModalDivider {
            visible: (root.leftButtons.length || root.rightButtons.length) && rootLayout.height > 1
            anchors.top: parent.top
            width: parent.width
        }
    }
}
