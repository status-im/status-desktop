#include "StatusQ/browserprofileutils.h"

#include <QtWebEngineQuick/qquickwebengineprofile.h>
#include <QtWebEngineCore/QWebEngineCookieStore>
#include <QtWebEngineCore/QWebEngineDownloadRequest>
#include <QtWebEngineCore/QWebEnginePage>
#include <QtWebEngineCore/QWebEngineProfile>
#include <QtWebEngineCore/QWebEngineUrlRequestInfo>
#include <QtWebEngineCore/QWebEngineUrlRequestInterceptor>

#include <QDir>
#include <QFileInfo>
#include <QCryptographicHash>
#include <QNetworkCookie>
#include <QPointer>
#include <QSet>
#include <QSslKey>
#include <QStandardPaths>
#include <QTimer>

namespace {

// Chrome Root Store constraint override that disables trust in
// `emSign ECC Root CA - G3` (SHA-256: 86a1ecba...bbe6b), the root certificate
// above the eight compromised eMudhra G3 intermediate CAs disclosed in Oct 2026.
// Setting maxversionexclusive=0 causes CertVerifyProcBuiltin to fail path
// verification with kChromeRootConstraintsFailed (ERR_CERT_AUTHORITY_INVALID)
// on all desktop platforms without waiting for a Qt WebEngine rebuild.
constexpr char kEmSignEccRootG3CrsConstraintFlag[] =
    "--test-crs-constraints=86a1ecba089c4a8d3bbe2734c612ba341d813e043cf9e8a862cd5c57a36bbe6b:maxversionexclusive=0";

// SHA-256 fingerprints (lowercase hex) of the 8 compromised eMudhra G3
// intermediate certificates (from Chromium net/data/ssl/blocklist) plus
// emSign Root TLS CA - G3 and emSign ECC Root CA - G3.
const QSet<QByteArray> &distrustedCertSha256Hex()
{
    static const QSet<QByteArray> kSet = {
        QByteArrayLiteral("0164d7ceae5bb909c272af151ff44b1177ae9b47d9424b94f1d9558c30934d19"), // EM DV TLS CA - G3C
        QByteArrayLiteral("42c4accd12c4f59597925e1a08a7a90102608543809308d50ec427e118ba1493"), // EM DV TLS CA - G3B
        QByteArrayLiteral("432ec25f0d28de9006d97bf752f17bbb2cd41f669933fcb072d9a1148d0261f3"), // EM EV TLS CA - G3C
        QByteArrayLiteral("4b2460a466f95fd40113bcdcca2ceb29b3b093921de45474da7df48874c630b1"), // EM OV CS CA - G3C
        QByteArrayLiteral("98b896625c0c230adeec3eb2cf6aad5001ecf9156a68644e82374ce5833bc25b"), // EM OV TLS CA - G3B
        QByteArrayLiteral("9e39de2881273acc225a149c72ba3e0f51424963669ab633ee1dc7df5db067b4"), // EM OV CS CA - G3B
        QByteArrayLiteral("cb6e15165ac802e9b3f993f16c25d41f4e81c21ebde71ae1b012ac00bf9c7c3f"), // EM OV TLS CA - G3C
        QByteArrayLiteral("e7568fe6e12331f4fd7de61da4c7559d0f8eb192a218d4741a3ba75184333838"), // EM EV TLS CA - G3B
        QByteArrayLiteral("3094025792039a68af6e553686410bdab7c0d4a36b9084cba64202e35d6ebbdd"), // emSign Root TLS CA - G3
        QByteArrayLiteral("86a1ecba089c4a8d3bbe2734c612ba341d813e043cf9e8a862cd5c57a36bbe6b"), // emSign ECC Root CA - G3
    };
    return kSet;
}

// SHA-256 of SubjectPublicKeyInfo DER (lowercase hex) for the 8 compromised
// eMudhra keys plus emSign Root TLS CA - G3 and emSign ECC Root CA - G3.
const QSet<QByteArray> &distrustedSpkiSha256Hex()
{
    static const QSet<QByteArray> kSet = {
        QByteArrayLiteral("49dd353dc2b919a3770645117d0e60c16115e7d1bc259eefe734b00ea434fe5f"), // EM DV TLS CA - G3C
        QByteArrayLiteral("ebed6475c2c2d80fcb199f3fe8dd6e6b3ce60b77eb15d4e42c3dec0c6f5b5105"), // EM DV TLS CA - G3B
        QByteArrayLiteral("5c0660a2b164910d8ff589c18e14552e9e0ec237dcefe2cb736d41a4811f81a0"), // EM EV TLS CA - G3C
        QByteArrayLiteral("92c063d67e8f14db71d288e11266ffdaf69cbf115f7bab14f3bc2f68d25e0e30"), // EM OV CS CA - G3C
        QByteArrayLiteral("43bffa19d6ef651451f6841e019931e96f6f2eaeff28ab4b6f1ce4576de2717b"), // EM OV TLS CA - G3B
        QByteArrayLiteral("ec4ffa1ad0ac88081314b7aaffef6a91f97cd57291bb5ba686c5415f5eb4f6b6"), // EM OV CS CA - G3B
        QByteArrayLiteral("63ecefee431d49523bc1136c4e72d0206a477086caf606cd5cf025686c109cf8"), // EM OV TLS CA - G3C
        QByteArrayLiteral("e0254c7fcdc265e2f0f8a428dabb75ab4ae039b4872d62f5ee57f0877d5a8a41"), // EM EV TLS CA - G3B
        QByteArrayLiteral("c619e4780ed8e0abeda24ad732567de4383a7ea941338f6d1a7d1b49ac792fe9"), // emSign Root TLS CA - G3
        QByteArrayLiteral("8d417db2dd8bf5e3084d1e3f196d583849d81bdd4c00c70b9d39369e96b8c782"), // emSign ECC Root CA - G3
    };
    return kSet;
}

// Common Names of the distrusted eMudhra G3 root and intermediates — catches
// leaf-only handshakes where the server omits the intermediate certificate
// from the TLS handshake.
const QSet<QString> &distrustedCaCommonNames()
{
    static const QSet<QString> kNames = {
        QStringLiteral("emSign ECC Root CA - G3"),
        QStringLiteral("emSign Root TLS CA - G3"),
        QStringLiteral("emSign Root CS CA - G3"),
        QStringLiteral("EM DV TLS CA - G3B"),
        QStringLiteral("EM DV TLS CA - G3C"),
        QStringLiteral("EM OV TLS CA - G3B"),
        QStringLiteral("EM OV TLS CA - G3C"),
        QStringLiteral("EM EV TLS CA - G3B"),
        QStringLiteral("EM EV TLS CA - G3C"),
        QStringLiteral("EM OV CS CA - G3B"),
        QStringLiteral("EM OV CS CA - G3C"),
    };
    return kNames;
}

// Written after deletes so cookieAdded(sentinel) means the store has applied
// every prior deleteCookie for this host (Mojo IPC is ordered per store).
constexpr char kClearBarrierCookieName[] = "__status_clear_barrier";

void invokeCallback(QJSValue callback)
{
    if (!callback.isCallable())
        return;
    const QJSValue result = callback.call();
    if (result.isError())
        qWarning("BrowserProfileUtils: clear callback threw: %s",
                 qPrintable(result.toString()));
}

// One-shot: deleteCookie(name, siteUrl) for each known name, then set a sentinel
// cookie and wait for cookieAdded(sentinel) before notifying. No pending-name
// counters — Mojo ordering guarantees deletes are applied before the add.
class SiteCookieClearOp : public QObject
{
public:
    SiteCookieClearOp(QWebEngineCookieStore *store,
                      QSet<QByteArray> names,
                      QUrl siteUrl,
                      QJSValue callback,
                      QObject *parent = nullptr)
        : QObject(parent)
        , m_store(store)
        , m_names(std::move(names))
        , m_siteUrl(std::move(siteUrl))
        , m_callback(std::move(callback))
        , m_timeout(this)
    {
        m_timeout.setSingleShot(true);
        m_timeout.setInterval(2000);
        connect(&m_timeout, &QTimer::timeout, this, [this]() { finish(); });
    }

