import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

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
        text: "Modal with editable identicon"
        onClicked: modalWithEditableIdenticon.open()
    }

    StatusButton {
        text: "Modal with long titles"
        onClicked: modalWithLongTitles.open()
    }

    StatusButton {
        text: "Modal with Header Popup Menu"
        onClicked: modalWithHeaderPopupMenu.open()
    }

    StatusButton {
        text: "Modal with Editable Title"
        onClicked: editTitleModal.open()
    }

    StatusButton {
        text: "Modal with Advanced Header/Footer"
        onClicked: advancedHeaderFooterModal.open()
    }


    StatusButton {
        text: "Modal with Floating header Buttons"
        onClicked: floatingHeaderModal.open()
    }

    StatusModal {
        id: simpleModal
        anchors.centerIn: parent
        headerSettings.title: "Some Title"
        headerSettings.subTitle: "Subtitle"
    }

    StatusModal {
        id: simpleTitleModal
        anchors.centerIn: parent
        headerSettings.title: "Some Title"
    }

    StatusModal {
        id: headerImageModal
        anchors.centerIn: parent
        headerSettings.title: "Some Title"
        headerSettings.subTitle: "Subtitle"
        headerSettings.asset.isImage: true
        headerSettings.asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"
    }

    StatusModal {
        id: footerButtonsModal
        anchors.centerIn: parent
        headerSettings.title: "Some Title"
        headerSettings.subTitle: "Subtitle"
        headerSettings.asset.isImage: true
        headerSettings.asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"
        leftButtons: [
            StatusBackButton { }
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
        headerSettings.title: "Some Title"
        headerSettings.subTitle: "Subtitle"
        headerSettings.asset.isImage: true
        headerSettings.asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"

        headerActionButton: StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Secondary
            width: 32
            height: 32

            icon.width: 20
            icon.height: 20
            icon.name: "info"
        }

        leftButtons: [
            StatusBackButton { }
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
        headerSettings.asset.isImage: true
        headerSettings.asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"
        headerSettings.title: "Header"
        headerSettings.subTitle: "SubTitle"
        rightButtons: [
            StatusButton {
                text: "Button"
            },
            StatusButton {
                text: "Button"
            }
        ]

        leftButtons: [
            StatusBackButton { }
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
        headerSettings.title: "Header"
        headerSettings.subTitle: "SubTitle"

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
        headerSettings.title: "Header"
        headerSettings.subTitle: "SubTitle"
        headerSettings.asset.isLetterIdenticon: true
        headerSettings.asset.bgColor: "red"

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
        headerSettings.title: "Header"
        headerSettings.subTitle: "SubTitle"
        headerSettings.asset.name: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                      nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
        headerSettings.asset.imgIsIdenticon: true

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
        id: modalWithEditableIdenticon
        anchors.centerIn: parent
        headerSettings.title: "Header"
        headerSettings.subTitle: "SubTitle"
        headerSettings.headerImageEditable: true
        headerSettings.asset.name: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                      nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
        headerSettings.asset.imgIsIdenticon: true

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
        headerSettings.title: "Some super long text here that exceeds the available space"
        headerSettings.subTitle: "Some super long text here that exceeds the available space"
        headerSettings.subTitleElide: Text.ElideMiddle
        headerSettings.asset.name: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                      nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
        headerSettings.asset.imgIsIdenticon: true

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
        headerSettings.title: "helloworld.eth"
        headerSettings.subTitle: "Basic address"
        headerSettings.popupMenu: StatusMenu {
            id: popupMenu

            StatusMenuInstantiator {
                model: dummyAccountsModel
                menu: popupMenu
                delegate: StatusAction {
                    text: model.name
                    assetSettings.name: model.iconName
                    onTriggered: {
                        popupMenu.dismiss()
                    }
                }
            }
        }
    }

    StatusModal {
        id: editTitleModal
        anchors.centerIn: parent
        headerSettings.title: "This title can be edited"
        headerSettings.editable: true
    }

    StatusModal {
        id: advancedHeaderFooterModal
        anchors.centerIn: parent
        showHeader: false
        showFooter: false
        showAdvancedHeader: true
        showAdvancedFooter: true
        height: 200
        advancedHeaderComponent: Rectangle {
            width: parent.width
            height: 50
            color: Theme.palette.baseColor1
            border.width: 1
            StatusBaseText {
                anchors.centerIn: parent
                text: "Add any header here"
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

        }
        advancedFooterComponent: Rectangle {
            width: parent.width
            height: 50
            color: Theme.palette.baseColor1
            border.width: 1
            StatusBaseText {
                anchors.centerIn: parent
                text: "Add any footer here"
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

        }
    }

    ListModel {
        id: dummyAccountsModel
        ListElement{name: "Account 1"; iconName: "filled-account"; emoji: "🥑" }
        ListElement{name: "Account 2"; iconName: "filled-account"; emoji: "🚀" }
        ListElement{name: "Account 3"; iconName: "filled-account"}
        ListElement{name: "Account 4"; iconName: "filled-account"}
        ListElement{name: "Account 5"; iconName: "filled-account"}
        ListElement{name: "Account 6"; iconName: "filled-account"}
        ListElement{name: "Account 7"; iconName: "filled-account"}
    }
}
