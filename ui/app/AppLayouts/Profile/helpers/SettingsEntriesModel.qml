import QtQuick 2.15

import StatusQ 0.1
import utils 1.0

import SortFilterProxyModel 0.2

/*!
    \qmltype SettingsEntriesModel
    \inherits SortFilterProxyModel
    \inqmlmodule AppLayouts.Profile.helpers

    Model providing entries to the settings section.

    Model structure:

    subsection          [int]    - identifier of the entry (Constants.settingsSubsection)
    text                [string] - readable name of the entry
    icon                [string] - icon name
    badgeCount          [int]    - number presented on the badge
    isExperimental      [bool]   - indicates if the beta tag should be presented
    experimentalTooltip [string] - tooltip text for the beta tag
*/
SortFilterProxyModel {
    id: root

    // Determines if wallet-related entries should be included
    property bool showWalletEntries

    // Determines if back up seed phrase entry should be included
    property bool showBackUpSeed

    // Badge count for the syncing entry
    property int syncingBadgeCount: 0

    // Badge count for the messaging section
    property int messagingBadgeCount: 0

    readonly property string appsGroupTitle: qsTr("Apps")
    readonly property string preferencesGroupTitle: qsTr("Preferences")
    readonly property string aboutAndHelpGroupTitle: qsTr("About & Help")

    readonly property var entries: [
        {
            subsection: Constants.settingsSubsection.backUpSeed,
            text: qsTr("Back up seed phrase"),
            icon: "seed-phrase"
        },
        {
            subsection: Constants.settingsSubsection.profile,
            text: qsTr("Profile"),
            icon: "profile"
        },
        {
            subsection: Constants.settingsSubsection.password,
            text: qsTr("Password"),
            icon: "password"
        },
        {
            subsection: Constants.settingsSubsection.keycard,
            text: qsTr("Keycard"),
            icon: "keycard"
        },
        {
            subsection: Constants.settingsSubsection.ensUsernames,
            text: qsTr("ENS usernames"),
            icon: "username",
            isExperimental: true,
            experimentalTooltip: qsTr("This section is going through a redesign.")
        },
        {
            subsection: Constants.settingsSubsection.syncingSettings,
            text: qsTr("Syncing"),
            icon: "rotate",
            isExperimental: true,
            experimentalTooltip: qsTr("Connection problems can happen.<br>If they do, please use the Enter a Seed Phrase feature instead.")
        },
        {
            subsection: Constants.settingsSubsection.messaging,
            text: qsTr("Messaging"),
            icon: "chat",
            group: root.appsGroupTitle
        },
        {
            subsection: Constants.settingsSubsection.wallet,
            text: qsTr("Wallet"),
            icon: "wallet",
            group: root.appsGroupTitle
        },
        {
            subsection: Constants.settingsSubsection.communitiesSettings,
            text: qsTr("Communities"),
            icon: "communities",
            group: root.appsGroupTitle
        },
        {
            subsection: Constants.settingsSubsection.privacyAndSecurity,
            text: qsTr("Privacy and security"),
            icon: "security",
            group: root.preferencesGroupTitle
        },
        {
            subsection: Constants.settingsSubsection.appearance,
            text: qsTr("Appearance"),
            icon: "appearance",
            group: root.preferencesGroupTitle
        },
        {
            subsection: Constants.settingsSubsection.notifications,
            text: qsTr("Notifications & Sounds"),
            icon: "notification",
            group: root.preferencesGroupTitle
        },
        {
            subsection: Constants.settingsSubsection.language,
            text: qsTr("Language & Currency"),
            icon: "language",
            group: root.preferencesGroupTitle
        },
        {
            subsection: Constants.settingsSubsection.advanced,
            text: qsTr("Advanced"),
            icon: "settings",
            group: root.preferencesGroupTitle
        },
        {
            subsection: Constants.settingsSubsection.about,
            text: qsTr("About"),
            icon: "info",
            group: root.aboutAndHelpGroupTitle
        },
        {
            subsection: Constants.settingsSubsection.signout,
            text: qsTr("Sign out & Quit"),
            icon: "logout",
            group: root.aboutAndHelpGroupTitle
        }
    ]

    // Update model after retranslation
    onEntriesChanged: {
        entries.forEach((elem, index) => {
            baseModel.setProperty(index, "text", elem.text)

            if (elem.group)
                baseModel.setProperty(index, "group", elem.group)
        })
    }

    function getNameForSubsection(subsection) {
        const entry = root.entries.find(entry => entry.subsection === subsection)
        return entry ? entry.text : ""
    }

    sourceModel: ObjectProxyModel {
        sourceModel: ListModel {
            id: baseModel

            Component.onCompleted: append(root.entries)
        }

        delegate: QtObject {
            readonly property bool visible: {
                switch (model.subsection) {
                    case Constants.settingsSubsection.ensUsernames:
                    case Constants.settingsSubsection.wallet:
                        return root.showWalletEntries
                    case Constants.settingsSubsection.backUpSeed:
                        return root.showBackUpSeed

                    default: return true
                }
            }

            readonly property int badgeCount: {
                switch (model.subsection) {
                    case Constants.settingsSubsection.backUpSeed:
                        return root.showBackUpSeed
                    case Constants.settingsSubsection.syncingSettings:
                        return root.syncingBadgeCount
                    case Constants.settingsSubsection.messaging:
                        return root.messagingBadgeCount

                    default: return 0
                }
            }
        }

        expectedRoles: ["subsection"]
        exposedRoles: ["visible", "badgeCount"]
    }

    filters: ValueFilter {
        roleName: "visible"
        value: true
    }
}
