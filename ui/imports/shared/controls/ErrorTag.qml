import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import shared.controls

InformationTag {
    id: root

    property string text
    property string buttonText
    property bool buttonVisible

    signal buttonClicked()

    implicitHeight: 33
    leftPadding: 10
    rightPadding: buttonVisible ? 4 : 8
    verticalPadding: 4
    spacing: 6

    backgroundColor: Theme.palette.dangerColor3
    bgBorderColor: Theme.palette.dangerColor2

    QtObject {
        id: d

        readonly property int fontPixelSize: root.Theme.tertiaryTextFontSize
        readonly property color foregroundColor: root.Theme.palette.dangerColor1
    }

    asset {
        name: "warning"
        color: d.foregroundColor
    }

    tagPrimaryLabel.text: root.text
    tagPrimaryLabel.color: d.foregroundColor
    tagPrimaryLabel.font.pixelSize: d.fontPixelSize
    tagPrimaryLabel.elide: Text.ElideRight

    // NB: regular binding won't work as `tagPrimaryLabel` is an alias
    Binding {
        target: tagPrimaryLabel
        property: "Layout.fillWidth"
        value: true
    }

    rightComponent: buttonVisible ? rightButtonComponent : undefined

    Component {
        id: rightButtonComponent
        StatusButton {
            objectName: "rightComponentButton"
            horizontalPadding: 8
            size: StatusBaseButton.Size.Tiny
            font.pixelSize: d.fontPixelSize
            type: StatusBaseButton.Type.Danger
            normalColor: d.foregroundColor
            hoverColor: Theme.palette.hoverColor(normalColor)
            textColor: StatusColors.white
            radius: root.bgRadius
            text: root.buttonText
            onClicked: root.buttonClicked()
        }
    }
}
