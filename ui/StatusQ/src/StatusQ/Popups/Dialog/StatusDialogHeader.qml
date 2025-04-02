import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    readonly property alias headline: headline
    readonly property alias actions: actions
    property bool dropShadowEnabled

    property alias leftComponent: leftComponentLoader.sourceComponent

    property bool internalPopupActive
    property color internalOverlayColor
    property int popupFullHeight
    property Component internalPopupComponent

    signal closeInternalPopup()

    color: Theme.palette.statusModal.backgroundColor
    radius: Theme.radius

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    // cover for the bottom rounded corners
    Rectangle {
        width: parent.width
        height: parent.radius
        anchors.bottom: parent.bottom
        color: parent.color
    }

    RowLayout {
        id: layout

        clip: true

        anchors {
            fill: parent
            margins: Theme.padding
        }

        spacing: Theme.halfPadding

        Loader {
            id: leftComponentLoader

            Layout.fillHeight: true
            visible: sourceComponent
        }

        StatusTitleSubtitle {
            id: headline

            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        StatusHeaderActions {
            id: actions

            Layout.alignment: Qt.AlignTop
        }
    }

    StatusDialogDivider {
        anchors.bottom: parent.bottom
        width: parent.width
    }

    layer.enabled: root.dropShadowEnabled
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 2
        samples: 37
        color: Theme.palette.dropShadow
    }

    Rectangle {
        id: internalOverlay
        anchors.fill: parent
        anchors.bottomMargin: -1 * root.popupFullHeight + root.height
        visible: root.internalPopupActive
        radius: root.radius
        color: root.internalOverlayColor

        StatusMouseArea {
            anchors.fill: parent
            anchors.bottomMargin: popupLoader.height
            onClicked: {
                root.closeInternalPopup()
            }
        }
    }

    Loader {
        id: popupLoader
        anchors.bottom: parent.bottom
        anchors.bottomMargin: internalOverlay.anchors.bottomMargin
        active: root.internalPopupActive
        sourceComponent: root.internalPopupComponent
    }
}
