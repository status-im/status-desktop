import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.stores 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../panels"
import "../controls"
import "../views"

Item {
    id: root
    height: visible ? stackLayout.height + modeSelectionTabBar.height + 2*Style.current.xlPadding: 0

    signal contactSelected(string address, int type)

    StatusSwitchTabBar {
        id: modeSelectionTabBar
        anchors.horizontalCenter: parent.horizontalCenter
        StatusSwitchTabButton {
            //% "Simple"
            text: qsTr("Simple")
        }
        StatusSwitchTabButton {
            //% "Advanced"
            text: qsTr("Advanced")
        }
        StatusSwitchTabButton {
            //% "Custom"
            text: qsTr("Custom")
        }
    }

    StackLayout {
        id: stackLayout
        anchors.top: modeSelectionTabBar.bottom
        anchors.topMargin: Style.current.xlPadding
        height: simpleLayout.height
        width: parent.width
        currentIndex: modeSelectionTabBar.currentIndex

        ColumnLayout {
            id: simpleLayout
            Layout.fillWidth: true
            spacing: 24
            // To-do networks depends on multi networks and fee suggestions not available yet
            Rectangle {
                id: networksRect
                radius: 13
                color: Theme.palette.indirectColor1
                Layout.fillWidth: true
                Layout.preferredHeight: layout.height + 24
                ColumnLayout {
                    id: layout
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 16
                    spacing: 20
                    RowLayout {
                        spacing: 10
                        StatusRoundIcon {
                            Layout.alignment: Qt.AlignTop
                            radius: 8
                            icon.name: "flash"
                        }
                        ColumnLayout {
                            StatusBaseText {
                                Layout.maximumWidth: 410
                                font.pixelSize: 15
                                font.weight: Font.Medium
                                color: Theme.palette.directColor1
                                //% "Networks"
                                text: qsTr("Networks")
                                wrapMode: Text.WordWrap
                            }
                            StatusBaseText {
                                Layout.maximumWidth: 410
                                font.pixelSize: 15
                                color: Theme.palette.baseColor1
                                //% "The networks where the receipient will receive tokens. Amounts calculated automatically for the lowest cost."
                                text: qsTr("The networks where the receipient will receive tokens. Amounts calculated automatically for the lowest cost.")
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                    RowLayout {
                        spacing: 16
                        Layout.leftMargin: 40
                        Repeater {
                            model: 3
                            StatusListItem {
                                implicitWidth: 126
                                title: "PlaceHolder" + index
                                subTitle: ""
                                icon.isLetterIdenticon: true
                                icon.width: 32
                                icon.height: 32
                                leftPadding: 0
                                rightPadding: 0
                                color: "transparent"
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: feesRect
                radius: 13
                color: Theme.palette.indirectColor1
                Layout.fillWidth: true
                Layout.preferredHeight: feesLayout.height + 32
                RowLayout {
                    id: feesLayout
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 16
                    spacing: 10
                    StatusRoundIcon {
                        Layout.alignment: Qt.AlignTop
                        radius: 8
                        icon.name: "fees"
                    }
                    ColumnLayout {
                        spacing: 12
                        StatusBaseText {
                            Layout.maximumWidth: 410
                            font.pixelSize: 15
                            font.weight: Font.Medium
                            color: Theme.palette.directColor1
                            //% "Fees"
                            text: qsTr("Fees")
                            wrapMode: Text.WordWrap
                        }
                        RowLayout {
                            spacing: 16
                            Repeater {
                                model: 3
                                delegate:
                                    RadioDelegate {
                                    id: control
                                    checked: index === 0
                                    contentItem.visible: false
                                    indicator.visible: false
                                    background: Rectangle {
                                        implicitWidth: 128
                                        implicitHeight: 78
                                        radius: 8
                                        color: control.checked ?  Theme.palette.indirectColor1: Theme.palette.baseColor4
                                        border.width: control.checked
                                        border.color: Theme.palette.primaryColor2
                                        ColumnLayout {
                                            width: parent.width
                                            anchors.top: parent.top
                                            anchors.left: parent.left
                                            anchors.margins: 8
                                            StatusBaseText {
                                                font.pixelSize: 15
                                                color: Theme.palette.baseColor1
                                                //% "Slow"
                                                text: qsTr("Slow")
                                                wrapMode: Text.WordWrap
                                            }
                                            StatusBaseText {
                                                font.pixelSize: 13
                                                color: Theme.palette.baseColor1                                                
                                                text: "0.24 USD"
                                                wrapMode: Text.WordWrap
                                            }
                                            StatusBaseText {
                                                font.pixelSize: 13
                                                color: Theme.palette.baseColor1
                                                text: "~15 minutes"
                                                wrapMode: Text.WordWrap
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        StatusBaseText {
            Layout.alignment: Qt.AlignCenter
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: "Not Implemented"
        }

        StatusBaseText {
            Layout.alignment: Qt.AlignCenter
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: "Not Implemented"
        }
    }
}
