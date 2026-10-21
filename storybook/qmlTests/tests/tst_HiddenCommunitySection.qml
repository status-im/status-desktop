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
