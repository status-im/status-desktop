import QtQuick 2.13
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1


StatusListView {
    id: root

    property var checkedKeys: []

    property var headerModel
    property bool areHeaderButtonsVisible: true
    property bool searchMode: false

    property int maxHeight: 381 // default by design

    signal headerItemClicked(string key)
    signal itemClicked(var key, string name, var shortName,  url iconSource, var subItems)

    implicitWidth: 273
    implicitHeight: Math.min(contentHeight, root.maxHeight)
    currentIndex: -1
    clip: true

    header: ColumnLayout {
        width: root.width

        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: root.areHeaderButtonsVisible
                                    ? columnHeader.implicitHeight + 2 * columnHeader.anchors.topMargin
                                    : 0

            visible: root.areHeaderButtonsVisible
            z: 3 // Above delegate (z=1) and above section.delegate (z = 2)

            ColumnLayout {
                id: columnHeader

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.rightMargin: anchors.leftMargin
                anchors.topMargin: 8
                anchors.bottomMargin: 2 * anchors.topMargin
                spacing: 20
                Repeater {
                    model: root.headerModel
                    delegate: StatusIconTextButton {
                        z: 3 // Above delegate (z=1) and above section.delegate (z = 2)
                        spacing: model.spacing
                        statusIcon: model.icon
                        icon.width: model.iconSize
                        icon.height: model.iconSize
                        iconRotation: model.rotation
                        text: model.description
                        onClicked: root.headerItemClicked(model.index)
                    }
                }
            }
        }

        Loader {
            Layout.preferredHeight: visible ? d.sectionHeight : 0
            Layout.fillWidth: true

            visible: root.searchMode
            sourceComponent: sectionComponent
        }
    }

    delegate: TokenItem {
        width: ListView.view.width
        key: model.key
        name: model.name
        shortName: !!model.shortName ? model.shortName : ""
        iconSource: model.iconSource
        subItems: model.subItems
        selected: root.checkedKeys.includes(model.key)

        onItemClicked: root.itemClicked(model.key,
                                        model.name,
                                        model.shortName,
                                        model.iconSource,
                                        model.subItems)
    }

    section.property: root.searchMode ? "" : "category"
    section.criteria: ViewSection.FullString

    section.delegate: Item {
        width: ListView.view.width
        height: d.sectionHeight

        Loader {
            id: loader
            anchors.fill: parent
            sourceComponent: sectionComponent

            Binding {
                target: loader.item
                property: "section"
                value: section
            }
        }
    }

    QtObject {
        id: d

        readonly property int sectionHeight: 34
    }

    Component {
        id: sectionComponent

        Item {
            id: sectionDelegateRoot

            property string section: root.model && root.model.count ?
                                         qsTr("Search result") :
                                         qsTr("No results")

            StatusBaseText {
                anchors.leftMargin: 8
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: sectionDelegateRoot.section
                color: Theme.palette.baseColor1
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }
    }
}
