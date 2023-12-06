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

import AppLayouts.Wallet.controls 1.0

Control {
    id: root

    required property var baseModel

    readonly property bool dirty: d.controller.dirty
    readonly property bool hasSettings: d.controller.hasSettings

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

            delegate: ManageTokensDelegate {
                controller: d.controller
                dragParent: root
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
                text: qsTr("Community")
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
            text: qsTr("Hidden")
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

            delegate: ManageTokensDelegate {
                controller: d.controller
                dragParent: root
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

            delegate: ManageTokensDelegate {
                controller: d.controller
                dragParent: root
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

            delegate: ManageTokensGroupDelegate {
                controller: d.controller
                dragParent: root
                dragEnabled: d.controller.communityTokenGroupsModel.count > 1
                communityGroupsExpanded: d.communityGroupsExpanded
            }
        }
    }
}
