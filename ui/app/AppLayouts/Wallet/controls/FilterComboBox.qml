import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Components.private 0.1 as SQP
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls 1.0

import SortFilterProxyModel 0.2

ComboBox {
    id: root

    required property var regularTokensModel // "uncategorized" collectibles (not grouped)
    required property var collectionGroupsModel // collection groups
    required property var communityTokenGroupsModel // community groups

    property bool hasCommunityGroups

    property alias selectedFilterGroupIds: d.selectedFilterGroupIds
    readonly property bool hasEnabledFilters: d.selectedFilterGroupIds.length

    function clearFilter() {
        d.selectedFilterGroupIds = []
    }

    enabled: d.searchTextLowerCase || d.combinedProxyModel.count || d.uncategorizedModel.count
    opacity: enabled ? 1 : 0.3

    displayText: qsTr("Collection")

    horizontalPadding: 12
    verticalPadding: Style.current.halfPadding
    spacing: Style.current.halfPadding

    font.family: Theme.palette.baseFont.name
    font.pixelSize: Style.current.additionalTextSize

    QtObject {
        id: d

        readonly property int defaultDelegateHeight: 34

        readonly property string searchTextLowerCase: searchBox.input.text.toLowerCase()

        readonly property var combinedModel: ConcatModel {
            sources: [
                SourceModel {
                    model: root.communityTokenGroupsModel
                    markerRoleValue: "community"
                },
                SourceModel {
                    model: root.collectionGroupsModel
                    markerRoleValue: "collection"
                }
            ]

            markerRoleName: "sourceGroup"
            onRowsRemoved: root.clearFilter() // different underlying model -> uncheck all
        }

        readonly property var combinedProxyModel: SortFilterProxyModel {
            sourceModel: d.combinedModel
            proxyRoles: [
                JoinRole {
                    name: "groupName"
                    roleNames: ["collectionName", "communityName"]
                    separator: ""
                },
                JoinRole {
                    name: "groupId"
                    roleNames: ["collectionUid", "communityId"]
                    separator: ""
                }
            ]
            filters: [
                FastExpressionFilter {
                    enabled: d.searchTextLowerCase !== ""
                    expression: {
                        d.searchTextLowerCase // ensure expression is reevaluated when searchString changes
                        return model.groupName.toLowerCase().includes(d.searchTextLowerCase) || model.groupId.toLowerCase().includes(d.searchTextLowerCase)
                    }
                    expectedRoles: ["groupName", "groupId"]
                },
                FastExpressionFilter {
                    expression: {
                        if (model.sourceGroup === "collection")
                            return !model.isSelfCollection
                        return true
                    }
                    expectedRoles: ["sourceGroup", "isSelfCollection"]
                }
            ]
        }

        readonly property var uncategorizedModel: SortFilterProxyModel { // regular collectibles with no collection
            sourceModel: root.regularTokensModel
            filters: ValueFilter {
                roleName: "isSelfCollection"
                value: true
            }
            onCountChanged: if (!count) d.removeFilter("") // different underlying model -> uncheck
        }

        property var selectedFilterGroupIds: []
        readonly property bool allVisuallyChecked: selectedFilterGroupIds.length === 0

        function addFilter(groupId) {
            if (d.selectedFilterGroupIds.includes(groupId))
                return
            const newFilters = d.selectedFilterGroupIds.concat(groupId)
            d.selectedFilterGroupIds = newFilters
        }
        function removeFilter(groupId) {
            const newFilters = d.selectedFilterGroupIds.filter((filter) => filter !== groupId)
            d.selectedFilterGroupIds = newFilters
        }
        function removeGroupFilters() {
            const newFilters = d.selectedFilterGroupIds.filter((filter) => filter === "")
            d.selectedFilterGroupIds = newFilters
        }
    }

    background: SQP.StatusComboboxBackground {
        active: root.down || root.hovered
    }

    contentItem: RowLayout {
        spacing: -6 // badge has an implicit border :/
        StatusBaseText {
            leftPadding: root.horizontalPadding
            rightPadding: root.horizontalPadding
            font.pixelSize: root.font.pixelSize
            font.weight: Font.Medium
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            text: root.displayText
            color: Theme.palette.baseColor1
        }
        StatusBadge {
            Layout.preferredHeight: 16
            Layout.preferredWidth: 16
            Layout.rightMargin: Style.current.halfPadding
            value: d.selectedFilterGroupIds.length
            visible: root.hasEnabledFilters
        }
    }

    indicator: SQP.StatusComboboxIndicator {
        x: root.mirrored ? root.horizontalPadding : root.width - width - root.horizontalPadding
        y: root.topPadding + (root.availableHeight - height) / 2
    }

    popup: Popup {
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        y: root.height + 4

        implicitWidth: 290
        implicitHeight: Math.min(contentHeight+margins, 380)
        margins: Style.current.halfPadding

        padding: 0
        bottomPadding: Style.current.halfPadding

        background: Rectangle {
            color: Theme.palette.statusSelect.menuItemBackgroundColor
            radius: Style.current.radius
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 25
                spread: 0.2
                color: Theme.palette.dropShadow
            }
        }

        contentItem: ColumnLayout {
            spacing: 0
            SearchBox {
                id: searchBox
                Layout.fillWidth: true
                Layout.topMargin: 12
                Layout.leftMargin: Style.current.halfPadding
                Layout.rightMargin: Style.current.halfPadding
                Layout.bottomMargin: 12
                minimumHeight: d.defaultDelegateHeight
                maximumHeight: d.defaultDelegateHeight
                input.edit.font.pixelSize: root.font.pixelSize
                input.placeholder.font.pixelSize: root.font.pixelSize
                input.asset.width: 16
                input.asset.height: 16
                topPadding: 0
                bottomPadding: 0
                placeholderText: qsTr("Collection, community, name or #")
            }
            StatusListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitWidth: contentWidth
                implicitHeight: contentHeight

                model: d.combinedProxyModel
                delegate: Item { // NB anything but AbstractButton to prevent auto-closing of the popup
                    width: ListView.view.width
                    implicitHeight: customMenuDelegate.implicitHeight

                    CustomItemDelegate {
                        id: customMenuDelegate
                        width: parent.width
                    }
                }
                section.property: "sourceGroup"
                section.delegate: ColumnLayout {
                    id: sectionDelegate
                    width: ListView.view.width
                    height: d.defaultDelegateHeight
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Theme.palette.statusListItem.backgroundColor

                        StatusBaseText {
                            anchors.fill: parent
                            anchors.leftMargin: Style.current.padding
                            anchors.rightMargin: Style.current.padding
                            verticalAlignment: Text.AlignVCenter
                            text: section === "community" ? qsTr("Community minted") : root.hasCommunityGroups ? qsTr("Other")
                                                                                                               : qsTr("Collections")
                            color: Theme.palette.baseColor1
                            font.pixelSize: Style.current.tertiaryTextFontSize
                            elide: Text.ElideRight
                        }
                    }

                    // floating divider
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 4
                        color: sectionDelegate.y <= sectionDelegate.ListView.view.contentY && sectionDelegate.y !== 0 ? Theme.palette.directColor8
                                                                                                                      : Theme.palette.statusListItem.backgroundColor
                    }
                }
                section.labelPositioning: ViewSection.InlineLabels | ViewSection.CurrentLabelAtStart
            }
            StatusMenuSeparator {
                Layout.fillWidth: true
                visible: d.uncategorizedModel.count
            }
            CustomItemDelegate {
                Layout.fillWidth: true
                icon.name: "image"
                text: qsTr("No collection")
                count: d.uncategorizedModel.count
                groupId: ""
                visible: count
            }
        }
    }

    component CustomItemDelegate: CheckDelegate {
        id: menuDelegate

        property int count: model.enabledNetworkBalance
        readonly property bool isCommunityGroup: !!model && !!model.communityId
        property string groupId: model.groupId
        readonly property string groupImage: !!model ? model.communityImage || model.imageUrl : ""

        highlighted: hovered
        leftPadding: Style.current.padding
        rightPadding: 44
        verticalPadding: 4
        spacing: root.spacing
        font: root.font
        text: model.groupName
        icon.source: groupImage
        icon.name: isCommunityGroup ? "group" : "gallery"
        checked: d.selectedFilterGroupIds.includes(menuDelegate.groupId)
        onToggled: checked ? d.addFilter(menuDelegate.groupId) : d.removeFilter(menuDelegate.groupId)
        background: Rectangle {
            color: menuDelegate.highlighted ? Theme.palette.statusMenu.hoverBackgroundColor : "transparent"
            HoverHandler {
                cursorShape: menuDelegate.enabled ? Qt.PointingHandCursor : undefined
            }
        }
        indicator: Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: 18
            implicitHeight: implicitWidth
            radius: 2
            color: menuDelegate.down || menuDelegate.checkState !== Qt.Checked
                        ? Theme.palette.directColor8
                        : Theme.palette.primaryColor1

            StatusIcon {
                icon: "checkbox"
                width: 11
                height: 8
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 1
                color: d.allVisuallyChecked ? Theme.palette.baseColor1 : Theme.palette.white
                visible: menuDelegate.down || menuDelegate.checkState !== Qt.Unchecked || d.allVisuallyChecked
            }
        }
        contentItem: RowLayout {
            spacing: root.spacing

            Loader {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32

                sourceComponent: !!menuDelegate.groupImage ? roundImage : roundIcon

                Component {
                    id: roundImage
                    StatusRoundedImage {
                        image.source: menuDelegate.icon.source
                        radius: menuDelegate.isCommunityGroup ? width/2 : 6
                        showLoadingIndicator: true
                        image.fillMode: Image.PreserveAspectCrop
                    }
                }

                Component {
                    id: roundIcon
                    StatusRoundIcon {
                        asset.bgRadius: menuDelegate.isCommunityGroup ? width/2 : 6
                        asset.bgWidth: 16
                        asset.bgHeight: 16
                        asset.bgColor: Theme.palette.primaryColor3
                        asset.width: 16
                        asset.height: 16
                        asset.name: menuDelegate.icon.name
                        asset.color: Theme.palette.primaryColor1
                    }
                }
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: menuDelegate.text
                elide: Text.ElideRight
                font.pixelSize: menuDelegate.font.pixelSize
                font.weight: menuDelegate.checked ? Font.Medium : Font.Normal
            }

            Item { Layout.fillWidth: true }

            StatusBaseText {
                font.pixelSize: Style.current.tertiaryTextFontSize
                color: Theme.palette.baseColor1
                text: menuDelegate.count
            }
        }
    }
}
