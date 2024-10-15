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

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared 1.0
import shared.controls 1.0
import shared.panels 1.0
import shared.controls.chat 1.0

Rectangle {
    id: container

    property var model
    property Item delegate
    property alias suggestionsModel: filterItem.model
    property alias filter: filterItem.filter
    property alias formattedPlainTextFilter: filterItem.formattedFilter
    property alias suggestionFilter: filterItem
    property alias property: filterItem.property
    property int cursorPosition
    signal itemSelected(var item, int lastAtPosition, int lastCursorPosition)
    property alias listView: listView
    property var inputField
    property bool shouldHide: false

    onFormattedPlainTextFilterChanged: {
        // We need to callLater because the sort needs to happen before setting the index
        Qt.callLater(function () {
            listView.currentIndex = 0
        })
    }

    onCursorPositionChanged: {
        if (shouldHide) {
            shouldHide = false
        }
    }

    function hide() {
        shouldHide = true
        formattedPlainTextFilter = "";
    }

    function selectCurrentItem() {
        container.itemSelected(mentionsListDelegate.items.get(listView.currentIndex).model, filterItem.lastAtPosition, filterItem.cursorPosition)
    }

    onVisibleChanged: {
        if (visible && listView.currentIndex === -1) {
            // If the previous selection was made using the mouse, the currentIndex was changed to -1
            // We change it back to 0 so that it can be used to select using the keyboard
            listView.currentIndex = 0
        }
        if (visible) {
            listView.forceActiveFocus();
        }
    }

    z: parent.z + 100
    visible: !shouldHide && filter.length > 0 && suggestionsModel.count > 0
    height: Math.min(400, listView.contentHeight + Theme.padding)

    opacity: visible ? 1.0 : 0
    Behavior on opacity {
        NumberAnimation { }
    }

    color: Theme.palette.background
    radius: Theme.radius
    border.width: 0
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

    SuggestionFilterPanel {
        id: filterItem
        sourceModel: container.model
        cursorPosition: container.cursorPosition
    }

    StatusListView {
        id: listView
        objectName: "suggestionBoxList"
        model: mentionsListDelegate
        keyNavigationEnabled: true
        anchors.fill: parent
        anchors.topMargin: Theme.halfPadding
        anchors.leftMargin: Theme.halfPadding
        anchors.rightMargin: Theme.halfPadding
        anchors.bottomMargin: Theme.halfPadding
        Keys.priority: Keys.AfterItem
        Keys.forwardTo: container.inputField
        Keys.onPressed: {
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                container.itemSelected(mentionsListDelegate.items.get(listView.currentIndex).model, filterItem.lastAtPosition, filterItem.cursorPosition)
            } else if (event.key === Qt.Key_Escape) {
                container.hide();
            } else if (event.key !== Qt.Key_Up && event.key !== Qt.Key_Down) {
                event.accepted = false;
            }
        }

        DelegateModelGeneralized {
            id: mentionsListDelegate

            lessThan: [
                function(left, right) {
                    // Priorities:
                    // 1. Match at the start
                    // 2. Match in the start of one of the three words
                    // 3. Alphabetical order (also in case of multiple matches at the start of the name)

                    const leftProp = left[container.property.find(p => !!left[p])].toLowerCase()
                    const rightProp = right[container.property.find(p => !!right[p])].toLowerCase()

                    if (!formattedPlainTextFilter) {
                        return leftProp < rightProp
                    }

                    // check the start of the string
                    const leftMatches = leftProp.startsWith(formattedPlainTextFilter)

                    const rightMatches = rightProp.startsWith(formattedPlainTextFilter)

                    if (leftMatches === true && rightMatches === true) {
                        return leftProp < rightProp
                    }

                    if (leftMatches || rightMatches) {
                        return leftMatches && !rightMatches
                    }

                    // Check for the start of the 3 word names
                    let leftMatchesIndex = leftProp.indexOf(" " + formattedPlainTextFilter)
                    let rightMatchesIndex = rightProp.indexOf(" " + formattedPlainTextFilter)
                    if (leftMatchesIndex === rightMatchesIndex) {
                        return leftProp < rightProp
                    }

                    // Change index so that -1 is not the smallest
                    if (leftMatchesIndex === -1) {
                        leftMatchesIndex = 999
                    }
                    if (rightMatchesIndex === -1) {
                        rightMatchesIndex = 999
                    }

                    return leftMatchesIndex < rightMatchesIndex
                }
            ]

            model: container.suggestionsModel

            delegate: Rectangle {
                id: itemDelegate
                objectName: model.name
                color: ListView.isCurrentItem ? Theme.palette.backgroundHover : Theme.palette.transparent
                border.width: 0
                width: ListView.view.width
                height: 42
                radius: Theme.radius

                UserImage {
                    id: accountImage
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.smallPadding
                    imageWidth: 32
                    imageHeight: 32

                    name: model.name
                    pubkey: model.publicKey
                    image: model.icon
                    interactive: false
                }

                StyledText {
                    text: model[container.property.find(p => !!model[p])]
                    color: Theme.palette.textColor
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: accountImage.right
                    anchors.leftMargin: Theme.smallPadding
                    font.pixelSize: 15
                }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        listView.currentIndex = itemDelegate.DelegateModel.itemsIndex
                    }
                    onClicked: {
                        container.itemSelected(model, filterItem.lastAtPosition, filterItem.cursorPosition)
                    }
                }
            }
        }
    }
}



