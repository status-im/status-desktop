import QtQuick 2.15

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
    \qmltype SettingsList
    \inherits StatusListView
    \inqmlmodule AppLayouts.Profile.controls

    \brief List view rendering setting entries

    Expected model structure:

    subsection          [int]    - identifier of the entry (Constants.settingsSubsection)
    text                [string] - readable name of the entry
    icon                [string] - icon name
    badgeCount          [int]    - number presented on the badge
    isExperimental      [bool]   - indicates if the beta tag should be presented
    experimentalTooltip [string] - tooltip text for the beta tag
*/
StatusListView {
    id: root

    property int currenctSubsection

    readonly property int availableWidth: width - leftMargin - rightMargin

    signal clicked(int subsection)

    spacing: Theme.halfPadding

    delegate: StatusNavigationListItem {
        id: delegate

        objectName: model.subsection + "-MenuItem"

        width: ListView.view.availableWidth
        title: model.text
        asset.name: model.icon
        selected: root.currenctSubsection === model.subsection
        highlighted: !!betaTagLoader.item && betaTagLoader.item.hovered
        badge.value: model.badgeCount

        Loader {
            id: betaTagLoader

            active: model.isExperimental
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding +
                                 (delegate.badge.visible
                                  ? delegate.badge.width + Theme.halfPadding : 0)

            sourceComponent: StatusBetaTag {
                tooltipText: model.experimentalTooltip
                cursorShape: Qt.PointingHandCursor
            }
        }

        onClicked: root.clicked(model.subsection)
    }

    section.property: "group"

    section.delegate: StatusBaseText {
        text: section
        color: Theme.palette.baseColor1

        width: ListView.view.availableWidth

        leftPadding: Theme.padding
        rightPadding: Theme.padding
        topPadding: Theme.smallPadding
        bottomPadding: Theme.smallPadding
    }
}
