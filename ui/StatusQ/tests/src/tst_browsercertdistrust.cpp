#include <StatusQ/browserprofileutils.h>

#include <QByteArray>
#include <QSslCertificate>
#include <QTest>

namespace {

// Public certificate for `emSign ECC Root CA - G3` (from the Chrome Root Store).
constexpr char kEmSignEccRootG3Pem[] =
    "-----BEGIN CERTIFICATE-----\n"
    "MIICTjCCAdOgAwIBAgIKPPYHqWhwDtqLhDAKBggqhkjOPQQDAzBrMQswCQYDVQQG\n"
    "EwJJTjETMBEGA1UECxMKZW1TaWduIFBLSTElMCMGA1UEChMcZU11ZGhyYSBUZWNo\n"
    "bm9sb2dpZXMgTGltaXRlZDEgMB4GA1UEAxMXZW1TaWduIEVDQyBSb290IENBIC0g\n"
    "RzMwHhcNMTgwMjE4MTgzMDAwWhcNNDMwMjE4MTgzMDAwWjBrMQswCQYDVQQGEwJJ\n"
    "TjETMBEGA1UECxMKZW1TaWduIFBLSTElMCMGA1UEChMcZU11ZGhyYSBUZWNobm9s\n"
    "b2dpZXMgTGltaXRlZDEgMB4GA1UEAxMXZW1TaWduIEVDQyBSb290IENBIC0gRzMw\n"
    "djAQBgcqhkjOPQIBBgUrgQQAIgNiAAQjpQy4LRL1KPOxst3iAhKAnjlfSU2fySU0\n"
    "WXTsuwYc58Byr+iuL+FBVIcUqEqy6HyC5ltqtdyzdc6LBtCGI79G1Y4PPwT01xyS\n"
    "fvalY8L1X44uT6EYGQIrMgqCZH0Wk9GjQjBAMB0GA1UdDgQWBBR8XQKEE9TMipuB\n"
    "zhccLikenEhjQjAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAKBggq\n"
    "hkjOPQQDAwNpADBmAjEAvvNhzwIQHWSVB7gYboiFBS+DCBeQyh+KTOgNG3qxrdWB\n"
    "CUfvO6wIBHxcmbHtRwfSAjEAnbpV/KlK6O3t5nYBQnvI+GDZjVGLVTv7jHvrZQnD\n"
    "+JbNR6iC8hZVdyR+EhCVBCyj\n"
    "-----END CERTIFICATE-----\n";

// Synthetic leaf certificate signed with a throwaway random key whose issuer is
// `CN=EM OV TLS CA - G3C` (simulating a leaf-only TLS handshake from a
// compromised eMudhra G3 intermediate).
constexpr char kLeafIssuedByCompromisedIntermediatePem[] =
    "-----BEGIN CERTIFICATE-----\n"
    "MIIBJDCBy6ADAgECAgECMAoGCCqGSM49BAMCMB0xGzAZBgNVBAMMEkVNIE9WIFRM\n"
    "UyBDQSAtIEczQzAeFw0yNjAxMDEwMDAwMDBaFw0zNTEyMzAwMDAwMDBaMBsxGTAX\n"
    "BgNVBAMMEGxlYWYuZXhhbXBsZS5vcmcwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNC\n"
    "AARGtCBSuZIqw23gSDy2WxJSrRJZEMghO5Htftgd9HcE94Ol7Ko1Ya0xLh55lAGx\n"
    "OsOHlYX/+qAUb3MhdY7OiyHxMAoGCCqGSM49BAMCA0gAMEUCICYycRTB/cFu5nAr\n"
    "zAWwzdkSh2fYAKYxBR7gqi35l0qTAiEApDGtweVF2dGU5jFnGs81XiJuTLN40XPc\n"
    "aWM9yJV/K9s=\n"
    "-----END CERTIFICATE-----\n";

// Unrelated test certificate (`CN=example.org`, issuer `CN=Example Test Root CA`).
constexpr char kBenignCertPem[] =
    "-----BEGIN CERTIFICATE-----\n"
    "MIIBIjCByKADAgECAgEBMAoGCCqGSM49BAMCMB8xHTAbBgNVBAMMFEV4YW1wbGUg\n"
    "VGVzdCBSb290IENBMB4XDTI2MDEwMTAwMDAwMFoXDTM1MTIzMDAwMDAwMFowFjEU\n"
    "MBIGA1UEAwwLZXhhbXBsZS5vcmcwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAS6\n"
    "KK0YeD91uXvvU44RlmiX6u7rV5wrpiGbQtQRiHRDPGvf6Lea4F+48DCbtEUh6rGW\n"
    "C+AYNjnCh0xP0U+2wJHkMAoGCCqGSM49BAMCA0kAMEYCIQD+jbTDuuQnohEC0shc\n"
    "c2Z7d7H9lcYdYwFbQg7ewUjHSQIhAIpTraBEjtS5Kl7y+8fDhwA3MIg87UFC3xTo\n"
    "Gme6ohgp\n"
    "-----END CERTIFICATE-----\n";

constexpr char kExpectedCrsFlag[] =
    "--test-crs-constraints=86a1ecba089c4a8d3bbe2734c612ba341d813e043cf9e8a862cd5c57a36bbe6b:maxversionexclusive=0";

} // namespace

