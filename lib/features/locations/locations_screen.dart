import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/content/content_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../shared/widgets/status_views.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final _content = ContentStore.instance;
  final _mapController = MapController();
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  bool _mapView = true;
  String _query = '';
  Bakery? _selectedBakery;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
    _searchFocus.addListener(() => setState(() {}));
    _content.load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Bakery> _filter(List<Bakery> bakeries) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return bakeries;
    return bakeries
        .where(
          (b) =>
              b.name.toLowerCase().contains(q) ||
              b.address.toLowerCase().contains(q) ||
              (b.metro?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  bool get _showDropdown =>
      _mapView && _searchFocus.hasFocus && _searchCtrl.text.isNotEmpty;

  void _toggleView() {
    setState(() {
      _mapView = !_mapView;
      _selectedBakery = null;
    });
    _searchFocus.unfocus();
  }

  void _selectResult(Bakery b) {
    _searchFocus.unfocus();
    setState(() {
      _mapView = true;
      _searchCtrl.text = b.address;
      _selectedBakery = b;
    });
    final position = _position(b);
    if (position != null) _mapController.move(position, 15);
  }

  void _onPinTap(Bakery b, LatLng position) {
    _searchFocus.unfocus();
    setState(() => _selectedBakery = b);
    final zoom = _mapController.camera.zoom;
    _mapController.move(position, zoom < 14 ? 14 : zoom);
  }

  void _dismissInfo() {
    if (_selectedBakery != null) setState(() => _selectedBakery = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _searchFocus.unfocus();
          _dismissInfo();
        },
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AspectRatio(
                aspectRatio: 1572 / 1200,
                child: Image.asset(
                  'assets/images/page_promo_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                  isAntiAlias: true,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'Наши адреса',
                          style: AppTextStyles.h1().copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          left: 16,
                          child: _CircleIconButton(
                            asset: 'assets/icons/back.svg',
                            onTap: () => context.pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _content,
                      builder: (context, _) => _buildBody(),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNav(
                currentIndex: -1,
                onTap: (i) {
                  context.go(i == 0 ? '/home' : '/home?tab=1');
                },
                onLogoTap: () => context.push('/qr'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final data = _content.data;
    if (data == null) {
      final error = _content.error;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.topCenter,
          child: error != null && !_content.isLoading
              ? StatusCard(
                  title: 'Не удалось загрузить адреса',
                  subtitle: error,
                  onRetry: () => _content.load(force: true),
                )
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: LoadingSpinner(),
                ),
        ),
      );
    }
    if (data.bakeries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.topCenter,
          child: StatusCard(
            title: 'Адреса пока не добавлены',
            subtitle: 'Загляните позже — здесь появятся наши пекарни',
          ),
        ),
      );
    }
    final bakeries = data.bakeries;
    final filtered = _filter(bakeries);
    final selected = _selectedBakery;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SearchField(
                  controller: _searchCtrl,
                  focusNode: _searchFocus,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _toggleView,
                child: SvgPicture.asset(
                  _mapView
                      ? 'assets/icons/list_badge.svg'
                      : 'assets/icons/map_badge.svg',
                  width: 48,
                  height: 48,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _mapView
                    ? _MapContent(
                        key: const ValueKey('map'),
                        controller: _mapController,
                        bakeries: bakeries,
                        onPinTap: _onPinTap,
                        onMapTap: _dismissInfo,
                      )
                    : _ListContent(
                        key: const ValueKey('list'),
                        items: filtered,
                      ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _showDropdown
                    ? _SearchDropdown(items: filtered, onSelect: _selectResult)
                    : const SizedBox(width: double.infinity),
              ),
              if (_mapView)
                IgnorePointer(
                  ignoring: selected == null,
                  child: Align(
                    alignment: const Alignment(0, -0.12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        scale: selected == null ? 0.9 : 1,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: selected == null ? 0 : 1,
                          child: selected == null
                              ? const SizedBox.shrink()
                              : _BakeryInfoCard(
                                  bakery: selected,
                                  onClose: _dismissInfo,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

LatLng? _position(Bakery bakery) {
  final latitude = bakery.latitude;
  final longitude = bakery.longitude;
  if (latitude == null || longitude == null) return null;
  return LatLng(latitude, longitude);
}

String? _metroLabel(Bakery bakery) {
  final metro = bakery.metro;
  if (metro == null) return null;
  final lower = metro.toLowerCase();
  return lower.startsWith('метро') || lower.startsWith('м.')
      ? metro
      : 'Метро $metro';
}

String _addressLine(Bakery bakery) {
  final metro = _metroLabel(bakery);
  return metro == null ? bakery.address : '${bakery.address} · $metro';
}

class _CircleIconButton extends StatefulWidget {
  final String asset;
  final VoidCallback onTap;
  const _CircleIconButton({required this.asset, required this.onTap});

  @override
  State<_CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<_CircleIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(widget.asset),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  const _SearchField({required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          SvgPicture.asset('assets/icons/search.svg', width: 18, height: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              cursorColor: AppColors.orange,
              style: AppTextStyles.body().copyWith(
                fontSize: 15,
                height: 20 / 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Найти пекарню',
                hintStyle: AppTextStyles.body().copyWith(
                  fontSize: 15,
                  height: 20 / 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchDropdown extends StatelessWidget {
  final List<Bakery> items;
  final ValueChanged<Bakery> onSelect;
  const _SearchDropdown({required this.items, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Ничего не найдено',
                style: AppTextStyles.body().copyWith(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: items.length,
              separatorBuilder: (context, i) => const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Color(0xFFF0EDEA),
              ),
              itemBuilder: (context, i) {
                final b = items[i];
                return InkWell(
                  onTap: () => onSelect(b),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.name,
                          style: AppTextStyles.body().copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _addressLine(b),
                          style: AppTextStyles.body().copyWith(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _MapContent extends StatelessWidget {
  final MapController controller;
  final List<Bakery> bakeries;
  final void Function(Bakery bakery, LatLng position) onPinTap;
  final VoidCallback onMapTap;
  const _MapContent({
    super.key,
    required this.controller,
    required this.bakeries,
    required this.onPinTap,
    required this.onMapTap,
  });

  static const _fallbackCenter = LatLng(55.7558, 37.6173);

  @override
  Widget build(BuildContext context) {
    final pins = [
      for (final bakery in bakeries)
        if (_position(bakery) case final position?) (bakery, position),
    ];
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: _fallbackCenter,
        initialZoom: 10,
        initialCameraFit: pins.isEmpty
            ? null
            : CameraFit.coordinates(
                coordinates: [for (final pin in pins) pin.$2],
                padding: const EdgeInsets.fromLTRB(
                  48,
                  72,
                  48,
                  AppBottomNav.barHeight + 48,
                ),
                maxZoom: 15,
              ),
        minZoom: 4,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onTap: (tapPosition, point) => onMapTap(),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.makovka.makovkaapp',
          maxNativeZoom: 20,
        ),
        MarkerLayer(
          markers: [
            for (final (bakery, position) in pins)
              Marker(
                point: position,
                width: 36,
                height: 44,
                alignment: Alignment.topCenter,
                child: _MapPin(onTap: () => onPinTap(bakery, position)),
              ),
          ],
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  final VoidCallback onTap;
  const _MapPin({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.orange,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.storefront, size: 15, color: Colors.white),
          ),
          Container(width: 2, height: 8, color: AppColors.orange),
        ],
      ),
    );
  }
}

class _BakeryInfoCard extends StatelessWidget {
  final Bakery bakery;
  final VoidCallback onClose;
  const _BakeryInfoCard({required this.bakery, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final hours = bakery.hoursText;
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E4),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.storefront,
                color: AppColors.orange,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hours != null) ...[
                    Text(
                      hours,
                      style: AppTextStyles.body().copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    bakery.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body().copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 20 / 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _addressLine(bakery),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body().copyWith(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListContent extends StatelessWidget {
  final List<Bakery> items;
  const _ListContent({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Ничего не найдено',
          style: AppTextStyles.body().copyWith(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        AppBottomNav.barHeight + 40,
      ),
      itemCount: items.length,
      separatorBuilder: (context, i) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final b = items[i];
        final hours = b.hoursText;
        final metro = _metroLabel(b);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hours != null) ...[
                Text(
                  hours,
                  style: AppTextStyles.body().copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.orange,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                b.name,
                style: AppTextStyles.body().copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 20 / 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                b.address,
                style: AppTextStyles.body().copyWith(
                  fontSize: 14,
                  height: 18 / 14,
                  color: AppColors.textSecondary,
                ),
              ),
              if (metro != null) ...[
                const SizedBox(height: 4),
                Text(
                  metro,
                  style: AppTextStyles.body().copyWith(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
