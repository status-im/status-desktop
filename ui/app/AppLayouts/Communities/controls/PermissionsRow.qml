import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils
import StatusQ.Components
import StatusQ.Controls

import AppLayouts.Communities.views

import SortFilterProxyModel

/*!
   \qmltype PermissionsRow
   \inherits Control
   \inqmlmodule AppLayouts.Communities.controls 1.0
   \brief It is a permissions row control that provides information about community tokens permissions. Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-controls2-control.html}{Control}.

   The \c PermissionsRow is the token permissions representation row component.
   It has different ui abreviations / permutations depending on the tokens and permissions the permissions model provides.

   Example of how to use it:
   \qml
        PermissionsRow {
            model: root.permissionsModel
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel

            overlapping: 8
            overlappingBorder: 1
            backgroundRadius: 8
        }
   \endqml
   For a list of components available see StatusQ.
*/
Control {

    id: root

    /*!
       \qmlproperty var PermissionsRow::model
       This property holds the permissions model with expected roles: [ holdingsModel [ roles: key] ].
    */
    property var model

    /*!
       \qmlproperty var PermissionsRow::assetsModel
       This property holds the global assets model.
    */
    property var assetsModel

    /*!
       \qmlproperty var PermissionsRow::collectiblesModel
       This property holds the global collectibles model.
    */
    property var collectiblesModel

    /*!
       \qmlproperty bool PermissionsRow::requirementsMet
       This property holds if the token requirements are met in case the community requires permissions.
    */
    property bool requirementsMet: false

    /*!
       \qmlproperty int PermissionsRow::overlapping
       This property allows customizing the overlapping distance between elements.
    */
    property int overlapping: 8

    /*!
       \qmlproperty int PermissionsRow::overlappingBorder
       This property allows customizing the overlapping border between elements.
    */
    property int overlappingBorder: 1

    /*!
       \qmlproperty color PermissionsRow::backgroundColor
       This property holds the control background color, including border color of overlapped elements.
    */
    property color backgroundColor: Theme.palette.baseColor4

    /*!
       \qmlproperty color PermissionsRow::backgroundColor
       This property holds the control background color, including border color of overlapped elements.
    */
    property color backgroundBorderColor: Theme.palette.baseColor4

    /*!
       \qmlproperty int PermissionsRow::backgroundRadius
       This property holds the background radius.
    */
    property int backgroundRadius: 8

    /*!
       \qmlproperty int PermissionsRow::dotsIconSize
       This property holds the dots icon size.
    */
    property int dotsIconSize: 8

    /*!
       \qmlproperty int PermissionsRow::pixelSize
       This property holds the font pixel size of all elements that contain text,
       like the text `or` between elements or the `+2` and `+3` element's text.
    */
    property int fontPixelSize: 11

    QtObject {
        id: d

        readonly property int maxTokens: 5
        readonly property int maxVisualPermissions: 2

        property bool dotsVisible: false

        readonly property var filteredModel: SortFilterProxyModel {
            sourceModel: root.model
            filters: FastExpressionFilter {
                expression: {
                    if (model.isPrivate) {
                        return model.tokenCriteriaMet
                    }
                    return true
                }
                expectedRoles: ["isPrivate", "tokenCriteriaMet"]
            }
        }

        function buildShortModel(model) {
            shortModel.clear()
            dotsVisible = false

            if(!model)
                return

            const modelCount = model.rowCount()
            if(modelCount <= 0)
                return

            // CASE 1: Only 1 or 2 permission (no abbreviations)
            if(modelCount <= maxVisualPermissions) {
                dotsVisible = false
                for(var i = 0; i < modelCount; i++)
                    shortModel.append(ModelUtils.get(model, i))
                return
            }

            // Global data needed:
            const permission1 = ModelUtils.get(model, 0)
            const permission2 = ModelUtils.get(model, 1)
            const holdingsCount1 = permission1.holdingsListModel.rowCount()
            const holdingsCount2 = permission2.holdingsListModel.rowCount()

            // CASE 2: Exactly 3 permissions (All they have only 1 token
            // OR all they have 1 token but only 1 has 2 tokens)
            if(modelCount === 3) {
                const permission3 = ModelUtils.get(model, 2)
                const holdingsCount3 = permission3.holdingsListModel.rowCount()

                if((holdingsCount1 === 1 && holdingsCount2 === 1 && holdingsCount3 === 1) ||
                   (holdingsCount1 === 2 && holdingsCount2 === 1 && holdingsCount3 === 1) ||
                   (holdingsCount1 === 1 && holdingsCount2 === 2 && holdingsCount3 === 1) ||
                   (holdingsCount1 === 1 && holdingsCount2 === 1 && holdingsCount3 === 2)) {
                    shortModel.append(permission1)
                    shortModel.append(permission2)
                    shortModel.append(permission3)
                    return
                }
            }

            // CASE 3: More than 2 permissions and didn't fit with previous conditions (dots visualized)
            if(modelCount > maxVisualPermissions) {
                dotsVisible = true
                shortModel.append(permission1)

                // More than 2 permissions but 1st and 2nd have only 1:1 or 1:2 tokens
                if((holdingsCount1 === 1 && holdingsCount2 === 1) ||
                   (holdingsCount1 === 2 && holdingsCount2 === 1) ||
                   (holdingsCount1 === 1 && holdingsCount2 === 2)) {
                    shortModel.append(permission2)
                }
            }
        }
    }

    implicitHeight: 24
    spacing: 4
    padding: 4

    background: Rectangle {
        color: root.backgroundColor
        radius: root.backgroundRadius
        border.color: root.backgroundBorderColor
    }

    contentItem: RowLayout {
        spacing: root.spacing

        StatusIcon {
            Layout.fillHeight: true
            Layout.preferredWidth: height

            icon: root.requirementsMet ? "tiny/unlocked" : "tiny/locked"
            color: root.hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
        }

        Repeater {
            id: repeater

            model: shortModel

            RowLayout {
                spacing: root.spacing

                SinglePermissionRow {
                    model: holdingsListModel
                }

                StatusBaseText {
                    visible: index !== (repeater.count - 1) || d.dotsVisible
                    text: qsTr("or")
                    font.pixelSize: root.fontPixelSize
                    color: Theme.palette.baseColor1
                }
            }
        }

        StatusRoundedComponent {
            Layout.fillHeight: true
            Layout.preferredWidth: height

            visible: d.dotsVisible
            color: Theme.palette.baseColor3
            border.color: root.backgroundColor
            border.width: root.overlappingBorder

            StatusIcon {
                anchors.centerIn: parent
                visible: d.dotsVisible
                icon: "dots-icon"
                height: root.dotsIconSize
                width: height
            }
        }

        StatusToolTip {
            text: root.requirementsMet ? qsTr("Eligible to join") : qsTr("Not eligible to join")
            visible: root.hovered
        }
    }

    ModelChangeTracker {
        model: d.filteredModel
        onRevisionChanged: d.buildShortModel(d.filteredModel)
    }

    ListModel { id: shortModel }

    component SinglePermissionRow: RowLayout {
        id: singlePermissionItem

        readonly property int maxVisualTokens: 3

        property var model
        property string plusElementText: ""
        property bool plusElementVisible: false

        function getVisualTokensCount(modelCount) {
            if(singlePermissionItem.maxVisualTokens < modelCount)
                 // Need of shorter model
                return singlePermissionItem.maxVisualTokens - 1
            // All elements in model
            return modelCount
        }

        function buildTokensRowModel(model) {
            shortTokensRowModel.clear()
            if(!model)
                return

            var modelCount = model.rowCount()

            for(var i = 0; i < getVisualTokensCount(modelCount); i++)
                shortTokensRowModel.append(ModelUtils.get(model, i))

            plusElementVisible = modelCount > maxVisualTokens
            if(plusElementVisible)
                plusElementText = qsTr("+%1").arg(modelCount - maxVisualTokens)
        }

        spacing: -root.overlapping

        onModelChanged: buildTokensRowModel(singlePermissionItem.model)
        Connections {
            target: singlePermissionItem.model
            function onCountChanged() {
                singlePermissionItem.buildTokensRowModel(singlePermissionItem.model)
            }
        }
        Component.onCompleted: buildTokensRowModel(singlePermissionItem.model)

        ListModel{ id: shortTokensRowModel }

        Repeater {
            model: HoldingsSelectionModel {
                sourceModel: shortTokensRowModel

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
            }

            StatusRoundedImage {
                Layout.fillHeight: true
                Layout.preferredWidth: height

                z: index
                image.source: model.imageSource
                color: "transparent"
                border.color: root.backgroundColor
                border.width: root.overlappingBorder
            }
        }

        StatusRoundedComponent {
            visible: singlePermissionItem.plusElementVisible
            Layout.fillHeight: true
            Layout.preferredWidth: height

            z: d.maxTokens
            color: Theme.palette.baseColor3
            border.color: root.backgroundColor
            border.width: root.overlappingBorder
            StatusBaseText {
                anchors.centerIn: parent
                text: singlePermissionItem.plusElementText
                color: Theme.palette.baseColor1
                font.pixelSize: root.fontPixelSize
            }
        }
    }
}