    void start()
    {
        if (!m_store || m_siteUrl.host().isEmpty()) {
            done();
            return;
        }

        m_names.remove(QByteArray(kClearBarrierCookieName));

        m_addedConn = connect(
            m_store,
            &QWebEngineCookieStore::cookieAdded,
            this,
            [this](const QNetworkCookie &cookie) {
                if (cookie.name() != QByteArray(kClearBarrierCookieName))
                    return;
                // Drop the sentinel so it does not linger on the site.
                m_store->deleteCookie(cookie, m_siteUrl);
                finish();
            });

        for (const QByteArray &name : std::as_const(m_names)) {
            QNetworkCookie cookie(name);
            m_store->deleteCookie(cookie, m_siteUrl);
        }

        QNetworkCookie barrier(QByteArray(kClearBarrierCookieName),
                               QByteArrayLiteral("1"));
        barrier.setPath(QStringLiteral("/"));
        m_store->setCookie(barrier, m_siteUrl);

        m_timeout.start();
    }

private:
    void finish()
    {
        if (m_finished)
            return;
        m_finished = true;
        if (m_addedConn)
            disconnect(m_addedConn);
        m_timeout.stop();
        done();
    }

    void done()
    {
        invokeCallback(m_callback);
        deleteLater();
    }

    QPointer<QWebEngineCookieStore> m_store;
    QSet<QByteArray> m_names;
    QUrl m_siteUrl;
    QJSValue m_callback;
    QMetaObject::Connection m_addedConn;
    QTimer m_timeout;
    bool m_finished = false;
};

// One-shot: wait for clearHttpCacheCompleted (or timeout), then invoke callback.
class BrowsingDataClearOp : public QObject
{
public:
    BrowsingDataClearOp(QQuickWebEngineProfile *profile,
                        QJSValue callback,
                        QObject *parent = nullptr)
        : QObject(parent)
        , m_profile(profile)
        , m_callback(std::move(callback))
        , m_timeout(this)
    {
        m_timeout.setSingleShot(true);
        m_timeout.setInterval(2000);
        connect(&m_timeout, &QTimer::timeout, this, [this]() { finish(); });
    }

