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

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils
import StatusQ.Components

import utils
import shared.controls
import shared.panels
import shared.controls.chat

Rectangle {
    id: container

    property var model
    property Item delegate
    property alias suggestionsModel: filterItem.model
    property alias filter: filterItem.filter
    readonly property alias formattedPlainTextFilter: filterItem.formattedFilter
    property alias suggestionFilter: filterItem
    property int cursorPosition
    property alias listView: listView
    property var inputField
    property bool shouldHide: false

    signal itemSelected(var item, int lastAtPosition, int lastCursorPosition)

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
    }

    function selectCurrentItem() {
        container.itemSelected(listView.model.get(listView.currentIndex), filterItem.lastAtPosition, filterItem.cursorPosition)
    }

    onVisibleChanged: {
        if (visible && listView.currentIndex === -1) {
            // If the previous selection was made using the mouse, the currentIndex was changed to -1
            // We change it back to 0 so that it can be used to select using the keyboard
            listView.currentIndex = 0
        }
        if (visible && !SQUtils.Utils.isMobile) {
            listView.forceActiveFocus();
        }
    }

    z: parent.z + 100
    visible: !shouldHide && filter.length > 0 && suggestionsModel.count > 0 && filterItem.lastAtPosition > -1
    height: Math.min(400, listView.contentHeight + Theme.padding)

    opacity: visible ? 1.0 : 0
    Behavior on opacity {
        NumberAnimation { }
    }

    color: Theme.palette.background
    radius: Theme.radius

    layer.enabled: true
    layer.effect: DropShadow {
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
        keyNavigationEnabled: true
        anchors.fill: parent
        anchors.margins: Theme.halfPadding
        Keys.priority: Keys.AfterItem
        Keys.forwardTo: container.inputField
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                container.hide();
            } else if (event.key !== Qt.Key_Up && event.key !== Qt.Key_Down) {
                event.accepted = false;
            }
        }
        model: container.suggestionsModel

        delegate: Rectangle {
            id: itemDelegate
            objectName: model.preferredDisplayName
            color: ListView.isCurrentItem ? Theme.palette.backgroundHover : Theme.palette.transparent
            width: ListView.view.width
            height: 42
            radius: Theme.radius

            StatusUserImage {
                id: accountImage
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.smallPadding
                imageWidth: 32
                imageHeight: 32

                name: model.preferredDisplayName
                usesDefaultName: model.usesDefaultName
                colorHash: model.colorHash
                userColor: Utils.colorForColorId(model.colorId)
                image: model.icon
                interactive: false
            }

            StyledText {
                text: model.preferredDisplayName
                color: Theme.palette.textColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: accountImage.right
                anchors.leftMargin: Theme.smallPadding
            }

            StatusMouseArea {
                id: mouseArea
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    listView.currentIndex = index
                }
                onClicked: {
                    container.itemSelected(model, filterItem.lastAtPosition, filterItem.cursorPosition)
                }
            }
        }
    }
}
