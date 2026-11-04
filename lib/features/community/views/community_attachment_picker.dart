import 'dart:async';

import 'package:flutter/material.dart';

import '../data/datasources/community_attachment_datasource.dart';
import '../../../core/network/api_error_handler.dart';

class CommunityAttachmentPicker extends StatefulWidget {
  final bool journeys;
  final CommunityAttachmentDataSource? dataSource;
  const CommunityAttachmentPicker({
    super.key,
    required this.journeys,
    this.dataSource,
  });
  @override
  State<CommunityAttachmentPicker> createState() =>
      _CommunityAttachmentPickerState();
}

class _CommunityAttachmentPickerState extends State<CommunityAttachmentPicker> {
  late final _source = widget.dataSource ?? CommunityAttachmentDataSource();
  final _search = TextEditingController();
  Timer? _debounce;
  final List<CommunityAttachment> _items = [];
  int _page = 0, _generation = 0;
  bool _loading = false, _hasMore = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (!reset && (_loading || !_hasMore)) return;
    final generation = reset ? ++_generation : _generation;
    final query = _search.text;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _items.clear();
        _page = 0;
      }
    });
    try {
      final result = await _source.load(
        journeys: widget.journeys,
        page: _page + 1,
        query: query,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        final ids = _items.map((p) => p.id).toSet();
        _items.addAll(result.items.where((p) => ids.add(p.id)));
        _page++;
        _hasMore = result.hasMore;
      });
    } catch (e) {
      if (mounted && generation == _generation) {
        setState(() => _error = ApiErrorHandler.handle(e));
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _generation++;
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.journeys ? 'Chọn hành trình của bạn' : 'Gắn thẻ địa điểm',
      ),
    ),
    body: Column(
      children: [
        if (!widget.journeys)
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                labelText: 'Tìm địa điểm',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) {
                _debounce?.cancel();
                _generation++;
                _debounce = Timer(
                  const Duration(milliseconds: 350),
                  () => _load(reset: true),
                );
              },
            ),
          ),
        if (widget.journeys)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Chỉ chia sẻ hành trình đã đồng bộ lên máy chủ.'),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                TextButton(
                  onPressed: () => _load(reset: _page == 0),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        Expanded(
          child: _loading && _items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty && _error == null
              ? const Center(child: Text('Chưa có dữ liệu để chọn.'))
              : ListView.builder(
                  itemCount:
                      _items.length + (_hasMore && _items.isNotEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _items.length) {
                      return TextButton(
                        onPressed: _loading ? null : _load,
                        child: Text(_loading ? 'Đang tải...' : 'Xem thêm'),
                      );
                    }
                    final item = _items[index];
                    return ListTile(
                      leading: Icon(
                        widget.journeys ? Icons.hiking : Icons.place_outlined,
                      ),
                      title: Text(item.name),
                      onTap: () => Navigator.pop(context, item),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}
