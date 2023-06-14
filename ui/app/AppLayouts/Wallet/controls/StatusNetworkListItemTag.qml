import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Control {
    id: root

    property alias titleText: titleText
    property alias button: button

    property string title: ""

    signal clicked(var mouse)

    property StatusAssetSettings asset: StatusAssetSettings {
        height: 20
        width: 20
        rotation: 0
        isLetterIdenticon: false
        letterSize: 10
        color: "transparent"
        bgWidth: 15
        bgHeight: 15
        bgColor: "transparent"
        bgBorderColor: Theme.palette.baseColor2
        bgRadius: 16
        imgIsIdenticon: false
    }

    QtObject {
        id: d
        readonly property int commonMargin: 5
        readonly property int leftMargin: 8
        readonly property int minHeight: 32
    }

    leftPadding: d.leftMargin
    spacing: d.commonMargin
    implicitHeight: d.minHeight

    background: Rectangle {
        objectName: "networkTagRectangle_" + root.title
        color: root.hovered ? Theme.palette.primaryColor3 : asset.bgColor
        radius: asset.bgRadius
        border.color: asset.bgBorderColor

        MouseArea {
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            onClicked: root.clicked(mouse)
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

            color: enabled ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
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

            type: StatusRoundButton.Tertiary
            icon.name: "close"
        }
    }
}
