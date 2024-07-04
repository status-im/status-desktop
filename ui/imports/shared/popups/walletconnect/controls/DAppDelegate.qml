import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

MouseArea {
    id: root
    implicitHeight: 50

    hoverEnabled: true

    required property string name
    required property string url
    required property string iconUrl

    signal disconnectDapp()

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8

        Item {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32

            StatusImage {
                id: iconImage

                anchors.fill: parent

                source: root.iconUrl
                visible: !fallbackImage.visible
            }

            StatusIcon {
                id: fallbackImage

                anchors.fill: parent

                icon: "dapp"
                color: Theme.palette.baseColor1

                visible: iconImage.isLoading || iconImage.isError || !root.iconUrl
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: iconImage.width
                    height: iconImage.height
                    radius: width / 2
                    visible: false
                }
            }
        }

        ColumnLayout {
            Layout.leftMargin: 12
            Layout.rightMargin: 12

            StatusBaseText {
                text: root.name

                Layout.fillWidth: true

                font.pixelSize: 13
                font.bold: true

                elide: Text.ElideRight

                clip: true
            }
            StatusBaseText {
                text: root.url

                Layout.fillWidth: true

                font.pixelSize: 12
                color: Theme.palette.baseColor1

                elide: Text.ElideRight

                clip: true
            }
        }

        StatusFlatButton {
            size: StatusBaseButton.Size.Large

            asset.color: root.containsMouse ? Theme.palette.directColor1
                                            : Theme.palette.baseColor1

            icon.name: "disconnect"
            tooltip.text: qsTr("Disconnect dApp")

            onClicked: {
                console.debug(`TODO #14755 - Disconnect ${root.name}`)
                // root.disconnectDapp()
            }
        }
    }
}
