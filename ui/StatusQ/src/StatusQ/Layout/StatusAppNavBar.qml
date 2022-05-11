import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.13
import QtQml.Models 2.13
import Qt.labs.qmlmodels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

Rectangle {
    id: statusAppNavBar

    width: 78
    implicitHeight: 600
    color: Theme.palette.statusAppNavBar.backgroundColor

    property var sectionModel: []
    property string communityTypeRole: ""
    property int communityTypeValue: -1
    property int navBarButtonSpacing: 12

    property StatusNavBarTabButton navBarCameraButton 
    property StatusNavBarTabButton navBarProfileButton
    property Component regularNavBarButton
    property Component communityNavBarButton

    property var filterRegularItem: function(item) { return true; }
    property var filterCommunityItem: function(item) { return true; }

    signal aboutToUpdateFilteredRegularModel()
    signal aboutToUpdateFilteredCommunityModel()

    onNavBarProfileButtonChanged: {
        if (!!navBarProfileButton) {
            navBarProfileButton.parent = navBarProfileButtonSlot
        }
    }

    onNavBarCameraButtonChanged: {
        if (!!navBarCameraButton) {
            navBarCameraButton.parent = navBarCameraButtonSlot
        }
    }

    function triggerUpdate(){
        navBarModel.update()
    }

    StatusAppNavBarFilterModel {
        id: navBarModel

        filterAcceptsItem: filterRegularItem

        model: statusAppNavBar.sectionModel

        onAboutToUpdateFilteredModel: {
            statusAppNavBar.aboutToUpdateFilteredRegularModel()
        }

        DelegateChooser {
            id: delegateChooser
            role: communityTypeRole
            DelegateChoice { roleValue: communityTypeValue; delegate: communityNavButton }
            DelegateChoice { delegate: regularNavBarButton }
        }

        delegate: delegateChooser
    }

    Component {
        id: communityNavButton

        Item {
            width: parent.width
            height: (necessaryHightForCommunities > maxHightForCommunities)?
                        maxHightForCommunities : necessaryHightForCommunities

            property int communityNavBarButtonHeight: 40

            property int maxHightForCommunities: {
                let numOfOtherThanCommunityBtns = navBarListView.model.count - 1
                let numOfSpacingsForNavBar = navBarListView.model.count - 1

                return navBarListView.height -
                        numOfOtherThanCommunityBtns * communityNavBarButtonHeight -
                        numOfSpacingsForNavBar * navBarButtonSpacing
            }

            property int necessaryHightForCommunities: {
                let numOfSpacingsForCommunities = communityListView.model.count - 1
                return communityListView.model.count * communityNavBarButtonHeight +
                        numOfSpacingsForCommunities * navBarButtonSpacing +
                        separatorBottom.height
            }

            StatusAppNavBarFilterModel {
                id: navBarCommunityModel

                filterAcceptsItem: filterCommunityItem

                model: statusAppNavBar.sectionModel

                delegate: communityNavBarButton

                onAboutToUpdateFilteredModel: {
                    statusAppNavBar.aboutToUpdateFilteredCommunityModel()
                }
            }

            Item {
                id: separatorTop
                width: parent.width
                height: navBarButtonSpacing
                anchors.top: parent.top
                visible: parent.necessaryHightForCommunities > parent.maxHightForCommunities

                Rectangle {
                    height: 1
                    width: 30
                    color: Theme.palette.directColor7
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            ListView {
                id: communityListView
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: separatorTop.visible? separatorTop.bottom : parent.top
                anchors.bottom: separatorBottom.top
                clip: true

                spacing: navBarButtonSpacing

                model: navBarCommunityModel
            }

            Item {
                id: separatorBottom
                width: parent.width
                height: navBarButtonSpacing
                anchors.bottom: parent.bottom

                Rectangle {
                    height: 1
                    width: 30
                    color: Theme.palette.directColor7
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    ListView {
        id: navBarListView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 48
        anchors.bottom: navBarProfileButtonSlot.top
        anchors.bottomMargin: navBarButtonSpacing

        spacing: navBarButtonSpacing

        model: navBarModel
    }

    Item {
        id: navBarCameraButtonSlot
        anchors.horizontalCenter: parent.horizontalCenter
        height: visible? statusAppNavBar.navBarProfileButton.height : 0
        width: visible? statusAppNavBar.navBarProfileButton.width : 0
        visible: !!statusAppNavBar.navBarCameraButton
        anchors.bottom: navBarProfileButtonSlot.visible ? navBarProfileButtonSlot.top : parent.bottom
        anchors.bottomMargin: visible ? 12 : 0
    }


    Item {
        id: navBarProfileButtonSlot
        anchors.horizontalCenter: parent.horizontalCenter
        height: visible? statusAppNavBar.navBarProfileButton.height : 0
        width: visible? statusAppNavBar.navBarProfileButton.width : 0
        visible: !!statusAppNavBar.navBarProfileButton
        anchors.bottom: parent.bottom
        anchors.bottomMargin: visible ? 24 : 0
    }
}
