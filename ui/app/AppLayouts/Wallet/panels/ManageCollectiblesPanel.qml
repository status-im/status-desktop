import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet.controls 1.0

import "internals"

DoubleFlickableWithFolding {
    id: root

    required property var controller

    readonly property bool dirty: root.controller.dirty
    readonly property bool hasSettings: root.controller.hasSettings

    function saveSettings() {
        root.controller.saveSettings();
    }

    function revert() {
        root.controller.revert();
    }

    function clearSettings() {
        root.controller.clearSettings();
    }

    clip: true

    ScrollBar.vertical: StatusScrollBar {
        id: scrollbar
        policy: ScrollBar.AsNeeded
        visible: resolveVisibility(policy, root.height, root.contentHeight)
    }

    flickable1: ManageTokensListViewBase {
        objectName: "communityTokensListView"

        width: (root.width-scrollbar.width)

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

    flickable2: ManageTokensListViewBase {
        objectName: "otherTokensListView"

        width: (root.width-scrollbar.width)

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
