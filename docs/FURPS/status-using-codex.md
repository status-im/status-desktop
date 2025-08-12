# Status using Codex - FURPS

## Shared Codex Requirements for Status

### Functionality

- Data stored via Codex must remain **available for at least 30 days**
- Content must be **accessible even if the original uploader is offline**
- Mobile clients must be able to **send/receive files without running full nodes** (light mode)

### Usability

- All interactions must be **transparent to end users** (ie users should not know or care if Codex or another storage protocol is used)
- Integration should not require users to configure Codex manually — behavior should be seamless and automatic
- Downloads should be **automated** with retry logic on failure

### Reliability

- Ensure file availability regardless of sender being offline or unresponsive
- Codex must provide a reliability of 99.99% the data will be available when **some** nodes are offline
- Resumable uploads and downloads must be supported

### Performance

- Desktop Codex nodes must not exceed:
  - while actively storing and/or sending:
    - **1000MB RAM**
    - **20% CPU**
  - while idle:
    - **100MB RAM**
    - **5% CPU**
- Storage limits must be **configurable** for Desktop nodes (e.g., maximum disk space used).
- Mobile clients must use **minimal resources**

### Supportability

- Must support a migration path so that there is never a breaking change in between consecutive versions of Status
  - eg: v0.1.0 works with v0.2.0. v0.2.0 works with v0.3.0, However, it is ok if v0.1.0 does **not** work with v0.3.0
- [nice to have] Codex should expose a **stable API through a C library** to enable integration with Status backend services
- Provide **clear documentation** for embedding Codex into Status:
  - Build instructions
  - Dependencies
  - Integration and deployment guidance
- Codex integration must support **structured logs and metrics** for debugging and performance monitoring
- The system must support **automated upgrade paths** to maintain protocol compatibility across versions


## Codex Integration for File Sharing

### Functionality

- Enable file sharing up to **50MB** in:
  - One-on-one chats  
  - Group chats (up to 20 members)
  - Communities (up to 10,000 members)
- Files must be retrievable even if the sender is **offline**

### Usability

- File sending should **feel instantaneous to users**, with uploading handled asynchronously in the background
- Receiving a file (download and decrypt) should complete in **under 30 seconds**, even on mobile nodes

### Reliability

- See shared requirements above

### Performance

- See shared requirements above

### Supportability

- See shared requirements above


## Codex Integration for Community Description

### Functionality

- The **community description** (defined in [`communities.proto`](https://github.com/status-im/status-go/blob/develop/protocol/protobuf/communities.proto)) must be:
  - Uploaded to Codex by the **control node** (a Status Desktop node)
  - Downloadable by all **existing community members**, including admins
  - Available to **new users** attempting to join the community
- The Codex integration must support the **replacement of Waku-based propagation** for this data type
- [Nice to have] Mutability of the description file or possbility to overwrite the previous description, since older descriptions are irrelevant

### Usability

- Retrieval of a community description must be **transparent and automatic** to the end user
- Fetching the description must not require users to manually retry or interact with the storage mechanism
- If the description is not immediately available, **retry logic or background fetching** should occur seamlessly

### Reliability

- Integrity of the description must be **verifiable by hash or signature**, to ensure authenticity and prevent tampering (Status protocol's responsability).

### Performance

- See shared requirements above

### Supportability

- See shared requirements above
