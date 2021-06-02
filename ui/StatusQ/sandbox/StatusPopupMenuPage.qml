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
        subMenuItemIcons: ['info']
        StatusMenuItem { 
            text: "One" 
            icon.name: "info"
        }

        StatusMenuSeparator {}

        StatusMenuItem { 
            text: "Two"
            icon.name: "info"
        }

        StatusMenuItem { 
            text: "Three"
            icon.name: "info"
        }

        StatusPopupMenu {
            title: "Four"
            StatusMenuItem { 
                text: "One"
                icon.name: "info"
            }
            StatusMenuItem { 
                text: "Three"
                icon.name: "info"
            }
        }
    }
}
