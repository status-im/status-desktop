import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1


StatusPopupMenu {
    id: root

    property alias suggestions: suggestionsMenu.model

    signal addToUserDict()
    signal disableSpellchecking()

    Column {

        Repeater {
            id: suggestionsMenu

            delegate:  MenuItem {
                id: variants
                implicitWidth: parent ? parent.width : 0
                implicitHeight: 38
                contentItem: StatusBaseText {
                    rightPadding: 8
                    leftPadding: 4

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter

                    text: modelData
                    color: Theme.palette.directColor1
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    color: variants.hovered ? Theme.palette.statusPopupMenu.hoverBackgroundColor
                                              : "transparent"
                }

                onTriggered: {
                    root.menuItemClicked(index)
                }
            }
        }

        StatusMenuSeparator { visible: !!suggestionsMenu.model && suggestionsMenu.model.length !== 0}

        MenuItem {
            id: ignoreWord
            implicitWidth: parent ? parent.width : 0
            implicitHeight: 38
            contentItem: StatusBaseText {
                rightPadding: 8
                leftPadding: 4

                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter

                text: qsTr("Add to dictionary")
                color: Theme.palette.directColor1
                font.pixelSize: 13
                elide: Text.ElideRight
            }

            background: Rectangle {
                color: ignoreWord.hovered ? Theme.palette.statusPopupMenu.hoverBackgroundColor
                                          : "transparent"
            }

            onTriggered: {
                root.addToUserDict()
            }
        }

        MenuItem {
            id: disableSpellchecking
            implicitWidth: parent ? parent.width : 0
            implicitHeight: 38
            contentItem: StatusBaseText {
                rightPadding: 8
                leftPadding: 4

                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter

                text: qsTr("Disable Spellchecking")
                color: Theme.palette.directColor1
                font.pixelSize: 13
                elide: Text.ElideRight
            }


            background: Rectangle {
                color: disableSpellchecking.hovered ? Theme.palette.statusPopupMenu.hoverBackgroundColor
                                                    : "transparent"
            }

            onTriggered: {
                root.disableSpellchecking()
            }
        }
    }

}
