import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import "../../components" as WalletComponents
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status/core"

Item {

    Loader {
        id: contentLoader
        width: parent.width
        height: parent.height

        sourceComponent: {
            if (walletV2Model.activityTabController.isLoadingActivities) {
                return loadingComponent
            }

            if (walletV2Model.activityTabController.activityModel.count === 0) {
                return emptyComponent
            }

            return loadedComponent
        }
    }

    Component {
        id: loadingComponent

        Item {
            StatusLoadingIndicator {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: 20
                height: 20
            }
        }
    }

    Component {
        id: emptyComponent
        Item {
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: Style.current.secondaryText
                text: qsTr("There are no any activities yet")
                font.pixelSize: 15
            }
        }
    }

    Component {
        id: loadedComponent

        ListView {
            id: listView
            anchors.fill: parent
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: walletV2Model.activityTabController.activityModel
            delegate: rowComponent
            ScrollBar.vertical: ScrollBar { }

            section.property: "sectionName"
            section.criteria: ViewSection.FullString
            section.delegate: Item {
                height: 34
                width: listView.width
                StyledText {
                    font.pixelSize: Style.current.primaryTextFontSize
                    color: Style.current.secondaryText
                    text: section
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                }
            }
        }
    }

    Component {
        id: rowComponent

        Rectangle {
            id: row
            property bool isIncoming: toAddress === walletV2Model.accountsView.currentAccount.address
            anchors.right: parent.right
            anchors.left: parent.left
            height: 64
            color: rowMouseArea.containsMouse? Style.current.secondaryBackground : Style.current.transparent
            radius: 8

            MouseArea {
                id: rowMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: {
                    rightPanelActivityItem.open(model.tokenName,
                                                model.tokenIcon,
                                                model.timestamp,
                                                model.transactionHash,
                                                model.blockNumber,
                                                model.nonce,
                                                model.fromAddress,
                                                model.toAddress,
                                                model.gasLimit,
                                                model.gasUsed,
                                                model.gasPrice,
                                                model.inputData)
                }
            }

            RowLayout {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                spacing: Style.current.smallPadding

                Image {
                    id: assetIcon
                    Layout.leftMargin: Style.current.smallPadding
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 40
                    source: "../../../../" + model.tokenIcon
                    onStatusChanged: {
                        if (assetIcon.status == Image.Error) {
                            assetIcon.source = "../../../../img/tokens/DEFAULT-TOKEN@3x.png"
                        }
                    }
                }

                Column {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 180
                    spacing: Style.current.smallPadding

                    StyledText {
                        font.pixelSize: Style.current.primaryTextFontSize
                        text: model.tokenName
                    }

                    Row {
                        width: parent.width
                        spacing: 0

                        WalletComponents.DateTime {
                            timestamp: model.timestamp
                            selectedFormat: format_hhmm
                        }

                        StyledText {
                            text: " • "
                            color: Style.current.secondaryText
                            font.pixelSize: Style.current.primaryTextFontSize
                        }

                        StyledText {
                            text: row.isIncoming? fromAddress : toAddress
                            width: 150
                            color: Style.current.secondaryText
                            font.pixelSize: Style.current.primaryTextFontSize
                            elide: Text.ElideMiddle
                        }
                    }
                }

                Item {
                    // this is a simple spacer
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }

                Column {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 180
                    Layout.rightMargin: Style.current.smallPadding
                    Layout.alignment: Qt.AlignRight
                    spacing: Style.current.smallPadding

                    Row {
                        anchors.right: parent.right

                        StyledText {
                            id: direction
                            height: 15
                            width: 15
                            color: isIncoming ? Style.current.success : Style.current.danger
                            text: isIncoming ? "↓" : "↑"
                            transform: Rotation {
                                origin.x: direction.width*0.5
                                origin.y: direction.height*0.5
                                angle: row.isIncoming? -45 : 45
                            }
                        }

                        StyledText {
                            text: Utils.toLocaleString(amount, globalSettings.locale) + " " + tokenSymbol
                            font.strikeout: false
                            font.pixelSize: Style.current.primaryTextFontSize
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    StyledText {
                        anchors.right: parent.right
                        text: Utils.toLocaleString(forAmount, globalSettings.locale) + " " + walletV2Model.activityTabController.defaultCurrency().toUpperCase()
                        color: Style.current.secondaryText
                        font.pixelSize: Style.current.primaryTextFontSize
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
