import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15
import QtQml 2.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Models 0.1

import shared.controls 1.0

import AppLayouts.Wallet.controls 1.0

import "internals"

Control {
    id: root

    required property var controller

    readonly property bool dirty: root.controller.dirty
    readonly property bool hasSettings: root.controller.hasSettings

    property var getCurrencyAmount: function (balance, symbol) {}
    property var getCurrentCurrencyAmount: function(balance) {}

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

        readonly property int sectionHeight: 64
    }

    contentItem: DoubleFlickableWithFolding {
        id: doubleFlickable

        clip: true

        ScrollBar.vertical: StatusScrollBar {
            policy: ScrollBar.AsNeeded
            visible: resolveVisibility(policy, doubleFlickable.height,
                                       doubleFlickable.contentHeight)
        }

        flickable1: ManageTokensListViewBase {
            model: root.controller.regularTokensModel
            width: doubleFlickable.width

            ScrollBar.vertical: null

            header: FoldableHeader {
                width: ListView.view.width
                title: qsTr("Assets")
                folded: doubleFlickable.flickable1Folded

                onToggleFolding: doubleFlickable.flip1Folding()
            }

            delegate: ManageTokensDelegate {
                controller: root.controller
                dragParent: root
                count: root.controller.regularTokensModel.count
                dragEnabled: count > 1
                getCurrencyAmount: function (balance, symbol) {
                    return root.getCurrencyAmount(balance, symbol)
                }
                getCurrentCurrencyAmount: function (balance) {
                    return root.getCurrentCurrencyAmount(balance)
                }
            }

            placeholderText: qsTr("Your assets will appear here")
        }

        flickable2: ManageTokensListViewBase {
            width: doubleFlickable.width

            model: root.controller.arrangeByCommunity ? communityGroupedModel
                                                      : communityNonGroupedModel

            header: FoldableHeader {
                width: ListView.view.width
                title: qsTr("Community minted")
                switchText: qsTr("Arrange by community")
                folded: doubleFlickable.flickable2Folded
                checked: root.controller.arrangeByCommunity

                onToggleFolding: doubleFlickable.flip2Folding()
                onToggleSwitch: root.controller.arrangeByCommunity = checked
            }

            placeholderText: qsTr("Your community minted assets will appear here")
        }
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
            getCurrencyAmount: function (balance, symbol) {
                return root.getCurrencyAmount(balance, symbol)
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
