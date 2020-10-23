import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "Privileges/"

Item {
    id: privacyContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    ListModel {
        id: previewableSites
    }

    Component.onCompleted: {
        const sites = profileModel.getLinkPreviewWhitelist()
        try {
            const sitesJSON = JSON.parse(sites)
            sitesJSON.forEach(function (site) {
                previewableSites.append(site)
            })
        } catch (e) {
            console.error(e)
        }
    }

    property Component dappListPopup: DappList {
        onClosed: destroy()
    }


    Column {
        id: containerColumn
        spacing: Style.current.padding
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: contentMargin
        anchors.left: parent.left
        anchors.leftMargin: contentMargin
        anchors.bottom: parent.bottom

        StatusSectionHeadline {
            id: labelSecurity
            //% "Security"
            text: qsTrId("security")
        }

        Item {
            id: backupSeedPhrase
            height: backupText.height
            width: parent.width

            StyledText {
                id: backupText
                //% "Backup Seed Phrase"
                text: qsTrId("backup-seed-phrase")
                font.pixelSize: 15
                color: !badge.visible ? Style.current.darkGrey : Style.current.textColor
            }

            Rectangle {
                id: badge
                visible: !profileModel.isMnemonicBackedUp
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 0
                radius: 9
                color: Style.current.blue
                width: 18
                height: 18
                Text {
                    font.pixelSize: 12
                    color: Style.current.white
                    anchors.centerIn: parent
                    text: "1"
                }
            }

            MouseArea {
                enabled: !profileModel.isMnemonicBackedUp
                anchors.fill: parent
                onClicked: backupSeedModal.open()
                cursorShape: enabled && Qt.PointingHandCursor
            }
        }

        BackupSeedModal {
            id: backupSeedModal
        }

        Separator {
            id: separator
            Layout.topMargin: Style.current.bigPadding - containerColumn.spacing
        }

        Item {
            id: dappPermissions
            height: dappPermissionsText.height
            width: parent.width

            StyledText {
                id: dappPermissionsText
                text: qsTr("Set DApp access permissions")
                font.pixelSize: 15
            }

            SVGImage {
                id: caret2
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.verticalCenter: dappPermissionsText.verticalCenter
                source: "../../../img/caret.svg"
                width: 13
                height: 7
                rotation: -90
            }
            
            ColorOverlay {
                anchors.fill: caret2
                source: caret2
                color: Style.current.darkGrey
                rotation: -90
            }

            MouseArea {
                anchors.fill: parent
                onClicked: dappListPopup.createObject(privacyContainer).open()
                cursorShape: Qt.PointingHandCursor
            }
        }

        Separator {
            id: separator2
            Layout.topMargin: Style.current.bigPadding - containerColumn.spacing
        }

        StatusSectionHeadline {
            id: labelPrivacy
            //% "Privacy"
            text: qsTrId("privacy")
        }

        RowLayout {
            id: displayImageSettings
            StyledText {
                //% "Display images in chat automatically"
                text: qsTrId("display-images-in-chat-automatically")
            }
            StatusSwitch {
                checked: appSettings.displayChatImages
                onCheckedChanged: function (value) {
                    appSettings.displayChatImages = this.checked
                }
            }
            StyledText {
                //% "under development"
                text: qsTrId("under-development")
            }
        }

        StatusSectionHeadline {
            id: labelURLUnfurling
            text: qsTr("URL Previews")
        }

        ListView {
            id: sitesListView
            width: parent.width
            model: previewableSites
            interactive: false
            height: childrenRect.height

            delegate: Component {
                RowLayout {
                    id: displayYoutubeSettings
                    StyledText {
                        text: qsTr("Display %1 previews").arg(title)
                    }
                    StatusSwitch {
                        checked: !!appSettings.whitelistedUnfurlingSites[address]
                        onCheckedChanged: function () {
                            appSettings.whitelistedUnfurlingSites[address] = this.checked
                        }
                    }
                    StyledText {
                        //% "under development"
                        text: qsTrId("under-development")
                    }
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
