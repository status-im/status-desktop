# Requirements for Status Communities — FURPS

These requirements are written with the Logos stack in mind, without associating a particular protocol to each requirement.

## Functionality

- **Community messages** (channel posts, updates) must be exchanged between users of the community in a real-time.
- The Community will be described in the **Community Description**
  - See Annex A below for the list of properties of the Community Description
- The Community Description must be available to all users of the community. Only the community owner can update the Community Description.
- Every user has access to the full Community Description **except when**:
  - The **Community** is private (ie has a token permission to become a member). Then, only members have access to:
      - The list of members
      - The list of channels
  - A **channel** is private (ie has a token permission to view and/or post). Then, only members of that channel have access to:
    - The list of members from that channel
- Fetching the Community Description of a previously unknown Community should take **less than 30 seconds**.
- Users must be aware of **changes** on the Community Description within 10 minutes.
  - Only changes on the Community Description published by the **Community owner** are valid.
- Communities support a **role model**:
  - **Owner**: the sole authority for publishing official Community description changes.
  - **Token masters**: same rights as owners except cannot manage other token masters.
  - **Admins**: same rights as token masters, except cannot deploy/mint/burn tokens.
- **Admins** can propose **partial updates** (e.g., channel edits, member changes) to the **Owner**.
- Within a Community, messages can be segregated by **channels**, for which users may have different **permission** access (read/write)
- Permissions may be defined using onchain **tokens** (token-gated channels) (see Annex A)
- Users that do **not** have the read permissions on a channel, must **not** be able to read messages on this channel (encryption must be used).

## Usability

- Automated retry for message sending and retrieval should apply **without additional configuration**.
- A message sent by a user should be received by another online user **within 500ms**.
- A message sent by a user should be marked as acknowledged **within 5 seconds** if another user was online.
- The usage of Waku content topics should be managed by the provided Chat SDK

## Reliability

- The Messaging Protocol must ensure **delivery of messages to subscribed peers**, even under:
  - Temporary disconnections
  - Slow or lossy networks
- A user who was offline must **eventually** be able to retrieve **all messages** of the Community, as long as they were **offline for less than 30 days**.
- A user that was offline **less than one week** must be able to retrieve all missed messages **within 5 minutes**.
- A user that was offline for **more than one week**, and **less than 30 days**, must be able to retrieve all missed messages **within 15 minutes**.

## Performance

- A Status Desktop instance should use **less than 10Mbps** on download and **5Mpbs** (avg per day) on upload
- A Status Mobile instance should use **less than 5GB per month** in total data transmitted.
- Messaging **Full** Nodes must not exceed:
  - **200MB RAM**
  - **5% CPU usage** on average when relaying
- Mobile clients must:
  - Use **minimal resources** when idle
  - Only subscribe to channels relevant to the user
  - Not relay or store unrelated messages

## Supportability

- Usage in Status must support easy configuration of light vs full mode
- Provide **monitoring and logging hooks** for message handling and topic subscriptions
- Ensure **compatibility across Status app versions**, including topic format and encryption
- Integration must support **structured debugging** tools to troubleshoot missed messages or delivery failures


# Annexes

## Annex A: Community Description

Full protobuf can be found here: https://github.com/status-im/status-go/blob/develop/protocol/protobuf/communities.proto

This list is a summary that's easier to read and also exludes all the deprecated and un-needed properties.

- Community Metadata
    - ID (public key)
    - Name
    - Description (textual summary)
    - Logo (thumbnail and large)
    - Banner image
    - Color
    - Intro message
    - Outro message
    - Tags
    - Active members count
  - Settings
    - All members can pin messages
    - Manual accept or automatic
  - Members
    - Joined Members
      - ID (public chat key)
      - Role (Owner, TokenMaster, Admin, None)
    - Banned Members
      - ID (public chat key)
      - DeleteAllMessages (when set to true, members know to delete the member's messages)
  - Chat
    - Identity
      - Name
      - Description (textual summary)
      - Emoji
      - Color
    - Position
    - Category ID
    - Channel settings
      - Viewers can post reactions
      - Hide channel if permissions are not met
    - Members
      - ID (public chat key)
      - Role (poster or viewer)
  - Category
    - ID
    - Name
    - Position
  - Tokens
    - ID
    - Name
    - Symbol
    - Addresses ([chainId]address)
    - Decimals
    - Type (ERC20, ERC721, ENS)
    - Image
  - Permisisons
    - ID
    - Type (become admin, become member, can view in channel, can view and post in channel, become token master, become owner)
    - Chat IDs (which channels are affected, if applicable)
    - Criteria
      - Token Type
      - Symbol
      - Contract Addresses ([chainId]address)
      - TokenIds (in the case of NFTs)
      - EnsPattern
      - Amount (in wei)