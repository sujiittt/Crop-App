import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final List<String> suggestions;

  const SearchBarWidget({
    Key? key,
    required this.hintText,
    required this.onSearchChanged,
    required this.onFilterTap,
    this.suggestions = const [],
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions =
            _focusNode.hasFocus && _filteredSuggestions.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterSuggestions(String query) {
    if (query.isEmpty) {
      _filteredSuggestions = [];
    } else {
      _filteredSuggestions = widget.suggestions
          .where((suggestion) =>
          suggestion.toLowerCase().contains(query.toLowerCase()))
          .take(5)
          .toList();
    }
    setState(() {
      _showSuggestions = _focusNode.hasFocus && _filteredSuggestions.isNotEmpty;
    });
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    widget.onSearchChanged(suggestion);
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .shadowColor
                            .withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: (value) {
                      widget.onSearchChanged(value);
                      _filterSuggestions(value);
                    },
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'search',
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          _controller.clear();
                          widget.onSearchChanged('');
                          _filterSuggestions('');
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          size: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: widget.onFilterTap,
                  icon: CustomIconWidget(
                    iconName: 'tune',
                    size: 20,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(3.w),
                ),
              ),
            ],
          ),
        ),
        if (_showSuggestions) ...[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: _filteredSuggestions.map((suggestion) {
                return ListTile(
                  dense: true,
                  leading: CustomIconWidget(
                    iconName: 'search',
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    suggestion,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () => _selectSuggestion(suggestion),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
