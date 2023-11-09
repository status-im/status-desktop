import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import Models 1.0
import Storybook 1.0

import SortFilterProxyModel 0.2

import utils 1.0

SplitView {
    id: root

    component Separator: Rectangle {
        height: 30
        width: 300
        color: "green"
        Label {
            anchors.centerIn: parent
            color: "white"
            text: "separator"
        }
    }

    StatusLazyScrollView {
        id: scrollView
        // TODO: fix this
        //Layout.fillHeight: true //doesn't work well. The initial height of the listviews is max
        height: root.height
        Layout.fillWidth: true

        Rectangle {
            color: "transparent"
            border.color: "red"
            border.width: 5
            anchors.fill: parent
        }

        contentWidth: layout.width
        contentHeight: layout.height

        ColumnLayout {
            id: layout

            Separator {
                id: separator0
            }

            ListView {
                id: listview1
                objectName: "listview1"

                property int delegatesCount: 0
                onDelegatesCountChanged: listView1MaxDelegatesCount.number = Math.max(listView1MaxDelegatesCount.number, delegatesCount)

                NestedListViewAnchor {
                    target: listview1
                    anchorIn: scrollView.flickable
                }

                Label {
                    text: "Listview 1 top"
                    anchors.top: parent.top
                    anchors.right: parent.right
                }

                model: 50
                clip: true

                delegate: Rectangle {
                    height: Math.random() * 200
                    width: 50
                    color: Qt.rgba(Math.random(),Math.random(),Math.random(),1)
                    Label {
                        anchors.centerIn: parent
                        color: "white"
                        text: index
                    }

                    Component.onCompleted: listview1.delegatesCount++
                    Component.onDestruction: listview1.delegatesCount--
                }
            }

            Separator {
                id: separator1
            }

            ListView {
                id: listview2
                property int delegatesCount: 0
                onDelegatesCountChanged: listView2MaxDelegatesCount.number = Math.max(listView2MaxDelegatesCount.number, delegatesCount)


                NestedListViewAnchor {
                    target: listview2
                    anchorIn: scrollView.flickable
                }

                Label {
                    text: "Listview 2 top"
                    anchors.top: parent.top
                    anchors.right: parent.right
                }

                objectName: "listview2"
                model: 50
                clip: true
                delegate: Rectangle {
                    height: Math.random() * 200
                    width: 50
                    color: Qt.rgba(Math.random(),Math.random(),Math.random(),1)
                    Label {
                        anchors.centerIn: parent
                        color: "white"
                        text: index
                    }

                    Component.onCompleted: listview2.delegatesCount++
                    Component.onDestruction: listview2.delegatesCount--
                }
            }

            Separator {
                id: separator2
            }

            ListView {
                id: listview3

                property int delegatesCount: 0
                onDelegatesCountChanged: listView3MaxDelegatesCount.number = Math.max(listView3MaxDelegatesCount.number, delegatesCount)

                NestedListViewAnchor {
                    target: listview3
                    anchorIn: scrollView.flickable
                }

                Label {
                    text: "Listview 3 top"
                    anchors.top: parent.top
                    anchors.right: parent.right
                }

                model: 50
                clip: true

                objectName: "listview3"
                delegate: Rectangle {
                    height: Math.random() * 200
                    width: 50
                    color: Qt.rgba(Math.random(),Math.random(),Math.random(),1)
                    Label {
                        anchors.centerIn: parent
                        color: "white"
                        text: index
                    }

                    Component.onCompleted: {
                        listview3.delegatesCount++
                    }
                    Component.onDestruction: listview3.delegatesCount--
                }
            }

            Separator {
                id: separator3
            }
        }
    }

    Pane {
        SplitView.fillHeight: true
        SplitView.preferredWidth: 400
        ColumnLayout {
            Label {
                text: "Listview 1 delegates count: " + listview1.delegatesCount + " model count: " + listview1.count
            }
            Label {
                id: listView1MaxDelegatesCount
                property int number: 0
                text: "Listview 1 Max delegates count: " + number + " model count: " + listview1.count
            }
            Slider {
                from: 0
                to: 1000
                value: listview1.model
                onValueChanged: listview1.model = value
            }
            Label {
                text: "Listview 2 delegates count: " + listview2.delegatesCount + " model count: " + listview2.count
            }

            Label {
                id: listView2MaxDelegatesCount
                property int number: 0
                text: "Listview 1 Max delegates count: " + number + " model count: " + listview2.count
            }

            Slider {
                from: 0
                to: 1000
                value: listview2.model
                onValueChanged: listview2.model = value
            }

            Label {
                text: "Listview 3 delegates count: " + listview3.delegatesCount + " model count: " + listview3.count
            }
            Label {
                id: listView3MaxDelegatesCount
                property int number: 0
                text: "Listview 3 Max delegates count: " + number + " model count: " + listview3.count
            }

            Slider {
                from: 0
                to: 1000
                value: listview3.model
                onValueChanged: listview3.model = value
            }
        }
    }
}

// category: POC
