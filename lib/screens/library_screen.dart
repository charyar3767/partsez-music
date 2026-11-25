import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart' show Permission;
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/duzeltme_service.dart';
import '../services/favorit_service.dart';
import '../services/media_service.dart';
import '../theme.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final OynadyjyHyzmat _h = OynadyjyHyzmat.instance;

  List<Aydym> _hemme = [];
  String _soz = '';
  int _tab = 0; // 0 = Hemmesi, 1 = Halananlar, 2 = Papkalar
  String? _papka; // Papkalar sekmesinde acyk papka
  bool _yuklenyar = true;
  bool _ygtyyarYok = false;

  @override
  void initState() {
    super.initState();
    _baslat();
  }

  Future<void> _baslat() async {
    setState(() {
      _yuklenyar = true;
      _ygtyyarYok = false;
    });

    bool bar = await _audioQuery.permissionsStatus();
    if (!bar) {
      bar = await _audioQuery.permissionsRequest();
    }
    if (!bar) {
      setState(() {
        _yuklenyar = false;
        _ygtyyarYok = true;
      });
      return;
    }

    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    final list = songs
        .where((s) => (s.isMusic ?? true) && (s.duration ?? 0) > 30000)
        .map(Aydym.fromSong)
        .map(DuzeltmeHyzmat.instance.ulan)
        .toList();

    setState(() {
      _hemme = list;
      _yuklenyar = false;
    });

    try {
      Permission.notification.request();
    } catch (_) {}
  }

  // ---------- komekci funksiyalar ----------
  String _papkaAdy(String p) {
    if (p.isEmpty) return 'Nama-belli';
    final i = p.lastIndexOf('/');
    return i < 0 ? p : p.substring(i + 1);
  }

  String _papkaYoly(String p) {
    return p.replaceFirst('/storage/emulated/0', 'Telefon');
  }

  List<MapEntry<String, int>> _papkalar() {
    final m = <String, int>{};
    for (final a in _hemme) {
      m[a.papka] = (m[a.papka] ?? 0) + 1;
    }
    var e = m.entries.toList();
    if (_soz.isNotEmpty) {
      e = e.where((x) => _papkaAdy(x.key).toLowerCase().contains(_soz)).toList();
    }
    e.sort((x, y) => _papkaAdy(x.key)
        .toLowerCase()
        .compareTo(_papkaAdy(y.key).toLowerCase()));
    return e;
  }

  List<Aydym> _sanawyAl(Set<int> fav) {
    Iterable<Aydym> l = _hemme;
    if (_tab == 1) {
      l = l.where((a) => fav.contains(a.id));
    }
    if (_tab == 2 && _papka != null) {
      l = l.where((a) => a.papka == _papka);
    }
    if (_soz.isNotEmpty) {
      l = l.where((a) =>
          a.ady.toLowerCase().contains(_soz) ||
          a.artist.toLowerCase().contains(_soz));
    }
    return l.toList();
  }

  void _habar(String t) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _oynatVeAc(List<Aydym> sanaw, int index) async {
    await _h.oynat(sanaw, index);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OynadyjyEkrany()),
    );
  }

  // ---------- Uytget ----------
  Future<void> _duzelt(Aydym a) async {
    final adyK = TextEditingController(text: a.ady);
    final artK = TextEditingController(text: a.artist);
    final bar = DuzeltmeHyzmat.instance.bar(a.id);

    final netije = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Renkler.kart,
        title: const Text('Maglumaty uytget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: adyK,
              decoration: const InputDecoration(labelText: 'Aydymyn ady'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: artK,
              decoration: const InputDecoration(labelText: 'Artist'),
            ),
          ],
        ),
        actions: [
          if (bar)
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'reset'),
              child: const Text('Asyl ada gaytar'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Goybolsun'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: const Text('Sakla'),
          ),
        ],
      ),
    );

    final yeniAdy = adyK.text.trim();
    final yeniArt = artK.text.trim();
    adyK.dispose();
    artK.dispose();

    if (netije == null) return;

    if (netije == 'reset') {
      await DuzeltmeHyzmat.instance.ochur(a.id);
      await _baslat();
      return;
    }

    final ady = yeniAdy.isEmpty ? a.ady : yeniAdy;
    final art = yeniArt.isEmpty ? a.artist : yeniArt;
    await DuzeltmeHyzmat.instance.sakla(a.id, ady, art);
    final tazesi = a.copyWith(ady: ady, artist: art);
    if (!mounted) return;
    setState(() {
      final i = _hemme.indexWhere((x) => x.id == a.id);
      if (i >= 0) _hemme[i] = tazesi;
    });
    _h.maglumatAyyr(tazesi);
    _habar('Maglumat saklandy');
  }

  // ---------- Pozmak ----------
  Future<void> _poz(Aydym a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Renkler.kart,
        title: const Text('Aydymy pozmak'),
        content: Text(
          '"${a.ady}" telefondan hemishelik pozular. Dowam edelinmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Goybolsun'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pozmak'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final boldy = await MediaHyzmat.aydymyPozmak(a.id);
    if (!mounted) return;

    if (!boldy) {
      _habar('Poz bolmady ya-da ret edildi');
      return;
    }

    await _h.aydymyAyyr(a.id);
    await FavoritHyzmat.instance.ochur(a.id);
    await DuzeltmeHyzmat.instance.ochur(a.id);
    if (!mounted) return;
    setState(() {
      _hemme.removeWhere((x) => x.id == a.id);
      if (_papka != null && !_hemme.any((x) => x.papka == _papka)) {
        _papka = null;
      }
    });
    _habar('Aydym pozuldy');
  }

  // ---------- Gorunus ----------
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !(_tab == 2 && _papka != null),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) setState(() => _papka = null);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Renkler.fon,
          elevation: 0,
          title: ShaderMask(
            shaderCallback: (r) => Renkler.gradient.createShader(r),
            child: const Text(
              'Partsez Music',
              style:
                  TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ),
        body: _govdeKur(),
        bottomNavigationBar: const SafeArea(child: KiciOynadyjy()),
      ),
    );
  }

  Widget _tabKur(String ady, int nomer) {
    final saylanan = _tab == nomer;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(ady),
        selected: saylanan,
        onSelected: (_) => setState(() {
          _tab = nomer;
          _papka = null;
        }),
        selectedColor: Renkler.esasy.withOpacity(0.35),
        backgroundColor: Renkler.kart,
        side: BorderSide(
          color: saylanan ? Renkler.esasy : Colors.transparent,
        ),
      ),
    );
  }

  Widget _govdeKur() {
    if (_yuklenyar) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_ygtyyarYok) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: Renkler.esasy),
            const SizedBox(height: 12),
            const Text('Aydymlary okamak ucin ygtyyar gerek'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _baslat,
              child: const Text('Ygtyyar ber'),
            ),
          ],
        ),
      );
    }
    if (_hemme.isEmpty) {
      return const Center(child: Text('Telefonda aydym tapylmady'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
          child: TextField(
            onChanged: (q) => setState(() => _soz = q.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: _tab == 2 && _papka == null
                  ? 'Papka gozle'
                  : 'Aydym ya-da artist gozle',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Renkler.kart,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _tabKur('Hemmesi', 0),
                _tabKur('Halananlar', 1),
                _tabKur('Papkalar', 2),
              ],
            ),
          ),
        ),
        Expanded(
          child: (_tab == 2 && _papka == null)
              ? _papkalarKur()
              : Column(
                  children: [
                    if (_tab == 2) _papkaBashy(),
                    Expanded(child: _aydymlarKur()),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _papkalarKur() {
    final l = _papkalar();
    if (l.isEmpty) {
      return const Center(
        child: Text('Papka tapylmady',
            style: TextStyle(color: Renkler.tekstSoluk)),
      );
    }
    return ListView.builder(
      itemCount: l.length,
      itemBuilder: (context, index) {
        final e = l[index];
        return ListTile(
          onTap: () => setState(() {
            _papka = e.key;
            _soz = '';
          }),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: Renkler.gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.folder, color: Colors.white),
          ),
          title: Text(
            _papkaAdy(e.key),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${e.value} aydym  -  ${_papkaYoly(e.key)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Renkler.tekstSoluk, fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right, color: Renkler.tekstSoluk),
        );
      },
    );
  }

  Widget _papkaBashy() {
    final p = _papka ?? '';
    final papkaAydymlary = _hemme.where((a) => a.papka == p).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 14, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _papka = null),
          ),
          Expanded(
            child: Text(
              _papkaAdy(p),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          FilledButton.icon(
            onPressed: papkaAydymlary.isEmpty
                ? null
                : () => _oynatVeAc(papkaAydymlary, 0),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Oynat'),
          ),
        ],
      ),
    );
  }

  Widget _aydymlarKur() {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: FavoritHyzmat.instance.halananlar,
      builder: (context, fav, _) {
        final sanaw = _sanawyAl(fav);
        if (sanaw.isEmpty) {
          return Center(
            child: Text(
              _tab == 1 ? 'Entek halanan aydym yok' : 'Hic zat tapylmady',
              style: const TextStyle(color: Renkler.tekstSoluk),
            ),
          );
        }
        return ValueListenableBuilder<int>(
          valueListenable: _h.yndeks,
          builder: (context, i, _) {
            final hazirkiId = _h.hazirki?.id ?? -1;
            return ListView.builder(
              itemCount: sanaw.length,
              itemBuilder: (context, index) {
                final a = sanaw[index];
                return AydymKart(
                  aydym: a,
                  oynayar: a.id == hazirkiId,
                  onTap: () => _oynatVeAc(sanaw, index),
                  onEdit: () => _duzelt(a),
                  onDelete: () => _poz(a),
                );
              },
            );
          },
        );
      },
    );
  }
}
