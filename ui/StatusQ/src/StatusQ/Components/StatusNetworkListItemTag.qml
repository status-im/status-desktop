import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Control {
    id: root

    property alias titleText: titleText
    property alias button: button

    // property alias backgroundRect: backgroundRect

    property string title: ""
    // property color bgColor: Theme.palette.primaryColor3
    // property color bgColor: "transparent"
    // property color bgBorderColor: Theme.palette.baseColor2
    // property int bgRadius: 15

    signal clicked(var mouse)
    // signal tagClicked(var mouse)

    property StatusAssetSettings asset: StatusAssetSettings {
        height: 20
        width: 20
        rotation: 0
        isLetterIdenticon: false
        letterSize: 10
        // color: Theme.palette.primaryColor1
        color: "transparent"
        bgWidth: 15
        bgHeight: 15
        // bgColor: Theme.palette.primaryColor3
        bgColor: "transparent"
        imgIsIdenticon: false
    }

    property StatusBackgroundSettings bgSettings: StatusBackgroundSettings {
        color.normal: "transparent"
        color.hover: Theme.palette.primaryColor3
        borderColor.normal: Theme.palette.primaryColor2
        radius: 16
    }

    QtObject {
        id: d
        readonly property int commonMargin: 5
        readonly property int leftMargin: 8
        readonly property int minHeight: 32
    }

    leftPadding: d.leftMargin
    // rightPadding: d.commonMargin
    spacing: d.commonMargin
    implicitHeight: d.minHeight

    onHoveredChanged: console.log("hovered:", hovered)

    background: Rectangle {
        id: backgroundRect

        color: root.hovered ? bgSettings.color.hover : bgSettings.color.normal
        radius: bgSettings.radius
        onRadiusChanged: console.log("Background radiusChanged:", radius)
        border.color: bgSettings.borderColor.normal
        onHeightChanged: console.log("bg height:", height)

        TapHandler {
            // cursorShape: Qt.PointingHandCursor
            onTapped: root.clicked(eventPoint.position)
        }
    }

    contentItem: RowLayout {
        spacing: root.spacing

        StatusSmartIdenticon {
            id: iconOrImage
            asset: root.asset
            name: root.title
            active: root.asset.isLetterIdenticon ||
                    !!root.asset.name
        }

        StatusBaseText {
            id: titleText

            Layout.rightMargin: button.visible ? 0 : d.commonMargin
            Layout.fillWidth: true
            // Layout.fillHeight: true
            // Layout.alignment: Qt.AlignVCenter

            color: Theme.palette.primaryColor1
            text: root.title
            font.pixelSize: 15
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        StatusRoundButton {
            id: button

            Layout.preferredHeight: root.height - d.commonMargin
            Layout.preferredWidth: root.height - d.commonMargin
            Layout.rightMargin: d.commonMargin
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

            radius: height / 2
            onRadiusChanged: console.log("radius:", radius)
            onHeightChanged: console.log("height:", height)

            // color: "transparent"
            type: StatusRoundButton.Tertiary
            icon.name: "close"
            // icon.width: 12
            // icon.height: 12
        }
    }
}
