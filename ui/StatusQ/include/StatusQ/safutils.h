#pragma once

#include <QtGlobal>

extern "C" {

// Persist read/write permission for a SAF tree URI. No-op if not Android.
Q_DECL_EXPORT void statusq_saf_takePersistablePermission(const char* treeUri);

// Convenience: copy a filesystem path into a SAF tree, creating a document. Returns new document URI (malloc'd) or nullptr.
Q_DECL_EXPORT const char* statusq_saf_copyFromPathToTree(const char* srcPath,
                                                         const char* treeUri,
                                                         const char* mime,
                                                         const char* displayName);

// Produce a user-friendly display path for a SAF tree URI.
Q_DECL_EXPORT const char* statusq_saf_getReadableTreePath(const char* treeUri);

}
