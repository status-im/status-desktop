# Local User Backup FURPS ([#18106](https://github.com/status-im/status-app/issues/18106))

## Functionality
- Replace remote Waku-based storage with local file-based backup for user data (settings, contacts, chat IDs, etc.).
- Allow exporting user data to a local file at any  and every hour.
- Provide an import mechanism during profile setup or from settings to restore data from a backup file.

## Usability
- Present intuitive options in the UI to export and import data (with clear labels and explanations).
- Guide users through the import process during onboarding or in settings with minimal friction.
- Handle errors (e.g., corrupt or mismatched files) with informative, user-friendly messages.
- Make the location and format of the backup file clear and accessible.

## Reliability
- Ensure backward compatibility or graceful fallback if no backup is present.
- Ensure data integrity when saving and loading backups (e.g., hashing, validation, versioning).
- Fail safely: don’t overwrite current state unless the import is fully valid.
- Handle partial restores gracefully, ensuring app stability even if some data types fail.

## Performance
- Perform export and import operations quickly, even with large data sets.
- Minimize memory usage during backup and restore processes.
- Run file I/O operations asynchronously to avoid blocking the UI.

## Supportability
- Keep backup/export logic modular to support future extensions (e.g., selective data export).
