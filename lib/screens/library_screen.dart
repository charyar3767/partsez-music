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
  int _tab = 0;
  String? _papka;
  bool _yuklenyar = true;
  bool _ygtyyarYok = false;

  @override
  void initState() { super.initState(); _baslat(); }

  Future<void> _baslat() async {
    setState(() { _yuklenyar = true; _ygtyyarYok = false; });
    bool bar = await _audioQuery.permissionsStatus();
    if (!bar) bar = await _audioQuery.permissionsRequest();
    if (!bar) { setState(() { _yuklenyar = false; _ygtyyarYok = true; }); return; }
    final songs = await _audioQuery.querySongs(sortType: SongSortType.TITLE, orderType: OrderType.ASC_OR_SMALLER, uriType: UriType.EXTERNAL, ignoreCase: true);
    final list = songs.where((s) => (s.isMusic ?? true) && (s.duration ?? 0) > 30000).map(Aydym.fromSong).map(DuzeltmeHyzmat.instance.ulan).toList();
    setState(() { _hemme = list; _yuklenyar = false; });
    try { Permission.notification.request(); } catch (_) {}
  }

  String _papkaAdy(String p) {
    if (p.isEmpty) return 'Nämä-belli';
    final i = p.lastIndexOf('/');
    return i < 0 ? p : p.substring(i + 1);
  }

  List<MapEntry<String, int>> _papkalar() {
    final m = <String, int>{};
    for (final a in _hemme) m[a.papka] = (m[a.papka] ?? 0) + 1;
    var e = m.entries.toList();
    if (_soz.isNotEmpty) e = e.where((x) => _papkaAdy(x.key).toLowerCase().contains(_soz)).toList();
    e.sort((x, y) => _papkaAdy(x.key).toLowerCase().compareTo(_papkaAdy(y.key).toLowerCase()));
    return e;
  }

  List<Aydym> _sanawyAl(Set<int> fav) {
    Iterable<Aydym> l = _hemme;
    if (_tab == 1) l = l.where((a) => fav.contains(a.id));
    if (_tab == 2 && _papka != null) l = l.where((a) => a.papka == _papka);
    if (_soz.isNotEmpty) l = l.where((a) => a.ady.toLowerCase().contains(_soz) || a.artist.toLowerCase().contains(_soz));
    return l.toList();
  }

  void _habar(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t), behavior: SnackBarBehavior.floating));

  Future<void> _oynatVeAc(List<Aydym> sanaw, int index) async {
    await _h.oynat(sanaw, index);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OynadyjyEkrany()));
  }

  Future<void> _duzelt(Aydym a) async {
    final adyK = TextEditingController(text: a.ady);
    final artK = TextEditingController(text: a.artist);
    final bar = DuzeltmeHyzmat.instance.bar(a.id);
    final netije = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Renkler.kart,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Maglumaty üýtget'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: adyK, decoration: const InputDecoration(labelText: 'Aýdymyň ady')),
        const SizedBox(height: 12),
        TextField(controller: artK, decoration: const InputDecoration(labelText: 'Artist')),
      ]),
      actions: [
        if (bar) TextButton(onPressed: () => Navigator.pop(ctx, 'reset'), child: const Text('Asyl adyna gaýt'),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Goýbolsun')),
        FilledButton(onPressed: () => Navigator.pop(ctx, 'save'), child: const Text('Sakla')),
      ],
    ));
    if (netije == null) { adyK.dispose(); artK.dispose(); return; }
    if (netije == 'reset') { await DuzeltmeHyzmat.instance.ochur(a.id); await _baslat(); adyK.dispose(); artK.dispose(); return; }
    final ady = adyK.text.trim().isEmpty ? a.ady : adyK.text.trim();
    final art = artK.text.trim().isEmpty ? a.artist : artK.text.trim();
    adyK.dispose(); artK.dispose();
    await DuzeltmeHyzmat.instance.sakla(a.id, ady, art);
    final tazesi = a.copyWith(ady: ady, artist: art);
    if (!mounted) return;
    setState(() { final i = _hemme.indexWhere((x) => x.id == a.id); if (i >= 0) _hemme[i] = tazesi; });
    _h.maglumatAyyr(tazesi); _habar('Maglumat saklandy');
  }

  Future<void> _poz(Aydym a) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Renkler.kart,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Aýdymy pozmak'),
      content: Text('"${a.ady}" telefondan pozular. Dowam edelipmi?'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Goýbolsun')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Pozmak'))],
    ));
    if (ok != true) return;
    final boldy = await MediaHyzmat.aydymyPozmak(a.id);
    if (!mounted) return;
    if (!boldy) { _habar('Pozup bolmady'); return; }
    await _h.aydymyAyyr(a.id); await FavoritHyzmat.instance.ochur(a.id); await DuzeltmeHyzmat.instance.ochur(a.id);
    if (!mounted) return;
    setState(() { _hemme.removeWhere((x) => x.id == a.id); if (_papka != null && !_hemme.any((x) => x.papka == _papka)) _papka = null; });
    _habar('Aydym pozuldy');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: !(_tab == 2 && _papka != null), onPopInvokedWithResult: (didPop, _) { if (!didPop) setState(() => _papka = null); }, child: Scaffold(
      appBar: AppBar(title: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 34, height: 34, decoration: const BoxDecoration(gradient: Renkler.gradient, shape: BoxShape.circle), child: const Icon(Icons.graphic_eq_rounded, size: 20)),
        const SizedBox(width: 10),
        const Text('Partsez Music', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ]), actions: [IconButton(onPressed: _baslat, tooltip: 'Täzele', icon: const Icon(Icons.refresh_rounded))]),
      body: _govdeKur(),
      bottomNavigationBar: const SafeArea(top: false, child: KiciOynadyjy()),
    ));
  }

  Widget _tabKur(String ady, int nomer, IconData icon) {
    final on = _tab == nomer;
    return GestureDetector(onTap: () => setState(() { _tab = nomer; _papka = null; }), child: AnimatedContainer(duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(gradient: on ? Renkler.gradient : null, color: on ? null : Renkler.kart,
        borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 17, color: Colors.white), const SizedBox(width: 7), Text(ady, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))]),
    );
  }

  Widget _govdeKur() {
    if (_yuklenyar) return const Center(child: CircularProgressIndicator(color: Renkler.esasy));
    if (_ygtyyarYok) return Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 84, height: 84, decoration: BoxDecoration(color: Renkler.kart, borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.lock_outline_rounded, size: 40, color: Renkler.esasy)),
      const SizedBox(height: 18), const Text('Aýdymlary okumaga rugsat gerek', textAlign: TextAlign.center), const SizedBox(height: 14),
      FilledButton.icon(onPressed: _baslat, icon: const Icon(Icons.security_rounded), label: const Text('Rugsat ber')),
    ])));
    if (_hemme.isEmpty) return const Center(child: Text('Telefonda aýdym tapylmady', style: TextStyle(color: Renkler.tekstSoluk)));
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(12, 6, 12, 10), child: Container(decoration: BoxDecoration(color: Renkler.kart, borderRadius: BorderRadius.circular(16)), child: TextField(
        onChanged: (q) => setState(() => _soz = q.trim().toLowerCase()),
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(hintText: _tab == 2 && _papka == null ? 'Papkadan gözle' : 'Aydym ýa-da artist gözle', hintStyle: const TextStyle(color: Renkler.tekstSoluk),
          prefixIcon: const Icon(Icons.search_rounded, color: Renkler.tekstSoluk), suffixIcon: _soz.isEmpty ? null : IconButton(onPressed: () => setState(() => _soz = ''), icon: const Icon(Icons.close_rounded, size: 18)),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15)),
      ))),
      SizedBox(height: 42, child: ListView(padding: const EdgeInsets.symmetric(horizontal: 12), scrollDirection: Axis.horizontal, children: [
        _tabKur('Hemmesi', 0, Icons.library_music_rounded), _tabKur('Halananlar', 1, Icons.favorite_rounded), _tabKur('Papkalar', 2, Icons.folder_rounded),
      ])),
      const SizedBox(height: 8),
      Expanded(child: (_tab == 2 && _papka == null) ? _papkalarKur() : Column(children: [if (_tab == 2) _papkaBashy(), Expanded(child: _aydymlarKur())])),
    ]);
  }

  Widget _papkalarKur() {
    final l = _papkalar();
    if (l.isEmpty) return const Center(child: Text('Papka tapylmady', style: TextStyle(color: Renkler.tekstSoluk)));
    return ListView.separated(padding: const EdgeInsets.fromLTRB(12, 4, 12, 12), itemCount: l.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, index) { final e = l[index]; return Container(decoration: BoxDecoration(color: Renkler.kart, borderRadius: BorderRadius.circular(16)), child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), onTap: () => setState(() { _papka = e.key; _soz = ''; }),
        leading: Container(width: 48, height: 48, decoration: BoxDecoration(gradient: Renkler.gradient, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.folder_rounded, color: Colors.white)),
        title: Text(_papkaAdy(e.key), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${e.value} aýdym', style: const TextStyle(color: Renkler.tekstSoluk, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Renkler.tekstSoluk),
      )); });
  }

  Widget _papkaBashy() {
    final p = _papka ?? ''; final list = _hemme.where((a) => a.papka == p).toList();
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Row(children: [
      IconButton(onPressed: () => setState(() => _papka = null), icon: const Icon(Icons.arrow_back_rounded)),
      Expanded(child: Text(_papkaAdy(p), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
      FilledButton.icon(onPressed: list.isEmpty ? null : () => _oynatVeAc(list, 0), icon: const Icon(Icons.play_arrow_rounded, size: 18), label: const Text('Oynat')),
    ]));
  }

  Widget _aydymlarKur() {
    return ValueListenableBuilder<Set<int>>(valueListenable: FavoritHyzmat.instance.halananlar, builder: (_, fav, __) {
      final sanaw = _sanawyAl(fav);
      if (sanaw.isEmpty) return Center(child: Text(_tab == 1 ? 'Enteke halanan aýdym ýok' : 'Hiç zat tapylmady', style: const TextStyle(color: Renkler.tekstSoluk)));
      return ValueListenableBuilder<int>(valueListenable: _h.yndeks, builder: (_, __, ___) { final id = _h.hazirki?.id ?? -1;
        return ListView.builder(padding: const EdgeInsets.only(bottom: 8), itemCount: sanaw.length, itemBuilder: (_, index) { final a = sanaw[index]; return AydymKart(aydym: a, oynayar: a.id == id, onTap: () => _oynatVeAc(sanaw, index), onEdit: () => _duzelt(a), onDelete: () => _poz(a)); });
      });
    });
  }
}
