import QtQuick
import QtQuick.Controls
import QtQml.Models

import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Core.Utils

import AppLayouts.Wallet.controls

import shared.controls

DoubleFlickableWithFolding {
    id: root

    required property var controller

    readonly property bool dirty: root.controller.dirty
    readonly property bool hasSettings: root.controller.hasSettings

    function saveSettings(update) {
        let jsonSettings = root.controller.serializeSettingsAsJson()
        root.controller.requestSaveSettings(jsonSettings)
        if(update) {
            root.controller.requestLoadSettings();
        }
    }

    function revert() {
        root.controller.revert();
    }

    function clearSettings() {
        root.controller.requestClearSettings()
    }

    clip: true

    ScrollBar.vertical: StatusScrollBar {
        policy: ScrollBar.AsNeeded
        visible: resolveVisibility(policy, root.height, root.contentHeight)
    }

    flickable1: EmptyShapeRectangleFooterListView {
        objectName: "communityTokensListView"

        width: root.width

        model: root.controller.arrangeByCommunity
               ? communityGroupedModel : communityNonGroupedModel

        header: FoldableHeader {
            objectName: "communityHeader"

            width: ListView.view.width
            title: qsTr("Community minted")
            switchText: qsTr("Arrange by community")
            folded: root.flickable1Folded
            checked: root.controller.arrangeByCommunity

            onToggleFolding: root.flip1Folding()
            onToggleSwitch: root.controller.arrangeByCommunity = checked
        }

        placeholderText: qsTr("Your community minted collectibles will appear here")
    }

    flickable2: EmptyShapeRectangleFooterListView {
        objectName: "otherTokensListView"

        width: root.width

        model: root.controller.arrangeByCollection
               ? otherGroupedModel : otherNonGroupedModel

        header: FoldableHeader {
            objectName: "nonCommunityHeader"

            width: ListView.view.width
            title: qsTr("Other")
            switchText: qsTr("Arrange by collection")
            folded: root.flickable2Folded
            checked: root.controller.arrangeByCollection

            onToggleFolding: root.flip2Folding()
            onToggleSwitch: root.controller.arrangeByCollection = checked
        }

        placeholderText: qsTr("Your other collectibles will appear here")
    }

    DelegateModel {
        id: communityNonGroupedModel

        model: root.controller.communityTokensModel

        function moveItem(from, to) {
            model.moveItem(from, to)
        }

        delegate: ManageTokensDelegate {
            isCollectible: true
            controller: root.controller
            dragParent: root
            count: root.controller.communityTokensModel.count
            dragEnabled: count > 1
        }
    }

    DelegateModel {
        id: communityGroupedModel

        model: root.controller.communityTokenGroupsModel

        function moveItem(from, to) {
            model.moveItem(from, to)
        }

        delegate: ManageTokensGroupDelegate {
            isCollectible: true
            controller: root.controller
            dragParent: root
            dragEnabled: root.controller.communityTokenGroupsModel.count > 1
        }
    }

    DelegateModel {
        id: otherNonGroupedModel

        model: root.controller.regularTokensModel

        function moveItem(from, to) {
            model.moveItem(from, to)
        }

        delegate: ManageTokensDelegate {
            isCollectible: true
            controller: root.controller
            dragParent: root
            count: root.controller.regularTokensModel.count
            dragEnabled: count > 1
        }
    }

    DelegateModel {
        id: otherGroupedModel

        model: root.controller.collectionGroupsModel

        function moveItem(from, to) {
            model.moveItem(from, to)
        }

        delegate: ManageTokensGroupDelegate {
            isCollection: true
            controller: root.controller
            dragParent: root
            dragEnabled: root.controller.collectionGroupsModel.count > 1
        }
    }
}
