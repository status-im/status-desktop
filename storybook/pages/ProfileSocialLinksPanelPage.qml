import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils

import mainui 1.0
import AppLayouts.Profile.panels 1.0
import shared.stores 1.0

import utils 1.0

import Storybook 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Popups {
        popupParent: root
        rootStore: QtObject {}
        communityTokensStore: CommunityTokensStore {}
    }

    ListModel {
        id: linksModel
        ListElement {
            uuid: "0001"
            text: "__github"
            url: "https://github.com/caybro"
            linkType: 3 // Constants.socialLinkType.github
            icon: "github"
        }
        ListElement {
            uuid: "0002"
            text: "__twitter"
            url: "https://twitter.com/caybro"
            linkType: 1 // Constants.socialLinkType.twitter
            icon: "twitter"
        }
        ListElement {
            uuid: "0003"
            text: "__personal_site"
            url: "https://status.im"
            linkType: 2 // Constants.socialLinkType.personalSite
            icon: "language"
        }
        ListElement {
            uuid: "0004"
            text: "__youtube"
            url: "https://www.youtube.com/@LukasTinkl"
            linkType: 4 // Constants.socialLinkType.youtube
            icon: "youtube"
        }
        ListElement { // NB: empty on purpose, for testing
            uuid: ""
            text: ""
            url: ""
            linkType: -1
            icon: ""
        }
        ListElement {
            uuid: "0005"
            text: "Figma design very long URL link text that should elide"
            url: "https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=1223%3A124882&t=qvYeJ8grsZLyUS0V-0"
            linkType: 0 // Constants.socialLinkType.custom
            icon: "link"
        }
        ListElement {
            uuid: "0006"
            text: "__telegram"
            url: "https://t.me/ltinkl"
            linkType: 6 // Constants.socialLinkType.telegram
            icon: "telegram"
        }
    }

    Connections {
        target: Global
        function onOpenLink(link) {
            logs.logEvent("Global::openLink", ["link"], [link])
        }
    }

    StatusScrollView { // wrapped in a ScrollView on purpose; to simulate SettingsContentBase.qml
        SplitView.fillWidth: true
        SplitView.preferredHeight: 300
        ProfileSocialLinksPanel {
            width: 500
            profileStore: QtObject {
                function createLink(text, url, linkType, icon) {
                    logs.logEvent("ProfileStore::createLink", ["text", "url", "linkType", "icon"], arguments)
                    linksModel.append({text, url, linkType, icon})
                }

                function removeLink(uuid) {
                    logs.logEvent("ProfileStore::removeLink", ["uuid"], arguments)
                    const idx = CoreUtils.ModelUtils.indexOf(linksModel, "uuid", uuid)
                    if (idx === -1)
                        return
                    linksModel.remove(idx, 1)
                }

                function updateLink(uuid, text, url) {
                    logs.logEvent("ProfileStore::updateLink", ["uuid", "text", "url"], arguments)
                    const idx = CoreUtils.ModelUtils.indexOf(linksModel, "uuid", uuid)
                    if (idx === -1)
                        return
                    if (!!text)
                        linksModel.setProperty(idx, "text", text)
                    if (!!url)
                        linksModel.setProperty(idx, "url", url)
                }

                function moveLink(fromRow, toRow, count) {
                    logs.logEvent("ProfileStore::moveLink", ["fromRow", "toRow", "count"], arguments)
                    linksModel.move(fromRow, toRow, 1)
                }

                function resetSocialLinks() {
                    logs.logEvent("ProfileStore::resetSocialLinks")
                }

                function saveSocialLinks(silent = false) {
                    logs.logEvent("ProfileStore::saveSocialLinks", ["silent"], arguments)
                }
            }

            socialLinksModel: linksModel
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Panels

// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14588%3A308727&t=cwFGbBHsAGOP0T5R-0
