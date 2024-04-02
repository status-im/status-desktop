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

import SortFilterProxyModel 0.2

import utils 1.0
import shared.controls 1.0 // Timer
import shared.controls.delegates 1.0
import AppLayouts.Communities.controls 1.0

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

    required property string mainDisplayName
    required property bool readOnly
    required property bool sendToAccountEnabled
    property var enabledNetworks

    signal closeRequested()
    signal copyToClipboard(string text)

    horizontalPadding: readOnly ? 20 : 40 // smaller in settings/preview
    topPadding: Style.current.bigPadding

    StatusQUtils.QObject {
        id: d

        property int delegateWidthS: 152
        property int delegateHeightS: 152
        property int delegateWidthM: 202
        property int delegateHeightM: 160

        readonly property string copyLiteral: qsTr("Copy")
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
            visible: ((communitiesView.contentY + accountsView.contentY + collectiblesView.contentY
                      /*+ assetsView.contentY*/ + webView.contentY) > Style.current.xlPadding)
        }
    }

    contentItem: StackLayout {
        id: stackLayout
        // communities
        anchors.fill:parent
        ColumnLayout {
            width: parent.width
            height: parent.height
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                visible: communitiesView.count == 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 has not shared any communities").arg(root.mainDisplayName)
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: (communitiesView.contentY > Style.current.padding) ? 1 : Style.current.padding
                Behavior on Layout.topMargin { NumberAnimation { duration: 50 } }
                clip: true
                StatusGridView {
                    id: communitiesView
                    width: 606
                    height: parent.height
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.halfPadding
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Style.current.halfPadding
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: Style.current.halfPadding
                    clip: false
                    cellWidth: d.delegateWidthM
                    cellHeight: d.delegateHeightM
                    visible: count
                    model: communitiesProxyModel
                    ScrollBar.vertical: StatusScrollBar { }
                    delegate: StatusCommunityCard {
                        id: profileDialogCommunityCard
                        readonly property var permissionsList: model.permissionsModel //TODO: Add permissions model in the community model
                        readonly property bool requirementsMet: !!model.allTokenRequirementsMet ? model.allTokenRequirementsMet : false
                        cardSize: StatusCommunityCard.Size.Small
                        width: GridView.view.cellWidth - Style.current.padding
                        height: GridView.view.cellHeight - Style.current.padding
                        titleFontSize: 15
                        descriptionFontSize: 12
                        communityId: model.id ?? ""
                        loaded: !!model.id
                        asset.source: model.image ?? ""
                        asset.isImage: !!model.image
                        asset.width: 32
                        asset.height: 32
                        name: model.name ?? ""
                        memberCountVisible: false
                        layer.enabled: hovered
                        border.width: hovered ? 0 : 1
                        border.color: Theme.palette.baseColor2
                        descriptionFontColor: Theme.palette.baseColor1
                        description: {
                            switch (model.memberRole)  {
                            case (Constants.memberRole.owner):
                                return qsTr("Owner");
                            case (Constants.memberRole.admin) :
                                return qsTr("Admin");
                            case (Constants.memberRole.tokenMaster):
                                return qsTr("Token Master");
                            default:
                                return qsTr("Member");
                            }
                        }
                        communityColor: model.color ?? ""
                        // Community restrictions
                        bottomRowComponent: model.memberRole ?? -1 ===  Constants.memberRole.tokenMaster ?
                                            communityMembershipComponent :
                                            !!profileDialogCommunityCard.permissionsList && profileDialogCommunityCard.permissionsList.count > 0 ?
                                            permissionsRowComponent : null

                        Component {
                            id: communityMembershipComponent
                            Item {
                                width: 125
                                height: 24
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 20
                                    color: Theme.palette.successColor1
                                    opacity: .1
                                    border.color: Theme.palette.successColor1
                                }
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    StatusIcon {
                                        width: 16
                                        height: 16
                                        color: Theme.palette.successColor1
                                        icon: "tiny/checkmark"
                                    }
                                    StatusBaseText {
                                        font.pixelSize: Theme.tertiaryTextFontSize
                                        color: Theme.palette.successColor1
                                        text: qsTr("You’re there too")
                                    }
                                }
                            }
                        }

                        Component {
                            id: permissionsRowComponent
                            PermissionsRow {
                                hoverEnabled: false
                                assetsModel: root.globalAssetsModel
                                collectiblesModel: root.globalCollectiblesModel
                                model: profileDialogCommunityCard.permissionsList
                                requirementsMet: profileDialogCommunityCard.requirementsMet
                            }
                        }

                        onClicked: {
                            if (root.readOnly)
                                return
                            root.closeRequested()
                            Global.switchToCommunity(model.id)
                            //TODO https://github.com/status-im/status-desktop/issues/13702
                            //on right click add menu
                        }
                    }
                }
            }
        }

        // wallets/accounts
        ColumnLayout {
            width: parent.width
            height: parent.height
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                visible: accountsView.count == 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 has not shared any accounts").arg(root.mainDisplayName)
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: (accountsView.contentY > Style.current.padding) ? 1 : Style.current.padding
                Behavior on Layout.topMargin { NumberAnimation { duration: 50 } }
                clip: true
                StatusGridView {
                    id: accountsView
                    width: 606
                    height: parent.height
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.halfPadding
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Style.current.halfPadding
                    anchors.horizontalCenter: parent.horizontalCenter
                    cellWidth: d.delegateWidthM
                    cellHeight: d.delegateHeightM
                    visible: count
                    clip: false
                    ScrollBar.vertical: StatusScrollBar { }
                    model: accountsProxyModel
                    delegate: InfoCard {
                        implicitWidth: GridView.view.cellWidth - Style.current.padding
                        implicitHeight: GridView.view.cellHeight - Style.current.padding
                        title: model.name
                        subTitle: StatusQUtils.Utils.elideText(model.address, 6, 4).replace("0x", "0×")
                        asset.color: Utils.getColorForId(model.colorId)
                        asset.emoji: model.emoji ?? ""
                        asset.name: asset.emoji || "filled-account"
                        asset.isLetterIdenticon: asset.emoji
                        asset.letterSize: 14
                        asset.bgColor: Theme.palette.primaryColor3
                        asset.isImage: asset.emoji
                        enabledNetworks: root.enabledNetworks
                        rightSideButtons: RowLayout {
                            StatusFlatRoundButton {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                type: StatusFlatRoundButton.Type.Secondary
                                icon.name: "send"
                                icon.color: Theme.palette.baseColor1
                                enabled: root.sendToAccountEnabled
                                onClicked: {
                                    Global.openSendModal(model.address)
                                }
                            }
                            StatusFlatRoundButton {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                type: StatusFlatRoundButton.Type.Secondary
                                icon.name: "more"
                                icon.color: Theme.palette.baseColor1
                                onClicked: {
                                    //TODO https://github.com/status-im/status-desktop/issues/13702
                                    //open menu
                                }
                            }
                        }
                    }
                    //TODO remove when https://github.com/status-im/status-desktop/issues/13702
                    //                delegate: StatusListItem {
                    //                    id: accountDelegate
                    //                    property bool saved: {
                    //                        let savedAddress = root.walletStore.getSavedAddress(model.address)
                    //                        if (savedAddress.name !== "")
                    //                            return true

                    //                        if (!!root.walletStore.lastCreatedSavedAddress) {
                    //                            if (root.walletStore.lastCreatedSavedAddress.address.toLowerCase() === model.address.toLowerCase()) {
                    //                                return !!root.walletStore.lastCreatedSavedAddress.error
                    //                            }
                    //                        }

                    //                        return false
                    //                    }
                    //                    border.width: 1
                    //                    border.color: Theme.palette.baseColor2
                    //                    width: ListView.view.width
                    //                    title: model.name
                    //                    subTitle: StatusQUtils.Utils.elideText(model.address, 6, 4).replace("0x", "0×")
                    //                    asset.color: Utils.getColorForId(model.colorId)
                    //                    asset.emoji: model.emoji ?? ""
                    //                    asset.name: asset.emoji || "filled-account"
                    //                    asset.isLetterIdenticon: asset.emoji
                    //                    asset.letterSize: 14
                    //                    asset.bgColor: Theme.palette.primaryColor3
                    //                    asset.isImage: asset.emoji
                    //                    components: [
                    //                        StatusIcon {
                    //                            anchors.verticalCenter: parent.verticalCenter
                    //                            icon: "show"
                    //                            color: Theme.palette.directColor1
                    //                        },
                    //                        StatusFlatButton {
                    //                            anchors.verticalCenter: parent.verticalCenter
                    //                            size: StatusBaseButton.Size.Small
                    //                            enabled: !accountDelegate.saved
                    //                            text: accountDelegate.saved ? qsTr("Address saved") : qsTr("Save Address")
                    //                            onClicked: {
                    //                                // From here, we should just run add saved address popup
                    //                                Global.openAddEditSavedAddressesPopup({
                    //                                                                          addAddress: true,
                    //                                                                          address: model.address
                    //                                                                      })
                    //                            }
                    //                        },
                    //                        StatusFlatRoundButton {
                    //                            anchors.verticalCenter: parent.verticalCenter
                    //                            type: StatusFlatRoundButton.Type.Secondary
                    //                            icon.name: "send"
                    //                            tooltip.text: qsTr("Send")
                    //                            enabled: root.sendToAccountEnabled
                    //                            onClicked: {
                    //                                Global.openSendModal(model.address)
                    //                            }
                    //                        },
                    //                        StatusFlatRoundButton {
                    //                            anchors.verticalCenter: parent.verticalCenter
                    //                            type: StatusFlatRoundButton.Type.Secondary
                    //                            icon.name: "copy"
                    //                            tooltip.text: d.copyLiteral
                    //                            onClicked: {
                    //                                tooltip.text = qsTr("Copied")
                    //                                root.profileStore.copyToClipboard(model.address)
                    //                                d.timer.setTimeout(function() {
                    //                                    tooltip.text = d.copyLiteral
                    //                                }, 2000);
                    //                            }
                    //                        }
                    //                    ]
                    //                }
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
                text: qsTr("%1 has not shared any collectibles").arg(root.mainDisplayName)
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: (collectiblesView.contentY > Style.current.padding) ? 1 : Style.current.padding
                Behavior on Layout.topMargin { NumberAnimation { duration: 50 } }
                clip: true
                StatusGridView {
                    id: collectiblesView
                    width: 608
                    height: parent.height
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.halfPadding
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Style.current.halfPadding
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: Style.current.halfPadding
                    cellWidth: d.delegateWidthS
                    cellHeight: d.delegateHeightS
                    visible: count
                    clip: false
                    // TODO Issue #11637: Dedicated controller for user's list of collectibles (no watch-only entries)
                    model: collectiblesProxyModel
                    ScrollBar.vertical: StatusScrollBar { }
                    delegate: StatusRoundedImage {
                        width: GridView.view.cellWidth - Style.current.padding
                        height: GridView.view.cellHeight - Style.current.padding
                        border.width: 1
                        border.color: Theme.palette.directColor7
                        color: !!model.backgroundColor ? model.backgroundColor : "transparent"
                        radius: Style.current.radius
                        showLoadingIndicator: true
                        isLoading: image.isLoading || !model.imageUrl
                        image.fillMode: Image.PreserveAspectCrop
                        image.source: model.imageUrl ?? ""

                        Control {
                            width: (amountText.contentWidth + Style.current.padding)
                            height: 24
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.top: parent.top
                            anchors.topMargin: 12
                            //TODO TBD, we need to show the number if the user has more than 1 of each collectible
                            //not sure how to name the role
                            visible: (model.userHas > 1)

                            background: Rectangle {
                                radius: 30
                                color: Theme.palette.indirectColor2
                            }

                            contentItem: StatusBaseText {
                                id: amountText
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: Style.current.asideTextFontSize
                                text: "x"+model.userHas
                            }
                        }

                        Control {
                            width: 24
                            height: 24
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 12
                            visible: !!model.communityImage

                            background: Rectangle {
                                radius: parent.width/2
                                color: Theme.palette.indirectColor2
                            }
                            contentItem: StatusRoundedImage {
                                anchors.fill: parent
                                anchors.margins: 4
                                image.fillMode: Image.PreserveAspectFit
                                image.source: model.communityImage
                            }
                        }
                        HoverHandler {
                            id: hhandler
                            cursorShape: hovered ? Qt.PointingHandCursor : undefined
                        }

                        TapHandler {
                            onSingleTapped: {
                                //TODO https://github.com/status-im/status-desktop/issues/13702
                                Global.openLink(model.permalink)
                            }
                        }
                    }
                }
            }
        }

        // assets/tokens
        // ColumnLayout {
        //     StatusBaseText {
        //         Layout.fillWidth: true
        //         Layout.fillHeight: true
        //         Layout.alignment: Qt.AlignCenter
        //         visible: assetsView.count == 0
        //         horizontalAlignment: Text.AlignHCenter
        //         verticalAlignment: Text.AlignVCenter
        //         color: Theme.palette.directColor1
        //         text: qsTr("%1 has not shared any assets").arg(root.mainDisplayName)
        //     }
        //     Item {
        //         Layout.fillWidth: true
        //         Layout.fillHeight: true
        //         Layout.topMargin: (assetsView.contentY > Style.current.padding) ? 1 : Style.current.padding
        //         Behavior on Layout.topMargin { NumberAnimation { duration: 50 } }
        //         clip: true
        //         StatusGridView {
        //             id: assetsView
        //             width: 608
        //             height: parent.height
        //             anchors.top: parent.top
        //             anchors.topMargin: Style.current.halfPadding
        //             anchors.bottom: parent.bottom
        //             anchors.bottomMargin: Style.current.halfPadding
        //             anchors.horizontalCenter: parent.horizontalCenter
        //             anchors.horizontalCenterOffset: Style.current.halfPadding
        //             cellWidth: d.delegateWidthS
        //             cellHeight: d.delegateHeightS
        //             visible: count
        //             clip: false
        //             model: assetsProxyModel
        //             ScrollBar.vertical: StatusScrollBar { }
        //             delegate: InfoCard {
        //                 width: GridView.view.cellWidth - Style.current.padding
        //                 height: GridView.view.cellHeight - Style.current.padding
        //                 title: model.name
        //                 subTitle: LocaleUtils.currencyAmountToLocaleString(model.enabledNetworkBalance)
        //                 asset.name: Constants.tokenIcon(model.symbol)
        //                 asset.isImage: true
        //                 tagIcon: !!model.communityImage ? model.communityImage : ""
        //                 rightSideButtons: RowLayout {
        //                     StatusFlatRoundButton {
        //                         implicitWidth: 24
        //                         implicitHeight: 24
        //                         type: StatusFlatRoundButton.Type.Secondary
        //                         icon.name: "external"
        //                         icon.width: 16
        //                         icon.height: 16
        //                         icon.color: Theme.palette.baseColor1
        //                         enabled: root.sendToAccountEnabled
        //                         onClicked: {
        //                             //TODO https://github.com/status-im/status-desktop/issues/13702
        //                             //Global.openSendModal(model.address)
        //                             //on right click open menu
        //                         }
        //                     }
        //                 }
        //             }
        //             //TODO remove when https://github.com/status-im/status-desktop/issues/13702
        //             //                delegate: StatusListItem {
        //             //                    readonly property double changePct24hour: model.changePct24hour ?? 0
        //             //                    readonly property string textColor: changePct24hour === 0
        //             //                                                        ? Theme.palette.baseColor1 : changePct24hour < 0
        //             //                                                          ? Theme.palette.dangerColor1 : Theme.palette.successColor1
        //             //                    readonly property string arrow: changePct24hour === 0 ? "" : changePct24hour < 0 ? "↓" : "↑"

        //             //                    width: GridView.view.cellWidth - Style.current.halfPadding
        //             //                    height: GridView.view.cellHeight - Style.current.halfPadding
        //             //                    title: model.name
        //             //                    //subTitle: LocaleUtils.currencyAmountToLocaleString(model.enabledNetworkBalance)
        //             //                    statusListItemTitle.font.weight: Font.Medium
        //             //                    tertiaryTitle: qsTr("%1% today %2")
        //             //                      .arg(LocaleUtils.numberToLocaleString(changePct24hour, changePct24hour === 0 ? 0 : 2)).arg(arrow)
        //             //                    statusListItemTertiaryTitle.color: textColor
        //             //                    statusListItemTertiaryTitle.font.pixelSize: Theme.asideTextFontSize
        //             //                    statusListItemTertiaryTitle.anchors.topMargin: 6
        //             //                    leftPadding: Style.current.halfPadding
        //             //                    rightPadding: Style.current.halfPadding
        //             //                    border.width: 1
        //             //                    border.color: Theme.palette.baseColor2
        //             //                    components: [
        //             //                        Image {
        //             //                            width: 40
        //             //                            height: 40
        //             //                            anchors.verticalCenter: parent.verticalCenter
        //             //                            source: Constants.tokenIcon(model.symbol)
        //             //                        }
        //             //                    ]
        //             //                    onClicked: {
        //             //                        if (root.readOnly)
        //             //                            return
        //             //                        // TODO what to do here?
        //             //                    }
        //             //                }
        //         }
        //     }
        // }

        // social links
        ColumnLayout {
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                visible: webView.count == 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 has not shared any links").arg(root.mainDisplayName)
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: (webView.contentY > Style.current.padding) ? 1 : Style.current.padding
                Behavior on Layout.topMargin { NumberAnimation { duration: 50 } }
                clip: true

                StatusGridView {
                    id: webView
                    width: 608
                    height: parent.height
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.halfPadding
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Style.current.halfPadding
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: Style.current.halfPadding
                    cellWidth: d.delegateWidthS
                    cellHeight: d.delegateHeightS
                    visible: count
                    clip: false
                    model: socialLinksProxyModel
                    ScrollBar.vertical: StatusScrollBar { }
                    delegate: InfoCard {
                        readonly property int linkType: ProfileUtils.linkTextToType(model.text)
                        width: GridView.view.cellWidth - Style.current.padding
                        height: GridView.view.cellHeight - Style.current.padding
                        title: ProfileUtils.linkTypeToText(linkType)
                        asset.bgColor: Style.current.translucentBlue
                        asset.name: ProfileUtils.linkTypeToIcon(linkType)
                        asset.color: ProfileUtils.linkTypeColor(linkType)
                        asset.width: 20
                        asset.height: 20
                        asset.bgWidth: 32
                        asset.bgHeight: 32
                        asset.isImage: false
                        subTitle: ProfileUtils.stripSocialLinkPrefix(model.url, linkType)
                        rightSideButtons: RowLayout {
                            StatusFlatRoundButton {
                                implicitWidth: 24
                                implicitHeight: 24
                                type: StatusFlatRoundButton.Type.Secondary
                                icon.name: "external"
                                icon.width: 16
                                icon.height: 16
                                icon.color: Theme.palette.baseColor1
                                enabled: root.sendToAccountEnabled
                                onClicked: {
                                    //TODO https://github.com/status-im/status-desktop/issues/13702
                                    //on right click open menu
                                }
                            }
                        }
                    }
                }
                Item {
                    width: 279
                    height: 32
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20
                    Rectangle {
                        anchors.fill: parent
                        color: Style.current.background
                        radius: 30
                        border.color: Theme.palette.baseColor2
                    }
                    Row {
                        anchors.centerIn: parent
                        spacing: 4
                        StatusIcon {
                            width: 16
                            height: 16
                            icon: "info"
                            color: Theme.palette.directColor1
                        }

                        StatusBaseText {
                            font.pixelSize: 13
                            text: qsTr("Social handles and links are unverified")
                        }
                    }
                }
            }
        }
    }
}
