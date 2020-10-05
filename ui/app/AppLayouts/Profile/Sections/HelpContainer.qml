import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
    id: helpContainer
    height: parent.height
    Layout.fillWidth: true


    ScrollView {
        height: parent.height
        width: parent.width
        contentHeight: glossary.height + linksSection.height + Style.current.bigPadding * 4
        clip: true
        Item {
            id: glossary
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: contentMargin
            anchors.left: parent.left
            anchors.leftMargin: contentMargin
            height: this.childrenRect.height

            StatusSectionHeadline {
                id: glossaryTitle
                //% "Glossary"
                text: qsTrId("glossary")
                anchors.left: parent.left
                anchors.top: parent.top
            }

            GlossaryEntry {
                id: entryAccount
                anchors.top: glossaryTitle.bottom
                anchors.topMargin: Style.current.padding
                //% "Account"
                name: qsTrId("account-title")
                //% "A"
                letter: qsTrId("a")
                //% "Your Status account, accessed by the seed phrase that you create or import during onboarding. A Status account can hold more than one Ethereum address, in addition to the one created during onboarding. We refer to these as additional accounts within the wallet"
                description: qsTrId("your-status-account--accessed-by-the-seed-phrase-that-you-create-or-import-during-onboarding--a-status-account-can-hold-more-than-one-ethereum-address--in-addition-to-the-one-created-during-onboarding--we-refer-to-these-as-additional-accounts-within-the-wallet")
            }

            GlossaryEntry {
                id: entryChatKey
                anchors.top: entryAccount.bottom
                anchors.topMargin: Style.current.padding
                //% "Chat Key"
                name: qsTrId("chat-key-title")
                //% "C"
                letter: qsTrId("c")
                //% "Messages on the Status chat protocol are sent and received using encryption keys. The public chat key is a string of characters you share with others so they can send you messages in Status."
                description: qsTrId("chat-key-content")
            }

            GlossaryEntry {
                id: entryChatName
                anchors.top: entryChatKey.bottom
                anchors.topMargin: Style.current.padding
                //% "Chat Name"
                name: qsTrId("chat-name-title")
                //% "Three random words, derived algorithmically from your chat key and used as your default alias in chat. Chat names are completely unique; no other user can have the same three words."
                description: qsTrId("chat-name-content")
            }

            GlossaryEntry {
                id: entryENSName
                anchors.top: entryChatName.bottom
                anchors.topMargin: Style.current.padding
                //% "ENS Name"
                name: qsTrId("ens-name-title")
                //% "E"
                letter: qsTrId("e")
                //% "Custom alias for your chat key that you can register using the Ethereum Name Service. ENS names are decentralized usernames."
                description: qsTrId("ens-name-content")
            }

            GlossaryEntry {
                id: entryMailserver
                //% "M"
                letter: qsTrId("m")
                anchors.top: entryENSName.bottom
                anchors.topMargin: Style.current.padding
                //% "Mailserver"
                name: qsTrId("mailserver-title")
                //% "A node in the Status network that routes and stores messages, for up to 30 days."
                description: qsTrId("mailserver-content")
            }

            GlossaryEntry {
                id: entryPeer
                anchors.top: entryMailserver.bottom
                anchors.topMargin: Style.current.padding
                //% "Peer"
                name: qsTrId("peer-title")
                //% "P"
                letter: qsTrId("p")
                //% "A device connected to the Status chat network. Each user can represent one or more peers, depending on their number of devices"
                description: qsTrId("a-device-connected-to-the-status-chat-network--each-user-can-represent-one-or-more-peers--depending-on-their-number-of-devices")
            }

            GlossaryEntry {
                id: entrySeedPhrase
                anchors.top: entryPeer.bottom
                anchors.topMargin: Style.current.padding
                //% "Seed Phrase"
                name: qsTrId("seed-phrase-title")
                //% "S"
                letter: qsTrId("s")
                //% "A 64 character hex address based on the Ethereum standard and beginning with 0x. Public-facing, your wallet key is shared with others when you want to receive funds. Also referred to as an “Ethereum address” or “wallet address."
                description: qsTrId("a-64-character-hex-address-based-on-the-ethereum-standard-and-beginning-with-0x--public-facing--your-wallet-key-is-shared-with-others-when-you-want-to-receive-funds--also-referred-to-as-an--ethereum-address--or--wallet-address-")
            }
        }


        Item {
            id: linksSection
            anchors.top: glossary.bottom
            anchors.topMargin: Style.current.bigPadding * 2
            anchors.left: parent.left
            anchors.leftMargin: contentMargin
            anchors.right: parent.left
            anchors.rightMargin: contentMargin
            height: this.childrenRect.height

            StyledText {
                id: faqLink
                //% "<a href='https://status.im/docs/FAQs.html'>Frequently asked questions</a>"
                text: qsTrId("-a-href--https---status-im-docs-faqs-html--frequently-asked-questions--a-")
                font.pixelSize: Style.current.primaryTextFontSize
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mouse.accepted = false
                        Qt.openUrlExternally("https://status.im/faq/")
                    }
                }
            }

            StyledText {
                id: issueLink
                //% "<a href='https://github.com/status-im/nim-status-client/issues/new'>Submit a bug</a>"
                text: qsTrId("-a-href--https---github-com-status-im-nim-status-client-issues-new--submit-a-bug--a-")
                anchors.topMargin: Style.current.bigPadding
                anchors.top: faqLink.bottom
                font.pixelSize: Style.current.primaryTextFontSize
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mouse.accepted = false
                        Qt.openUrlExternally("https://github.com/status-im/nim-status-client/issues/new")
                    }
                }
            }

            StyledText {
                //% "<a href='https://discuss.status.im/c/features/51'>Request a feature</a>"
                text: qsTrId("-a-href--https---discuss-status-im-c-features-51--request-a-feature--a-")
                anchors.topMargin: Style.current.bigPadding
                anchors.top: issueLink.bottom
                font.pixelSize: Style.current.primaryTextFontSize
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mouse.accepted = false
                        Qt.openUrlExternally("https://discuss.status.im/c/features/51")
                    }
                }
            }
        }
    }
}

