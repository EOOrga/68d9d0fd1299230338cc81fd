import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bool _screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');
const String _recordsKey = 'bayle_operations_records_v1';
const String _appName = 'BAYLE PHILIPPE LEOPOLD';

void main() {
  runApp(const BayleOpsApp(screenshotMode: _screenshotMode));
}

class BayleOpsApp extends StatelessWidget {
  const BayleOpsApp({super.key, required this.screenshotMode});

  final bool screenshotMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appName,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: OperationsShell(screenshotMode: screenshotMode),
    );
  }
}

ThemeData _buildTheme() {
  const primary = Color(0xFF32B8F2);
  const secondary = Color(0xFF16C7A6);
  const tertiary = Color(0xFFF4B727);
  const purple = Color(0xFF8E63F2);
  const surface = Color(0xFF101B2D);
  const background = Color(0xFF071321);

  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.dark,
    primary: primary,
    secondary: secondary,
    tertiary: tertiary,
    surface: surface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: scheme,
    textTheme: Typography.whiteMountainView.apply(
      bodyColor: const Color(0xFFF5F8FC),
      displayColor: const Color(0xFFF5F8FC),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF111E31),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF253B58)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: background,
      foregroundColor: Color(0xFFF5F8FC),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0B1728),
      indicatorColor: primary.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tertiary,
        foregroundColor: const Color(0xFF10131A),
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0B1728),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      BrandAccentColors(purple: purple),
    ],
  );
}

@immutable
class BrandAccentColors extends ThemeExtension<BrandAccentColors> {
  const BrandAccentColors({required this.purple});

  final Color purple;

  @override
  BrandAccentColors copyWith({Color? purple}) {
    return BrandAccentColors(purple: purple ?? this.purple);
  }

  @override
  BrandAccentColors lerp(ThemeExtension<BrandAccentColors>? other, double t) {
    if (other is! BrandAccentColors) {
      return this;
    }
    return BrandAccentColors(purple: Color.lerp(purple, other.purple, t)!);
  }
}

enum RecordKind {
  patrolLog,
  equipmentCheckout,
  procurementRequest,
  supplyOrder,
}

extension RecordKindInfo on RecordKind {
  String get storageName => switch (this) {
    RecordKind.patrolLog => 'patrolLog',
    RecordKind.equipmentCheckout => 'equipmentCheckout',
    RecordKind.procurementRequest => 'procurementRequest',
    RecordKind.supplyOrder => 'supplyOrder',
  };

  String get label => switch (this) {
    RecordKind.patrolLog => 'Guard patrol',
    RecordKind.equipmentCheckout => 'Equipment checkout',
    RecordKind.procurementRequest => 'Procurement request',
    RecordKind.supplyOrder => 'Supply order',
  };

  String get shortLabel => switch (this) {
    RecordKind.patrolLog => 'Patrol',
    RecordKind.equipmentCheckout => 'Equipment',
    RecordKind.procurementRequest => 'Procurement',
    RecordKind.supplyOrder => 'Supplies',
  };

  IconData get icon => switch (this) {
    RecordKind.patrolLog => Icons.route_outlined,
    RecordKind.equipmentCheckout => Icons.inventory_2_outlined,
    RecordKind.procurementRequest => Icons.fact_check_outlined,
    RecordKind.supplyOrder => Icons.shopping_cart_checkout_outlined,
  };

  Color get accent => switch (this) {
    RecordKind.patrolLog => const Color(0xFF32B8F2),
    RecordKind.equipmentCheckout => const Color(0xFF16C7A6),
    RecordKind.procurementRequest => const Color(0xFF8E63F2),
    RecordKind.supplyOrder => const Color(0xFFF4B727),
  };

  static RecordKind fromStorage(String value) {
    return RecordKind.values.firstWhere(
      (kind) => kind.storageName == value,
      orElse: () => RecordKind.patrolLog,
    );
  }
}

