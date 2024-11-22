import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Control {
    id: root

    property alias image: image.source
    property alias title: title.text
    property alias subTitle: subTitle.text
    property bool closeEnabled: true

    signal clicked()
    signal close()

    implicitHeight: 70
    implicitWidth: 400
    padding: Theme.halfPadding
    leftPadding: 20

    TapHandler {
        acceptedButtons: Qt.LeftButton
        enabled: !closeHandler.pressed
        onTapped: {
            root.clicked()
        }
    }
    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
    background: Rectangle {
        id: background
        color: Theme.palette.background
        radius: 12
        border.width: 1
        border.color: Theme.palette.baseColor2
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 7
            radius: 8
            spread: root.hovered ? 0.3 : 0
            color: Theme.palette.baseColor2
        }
    }
    contentItem: RowLayout {
        id: layout
        spacing: Theme.padding
        StatusImage {
            id: image
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            StatusBaseText {
                id: title
                Layout.fillWidth: true
                color: Theme.palette.directColor1
                font.pixelSize: Theme.additionalTextSize
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
            StatusBaseText {
                id: subTitle
                Layout.fillWidth: true
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.additionalTextSize
                elide: Text.ElideRight
            }
        }
        StatusIcon {
            id: closeButton
            objectName: "bannerCard_closeButton"
            Layout.topMargin: 4
            Layout.rightMargin: 4
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            icon: "close"
            color: closeHoverHandler.hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
            visible: root.closeEnabled && root.hovered
            TapHandler {
                id: closeHandler
                acceptedButtons: Qt.LeftButton
                onTapped: {
                    root.close()
                }
            }
            HoverHandler {
                id: closeHoverHandler
            }
        }
    }
}
