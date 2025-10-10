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

    property var getCurrencyAmount: function (balance, key) {}
    property var getCurrentCurrencyAmount: function(balance) {}

    function saveSettings(update) {
        let jsonSettings = root.controller.serializeSettingsAsJson()
        root.controller.requestSaveSettings(jsonSettings);
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

    QtObject {
        id: d

        readonly property int sectionHeight: 64
    }

    ScrollBar.vertical: StatusScrollBar {
        policy: ScrollBar.AsNeeded
        visible: resolveVisibility(policy, root.height, root.contentHeight)
    }

    flickable1: EmptyShapeRectangleFooterListView {
        model: root.controller.regularTokensModel
        width: root.width

        header: FoldableHeader {
            width: ListView.view.width
            title: qsTr("Assets")
            folded: root.flickable1Folded

            onToggleFolding: root.flip1Folding()
        }

        delegate: ManageTokensDelegate {
            controller: root.controller
            dragParent: root
            count: root.controller.regularTokensModel.count
            dragEnabled: count > 1
            getCurrencyAmount: function (balance, key) {
                return root.getCurrencyAmount(balance, key)
            }
            getCurrentCurrencyAmount: function (balance) {
                return root.getCurrentCurrencyAmount(balance)
            }
        }

        placeholderText: qsTr("Your assets will appear here")
    }

    flickable2: EmptyShapeRectangleFooterListView {
        width: root.width

        model: root.controller.arrangeByCommunity ? communityGroupedModel
                                                  : communityNonGroupedModel

        header: FoldableHeader {
            width: ListView.view.width
            title: qsTr("Community minted")
            switchText: qsTr("Arrange by community")
            folded: root.flickable2Folded
            checked: root.controller.arrangeByCommunity

            onToggleFolding: root.flip2Folding()
            onToggleSwitch: root.controller.arrangeByCommunity = checked
        }

        placeholderText: qsTr("Your community minted assets will appear here")
    }

    DelegateModel {
        id: communityNonGroupedModel

        model: root.controller.communityTokensModel

        function moveItem(from, to) {
            model.moveItem(from, to)
        }

        delegate: ManageTokensDelegate {
            controller: root.controller
            dragParent: root
            count: root.controller.communityTokensModel.count
            dragEnabled: count > 1
            getCurrencyAmount: function (balance, key) {
                return root.getCurrencyAmount(balance, key)
            }
            getCurrentCurrencyAmount: function (balance) {
                return root.getCurrentCurrencyAmount(balance)
            }
        }
    }

    DelegateModel {
        id: communityGroupedModel

        model: root.controller.communityTokenGroupsModel

        function moveItem(from, to) {
            model.moveItem(from, to)
        }

        delegate: ManageTokensGroupDelegate {
            height: 76

            controller: root.controller
            dragParent: root
            dragEnabled: root.controller.communityTokenGroupsModel.count > 1
        }
    }
}
