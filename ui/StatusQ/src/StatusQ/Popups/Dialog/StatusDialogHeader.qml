import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    readonly property alias headline: headline
    readonly property alias actions: actions

    property alias leftComponent: leftComponentLoader.sourceComponent

    color: Theme.palette.statusModal.backgroundColor
    radius: 8

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    RowLayout {
        id: layout

        clip: true

        anchors {
            fill: parent
            margins: 16
        }

        spacing: 8

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
}
