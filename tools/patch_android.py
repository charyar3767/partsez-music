import glob
import os
import re
import sys

MANIFEST = 'android/app/src/main/AndroidManifest.xml'


def manifest_sazla():
    s = open(MANIFEST, encoding='utf-8').read()
    if 'MediaButtonReceiver' in s:
        print('Manifest eyyam taiyar')
        return

    ygtyyarlar = [
        '<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>',
        '<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>',
        '<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>',
        '<uses-permission android:name="android.permission.WAKE_LOCK"/>',
        '<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>',
        '<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>',
        '<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>',
    ]
    blok = '\n    ' + '\n    '.join(ygtyyarlar)
    s = re.sub(r'(<manifest[^>]*>)', lambda m: m.group(1) + blok, s, count=1)

    s = re.sub(r'android:label="[^"]*"', 'android:label="Partsez Music"', s, count=1)

    goshmaca = '''
        <service android:name="com.ryanheise.audioservice.AudioService"
            android:foregroundServiceType="mediaPlayback"
            android:exported="true">
            <intent-filter>
                <action android:name="android.media.browse.MediaBrowserService" />
            </intent-filter>
        </service>
        <receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MEDIA_BUTTON" />
            </intent-filter>
        </receiver>
    '''
    s = s.replace('</application>', goshmaca + '</application>', 1)
    open(MANIFEST, 'w', encoding='utf-8').write(s)
    print('Manifest uytgedildi')


def activity_sazla():
    fayllar = glob.glob('android/app/src/main/**/MainActivity.*', recursive=True)
    if not fayllar:
        print('MainActivity tapylmady')
        sys.exit(1)
    paket = None
    papka = None
    for f in fayllar:
        txt = open(f, encoding='utf-8').read()
        m = re.search(r'package\s+([\w.]+)', txt)
        if m and paket is None:
            paket = m.group(1)
            papka = os.path.dirname(f)
    if paket is None:
        print('Paket ady tapylmady')
        sys.exit(1)
    for f in fayllar:
        os.remove(f)
    shablon = open('tools/MainActivity.kt.tmpl', encoding='utf-8').read()
    yol = os.path.join(papka, 'MainActivity.kt')
    open(yol, 'w', encoding='utf-8').write(shablon.replace('__PAKET__', paket))
    print('MainActivity.kt yazyldy:', yol)


manifest_sazla()
activity_sazla()
