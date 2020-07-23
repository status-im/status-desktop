/*
    Copyright (C) 2011 Jocelyn Turcotte <turcotte.j@gmail.com>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this program; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"

Rectangle {
    id: container

    property QtObject model: undefined
    property Item delegate
    property alias suggestionsModel: filterItem.model
    property alias filter: filterItem.filter
    property alias property: filterItem.property
    property int cursorPosition
    signal itemSelected(var item, int lastAtPosition, int lastCursorPosition)


    z: parent.z + 100
    visible: filter.length > 0 && suggestionsModel.count > 0
    height: visible ? popup.height + (Style.current.padding * 2) : 0
    opacity: visible ? 1.0 : 0
    Behavior on opacity {
        NumberAnimation { }
    }

    // --- defaults
    color: Style.current.white2
    radius: 16
    layer.enabled: true
    layer.effect: DropShadow{
        width: container.width
        height: container.height
        x: container.x
        y: container.y + 10
        visible: container.visible
        source: container
        horizontalOffset: 0
        verticalOffset: 2
        radius: 10
        samples: 15
        color: "#22000000"
    }

    SuggestionFilter {
        id: filterItem
        sourceModel: container.model
        cursorPosition: container.cursorPosition
    }


    ScrollView {
        id: popup
        height: items.height >= 400 ? 400 : items.height
        width: parent.width
        anchors.centerIn: parent
        clip: true

        property int selectedIndex
        property var selectedItem: selectedIndex == -1 ? null : model[selectedIndex]
        signal suggestionClicked(var item)
        ScrollBar.vertical.policy: items.contentHeight > items.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            id: items
            clip: true
            height: childrenRect.height
            width: parent.width
            Repeater {
                id: repeater
                model: container.suggestionsModel
                delegate: Rectangle {
                    id: delegateItem
                    property var suggestion: model
                    property bool hovered

                    height: 50
                    width: container.width
                    color: hovered ? Style.current.blue : "white"

                    Identicon {
                        id: accountImage
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.smallPadding
                        anchors.verticalCenter: parent.verticalCenter
                        source: suggestion.identicon
                    }

                    Text {
                        id: textComponent
                        color: delegateItem.hovered ? Style.current.white : Style.current.black
                        text: suggestion[container.property.split(",").map(p => p.trim()).find(p => !!suggestion[p])]
                        width: parent.width
                        height: parent.height
                        anchors.left: accountImage.right
                        anchors.leftMargin: Style.current.padding
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 15
                    }
                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            delegateItem.hovered = true
                        }
                        onExited: {
                            delegateItem.hovered = false
                        }
                        onClicked: {
                          container.itemSelected(delegateItem.suggestion, filterItem.lastAtPosition, filterItem.cursorPosition)
                        }
                    }
                }
            }
        }
    }
}



