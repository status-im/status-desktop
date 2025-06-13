import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Models 0.1

import utils 1.0
import shared.controls 1.0

import AppLayouts.Wallet.controls 1.0

import QtModelsToolkit 1.0
import SortFilterProxyModel 0.2

Control {
    id: root

    required property var assetsController
    required property var collectiblesController

    property var getCurrencyAmount: function (balance, symbol) {}
    property var getCurrentCurrencyAmount: function (balance) {}

    readonly property bool dirty: false // never dirty, the "show xxx" actions are immediate
    readonly property bool hasSettings: root.assetsController.hasSettings || root.collectiblesController.hasSettings

    background: null

    function clearSettings() {
        root.assetsController.requestClearSettings();
        root.collectiblesController.requestClearSettings();
    }

    QtObject {
        id: d

        property bool assetsExpanded: true
        property bool collectiblesExpanded: true

        readonly property int assetsCount: root.assetsController.hiddenTokensModel.count + root.assetsController.hiddenCommunityTokenGroupsModel.count
        readonly property int collectiblesCount: root.collectiblesController.hiddenTokensModel.count + root.collectiblesController.hiddenCommunityTokenGroupsModel.count // + TODO collection groups

        readonly property var filteredHiddenAssets: SortFilterProxyModel {
            sourceModel: root.assetsController.hiddenTokensModel
            filters: FastExpressionFilter {
                expression: {
                    root.assetsController.hiddenCommunityGroups
                    return !root.assetsController.hiddenCommunityGroups.includes(model.communityId)
                }
                expectedRoles: ["communityId"]
            }
        }

        readonly property var filteredHiddenCollectibles: SortFilterProxyModel {
            sourceModel: root.collectiblesController.hiddenTokensModel
            filters: FastExpressionFilter {
                expression: {
                    root.collectiblesController.hiddenCommunityGroups
                    root.collectiblesController.hiddenCollectionGroups
                    return !root.collectiblesController.hiddenCommunityGroups.includes(model.communityId) &&
                            !root.collectiblesController.hiddenCollectionGroups.includes(model.collectionUid)
                }
                expectedRoles: ["communityId", "collectionUid"]
            }
        }

        readonly property var combinedModel: ConcatModel {
            sources: [
                // assets
                SourceModel { // single hidden assets (not belonging to a group)
                    model: d.filteredHiddenAssets
                    markerRoleValue: "asset"
                },
                SourceModel { // community asset groups
                    model: root.assetsController.hiddenCommunityTokenGroupsModel
                    markerRoleValue: "assetGroup"
                },
                // collectibles
                SourceModel { // single hidden collectibles (not belonging to any group)
                    model: d.filteredHiddenCollectibles
                    markerRoleValue: "collectible"
                },
                SourceModel { // community collectible groups
                    model: root.collectiblesController.hiddenCommunityTokenGroupsModel
                    markerRoleValue: "collectibleGroup"
                },
                SourceModel { // collectible collection groups
                    model: root.collectiblesController.hiddenCollectionGroupsModel
                    markerRoleValue: "collectibleCollectionGroup"
                }
            ]

            markerRoleName: "tokenType"
        }

        readonly property var sfpm: SortFilterProxyModel {
            sourceModel: d.combinedModel
            proxyRoles: [
                FastExpressionRole {
                    name: "isCollectible"
                    expression: model.tokenType.startsWith("collectible")
                    expectedRoles: "tokenType"
                },
                FastExpressionRole {
                    name: "isGroup"
                    expression: model.tokenType.endsWith("Group")
                    expectedRoles: "tokenType"
                }
            ]
            // TODO sort by recency/timestamp (newest first)
        }
    }

    component SectionDelegate: Rectangle {
        id: sectionDelegate
        height: 64
        color: Theme.palette.statusListItem.backgroundColor

        property bool isCollectible

        RowLayout {
            anchors.fill: parent
            StatusFlatButton {
                size: StatusBaseButton.Size.Small
                icon.name: checked ? "chevron-down" : "next"
                checkable: true
                checked: sectionDelegate.isCollectible ? d.collectiblesExpanded : d.assetsExpanded
                textColor: Theme.palette.baseColor1
                textHoverColor: Theme.palette.directColor1
                onToggled: {
                    if (sectionDelegate.isCollectible)
                        d.collectiblesExpanded = !d.collectiblesExpanded
                    else
                        d.assetsExpanded = !d.assetsExpanded
                }
            }
            StatusBaseText {
                Layout.fillWidth: true
                text: sectionDelegate.isCollectible ? qsTr("Collectibles") : qsTr("Assets")
                elide: Text.ElideRight
            }
        }
    }

    component Placeholder: Item {
        property bool isCollectible

        height: ProfileUtils.defaultDelegateHeight
        ShapeRectangle {
            anchors.fill: parent
            anchors.margins: 1
            text: parent.isCollectible ? qsTr("Your hidden collectibles will appear here") : qsTr("Your hidden assets will appear here")
        }
    }

    Component {
        id: tokenDelegate
        ManageTokensDelegate {
            isCollectible: model.isCollectible
            controller: isCollectible ? root.collectiblesController : root.assetsController
            dragParent: null
            dragEnabled: false
            isHidden: true
            getCurrencyAmount: function (balance, symbol) {
                return root.getCurrencyAmount(balance, symbol)
            }
            getCurrentCurrencyAmount: function (balance) {
                return root.getCurrentCurrencyAmount(balance)
            }
        }
    }

    Component {
        id: tokenGroupDelegate
        ManageTokensGroupDelegate {
            isCollectible: model.isCollectible
            isCollection: model.tokenType === "collectibleCollectionGroup"
            controller: isCollectible ? root.collectiblesController : root.assetsController
            dragParent: null
            dragEnabled: false
            isHidden: true
        }
    }

    contentItem: ColumnLayout {
        spacing: 2 // subtle spacing for the dashed placeholders to be fully visible

        ColumnLayout { // no assets placeholder
            Layout.fillWidth: true
            Layout.fillHeight: false

            spacing: 0
            visible: !d.assetsCount
            SectionDelegate {
                Layout.fillWidth: true
            }
            Placeholder {
                Layout.fillWidth: true
                visible: d.assetsExpanded
            }
        }

        StatusListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: d.sfpm

            // For some reason displaced transition doesn't work correctly in
            // combination of delegate using Loader and leads to improper
            // delegates positioning when the top-most item from the list is
            // removed.
            //displaced: Transition {
            //    NumberAnimation { properties: "x,y" }
            //}

            spacing: Theme.halfPadding
            delegate: Loader {
                required property var model
                required property int index

                width: ListView.view.width
                height: visible ? ProfileUtils.defaultDelegateHeight : 0
                sourceComponent: model.isGroup ? tokenGroupDelegate : tokenDelegate
                visible: (!model.isCollectible && d.assetsExpanded) || (model.isCollectible && d.collectiblesExpanded)
            }

            section.property: "isCollectible"
            section.delegate: SectionDelegate {
                width: ListView.view.width
                isCollectible: section == "true"
            }
            section.labelPositioning: ViewSection.InlineLabels | ViewSection.CurrentLabelAtStart

            footer: ColumnLayout { // no collectibles placeholder
                width: ListView.view.width

                spacing: 0
                visible: !d.collectiblesCount
                height: visible ? implicitHeight : 0

                SectionDelegate {
                    Layout.fillWidth: true
                    isCollectible: true
                }
                Placeholder {
                    Layout.fillWidth: true
                    isCollectible: true
                    visible: d.collectiblesExpanded
                }
            }
        }

        Item {
            Layout.fillHeight: true
            visible: listView.count === 0
        }
    }
}
