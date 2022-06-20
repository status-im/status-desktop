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
    height: visible ? stackLayout.height + 2* Style.current.xlPadding : 0

    signal networkChanged(int chainId)

    property var suggestedRoutes: ""
    property var selectedNetwork: ""

    StackLayout {
        id: stackLayout
        anchors.top: parent.top
        anchors.topMargin: Style.current.xlPadding
        height: simpleLayout.height
        width: parent.width
        currentIndex: 0

        ColumnLayout {
            id: simpleLayout
            Layout.fillWidth: true
            spacing: Style.dp(24)
            Rectangle {
                id: networksRect
                radius: Style.dp(13)
                color: Theme.palette.indirectColor1
                Layout.fillWidth: true
                Layout.preferredHeight: layout.height + Style.dp(24)
                ColumnLayout {
                    id: layout
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: Style.current.padding
                    spacing: Style.dp(20)
                    RowLayout {
                        spacing: Style.dp(10)
                        StatusRoundIcon {
                            Layout.alignment: Qt.AlignTop
                            radius: Style.current.radius
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
                                Layout.maximumWidth: Style.dp(410)
                                font.pixelSize: Style.current.primaryTextFontSize
                                color: Theme.palette.baseColor1
                                text: qsTr("Choose a network to use for the transaction")
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                    StatusBaseText {
                        visible: suggestedRoutes.length === 0
                        font.pixelSize: Style.current.primaryTextFontSize
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: Theme.palette.dangerColor1
                        text: qsTr("No networks available")
                        wrapMode: Text.WordWrap
                    }

                    Item {
                        Layout.fillWidth: true
                        height: Style.dp(50)
                        ScrollView {
                            width: parent.width
                            contentWidth: row.width
                            contentHeight: row.height + Style.dp(10)
                            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
                            clip: true
                            Row {
                                id: row
                                spacing: Style.dp(16)
                                Repeater {
                                    id: repeater
                                    model: suggestedRoutes
                                    StatusListItem {
                                        id: item
                                        implicitWidth: Style.dp(126)
                                        title: modelData.chainName
                                        subTitle: ""
                                        image.source: Style.png("networks/" + modelData.chainName.toLowerCase())
                                        image.width: Style.dp(32)
                                        image.height: Style.dp(32)
                                        leftPadding: Style.dp(5)
                                        rightPadding: Style.dp(5)
                                        color: "transparent"
                                        border.color: Style.current.primary
                                        border.width: root.selectedNetwork.chainId === modelData.chainId ? 1 : 0
                                        onClicked: {
                                            root.selectedNetwork = modelData
                                            root.networkChanged(modelData.chainId)
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
}
