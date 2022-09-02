import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

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
        text: "Menu with custom images and icons"
        onClicked: customMenu.popup()
    }

    StatusButton {
        text: "Menu with custom font settings"
        onClicked: differentFontMenu.popup()
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
        subMenuItemIcons: [{ icon: 'info' }]

        StatusMenuItem { 
            text: "One" 
            assetSettings.name: "info"
        }

        StatusMenuSeparator {}

        StatusMenuItem { 
            text: "Two"
            assetSettings.name: "info"
        }

        StatusMenuItem { 
            text: "Three"
            assetSettings.name: "info"
        }

        StatusPopupMenu {
            title: "Four"
            StatusMenuItem { 
                text: "One"
                assetSettings.name: "info"
            }
            StatusMenuItem { 
                text: "Three"
                assetSettings.name: "info"
            }
        }
    }

    StatusPopupMenu {
        id: customMenu

        subMenuItemIcons: [
            { icon: "chat" },
            { 
                source: "qrc:/demoapp/data/profile-image-1.jpeg"
            },
            { 
                isLetterIdenticon: true, 
                color: "red" 
            }
        ]

        StatusMenuItem {
            text: "Anywhere"
        }

        StatusMenuSeparator {}

        StatusPopupMenu {
            title: "Chat" 

            StatusMenuItem { 
                text: "vitalik.eth"
                assetSettings.isImage: true
                assetSettings.name: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0Bh
CExPynn1gWf9bx498P7/nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
                assetSettings.imgIsIdenticon: true
            }

            StatusMenuItem { 
                text: "Pascal"
                assetSettings.isImage: true
                assetSettings.name: "qrc:/demoapp/data/profile-image-1.jpeg"
            }
        }

        StatusPopupMenu {
            title: "Cryptokitties"

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

            StatusMenuItem { 
                text: "welcome" 
                assetSettings.isLetterIdenticon: true
                assetSettings.bgColor: "red"
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