    void start()
    {
        if (!m_profile) {
            done();
            return;
        }

        m_cacheConn = connect(
            m_profile,
            &QQuickWebEngineProfile::clearHttpCacheCompleted,
            this,
            [this]() { finish(); });

        m_profile->clearHttpCache();
        m_timeout.start();
    }

private:
    void finish()
    {
        if (m_finished)
            return;
        m_finished = true;
        if (m_cacheConn)
            disconnect(m_cacheConn);
        m_timeout.stop();
        done();
    }

    void done()
    {
        invokeCallback(m_callback);
        deleteLater();
    }

    QPointer<QQuickWebEngineProfile> m_profile;
    QJSValue m_callback;
    QMetaObject::Connection m_cacheConn;
    QTimer m_timeout;
    bool m_finished = false;
};

// Keep in sync with BrowserDownloadOpenContext.mediaPlayerDirectory (QML).
constexpr char kMediaPlayerDirName[] = "status-browser-player";

// Resolve symlinks so the two allowed roots and the requested path are compared
// in the same form (macOS TempLocation is /var/... -> /private/var/...).
// canonicalFilePath() is empty for paths that do not exist, hence the fallback.
QString canonicalPath(const QString &path)
{
    if (path.isEmpty())
        return {};
    const QString canonical = QFileInfo(path).canonicalFilePath();
    return canonical.isEmpty() ? QDir::cleanPath(QDir(path).absolutePath()) : canonical;
}

// Canonicalize the (existing) parent and append the leaf, so the root resolves
// even before the leaf is created — the player directory is written lazily, and
// canonicalizing it while absent would leave /var/... unresolved and then fail
// to match the /private/var/... form the same request arrives in later.
QString canonicalSubDir(const QString &parent, const QString &leaf)
{
    const QString root = canonicalPath(parent);
    return root.isEmpty() ? QString() : root + QLatin1Char('/') + leaf;
}

// The Backend's local-browsing policy, split by what the profile is for
// (ADR 0006 §8). A browsing profile reaches no file:// at all — typing a local
// path in the address bar dead-ends. The local-preview profile, which backs
// only the tabs that display a downloaded file, reaches the two directories the
// browser itself writes: the platform downloads location (Download Targets) and
// the temp directory holding generated player pages. Owned here rather than
// injected from QML so both Backends keep the policy library-side; mobilewebview
// has the equivalent guard.
//
// Scope: navigations only (main frame + subframes), matching what the QML
// navigationRequested handler used to cover. Subresources are deliberately left
// alone so a player page can load the media it points at; Chromium already
// forbids web origins from reaching file:// subresources.
//
// Stateless after construction (a mode and two const roots computed on the UI
// thread), so it is safe whichever thread WebEngine calls interceptRequest on.
class LocalUrlPolicyInterceptor final : public QWebEngineUrlRequestInterceptor
{
public:
    enum class Mode {
        DenyLocalFiles,      // browsing profiles
        AllowDownloadedFiles // the local-preview profile
    };

