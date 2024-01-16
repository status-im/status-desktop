import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
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

    required property var controller

    readonly property bool dirty: root.controller.dirty
    readonly property bool hasSettings: root.controller.hasSettings

    background: null

    function saveSettings() {
        root.controller.saveSettings();
    }

    function revert() {
        root.controller.revert();
    }

    function clearSettings() {
        root.controller.clearSettings();
    }

    QtObject {
        id: d

        //property bool collectionGroupsExpanded: true
        property bool communityGroupsExpanded: true
    }

    Binding {
        target: controller
        property: "arrangeByCommunity"
        value: switchArrangeByCommunity.checked
    }

    contentItem: ColumnLayout {
        spacing: Style.current.padding

        ShapeRectangle {
            Layout.fillWidth: true
            Layout.margins: 2
            visible: !root.controller.regularTokensModel.count
            text: qsTr("You’ll be able to manage the display of your collectibles here")
        }

// TODO https://github.com/status-im/status-desktop/issues/12703
//        StatusSwitch {
//            Layout.alignment: Qt.AlignTrailing
//            LayoutMirroring.enabled: true
//            LayoutMirroring.childrenInherit: true
//            id: switchArrangeByCollection
//            textColor: Theme.palette.baseColor1
//            text: qsTr("Arrange by collection")
//            visible: root.controller.regularTokensModel.count
//        }

//        StatusModalDivider {
//            Layout.fillWidth: true
//            Layout.topMargin: -Style.current.halfPadding
//            visible: switchArrangeByCollection.visible && switchArrangeByCollection.checked
//        }

//        StatusLinkText {
//            Layout.alignment: Qt.AlignTrailing
//            visible: switchArrangeByCollection.visible && switchArrangeByCollection.checked
//            text: d.collectionGroupsExpanded ? qsTr("Collapse all") : qsTr("Expand all")
//            normalColor: linkColor
//            font.weight: Font.Normal
//            onClicked: d.collectionGroupsExpanded = !d.collectionGroupsExpanded
//        }

        StatusListView {
            objectName: "lvRegularTokens"
            Layout.fillWidth: true
            model: root.controller.regularTokensModel
            implicitHeight: contentHeight
            interactive: false

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: ManageTokensDelegate {
                isCollectible: true
                controller: root.controller
                dragParent: root
                count: root.controller.regularTokensModel.count
                dragEnabled: count > 1
                keys: ["x-status-draggable-token-item"]
            }
        }

        RowLayout {
            id: communityTokensHeader
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding
            visible: root.controller.communityTokensModel.count
            StatusBaseText {
                color: Theme.palette.baseColor1
                text: qsTr("Community")
            }
            Item { Layout.fillWidth: true }
            StatusSwitch {
                objectName: "switchArrangeByCommunity"
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
            objectName: "switchCollapseCommunityGroups"
            Layout.alignment: Qt.AlignTrailing
            visible: communityTokensHeader.visible && switchArrangeByCommunity.checked
            text: d.communityGroupsExpanded ? qsTr("Collapse all") : qsTr("Expand all")
            normalColor: linkColor
            font.weight: Font.Normal
            onClicked: d.communityGroupsExpanded = !d.communityGroupsExpanded
        }

        Loader {
            objectName: "loaderCommunityTokens"
            Layout.fillWidth: true
            active: root.controller.communityTokensModel.count
            visible: active
            sourceComponent: switchArrangeByCommunity.checked ? cmpCommunityTokenGroups : cmpCommunityTokens
        }
    }

    Component {
        id: cmpCommunityTokens
        StatusListView {
            objectName: "lvCommunityTokens"
            model: root.controller.communityTokensModel
            implicitHeight: contentHeight
            interactive: false

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: ManageTokensDelegate {
                isCollectible: true
                controller: root.controller
                dragParent: root
                count: root.controller.communityTokensModel.count
                dragEnabled: count > 1
                keys: ["x-status-draggable-community-token-item"]
            }
        }
    }

    Component {
        id: cmpCommunityTokenGroups
        StatusListView {
            objectName: "lvCommunityTokenGroups"
            model: root.controller.communityTokenGroupsModel
            implicitHeight: contentHeight
            interactive: false
            spacing: Style.current.halfPadding

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: ManageTokensGroupDelegate {
                isCollectible: true
                controller: root.controller
                dragParent: root
                dragEnabled: root.controller.communityTokenGroupsModel.count > 1
                communityGroupsExpanded: d.communityGroupsExpanded
            }
        }
    }
}
