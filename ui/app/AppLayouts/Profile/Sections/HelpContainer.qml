import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

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
            anchors.topMargin: 24
            anchors.right: parent.right
            anchors.rightMargin: contentMargin
            anchors.left: parent.left
            anchors.leftMargin: contentMargin
            height: this.childrenRect.height

            StyledText {
                id: glossaryTitle
                text: qsTr("Glossary")
                anchors.left: parent.left
                anchors.top: parent.top
                font.pixelSize: 15
                color: Style.current.secondaryText
            }

            GlossaryEntry {
                id: entryAccount
                anchors.top: glossaryTitle.bottom
                anchors.topMargin: Style.current.padding
                name: qsTr("Account")
                letter: qsTr("A")
                description: qsTr("Your Status account, accessed by the seed phrase that you create or import during onboarding. A Status account can hold more than one Ethereum address, in addition to the one created during onboarding. We refer to these as additional accounts within the wallet")
            }

            GlossaryEntry {
                id: entryChatKey
                anchors.top: entryAccount.bottom
                anchors.topMargin: Style.current.padding
                name: qsTr("Chat Key")
                letter: qsTr("C")
                description: qsTr("Messages on the Status chat protocol are sent and received using encryption keys. The public chat key is a string of characters you share with others so they can send you messages in Status.")
            }

            GlossaryEntry {
                id: entryChatName
                anchors.top: entryChatKey.bottom
                anchors.topMargin: Style.current.padding
                name: qsTr("Chat Name")
                description: qsTr("Three random words, derived algorithmically from your chat key and used as your default alias in chat. Chat names are completely unique; no other user can have the same three words.")
            }

            GlossaryEntry {
                id: entryENSName
                anchors.top: entryChatName.bottom
                anchors.topMargin: Style.current.padding
                name: qsTr("ENS Name")
                letter: qsTr("E")
                description: qsTr("Custom alias for your chat key that you can register using the Ethereum Name Service. ENS names are decentralized usernames.")
            }

            GlossaryEntry {
                id: entryMailserver
                letter: qsTr("M")
                anchors.top: entryENSName.bottom
                anchors.topMargin: Style.current.padding
                name: qsTr("Mailserver")
                description: qsTr("A node in the Status network that routes and stores messages, for up to 30 days.")
            }

            GlossaryEntry {
                id: entryPeer
                anchors.top: entryMailserver.bottom
                anchors.topMargin: Style.current.padding
                name: qsTr("Peer")
                letter: qsTr("P")
                description: qsTr("A device connected to the Status chat network. Each user can represent one or more peers, depending on their number of devices")
            }

            GlossaryEntry {
                id: entrySeedPhrase
                anchors.top: entryPeer.bottom
                anchors.topMargin: Style.current.padding
                name: qsTr("Seed Phrase")
                letter: qsTr("S")
                description: qsTr("A 64 character hex address based on the Ethereum standard and beginning with 0x. Public-facing, your wallet key is shared with others when you want to receive funds. Also referred to as an “Ethereum address” or “wallet address.")
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
                text: qsTr("<a href='https://status.im/docs/FAQs.html'>Frequently asked questions</a>")
                font.pixelSize: 15
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
                text: qsTr("<a href='https://github.com/status-im/nim-status-client/issues/new'>Submit a bug</a>")
                anchors.topMargin: Style.current.bigPadding
                anchors.top: faqLink.bottom
                font.pixelSize: 15
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
                text: qsTr("<a href='https://discuss.status.im/c/features/51'>Request a feature</a>")
                anchors.topMargin: Style.current.bigPadding
                anchors.top: issueLink.bottom
                font.pixelSize: 15
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

