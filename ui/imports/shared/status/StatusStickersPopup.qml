import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import utils 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
//TODO improve this!
import AppLayouts.Chat.stores 1.0

Popup {
    id: root

    property var store

    signal stickerSelected(string hashId, string packId, string url)

    QtObject {
        id: d

        // FIXME: move me to store
        readonly property int installedPacksCount: root.store.stickersModuleInst.numInstalledStickerPacks
        readonly property var recentStickers: root.store.stickersModuleInst.recent
        readonly property var stickerPackList: store.stickersModuleInst.stickerPacks
        readonly property bool stickerPacksLoaded: store.stickersModuleInst.packsLoaded
        readonly property bool stickerPacksLoadFailed: store.stickersModuleInst.packsLoadFailed
        readonly property bool stickerPacksLoading: !stickerPacksLoaded && !stickerPacksLoadFailed

        function loadStickers() {
            store.stickersModuleInst.loadStickers()
        }

        function getRecentStickers() {
            store.stickersModuleInst.getRecentStickers()
        }

        function getInstalledStickerPacks() {
            store.stickersModuleInst.getInstalledStickerPacks()
        }

        readonly property bool online: root.store.networkConnectionStore.isOnline
        onOnlineChanged: {
            if (online)
                d.loadStickers()
        }
    }

    enabled: !!d.recentStickers && !!d.stickerPackList
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

    onAboutToShow: {
        d.getInstalledStickerPacks()
        if (!stickerGrid.packId) {
            d.getRecentStickers()
        }
    }

    onClosed: {
        stickerMarket.visible = false
        footerContent.visible = true
        stickersContainer.visible = true
    }

    padding: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StatusStickerMarket {
            id: stickerMarket
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true
            store: root.store
            stickerPacks: d.stickerPackList
            packId: stickerPackListView.selectedPackId
            marketVisible: d.stickerPacksLoaded && d.online
            onInstallClicked: {
                //starts async task
                stickersModule.install(packId)
            }
            onUninstallClicked: {
                stickersModule.uninstall(packId)
                stickerGrid.model = d.recentStickers
                btnHistory.clicked(null)
            }
            onBackClicked: {
                stickerMarket.visible = false
                footerContent.visible = true
                stickersContainer.visible = true
            }

            Connections {
                target: root.store.stickersModuleInst
                function onStickerPackInstalled(packId) {
                    const idx = stickersModule.stickerPacks.findIndexById(packId, false);
                    if (idx === -1) {
                        return
                    }
                    stickersModule.stickerPacks.findStickersById(packId)
                    stickerGrid.model = stickersModule.stickerPacks.getFoundStickers()
                    stickerPackListView.itemAt(idx).clicked()
                }
            }

            Loader {
                id: marketLoader
                anchors.centerIn: parent
                active: d.stickerPacksLoading
                sourceComponent: loadingImageComponent
            }

            ColumnLayout {
                id: failedToLoadStickersInfo

                anchors.centerIn: parent
                visible: d.stickerPacksLoadFailed || !d.online

                StatusBaseText {
                    text: qsTr("Failed to load stickers")
                    color: Theme.palette.dangerColor1
                }

                StatusButton {
                    objectName: "stickersPopupRetryButton"
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Try again")
                    enabled: d.online

                    onClicked: d.loadStickers()
                }
            }
        }

        Item {
            id: stickersContainer
            Layout.fillWidth: true
            Layout.leftMargin: 4
            Layout.topMargin: 4
            Layout.bottomMargin: 0
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.preferredHeight: 400 - 4

            Item {
                id: noStickerPacks
                anchors.fill: parent
                visible: d.installedPacksCount == 0 && stickersModule.recent.rowCount() === 0

                Image {
                    id: imgNoStickers
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
                        anchors.fill: parent
                        font.pixelSize: 15
                        text: d.installedPacksCount === 0 || !d.online ? qsTr("You don't have any stickers yet")
                                                                       : qsTr("Recently used stickers will appear here")
                        lineHeight: 22
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                StatusButton {
                    objectName: "stickersPopupGetStickersButton"
                    visible: d.installedPacksCount === 0
                    text: qsTr("Get Stickers")
                    enabled: d.online
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
                objectName: "statusStickerPopupStickerGrid"
                anchors.fill: parent
                model: d.recentStickers
                packId: stickerPackListView.selectedPackId
                onStickerClicked: {
                    root.stickerSelected(hash, packId, url)
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
                active: d.stickerPacksLoading
                sourceComponent: loadingImageComponent
                anchors.centerIn: parent
            }
        }

        RowLayout {
            id: footerContent
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.rightMargin: Style.current.padding / 2
            Layout.leftMargin: Style.current.padding / 2
            spacing: Style.current.padding / 2

            StatusRoundButton {
                id: btnAddStickerPack
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                icon.name: "add"
                type: StatusFlatRoundButton.Type.Secondary
                loading: d.stickerPacksLoading
                onClicked: {
                    stickersContainer.visible = false
                    stickerMarket.visible = true
                    footerContent.visible = false
                }
            }

            StatusTabBarIconButton {
                id: btnHistory
                icon.name: "time"
                highlighted: true
                onClicked: {
                    highlighted = true
                    stickerPackListView.selectedPackId = ""
                    d.getRecentStickers()
                    stickerGrid.model = d.recentStickers
                }
            }

            StatusScrollView {
                id: scrollView

                Layout.fillWidth: true
                Layout.fillHeight: true
                padding: 0
                contentHeight: availableHeight
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                RowLayout {
                    height: scrollView.availableHeight
                    spacing: footerContent.spacing

                    Repeater {
                        id: stickerPackListView
                        property string selectedPackId
                        model: d.stickerPackList
                        visible: d.stickerPacksLoaded

                        delegate: StatusStickerPackIconWithIndicator {
                            id: packIconWithIndicator
                            visible: installed
                            Layout.alignment: Qt.AlignVCenter
                            selected: stickerPackListView.selectedPackId === packId
                            source: thumbnail
                            onClicked: {
                                btnHistory.highlighted = false
                                stickerPackListView.selectedPackId = packId
                                stickerGrid.model = stickers
                            }
                        }
                    }
                    Repeater {
                        id: loadingStickerPackListView
                        model: d.stickerPacksLoading ? 7 : 0

                        delegate: Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: width / 2
                            color: Style.current.backgroundHover
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}

