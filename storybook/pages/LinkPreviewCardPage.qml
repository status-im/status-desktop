import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1

import shared.controls.chat 1.0
import utils 1.0

SplitView {
    id: root

    property alias logoSettings: previewCard.logoSettings
    property string ytBannerQuality: "hqdefault"

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        LinkPreviewCard {
            id: previewCard
            bannerImageSource: "https://img.youtube.com/vi/yHN1M7vcPKU/%1.jpg".arg(root.ytBannerQuality)
            title: titleInput.text
            description: descriptionInput.text
            footer: footerInput.text
            logoSettings.name: Style.png("tokens/SOCKS")
            logoSettings.isImage: true
            logoSettings.isLetterIdenticon: false
        }
    }

    Pane {
        SplitView.preferredWidth: 500
        SplitView.fillHeight: true
        ColumnLayout {
            spacing: 24
            ColumnLayout {
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

                Label {
                    text: "Footer"
                }

                TextField {
                    id: footerInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: footerTypeCommunity.footerRichText
                }
            }
            ColumnLayout {
                Label {
                    Layout.fillWidth: true
                    text: "Logo"
                }

                RadioButton {
                    text: qsTr("No logo")
                    checked: root.logoSettings.name === "" && root.logoSettings.emoji === ""
                    onToggled: {
                        root.logoSettings.name = ""
                        root.logoSettings.emoji = ""
                        root.logoSettings.isImage = false
                        root.logoSettings.isLetterIdenticon = false
                    }
                }

                RadioButton {
                    readonly property string rawImageData: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB0AAAAcCAYAAACdz7SqAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAM2SURBVHgBtVbNbtNAEJ7ZpBQ4pRGF9kQqWqkBRNwnwLlxI9y4NX2CiiOntE9QeINw49a8QdwT3NhKQCKaSj4WUVXmABRqe5hxE+PGTuyk5ZOSXe/ftzs/3y5CBiw/NEzw/cdAaCJAifgXdCA4QGAjggbEvbMf0LJt7aSth6lkHjW4akIG8GI2/1k5H7e7XW2PGRdHqWQU8jdoNytZIrnC7YNPupnUnxtuWF01SjhD77hqwPQosNlrxdt34OTb172xpELoKvrA1QW4EqCZRJyLEnpI7ZBQggThlGvXYVLI3HAeE88vfj85Pno/6FaDiqeoEUZlMA9bvc/7cxyxVa6/SeM5j2Tcdn/hnHsNly520s7KAyN0V17+7pWNGhHVhxYJTNLraosLi8e0kMBxT0FH00IW830oeT/ButBertjRQ5BPO1xUQ1IE2oQUHHZ0K6mdI1RzoSEdpqRg76O2lPgSElKDdz919JYMoxA95QDow7qUykWoxTo5z2YIXsGUsLV2CPD1cDu7MODiQKKnsVmI1jhFyQJvFrb6URxFQWJAYYIZSEF6tKZATitFQpehEm1PkCraWYCE+8Nt5ENBwX8EAd2NNaKQxu0ukVuCqwATQHwnjhphShMuiSAVKZ527E6bzYt78Q3SulxvcAm44K8ntXMqagmkJDUpzNwMZGsqBDqLuDXcLvkvqajcWWgm+ZUI6svlym5fsbITlh9tsgi0Ezs5//vkMtBocqSJOZw84ZrHPiXFJ6UwECx5A/FbqNXX2hAiefkzqCNRha1Wi8yJgddeCk4qHzkK1aMgdypfshYRbkTGm3z0Rs6LW0REgDXVEMuMI0TE5kDlgkv8+PjIKRYXfzPxEyH2EYzDzv7L4q1FHsvpg8Gkt186OlGp5uYXZMjzkYS8txwfQnj63//APmzDIF1yWJVrCDJgeZVfjTjCj0KicC3qlny0053FZ/k/PFnyy6P2yv1Kk1T/1eCGF/pEYCncGI6DCzIo/uGnRvg8CfzE5MEPoQGT4Pz5Uj3oxp+hMe0V4oOOrssOMfmWyMJo5X1cG2WZkYIvO2Tn85sGXwg5B5Q9kiKMas5DntPr6Oq4+/gvs8hkkbAzoC8AAAAASUVORK5CYII="
                    text: qsTr("Raw image")
                    checked: root.logoSettings.name === rawImageData
                    onToggled: {
                            root.logoSettings.name = rawImageData
                            root.logoSettings.isImage = true
                            root.logoSettings.isLetterIdenticon = false
                    }
                }

                RadioButton {
                    text: qsTr("QRC asset: SOCKS")
                    checked: root.logoSettings.name = Style.png("tokens/SOCKS")
                    onToggled:{
                        root.logoSettings.name = Style.png("tokens/SOCKS")
                        root.logoSettings.isImage = true
                        root.logoSettings.isLetterIdenticon = false
                    }
                }
                RadioButton {
                    text: qsTr("Letter identicon")
                    checked: root.logoSettings.name = "github.com"
                    onToggled: {
                        root.logoSettings.name = "github.com"
                        root.logoSettings.emoji = ""
                        root.logoSettings.isLetterIdenticon = true
                        root.logoSettings.color = "blue"
                    }
                }
                RadioButton {
                    text: qsTr("Emoji")
                    checked: root.logoSettings.emoji === "👋"
                    onToggled: {
                        root.logoSettings.emoji = "👋"
                        root.logoSettings.isLetterIdenticon = true
                        root.logoSettings.color = "orchid"
                    }
                }
            }

            ColumnLayout {
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

            ColumnLayout {
                Label {
                    Layout.fillWidth: true
                    text: "Footer type"
                }
                RadioButton {
                    id: footerTypeCommunity
                    property string footerRichText: `<img src="%1" width="16" height="16" style="vertical-align: top" ></img><font color="%2"> 629.2K </font> <img src="%3" width="16" height="16" style="vertical-align: top" ><font color="%2">112.1K</font>`.arg(Style.svg("group")).arg(Theme.palette.directColor1).arg(Style.svg("active-members"))
                    text: qsTr("Community")
                    checked: footerInput.text === footerRichText
                    onToggled: footerInput.text = footerRichText
                }
                RadioButton {
                    property string footerRichText: `%1 <img src="%2" width="16" height="16" style="vertical-align: top" ><font color="%2"> %3</font>`.arg(qsTr("Channel in")).arg(Style.png("tokens/SOCKS")).arg(qsTr("Doodles"))
                    text: qsTr("Channel")
                    checked: footerInput.text === footerRichText
                    onToggled: footerInput.text = footerRichText
                }
                RadioButton {
                    text: qsTr("Link domain")
                    property string footerText: "X"
                    checked: footerInput.text === footerText
                    onToggled: footerInput.text = footerText
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
}
