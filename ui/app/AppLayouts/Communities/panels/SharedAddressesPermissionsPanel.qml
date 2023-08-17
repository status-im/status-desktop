import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.views 1.0
import AppLayouts.Communities.helpers 1.0

import utils 1.0

Rectangle {
    id: root

    property bool isEditMode

    property string communityName
    property string communityIcon

    property var permissionsModel
    property var assetsModel
    property var collectiblesModel

    readonly property bool lostPermissionToJoin: d.lostPermissionToJoin
    readonly property bool lostChannelPermissions: d.lostChannelPermissions

    implicitHeight: permissionsScrollView.contentHeight - permissionsScrollView.anchors.topMargin
    color: Theme.palette.baseColor2

    QtObject {
        id: d

        // UI
        readonly property int absLeftMargin: 12
        readonly property color tableBorderColor: Theme.palette.directColor7

        // internal logic
        readonly property bool lostPermissionToJoin: root.isEditMode && joinPermissionsModel.count && !joinPermissionPanel.tokenCriteriaMet

        readonly property var uniquePermissionChannels:
            root.permissionsModel && root.permissionsModel.count ?
                PermissionsHelpers.getUniquePermissionChannels(root.permissionsModel, [PermissionTypes.Type.Read, PermissionTypes.Type.ViewAndPost])
              : []

        property var initialChannelPermissions

        function getChannelPermissions() {
            var result = {}
            for (let i = 0; i < channelPermissionsPanel.count; i++) {
                const channel = channelPermissionsPanel.itemAt(i)
                const ckey = channel.channelKey
                result[ckey] = [channel.readPermissionMet, channel.viewAndPostPermissionMet]
            }
            return result
        }
        readonly property bool lostChannelPermissions: root.isEditMode && d.uniquePermissionChannels.length > 0 && channelPermissionsPanel.anyPermissionLost

        // models
        readonly property var adminPermissionsModel: SortFilterProxyModel {
            id: adminPermissionsModel
            sourceModel: root.permissionsModel
            function filterPredicate(modelData) {
                return (modelData.permissionType === Constants.permissionType.admin) &&
                        (modelData.tokenCriteriaMet && !modelData.isPrivate) // admin privs are hidden if criteria not met
            }
            filters: ExpressionFilter {
                expression: adminPermissionsModel.filterPredicate(model)
            }
        }
        readonly property var joinPermissionsModel: SortFilterProxyModel {
            id: joinPermissionsModel
            sourceModel: root.permissionsModel
            function filterPredicate(modelData) {
                return (modelData.permissionType === Constants.permissionType.member) &&
                        (modelData.tokenCriteriaMet || !modelData.isPrivate)
            }
            filters: ExpressionFilter {
                expression: joinPermissionsModel.filterPredicate(model)
            }
        }
    }

    Component.onCompleted: {
        d.initialChannelPermissions = d.getChannelPermissions()
    }

    StatusScrollView {
        id: permissionsScrollView
        anchors.fill: parent
        anchors.topMargin: -Style.current.padding
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: Style.current.halfPadding

            // header
            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 4
                spacing: Style.current.padding
                StatusRoundedImage {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    Layout.leftMargin: d.absLeftMargin
                    image.source: root.communityIcon
                }
                StatusBaseText {
                    font.weight: Font.Medium
                    text: qsTr("Permissions")
                }
            }

            // permission types
            PermissionPanel {
                id: joinPermissionPanel
                permissionType: PermissionTypes.Type.Member
                permissionsModel: d.joinPermissionsModel
            }
            PermissionPanel {
                permissionType: PermissionTypes.Type.Admin
                permissionsModel: d.adminPermissionsModel
            }

            Repeater { // channel repeater
                id: channelPermissionsPanel
                model: d.uniquePermissionChannels
                delegate: ChannelPermissionPanel {}
                readonly property bool anyPermissionLost: {
                    for (let i = 0; i < channelPermissionsPanel.count; i++) {
                        const channel = channelPermissionsPanel.itemAt(i)
                        if (channel && channel.anyPermissionLost)
                            return true
                    }
                    return false
                }
            }
        }
    }

    component PanelBg: Rectangle {
        color: Theme.palette.statusListItem.backgroundColor
        border.width: 1
        border.color: Theme.palette.baseColor2
        radius: Style.current.radius
    }

    component PanelIcon: StatusRoundIcon {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        Layout.alignment: Qt.AlignTop
        asset.name: {
            switch (permissionType) {
            case PermissionTypes.Type.Admin:
                return "admin"
            case PermissionTypes.Type.Member:
                return "communities"
            default:
                return "channel"
            }
        }
        radius: height/2
    }

    component PanelHeading: StatusBaseText {
        Layout.fillWidth: true
        elide: Text.ElideRight
        font.weight: Font.Medium
        text: {
            switch (permissionType) {
            case PermissionTypes.Type.Admin:
                return qsTr("Become an admin")
            case PermissionTypes.Type.Member:
                return qsTr("Join %1").arg(root.communityName)
            default:
                return d.uniquePermissionChannels[index][1]
            }
        }
    }

    component SinglePermissionFlow: Flow {
        Layout.fillWidth: true
        spacing: Style.current.halfPadding
        Repeater {
            model: HoldingsSelectionModel {
                sourceModel: model.holdingsListModel
                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
            }
            delegate: Row {
                spacing: 4
                StatusRoundedImage {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16
                    image.source: model.imageSource
                }
                StatusBaseText {
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.tertiaryTextFontSize
                    text: model.text
                    color: model.available ? Theme.palette.successColor1 : Theme.palette.directColor1
                }
            }
        }
    }

    component PermissionPanel: Control {
        id: permissionPanel
        property int permissionType: PermissionTypes.Type.None
        property var permissionsModel

        readonly property bool tokenCriteriaMet: overallPermissionRow.tokenCriteriaMet

        visible: permissionsModel.count
        Layout.fillWidth: true
        padding: d.absLeftMargin
        background: PanelBg {}
        contentItem: RowLayout {
            spacing: Style.current.padding
            PanelIcon {}
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                PanelHeading {}
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: grid.implicitHeight + grid.anchors.margins*2
                    border.width: 1
                    border.color: d.tableBorderColor
                    radius: Style.current.radius
                    color: "transparent"

                    GridLayout {
                        id: grid
                        anchors.fill: parent
                        anchors.margins: Style.current.halfPadding
                        rowSpacing: Style.current.halfPadding
                        columnSpacing: Style.current.halfPadding
                        columns: 2

                        Repeater {
                            id: permissionsRepeater

                            property int revision
                            onItemAdded: revision++
                            onItemRemoved: revision++

                            model: permissionPanel.permissionsModel
                            delegate: ColumnLayout {
                                Layout.column: 0
                                Layout.row: index
                                Layout.fillWidth: true
                                spacing: Style.current.halfPadding

                                readonly property bool tokenCriteriaMet: model.tokenCriteriaMet ?? false
                                onTokenCriteriaMetChanged: permissionsRepeater.revision++

                                SinglePermissionFlow {}

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: -grid.anchors.leftMargin
                                    Layout.rightMargin: -grid.anchors.rightMargin
                                    Layout.preferredHeight: 1
                                    color: d.tableBorderColor
                                    visible: index < permissionsRepeater.count - 1
                                }
                            }
                        }
                        RowLayout {
                            id: overallPermissionRow
                            Layout.column: 1
                            Layout.rowSpan: permissionsRepeater.count || 1
                            Layout.preferredWidth: 110
                            Layout.fillHeight: true

                            readonly property bool tokenCriteriaMet: {
                                permissionsRepeater.revision
                                for (var i = 0; i < permissionsRepeater.count; i++) { // NB no let/const here b/c of https://bugreports.qt.io/browse/QTBUG-91917
                                    var permissionItem = permissionsRepeater.itemAt(i);
                                    if (permissionItem && permissionItem.tokenCriteriaMet)
                                        return true
                                }
                                return false
                            }

                            Rectangle {
                                Layout.preferredWidth: 1
                                Layout.fillHeight: true
                                Layout.topMargin: -Style.current.halfPadding
                                Layout.bottomMargin: -Style.current.halfPadding
                                color: d.tableBorderColor
                            }
                            Row {
                                Layout.alignment: Qt.AlignCenter
                                StatusIcon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 16
                                    height: 16
                                    icon: overallPermissionRow.tokenCriteriaMet ? "tiny/checkmark" : "tiny/secure"
                                    color: {
                                        if (d.lostPermissionToJoin)
                                            return Theme.palette.dangerColor1
                                        if (overallPermissionRow.tokenCriteriaMet)
                                            return Theme.palette.successColor1
                                        return Theme.palette.baseColor1
                                    }
                                }
                                StatusBaseText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.pixelSize: Theme.tertiaryTextFontSize
                                    text: {
                                        switch (permissionPanel.permissionType) {
                                        case PermissionTypes.Type.Admin:
                                            return qsTr("Admin")
                                        case PermissionTypes.Type.Member:
                                            return qsTr("Join")
                                        case PermissionTypes.Type.Read:
                                            return qsTr("View only")
                                        case PermissionTypes.Type.ViewAndPost:
                                            return qsTr("View & post")
                                        default:
                                            return "???"
                                        }
                                    }

                                    color: {
                                        if (d.lostPermissionToJoin)
                                            return Theme.palette.dangerColor1
                                        if (overallPermissionRow.tokenCriteriaMet)
                                            return Theme.palette.directColor1
                                        return Theme.palette.baseColor1
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component ChannelPermissionPanel: Control {
        id: channelPermsPanel
        Layout.fillWidth: true
        spacing: 10
        padding: d.absLeftMargin
        background: PanelBg {}

        readonly property string channelKey: modelData[0]
        readonly property bool readPermissionMet: channelPermsRepeater.count > 0 ? channelPermsRepeater.itemAt(0).tokenCriteriaMet : false
        readonly property bool viewAndPostPermissionMet: channelPermsRepeater.count > 1 ? channelPermsRepeater.itemAt(1).tokenCriteriaMet : false
        readonly property bool anyPermissionLost: channelPermsRepeater.count > 0 ? channelPermsRepeater.itemAt(0).permissionLost || channelPermsRepeater.itemAt(1).permissionLost : false

        contentItem: RowLayout {
            spacing: Style.current.padding
            PanelIcon {}
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Style.current.smallPadding
                PanelHeading {}
                Repeater { // permissions repeater
                    id: channelPermsRepeater
                    model: [PermissionTypes.Type.Read, PermissionTypes.Type.ViewAndPost]

                    delegate: Rectangle {
                        id: channelPermsSubPanel

                        readonly property int permissionType: modelData
                        readonly property alias tokenCriteriaMet: overallPermissionRow2.tokenCriteriaMet
                        readonly property bool permissionLost: d.initialChannelPermissions[channelPermsPanel.channelKey][index] && !tokenCriteriaMet

                        Layout.fillWidth: true
                        Layout.preferredHeight: grid2.implicitHeight + grid2.anchors.margins*2
                        border.width: 1
                        border.color: d.tableBorderColor
                        radius: Style.current.radius
                        color: "transparent"

                        GridLayout {
                            id: grid2
                            anchors.fill: parent
                            anchors.margins: Style.current.halfPadding
                            rowSpacing: Style.current.halfPadding
                            columnSpacing: Style.current.halfPadding
                            columns: 2

                            Repeater {
                                id: permissionsRepeater2

                                property int revision
                                onItemAdded: revision++
                                onItemRemoved: revision++

                                model: SortFilterProxyModel {
                                    id: channelPermissionsModel
                                    sourceModel: root.permissionsModel
                                    function filterPredicate(modelData) {
                                        return modelData.permissionType === channelPermsSubPanel.permissionType &&
                                                !modelData.isPrivate &&
                                                ModelUtils.contains(modelData.channelsListModel, "key", channelPermsPanel.channelKey) // filter and group by channel "key"
                                    }
                                    filters: ExpressionFilter {
                                        expression: channelPermissionsModel.filterPredicate(model)
                                    }
                                }
                                delegate: ColumnLayout {
                                    Layout.column: 0
                                    Layout.row: index
                                    Layout.fillWidth: true
                                    spacing: Style.current.halfPadding

                                    readonly property bool tokenCriteriaMet: model.tokenCriteriaMet ?? false
                                    onTokenCriteriaMetChanged: permissionsRepeater2.revision++

                                    SinglePermissionFlow {}

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.leftMargin: -grid2.anchors.leftMargin
                                        Layout.rightMargin: -grid2.anchors.rightMargin
                                        Layout.preferredHeight: 1
                                        color: d.tableBorderColor
                                        visible: index < permissionsRepeater2.count - 1
                                    }
                                }
                            }

                            RowLayout {
                                id: overallPermissionRow2
                                Layout.column: 1
                                Layout.rowSpan: channelPermissionsModel.count || 1
                                Layout.preferredWidth: 110
                                Layout.fillHeight: true

                                readonly property bool tokenCriteriaMet: {
                                    permissionsRepeater2.revision
                                    for (var i = 0; i < permissionsRepeater2.count; i++) { // NB no let/const here b/c of https://bugreports.qt.io/browse/QTBUG-91917
                                        const permissionItem = permissionsRepeater2.itemAt(i);
                                        if (permissionItem && permissionItem.tokenCriteriaMet)
                                            return true
                                    }
                                    return false
                                }

                                Rectangle {
                                    Layout.preferredWidth: 1
                                    Layout.fillHeight: true
                                    Layout.topMargin: -Style.current.halfPadding
                                    Layout.bottomMargin: -Style.current.halfPadding
                                    color: d.tableBorderColor
                                }
                                Row {
                                    Layout.alignment: Qt.AlignCenter
                                    StatusIcon {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 16
                                        height: 16
                                        icon: overallPermissionRow2.tokenCriteriaMet ? "tiny/checkmark" : "tiny/secure"
                                        color: {
                                            if (channelPermsSubPanel.permissionLost)
                                                return Theme.palette.dangerColor1
                                            if (overallPermissionRow2.tokenCriteriaMet)
                                                return Theme.palette.successColor1
                                            return Theme.palette.baseColor1
                                        }
                                    }
                                    StatusBaseText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font.pixelSize: Theme.tertiaryTextFontSize
                                        text: {
                                            switch (channelPermsSubPanel.permissionType) {
                                            case PermissionTypes.Type.Read:
                                                return qsTr("View only")
                                            case PermissionTypes.Type.ViewAndPost:
                                                return qsTr("View & post")
                                            default:
                                                return "???"
                                            }
                                        }

                                        color: {
                                            if (channelPermsSubPanel.permissionLost)
                                                return Theme.palette.dangerColor1
                                            if (overallPermissionRow2.tokenCriteriaMet)
                                                return Theme.palette.directColor1
                                            return Theme.palette.baseColor1
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
