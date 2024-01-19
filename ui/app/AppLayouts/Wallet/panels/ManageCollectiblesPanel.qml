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

    contentItem: ColumnLayout {
        spacing: Style.current.padding

        ShapeRectangle {
            Layout.fillWidth: true
            Layout.margins: 2
            visible: !root.controller.regularTokensModel.count && !root.controller.communityTokensModel.count
            text: qsTr("You’ll be able to manage the display of your collectibles here")
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding
            visible: root.controller.communityTokensModel.count
            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Community minted")
            }
            StatusSwitch {
                objectName: "switchArrangeByCommunity"
                LayoutMirroring.enabled: true
                LayoutMirroring.childrenInherit: true
                id: switchArrangeByCommunity
                textColor: Theme.palette.baseColor1
                font.pixelSize: 13
                text: qsTr("Arrange by community")
                checked: root.controller.arrangeByCommunity
                onToggled: root.controller.arrangeByCommunity = checked
            }
        }

        Loader {
            objectName: "loaderCommunityTokens"
            Layout.fillWidth: true
            active: root.controller.communityTokensModel.count
            visible: active
            sourceComponent: switchArrangeByCommunity.checked ? cmpCommunityTokenGroups : cmpCommunityTokens
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding
            visible: root.controller.regularTokensModel.count
            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Other")
            }
            StatusSwitch {
                LayoutMirroring.enabled: true
                LayoutMirroring.childrenInherit: true
                id: switchArrangeByCollection
                textColor: Theme.palette.baseColor1
                font.pixelSize: 13
                text: qsTr("Arrange by collection")
                checked: root.controller.arrangeByCollection
                onToggled: root.controller.arrangeByCollection = checked
            }
        }

        Loader {
            objectName: "loaderRegularTokens"
            Layout.fillWidth: true
            active: root.controller.regularTokensModel.count
            visible: active
            sourceComponent: switchArrangeByCollection.checked ? cmpCollectionTokenGroups : cmpRegularTokens
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

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: ManageTokensGroupDelegate {
                isCollectible: true
                controller: root.controller
                dragParent: root
                dragEnabled: root.controller.communityTokenGroupsModel.count > 1
            }
        }
    }

    Component {
        id: cmpRegularTokens
        StatusListView {
            objectName: "lvRegularTokens"
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
            }
        }
    }

    Component {
        id: cmpCollectionTokenGroups
        StatusListView {
            objectName: "lvCollectionTokenGroups"
            model: root.controller.collectionGroupsModel
            implicitHeight: contentHeight
            interactive: false

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: ManageTokensGroupDelegate {
                isCollection: true
                controller: root.controller
                dragParent: root
                dragEnabled: root.controller.collectionGroupsModel.count > 1
            }
        }
    }
}
