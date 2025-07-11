import QtQuick
import QtTest

import Qt.labs.settings

import StatusQ.Models

import AppLayouts.Wallet.panels

import Models
import utils

import QtModelsToolkit

Item {
    id: root
    width: 600
    height: 2000

    ManageCollectiblesModel {
        id: collectiblesModel
    }

    RolesRenamingModel {
        id: renamedModel
        sourceModel: collectiblesModel
        mapping: [
            RoleRename {
                from: "uid"
                to: "symbol"
            }
        ]
    }

    Component {
        id: componentUnderTest
        ManageCollectiblesPanel {
            id: panel
            width: 500
            height: contentHeight
            controller: ManageTokensController {
                sourceModel: renamedModel
                settingsKey: "WalletCollectibles"
                serializeAsCollectibles: true

                onRequestSaveSettings: (jsonData) => {
                    savingStarted()
                    settingsStore.setValue(settingsKey, jsonData)
                    savingFinished()
                }
                onRequestLoadSettings: {
                    loadingStarted()
                    const jsonData = settingsStore.value(settingsKey, null)
                    loadingFinished(jsonData)
                }
                onRequestClearSettings: panel.clearSettings()

                onCommunityTokenGroupHidden: (communityName) => Global.displayToastMessage(
                                                 qsTr("%1 community collectibles successfully hidden").arg(communityName), "", "checkmark-circle",
                                                 false, Constants.ephemeralNotificationType.success, "")
            }

            function clearSettings() {
                controller.clearQSettings()
                settingsStore.setValue(panel.controller.settingsKey, null)
            }

            Settings {
                id: settingsStore
                category: "ManageTokens-" + panel.controller.settingsKey
            }
        }
    }

    SignalSpy {
        id: notificationSpy
        target: Global
        signalName: "displayToastMessage"
    }

    TestCase {
        name: "ManageCollectiblesPanel"
        when: windowShown

        property ManageCollectiblesPanel controlUnderTest: null

        function findDelegateIndexWithTitle(listview, title) {
            waitForRendering(listview)
            const count = listview.count
            for (let i = 0; i < count; i++) {
                const item = listview.itemAtIndex(i)
                if (!!item && item.visible && item.title === title)
                    return i
            }
            return -1
        }

        function findDelegateMenuAction(listview, index, actionName, isGroup=false) {
            const token = findChild(listview, "manageTokens%2Delegate-%1".arg(index).arg(isGroup ? "Group" : ""))
            verify(!!token)
            const delegateBtn = findChild(token, "btnManageTokenMenu-%1".arg(index))
            verify(!!delegateBtn)

            waitForItemPolished(delegateBtn)
            mouseClick(delegateBtn)
            const btnMenuLoader = findChild(delegateBtn, "manageTokensContextMenuLoader")
            verify(!!btnMenuLoader)

            tryCompare(btnMenuLoader, "active", true)
            const btnMenu = btnMenuLoader.item
            verify(!!btnMenu)
            verify(btnMenu.open)
            return findChild(btnMenu, actionName)
        }

        function triggerDelegateMenuAction(listview, index, actionName, isGroup=false) {
            const action = findDelegateMenuAction(listview, index, actionName, isGroup)
            verify(!!action)
            action.trigger()
        }

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            notificationSpy.clear()
        }

        function cleanup() {
            controlUnderTest.clearSettings()
        }

        function test_showHideSingleToken() {
            waitForItemPolished(controlUnderTest)
            verify(!controlUnderTest.dirty)

            const lvOther = findChild(controlUnderTest, "otherTokensListView")
            verify(!!lvOther)

            tryCompare(lvOther, "count", 10)
            const delegate0 = findChild(lvOther, "manageTokensDelegate-0")
            verify(!!delegate0)
            const title = delegate0.title
            tryCompare(notificationSpy, "count", 0)
            triggerDelegateMenuAction(lvOther, 0, "miHideCollectionToken")
            // verify the signal to show the notification toast got fired
            tryCompare(notificationSpy, "count", 1)

            // verify we now have -1 regular tokens after the "hide" operation
            tryCompare(lvOther, "count", 9)
        }

        function test_showHideCommunityGroup() {
            verify(!controlUnderTest.dirty)

            const communityHeader = findChild(controlUnderTest, "communityHeader")
            verify(!!communityHeader)
            const switchArrangeByCommunity = findChild(communityHeader, "switch")
            verify(!!switchArrangeByCommunity)

            waitForRendering(switchArrangeByCommunity)
            mouseClick(switchArrangeByCommunity)
            tryCompare(switchArrangeByCommunity, "checked", true)

            tryCompare(controlUnderTest.controller, "arrangeByCommunity", true)

            waitForRendering(controlUnderTest)
            const lvCommunity = findChild(controlUnderTest, "communityTokensListView")
            verify(!!lvCommunity)

            // verify we have 2 community collectible groups
            tryCompare(lvCommunity, "count", 6)
            tryCompare(notificationSpy, "count", 0)
            triggerDelegateMenuAction(lvCommunity, 0, "miHideTokenGroup", true)
            // verify the signal to show the notification toast got fired
            tryCompare(notificationSpy, "count", 1)

            // verify we have one less group
            waitForItemPolished(lvCommunity)
            tryCompare(lvCommunity, "count", 5)
        }

        function test_dnd() {
            verify(!controlUnderTest.dirty)

            const lvOther = findChild(controlUnderTest, "otherTokensListView")
            verify(!!lvOther)
            verify(lvOther.count !== 0)

            const delegate0 = findChild(lvOther, "manageTokensDelegate-0")
            verify(!!delegate0)
            const title0 = delegate0.title
            verify(!!title0)
            const delegate1 = findChild(lvOther, "manageTokensDelegate-1")
            const title1 = delegate1.title
            verify(!!title1)

            waitForRendering(delegate1)

            // DND one item up
            mouseDrag(delegate1, delegate1.width/2, delegate1.height/2, 0, -delegate1.height)

            // cross compare the titles
            tryCompare(findChild(lvOther, "manageTokensDelegate-0"), "title", title1)
            tryCompare(findChild(lvOther, "manageTokensDelegate-1"), "title", title0)
            verify(controlUnderTest.dirty)
        }

        function test_group_dnd() {
            verify(!controlUnderTest.dirty)

            const communityHeader = findChild(controlUnderTest, "communityHeader")
            verify(!!communityHeader)
            const switchArrangeByCommunity = findChild(communityHeader, "switch")
            verify(!!switchArrangeByCommunity)

            waitForItemPolished(switchArrangeByCommunity)
            mouseClick(switchArrangeByCommunity)

            const lvCommunity = findChild(controlUnderTest, "communityTokensListView")
            verify(!!lvCommunity)
            waitForItemPolished(lvCommunity)
            tryCompare(lvCommunity, "count", 6)

            const group0 = findChild(lvCommunity, "manageTokensGroupDelegate-0")
            const title0 = group0.title
            verify(!!title0)
            const group1 = findChild(lvCommunity, "manageTokensGroupDelegate-1")
            const title1 = group1.title
            verify(!!title1)
            verify(title0 !== title1)

            waitForRendering(group1)

            mouseDrag(group1, group1.width/2, group1.height/2, 0, -group1.height)

            // cross compare the titles
            tryCompare(findChild(lvCommunity, "manageTokensGroupDelegate-0"), "title", title1)
            tryCompare(findChild(lvCommunity, "manageTokensGroupDelegate-1"), "title", title0)

            verify(controlUnderTest.dirty)
        }

        function test_group_move_hide_show_community_token() {
            verify(!controlUnderTest.dirty)
            const titleToTest = "Bearz"

            const communityHeader = findChild(controlUnderTest, "communityHeader")
            verify(!!communityHeader)
            const switchArrangeByCommunity = findChild(communityHeader, "switch")
            verify(!!switchArrangeByCommunity)
            waitForRendering(switchArrangeByCommunity)
            mouseClick(switchArrangeByCommunity)

            const lvCommunity = findChild(controlUnderTest, "communityTokensListView")
            verify(!!lvCommunity)
            waitForItemPolished(lvCommunity)
            tryCompare(lvCommunity, "count", 6)

            // get the "Bearz" group at index 1
            var bearzGroupTokenDelegate = findChild(lvCommunity, "manageTokensGroupDelegate-1")
            const bearzTitle = bearzGroupTokenDelegate.title
            compare(bearzTitle, titleToTest)
            verify(!!bearzGroupTokenDelegate)
            waitForItemPolished(bearzGroupTokenDelegate)

            // now move the Bearz group up so that it's first (ends up at index 0)
            waitForItemPolished(lvCommunity)
            triggerDelegateMenuAction(lvCommunity, 1, "miMoveUp", true)
            verify(controlUnderTest.dirty)
            bearzGroupTokenDelegate = findChild(lvCommunity, "manageTokensGroupDelegate-0")
            verify(!!bearzGroupTokenDelegate)

            // finally verify that the Bearz group is still at top
            waitForItemPolished(lvCommunity)
            tryCompare(findChild(lvCommunity, "manageTokensGroupDelegate-0"), "title", titleToTest)
        }

        function test_arrangeByCommunity() {
            const communityHeader = findChild(controlUnderTest, "communityHeader")
            verify(!!communityHeader)
            const switchArrangeByCommunity = findChild(communityHeader, "switch")
            verify(!!switchArrangeByCommunity)
            waitForRendering(switchArrangeByCommunity)
            mouseClick(switchArrangeByCommunity)

            const lvCommunity = findChild(controlUnderTest, "communityTokensListView")
            verify(!!lvCommunity)
            waitForItemPolished(lvCommunity)

            const pandasGroup = findChild(lvCommunity, "manageTokensGroupDelegate-0")
            tryCompare(pandasGroup, "title", "Frenly Pandas")
            tryCompare(pandasGroup, "childCount", 4)
        }

        function test_arrangeByCollection() {
            const collectionsHeader = findChild(controlUnderTest, "nonCommunityHeader")
            verify(!!collectionsHeader)
            const switchArrangeByCollection = findChild(collectionsHeader, "switch")
            verify(!!switchArrangeByCollection)
            waitForRendering(switchArrangeByCollection)
            mouseClick(switchArrangeByCollection)

            const lvCollections = findChild(controlUnderTest, "otherTokensListView")
            verify(!!lvCollections)
            waitForItemPolished(lvCollections)

            const kittiesGroup = findChild(lvCollections, "manageTokensGroupDelegate-0")
            tryCompare(kittiesGroup, "title", "Kitties")
            tryCompare(kittiesGroup, "childCount", 3)
        }

        function test_moveOperations() {
            verify(!controlUnderTest.dirty)

            const lvOther = findChild(controlUnderTest, "otherTokensListView")
            verify(!!lvOther)
            verify(lvOther.count !== 0)

            var delegate0 = findChild(lvOther, "manageTokensDelegate-0")
            verify(!!delegate0)
            const title = delegate0.title

            // verify moveUp and moveToTop is not available for the first item
            const moveUpAction = findDelegateMenuAction(lvOther, 0, "miMoveUp")
            tryCompare(moveUpAction, "enabled", false)
            const moveTopAction = findDelegateMenuAction(lvOther, 0, "miMoveToTop")
            tryCompare(moveTopAction, "enabled", false)

            // trigger move to bottom
            waitForItemPolished(lvOther)
            triggerDelegateMenuAction(lvOther, 0, "miMoveToBottom")
            verify(controlUnderTest.dirty)

            // verify the previous first and current last are actually the same item
            const delegateN = findChild(lvOther, "manageTokensDelegate-%1".arg(lvOther.count-1))
            verify(!!delegateN)
            const titleN = delegateN.title
            compare(title, titleN)

            // verify move down and to bottom is not available for the last item
            const moveDownAction = findDelegateMenuAction(lvOther, lvOther.count-1, "miMoveDown")
            tryCompare(moveDownAction, "enabled", false)
            const moveBottomAction = findDelegateMenuAction(lvOther, lvOther.count-1, "miMoveToBottom")
            tryCompare(moveBottomAction, "enabled", false)

            // trigger move to top and verify we got the same title (item) again
            triggerDelegateMenuAction(lvOther, lvOther.count-1, "miMoveToTop")
            waitForItemPolished(lvOther)
            tryCompare(findChild(lvOther, "manageTokensDelegate-0"), "title", title)

            // trigger move down and verify we got the same title (item) again
            triggerDelegateMenuAction(lvOther, 0, "miMoveDown")
            tryCompare(findChild(lvOther, "manageTokensDelegate-1"), "title", title)

            // trigger move up and verify we got the same title (item) again
            triggerDelegateMenuAction(lvOther, 1, "miMoveUp")
            tryCompare(findChild(lvOther, "manageTokensDelegate-0"), "title", title)
        }

        function test_saveLoad() {
            verify(!controlUnderTest.dirty)
            const titleToTest = "Big Kitty"

            let lvOther = findChild(controlUnderTest, "otherTokensListView")
            verify(!!lvOther)
            const bigKittyIndex = findDelegateIndexWithTitle(lvOther, titleToTest)
            verify(bigKittyIndex !== -1)
            const title0 = findChild(lvOther, "manageTokensDelegate-0").title
            verify(!!title0)
            verify(title0 !== titleToTest)

            // trigger move to top and verify we got the correct title
            triggerDelegateMenuAction(lvOther, bigKittyIndex, "miMoveToTop")
            waitForItemPolished(lvOther)
            tryCompare(findChild(lvOther, "manageTokensDelegate-0"), "title", titleToTest)

            // save
            verify(controlUnderTest.dirty)
            controlUnderTest.saveSettings(false /* update */)
            verify(!controlUnderTest.dirty)

            // load the settings and check BigKitty is still on top
            controlUnderTest.revert()
            verify(!controlUnderTest.dirty)
            lvOther = findChild(controlUnderTest, "otherTokensListView")
            verify(!!lvOther)
            waitForItemPolished(lvOther)
            tryVerify(() => lvOther.count > 0)
            const topItem = findChild(lvOther, "manageTokensDelegate-0")
            verify(!!topItem)
            tryCompare(topItem, "title", titleToTest)
        }
    }
}
