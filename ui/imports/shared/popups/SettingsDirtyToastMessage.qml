import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: root

    property bool active: false
    property bool saveChangesButtonEnabled: false

    property Flickable flickable: null

    signal saveChangesClicked
    signal resetChangesClicked

    function notifyDirty() {
        toastAlertAnimation.running = true
        saveChangesButton.forceActiveFocus()
    }

    implicitHeight: toastContent.implicitHeight + toastContent.anchors.topMargin + toastContent.anchors.bottomMargin
    implicitWidth: toastContent.implicitWidth + toastContent.anchors.leftMargin + toastContent.anchors.rightMargin

    opacity: active ? 1 : 0
    color: Theme.palette.statusToastMessage.backgroundColor
    radius: 8
    border.color: Theme.palette.dangerColor2
    border.width: 2
    layer.enabled: true
    layer.effect: DropShadow {
        verticalOffset: 3
        radius: 8
        samples: 15
        fast: true
        cached: true
        color: Theme.palette.dangerColor2
        spread: 0.1
    }

    onActiveChanged: {
        if (!active || !flickable)
            return;

        const item = Global.applicationWindow.activeFocusItem;
        const h1 = this.height;
        const y1 = this.mapToGlobal(0, 0).y;
        const h2 = item.height;
        const y2 = item.mapToGlobal(0, 0).y;
        const margin = 20;
        const offset = h2 - (y1 - y2);

        if (offset <= 0)
            return;

        toastFlickAnimation.from = flickable.contentY;
        toastFlickAnimation.to = flickable.contentY + offset + margin;
        toastFlickAnimation.start()
    }

    NumberAnimation {
        id: toastFlickAnimation
        target: root.flickable
        property: "contentY"
        duration: 150
        easing.type: Easing.InOutQuad
    }

    NumberAnimation on border.width {
        id: toastAlertAnimation
        from: 0
        to: 4
        loops: 2
        duration: 600
        onFinished: root.border.width = 2
    }

    Behavior on opacity {
        NumberAnimation {}
    }

    MouseArea {
        anchors.fill: parent
        visible: root.active // This is required not to change cursorShape
        enabled: root.active
        hoverEnabled: true
    }

    RowLayout {
        id: toastContent

        anchors {
            fill: parent
            margins: 16
        }

        StatusBaseText {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            padding: 8
            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.directColor1
            text: qsTr("Changes detected")
        }

        StatusButton {
            text: qsTr("Cancel")
            enabled: root.active
            type: StatusBaseButton.Type.Danger
            onClicked: root.resetChangesClicked()
        }

        StatusButton {
            id: saveChangesButton
            enabled: root.active && root.saveChangesButtonEnabled
            text: qsTr("Save changes")
            onClicked: root.saveChangesClicked()
        }
    }
}