    explicit LocalUrlPolicyInterceptor(Mode mode, QObject *parent = nullptr)
        : QWebEngineUrlRequestInterceptor(parent)
        , m_mode(mode)
        , m_downloadsDir(canonicalPath(
              QStandardPaths::writableLocation(QStandardPaths::DownloadLocation)))
        , m_playerDir(canonicalSubDir(
              QStandardPaths::writableLocation(QStandardPaths::TempLocation),
              QLatin1String(kMediaPlayerDirName)))
    {
    }

    void interceptRequest(QWebEngineUrlRequestInfo &info) override
    {
        const QUrl url = info.requestUrl();
        if (!url.isLocalFile())
            return;

        const auto type = info.resourceType();
        if (type != QWebEngineUrlRequestInfo::ResourceTypeMainFrame
            && type != QWebEngineUrlRequestInfo::ResourceTypeSubFrame)
            return;

        if (isAllowed(url.toLocalFile()))
            return;

        qWarning("BrowserProfileUtils: local file browsing is disabled");
        info.block(true);
    }

private:
    bool isAllowed(const QString &localFile) const
    {
        if (m_mode == Mode::DenyLocalFiles)
            return false;
        const QString path = canonicalPath(localFile);
        if (path.isEmpty())
            return false;
        return isUnder(path, m_downloadsDir) || isUnder(path, m_playerDir);
    }

    static bool isUnder(const QString &path, const QString &dir)
    {
        // The trailing separator keeps "/home/user/Downloads-evil" out.
        return !dir.isEmpty() && path.startsWith(dir + QLatin1Char('/'));
    }

    const Mode m_mode;
    const QString m_downloadsDir;
    const QString m_playerDir;
};

} // namespace

struct BrowserProfileUtils::TrackedStore
{
    QPointer<QWebEngineCookieStore> store;
    // Cookie names observed via cookieAdded. Qt 6 reports overwrites
    // (e.g. JS cookie replaced by HttpOnly Set-Cookie) as cookieRemoved only,
    // so we never drop names on removal — stale names make deleteCookie a no-op.
    QSet<QByteArray> cookieNames;
    QMetaObject::Connection addedConn;
    QMetaObject::Connection destroyedConn;
};

// QML WebEngineView has no page.download(); Core QWebEnginePages on an OTR
// helper profile force downloadRequested for Retry (renderable media would
// otherwise navigate/play). Helper does not share the tab's live cookies.
struct BrowserProfileUtils::DownloadHelper
{
    // What downloadUrl() promised to hand back with the download it starts.
    struct Origin
    {
        // QPointer so a destroyed view degrades to null rather than dangling.
        QPointer<QObject> view;
        QString token;
    };

    // Owns the pages in pageViews and the coreProfile they live on; pages must
    // go first so their retire connections die before the helper does.
    ~DownloadHelper()
    {
        for (auto it = pageViews.cbegin(); it != pageViews.cend(); ++it)
            delete it.key();
        pageViews.clear();
        delete coreProfile;
    }

    QPointer<QQuickWebEngineProfile> quickProfile;
    QWebEngineProfile *coreProfile = nullptr;
    QMetaObject::Connection downloadConn;
    QMetaObject::Connection destroyedConn;

