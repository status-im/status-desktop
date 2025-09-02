import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls

import utils

Control {
    id: root

    property alias primaryText: primaryTextComponent.text
    property alias primaryTextSize: primaryTextComponent.font.pixelSize
    property bool primaryTextClickable: false
    property string primarySideText: ""
    property string secondaryText: ""
    property string tertiaryText: ""
    property alias iconsRowComponent: iconsLoader.sourceComponent

    signal primaryTextClicked()

    contentItem: Flow {
        spacing: Theme.smallPadding / 2

        StatusLinkText {
            id: primaryTextComponent

            width: Math.min(implicitWidth, parent.width)
            maximumLineCount: 3
            color: Theme.palette.directColor1
            font.pixelSize: Theme.additionalTextSize
            font.weight: Font.Middle
            wrapMode: Text.WordWrap
            enabled: root.primaryTextClickable
            font.underline: containsMouse && enabled

            onClicked: root.primaryTextClicked()
        }

        Loader {
            active: !!root.primarySideText
            width: Math.min(implicitWidth, parent.width)
            visible: active
            asynchronous: true
            sourceComponent: StatusBaseText {
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.asideTextFontSize
                text: root.primarySideText
                elide: Text.ElideRight
            }
        }

        Loader {
            id: iconsLoader
            asynchronous: true
        }

        Loader {
            id: secondaryTextLoader
            active: !!root.secondaryText
            width: Math.min(implicitWidth, parent.width)
            visible: active
            asynchronous: true
            sourceComponent: StatusBaseText {
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.asideTextFontSize
                text: `(${root.secondaryText})`
                elide: Text.ElideRight
            }
        }

        Loader {
            id: dotLoader
            sourceComponent: dotComponent
            active: secondaryTextLoader.active && tertiaryTextLoader.active
            asynchronous: true
        }

        Loader {
            id: tertiaryTextLoader
            active: !!root.tertiaryText
            visible: active
            asynchronous: true
            sourceComponent: StatusBaseText {
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.asideTextFontSize
                visible: text
                elide: Text.ElideMiddle
                color: Theme.palette.baseColor1
                text: Utils.getElidedPk(root.tertiaryText)
            }
        }

        Component {
            id: dotComponent
            StatusBaseText {
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.asideTextFontSize
                color: Theme.palette.baseColor1
                text: "•"
            }
        }
    }
}
