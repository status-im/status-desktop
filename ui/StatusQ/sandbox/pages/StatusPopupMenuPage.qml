import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.13

import Qt.labs.qmlmodels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../demoapp/data" 1.0

GridLayout {
    columns: 1
    columnSpacing: 5
    rowSpacing: 5

    StatusButton {
        text: "Simple"
        onClicked: simpleMenu.popup()
    }

    StatusButton {
        text: "Complex"
        onClicked: complexMenu.popup()
    }

    StatusButton {
        id: customPopupButton
        text: "Menu with custom images and icons"
        onClicked: customMenu.popup()
    }

    StatusButton {
        text: "Menu with custom font settings"
        onClicked: differentFontMenu.popup()
    }

    StatusButton {
        text: "StatusSearchLocationMenu"
        onClicked: searchPopupMenu.popup()

        StatusSearchLocationMenu {
            id: searchPopupMenu
            locationModel: Models.optionsModel
        }
    }

    StatusPopupMenu {
        id: simpleMenu
        StatusMenuItem { 
            text: "One" 
        }

        StatusMenuItem { 
            text: "Two"
        }

        StatusMenuItem { 
            text: "Three"
        }
    }

    StatusPopupMenu {
        id: complexMenu

        StatusMenuItem { 
            text: "One" 
            assetSettings.name: "info"
        }

        StatusMenuSeparator {}

        StatusMenuItem { 
            text: "Two"
            assetSettings.name: "info"
        }

        StatusPopupMenu {
            title: "Two"
            assetSettings.name: "info"

            StatusMenuItem { 
                text: "One"
                assetSettings.name: "info"
            }
            StatusMenuItem { 
                text: "Three"
                assetSettings.name: "info"
            }
        }

        StatusMenuItem {
            text: "Disabled"
            assetSettings.name: "info"
            enabled: false
        }

        StatusMenuItem {
            text: "Danger"
            type: StatusMenuItem.Type.Danger
        }
    }

    StatusPopupMenu {
        id: customMenu

        StatusMenuItem {
            text: "Anywhere"
        }

        StatusMenuSeparator {}

        StatusPopupMenu {
            title: "Chat"
            assetSettings.name: "chat"

            StatusMenuItem { 
                text: "vitalik.eth"
                assetSettings.isImage: true
                assetSettings.imgIsIdenticon: true
                assetSettings.name: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0Bh
CExPynn1gWf9bx498P7/nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
            }

            StatusMenuItem { 
                text: "Pascal"
                assetSettings.isImage: true
                assetSettings.name: "qrc:/demoapp/data/profile-image-1.jpeg"
                ringSettings.ringSpecModel:
                    ListModel {
                        ListElement { colorId: 13; segmentLength: 5 }
                        ListElement { colorId: 31; segmentLength: 5 }
                        ListElement { colorId: 10; segmentLength: 1 }
                        ListElement { colorId: 2; segmentLength: 5 }
                        ListElement { colorId: 26; segmentLength: 2 }
                        ListElement { colorId: 19; segmentLength: 4 }
                        ListElement { colorId: 28; segmentLength: 3 }
                    }
                ringSettings.distinctiveColors: Theme.palette.identiconRingColors
            }
        }

        StatusPopupMenu {
            title: "Cryptokitties"
            assetSettings.isImage: true
            assetSettings.name: "qrc:/demoapp/data/profile-image-1.jpeg"

            StatusMenuItem { 
                text: "welcome" 
                assetSettings.name: "channel"
                assetSettings.color: Theme.palette.directColor1
            }
            StatusMenuItem { 
                text: "support" 
                assetSettings.name: "channel"
                assetSettings.color: Theme.palette.directColor1
            }

            StatusMenuHeadline { text: "Public" }

            StatusMenuItem { 
                text: "news" 
                assetSettings.name: "channel"
                assetSettings.color: Theme.palette.directColor1
            }
        }

        StatusPopupMenu {
            title: "Another community"
            assetSettings.isLetterIdenticon: true
            assetSettings.color: "red"

            StatusMenuItem { 
                text: "welcome" 
                assetSettings.isLetterIdenticon: true
                assetSettings.color: "blue"
            }
        }
    }

    StatusPopupMenu {
        id: differentFontMenu
        StatusMenuItem {
            text: "Bold"
            fontSettings.bold: true
        }

        StatusMenuItem {
            text: "Italic"
            fontSettings.italic: true
        }

        StatusMenuItem {
            text: "16px"
            fontSettings.pixelSize: 16
        }
    }
}
