import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Profile.panels 1.0
import AppLayouts.Profile.controls 1.0
import AppLayouts.Wallet.controls 1.0
import StatusQ.Components 0.1

import utils 1.0

import Storybook 1.0

SplitView {
    id: root

    property int inShowcaseModelCount: inShowcaseCounter.value
    property int hiddenModelCount: hiddenCounter.value

    orientation: Qt.Vertical

    Logs { id: logs }

    ListModel {
        id: inShowcaseModelItem
        ListElement {
            showcaseKey: 1
            title: "Item 1"
            secondaryTitle: "Description 1"
            hasImage: true
            image: "https://picsum.photos/200/300?random=1"
            iconName: "https://picsum.photos/40/40?random=1"
            showcaseVisibility: 2
            name: "Test community"
            joined: true
            isControlNode: true
            color: "yellow"
            hasTag: true
            tagText: "New"
            tagAsset: "https://picsum.photos/40/40?random=1"
            tagLoading: true
        }
    }

    ListModel {
        id: hiddenModelItem
        ListElement {
            showcaseKey: 2
            title: "Item 1"
            secondaryTitle: "Description 1"
            hasImage: true
            image: "https://picsum.photos/200/300?random=1"
            iconName: "https://picsum.photos/40/40?random=1"
            showcaseVisibility: 0
            name: "Test community"
            joined: true
            isControlNode: true
            color: "yellow"
            tagVisible: true
            tagText: "New"
            tagAsset: "https://picsum.photos/40/40?random=1"
            tagLoading: true
        }
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        ProfileShowcasePanel {
            id: panel

            inShowcaseModel: inShowcaseModelItem
            hiddenModel: hiddenModelItem
            anchors.centerIn: parent
            width: parent.width - 16
            height: parent.height - 16
            emptyInShowcasePlaceholderText: "No items in showcase"
            emptyHiddenPlaceholderText: "No hidden items"
            showcaseLimit: limitCounter.value
            searchPlaceholderText: qsTr("Search not available in storybook")

            onChangePositionRequested: function (from, to) {
                inShowcaseModelItem.move(from, to, 1)
            }
            onSetVisibilityRequested: function (key, toVisibility) {
                for (var i = 0; i < inShowcaseModelItem.count; i++) {
                    if (inShowcaseModelItem.get(i).showcaseKey === key) {
                        inShowcaseModelItem.setProperty(i, "showcaseVisibility", toVisibility)
                        if(toVisibility === 0) {
                            let item = inShowcaseModelItem.get(i)
                            hiddenModelItem.append(item)
                            inShowcaseModelItem.remove(i, 1)
                        }
                        return
                    }
                }

                for (var i = 0; i < hiddenModelItem.count; i++) {
                    if (hiddenModelItem.get(i).showcaseKey === key) {
                        hiddenModelItem.setProperty(i, "showcaseVisibility", toVisibility)
                        if(toVisibility !== 0) {
                            let item = hiddenModelItem.get(i)
                            inShowcaseModelItem.append(item)
                            hiddenModelItem.remove(i, 1)
                        }
                        return
                    }
                }
            }

            delegate: ProfileShowcasePanelDelegate {
                id: delegate

                title: model ? model.title : ""
                secondaryTitle: model ? model.secondaryTitle : ""
                hasImage: model ? model.hasImage : false
                icon.name: model ? model.iconName : ""
                icon.source: model ? model.image : ""
                icon.color: model ? model.color : ""

                actionComponent: model && model.hasTag ? manageTokensCommunityTag : null

                Component {
                    id: manageTokensCommunityTag
                    ManageTokensCommunityTag {
                        Layout.maximumWidth: delegate.width *.4
                        communityName: model ? model.tagText : ""
                        communityId: ""
                        communityImage: model ? model.tagAsset : ""
                        loading: model ? model.tagLoading : false
                    }
                }
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel
        SplitView.fillWidth: true
        SplitView.preferredHeight: 200

        RowLayout {
            anchors.fill: parent
            spacing: 10

            ColumnLayout {
                Label {
                    text: "In showcase: " + inShowcaseCounter.value
                }
                Slider {
                    id: inShowcaseCounter
                    from: 0
                    to: limitCounter.value
                    stepSize: 1
                    value: limitCounter.value > 0 ? limitCounter.value - 1 : 0
                }
            }

            ColumnLayout {
                Label {
                    text: "Hidden: " + hiddenCounter.value
                }
                Slider {
                    id: hiddenCounter
                    from: 0
                    to: 200
                    stepSize: 1
                    value: 25
                }
            }
            ColumnLayout {
                Label {
                    text: "Showcase limit: " + limitCounter.value
                }
                Slider {
                    id: limitCounter
                    from: 0
                    to: 200
                    stepSize: 1
                    value: 5
                }
            }
        }
    }

    onInShowcaseModelCountChanged: {
        let count = inShowcaseModelCount - inShowcaseModelItem.count;
        let operation = count > 0 ? (i) =>{
                                        inShowcaseModelItem.append({
                                                                       showcaseKey: Math.random() * Math.random() * Math.random() * 1000,
                                                                       title: "Item " + i,
                                                                       secondaryTitle: "Description " + i,
                                                                       hasImage: true,
                                                                       image: "https://picsum.photos/200/300?random=" + i,
                                                                       iconName: "https://picsum.photos/40/40?random=" + i,
                                                                       showcaseVisibility: Math.random() > 0.5 ? Constants.ShowcaseVisibility.Everyone : Constants.ShowcaseVisibility.Contacts,
                                                                       name: "Test community",
                                                                       joined: true,
                                                                       isControlNode: true,
                                                                       color: "yellow",
                                                                       hasTag: Math.random() > 0.5,
                                                                       tagText: "New " + 1,
                                                                       tagAsset: "https://picsum.photos/40/40?random=" + i,
                                                                       tagLoading: Math.random() > 0.9
                                                                   })} : (i) => {
            inShowcaseModelItem.remove(inShowcaseModelItem.count - 1);
        }

        for (var i = 0; i < Math.abs(count); i++) {
            operation(i)
        }
    }

    onHiddenModelCountChanged: {
        let count = hiddenModelCount - hiddenModelItem.count;
        let operation = count > 0 ? (i) =>{
                                        hiddenModelItem.append({
                                                                   showcaseKey: Math.random() * Math.random() * Math.random() * 1000,
                                                                   title: "Item " + i,
                                                                   secondaryTitle: "Description " + i,
                                                                   hasImage: true,
                                                                   image: "https://picsum.photos/200/300?random=" + i,
                                                                   iconName: "https://picsum.photos/40/40?random=" + i,
                                                                   showcaseVisibility: Constants.ShowcaseVisibility.NoOne,
                                                                   name: "Test community",
                                                                   joined: true,
                                                                   memberRole: Constants.memberRole.owner,
                                                                   isControlNode: true,
                                                                   color: "yellow",
                                                                   hasTag: Math.random() > 0.5,
                                                                   tagText: "New " + i,
                                                                   tagAsset: "https://picsum.photos/40/40?random=" + i,
                                                                   tagLoading: Math.random() > 0.8
                                                               })} : (i) => {
            hiddenModelItem.remove(hiddenModelItem.count - 1);
        }

        for (var i = 0; i < Math.abs(count); i++) {
            operation(i)
        }
    }
}

// category: Panels
// status: good
