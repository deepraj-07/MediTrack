import 'package:flutter/material.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/theme/app_theme.dart';

class MedicinesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> medicinesList;
  final Function(int) onToggleStatus;
  final Function(String, String, String, String) onAddMedicine;
  final int notificationCount;
  final VoidCallback onOpenNotifications;

  const MedicinesScreen({
    super.key,
    required this.medicinesList,
    required this.onToggleStatus,
    required this.onAddMedicine,
    required this.notificationCount,
    required this.onOpenNotifications,
  });

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  String _activeFilter = 'all'; // 'all', 'pending', 'taken'

  @override
  Widget build(BuildContext context) {
    // Filter list items based on selection
    List<Map<String, dynamic>> filteredList = widget.medicinesList.where((med) {
      if (_activeFilter == 'pending') return med['isTaken'] == false;
      if (_activeFilter == 'taken') return med['isTaken'] == true;
      return true;
    }).toList();

    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.medicinesTitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: c.primaryText,
          ),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none_rounded, color: c.secondaryText),
                onPressed: widget.onOpenNotifications,
              ),
              if (widget.notificationCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.notificationCount > 9 ? '9+' : '${widget.notificationCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildFilterTabs(),
          ),
          
          const SizedBox(height: 16),
          
          // Today's Medicines Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.todayMedicines,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: c.primaryText,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Medicines List
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      // Find the actual index in main list
                      int mainIndex = widget.medicinesList.indexOf(item);
                      return _buildMedicineItemCard(item, mainIndex);
                    },
                  ),
          ),
        ],
      ),
      
      // Bottom Floating Add Medicine Button
      floatingActionButton: _buildAddMedicineFloatingBtn(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Segmented filters
  Widget _buildFilterTabs() {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.divider,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildFilterTab('all', AppLocalizations.of(context)!.filterAll),
          _buildFilterTab('pending', AppLocalizations.of(context)!.filterPending),
          _buildFilterTab('taken', AppLocalizations.of(context)!.filterTaken),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filter, String label) {
    final c = context.appColors;
    bool isActive = _activeFilter == filter;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeFilter = filter;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? c.cardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF7F56D9) : c.secondaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom Item Card
  Widget _buildMedicineItemCard(Map<String, dynamic> item, int mainIndex) {
    final c = context.appColors;
    bool isTaken = item['isTaken'] ?? false;
    String timeStr = item['time'] ?? '08:00 AM';
    
    // Determine morning or evening icon
    bool isMorning = true;
    if (timeStr.contains('PM')) {
      int hour = int.tryParse(timeStr.split(':')[0]) ?? 12;
      if (hour >= 4 && hour != 12) {
        isMorning = false;
      }
    }
    
    Color iconBgColor = isMorning ? const Color(0xFFFFFBEB) : const Color(0xFFE0E7FF);
    String iconEmoji = isMorning ? '☀️' : '🌙';
    Color timeColor = isMorning ? const Color(0xFFF59E0B) : const Color(0xFF4F46E5);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTaken ? const Color(0xFFECFDF3) : c.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Time Period Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(iconEmoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: timeColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['name'] ?? AppLocalizations.of(context)!.medicineDefaultName,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: c.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item['dose']} - ${item['instruction']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: c.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          
          // Action Toggle
          InkWell(
            onTap: () => widget.onToggleStatus(mainIndex),
            borderRadius: BorderRadius.circular(100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isTaken ? const Color(0xFF12B76A) : c.cardBg,
                    border: Border.all(
                      color: isTaken ? const Color(0xFF12B76A) : c.divider,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: isTaken ? Colors.white : Colors.transparent,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isTaken ? AppLocalizations.of(context)!.taken : AppLocalizations.of(context)!.pending,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isTaken ? const Color(0xFF12B76A) : c.tertiaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Floating purple gradient add medicine button
  Widget _buildAddMedicineFloatingBtn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () => _showAddMedicineModal(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF7F56D9), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7F56D9).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '+',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.addMedicine,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.addMedicineSubtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modal Bottom Sheet Form for adding medicine
  void _showAddMedicineModal(BuildContext context) {
    final nameController = TextEditingController();
    final doseController = TextEditingController(text: AppLocalizations.of(context)!.dose1Pill);
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
    String selectedInstruction = AppLocalizations.of(context)!.instructionAfterBreakfast;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final c = context.appColors;
            return Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 20.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grab handle / header
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: c.divider,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.addMedicine,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: c.primaryText,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: c.tertiaryText),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(color: c.border),
                  const SizedBox(height: 12),
                  
                  // Medicine Name Field
                  Text(
                    AppLocalizations.of(context)!.medicineName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c.secondaryText),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: c.primaryText),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.medicineNameHint,
                      hintStyle: TextStyle(fontFamily: 'Outfit', color: c.tertiaryText, fontWeight: FontWeight.normal),
                      filled: true,
                      fillColor: c.scaffoldBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: c.divider, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: c.divider, width: 2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Time Selector
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.time,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c.secondaryText),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (time != null) {
                                  setModalState(() {
                                    selectedTime = time;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: c.scaffoldBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: c.divider, width: 2),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedTime.format(context),
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: c.primaryText,
                                      ),
                                    ),
                                    const Icon(Icons.access_time_rounded, color: Color(0xFF7F56D9)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Dosage Field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.dose,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c.secondaryText),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: doseController,
                              style: TextStyle(fontWeight: FontWeight.w600, color: c.primaryText),
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.doseHint,
                                filled: true,
                                fillColor: c.scaffoldBg,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: c.divider, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: c.divider, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Instruction Dropdown
                  Text(
                    AppLocalizations.of(context)!.instruction,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c.secondaryText),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: c.scaffoldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.divider, width: 2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedInstruction,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF7F56D9)),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: c.primaryText,
                        ),
                        items: <String>[
                          AppLocalizations.of(context)!.instructionAfterBreakfast,
                          AppLocalizations.of(context)!.instructionAfterLunch,
                          AppLocalizations.of(context)!.instructionAfterDinner,
                          AppLocalizations.of(context)!.instructionBeforeSleep,
                          AppLocalizations.of(context)!.instructionEmptyStomach,
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setModalState(() {
                              selectedInstruction = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          String timeFormatted = selectedTime.format(context);
                          widget.onAddMedicine(
                            nameController.text,
                            timeFormatted,
                            doseController.text,
                            selectedInstruction,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7F56D9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.scheduleMedicine,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final c = context.appColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💊', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.noMedicines,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.secondaryText),
          ),
          Text(
            AppLocalizations.of(context)!.noMedicinesSubtitle,
            style: TextStyle(fontSize: 13, color: c.tertiaryText),
          ),
        ],
      ),
    );
  }
}
