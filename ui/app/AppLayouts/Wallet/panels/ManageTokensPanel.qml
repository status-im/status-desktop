import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Models 0.1

import utils 1.0
import shared.controls 1.0

import AppLayouts.Wallet.controls 1.0

Control {
    id: root

    required property var baseModel

    readonly property bool dirty: d.controller.dirty

    background: null

    function saveSettings() {
        d.controller.saveSettings();
    }

    function revert() {
        d.controller.revert();
    }

    function clearSettings() {
        d.controller.clearSettings();
    }

    QtObject {
        id: d

        property bool communityGroupsExpanded: true

        readonly property var controller: ManageTokensController {
            sourceModel: root.baseModel
            arrangeByCommunity: switchArrangeByCommunity.checked
            settingsKey: "WalletAssets"
        }
    }

    component CommunityTag: InformationTag {
        tagPrimaryLabel.font.weight: Font.Medium
        customBackground: Component {
            Rectangle {
                color: Theme.palette.baseColor4
                radius: 20
            }
        }
    }

    component LocalTokenDelegate: DropArea {
        id: delegateRoot

        property int visualIndex: index
        property alias dragEnabled: delegate.dragEnabled
        property alias bgColor: delegate.bgColor
        property alias topInset: delegate.topInset
        property alias bottomInset: delegate.bottomInset
        property bool isGrouped
        property bool isHidden
        property int count

        ListView.onRemove: SequentialAnimation {
            PropertyAction { target: delegateRoot; property: "ListView.delayRemove"; value: true }
            NumberAnimation { target: delegateRoot; property: "scale"; to: 0; easing.type: Easing.InOutQuad }
            PropertyAction { target: delegateRoot; property: "ListView.delayRemove"; value: false }
        }

        width: ListView.view.width
        height: visible ? delegate.height : 0

        onEntered: function(drag) {
            var from = drag.source.visualIndex
            var to = delegate.visualIndex
            if (to === from)
                return
            //console.warn("!!! DROP from/to", from, to)
            ListView.view.model.moveItem(from, to)
            drag.accept()
        }

        StatusDraggableListItem {
            id: delegate

            visualIndex: index
            dragParent: root
            Drag.keys: delegateRoot.keys
            draggable: true

            width: delegateRoot.width
            title: model.name// + " (%1 -> %2)".arg(index).arg(model.customSortOrderNo)
            secondaryTitle: hovered || menuBtn.menuVisible ? "%1 <b>·</b> %2".arg(LocaleUtils.currencyAmountToLocaleString(model.enabledNetworkBalance))
                                                             .arg(LocaleUtils.currencyAmountToLocaleString(model.enabledNetworkCurrencyBalance))
                                                           : LocaleUtils.currencyAmountToLocaleString(model.enabledNetworkBalance)
            hasImage: true
            icon.source: model.imageUrl || Constants.tokenIcon(model.symbol)
            icon.width: 32
            icon.height: 32
            spacing: 12

            actions: [
                CommunityTag {
                    tagPrimaryLabel.text: model.communityName
                    visible: !!model.communityId && !delegateRoot.isGrouped
                    image.source: model.communityImage
                },
                ManageTokenMenuButton {
                    id: menuBtn
                    currentIndex: visualIndex
                    count: delegateRoot.count
                    inHidden: delegateRoot.isHidden
                    groupId: model.communityId
                    isCommunityAsset: !!model.communityId
                    onMoveRequested: (from, to) => isCommunityAsset ? d.controller.communityTokensModel.moveItem(from, to)
                                                                    : d.controller.regularTokensModel.moveItem(from, to)
                    onShowHideRequested: (index, flag) => isCommunityAsset ? d.controller.showHideCommunityToken(index, flag)
                                                                           : d.controller.showHideRegularToken(index, flag)
                    onShowHideGroupRequested: (groupId, flag) => d.controller.showHideGroup(groupId, flag)
                }
            ]
        }
    }

    component LocalTokenGroupDelegate: DropArea {
        id: communityDelegateRoot

        property int visualIndex: index
        readonly property string communityId: model.communityId
        readonly property int childCount: model.enabledNetworkBalance // NB using "balance" as "count" in m_communityTokenGroupsModel

        ListView.onRemove: SequentialAnimation {
            PropertyAction { target: communityDelegateRoot; property: "ListView.delayRemove"; value: true }
            NumberAnimation { target: communityDelegateRoot; property: "scale"; to: 0; easing.type: Easing.InOutQuad }
            PropertyAction { target: communityDelegateRoot; property: "ListView.delayRemove"; value: false }
        }

        keys: ["x-status-draggable-community-group-item"]
        visible: childCount
        width: ListView.view.width
        height: visible ? groupedCommunityTokenDelegate.implicitHeight : 0

        onEntered: function(drag) {
            var from = drag.source.visualIndex
            var to = groupedCommunityTokenDelegate.visualIndex
            if (to === from)
                return
            //console.warn("!!! DROP GROUP from/to", from, to)
            ListView.view.model.moveItem(from, to)
            drag.accept()
        }

        StatusDraggableListItem {
            id: groupedCommunityTokenDelegate
            width: parent.width
            height: dragActive ? implicitHeight : parent.height
            leftPadding: Style.current.halfPadding
            rightPadding: Style.current.halfPadding
            bottomPadding: Style.current.halfPadding
            topPadding: 22
            draggable: true
            spacing: 12
            bgColor: Theme.palette.baseColor4

            visualIndex: index
            dragParent: root
            Drag.keys: communityDelegateRoot.keys

            contentItem: ColumnLayout {
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.bottomMargin: 14
                    spacing: groupedCommunityTokenDelegate.spacing

                    StatusIcon {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        icon: "justify"
                        color: Theme.palette.baseColor1
                    }

                    StatusRoundedImage {
                        radius: groupedCommunityTokenDelegate.bgRadius
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        image.source: model.communityImage
                        showLoadingIndicator: true
                        image.fillMode: Image.PreserveAspectCrop
                    }

                    StatusBaseText {
                        text: model.communityName// + "(%1 -> %2)".arg(index).arg(model.customSortOrderNo)
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        font.weight: Font.Medium
                    }

                    StatusBaseText {
                        Layout.leftMargin: -parent.spacing/2
                        text: "<b>·</b> %1".arg(qsTr("%n asset(s)", "", communityDelegateRoot.childCount))
                        elide: Text.ElideRight
                        color: Theme.palette.baseColor1
                        maximumLineCount: 1
                        visible: !d.communityGroupsExpanded
                    }

                    Item { Layout.fillWidth: true }

                    ManageTokenMenuButton {
                        currentIndex: visualIndex
                        count: d.controller.communityTokenGroupsModel.count
                        isGroup: true
                        groupId: model.communityId
                        onMoveRequested: (from, to) => d.controller.communityTokenGroupsModel.moveItem(from, to)
                        onShowHideGroupRequested: (groupId, flag) => d.controller.showHideGroup(groupId, flag)
                    }
                }

                StatusListView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    model: d.controller.communityTokensModel
                    interactive: false
                    visible: d.communityGroupsExpanded

                    displaced: Transition {
                        NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
                    }

                    delegate: LocalTokenDelegate {
                        isGrouped: true
                        count: communityDelegateRoot.childCount
                        dragEnabled: count > 1
                        keys: ["x-status-draggable-community-token-item-%1".arg(model.communityId)]
                        bgColor: Theme.palette.indirectColor4
                        topInset: 2 // tighter "spacing"
                        bottomInset: 2
                        visible: communityDelegateRoot.communityId === model.communityId
                    }
                }
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: Style.current.padding

        StatusListView {
            Layout.fillWidth: true
            model: d.controller.regularTokensModel
            implicitHeight: contentHeight
            interactive: false

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: LocalTokenDelegate {
                count: d.controller.regularTokensModel.count
                dragEnabled: count > 1
                keys: ["x-status-draggable-token-item"]
            }
        }

        RowLayout {
            id: communityTokensHeader
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding
            visible: d.controller.communityTokensModel.count
            StatusBaseText {
                color: Theme.palette.baseColor1
                text: qsTr("Community")// + " -> %1".arg(switchArrangeByCommunity.checked ? d.controller.communityTokenGroupsModel.count : d.controller.communityTokensModel.count)
            }
            Item { Layout.fillWidth: true }
            StatusSwitch {
                LayoutMirroring.enabled: true
                LayoutMirroring.childrenInherit: true
                id: switchArrangeByCommunity
                textColor: Theme.palette.baseColor1
                text: qsTr("Arrange by community")
            }
        }

        StatusModalDivider {
            Layout.fillWidth: true
            Layout.topMargin: -Style.current.halfPadding
            visible: communityTokensHeader.visible && switchArrangeByCommunity.checked
        }

        StatusLinkText {
            Layout.alignment: Qt.AlignTrailing
            visible: communityTokensHeader.visible && switchArrangeByCommunity.checked
            text: d.communityGroupsExpanded ? qsTr("Collapse all") : qsTr("Expand all")
            normalColor: linkColor
            font.weight: Font.Normal
            onClicked: d.communityGroupsExpanded = !d.communityGroupsExpanded
        }

        Loader {
            Layout.fillWidth: true
            active: d.controller.communityTokensModel.count
            visible: active
            sourceComponent: switchArrangeByCommunity.checked ? cmpCommunityTokenGroups : cmpCommunityTokens
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding
            color: Theme.palette.baseColor1
            text: qsTr("Hidden")// + " -> %1".arg(d.controller.hiddenTokensModel.count)
            visible: d.controller.hiddenTokensModel.count
        }

        StatusListView {
            Layout.fillWidth: true
            model: d.controller.hiddenTokensModel
            implicitHeight: contentHeight
            interactive: false

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: LocalTokenDelegate {
                dragEnabled: false
                keys: ["x-status-draggable-none"]
                isHidden: true
            }
        }
    }

    Component {
        id: cmpCommunityTokens
        StatusListView {
            model: d.controller.communityTokensModel
            implicitHeight: contentHeight
            interactive: false

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: LocalTokenDelegate {
                count: d.controller.communityTokensModel.count
                dragEnabled: count > 1
                keys: ["x-status-draggable-community-token-item"]
            }
        }
    }

    Component {
        id: cmpCommunityTokenGroups
        StatusListView {
            model: d.controller.communityTokenGroupsModel
            implicitHeight: contentHeight
            interactive: false
            spacing: Style.current.halfPadding

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: LocalTokenGroupDelegate {}
        }
    }
}
