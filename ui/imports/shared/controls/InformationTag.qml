import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Control {
    property alias image : image
    property alias iconAsset : iconAsset
    property alias tagPrimaryLabel: tagPrimaryLabel
    property alias tagSecondaryLabel: tagSecondaryLabel
    property alias controlBackground: controlBackground
    property alias rightComponent: rightComponent.sourceComponent

    horizontalPadding: Style.current.halfPadding
    verticalPadding: 5

    background: Rectangle {
        id: controlBackground
        implicitWidth: 66
        implicitHeight: 32
        color: "transparent"
        border.width: 1
        border.color: Theme.palette.baseColor2
        radius: 36
    }

    contentItem: RowLayout {
        spacing: 4
        // FIXME this could be StatusIcon but it can't load images from an arbitrary URL
        Image {
            id: image
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: visible ? 22 : 0
            Layout.maximumHeight: visible ? 22 : 0
            visible: image.source !== ""
        }
        StatusIcon {
            id: iconAsset
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: visible ? 22 : 0
            Layout.maximumHeight: visible ? 22 : 0
            visible: iconAsset.icon !== ""
        }
        StatusBaseText {
            id: tagPrimaryLabel
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: Style.current.primaryTextFontSize
            font.weight: Font.Medium
            color: Theme.palette.directColor1
            visible: text !== ""
        }
        StatusBaseText {
            id: tagSecondaryLabel
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 100
            font.pixelSize: Style.current.primaryTextFontSize
            font.weight: Font.Medium
            color: Theme.palette.baseColor1
            visible: text !== ""
            elide: Text.ElideMiddle
        }
        Loader {
            id: rightComponent
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
