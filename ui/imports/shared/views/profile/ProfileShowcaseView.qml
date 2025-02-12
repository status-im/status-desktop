import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import SortFilterProxyModel 0.2

import shared.stores 1.0 as SharedStores
import utils 1.0

import AppLayouts.Wallet.stores 1.0 as WalletStores

Control {
    id: root

    property alias currentTabIndex: stackLayout.currentIndex

    property int maxVisibility: Constants.ShowcaseVisibility.Everyone
    
    property alias communitiesModel: communitiesProxyModel.sourceModel
    property alias accountsModel: accountsProxyModel.sourceModel
    property alias collectiblesModel: collectiblesProxyModel.sourceModel
    property alias assetsModel: assetsProxyModel.sourceModel
    property alias socialLinksModel: socialLinksProxyModel.sourceModel

    property var globalAssetsModel
    property var globalCollectiblesModel

    property WalletStores.RootStore walletStore
    required property SharedStores.NetworksStore networksStore

    required property string mainDisplayName
    required property bool readOnly
    required property bool sendToAccountEnabled

    signal closeRequested()
    signal copyToClipboard(string text)
    signal sendToAccountRequested(string recipientAddress)

    horizontalPadding: readOnly ? 20 : 40 // smaller in settings/preview
    topPadding: Theme.bigPadding

    StatusQUtils.QObject {
        id: d

        property int delegateWidthS: 152
        property int delegateHeightS: 152
        property int delegateWidthM: 202
        property int delegateHeightM: 160

        readonly property string displayNameVerySmallEmoji: StatusQUtils.Emoji.parse(root.mainDisplayName, StatusQUtils.Emoji.size.verySmall)
    }

    component PositionSFPM: SortFilterProxyModel {
        sorters: [
            RoleSorter {
                roleName: "showcasePosition"
            }
        ]
        filters: [
            AnyOf {
                inverted: true
                UndefinedFilter {
                    roleName: "showcaseVisibility"
                }

                ValueFilter {
                    roleName: "showcaseVisibility"
                    value: Constants.ShowcaseVisibility.NoOne
                }
            },
            FastExpressionFilter {
                expression: model.showcaseVisibility >= root.maxVisibility
                expectedRoles: ["showcaseVisibility"]
            }
        ]
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
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: Theme.palette.baseColor2
        }
    }

    contentItem: StackLayout {
        id: stackLayout

        anchors.fill:parent

        ProfileShowcaseCommunitiesView {
            width: parent.width
            height: parent.height

            cellWidth: d.delegateWidthM
            cellHeight: d.delegateHeightM

            mainDisplayName: d.displayNameVerySmallEmoji
            readOnly: root.readOnly
            globalAssetsModel: root.globalAssetsModel
            globalCollectiblesModel: root.globalCollectiblesModel

            communitiesProxyModel: communitiesProxyModel

            onCloseRequested: root.closeRequested()
            onCopyToClipboard: root.copyToClipboard(text)
        }

        ProfileShowcaseAccountsView {
            width: parent.width
            height: parent.height

            mainDisplayName: d.displayNameVerySmallEmoji
            sendToAccountEnabled: root.sendToAccountEnabled
            accountsModel: accountsProxyModel
            networksStore: root.networksStore

            cellWidth: d.delegateWidthM
            cellHeight: d.delegateHeightM

            onCopyToClipboard: root.copyToClipboard(text)
            onSendToAccountRequested: root.sendToAccountRequested(recipientAddress)
        }

        ProfileShowcaseCollectiblesView {
            width: parent.width
            height: parent.height

            cellWidth: d.delegateWidthS
            cellHeight: d.delegateHeightS

            mainDisplayName: d.displayNameVerySmallEmoji
            collectiblesModel: collectiblesProxyModel
            walletStore: root.walletStore
            networksStore: root.networksStore

            onCloseRequested: root.closeRequested()
            onVisitCommunity: {
                Global.openPopup(visitComunityPopupComponent, {communityId: model.communityId, communityName: model.communityName,
                                                communityLogo: model.communityImage, tokenName: model.name,
                                                tokenImage: model.imageUrl, isAssetType: false });
            }
        }

        // ProfileShowcaseAssetsView {
        //     width: parent.width
        //     height: parent.height

        //     mainDisplayName: root.mainDisplayName
        //     assetsModel: assetsProxyModel
        //     sendToAccountEnabled: root.sendToAccountEnabled
        //     delegatesActionsMenu: delegatesActionsMenu

        //     cellHeight: d.delegateHeightS
        //     cellWidth: d.delegateWidthS

        //     onCloseRequested: root.closeRequested()
        //     onVisitCommunity: {
        //        Global.openPopup(visitComunityPopupComponent, {communityId: model.communityId, communityName: model.communityName,
        //                     communityLogo: model.communityImage, tokenName: model.name,
        //                     tokenImage: Constants.tokenIcon(model.symbol), isAssetType: false });
        //      }
        // }

        ProfileShowcaseSocialLinksView {
            width: parent.width
            height: parent.height

            cellWidth: d.delegateWidthS
            cellHeight: d.delegateHeightS

            mainDisplayName: d.displayNameVerySmallEmoji
            socialLinksModel: socialLinksProxyModel

            onCopyToClipboard: root.copyToClipboard(text)
        }
    }

    Component {
        id: visitComunityPopupComponent
        StatusDialog {
            id: visitComunityPopup
            // Community related props:
            property string communityId
            property string communityName
            property string communityLogo

            // Token related props:
            property string tokenName
            property string tokenImage
            property bool isAssetType: false

            width: 521 // by design
            padding: 0
            destroyOnClose: true

            contentItem: StatusScrollView {
                id: scrollView
                padding: Theme.padding
                contentWidth: availableWidth

                ColumnLayout {
                    width: scrollView.availableWidth
                    spacing: Theme.padding

                    StatusBaseText {
                        Layout.fillWidth: true

                        text: visitComunityPopup.isAssetType ?  qsTr("%1 is a community minted asset. Would you like to visit the community that minted it?").arg(visitComunityPopup.tokenName) :
                                                               qsTr("%1 is a community minted collectible. Would you like to visit the community that minted it?").arg(visitComunityPopup.tokenName)
                        textFormat: Text.RichText
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        lineHeight: 1.2
                    }

                    // Navigate to community button
                    StatusListItem {
                        Layout.fillWidth: true
                        Layout.bottomMargin: Theme.halfPadding

                        title: visitComunityPopup.communityName
                        border.color: Theme.palette.baseColor2
                        asset.name: visitComunityPopup.communityLogo
                        asset.isImage: true
                        asset.isLetterIdenticon: !asset.name
                        components: [
                            RowLayout {
                                StatusIcon {
                                    Layout.alignment: Qt.AlignVCenter
                                    icon: "arrow-right"
                                    color: Theme.palette.primaryColor1
                                }

                                StatusBaseText {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.rightMargin: Theme.padding

                                    text: visitComunityPopup.tokenName
                                    font.pixelSize: Theme.additionalTextSize
                                    color: Theme.palette.primaryColor1
                                }
                            }
                        ]

                        onClicked: {
                            Global.switchToCommunity(visitComunityPopup.communityId);
                            visitComunityPopup.close();
                            root.closeRequested();
                        }
                    }
                }
            }

            header: StatusDialogHeader {
                leftComponent: StatusRoundedImage {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.margins: Theme.padding
                    Layout.preferredWidth: 68
                    Layout.preferredHeight: Layout.preferredWidth
                    radius: visitComunityPopup.isAssetType ? width / 2 : 8
                    image.source: visitComunityPopup.tokenImage
                    showLoadingIndicator: false
                    image.fillMode: Image.PreserveAspectCrop
                }
                headline.title: visitComunityPopup.tokenName
                headline.subtitle: qsTr("Minted by %1").arg(visitComunityPopup.communityName)
                actions.closeButton.onClicked: { visitComunityPopup.close(); }
            }

            footer: StatusDialogFooter {
                spacing: Theme.padding
                rightButtons: ObjectModel {
                    StatusFlatButton {
                        text: qsTr("Cancel")
                        onClicked: {
                            visitComunityPopup.close();
                        }
                    }
                }
            }
        }
    }
}
