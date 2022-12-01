import QtQuick 2.0

ListModel {
    Component.onCompleted:
        append([
                   {
                       key: "welcome",
                       iconSource: ModelsData.tokens.inch,
                       name: "#welcome"
                   },
                   {
                       key: "general",
                       iconSource: ModelsData.tokens.inch,
                       name: "#general"
                   }
               ])
}
