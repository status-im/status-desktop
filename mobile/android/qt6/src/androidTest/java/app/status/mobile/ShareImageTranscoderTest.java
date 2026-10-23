package app.status.mobile;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import android.content.Context;
import android.graphics.BitmapFactory;
import android.net.Uri;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.filters.SmallTest;
import androidx.test.platform.app.InstrumentationRegistry;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;

/**
 * Image normalization at share intake (see CONTEXT.md): neither the composer's
 * image validator nor status-go decodes HEIC, so shared HEIC/HEIF photos must
 * reach the composer as JPEG, as the iOS share extension already does.
 */
@RunWith(AndroidJUnit4.class)
@SmallTest
public class ShareImageTranscoderTest {

    private static final Context CTX =
            InstrumentationRegistry.getInstrumentation().getTargetContext();
    // Fixtures live in the test APK's assets, not the app's.
    private static final Context TEST_CTX =
            InstrumentationRegistry.getInstrumentation().getContext();

    private File inDir;
    private File outDir;

    @Before
    public void setUp() {
        inDir = new File(CTX.getCacheDir(), "share-transcoder-test-in");
        outDir = new File(CTX.getCacheDir(), "share-transcoder-test-out");
        assertTrue(inDir.mkdirs() || inDir.isDirectory());
        assertTrue(outDir.mkdirs() || outDir.isDirectory());
    }

    @After
    public void tearDown() {
        deleteDir(inDir);
        deleteDir(outDir);
    }

    @Test
    public void heicIsHandedOverAsJpegCappedAt2048() throws Exception {
        File heic = assetToFile("landscape-3000x2000.heic");

        File out = ShareImageTranscoder.copyNormalized(
                CTX, Uri.fromFile(heic), "image/heic", outDir, "share-1");

        assertNotNull(out);
        assertTrue("expected a .jpg copy, got " + out.getName(), out.getName().endsWith(".jpg"));
        BitmapFactory.Options bounds = decodeBounds(out);
        assertEquals("image/jpeg", bounds.outMimeType);
        assertEquals(2048, bounds.outWidth);
        assertEquals(1365, bounds.outHeight);
    }

    @Test
    public void undecodableHeicFallsBackToTheOriginalBytes() throws Exception {
        byte[] garbage = "not really a heic".getBytes("UTF-8");
        File heic = writeFile("broken.heic", garbage);

        File out = ShareImageTranscoder.copyNormalized(
                CTX, Uri.fromFile(heic), "image/heic", outDir, "share-2");

        assertNotNull(out);
        assertArrayEquals(garbage, Files.readAllBytes(out.toPath()));
    }

    private static BitmapFactory.Options decodeBounds(File file) {
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(file.getAbsolutePath(), opts);
        return opts;
    }

    private File assetToFile(String name) throws IOException {
        File out = new File(inDir, name);
        try (InputStream in = TEST_CTX.getAssets().open(name);
             OutputStream os = new FileOutputStream(out)) {
            byte[] buffer = new byte[64 * 1024];
            int read;
            while ((read = in.read(buffer)) != -1) {
                os.write(buffer, 0, read);
            }
        }
        return out;
    }

    private File writeFile(String name, byte[] bytes) throws IOException {
        File out = new File(inDir, name);
        try (OutputStream os = new FileOutputStream(out)) {
            os.write(bytes);
        }
        return out;
    }

    private static void deleteDir(File dir) {
        File[] files = dir.listFiles();
        if (files != null) {
            for (File f : files) f.delete();
        }
        dir.delete();
    }
}
