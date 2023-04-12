import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

import AppLayouts.Profile.controls 1.0

Control {
    id: root

    property var baseModel

    readonly property alias settings: settings
    readonly property alias showcaseModel: showcaseModel

    // to override
    property string settingsKey
    property string keyRole
    property var roleNames: []
    property var filterFunc: (modelData) => true
    property string hiddenPlaceholderBanner
    property string showcasePlaceholderBanner
    property Component draggableDelegateComponent
    property Component showcaseDraggableDelegateComponent

    background: null

    component VisibilityDropArea: AbstractButton {
        id: visibilityDropAreaLocal

        property int showcaseVisibility: Constants.ShowcaseVisibility.NoOne
        readonly property alias containsDrag: dropArea.containsDrag

        padding: Style.current.halfPadding
        spacing: padding/2

        icon.color: Theme.palette.primaryColor1

        background: ShapeRectangle {
            path.strokeColor: dropArea.containsDrag ? "transparent" : Theme.palette.directColor7
            path.fillColor: dropArea.containsDrag ? Theme.palette.white : "transparent"

            DropArea {
                id: dropArea
                anchors.fill: parent
                keys: ["x-status-draggable-showcase-item-hidden"]
                onEntered: function(drag) {
                    drag.accept()
                }

                onDropped: function(drop) {
                    var showcaseObj = drop.source.showcaseObj

                    var tmpObj = Object()
                    root.roleNames.forEach(role => tmpObj[role] = showcaseObj[role])
                    tmpObj.showcaseVisibility = visibilityDropAreaLocal.showcaseVisibility
                    showcaseModel.append(tmpObj)
                }
            }
        }

        contentItem: Item {
            RowLayout {
                width: Math.min(parent.width, implicitWidth)
                anchors.centerIn: parent
                spacing: visibilityDropAreaLocal.spacing
                StatusIcon {
                    width: 20
                    height: 20
                    icon: ProfileUtils.visibilityIcon(visibilityDropAreaLocal.showcaseVisibility)
                    color: visibilityDropAreaLocal.icon.color
                }
                StatusBaseText {
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    color: visibilityDropAreaLocal.icon.color
                    text: visibilityDropAreaLocal.text
                }
            }
        }
    }

    Component.onCompleted: showcaseModel.load()
    Component.onDestruction: showcaseModel.save()

    // NB temporary model until the backend knows the extra roles: "showcaseVisibility" and "order"
    ListModel {
        id: showcaseModel

        function hasItem(itemId) {
            for (let i = 0; i < count; i++) {
                let item = get(i)
                if (!!item && item[root.keyRole] === itemId)
                    return true
            }
            return false
        }

        function save() {
            var result = []
            for (let i = 0; i < count; i++) {
                let item = get(i)
                result.push(item)
            }
            settings.setValue(root.settingsKey, JSON.stringify(result))
        }

        function load() {
            const data = settings.value(root.settingsKey)
            try {
                const arr = JSON.parse(data)
                for (const i in arr)
                    showcaseModel.append(arr[i])
            } catch (e) {
                console.warn(e)
            }
        }
    }

    Settings {
        id: settings
        category: "Showcase"

        function reset() {
            showcaseModel.clear()
            settings.setValue(root.settingsKey, "")
            settings.sync()
        }
    }

    QtObject {
        id: d

        readonly property int defaultDelegateHeight: 60
        readonly property int contentSpacing: 12
        readonly property int strokeMargin: 2
    }

    contentItem: ColumnLayout {
        spacing: d.contentSpacing

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("In showcase")
            color: Theme.palette.baseColor1
            font.pixelSize: 13
            font.weight: Font.Medium
        }

        StatusListView {
            id: showcaseItemsListView
            Layout.fillWidth: true
            Layout.minimumHeight: Math.floor(targetDropArea.height + targetDropArea.anchors.bottomMargin)
            model: showcaseModel
            implicitHeight: contentHeight
            interactive: false

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: DropArea {
                id: showcaseDelegateRoot

                property int visualIndex: index

                ListView.onRemove: SequentialAnimation {
                    PropertyAction { target: showcaseDelegateRoot; property: "ListView.delayRemove"; value: true }
                    NumberAnimation { target: showcaseDelegateRoot; property: "scale"; to: 0; easing.type: Easing.InOutQuad }
                    PropertyAction { target: showcaseDelegateRoot; property: "ListView.delayRemove"; value: false }
                }

                width: ListView.view.width
                height: showcaseDraggableDelegateLoader.item ? showcaseDraggableDelegateLoader.item.height : 0

                keys: ["x-status-draggable-showcase-item"]

                onEntered: function(drag) {
                    const from = drag.source.visualIndex
                    const to = showcaseDraggableDelegateLoader.item.visualIndex
                    if (to === from)
                        return
                    showcaseModel.move(from, to, 1)
                    drag.accept()
                }

                Loader {
                    id: showcaseDraggableDelegateLoader
                    width: parent.width
                    sourceComponent: root.showcaseDraggableDelegateComponent

                    property var modelData: model
                    property var dragParentData: root
                    property int visualIndexData: index
                }
            }

            // overlaid at the bottom of the listview
            DropArea {
                id: targetDropArea
                width: parent.width
                height: d.defaultDelegateHeight
                anchors.bottom: parent.bottom
                anchors.bottomMargin: showcaseModel.count ? Style.current.halfPadding : 0
                keys: ["x-status-draggable-showcase-item-hidden"]

                ShapeRectangle {
                    anchors.fill: parent
                    anchors.margins: d.strokeMargin
                    visible: !showcaseModel.count && !showcaseCombinedDropArea.visible
                    text: root.hiddenPlaceholderBanner
                }

                Rectangle {
                    id: showcaseCombinedDropArea
                    width: parent.width
                    height: parent.height + d.strokeMargin
                    anchors.centerIn: parent
                    color: Theme.palette.baseColor5
                    radius: Style.current.radius
                    visible: parent.containsDrag || dropAreaEveryone.containsDrag || dropAreaContacts.containsDrag || dropAreaVerified.containsDrag

                    RowLayout {
                        width: parent.width - spacing*2
                        anchors.centerIn: parent
                        spacing: d.contentSpacing
                        VisibilityDropArea {
                            id: dropAreaEveryone
                            Layout.fillWidth: true
                            showcaseVisibility: Constants.ShowcaseVisibility.Everyone
                            text: qsTr("Everyone")
                        }
                        VisibilityDropArea {
                            id: dropAreaContacts
                            Layout.fillWidth: true
                            showcaseVisibility: Constants.ShowcaseVisibility.Contacts
                            text: qsTr("Contacts")
                        }
                        VisibilityDropArea {
                            id: dropAreaVerified
                            Layout.fillWidth: true
                            showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts
                            text: qsTr("Verified")
                        }
                    }
                }
            }
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.halfPadding
            text: qsTr("Hidden")
            color: Theme.palette.baseColor1
            font.pixelSize: 13
            font.weight: Font.Medium
        }

        StatusListView {
            id: hiddenItemsListView
            Layout.fillWidth: true
            Layout.minimumHeight: empty ? Math.floor(hiddenTargetDropArea.height + hiddenTargetDropArea.anchors.topMargin)
                                        : d.defaultDelegateHeight * Math.min(count, 4)
            model: root.baseModel

            readonly property bool empty: !contentHeight

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: DropArea {
                id: delegateRoot

                property int visualIndex: index

                visible: root.filterFunc(model)
                width: ListView.view.width
                height: visible && draggableDelegateLoader.item ? draggableDelegateLoader.item.height : 0

                keys: ["x-status-draggable-showcase-item"]

                onEntered: function(drag) {
                    drag.accept()
                }

                onDropped: function(drop) {
                    showcaseModel.remove(drop.source.visualIndex)
                }

                Rectangle {
                    width: parent.width
                    height: d.defaultDelegateHeight
                    anchors.centerIn: parent
                    color: Theme.palette.baseColor5
                    radius: Style.current.radius
                    visible: draggableDelegateLoader.item && draggableDelegateLoader.item.dragActive
                }

                Loader {
                    id: draggableDelegateLoader
                    width: parent.width
                    sourceComponent: root.draggableDelegateComponent

                    property var modelData: model
                    property var dragParentData: root
                    property int visualIndexData: delegateRoot.visualIndex
                }
            }

            // overlaid at the top of the listview
            DropArea {
                id: hiddenTargetDropArea
                width: parent.width
                height: d.defaultDelegateHeight
                anchors.top: parent.top
                anchors.topMargin: !hiddenItemsListView.empty ? Style.current.halfPadding : 0
                keys: ["x-status-draggable-showcase-item"]

                ShapeRectangle {
                    readonly property bool stroked: hiddenItemsListView.empty && !parent.containsDrag

                    anchors.fill: parent
                    anchors.margins: d.strokeMargin
                    visible: hiddenItemsListView.empty || parent.containsDrag
                    path.fillColor: stroked ? "transparent" : Theme.palette.baseColor5
                    path.strokeColor: stroked ? Theme.palette.baseColor2 : "transparent"
                    text: root.showcasePlaceholderBanner
                }

                onEntered: function(drag) {
                    drag.accept()
                }

                onDropped: function(drop) {
                    showcaseModel.remove(drop.source.visualIndex)
                }
            }
        }
    }
}