class tst_BrowserCertDistrust : public QObject
{
    Q_OBJECT

private slots:
    void applyChromiumCertDistrustFlags_populatesEmptyEnvAndIsIdempotent()
    {
        const QByteArray savedFlags = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
        qunsetenv("QTWEBENGINE_CHROMIUM_FLAGS");

        BrowserProfileUtils::applyChromiumCertDistrustFlags();
        const QByteArray first = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
        QCOMPARE(first, QByteArray(kExpectedCrsFlag));

        // Second call must not duplicate the switch.
        BrowserProfileUtils::applyChromiumCertDistrustFlags();
        QCOMPARE(qgetenv("QTWEBENGINE_CHROMIUM_FLAGS"), first);

        qputenv("QTWEBENGINE_CHROMIUM_FLAGS", savedFlags);
    }

    void applyChromiumCertDistrustFlags_preservesExistingSwitches()
    {
        const QByteArray savedFlags = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
        qputenv("QTWEBENGINE_CHROMIUM_FLAGS", "--disable-seccomp-filter-sandbox");

        BrowserProfileUtils::applyChromiumCertDistrustFlags();
        const QByteArray flags = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
        QVERIFY(flags.contains("--disable-seccomp-filter-sandbox"));
        QVERIFY(flags.contains(kExpectedCrsFlag));

        qputenv("QTWEBENGINE_CHROMIUM_FLAGS", savedFlags);
    }

    void isCertificateChainDistrusted_detectsEmSignRootAndIntermediates()
    {
        QVERIFY(!BrowserProfileUtils::isCertificateChainDistrusted({}));

        const auto benign = QSslCertificate::fromData(QByteArray(kBenignCertPem));
        QCOMPARE(benign.size(), 1);
        QVERIFY(!BrowserProfileUtils::isCertificateChainDistrusted(benign));

        const auto emSignRoot = QSslCertificate::fromData(QByteArray(kEmSignEccRootG3Pem));
        QCOMPARE(emSignRoot.size(), 1);
        QVERIFY(BrowserProfileUtils::isCertificateChainDistrusted(emSignRoot));

        const auto leafFromCompromisedCa =
            QSslCertificate::fromData(QByteArray(kLeafIssuedByCompromisedIntermediatePem));
        QCOMPARE(leafFromCompromisedCa.size(), 1);
        QVERIFY(BrowserProfileUtils::isCertificateChainDistrusted(leafFromCompromisedCa));
    }
};

QTEST_MAIN(tst_BrowserCertDistrust)
#include "tst_browsercertdistrust.moc"
