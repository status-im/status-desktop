import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    spacing: 8

    required property string dappName
    required property url dappIcon
    required property var account

    // Icons
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: 8

        StatusRoundedImage {
            id: dappIconComponent

            width: height
            height: parent.height

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -16
            anchors.verticalCenter: parent.verticalCenter

            image.source: root.dappIcon
        }
        StatusRoundIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 16
            anchors.verticalCenter: parent.verticalCenter

            asset: StatusAssetSettings {
                width: 24
                height: 24
                color: Theme.palette.primaryColor1
                bgWidth: 40
                bgHeight: 40
                bgColor: Theme.palette.desktopBlue10
                bgRadius: bgWidth / 2
                bgBorderWidth: 2
                bgBorderColor: Theme.palette.statusAppLayout.backgroundColor
                source: "assets/sign.svg"
            }
        }
    }
}