    // Live transient download pages (one per downloadUrl() call) mapped to the
    // origin of that call.
    QHash<QWebEnginePage *, Origin> pageViews;
};

BrowserProfileUtils::BrowserProfileUtils(QObject *parent)
    : QObject(parent)
{
}

void BrowserProfileUtils::applyChromiumCertDistrustFlags()
{
    QByteArray flags = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
    const QByteArray constraintFlag(kEmSignEccRootG3CrsConstraintFlag);
    if (!flags.contains(constraintFlag)) {
        if (!flags.isEmpty() && !flags.endsWith(' '))
            flags.append(' ');
        flags.append(constraintFlag);
        qputenv("QTWEBENGINE_CHROMIUM_FLAGS", flags);
    }
}

bool BrowserProfileUtils::isCertificateChainDistrusted(const QList<QSslCertificate> &chain)
{
    const auto &certHashes = distrustedCertSha256Hex();
    const auto &spkiHashes = distrustedSpkiSha256Hex();
    const auto &caNames = distrustedCaCommonNames();

    for (const QSslCertificate &cert : chain) {
        if (cert.isNull())
            continue;

        const QByteArray certSha256 = cert.digest(QCryptographicHash::Sha256).toHex();
        if (certHashes.contains(certSha256))
            return true;

        const QByteArray spkiDer = cert.publicKey().toDer();
        if (!spkiDer.isEmpty()) {
            const QByteArray spkiSha256 =
                QCryptographicHash::hash(spkiDer, QCryptographicHash::Sha256).toHex();
            if (spkiHashes.contains(spkiSha256))
                return true;
        }

        const QStringList issuerCns = cert.issuerInfo(QSslCertificate::CommonName);
        for (const QString &cn : issuerCns) {
            if (caNames.contains(cn))
                return true;
        }

        const QStringList subjectCns = cert.subjectInfo(QSslCertificate::CommonName);
        for (const QString &cn : subjectCns) {
            if (caNames.contains(cn))
                return true;
        }
    }

    return false;
}

bool BrowserProfileUtils::isDistrustedCertificateError(const QWebEngineCertificateError &error) const
{
    return isCertificateChainDistrusted(error.certificateChain());
}

BrowserProfileUtils::~BrowserProfileUtils()
{
    for (TrackedStore *tracked : std::as_const(m_tracked)) {
        if (tracked->addedConn)
            disconnect(tracked->addedConn);
        if (tracked->destroyedConn)
            disconnect(tracked->destroyedConn);
        delete tracked;
    }
    m_tracked.clear();

    for (DownloadHelper *helper : std::as_const(m_downloadHelpers)) {
        if (helper->downloadConn)
            disconnect(helper->downloadConn);
        if (helper->destroyedConn)
            disconnect(helper->destroyedConn);
        delete helper;
    }
    m_downloadHelpers.clear();
}

QWebEngineUrlRequestInterceptor *BrowserProfileUtils::browsingUrlPolicy()
{
    if (!m_browsingUrlPolicy)
        m_browsingUrlPolicy = new LocalUrlPolicyInterceptor(
            LocalUrlPolicyInterceptor::Mode::DenyLocalFiles, this);
    return m_browsingUrlPolicy;
}

QWebEngineUrlRequestInterceptor *BrowserProfileUtils::localPreviewUrlPolicy()
{
    if (!m_localPreviewUrlPolicy)
        m_localPreviewUrlPolicy = new LocalUrlPolicyInterceptor(
            LocalUrlPolicyInterceptor::Mode::AllowDownloadedFiles, this);
    return m_localPreviewUrlPolicy;
}

// A storage profile can fail to instantiate (one live profile per data path),
// leaving the view on the default profile — so it carries a policy too. It backs
// browsing views, hence the browsing one: a preview that lands there shows
// nothing, rather than handing file access to a browsing context.
void BrowserProfileUtils::installDefaultProfileFallback(QObject *installedOn)
{
    auto *fallback = QQuickWebEngineProfile::defaultProfile();
    if (fallback && fallback != installedOn)
        fallback->setUrlRequestInterceptor(browsingUrlPolicy());
}

