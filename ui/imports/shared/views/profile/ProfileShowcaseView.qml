import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0
import shared.controls 1.0 // Timer

import SortFilterProxyModel 0.2

Control {
    id: root

    property alias currentTabIndex: stackLayout.currentIndex
    
    property alias communitiesModel: communitiesProxyModel.sourceModel
    property alias accountsModel: accountsProxyModel.sourceModel
    property alias collectiblesModel: collectiblesProxyModel.sourceModel
    property alias assetsModel: assetsProxyModel.sourceModel
    property alias socialLinksModel: socialLinksProxyModel.sourceModel

    required property string mainDisplayName
    required property bool readOnly
    required property bool sendToAccountEnabled
    
    signal closeRequested()
    signal copyToClipboard(string text)

    horizontalPadding: readOnly ? 20 : 40 // smaller in settings/preview
    topPadding: Style.current.bigPadding

    StatusQUtils.QObject {
        id: d

        readonly property string copyLiteral: qsTr("Copy")
    }

    component PositionSFPM: SortFilterProxyModel {
        sorters: [
            RoleSorter {
                roleName: "showcasePosition"
            }
        ]
        filters: AnyOf {
            inverted: true
            UndefinedFilter {
                roleName: "showcaseVisibility"
            }

            ValueFilter {
                roleName: "showcaseVisibility"
                value: Constants.ShowcaseVisibility.NoOne
            }
        }
    } 

    PositionSFPM {
        id: communitiesProxyModel
    }

    PositionSFPM {
        id: accountsProxyModel
    }

    PositionSFPM {
        id: collectiblesProxyModel
    }

    PositionSFPM {
        id: assetsProxyModel
    }

    PositionSFPM {
        id: socialLinksProxyModel
    }

    background: StatusDialogBackground {
        color: Theme.palette.baseColor4

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: parent.radius
            color: parent.color
        }
    }

    contentItem: StackLayout {
        id: stackLayout

        // communities
        ColumnLayout {
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                visible: communitiesView.count == 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 hasn't joined any communities yet").arg(root.mainDisplayName)
            }

            StatusGridView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: communitiesView
                model: communitiesProxyModel
                rightMargin: Style.current.halfPadding
                cellWidth: (width-rightMargin)/2
                cellHeight: cellWidth/2
                visible: count
                ScrollBar.vertical: StatusScrollBar { }
                delegate: StatusListItem { // TODO custom delegate
                    width: GridView.view.cellWidth - Style.current.smallPadding
                    height: GridView.view.cellHeight - Style.current.smallPadding
                    title: model.name ?? ""
                    statusListItemTitle.font.pixelSize: 17
                    statusListItemTitle.font.bold: true
                    subTitle: model.description ?? ""
                    tertiaryTitle: qsTr("%n member(s)", "", model.membersCount ?? 0)
                    asset.name: model.image ?? model.name ?? ""
                    asset.isImage: asset.name.startsWith(Constants.dataImagePrefix)
                    asset.isLetterIdenticon: !model.image
                    asset.color: model.color ?? ""
                    asset.width: 40
                    asset.height: 40
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    loading: !model.id
                    components: [
                        StatusIcon {
                            visible: !!model.memberRole &&
                                     model.memberRole === Constants.memberRole.owner ||
                                     model.memberRole === Constants.memberRole.admin ||
                                     model.memberRole === Constants.memberRole.tokenMaster
                            anchors.verticalCenter: parent.verticalCenter
                            icon: "crown"
                            color: Theme.palette.directColor1
                        }
                    ]
                    onClicked: {
                        if (root.readOnly || loading)
                            return
                        root.closeRequested()
                        Global.switchToCommunity(model.id)
                    }
                }
            }
        }

        // wallets/accounts
        ColumnLayout {
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                visible: accountsView.count == 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 doesn't have any wallet accounts yet").arg(root.mainDisplayName)
            }

            StatusListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: accountsView
                model: accountsProxyModel
                spacing: Style.current.halfPadding
                visible: count
                delegate: StatusListItem {
                    id: accountDelegate

                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    width: ListView.view.width
                    title: model.name
                    subTitle: StatusQUtils.Utils.elideText(model.address, 6, 4).replace("0x", "0×")
                    asset.color: Utils.getColorForId(model.colorId)
                    asset.emoji: model.emoji ?? ""
                    asset.name: asset.emoji || "filled-account"
                    asset.isLetterIdenticon: asset.emoji
                    asset.letterSize: 14
                    asset.bgColor: Theme.palette.primaryColor3
                    asset.isImage: asset.emoji
                    components: [
                        StatusIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            icon: "show"
                            color: Theme.palette.directColor1
                        },
                        StatusFlatButton {
                            anchors.verticalCenter: parent.verticalCenter
                            size: StatusBaseButton.Size.Small
                            enabled: !model.saved
                            text: model.saved ? qsTr("Address saved") : qsTr("Save Address")
                            onClicked: {
                                // From here, we should just run add saved address popup
                                Global.openAddEditSavedAddressesPopup({
                                                                          addAddress: true,
                                                                          address: model.address
                                                                      })
                            }
                        },
                        StatusFlatRoundButton {
                            anchors.verticalCenter: parent.verticalCenter
                            type: StatusFlatRoundButton.Type.Secondary
                            icon.name: "send"
                            tooltip.text: qsTr("Send")
                            enabled: root.sendToAccountEnabled
                            onClicked: {
                                Global.openSendModal(model.address)
                            }
                        },
                        StatusFlatRoundButton {
                            anchors.verticalCenter: parent.verticalCenter
                            type: StatusFlatRoundButton.Type.Secondary
                            icon.name: "copy"
                            tooltip.text: d.copyLiteral
                            onClicked: {
                                tooltip.text = qsTr("Copied")
                                root.copyToClipboard(model.address)
                                Backpressure.setTimeout(this, 2000, () => tooltip.text = d.copyLiteral)
                            }
                        }
                    ]
                }
            }
        }

        // collectibles/NFTs
        ColumnLayout {
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                visible: collectiblesView.count == 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 doesn't have any collectibles/NFTs yet").arg(root.mainDisplayName)
            }

            StatusGridView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: collectiblesView
                model: collectiblesProxyModel
                rightMargin: Style.current.halfPadding
                cellWidth: (width-rightMargin)/4
                cellHeight: cellWidth
                visible: count
                ScrollBar.vertical: StatusScrollBar { }
                delegate: StatusRoundedImage {
                    width: GridView.view.cellWidth - Style.current.smallPadding
                    height: GridView.view.cellHeight - Style.current.smallPadding
                    border.width: 1
                    border.color: Theme.palette.directColor7
                    color: !!model.backgroundColor ? model.backgroundColor : "transparent"
                    radius: Style.current.radius
                    showLoadingIndicator: true
                    isLoading: image.isLoading || !model.imageUrl
                    image.fillMode: Image.PreserveAspectCrop
                    image.source: model.imageUrl ?? ""

                    RowLayout {
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.halfPadding
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Style.current.halfPadding
                        anchors.right: parent.right
                        anchors.rightMargin: Style.current.halfPadding

                        Control {
                            Layout.maximumWidth: parent.width
                            horizontalPadding: Style.current.halfPadding
                            verticalPadding: Style.current.halfPadding/2
                            visible: !!model.id

                            background: Rectangle {
                                radius: Style.current.halfPadding/2
                                color: Theme.palette.indirectColor2
                            }
                            contentItem: StatusBaseText {
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                maximumLineCount: 1
                                elide: Text.ElideRight
                                text: `#${model.id}`
                            }
                        }
                    }

                    StatusToolTip {
                        visible: hhandler.hovered && (!!model.name || !!model.collectionName)
                        text: {
                            const name = model.name
                            const descr = model.collectionName
                            const sep = !!name && !!descr ? "<br>" : ""
                            return `<b>${name}</b>${sep}${descr}`
                        }
                    }

                    HoverHandler {
                        id: hhandler
                        cursorShape: hovered ? Qt.PointingHandCursor : undefined
                    }

                    TapHandler {
                        onSingleTapped: {
                            Global.openLink(model.permalink)
                        }
                    }
                }
            }
        }

        // assets/tokens
        ColumnLayout {
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                visible: assetsView.count == 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 doesn't have any assets/tokens yet").arg(root.mainDisplayName)
            }

            StatusGridView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: assetsView
                model: assetsProxyModel
                rightMargin: Style.current.halfPadding
                cellWidth: (width-rightMargin)/3
                cellHeight: cellWidth/2.5
                visible: count
                ScrollBar.vertical: StatusScrollBar { }
                delegate: StatusListItem {
                    readonly property double changePct24hour: model.changePct24hour ?? 0
                    readonly property string textColor: changePct24hour === 0
                                                        ? Theme.palette.baseColor1 : changePct24hour < 0
                                                          ? Theme.palette.dangerColor1 : Theme.palette.successColor1
                    readonly property string arrow: changePct24hour === 0 ? "" : changePct24hour < 0 ? "↓" : "↑"

                    width: GridView.view.cellWidth - Style.current.halfPadding
                    height: GridView.view.cellHeight - Style.current.halfPadding
                    title: model.name
                    //subTitle: LocaleUtils.currencyAmountToLocaleString(model.enabledNetworkBalance)
                    statusListItemTitle.font.weight: Font.Medium
                    tertiaryTitle: qsTr("%1% today %2")
                      .arg(LocaleUtils.numberToLocaleString(changePct24hour, changePct24hour === 0 ? 0 : 2)).arg(arrow)
                    statusListItemTertiaryTitle.color: textColor
                    statusListItemTertiaryTitle.font.pixelSize: Theme.asideTextFontSize
                    statusListItemTertiaryTitle.anchors.topMargin: 6
                    leftPadding: Style.current.halfPadding
                    rightPadding: Style.current.halfPadding
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    components: [
                        Image {
                            width: 40
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter
                            source: Constants.tokenIcon(model.symbol)
                        }
                    ]
                    onClicked: {
                        if (root.readOnly)
                            return
                        // TODO what to do here?
                    }
                }
            }
        }
    }
}