class OperationRecord {
  const OperationRecord({
    required this.id,
    required this.kind,
    required this.title,
    required this.owner,
    required this.location,
    required this.status,
    required this.priority,
    required this.quantity,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final RecordKind kind;
  final String title;
  final String owner;
  final String location;
  final String status;
  final String priority;
  final int quantity;
  final String notes;
  final DateTime createdAt;

  OperationRecord copyWith({
    RecordKind? kind,
    String? title,
    String? owner,
    String? location,
    String? status,
    String? priority,
    int? quantity,
    String? notes,
    DateTime? createdAt,
  }) {
    return OperationRecord(
      id: id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      location: location ?? this.location,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'kind': kind.storageName,
      'title': title,
      'owner': owner,
      'location': location,
      'status': status,
      'priority': priority,
      'quantity': quantity,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OperationRecord.fromJson(Map<String, dynamic> json) {
    return OperationRecord(
      id: json['id'] as String? ?? UniqueKey().toString(),
      kind: RecordKindInfo.fromStorage(json['kind'] as String? ?? ''),
      title: json['title'] as String? ?? 'Untitled record',
      owner: json['owner'] as String? ?? 'Unassigned',
      location: json['location'] as String? ?? 'Main office',
      status: json['status'] as String? ?? 'Open',
      priority: json['priority'] as String? ?? 'Normal',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      notes: json['notes'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({super.key, required this.screenshotMode});

  final bool screenshotMode;

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  var _index = 0;
  var _loading = true;
  List<OperationRecord> _records = const [];

  @override
  void initState() {
    super.initState();
    if (widget.screenshotMode) {
      _records = _sampleRecords();
      _loading = false;
    } else {
      _loadRecords();
    }
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recordsKey);
    if (!mounted) {
      return;
    }
    setState(() {
      _records = raw == null || raw.isEmpty
          ? <OperationRecord>[]
          : (jsonDecode(raw) as List<dynamic>)
                .whereType<Map<String, dynamic>>()
                .map(OperationRecord.fromJson)
                .toList();
      _loading = false;
    });
  }

  Future<void> _saveRecords() async {
    if (widget.screenshotMode) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _records.map((record) => record.toJson()).toList(),
    );
    await prefs.setString(_recordsKey, encoded);
  }

  Future<void> _openForm({RecordKind? kind}) async {
    final record = await Navigator.of(context).push<OperationRecord>(
      MaterialPageRoute(
        builder: (_) => RecordFormPage(initialKind: kind ?? _defaultKind),
      ),
    );
    if (record == null || !mounted) {
      return;
    }
    setState(() => _records = <OperationRecord>[record, ..._records]);
    await _saveRecords();
  }

  Future<void> _openDetail(OperationRecord record) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RecordDetailPage(
          record: record,
          onChanged: (updated) async {
            setState(() {
              _records = _records
                  .map((item) => item.id == updated.id ? updated : item)
                  .toList();
            });
            await _saveRecords();
          },
        ),
      ),
    );
  }

  RecordKind get _defaultKind => switch (_index) {
    1 => RecordKind.patrolLog,
    2 => RecordKind.equipmentCheckout,
    3 => RecordKind.procurementRequest,
    _ => RecordKind.patrolLog,
  };

  @override
  Widget build(BuildContext context) {
    final titles = <String>[
      'Operations',
      'Patrol logs',
      'Equipment',
      'Requests',
      'Privacy',
    ];
    final pages = <Widget>[
      DashboardScreen(records: _records, onOpenRecord: _openDetail),
      KindRecordsScreen(
        title: 'Guard patrol logs',
        subtitle: 'Checkpoints, incidents, and route coverage',
        emptyText: 'Create the first patrol log to begin a route history.',
        kinds: const [RecordKind.patrolLog],
        records: _records,
        onOpenRecord: _openDetail,
      ),
      KindRecordsScreen(
        title: 'Equipment checkout',
        subtitle: 'Issued radios, scanners, vehicle kits, and returns',
        emptyText: 'Add equipment checkouts to track who has each kit.',
        kinds: const [RecordKind.equipmentCheckout],
        records: _records,
        onOpenRecord: _openDetail,
      ),
      RequestBoardScreen(records: _records, onOpenRecord: _openDetail),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titles[_index]),
            const SizedBox(height: 2),
            Text(
              _appName,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF9EB5D1),
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        actions: [
          if (_index != 4)
            IconButton.filledTonal(
              key: const Key('addRecordButton'),
              tooltip: 'New record',
              onPressed: () => _openForm(kind: _defaultKind),
              icon: const Icon(Icons.add_task_outlined),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
            ),
      floatingActionButton: _index == 4
          ? null
          : FloatingActionButton.extended(
              key: const Key('floatingNewRecordButton'),
              onPressed: () => _openForm(kind: _defaultKind),
              icon: const Icon(Icons.add),
              label: const Text('New'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Patrol',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Gear',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Privacy',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.records,
    required this.onOpenRecord,
  });

  final List<OperationRecord> records;
  final ValueChanged<OperationRecord> onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final urgentCount = records
        .where((record) => record.priority == 'Urgent')
        .length;
    final completedCount = records
        .where((record) => record.status == 'Completed')
        .length;
    final recent = records.take(4).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        const HeroPanel(),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.38,
          children: [
            SummaryTile(
              label: 'Patrols today',
              value: _countKind(records, RecordKind.patrolLog).toString(),
              icon: Icons.route_outlined,
              color: RecordKind.patrolLog.accent,
            ),
            SummaryTile(
              label: 'Gear checked out',
              value: _countKind(
                records,
                RecordKind.equipmentCheckout,
              ).toString(),
              icon: Icons.inventory_2_outlined,
              color: RecordKind.equipmentCheckout.accent,
            ),
            SummaryTile(
              label: 'Open requests',
              value:
                  (_countKind(records, RecordKind.procurementRequest) +
                          _countKind(records, RecordKind.supplyOrder))
                      .toString(),
              icon: Icons.assignment_outlined,
              color: RecordKind.procurementRequest.accent,
            ),
            SummaryTile(
              label: 'Urgent',
              value: urgentCount.toString(),
              icon: Icons.priority_high_outlined,
              color: RecordKind.supplyOrder.accent,
            ),
          ],
        ),
        const SizedBox(height: 18),
        SectionHeader(
          title: 'Control desk',
          action: '$completedCount completed',
        ),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          const EmptyPanel(
            icon: Icons.assignment_add,
            title: 'No records yet',
            body: 'Use New to add a patrol, equipment checkout, or request.',
          )
        else
          ...recent.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OperationCard(record: record, onTap: onOpenRecord),
            ),
          ),
      ],
    );
  }

  static int _countKind(List<OperationRecord> records, RecordKind kind) {
    return records.where((record) => record.kind == kind).length;
  }
}