void BrowserProfileUtils::installBrowsingUrlPolicy(QObject *profile)
{
    auto *webProfile = qobject_cast<QQuickWebEngineProfile *>(profile);
    if (!webProfile) {
        qWarning("BrowserProfileUtils::installBrowsingUrlPolicy: expected a WebEngineProfile");
        return;
    }

    webProfile->setUrlRequestInterceptor(browsingUrlPolicy());
    installDefaultProfileFallback(webProfile);
}

void BrowserProfileUtils::installLocalPreviewUrlPolicy(QObject *profile)
{
    auto *webProfile = qobject_cast<QQuickWebEngineProfile *>(profile);
    if (!webProfile) {
        qWarning("BrowserProfileUtils::installLocalPreviewUrlPolicy: expected a WebEngineProfile");
        return;
    }

    webProfile->setUrlRequestInterceptor(localPreviewUrlPolicy());
    installDefaultProfileFallback(webProfile);
}

BrowserProfileUtils::TrackedStore *BrowserProfileUtils::trackedStoreFor(QObject *profile) const
{
    auto *webProfile = qobject_cast<QQuickWebEngineProfile *>(profile);
    if (!webProfile)
        return nullptr;
    auto *store = webProfile->cookieStore();
    if (!store)
        return nullptr;
    return m_tracked.value(reinterpret_cast<quintptr>(store), nullptr);
}

void BrowserProfileUtils::trackProfile(QObject *profile)
{
    auto *webProfile = qobject_cast<QQuickWebEngineProfile *>(profile);
    if (!webProfile) {
        qWarning("BrowserProfileUtils::trackProfile: expected a WebEngineProfile");
        return;
    }

    auto *store = webProfile->cookieStore();
    if (!store) {
        qWarning("BrowserProfileUtils::trackProfile: no cookie store");
        return;
    }

    const quintptr key = reinterpret_cast<quintptr>(store);
    if (m_tracked.contains(key))
        return;

    auto *tracked = new TrackedStore;
    tracked->store = store;

    tracked->addedConn = connect(
        store,
        &QWebEngineCookieStore::cookieAdded,
        this,
        [tracked](const QNetworkCookie &cookie) {
            if (cookie.name() == QByteArray(kClearBarrierCookieName))
                return;
            tracked->cookieNames.insert(cookie.name());
        });

    tracked->destroyedConn = connect(
        store,
        &QObject::destroyed,
        this,
        [this, key]() {
            TrackedStore *gone = m_tracked.take(key);
            if (!gone)
                return;
            if (gone->addedConn)
                disconnect(gone->addedConn);
            delete gone;
        });

    m_tracked.insert(key, tracked);
}

void BrowserProfileUtils::clearBrowsingData(QObject *profile, QJSValue callback)
{
    auto *webProfile = qobject_cast<QQuickWebEngineProfile *>(profile);
    if (!webProfile) {
        qWarning("BrowserProfileUtils::clearBrowsingData: expected a WebEngineProfile");
        invokeCallback(callback);
        return;
    }

    if (auto *cookieStore = webProfile->cookieStore()) {
        cookieStore->deleteAllCookies();
        if (TrackedStore *tracked = trackedStoreFor(profile))
            tracked->cookieNames.clear();
    }

    auto *op = new BrowsingDataClearOp(webProfile, std::move(callback), this);
    op->start();
}

void BrowserProfileUtils::clearSiteData(QObject *profile, const QUrl &siteUrl,
                                        QJSValue callback)
{
    auto *webProfile = qobject_cast<QQuickWebEngineProfile *>(profile);
    if (!webProfile) {
        qWarning("BrowserProfileUtils::clearSiteData: expected a WebEngineProfile");
        invokeCallback(callback);
        return;
    }

    if (siteUrl.host().isEmpty()) {
        qWarning("BrowserProfileUtils::clearSiteData: empty host; ignoring");
        invokeCallback(callback);
        return;
    }

    TrackedStore *tracked = trackedStoreFor(profile);
    if (!tracked || !tracked->store) {
        qWarning("BrowserProfileUtils::clearSiteData: profile not tracked "
                 "(call trackProfile at profile creation); ignoring");
        invokeCallback(callback);
        return;
    }

    auto *op = new SiteCookieClearOp(
        tracked->store,
        tracked->cookieNames,
        siteUrl,
        std::move(callback),
        this);
    op->start();
}

