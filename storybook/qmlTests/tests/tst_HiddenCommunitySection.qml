import QtQuick
import QtTest

import utils

import "helpers"

// Visited sections stay loaded but hidden when the user switches away, so the
// member data a community view holds must be let go while it is hidden and
// taken back when it shows again.
Item {
    id: root

    width: 1000
    height: 700

    CommunityChatSectionHarness {
        id: harness
        anchors.fill: parent
    }

    TestCase {
        name: "HiddenCommunitySection"
        when: windowShown

        readonly property var mock: harness.mock

        function init() {
            mock.joined = true
            mock.memberRole = Constants.memberRole.owner
            mock.amIBanned = false
            mock.requestToJoinState = Constants.RequestToJoinState.None
            mock.membersCount = 20
            mock.categoriesCount = 1
            mock.channelsPerCategory = 2
            mock.messagesPerChannel = 5
            mock.install()
            harness.communitiesStore.rosterHolds = ({})
        }

        function cleanup() {
            harness.visible = true
            harness.loader.active = false
            mock.uninstall()
        }

        function loadSection() {
            harness.loader.active = true
            const loader = harness.loader.item
            verify(!!loader)
            tryVerify(() => loader.status === Loader.Ready, 120000)
            return loader
        }

        function rosterHolds() {
            return harness.communitiesStore.rosterHolds[mock.communityId] ?? 0
        }

        function test_hiddenMembersPanelReleasesTheRoster() {
            const loader = loadSection()
            const view = harness.findChildByTypePrefix(loader, "ChatView")
            verify(!!view)
            view.showUsersList = true
            tryVerify(() => rosterHolds() === 1, 20000,
                      "the shown members panel must hold the roster")

            harness.visible = false
            compare(rosterHolds(), 0, "a hidden section must release the roster")

            harness.visible = true
            compare(rosterHolds(), 1, "showing the section again must take it back")
        }

        function test_hiddenFocusedInputReleasesTheRoster() {
            const loader = loadSection()
            const view = harness.findChildByTypePrefix(loader, "ChatView")
            verify(!!view)
            view.showUsersList = false
            const column = harness.findChildByTypePrefix(loader, "ChatColumnView")
            verify(!!column)
            const input = harness.findChildByTypePrefix(column, "StatusChatInput")
            verify(!!input)
            input.textInput.forceActiveFocus()
            tryVerify(() => rosterHolds() === 1, 5000,
                      "the focused input must hold the roster")

            harness.visible = false
            compare(rosterHolds(), 0, "a hidden section must release the roster")
        }

        function test_hiddenSettingsAreNotShown() {
            const loader = loadSection()
            const layout = harness.findChildByTypePrefix(loader, "ChatLayout")
            verify(!!layout)
            const settings = harness.findChildByTypePrefix(layout, "CommunitySettingsLoader")
            verify(!!settings)

            layout.currentIndex = 1
            verify(settings.settingsShown)

            harness.visible = false
            verify(!settings.settingsShown,
                   "settings of a hidden section must not count as shown")

            harness.visible = true
            verify(settings.settingsShown)
        }
    }
}