class HeroPanel extends StatelessWidget {
  const HeroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A2E54), Color(0xFF062236), Color(0xFF132245)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF254766)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'docs/icon.png',
              width: 74,
              height: 74,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily operations board',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Patrol coverage, gear custody, purchase needs, and supply movement stay in one local workspace.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFC7D3E2),
                    height: 1.32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryTile extends StatelessWidget {
  const SummaryTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: const Color(0xFFD7E2EF)),
            ),
          ],
        ),
      ),
    );
  }
}

class KindRecordsScreen extends StatelessWidget {
  const KindRecordsScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emptyText,
    required this.kinds,
    required this.records,
    required this.onOpenRecord,
  });

  final String title;
  final String subtitle;
  final String emptyText;
  final List<RecordKind> kinds;
  final List<OperationRecord> records;
  final ValueChanged<OperationRecord> onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final visible = records
        .where((record) => kinds.contains(record.kind))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        WorkstreamHeader(title: title, subtitle: subtitle, kinds: kinds),
        const SizedBox(height: 16),
        if (visible.isEmpty)
          EmptyPanel(
            icon: kinds.first.icon,
            title: 'No ${kinds.first.shortLabel.toLowerCase()} records',
            body: emptyText,
          )
        else
          ...visible.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OperationCard(record: record, onTap: onOpenRecord),
            ),
          ),
      ],
    );
  }
}

