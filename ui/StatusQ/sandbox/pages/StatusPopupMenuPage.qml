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
            iconSettings.name: "info"
        }

        StatusMenuSeparator {}

        StatusMenuItem { 
            text: "Two"
            iconSettings.name: "info"
        }

        StatusMenuItem { 
            text: "Three"
            iconSettings.name: "info"
        }

        StatusPopupMenu {
            title: "Four"
            StatusMenuItem { 
                text: "One"
                iconSettings.name: "info"
            }
            StatusMenuItem { 
                text: "Three"
                iconSettings.name: "info"
            }
        }
    }

    StatusPopupMenu {
        id: customMenu

        subMenuItemIcons: [
            { icon: "chat" },
            { 
                source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg" 
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
                image.source: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0Bh
CExPynn1gWf9bx498P7/nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
                image.isIdenticon: true
            }

            StatusMenuItem { 
                text: "Pascal"
                image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
            }
        }

        StatusPopupMenu {
            title: "Cryptokitties"

            StatusMenuItem { 
                text: "welcome" 
                iconSettings.name: "channel"
                iconSettings.color: Theme.palette.directColor1
            }
            StatusMenuItem { 
                text: "support" 
                iconSettings.name: "channel"
                iconSettings.color: Theme.palette.directColor1
            }

            StatusMenuHeadline { text: "Public" }

            StatusMenuItem { 
                text: "news" 
                iconSettings.name: "channel"
                iconSettings.color: Theme.palette.directColor1
            }
        }

        StatusPopupMenu {
            title: "Another community"

            StatusMenuItem { 
                text: "welcome" 
                iconSettings.isLetterIdenticon: true
                iconSettings.background.color: "red"
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
