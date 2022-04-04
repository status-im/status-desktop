import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import utils 1.0
import shared.panels 1.0

import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Components 0.1
//TODO improve this!
import AppLayouts.Chat.stores 1.0

Popup {
    id: root
    property var store
    property var recentStickers: StickerData {}
    property var stickerPackList: StickerPackData {}
    signal stickerSelected(string hashId, string packId)
    property int installedPacksCount: stickersModule.numInstalledStickerPacks
    property bool stickerPacksLoaded: false
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
    Connections {
        target: mainModule
        onOnlineStatusChanged: {
            root.close()
        }
    }

    Component.onCompleted: {
        if (stickersModule.packsLoaded) {
            root.setStickersReady()
        }
    }

    function setStickersReady() {
        root.stickerPacksLoaded = true
        stickerPackListView.visible = true
        loadingGrid.active = false
        loadingStickerPackListView.model = []
        noStickerPacks.visible = installedPacksCount === 0 || stickersModule.recent.rowCount() === 0
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StatusStickerMarket {
            id: stickerMarket
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true
            store: root.store
            stickerPacks: stickerPackList
            packId: stickerPackListView.selectedPackId
            onInstallClicked: {
                stickersModule.install(packId)
                stickerGrid.model = stickers
                stickerPackListView.itemAt(index).clicked()
            }
            onUninstallClicked: {
                stickersModule.uninstall(packId)
                stickerGrid.model = recentStickers
                btnHistory.clicked()
            }
            onBackClicked: {
                stickerMarket.visible = false
                footerContent.visible = true
                stickersContainer.visible = true
            }

            Loader {
                id: marketLoader
                active: !root.stickerPacksLoaded
                sourceComponent: loadingImageComponent
                anchors.centerIn: parent
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
                visible: installedPacksCount == 0

                Image {
                    id: imgNoStickers
                    visible: lblNoStickersYet.visible || lblNoRecentStickers.visible
                    width: 56
                    height: 56
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 134
                    source: Style.svg("stickers_sad_icon")
                }

                Item {
                    id: noStickersContainer
                    width: parent.width
                    height: 22
                    anchors.top: imgNoStickers.bottom
                    anchors.topMargin: 8

                    StyledText {
                        id: lblNoStickersYet
                        visible: root.installedPacksCount === 0
                        anchors.fill: parent
                        font.pixelSize: 15
                        text: qsTr("You don't have any stickers yet")
                        lineHeight: 22
                        horizontalAlignment: Text.AlignHCenter
                    }

                    StyledText {
                        id: lblNoRecentStickers
                        visible: stickerPackListView.selectedPackId === -1 && stickersModule.recent.rowCount() === 0 && !lblNoStickersYet.visible
                        anchors.fill: parent
                        font.pixelSize: 15
                        text: qsTr("Recently used stickers will appear here")
                        lineHeight: 22
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                StatusQControls.StatusButton {
                    visible: lblNoStickersYet.visible
                    text: qsTr("Get Stickers")
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
                packId: stickerPackListView.selectedPackId
                onStickerClicked: {
                    root.stickerSelected(hash, packId)
                    root.close()
                }
            }


            Component {
                id: loadingImageComponent
                StatusLoadingIndicator {
                    width: 50
                    height: 50
                }
            }

            Loader {
                id: loadingGrid
                active: stickersModule.recent.rowCount() === 0
                sourceComponent: loadingImageComponent
                anchors.centerIn: parent
            }
        }

        Row {
            id: footerContent
            Layout.fillWidth: true
            leftPadding: Style.current.padding / 2
            rightPadding: Style.current.padding / 2
            spacing: Style.current.padding / 2

            StatusQControls.StatusFlatRoundButton {
                id: btnAddStickerPack
                implicitHeight: 24
                implicitWidth: 24
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.current.padding / 2
                icon.name: "add"
                type: StatusQControls.StatusFlatRoundButton.Type.Tertiary
                color: "transparent"
                state: root.stickerPacksLoaded ? "default" : "pending"
                onClicked: {
                    stickersContainer.visible = false
                    stickerMarket.visible = true
                    footerContent.visible = false
                }
            }

            StatusQControls.StatusTabBarIconButton {
                id: btnHistory
                icon.name: "time"
                highlighted: true
                onClicked: {
                    highlighted = true
                    stickerPackListView.selectedPackId = -1
                    stickerGrid.model = recentStickers
                }
            }

            ScrollView {
                id: installedStickersSV
                anchors.bottom: parent.bottom
                height: 32
                clip: true                
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
                            source: thumbnail
                            Layout.preferredHeight: height
                            Layout.preferredWidth: width
                            onClicked: {
                                btnHistory.highlighted = false
                                stickerPackListView.selectedPackId = packId
                                stickerGrid.model = stickers
                            }
                        }
                    }
                    Repeater {
                        id: loadingStickerPackListView
                        model: new Array(7)

                        delegate: Rectangle {
                            width: 24
                            height: 24
                            Layout.preferredHeight: height
                            Layout.preferredWidth: width
                            radius: width / 2
                            color: Style.current.backgroundHover
                        }
                    }
                }
            }
        }
    }
    Connections {
        id: loadedConnection
        target: stickersModule
        onStickerPacksLoaded: {
            root.setStickersReady()
            loadedConnection.enabled = false
        }
    }
}

