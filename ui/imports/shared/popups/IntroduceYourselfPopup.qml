import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import StatusQ
import StatusQ.Core
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog

import utils
import shared.controls.chat

StatusDialog {
    id: root

    required property string pubKey
    required property int colorId
    required property var colorHash

    width: 480
    padding: Theme.smallPadding*2
    topPadding: Theme.xlPadding

    closePolicy: Popup.NoAutoClose

    title: qsTr("Introduce yourself")

    contentItem: ColumnLayout {
        spacing: Theme.xlPadding
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            Rectangle {
                Layout.preferredWidth: layout1.implicitWidth + layout1.anchors.margins * 2
                Layout.preferredHeight: layout1.implicitHeight + layout1.anchors.topMargin + layout1.anchors.bottomMargin
                color: "transparent"
                border.width: 1
                border.color: Theme.palette.baseColor2
                radius: 16

                ColumnLayout {
                    id: layout1
                    anchors.fill: parent
                    anchors.margins: 20
                    anchors.bottomMargin: Theme.padding

                    StatusUserImage {
                        Layout.preferredWidth: 72
                        Layout.preferredHeight: 72
                        Layout.alignment: Qt.AlignHCenter

                        name: root.pubKey
                        usesDefaultName: true
                        userColor: Utils.colorForColorId(root.colorId)
                        imageWidth: 68
                        imageHeight: 68
                        colorHash: root.colorHash
                        interactive: false
                    }
                    StatusBaseText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Theme.additionalTextSize
                        text: Utils.getElidedPk(root.pubKey)
                    }
                }
            }

            StatusIcon {
                icon: "arrow-right"
                color: Theme.palette.baseColor1
            }

            Rectangle {
                Layout.preferredWidth: layout2.implicitWidth + layout2.anchors.margins * 2
                Layout.preferredHeight: layout2.implicitHeight + layout2.anchors.topMargin + layout2.anchors.bottomMargin
                color: "transparent"
                border.width: 1
                border.color: Theme.palette.baseColor2
                radius: 16

                ColumnLayout {
                    id: layout2
                    anchors.fill: parent
                    anchors.margins: 20
                    anchors.bottomMargin: Theme.padding

                    StatusUserImage {
                        Layout.preferredWidth: 72
                        Layout.preferredHeight: 72
                        Layout.alignment: Qt.AlignHCenter

                        name: root.pubKey
                        usesDefaultName: true
                        image: Theme.png("onboarding/avatar")
                        userColor: Utils.colorForColorId(root.colorId)
                        imageWidth: 68
                        imageHeight: 68
                        colorHash: root.colorHash
                        interactive: false
                    }
                    StatusBaseText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Theme.additionalTextSize
                        text: qsTr("Your Name")
                    }
                }
            }
        }
        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: qsTr("Add an optional display name and profile picture so others can easily recognise you.")
        }
    }

    footer: StatusDialogFooter {
        spacing: Theme.padding
        rightButtons: ObjectModel {
            StatusFlatButton {
                objectName: "introduceSkipStatusFlatButton"
                text: qsTr("Skip")
                onClicked: root.close()
            }
            StatusButton {
                objectName: "introduceEditStatusFlatButton"
                icon.name: "settings"
                text: qsTr("Edit Profile in Settings")
                onClicked: root.accept()
            }
        }
    }
}
