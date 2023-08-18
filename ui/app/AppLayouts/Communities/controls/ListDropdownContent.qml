import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0

StatusListView {
    id: root

    property var checkedKeys: []

    property string footerButtonText

    property var headerModel
    property bool areHeaderButtonsVisible: true
    property bool isFooterButtonVisible: true
    property bool areSectionsVisible: true

    property bool searchMode: false
    property bool availableData: false
    property string noDataText: qsTr("No data found")

    property int maxHeight: 381 // default by design
    property bool showTokenAmount: true

    signal headerItemClicked(string key)
    signal itemClicked(var key, string name, var shortName,  url iconSource, var subItems)

    signal footerButtonClicked

    implicitWidth: 273
    implicitHeight: Math.min(contentHeight, root.maxHeight)
    currentIndex: -1
    leftMargin: d.padding
    rightMargin: 14 // scrollbar width

    header: ColumnLayout {
        width: root.availableWidth

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

            visible: !root.availableData || root.searchMode
            sourceComponent: sectionComponent
        }
    }

    delegate: TokenItem {
        width: root.availableWidth

        name: model.name
        shortName: model.shortName ?? ""
        iconSource: model.iconSource ?? ""
        showSubItemsIcon: !!model.subItems && model.subItems.count > 0
        selected: root.checkedKeys.includes(model.key)
        amount: {
            if (model.remainingSupply === undefined
                    || model.multiplierIndex === undefined)
                return ""

            if (model.infiniteSupply)
                return "∞"

            if (model.remainingSupply === "1" && model.multiplierIndex === 0)
                return qsTr("Max. 1")

            if (root.showTokenAmount)
                return LocaleUtils.numberToLocaleString(
                            SQUtils.AmountsArithmetic.toNumber(
                                model.remainingSupply, model.multiplierIndex))

            return ""
        }

        onItemClicked: root.itemClicked(
                           model.key, name, shortName, iconSource, model.subItems)
    }

    section.property: root.searchMode || !root.areSectionsVisible
                      ? "" : "categoryLabel"
    section.delegate: ColumnLayout {
        width: root.availableWidth
        height: root.searchMode || root.areSectionsVisible ? d.sectionHeight : 0
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.palette.statusListItem.backgroundColor

            Loader {
                id: loader
                anchors.fill: parent
                sourceComponent: sectionComponent

                Binding {
                    target: loader.item
                    property: "section"
                    value: section
                    when: !root.searchMode
                }
            }
        }

        // floating divider
        Rectangle {
            visible: parent.y === root.contentY && (root.searchMode || root.areSectionsVisible)
            Layout.fillWidth: true
            Layout.leftMargin: -d.padding
            Layout.rightMargin: -d.padding*2
            Layout.preferredHeight: 4
            color: Theme.palette.directColor8
        }
    }
    section.labelPositioning: ViewSection.InlineLabels | ViewSection.CurrentLabelAtStart

    Component {
        id: footerComponent

        Item {
            width: ListView.view ? ListView.view.width - Style.current.smallPadding : 0
            height: d.sectionHeight

            Loader {
                id: footerLoader

                anchors.fill: parent
                sourceComponent: sectionComponent

                Binding {
                    target: footerLoader.item
                    property: "section"
                    value: root.footerButtonText
                }

                StatusIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 16

                    icon: "tiny/chevron-right"
                    color: Theme.palette.baseColor1
                    width: 16
                    height: 16
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.footerButtonClicked()
                }
            }
        }
    }

    footer: root.isFooterButtonVisible ? footerComponent : null

    QtObject {
        id: d

        readonly property int padding: Style.current.halfPadding
        readonly property int sectionHeight: 34
    }

    Component {
        id: sectionComponent

        Item {
            id: sectionDelegateRoot

            property string section: {
                if(!root.availableData)
                    return root.noDataText
                if(root.count)
                    return qsTr("Search results")
                return qsTr("No results")
            }

            StatusBaseText {
                anchors.leftMargin: Style.current.halfPadding
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - anchors.leftMargin
                text: sectionDelegateRoot.section
                color: Theme.palette.baseColor1
                font.pixelSize: 12
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                lineHeight: 1.2
            }
        }
    }
}
