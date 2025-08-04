# Waku Requirements for Status Communities — FURPS

Note: These requirements assume the Community Description has been moved to Codex

## Functionality

- **Community messages** (channel posts, updates) must be sent and received via **Waku**.
- **Description change notifications** must be broadcast on Waku when the community description is updated via Codex.
  - Only the **control node** is authorized to publish description changes.
- **Partial updates** (e.g., channel edits, member changes) can be proposed by **admins**, but must be sent to the **control node** for approval before being published.
- Communities support a **permission model**:
  - **Control node**: the sole authority for publishing official community description changes.
  - **Token masters**: same rights as owners except cannot manage other token masters.
  - **Admins**: same rights as token masters, except cannot deploy/mint/burn tokens.
- Messages must be available on Waku **store nodes** for **at least 30 days**.
- Waku must support **channel-based topics**, including:
  - Public channels
  - **Token-gated channels**, where messages are encrypted and sent to dedicated Waku topics
- The system must support **message encryption** using the Status protocol or none, depending on the use case.
- **Mobile clients** must operate in **light mode** (filtering by topic of interest) and not relay all Waku traffic.

## Usability

- Message propagation and retrieval must be **transparent to end users**.
- Users should not experience delays when sending or receiving messages in real time.
- **Token-gated channel access** should require no manual topic configuration — the Status app must handle Waku topic subscriptions automatically.

## Reliability

- Waku must ensure **delivery of messages to subscribed peers**, even under:
  - Temporary disconnections
  - Slow or lossy networks
- Waku store nodes must reliably store messages for **30 days**, and make them retrievable on demand.
- Description change messages must be **deduplicated and verifiable**.

## Performance

- Desktop Waku nodes must not exceed:
  - **200MB RAM**
  - **5% CPU usage** on average when relaying
- Mobile clients must:
  - Use **minimal resources** when idle
  - Only subscribe to Waku topics relevant to the user
  - Not relay or store unrelated messages

## Supportability

- Waku usage in Status must support easy configuration of light vs full relay mode
- Provide **monitoring and logging hooks** for Waku message handling and topic subscriptions
- Ensure **compatibility across Status app versions**, including Waku topic format and encryption
- Waku integration must support **structured debugging** tools to troubleshoot missed messages or delivery failures
