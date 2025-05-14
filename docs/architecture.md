
# Architecture of Status Desktop


## Top level architecture

This shows the flow from the UI all the way to the backend.

We do not use servers. [status-go](https://github.com/status-im/status-go) is what our app considers the backend and as such, it has it's own local databases to contain the user data.

```mermaid
flowchart LR
    qml["Frontend (QML)"] --> statusq(["StatusQ"])
    qml --> dotherside{{"DOtherside"}}
    dotherside --> nimqml{{"NimQML"}}
    nimqml --> nim["Middleware (Nim)"]
    nim --> statusgo{{"Backend (status-go)"}}
    statusgo --> waku{{"Waku"}}
    statusgo --> providers[["Wallet providers"]]
    statusgo --> db[(Local Databases)]
    subgraph Legend
      direction LR
      box["Status Desktop code"]
      roundedbox(["In-repo Library"])
      hexagon{{"Out of repo libraries"}}
      barbox[["External providers"]]
    end
    click qml "https://github.com/status-im/status-desktop/tree/master/ui" "Link to the UI folder containing the QML code"
    click statusq "https://github.com/status-im/status-desktop/tree/master/ui/StatusQ" "Link to the StatusQ folder"
    click dotherside "https://github.com/status-im/dotherside" "Link to the DOtherSide repo"
    click nimqml "https://github.com/status-im/nimqml" "Link to the NimQML repo"
    click nim "https://github.com/status-im/status-desktop/tree/master/src" "Link to the Nim code"
    click statusgo "https://github.com/status-im/status-go" "Link to the Status-Go repo"
    click waku "https://github.com/waku-org" "Link to the Waku org"
```

