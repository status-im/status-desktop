package app.status.mobile;

import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import androidx.documentfile.provider.DocumentFile;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * Storage Access Framework helper utilities for writing to user-selected folders.
 *
 * All methods are static and obtain the current Qt Activity internally.
 */
public final class SafHelper {
    private SafHelper() {}

    /**
     * Persist read/write permission to a previously selected tree URI.
     */
    public static void takePersistablePermission(Context context, String treeUriString) {
        if (context == null || treeUriString == null || treeUriString.isEmpty()) return;
        Uri uri = Uri.parse(treeUriString);
        final int flags = Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION;
        try {
            context.getContentResolver().takePersistableUriPermission(uri, flags);
        } catch (SecurityException ignored) {
        }
    }

    /**
     * Create a document (file) inside the given tree URI. Returns the created document URI string or empty on failure.
     */
    public static String createFileInTree(Context context, String treeUriString, String mime, String displayName) {
        if (context == null || treeUriString == null || treeUriString.isEmpty()) return "";
        Uri treeUri = Uri.parse(treeUriString);
        DocumentFile tree = DocumentFile.fromTreeUri(context, treeUri);
        if (tree == null) return "";
        if (mime == null || mime.isEmpty()) mime = "application/octet-stream";
        if (displayName == null || displayName.isEmpty()) displayName = "backup.bkp";
        DocumentFile file = tree.createFile(mime, displayName);
        return file != null ? file.getUri().toString() : "";
    }

    /**
     * Write the provided bytes into an existing document URI. Returns true on success.
     */
    public static boolean writeBytesToUri(Context context, String documentUriString, byte[] data) {
        if (context == null || documentUriString == null || documentUriString.isEmpty() || data == null) return false;
        Uri uri = Uri.parse(documentUriString);
        try (OutputStream os = context.getContentResolver().openOutputStream(uri, "w")) {
            if (os == null) return false;
            os.write(data);
            os.flush();
            return true;
        } catch (IOException e) {
            return false;
        }
    }

    /**
     * Open a writable file descriptor for an existing document URI and return its raw UNIX fd.
     * Caller is responsible for closing the fd at native side.
     */
    public static int openWritableFd(Context context, String documentUriString) throws IOException {
        if (context == null || documentUriString == null || documentUriString.isEmpty())
            throw new IOException("Invalid context or URI");
        Uri uri = Uri.parse(documentUriString);
        ContentResolver cr = context.getContentResolver();
        android.os.ParcelFileDescriptor pfd = cr.openFileDescriptor(uri, "w");
        if (pfd == null) throw new IOException("openFileDescriptor returned null");
        return pfd.detachFd();
    }

    /**
     * Convenience: copy a file from a temporary filesystem path into a destination SAF tree.
     * Returns the created document URI string, or empty on failure.
     */
    public static String copyFromPathToTree(Context context, String srcPath, String treeUriString, String mime, String displayName) {
        if (context == null || treeUriString == null || treeUriString.isEmpty() || srcPath == null || srcPath.isEmpty()) return "";
        Uri treeUri = Uri.parse(treeUriString);
        DocumentFile tree = DocumentFile.fromTreeUri(context, treeUri);
        if (tree == null) return "";
        if (mime == null || mime.isEmpty()) mime = "application/octet-stream";
        if (displayName == null || displayName.isEmpty()) displayName = "backup.bkp";
        DocumentFile file = tree.createFile(mime, displayName);
        if (file == null) return "";
        Uri destUri = file.getUri();

        try (InputStream is = new FileInputStream(srcPath);
             OutputStream os = context.getContentResolver().openOutputStream(destUri, "w")) {
            if (os == null) return "";
            byte[] buf = new byte[8192];
            int r;
            while ((r = is.read(buf)) != -1) {
                os.write(buf, 0, r);
            }
            os.flush();
            return destUri.toString();
        } catch (IOException e) {
            // Best-effort cleanup could be added here
            return "";
        }
    }

    /**
     * Derive a user-friendly display path for a SAF tree URI, e.g.
     *   content://... tree "primary:Documents/Backups" -> "Internal storage/Documents/Backups".
     * Falls back to URI lastPathSegment or the full URI if not recognized.
     */
    public static String getReadableTreePath(String treeUriString) {
        if (treeUriString == null || treeUriString.isEmpty()) return "";
        Uri uri = Uri.parse(treeUriString);
        try {
            String docId = android.provider.DocumentsContract.getTreeDocumentId(uri);
            if (docId == null || docId.isEmpty()) docId = uri.getLastPathSegment();
            if (docId == null) return treeUriString;

            String[] parts = docId.split(":", 2);
            String volume = parts.length > 0 ? parts[0] : "";
            String relPath = parts.length > 1 ? parts[1] : "";
            String volLabel;
            if ("primary".equalsIgnoreCase(volume)) {
                volLabel = "Internal storage";
            } else if (volume != null && !volume.isEmpty()) {
                volLabel = "SD card"; // generic label; device-specific labels require StorageManager
            } else {
                volLabel = "Storage";
            }
            if (relPath == null || relPath.isEmpty()) return volLabel;
            // Ensure we don't accidentally escape
            relPath = relPath.replaceAll("^/+", "");
            return volLabel + "/" + relPath;
        } catch (Throwable t) {
            String last = uri.getLastPathSegment();
            return last != null ? last : treeUriString;
        }
    }
}
