import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.controls 1.0

InformationTag {
    id: root

    property string text
    property string buttonText
    property bool buttonVisible

    signal buttonClicked()

    implicitHeight: 33
    leftPadding: 10
    rightPadding: 4
    verticalPadding: 4
    spacing: 6

    backgroundColor: Theme.palette.dangerColor3
    bgBorderColor: Theme.palette.dangerColor2

    QtObject {
        id: priv

        readonly property int fontPixelSize: Theme.tertiaryTextFontSize
        readonly property color foregroundColor: Theme.palette.dangerColor1
    }

    asset {
        name: "warning"
        color: priv.foregroundColor
    }

    tagPrimaryLabel.text: root.text
    tagPrimaryLabel.color: priv.foregroundColor
    tagPrimaryLabel.font.pixelSize: priv.fontPixelSize
    tagPrimaryLabel.elide: Text.ElideRight

    // NB: regular binding won't work as `tagPrimaryLabel` is an alias
    Binding {
        target: tagPrimaryLabel
        property: "Layout.fillWidth"
        value: true
    }

    rightComponent: StatusButton {
        objectName: "rightComponentButton"
        horizontalPadding: 8

        width: visible || root.loading ? implicitWidth : 0
        visible: root.buttonVisible

        size: StatusBaseButton.Size.Tiny
        font.pixelSize: priv.fontPixelSize
        type: StatusBaseButton.Type.Danger
        normalColor: priv.foregroundColor
        hoverColor: Theme.palette.hoverColor(normalColor)
        textColor: Theme.palette.white
        radius: root.bgRadius
        text: root.buttonText
        onClicked: root.buttonClicked()
    }
}