BrowserProfileUtils::DownloadHelper *BrowserProfileUtils::helperFor(QObject *profile)
{
    auto *quickProfile = qobject_cast<QQuickWebEngineProfile *>(profile);
    if (!quickProfile)
        return nullptr;

    const quintptr key = reinterpret_cast<quintptr>(quickProfile);
    if (DownloadHelper *existing = m_downloadHelpers.value(key, nullptr))
        return existing;

    auto *helper = new DownloadHelper;
    helper->quickProfile = quickProfile;

    // Always OTR: a named Core profile with the same storageName as the Quick
    // profile risks opening the same on-disk cookie DB twice. Public API cannot
    // attach a QWebEnginePage to the Quick profile's ProfileAdapter, so Retry
    // downloads do not see the tab's live cookies (OK for public CDN media;
    // authenticated Retry may need a revisit).
    helper->coreProfile = new QWebEngineProfile(this);

    helper->downloadConn = connect(
        helper->coreProfile,
        &QWebEngineProfile::downloadRequested,
        this,
        [this, helper](QWebEngineDownloadRequest *download) {
            if (!download)
                return;
            // Only downloadUrl() pages live on this profile, so an unknown
            // page() means the request has no identifiable initiator.
            QWebEnginePage *page = download->page();
            const auto it = helper->pageViews.constFind(page);
            if (it == helper->pageViews.cend()) {
                qWarning("BrowserProfileUtils: downloadRequested from an unknown page");
                emit downloadRequested(nullptr, download, QString());
                return;
            }
            const DownloadHelper::Origin origin = it.value();
            retirePageWhenFinished(helper, page, download);
            emit downloadRequested(origin.view.data(), download, origin.token);
        });

    helper->destroyedConn = connect(
        quickProfile,
        &QObject::destroyed,
        this,
        [this, key]() {
            DownloadHelper *gone = m_downloadHelpers.take(key);
            if (!gone)
                return;
            if (gone->downloadConn)
                disconnect(gone->downloadConn);
            if (gone->destroyedConn)
                disconnect(gone->destroyedConn);
            delete gone;
        });

    m_downloadHelpers.insert(key, helper);
    return helper;
}

// Whether a download outlives the page it started on is undocumented, so the
// transient page is kept until the download finishes (or is deleted).
void BrowserProfileUtils::retirePageWhenFinished(DownloadHelper *helper,
                                                 QWebEnginePage *page,
                                                 QWebEngineDownloadRequest *download)
{
    // Capturing `helper` raw is safe: both connections have context `page`, and
    // ~DownloadHelper deletes its pages first, so no run can outlive the helper.
    const auto retire = [helper, page]() {
        if (helper->pageViews.remove(page) > 0)
            page->deleteLater();
    };
    connect(download, &QWebEngineDownloadRequest::isFinishedChanged, page,
            [download, retire]() {
                if (download->isFinished())
                    retire();
            });
    connect(download, &QObject::destroyed, page, retire);
}

void BrowserProfileUtils::downloadUrl(QObject *profile, QObject *webEngineView,
                                      const QUrl &url,
                                      const QString &suggestedFileName,
                                      const QString &token)
{
    if (!url.isValid()) {
        qWarning("BrowserProfileUtils::downloadUrl: invalid url");
        return;
    }

    DownloadHelper *helper = helperFor(profile);
    if (!helper || !helper->coreProfile) {
        qWarning("BrowserProfileUtils::downloadUrl: expected a WebEngineProfile");
        return;
    }

    // One page per call: downloadRequested carries page(), so concurrent calls
    // are matched to their initiating view by identity, never by call order.
    auto *page = new QWebEnginePage(helper->coreProfile, this);
    helper->pageViews.insert(page, DownloadHelper::Origin{
                                       QPointer<QObject>(webEngineView), token});
    page->download(url, suggestedFileName);
}
