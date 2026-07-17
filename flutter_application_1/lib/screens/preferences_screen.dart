import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/local_storage.dart';

import '../services/auth_api.dart';
import '../services/auth_session.dart';
import '../services/preference_repository.dart';
import '../theme/softinsa_theme.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  static String firstLoginPreferencesDoneKeyFor(int accountId) {
    return 'first_login_preferences_done:$accountId';
  }

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<BackendArea> _areas = const [];
  bool _isLoading = true;
  bool _isSaving = false;
  String _statusMessage = '';
  String _searchTerm = '';

  int get _selectedCount => _areas.where((area) => area.selected).length;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAreas() async {
    try {
      final accountId = await AuthSession.getAccountId();
      if (!mounted) return;

      if (accountId == null || accountId <= 0) {
        setState(() {
          _statusMessage = AppLocalizations.of(context)!.accountIdentificationError;
          _areas = const [];
        });
        return;
      }

      final backendAreas = await PreferenceRepository.instance.loadPreferenceAreas(
        accountId: accountId,
      );

      if (!mounted) return;

      setState(() {
        _areas = backendAreas;
        _statusMessage = '';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _statusMessage = AppLocalizations.of(context)!.couldNotLoadAreas;
        _areas = const [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshAreas() async {
    setState(() {
      _isLoading = true;
    });
    await _loadAreas();
  }

  List<BackendArea> get _filteredAreas {
    final normalizedSearch = _searchTerm.trim().toLowerCase();
    if (normalizedSearch.isEmpty) {
      return _areas;
    }

    return _areas.where((area) {
      final searchable =
          '${area.name} ${area.description} ${area.serviceLine}'.toLowerCase();
      return searchable.contains(normalizedSearch);
    }).toList(growable: false);
  }

  void _toggleArea(int areaId) {
    setState(() {
      _areas = _areas
          .map(
            (area) => area.id == areaId
                ? BackendArea(
                    id: area.id,
                    name: area.name,
                    description: area.description,
                    serviceLine: area.serviceLine,
                    badgeCount: area.badgeCount,
                    selected: !area.selected,
                  )
                : area,
          )
          .toList(growable: false);
      _statusMessage = '';
    });
  }

  void _clearSelection() {
    setState(() {
      _areas = _areas
          .map(
            (area) => BackendArea(
              id: area.id,
              name: area.name,
              description: area.description,
              serviceLine: area.serviceLine,
              badgeCount: area.badgeCount,
              selected: false,
            ),
          )
          .toList(growable: false);
      _statusMessage = '';
    });
  }

  Future<void> _saveAndContinue() async {
    final selectedAreaIds = _areas
        .where((area) => area.selected)
        .map((area) => area.id)
        .toList(growable: false);

    if (selectedAreaIds.isEmpty) {
      setState(() {
        _statusMessage = AppLocalizations.of(context)!.selectAtLeastOne;
      });
      return;
    }

    final accountId = await AuthSession.getAccountId();
    if (!mounted) {
      return;
    }

    if (accountId == null || accountId <= 0) {
      setState(() {
        _statusMessage = AppLocalizations.of(context)!.accountIdentificationError;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _statusMessage = '';
    });

    try {
      await AuthApi.instance.savePreferences(
        accountId: accountId,
        areaIds: selectedAreaIds,
      );

      await PreferenceRepository.instance.clearCache(accountId);

      await localStorage.setBool(
        PreferencesScreen.firstLoginPreferencesDoneKeyFor(accountId),
        true,
      );
      await AuthSession.setHasPreferences(true);

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(context, '/app');
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = error.message.isEmpty
            ? AppLocalizations.of(context)!.couldNotSavePreferences
            : error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = AppLocalizations.of(context)!.couldNotSavePreferences;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAreas = _filteredAreas;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PopScope(
          canPop: widget.showBackButton,
          child: RefreshIndicator(
            onRefresh: _refreshAreas,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (widget.showBackButton) ...[
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 28),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        AppLocalizations.of(context)!.preferencesTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF243047),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.welcomePersonalization,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.chooseAreas,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SearchField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchTerm = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: SoftinsaColors.border),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.selectedCount(_selectedCount),
                          style: const TextStyle(
                            color: Color(0xFF243047),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isSaving ? null : _clearSelection,
                        child: Text(
                          AppLocalizations.of(context)!.clearSelection,
                          style: const TextStyle(
                            color: SoftinsaColors.blueDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4F4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF5C2C7)),
                      ),
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(
                          color: Color(0xFFB42318),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: SoftinsaColors.blue,
                        ),
                      ),
                    )
                  else if (filteredAreas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          _searchTerm.trim().isEmpty
                              ? AppLocalizations.of(context)!.noAreasFound
                              : AppLocalizations.of(context)!.noAreasForTerm,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: SoftinsaColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      itemCount: filteredAreas.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final area = filteredAreas[index];
                        return _PreferenceCard(
                          area: area,
                          onTap: () => _toggleArea(area.id),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.savePreferencesButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchPreferenceAreas,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({required this.area, required this.onTap});

  final BackendArea area;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = area.selected;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? SoftinsaColors.blue : SoftinsaColors.border,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: SoftinsaShadows.soft,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: isSelected ? SoftinsaColors.blue : SoftinsaColors.border,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    area.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: SoftinsaColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    area.serviceLine.isEmpty ? '-' : area.serviceLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SoftinsaColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    area.description.isEmpty ? '-' : area.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SoftinsaColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.badgesAvailable(area.badgeCount),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SoftinsaColors.blueDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? SoftinsaColors.blue : SoftinsaColors.border,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
