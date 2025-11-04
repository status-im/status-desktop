#pragma once

#include <QtGlobal>

extern "C" {

// Persist read/write permission for a SAF tree URI. No-op if not Android.
Q_DECL_EXPORT void statusq_saf_takePersistablePermission(const char* treeUri);

// Create a file in a SAF tree and return its document URI as a newly allocated C string.
// Caller must free() the returned pointer. Returns nullptr on failure.
Q_DECL_EXPORT const char* statusq_saf_createFileInTree(const char* treeUri,
                                                       const char* mime,
                                                       const char* displayName);

// Write bytes to an existing document URI via SAF. Returns true on success.
Q_DECL_EXPORT bool statusq_saf_writeBytesToUri(const char* documentUri,
                                               const void* data,
                                               int length);

// Open a writable file descriptor to an existing document URI. Returns -1 on failure.
Q_DECL_EXPORT int statusq_saf_openWritableFd(const char* documentUri);

// Convenience: copy a filesystem path into a SAF tree, creating a document. Returns new document URI (malloc'd) or nullptr.
Q_DECL_EXPORT const char* statusq_saf_copyFromPathToTree(const char* srcPath,
                                                         const char* treeUri,
                                                         const char* mime,
                                                         const char* displayName);

// Produce a user-friendly display path for a SAF tree URI.
Q_DECL_EXPORT const char* statusq_saf_getReadableTreePath(const char* treeUri);

}