class RequestBoardScreen extends StatelessWidget {
  const RequestBoardScreen({
    super.key,
    required this.records,
    required this.onOpenRecord,
  });

  final List<OperationRecord> records;
  final ValueChanged<OperationRecord> onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final procurement = records
        .where((record) => record.kind == RecordKind.procurementRequest)
        .toList();
    final supplies = records
        .where((record) => record.kind == RecordKind.supplyOrder)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        const WorkstreamHeader(
          title: 'Procurement and supply',
          subtitle: 'Requests, approvals, reorder quantities, and readiness',
          kinds: [RecordKind.procurementRequest, RecordKind.supplyOrder],
        ),
        const SizedBox(height: 16),
        SectionHeader(
          title: 'Procurement requests',
          action: '${procurement.length} active',
        ),
        const SizedBox(height: 10),
        if (procurement.isEmpty)
          const EmptyPanel(
            icon: Icons.fact_check_outlined,
            title: 'No procurement requests',
            body: 'Create a request for vendor items or service needs.',
          )
        else
          ...procurement.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OperationCard(record: record, onTap: onOpenRecord),
            ),
          ),
        const SizedBox(height: 10),
        SectionHeader(
          title: 'Supply orders',
          action: '${supplies.length} open',
        ),
        const SizedBox(height: 10),
        if (supplies.isEmpty)
          const EmptyPanel(
            icon: Icons.shopping_cart_checkout_outlined,
            title: 'No supply orders',
            body:
                'Add reorder cards for uniforms, office stock, or field kits.',
          )
        else
          ...supplies.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OperationCard(record: record, onTap: onOpenRecord),
            ),
          ),
      ],
    );
  }
}

