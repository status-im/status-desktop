package app.status.mobile;

import android.content.ContentResolver;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ImageDecoder;
import android.net.Uri;
import android.util.Log;
import android.webkit.MimeTypeMap;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

// Copies one shared image stream into the share-intake cache, normalized the
// same way as the iOS share extension: HEIC/HEIF is re-encoded as JPEG (the
// app's image validator and status-go do not decode it), JPEG only when
// larger than the cap. GIF/PNG/WebP keep their bytes (animation, transparency).
final class ShareImageTranscoder {
    private static final String TAG = "ShareImageTranscoder";
    // The chat compresses image messages to ~350 KB anyway, so nothing
    // visible is lost and the composer is spared decoding full-size photos.
    private static final int MAX_IMAGE_EDGE_PX = 2048;
    private static final int JPEG_QUALITY = 85;
    private static final Set<String> HEIF_MIMES = new HashSet<>(Arrays.asList(
            "image/heic", "image/heif", "image/heic-sequence", "image/heif-sequence"));

    private ShareImageTranscoder() {}

    // Returns the written file, or null when the stream could not be read.
    // A failed re-encode falls back to the original bytes.
    static File copyNormalized(Context ctx, Uri uri, String mime, File dir, String baseName) {
        ContentResolver resolver = ctx.getContentResolver();
        if (HEIF_MIMES.contains(mime)
                || ("image/jpeg".equals(mime) && isLargerThanCap(resolver, uri))) {
            File jpeg = new File(dir, baseName + ".jpg");
            if (writeJpeg(resolver, uri, jpeg)) return jpeg;
        }
        File out = new File(dir, baseName + extensionForMime(mime));
        return copyBytes(resolver, uri, out) ? out : null;
    }

    private static boolean isLargerThanCap(ContentResolver resolver, Uri uri) {
        BitmapFactory.Options bounds = new BitmapFactory.Options();
        bounds.inJustDecodeBounds = true;
        try (InputStream in = resolver.openInputStream(uri)) {
            if (in == null) return false;
            BitmapFactory.decodeStream(in, null, bounds);
        } catch (Exception e) {
            return false;
        }
        return Math.max(bounds.outWidth, bounds.outHeight) > MAX_IMAGE_EDGE_PX;
    }

    private static boolean writeJpeg(ContentResolver resolver, Uri uri, File out) {
        Bitmap bitmap = null;
        try {
            bitmap = ImageDecoder.decodeBitmap(ImageDecoder.createSource(resolver, uri),
                    (decoder, info, source) -> {
                        decoder.setAllocator(ImageDecoder.ALLOCATOR_SOFTWARE);
                        int w = info.getSize().getWidth();
                        int h = info.getSize().getHeight();
                        int longest = Math.max(w, h);
                        if (longest > MAX_IMAGE_EDGE_PX) {
                            double scale = (double) MAX_IMAGE_EDGE_PX / longest;
                            decoder.setTargetSize(
                                    Math.max(1, (int) Math.round(w * scale)),
                                    Math.max(1, (int) Math.round(h * scale)));
                        }
                    });
            try (OutputStream os = new FileOutputStream(out)) {
                if (bitmap.compress(Bitmap.CompressFormat.JPEG, JPEG_QUALITY, os)) return true;
            }
        } catch (Exception | OutOfMemoryError e) {
            Log.w(TAG, "JPEG transcode failed for " + uri + "; copying the original", e);
        } finally {
            if (bitmap != null) bitmap.recycle();
        }
        out.delete();
        return false;
    }

    private static boolean copyBytes(ContentResolver resolver, Uri uri, File out) {
        try (InputStream in = resolver.openInputStream(uri);
             OutputStream os = new FileOutputStream(out)) {
            if (in == null) {
                out.delete();
                return false;
            }
            byte[] buffer = new byte[64 * 1024];
            int read;
            while ((read = in.read(buffer)) != -1) {
                os.write(buffer, 0, read);
            }
            return true;
        } catch (Exception e) {
            Log.w(TAG, "failed to copy shared image " + uri, e);
            out.delete();
            return false;
        }
    }

    private static String extensionForMime(String mime) {
        String ext = MimeTypeMap.getSingleton().getExtensionFromMimeType(mime);
        return ext != null ? "." + ext : "";
    }
}
