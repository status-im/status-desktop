import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

Column {
    spacing: 20

    StatusButton {
        text: "Simple modal"
        onClicked: simpleModal.open()
    }

    StatusButton {
        text: "Simple title modal"
        onClicked: simpleTitleModal.open()
    }

    StatusButton {
        text: "Modal with header image"
        onClicked: headerImageModal.open()
    }

    StatusButton {
        text: "Modal with footer buttons"
        onClicked: footerButtonsModal.open()
    }

    StatusButton {
        text: "Modal with header action button"
        onClicked: headerActionButtonModal.open()
    }

    StatusButton {
        text: "Modal with content"
        onClicked: modalExample.open()
    }

    StatusButton {
        text: "Modal with changable content"
        onClicked: modalWithContentAccess.open()
    }

    StatusButton {
        text: "Modal with letter identicon"
        onClicked: modalWithLetterIdenticon.open()
    }

    StatusButton {
        text: "Modal with identicon"
        onClicked: modalWithIdenticon.open()
    }

    StatusButton {
        text: "Modal with long titles"
        onClicked: modalWithLongTitles.open()
    }

    StatusButton {
        text: "Modal with Header Popup Menu"
        onClicked: modalWithHeaderPopupMenu.open()
    }

    StatusModal {
        id: simpleModal
        anchors.centerIn: parent
        header.title: "Some Title"
        header.subTitle: "Subtitle"
    }

    StatusModal {
        id: simpleTitleModal
        anchors.centerIn: parent
        header.title: "Some Title"
    }

    StatusModal {
        id: headerImageModal
        anchors.centerIn: parent
        header.title: "Some Title"
        header.subTitle: "Subtitle"
        header.image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
    }

    StatusModal {
        id: footerButtonsModal
        anchors.centerIn: parent
        header.title: "Some Title"
        header.subTitle: "Subtitle"
        header.image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
        leftButtons: [
            StatusRoundButton {
                icon.name: "arrow-right"
                rotation: 180
            }
        ]
        rightButtons: [
            StatusButton {
                text: "Button"
            },
            StatusButton {
                text: "Button"
            }
        ]
    }

    StatusModal {
        id: headerActionButtonModal
        anchors.centerIn: parent
        header.title: "Some Title"
        header.subTitle: "Subtitle"
        header.image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"

        headerActionButton: StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Secondary
            width: 32
            height: 32

            icon.width: 20
            icon.height: 20
            icon.name: "info"
        }

        leftButtons: [
            StatusRoundButton {
                icon.name: "arrow-right"
                rotation: 180
            }
        ]
        rightButtons: [
            StatusButton {
                text: "Button"
            },
            StatusButton {
                text: "Button"
            }
        ]
    }

    StatusModal {
        id: modalExample
        anchors.centerIn: parent
        header.image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
        header.title: "Header"
        header.subTitle: "SubTitle"
        rightButtons: [
            StatusButton {
                text: "Button"
            },
            StatusButton {
                text: "Button"
            }
        ]

        leftButtons: [
            StatusRoundButton {
                icon.name: "arrow-right"
                rotation: 180
            }
        ]

        contentItem: StatusBaseText {
            anchors.centerIn: parent
            text: "Some text content"
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }

        headerActionButton: StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Secondary
            width: 32
            height: 32

            icon.width: 20
            icon.height: 20
            icon.name: "info"
        }
    }

    StatusModal {
        id: modalWithContentAccess
        anchors.centerIn: parent
        header.title: "Header"
        header.subTitle: "SubTitle"

        contentItem: StatusBaseText {
            id: text
            anchors.centerIn: parent
            text: "Some text content"
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }

        rightButtons: [
            StatusButton {
                text: "Change text"
                onClicked: {
                    modalWithContentAccess.contentItem.text = "Changed!"
                }
            }
        ]
    }

    StatusModal {
        id: modalWithLetterIdenticon
        anchors.centerIn: parent
        header.title: "Header"
        header.subTitle: "SubTitle"
        header.icon.isLetterIdenticon: true
        header.icon.background.color: "red"

        contentItem: StatusBaseText {
            anchors.centerIn: parent
            text: "Some text content"
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }

        rightButtons: [
            StatusButton {
                text: "Change text"
                onClicked: {
                    modalWithLetterIdenticon.contentItem.text = "Changed!"
                }
            }
        ]
    }

    StatusModal {
        id: modalWithIdenticon
        anchors.centerIn: parent
        header.title: "Header"
        header.subTitle: "SubTitle"
        header.image.source: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0Bh
CExPynn1gWf9bx498P7/nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
        header.image.isIdenticon: true

        contentItem: StatusBaseText {
            anchors.centerIn: parent
            text: "Some text content"
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }

        rightButtons: [
            StatusButton {
                text: "Change text"
                onClicked: {
                    modalWithIdenticon.contentItem.text = "Changed!"
                }
            }
        ]
    }

    StatusModal {
        id: modalWithLongTitles
        anchors.centerIn: parent
        header.title: "Some super long text here that exceeds the available space"
        header.subTitle: "Some super long text here that exceeds the available space"
        header.subTitleElide: Text.ElideMiddle
        header.image.source: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0Bh
CExPynn1gWf9bx498P7/nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
        header.image.isIdenticon: true

        contentItem: StatusBaseText {
            anchors.centerIn: parent
            text: "Some text content"
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }

        rightButtons: [
            StatusButton {
                text: "Change text"
                onClicked: {
                    modalWithLongTitles.contentItem.text = "Changed!"
                }
            }
        ]
    }

    StatusModal {
        id: modalWithHeaderPopupMenu
        anchors.centerIn: parent
        header.title: "helloworld.eth"
        header.subTitle: "Basic address"
        header.popupMenu: StatusPopupMenu {
            id: popupMenu
            Repeater {
                model: dummyAccountsModel
                delegate: Loader {
                    sourceComponent: popupMenu.delegate
                    onLoaded: {
                        item.action.text = model.name
                        item.action.iconSettings.name = model.iconName
                    }
                }
            }
            onMenuItemClicked: {
                popupMenu.dismiss()
            }
        }
    }

    ListModel {
        id: dummyAccountsModel
        ListElement{name: "Account 1"; iconName: "filled-account"}
        ListElement{name: "Account 2"; iconName: "filled-account"}
    }
}
