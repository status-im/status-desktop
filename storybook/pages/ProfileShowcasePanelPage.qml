import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Profile.panels 1.0
import AppLayouts.Profile.controls 1.0
import StatusQ.Components 0.1

import utils 1.0

import Storybook 1.0

SplitView {
    //id: root

    property int inShowcaseModelCount: inShowcaseCounter.value
    property int hiddenModelCount: hiddenCounter.value

    orientation: Qt.Vertical

    Logs { id: logs }

    ListModel {
        id: inShowcaseModelItem
        ListElement {
            key: 1
            title: "Item 1"
            secondaryTitle: "Description 1"
            hasImage: true
            image: "https://picsum.photos/200/300?random=1"
            iconName: "https://picsum.photos/40/40?random=1"
            visibility: 1
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
            key: 2
            title: "Item 1"
            secondaryTitle: "Description 1"
            hasImage: true
            image: "https://picsum.photos/200/300?random=1"
            iconName: "https://picsum.photos/40/40?random=1"
            visibility: 0
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

    ProfileShowcasePanel {
        id: root
        inShowcaseModel: inShowcaseModelItem
        hiddenModel: hiddenModelItem
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        emptyInShowcasePlaceholderText: "No items in showcase"
        emptyHiddenPlaceholderText: "No hidden items"
        onChangePositionRequested: function (key, to) {
            for (var i = 0; i < inShowcaseModelItem.count; i++) {
                if (inShowcaseModelItem.get(i).key === key) {
                    inShowcaseModelItem.move(i, to, 1)
                    break
                }
            }

            for (var i = 0; i < hiddenModelItem.count; i++) {
                if (hiddenModelItem.get(i).key === key) {
                    hiddenModelItem.move(from, to, 1)
                    break
                }
            }
        }
        onSetVisibilityRequested: function (key, toVisibility) {
            for (var i = 0; i < inShowcaseModelItem.count; i++) {
                if (inShowcaseModelItem.get(i).key === key) {
                    inShowcaseModelItem.setProperty(i, "visibility", toVisibility)
                    if(toVisibility === 0) {
                        let item = inShowcaseModelItem.get(i)
                        hiddenModelItem.append(item)
                        inShowcaseModelItem.remove(i, 1)
                    }
                    return
                }
            }

            for (var i = 0; i < hiddenModelItem.count; i++) {
                if (hiddenModelItem.get(i).key === key) {
                    hiddenModelItem.setProperty(i, "visibility", toVisibility)
                    if(toVisibility !== 0) {
                        let item = hiddenModelItem.get(i)
                        inShowcaseModelItem.append(item)
                        hiddenModelItem.remove(i, 1)
                    }
                    return
                }
            }
        }

        delegate: ProfileShowcasePanel.Delegate {
            title: model ? model.title : ""
            secondaryTitle: model ? model.secondaryTitle : ""
            hasImage: model ? model.hasImage : false
            icon.name: model ? model.iconName : ""
            icon.source: model ? model.image : ""
            icon.color: model ? model.color : ""

            tag.visible: model ? model.hasTag : false
            tag.text: model ? model.tagText : ""
            tag.asset.name: model ? model.tagAsset : ""
            tag.loading: model ? model.tagLoading : false
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
                    to: 200
                    stepSize: 1
                    value: 25
                }

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
        }
    }

    onInShowcaseModelCountChanged: {
        let count = inShowcaseModelCount - inShowcaseModelItem.count;
        let operation = count > 0 ? (i) =>{
                                   inShowcaseModelItem.append({
                                       key: Math.random() * Math.random() * Math.random() * 1000,
                                       title: "Item " + i,
                                       secondaryTitle: "Description " + i,
                                       hasImage: true,
                                       image: "https://picsum.photos/200/300?random=" + i,
                                       iconName: "https://picsum.photos/40/40?random=" + i,
                                       visibility: Math.ceil(Math.random() * 3),
                                        name: "Test community",
                                        joined: true,
                                        isControlNode: true,
                                        color: "yellow",
                                        hasTag: Math.random() > 0.5,
                                        tagText: "New " + 1,
                                        tagAsset: "https://picsum.photos/40/40?random=" + i,
                                        tagLoading: Math.random() > 0.5
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
                                       key: Math.random() * Math.random() * Math.random() * 1000,
                                       title: "Item " + i,
                                       secondaryTitle: "Description " + i,
                                       hasImage: true,
                                       image: "https://picsum.photos/200/300?random=" + i,
                                       iconName: "https://picsum.photos/40/40?random=" + i,
                                       visibility: 0,
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
