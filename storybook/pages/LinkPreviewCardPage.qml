import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

import StatusQ.Core.Theme 0.1

import shared.controls.chat 1.0
import utils 1.0


SplitView {
    id: root

    property string ytBannerQuality: "hqdefault"
    property string image: Style.png("tokens/SOCKS")
    property string banner: rawImageCheck.checked ? rawImageCheck.rawImageData : "https://img.youtube.com/vi/yHN1M7vcPKU/%1.jpg".arg(root.ytBannerQuality)
    property bool globalUtilsReady: false

    // globalUtilsInst mock
    QtObject {
        function getEmojiHashAsJson(publicKey) {
            return JSON.stringify(["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"])
        }
        function getColorId(publicKey) { return 4 }

        function getCompressedPk(publicKey) { return "zx3sh" + publicKey }

        function getColorHashAsJson(publicKey) {
            return JSON.stringify([{4: 0, segmentLength: 1},
                                   {5: 19, segmentLength: 2}])
        }

        function isCompressedPubKey(publicKey) { return true }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
            root.globalUtilsReady = true

        }
        Component.onDestruction: {
            root.globalUtilsReady = false
            Utils.globalUtilsInst = {}
        }
    }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        
        LinkPreviewCard {
            id: previewCard
            type: 1
            linkData {
                title: titleInput.text
                description: descriptionInput.text
                domain: footerInput.text
                thumbnail: root.banner
                image: root.image
            }
            userData {
                name: userNameInput.text
                publicKey: "zQ3shgmVJjmwwhkfAemjDizYJtv9nzot7QD4iRJ52ZkgdU6Ci"
                bio: bioInput.text
                image: root.image
                ensVerified: false
            }
            communityData {
                name: titleInput.text
                description: descriptionInput.text
                banner: root.banner
                image: root.image
                membersCount: parseInt(membersCountInput.text)
                activeMembersCount: parseInt(activeMembersCountInput.text)
                color: "orchid"
            }
            channelData {
                name: titleInput.text
                description: descriptionInput.text
                emoji: ""
                color: "blue"
                communityData {
                    name: "Community" + titleInput.text
                    description: "Community" + descriptionInput.text
                    banner: root.banner
                    image: root.image
                    membersCount: parseInt(membersCountInput.text)
                    activeMembersCount: parseInt(activeMembersCountInput.text)
                    color: "orchid"
                }
            }
        }
    }
        

    ScrollView {
        SplitView.preferredWidth: 500
        SplitView.fillHeight: true
        leftPadding: 10
        ColumnLayout {
            id: layout
            spacing: 24
            ColumnLayout {
                Label {
                    Layout.fillWidth: true
                    text: "Card type"
                }

                RadioButton {
                    text: qsTr("Link")
                    checked: previewCard.type === Constants.LinkPreviewType.Standard
                    onToggled: previewCard.type = Constants.LinkPreviewType.Standard
                }

                RadioButton {
                    text: qsTr("Contact")
                    checked: previewCard.type === Constants.LinkPreviewType.StatusContact
                    onToggled: previewCard.type = Constants.LinkPreviewType.StatusContact
                }

                RadioButton {
                    text: qsTr("Community")
                    checked: previewCard.type === Constants.LinkPreviewType.StatusCommunity
                    onToggled: {
                        previewCard.type = Constants.LinkPreviewType.StatusCommunity
                        titleInput.text = "Socks"
                        descriptionInput.text = "Community description goes here. If blank it will enable multi line title."
                    }
                }

                RadioButton {
                    text: qsTr("Channel")
                    checked: previewCard.type === Constants.LinkPreviewType.StatusCommunityChannel
                    onToggled: {
                        previewCard.type = Constants.LinkPreviewType.StatusCommunityChannel
                        titleInput.text = "general"
                        descriptionInput.text = "Channel description goes here. If blank it will enable multi line title."
                    }
                }
            }
            ColumnLayout {
                visible: previewCard.type !== Constants.LinkPreviewType.StatusContact
                Label {
                    text: "Title"
                }

                TextField {
                    id: titleInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "What Is Web3? A Decentralized Internet Via Blockchain Technology That Will Revolutionise All Sectors- Decrypt (@decryptmedia) August 31 2021"
                }

                Label {
                    text: "Description"
                }
                RowLayout {
                    TextField {
                        id: descriptionInput
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: "Link description goes here. If blank it will enable multi line title."
                    }
                    Button {
                        text: "clear"
                        onClicked: descriptionInput.text = ""
                    }
                    Button {
                        text: "Set"
                        onClicked: descriptionInput.text = "Link description goes here. If blank it will enable multi line title."
                    }
                }
                ColumnLayout {
                    visible: previewCard.type === Constants.LinkPreviewType.Standard
                    Label {
                        text: "Footer"
                    }

                    TextField {
                        id: footerInput
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: "X"
                    }
                }

                ColumnLayout {
                    visible: previewCard.type === Constants.LinkPreviewType.StatusCommunity
                    Label {
                        text: "MembersCount"
                    }
                    TextField {
                        id: membersCountInput
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        text: "629200"
                    }
                    TextField {
                        id: activeMembersCountInput
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        text: "112100"
                    }
                }
            }

            ColumnLayout {
                visible: previewCard.type === Constants.LinkPreviewType.StatusContact
                Label {
                    text: "User name"
                }

                TextField {
                    id: userNameInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "Test user name"
                }

                Label {
                    text: "Bio"
                }
                RowLayout {
                    TextField {
                        id: bioInput
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: "User bio description goes here. If blank it will enable multi line title."
                    }
                    Button {
                        text: "clear"
                        onClicked: bioInput.text = ""
                    }
                    Button {
                        text: "Set"
                        onClicked: bioInput.text = "User bio description goes here. If blank it will enable multi line title."
                    }
                }
            }

            ColumnLayout {
                visible: previewCard.type === Constants.LinkPreviewType.StatusCommunityChannel
                Label {
                    Layout.fillWidth: true
                    text: "channel settings"
                }
                CheckBox {
                    text: qsTr("Emoji")
                    checked: previewCard.channelData.emoji === "👋"
                    onToggled: previewCard.channelData.emoji = checked ? "👋" : ""
                }
                RadioButton {
                    text: qsTr("Blue channel color")
                    checked: previewCard.channelData.color === "blue"
                    onToggled: previewCard.channelData.color = "blue"
                }
                RadioButton {
                    text: qsTr("Red channel color")
                    checked: previewCard.channelData.color === "red"
                    onToggled: previewCard.channelData.color = "red"
                }
            }

            Label {
                Layout.fillWidth: true
                text: "Logo"
            }

            RadioButton {
                text: qsTr("no image")
                checked: root.image === ""
                onToggled: root.image = ""
            }

            RadioButton {
                readonly property string rawImageData: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB0AAAAcCAYAAACdz7SqAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAM2SURBVHgBtVbNbtNAEJ7ZpBQ4pRGF9kQqWqkBRNwnwLlxI9y4NX2CiiOntE9QeINw49a8QdwT3NhKQCKaSj4WUVXmABRqe5hxE+PGTuyk5ZOSXe/ftzs/3y5CBiw/NEzw/cdAaCJAifgXdCA4QGAjggbEvbMf0LJt7aSth6lkHjW4akIG8GI2/1k5H7e7XW2PGRdHqWQU8jdoNytZIrnC7YNPupnUnxtuWF01SjhD77hqwPQosNlrxdt34OTb172xpELoKvrA1QW4EqCZRJyLEnpI7ZBQggThlGvXYVLI3HAeE88vfj85Pno/6FaDiqeoEUZlMA9bvc/7cxyxVa6/SeM5j2Tcdn/hnHsNly520s7KAyN0V17+7pWNGhHVhxYJTNLraosLi8e0kMBxT0FH00IW830oeT/ButBertjRQ5BPO1xUQ1IE2oQUHHZ0K6mdI1RzoSEdpqRg76O2lPgSElKDdz919JYMoxA95QDow7qUykWoxTo5z2YIXsGUsLV2CPD1cDu7MODiQKKnsVmI1jhFyQJvFrb6URxFQWJAYYIZSEF6tKZATitFQpehEm1PkCraWYCE+8Nt5ENBwX8EAd2NNaKQxu0ukVuCqwATQHwnjhphShMuiSAVKZ527E6bzYt78Q3SulxvcAm44K8ntXMqagmkJDUpzNwMZGsqBDqLuDXcLvkvqajcWWgm+ZUI6svlym5fsbITlh9tsgi0Ezs5//vkMtBocqSJOZw84ZrHPiXFJ6UwECx5A/FbqNXX2hAiefkzqCNRha1Wi8yJgddeCk4qHzkK1aMgdypfshYRbkTGm3z0Rs6LW0REgDXVEMuMI0TE5kDlgkv8+PjIKRYXfzPxEyH2EYzDzv7L4q1FHsvpg8Gkt186OlGp5uYXZMjzkYS8txwfQnj63//APmzDIF1yWJVrCDJgeZVfjTjCj0KicC3qlny0053FZ/k/PFnyy6P2yv1Kk1T/1eCGF/pEYCncGI6DCzIo/uGnRvg8CfzE5MEPoQGT4Pz5Uj3oxp+hMe0V4oOOrssOMfmWyMJo5X1cG2WZkYIvO2Tn85sGXwg5B5Q9kiKMas5DntPr6Oq4+/gvs8hkkbAzoC8AAAAASUVORK5CYII="
                text: qsTr("Raw image")
                checked: root.image === rawImageData
                onToggled: root.image = rawImageData
            }

            RadioButton {
                text: qsTr("QRC asset: SOCKS")
                checked: root.image === Style.png("tokens/SOCKS")
                onToggled: root.image = Style.png("tokens/SOCKS")
            }

            ColumnLayout {
                visible: previewCard.type !== Constants.LinkPreviewType.StatusContact
                Label {
                    Layout.fillWidth: true
                    text: "Banner size"
                }
                RadioButton {
                    text: qsTr("Low (120x90)")
                    checked: ytBannerQuality === "default"
                    onToggled: ytBannerQuality = "default"
                }
                RadioButton {
                    text: qsTr("Medium(320x180)")
                    checked: ytBannerQuality === "mqdefault"
                    onToggled: ytBannerQuality = "mqdefault"
                }
                RadioButton {
                    text: qsTr("High(480x360)")
                    checked: ytBannerQuality === "hqdefault"
                    onToggled: ytBannerQuality = "hqdefault"
                }
            }

            CheckBox {
                id: rawImageCheck
                readonly property string rawImageData: "data:image/jpeg;base64,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"
                text: qsTr("Raw image banner")
                checked: root.banner === rawImageData
            }

            ColumnLayout {
                Label {
                    Layout.fillWidth: true
                    text: "UserName"
                }
            }

            ColumnLayout {
                Label {
                    Layout.fillWidth: true
                    text: "Tail position"
                }
                RadioButton {
                    text: qsTr("Left")
                    checked: previewCard.leftTail === true
                    onToggled: previewCard.leftTail = true
                }
                RadioButton {
                    text: qsTr("Right")
                    checked: previewCard.leftTail === false
                    onToggled: previewCard.leftTail = false
                }
            }
        }
    }

    Settings {
        property alias linkType: previewCard.type
    }
}

// category: Controls

// https://www.figma.com/file/Mr3rqxxgKJ2zMQ06UAKiWL/💬-Chat⎜Desktop?type=design&node-id=22347-219545&mode=design&t=bODv5MUGQgU9ThJF-0
