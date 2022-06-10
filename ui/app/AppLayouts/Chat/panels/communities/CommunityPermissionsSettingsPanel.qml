import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls.chat 1.0

import "../../layouts"

SettingsPageLayout {
    id: root

    signal addPermission()

    title: qsTr("Permissions")

    content: Flickable {
        contentWidth: mainLayout.width
        contentHeight: mainLayout.height
        clip: true
        flickableDirection: Flickable.AutoFlickIfNeeded

        ColumnLayout {
            id: mainLayout

            width: 560
            spacing: 24

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: contentColumn.implicitHeight + contentColumn.anchors.topMargin + contentColumn.anchors.bottomMargin
                color: "transparent"
                radius: 16
                border.color: Theme.palette.baseColor5
                clip: true

                ColumnLayout {
                    id: contentColumn
                    anchors.fill: parent
                    anchors.margins: 16
                    anchors.bottomMargin: 32
                    spacing: 8
                    clip: true
                    Image {
                        Layout.preferredWidth: 257
                        Layout.preferredHeight: Layout.preferredWidth
                        Layout.alignment: Qt.AlignHCenter
                        source: Style.png("community/permissions21_3 1")
                        mipmap: true
                    }
                    StatusBaseText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Permissions")
                        font.pixelSize: 17
                        font.weight: Font.Bold
                        color: Theme.palette.directColor1
                    }
                    StatusBaseText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("You can manage your community by creating and issuing membership and access permissions")
                        lineHeight: 1.2
                        font.pixelSize: 15
                        color: Theme.palette.baseColor1
                        wrapMode: Text.WordWrap
                    }
                    ColumnLayout {
                        id: checkersColumn
                        property int rowChildSpacing: 10
                        property color rowIconColor: Theme.palette.primaryColor1
                        property string rowIconName: "checkmark-circle"
                        property int rowFontSize: 15
                        property color rowTextColor: Theme.palette.directColor1
                        property double rowTextLineHeight: 1.2

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft
                        spacing: 10
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: checkersColumn.rowChildSpacing
                            StatusIcon {
                                icon: checkersColumn.rowIconName
                                color: checkersColumn.rowIconColor
                            }
                            StatusBaseText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                text: qsTr("Give individual members access to private channels")
                                lineHeight: checkersColumn.rowTextLineHeight
                                font.pixelSize: checkersColumn.rowFontSize
                                color: checkersColumn.rowTextColor
                                wrapMode: Text.WordWrap
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: checkersColumn.rowChildSpacing
                            StatusIcon {
                                icon: checkersColumn.rowIconName
                                color: checkersColumn.rowIconColor
                            }
                            StatusBaseText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                text: qsTr("Monetise your community with subscriptions and fees")
                                lineHeight: checkersColumn.rowTextLineHeight
                                font.pixelSize: checkersColumn.rowFontSize
                                color: Theme.palette.directColor1
                                wrapMode: Text.WordWrap
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: checkersColumn.rowChildSpacing
                            StatusIcon {
                                icon: checkersColumn.rowIconName
                                color: checkersColumn.rowIconColor
                            }
                            StatusBaseText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                text: qsTr("Require holding a token or NFT to obtain exclusive membership rights")
                                lineHeight: checkersColumn.rowTextLineHeight
                                font.pixelSize: checkersColumn.rowFontSize
                                color: checkersColumn.rowTextColor
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }

            // TODO: Needed `StatusButton` redesign that allows to fill the width.
            StatusButton {
                text: qsTr("Add permission")
                height: 44
                Layout.alignment: Qt.AlignHCenter
                //Layout.fillWidth: true
                onClicked: root.addPermission()
            }
        }
    }
}