class WorkstreamHeader extends StatelessWidget {
  const WorkstreamHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.kinds,
  });

  final String title;
  final String subtitle;
  final List<RecordKind> kinds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF0B1728),
        border: Border.all(color: const Color(0xFF253B58)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...kinds.map(
                (kind) => Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: kind.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(kind.icon, color: kind.accent, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFC7D3E2),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class OperationCard extends StatelessWidget {
  const OperationCard({super.key, required this.record, required this.onTap});

  final OperationRecord record;
  final ValueChanged<OperationRecord> onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        key: Key('record_${record.id}'),
        borderRadius: BorderRadius.circular(8),
        onTap: () => onTap(record),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: record.kind.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(record.kind.icon, color: record.kind.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${record.kind.label} | ${record.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFAFC1D4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusChip(
                          label: record.status,
                          color: record.kind.accent,
                        ),
                        StatusChip(
                          label: record.priority,
                          color: _priorityColor(record.priority),
                        ),
                        if (record.quantity > 1)
                          StatusChip(
                            label: 'Qty ${record.quantity}',
                            color: const Color(0xFFF4B727),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF9EB5D1)),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFFF5F8FC),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          action,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF9EB5D1),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFC7D3E2),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({
    super.key,
    required this.record,
    required this.onChanged,
  });

  final OperationRecord record;
  final ValueChanged<OperationRecord> onChanged;

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late OperationRecord _record = widget.record;

  void _updateStatus(String status) {
    setState(() => _record = _record.copyWith(status: status));
    widget.onChanged(_record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record detail')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _record.kind.accent.withValues(alpha: 0.12),
              border: Border.all(
                color: _record.kind.accent.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_record.kind.icon, color: _record.kind.accent, size: 34),
                const SizedBox(height: 14),
                Text(
                  _record.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _record.kind.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFFD7E2EF),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(
                      label: _record.status,
                      color: _record.kind.accent,
                    ),
                    StatusChip(
                      label: _record.priority,
                      color: _priorityColor(_record.priority),
                    ),
                    StatusChip(
                      label: 'Qty ${_record.quantity}',
                      color: const Color(0xFFF4B727),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DetailGrid(record: _record),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _record.notes.isEmpty
                        ? 'No notes have been added.'
                        : _record.notes,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFC7D3E2),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(title: 'Next status', action: _record.owner),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _updateStatus('In progress'),
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  key: const Key('completeRecordButton'),
                  onPressed: () => _updateStatus('Completed'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Complete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DetailGrid extends StatelessWidget {
  const DetailGrid({super.key, required this.record});

  final OperationRecord record;

  @override
  Widget build(BuildContext context) {
    final details = <({IconData icon, String label, String value})>[
      (icon: Icons.person_outline, label: 'Owner', value: record.owner),
      (icon: Icons.place_outlined, label: 'Location', value: record.location),
      (
        icon: Icons.calendar_today_outlined,
        label: 'Opened',
        value: _dateLabel(record.createdAt),
      ),
      (
        icon: Icons.layers_outlined,
        label: 'Quantity',
        value: '${record.quantity}',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: details.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final detail = details[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(detail.icon, color: record.kind.accent),
                const Spacer(),
                Text(
                  detail.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF9EB5D1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RecordFormPage extends StatefulWidget {
  const RecordFormPage({super.key, required this.initialKind});

  final RecordKind initialKind;

  @override
  State<RecordFormPage> createState() => _RecordFormPageState();
}

class _RecordFormPageState extends State<RecordFormPage> {
  final _formKey = GlobalKey<FormState>();
  late RecordKind _kind = widget.initialKind;
  final _titleController = TextEditingController();
  final _ownerController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  var _status = 'Open';
  var _priority = 'Normal';

  @override
  void initState() {
    super.initState();
    _applyKindTemplate(widget.initialKind, overwrite: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyKindTemplate(RecordKind kind, {bool overwrite = false}) {
    if (!overwrite && _titleController.text.isNotEmpty) {
      return;
    }
    switch (kind) {
      case RecordKind.patrolLog:
        _titleController.text = 'North gate patrol';
        _ownerController.text = 'Shift supervisor';
        _locationController.text = 'North gate';
        _notesController.text = 'Checkpoint sweep with badge and gate status.';
        break;
      case RecordKind.equipmentCheckout:
        _titleController.text = 'Radio kit checkout';
        _ownerController.text = 'Field team';
        _locationController.text = 'Equipment room';
        _notesController.text =
            'Record asset tag, condition, and return window.';
        break;
      case RecordKind.procurementRequest:
        _titleController.text = 'Replacement scanner request';
        _ownerController.text = 'Operations desk';
        _locationController.text = 'Procurement';
        _notesController.text =
            'Attach vendor quote and approval status locally.';
        break;
      case RecordKind.supplyOrder:
        _titleController.text = 'Uniform stock reorder';
        _ownerController.text = 'Supply lead';
        _locationController.text = 'Storage';
        _notesController.text =
            'Track reorder quantity and delivery readiness.';
        break;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final record = OperationRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      kind: _kind,
      title: _titleController.text.trim(),
      owner: _ownerController.text.trim(),
      location: _locationController.text.trim(),
      status: _status,
      priority: _priority,
      quantity: quantity < 1 ? 1 : quantity,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );
    Navigator.of(context).pop(record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New operations record')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          key: const Key('saveRecordButton'),
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save record'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
          children: [
            Text(
              'Record type',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RecordKind.values.map((kind) {
                return ChoiceChip(
                  selected: _kind == kind,
                  label: Text(kind.shortLabel),
                  avatar: Icon(kind.icon, size: 18),
                  onSelected: (_) {
                    setState(() => _kind = kind);
                    _applyKindTemplate(kind);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            TextFormField(
              key: const Key('recordTitleField'),
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Add a title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ownerController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Owner',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Add an owner' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Add a location'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: const ['Open', 'Submitted', 'In progress', 'Ready']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _status = value ?? _status),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      prefixIcon: Icon(Icons.priority_high_outlined),
                    ),
                    items: const ['Low', 'Normal', 'Urgent']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _priority = value ?? _priority),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                prefixIcon: Icon(Icons.layers_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Container(
          height: 178,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: AssetImage('docs/featured.png'),
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const PrivacyCard(
          icon: Icons.storage_outlined,
          title: 'Local records',
          body:
              'Patrol logs, equipment custody, requests, supply orders, and preferences stay on this device.',
        ),
        const SizedBox(height: 10),
        const PrivacyCard(
          icon: Icons.cloud_off_outlined,
          title: 'No account or sync',
          body:
              'The app does not require login, cloud storage, analytics, advertising identifiers, or background network services.',
        ),
        const SizedBox(height: 10),
        const PrivacyCard(
          icon: Icons.delete_outline,
          title: 'Removal',
          body:
              'Uninstalling the app removes locally stored records according to Android system behavior.',
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _appName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Support: support@baylephilippeleopold.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFC7D3E2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PrivacyCard extends StatelessWidget {
  const PrivacyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFC7D3E2),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _priorityColor(String priority) {
  return switch (priority) {
    'Urgent' => const Color(0xFFFF6B6B),
    'Low' => const Color(0xFF16C7A6),
    _ => const Color(0xFF32B8F2),
  };
}

String _dateLabel(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$month/$day/${local.year}';
}

List<OperationRecord> _sampleRecords() {
  final now = DateTime(2026, 5, 12, 9, 30);
  return [
    OperationRecord(
      id: 'sample_patrol_north',
      kind: RecordKind.patrolLog,
      title: 'North gate route sweep',
      owner: 'A. Martin',
      location: 'North gate',
      status: 'In progress',
      priority: 'Urgent',
      quantity: 1,
      notes:
          'Checkpoint badges verified. Loading bay door requires a second pass before close.',
      createdAt: now.subtract(const Duration(minutes: 48)),
    ),
    OperationRecord(
      id: 'sample_equipment_radio',
      kind: RecordKind.equipmentCheckout,
      title: 'Radio kit B12 checkout',
      owner: 'Security shift 2',
      location: 'Equipment room',
      status: 'Checked out',
      priority: 'Normal',
      quantity: 4,
      notes:
          'Radios issued with chargers and spare batteries. Return expected after evening patrol.',
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    OperationRecord(
      id: 'sample_procurement_scanner',
      kind: RecordKind.procurementRequest,
      title: 'Handheld scanner replacement',
      owner: 'Operations desk',
      location: 'Procurement queue',
      status: 'Submitted',
      priority: 'Urgent',
      quantity: 2,
      notes:
          'Two barcode scanners are failing on intake. Request includes vendor quote and expected lead time.',
      createdAt: now.subtract(const Duration(hours: 3)),
    ),
    OperationRecord(
      id: 'sample_supply_uniforms',
      kind: RecordKind.supplyOrder,
      title: 'Uniform stock reorder',
      owner: 'Supply lead',
      location: 'Storage B',
      status: 'Ready',
      priority: 'Normal',
      quantity: 18,
      notes:
          'Replenish high-visibility vests, rain jackets, and visitor badge sleeves.',
      createdAt: now.subtract(const Duration(hours: 5)),
    ),
    OperationRecord(
      id: 'sample_patrol_loading',
      kind: RecordKind.patrolLog,
      title: 'Loading bay incident note',
      owner: 'L. Bernard',
      location: 'Loading bay',
      status: 'Open',
      priority: 'Normal',
      quantity: 1,
      notes: 'Unscheduled delivery arrived after the morning gate checklist.',
      createdAt: now.subtract(const Duration(hours: 6)),
    ),
    OperationRecord(
      id: 'sample_supply_toner',
      kind: RecordKind.supplyOrder,
      title: 'Printer toner and seals',
      owner: 'Admin desk',
      location: 'Office supplies',
      status: 'Open',
      priority: 'Low',
      quantity: 9,
      notes: 'Standard monthly supply order for dispatch paperwork.',
      createdAt: now.subtract(const Duration(days: 1)),
    ),
  ];
}
