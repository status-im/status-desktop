import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "../../imports"
import "../../shared"
import "../../shared/status"
import "../../app/AppLayouts/Chat/ChatColumn/samples"

Popup {
    id: popup
    property var recentStickers: StickerData {}
    property var stickerPackList: StickerPackData {}
    signal stickerSelected(string hashId, string packId)
    width: 360
    height: 440
    modal: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background
        border.color: Style.current.border
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }
    onClosed: {
        stickerMarket.visible = false
        footerContent.visible = true
        stickersContainer.visible = true
    }
    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StatusStickerMarket {
            id: stickerMarket
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true
            stickerPacks: stickerPackList
            onInstallClicked: {
                chatsModel.installStickerPack(packId)
                stickerGrid.model = stickers
                stickerPackListView.itemAt(index).clicked()
            }
            onUninstallClicked: {
                chatsModel.uninstallStickerPack(packId)
                stickerGrid.model = recentStickers
                btnHistory.clicked()
            }
            onBackClicked: {
                stickerMarket.visible = false
                footerContent.visible = true
                stickersContainer.visible = true
            }
        }

        Item {
            id: stickersContainer
            Layout.fillWidth: true
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            Layout.topMargin: 4
            Layout.bottomMargin: 0
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.preferredHeight: 400 - 4

            Item {
                id: noStickerPacks
                anchors.fill: parent
                visible: stickerGrid.count <= 0 || stickerPackListView.count <= 0

                Image {
                    id: imgNoStickers
                    width: 56
                    height: 56
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 134
                    source: "../../app/img/stickers_sad_icon.svg"
                }

                Item {
                    id: noStickersContainer
                    width: parent.width
                    height: 22
                    anchors.top: imgNoStickers.bottom
                    anchors.topMargin: 8

                    StyledText {
                        id: lblNoStickersYet
                        visible: stickerPackListView.count <= 0
                        anchors.fill: parent
                        font.pixelSize: 15
                        //% "You don't have any stickers yet"
                        text: qsTrId("you-don't-have-any-stickers-yet")
                        lineHeight: 22
                        horizontalAlignment: Text.AlignHCenter
                    }

                    StyledText {
                        id: lblNoRecentStickers
                        visible: stickerPackListView.count > 0 && stickerGrid.count <= 0
                        anchors.fill: parent
                        font.pixelSize: 15
                        //% "Recently used stickers will appear here"
                        text: qsTrId("recently-used-stickers")
                        lineHeight: 22
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                StyledButton {
                    visible: stickerPackListView.count <= 0
                    //% "Get Stickers"
                    label: qsTrId("get-stickers")
                    anchors.top: noStickersContainer.bottom
                    anchors.topMargin: Style.current.padding
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        stickersContainer.visible = false
                        stickerMarket.visible = true
                        footerContent.visible = false
                    }
                }
            }
            StatusStickerList {
                id: stickerGrid
                model: recentStickers
                onStickerClicked: {
                    popup.stickerSelected(hash, packId)
                }
            }
        }

        Item {
            id: footerContent
            Layout.leftMargin: 8
            Layout.fillWidth: true
            Layout.preferredHeight: 40 - 8 * 2
            Layout.topMargin: 8
            Layout.rightMargin: 8
            Layout.bottomMargin: 8
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

            RoundedIcon {
                id: btnAddStickerPack
                anchors.left: parent.left
                anchors.top: parent.top
                width: 24
                height: 24
                iconWidth: 13.5
                iconHeight: 13.5
                source: "../../app/img/plusSign.svg"
                onClicked: {
                    stickersContainer.visible = false
                    stickerMarket.visible = true
                    footerContent.visible = false
                }
            }
            StatusStickerPackIconWithIndicator {
                id: btnHistory
                width: 24
                height: 24
                selected: true
                useIconInsteadOfImage: true
                source: "../../app/img/history_icon.svg"
                anchors.left: btnAddStickerPack.right
                anchors.leftMargin: Style.current.padding
                onClicked: {
                    btnHistory.selected = true
                    stickerPackListView.selectedPackId = -1
                    stickerGrid.model = recentStickers
                }
            }


            ScrollView {
                anchors.top: parent.top
                anchors.left: btnHistory.right
                anchors.leftMargin: Style.current.padding
                anchors.right: parent.right
                height: 32
                clip: true
                id: installedStickersSV
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                RowLayout {
                    id: stickersRowLayout
                    spacing: Style.current.padding
                    Repeater {
                        id: stickerPackListView
                        property int selectedPackId: -1
                        model: stickerPackList

                        delegate: StatusStickerPackIconWithIndicator {
                            id: packIconWithIndicator
                            visible: installed
                            width: 24
                            height: 24
                            selected: stickerPackListView.selectedPackId === packId
                            source: "https://ipfs.infura.io/ipfs/" + thumbnail
                            Layout.preferredHeight: height
                            Layout.preferredWidth: width
                            onClicked: {
                                btnHistory.selected = false
                                stickerPackListView.selectedPackId = packId
                                stickerGrid.model = stickers
                            }
                        }
                    }
                }
            }
        }
    }
}

