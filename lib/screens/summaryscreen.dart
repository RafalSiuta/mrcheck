import 'package:flutter/material.dart';
import 'package:mrcash/providers/cashprovider.dart';
import 'package:mrcash/screens/cash_creator.dart';
import 'package:mrcash/utils/constans/category_list.dart';
import 'package:mrcash/utils/extensions/string_extension.dart';
import 'package:mrcash/utils/routes/custom_route.dart';
import 'package:mrcash/widgets/cards/cash_card.dart';
import 'package:mrcash/widgets/cards/piggy.dart';
import 'package:provider/provider.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  static const double _borderRadius = 12;
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  bool _showCategories = false;
  final Set<String> _selectedCategories = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  Future<void> _pickDateRange() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      locale: const Locale('pl', 'PL'),
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      currentDate: now,
    );

    if (picked == null) return;

    setState(() {
      _selectedDateRange = picked;
    });
  }

  void _resetFilters() {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchController.clear();
      _selectedDateRange = null;
      _selectedCategories.clear();
      _showCategories = false;
    });
  }

  String _buildDateLine(CashProvider provider, DateTime date) {
    final weekday = provider.formatWeekdayLabel(date).capitalizeFirstLetter();
    final formattedDate = provider.formatDisplayDate(date);
    return '$weekday $formattedDate';
  }

  Widget _buildDateRangeLabel(BuildContext context, CashProvider provider) {
    if (_selectedDateRange == null) {
      return const SizedBox(height: 8);
    }

    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 6,
          height: 1.1,
        );

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 0, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            style: textStyle,
            children: [
              TextSpan(
                text:
                    'Od ${_buildDateLine(provider, _selectedDateRange!.start)}\n',
              ),
              TextSpan(
                text: 'Do ${_buildDateLine(provider, _selectedDateRange!.end)}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputBorder _buildSearchBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_borderRadius),
        topRight: Radius.circular(_borderRadius),
        bottomRight: Radius.circular(_borderRadius),
        bottomLeft: Radius.zero,
      ),
      borderSide: BorderSide(
        color: Theme.of(context).dialogTheme.titleTextStyle?.color ??
            Theme.of(context).colorScheme.onSurface,
        width: 0.5,
      ),
    );
  }

  bool get _hasActiveFilters =>
      _searchController.text.trim().isNotEmpty ||
      _selectedDateRange != null ||
      _selectedCategories.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Consumer<CashProvider>(
      builder: (context, cashProvider, _) {
        final media = MediaQuery.of(context);
        final isKeyboardOpen = media.viewInsets.bottom > 0;
        final searchResults = cashProvider.searchCash(
          keyword: _searchController.text,
          dateRange: _selectedDateRange,
          categories: _selectedCategories.toList(),
        );
        final totalValue = searchResults.fold<double>(
          0,
          (sum, result) => sum + result.value,
        );
        final summaryCurrency =
            searchResults.isNotEmpty ? searchResults.first.currency : 'zł';

        return SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Szukaj po slowie kluczowym',
                      isDense: true,
                      prefixIcon: IconButton(
                        onPressed: _pickDateRange,
                        icon: const Icon(Icons.calendar_month_outlined),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          // ignore: avoid_print
                          print('bbtn was clicked');
                        },
                        icon: const Icon(Icons.search),
                      ),
                      enabledBorder: _buildSearchBorder(context),
                      focusedBorder: _buildSearchBorder(context),
                      border: _buildSearchBorder(context),
                    ),
                  ),
                  _buildDateRangeLabel(context, cashProvider),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        if (isKeyboardOpen) {
                          FocusScope.of(context).unfocus();
                        }
                        setState(() {
                          _showCategories = !_showCategories;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Dodaj kategorie',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isKeyboardOpen || _showCategories
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: _showCategories && !isKeyboardOpen,
                    child: SizedBox(
                      width: media.size.width,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            List<Widget>.generate(categoryList.length, (index) {
                          final category = categoryList[index];
                          final isSelected =
                              _selectedCategories.contains(category);
                          return FilterChip(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(
                              horizontal: 0,
                              vertical: -4,
                            ),
                            label: Text(
                              category,
                              style: TextStyle(
                                fontSize: 8,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF0F0F0F),
                              ),
                            ),
                            labelPadding: EdgeInsets.zero,
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 0,
                            ),
                            side: const BorderSide(color: Color(0xFF0F0F0F)),
                            backgroundColor: Colors.transparent,
                            selectedColor: const Color(0xFF0F0F0F),
                            disabledColor: Colors.transparent,
                            selected: isSelected,
                            onSelected: (_) => _toggleCategory(category),
                          );
                        }),
                      ),
                    ),
                  ),
                  if (_showCategories && !isKeyboardOpen)
                    const SizedBox(height: 16)
                  else
                    const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'wyniki wyszukiwania',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hasActiveFilters
                        ? 'razem: ${totalValue.toStringAsFixed(2)} $summaryCurrency'
                        : 'Dodaj opcje wyszukiwania, aby zobaczyc wyniki.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: !_hasActiveFilters
                        ? const Center(
                            child: Text(
                              'Dodaj jakies opcje wyszukiwania.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : searchResults.isEmpty
                            ? const PiggyCard(
                                message: 'Brak wynikow dla wybranych filtrow',
                              )
                            : ListView.separated(
                                itemCount: searchResults.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 0.5,
                                  thickness: 0.5,
                                  color: Colors.grey.shade400,
                                ),
                                itemBuilder: (context, index) {
                                  final result = searchResults[index];
                                  return CashCard(
                                    name: result.name,
                                    value: result.value,
                                    date: result.date,
                                    isIncome: result.isIncome,
                                    currency: result.currency,
                                    showDate: true,
                                    onEdit: () async {
                                      await Navigator.push(
                                        context,
                                        CustomPageRoute(
                                          child: CashCreator(
                                            cash: result.cash,
                                            autofocusTitle: false,
                                          ),
                                          direction: AxisDirection.up,
                                        ),
                                      );
                                    },
                                    onDelete: () {},
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
