import 'dart:async';

import 'package:flutter/material.dart';

/// Swipeable pages with optional autoplay. Pauses while dragging, in the
/// background, under another route, and in an inactive tab's TickerMode.
class PagedCarousel extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? height;
  final Duration? autoAdvanceInterval;
  final bool overlayIndicator;
  final Widget? foreground;
  final double indicatorBottom;

  const PagedCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.height,
    this.autoAdvanceInterval,
    this.overlayIndicator = false,
    this.foreground,
    this.indicatorBottom = 10,
  });

  @override
  State<PagedCarousel> createState() => _PagedCarouselState();
}

class _PagedCarouselState extends State<PagedCarousel>
    with WidgetsBindingObserver {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;
  bool _scrolling = false;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _active = state == null || state == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant PagedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_page >= widget.itemCount) {
      _page = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) _controller.jumpToPage(0);
      });
    }
    if (oldWidget.itemCount != widget.itemCount ||
        oldWidget.autoAdvanceInterval != widget.autoAdvanceInterval) {
      _schedule();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final interval = widget.autoAdvanceInterval;
    if (interval == null ||
        widget.itemCount < 2 ||
        !_active ||
        _scrolling ||
        !TickerMode.valuesOf(context).enabled ||
        MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    _timer = Timer(interval, () {
      if (!mounted) return;
      if (!_controller.hasClients ||
          ModalRoute.of(context)?.isCurrent == false) {
        _schedule();
        return;
      }
      _controller.animateToPage(
        (_page + 1) % widget.itemCount,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Widget _indicator() {
    final overlay = widget.overlayIndicator;
    return Semantics(
      label: 'Ảnh ${_page + 1} / ${widget.itemCount}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: overlay
            ? BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: widget.itemCount > 8
            ? Text(
                '${_page + 1} / ${widget.itemCount}',
                style: TextStyle(
                  color: overlay
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.itemCount,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == _page ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: index == _page
                          ? Theme.of(context).colorScheme.primary
                          : overlay
                          ? Colors.white54
                          : Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pager = SizedBox(
      height: widget.height,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.depth != 0) return false;
          if (notification is ScrollStartNotification) {
            _scrolling = true;
            _timer?.cancel();
          } else if (notification is ScrollEndNotification) {
            _scrolling = false;
            _schedule();
          }
          return false;
        },
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.itemCount,
          onPageChanged: (page) => setState(() => _page = page),
          itemBuilder: widget.itemBuilder,
        ),
      ),
    );
    if (widget.overlayIndicator) {
      return Stack(
        fit: StackFit.expand,
        children: [
          pager,
          if (widget.foreground != null)
            IgnorePointer(child: widget.foreground!),
          if (widget.itemCount > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: widget.indicatorBottom,
              child: IgnorePointer(child: Center(child: _indicator())),
            ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        pager,
        if (widget.itemCount > 1) ...[const SizedBox(height: 2), _indicator()],
      ],
    );
  }
}
