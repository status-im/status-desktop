import QtQuick 2.15
import QtQuick.Controls 2.15
import QtTest 1.15

import StatusQ 0.1
import StatusQ.Models 0.1

import AppLayouts.Wallet.panels 1.0

import Storybook 1.0
import Models 1.0
import utils 1.0

Item {
    id: root
    width: 600
    height: 400

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
            id: showcasePanel
            width: 500
            controller: ManageTokensController {
                sourceModel: renamedModel
                settingsKey: "WalletCollectibles"
                onTokenHidden: (symbol, name) => Global.displayToastMessage(
                                   qsTr("%1 was successfully hidden.").arg(name), "", "checkmark-circle",
                                   false, Constants.ephemeralNotificationType.success, "")
                onCommunityTokenGroupHidden: (communityName) => Global.displayToastMessage(
                                                 qsTr("%1 community collectibles successfully hidden").arg(communityName), "", "checkmark-circle",
                                                 false, Constants.ephemeralNotificationType.success, "")
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
            waitForItemPolished(listview)
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
            controlUnderTest.clearSettings()
            notificationSpy.clear()
        }

        function test_showHideToken() {
            verify(!controlUnderTest.dirty)

            const lvRegular = findChild(controlUnderTest, "lvRegularTokens")
            verify(!!lvRegular)
            const lvRegularCount = lvRegular.count
            verify(lvRegularCount === 7)

            const delegate0 = findChild(lvRegular, "manageTokensDelegate-0")
            verify(!!delegate0)
            const title = delegate0.title
            tryCompare(notificationSpy, "count", 0)
            triggerDelegateMenuAction(lvRegular, 0, "miHideToken")
            // verify the signal to show the notification toast got fired
            tryCompare(notificationSpy, "count", 1)

            // verify we now have -1 regular tokens after the "hide" operation
            tryCompare(lvRegular, "count", lvRegularCount-1)
        }

        function test_showHideCommunityGroup() {
            verify(!controlUnderTest.dirty)

            const loaderCommunityTokens = findChild(controlUnderTest, "loaderCommunityTokens")
            verify(!!loaderCommunityTokens)
            tryCompare(loaderCommunityTokens, "active", true)
            const switchArrangeByCommunity = findChild(controlUnderTest, "switchArrangeByCommunity")
            verify(!!switchArrangeByCommunity)
            switchArrangeByCommunity.toggle()
            const lvCommunityTokenGroups = findChild(loaderCommunityTokens, "lvCommunityTokenGroups")
            verify(!!lvCommunityTokenGroups)

            // verify we have 2 community collectible groups
            tryCompare(lvCommunityTokenGroups, "count", 3)
            tryCompare(notificationSpy, "count", 0)
            triggerDelegateMenuAction(lvCommunityTokenGroups, 0, "miHideTokenGroup", true)
            // verify the signal to show the notification toast got fired
            tryCompare(notificationSpy, "count", 1)

            // verify we have one less group
            waitForItemPolished(lvCommunityTokenGroups)
            tryCompare(lvCommunityTokenGroups, "count", 2)
        }

        function test_dnd() {
            verify(!controlUnderTest.dirty)

            const lvRegular = findChild(controlUnderTest, "lvRegularTokens")
            verify(!!lvRegular)
            verify(lvRegular.count !== 0)

            const delegate0 = findChild(lvRegular, "manageTokensDelegate-0")
            verify(!!delegate0)
            const title0 = delegate0.title
            verify(!!title0)
            const title1 = findChild(lvRegular, "manageTokensDelegate-1").title
            verify(!!title1)

            // DND one item down (~80px in height)
            mouseDrag(delegate0, delegate0.width/2, delegate0.height/2, 0, 80)

            // cross compare the titles
            tryCompare(findChild(lvRegular, "manageTokensDelegate-0"), "title", title1)
            tryCompare(findChild(lvRegular, "manageTokensDelegate-1"), "title", title0)
            verify(controlUnderTest.dirty)
        }

        function test_group_dnd() {
            verify(!controlUnderTest.dirty)

            const switchArrangeByCommunity = findChild(controlUnderTest, "switchArrangeByCommunity")
            verify(!!switchArrangeByCommunity)
            mouseClick(switchArrangeByCommunity)

            const switchCollapseCommunityGroups = findChild(controlUnderTest, "switchCollapseCommunityGroups")
            verify(!!switchCollapseCommunityGroups)
            mouseClick(switchCollapseCommunityGroups)

            const loaderCommunityTokens = findChild(controlUnderTest, "loaderCommunityTokens")
            verify(!!loaderCommunityTokens)
            tryCompare(loaderCommunityTokens, "active", true)
            const lvCommunityTokenGroups = findChild(loaderCommunityTokens, "lvCommunityTokenGroups")
            verify(!!lvCommunityTokenGroups)
            waitForItemPolished(lvCommunityTokenGroups)
            tryCompare(lvCommunityTokenGroups, "count", 3)

            const group0 = findChild(lvCommunityTokenGroups, "manageTokensGroupDelegate-0")
            const title0 = group0.title
            verify(!!title0)
            const title1 = findChild(lvCommunityTokenGroups, "manageTokensGroupDelegate-1").title
            verify(!!title1)
            verify(title0 !== title1)

            // DND one group down (~80px in height)
            mouseDrag(group0, group0.width/2, group0.height/2, 0, 80)

            // cross compare the titles
            tryCompare(findChild(lvCommunityTokenGroups, "manageTokensGroupDelegate-0"), "title", title1)
            tryCompare(findChild(lvCommunityTokenGroups, "manageTokensGroupDelegate-1"), "title", title0)

            verify(controlUnderTest.dirty)
        }

        function test_group_move_hide_show_community_token() {
            verify(!controlUnderTest.dirty)
            const titleToTest = "Bearz"

            const switchArrangeByCommunity = findChild(controlUnderTest, "switchArrangeByCommunity")
            verify(!!switchArrangeByCommunity)
            mouseClick(switchArrangeByCommunity)

            const loaderCommunityTokens = findChild(controlUnderTest, "loaderCommunityTokens")
            verify(!!loaderCommunityTokens)
            tryCompare(loaderCommunityTokens, "active", true)
            const lvCommunityTokenGroups = findChild(loaderCommunityTokens, "lvCommunityTokenGroups")
            verify(!!lvCommunityTokenGroups)
            waitForItemPolished(lvCommunityTokenGroups)
            tryCompare(lvCommunityTokenGroups, "count", 3)

            // get the "Bearz" group at index 1
            var bearzGroupTokenDelegate = findChild(lvCommunityTokenGroups, "manageTokensGroupDelegate-1")
            const bearzTitle = bearzGroupTokenDelegate.title
            compare(bearzTitle, titleToTest)
            verify(!!bearzGroupTokenDelegate)
            waitForItemPolished(bearzGroupTokenDelegate)

            // get the Bearz child listview
            const bearzChildLV = findChild(bearzGroupTokenDelegate, "manageTokensGroupListView")
            verify(!!bearzChildLV)

            // find the 2385 delegate from the Bearz group and hide it
            const bear2385DelegateIdx = findDelegateIndexWithTitle(bearzChildLV, "KILLABEAR #2385")
            verify(bear2385DelegateIdx !== -1)
            tryCompare(notificationSpy, "count", 0)
            triggerDelegateMenuAction(bearzChildLV, bear2385DelegateIdx, "miHideCommunityToken")
            // verify the signal to show the notification toast got fired
            tryCompare(notificationSpy, "count", 1)

            // now move the Bearz group up so that it's first (ends up at index 0)
            waitForItemPolished(lvCommunityTokenGroups)
            triggerDelegateMenuAction(lvCommunityTokenGroups, 1, "miMoveUp", true)
            verify(controlUnderTest.dirty)
            bearzGroupTokenDelegate = findChild(lvCommunityTokenGroups, "manageTokensGroupDelegate-0")
            verify(!!bearzGroupTokenDelegate)

            // get one of the other group's (Pandas) tokens and hide it
            const pandasGroupTokenDelegate = findChild(lvCommunityTokenGroups, "manageTokensGroupDelegate-1")
            verify(!!pandasGroupTokenDelegate)
            const pandasChildLV = findChild(pandasGroupTokenDelegate, "manageTokensGroupListView")
            verify(!!pandasChildLV)
            const panda909DelegateIdx = findDelegateIndexWithTitle(pandasChildLV, "Frenly Panda #909")
            triggerDelegateMenuAction(pandasChildLV, panda909DelegateIdx, "miHideCommunityToken")
            // verify the signal to show the notification toast got fired
            tryCompare(notificationSpy, "count", 2)

            // finally verify that the Bearz group is still at top
            waitForItemPolished(lvCommunityTokenGroups)
            tryCompare(findChild(lvCommunityTokenGroups, "manageTokensGroupDelegate-0"), "title", titleToTest)
        }

        function test_moveOperations() {
            verify(!controlUnderTest.dirty)

            const lvRegular = findChild(controlUnderTest, "lvRegularTokens")
            verify(!!lvRegular)
            verify(lvRegular.count !== 0)

            var delegate0 = findChild(lvRegular, "manageTokensDelegate-0")
            verify(!!delegate0)
            const title = delegate0.title

            // verify moveUp and moveToTop is not available for the first item
            const moveUpAction = findDelegateMenuAction(lvRegular, 0, "miMoveUp")
            tryCompare(moveUpAction, "enabled", false)
            const moveTopAction = findDelegateMenuAction(lvRegular, 0, "miMoveToTop")
            tryCompare(moveTopAction, "enabled", false)

            // trigger move to bottom
            triggerDelegateMenuAction(lvRegular, 0, "miMoveToBottom")

            waitForItemPolished(lvRegular)
            verify(controlUnderTest.dirty)

            // verify the previous first and current last are actually the same item
            const delegateN = findChild(lvRegular, "manageTokensDelegate-%1".arg(lvRegular.count-1))
            verify(!!delegateN)
            const titleN = delegateN.title
            compare(title, titleN)

            // verify move down and to bottom is not available for the last item
            const moveDownAction = findDelegateMenuAction(lvRegular, lvRegular.count-1, "miMoveDown")
            tryCompare(moveDownAction, "enabled", false)
            const moveBottomAction = findDelegateMenuAction(lvRegular, lvRegular.count-1, "miMoveToBottom")
            tryCompare(moveBottomAction, "enabled", false)

            // trigger move to top and verify we got the same title (item) again
            triggerDelegateMenuAction(lvRegular, lvRegular.count-1, "miMoveToTop")
            waitForItemPolished(lvRegular)
            tryCompare(findChild(lvRegular, "manageTokensDelegate-0"), "title", title)

            // trigger move down and verify we got the same title (item) again
            triggerDelegateMenuAction(lvRegular, 0, "miMoveDown")
            tryCompare(findChild(lvRegular, "manageTokensDelegate-1"), "title", title)

            // trigger move up and verify we got the same title (item) again
            triggerDelegateMenuAction(lvRegular, 1, "miMoveUp")
            tryCompare(findChild(lvRegular, "manageTokensDelegate-0"), "title", title)
        }

        function test_saveLoad() {
            // start with clear settings
            controlUnderTest.clearSettings()
            controlUnderTest.revert()

            verify(!controlUnderTest.dirty)
            const titleToTest = "Big Kitty"

            const lvRegular = findChild(controlUnderTest, "lvRegularTokens")
            verify(!!lvRegular)
            const bigKittyIndex = findDelegateIndexWithTitle(lvRegular, titleToTest)
            verify(bigKittyIndex !== -1)
            const title0 = findChild(lvRegular, "manageTokensDelegate-0").title
            verify(!!title0)
            verify(title0 !== titleToTest)

            // trigger move to top and verify we got the correct title
            triggerDelegateMenuAction(lvRegular, bigKittyIndex, "miMoveToTop")
            waitForItemPolished(lvRegular)
            tryCompare(findChild(lvRegular, "manageTokensDelegate-0"), "title", titleToTest)

            // save
            verify(controlUnderTest.dirty)
            controlUnderTest.saveSettings()
            verify(!controlUnderTest.dirty)

            // load the settings and check BigKitty is still on top
            controlUnderTest.revert()
            verify(!controlUnderTest.dirty)
            waitForItemPolished(lvRegular)
            tryCompare(findChild(lvRegular, "manageTokensDelegate-0"), "title", titleToTest)
        }
    }
}
