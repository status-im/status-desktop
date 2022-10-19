import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Item {
    id: root

    implicitHeight: row.implicitHeight

    property alias enabled: hotReloadingCheckBox.checked

    signal forceReloadClicked

    function notifyReload() {
        reloadingAnimation.restart()
    }

    RowLayout {
        id: row

        anchors.left: parent.left
        anchors.right: parent.right

        CheckBox {
            id: hotReloadingCheckBox

            Layout.fillWidth: true

            text: "Hot reloading"
        }

        Button {
            Layout.rightMargin: 5

            text: "Reload now"

            onClicked: root.forceReloadClicked()
        }
    }

    Rectangle {
        anchors.fill: parent
        border.color: "red"
        border.width: 2
        color: "transparent"
        opacity: 0

        OpacityAnimator on opacity {
            id: reloadingAnimation

            running: false
            from: 1
            to: 0
            duration: 500
            easing.type: Easing.InQuad
        }
    }
}
