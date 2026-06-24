import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';

class TripDetailsForm extends ConsumerWidget {
  final TextEditingController destinationController;
  final TextEditingController budgetController;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final VoidCallback onPickDeparture;
  final VoidCallback onPickReturn;
  final VoidCallback onSubmit;

  const TripDetailsForm({
    super.key,
    required this.destinationController,
    required this.budgetController,
    required this.departureDate,
    required this.returnDate,
    required this.onPickDeparture,
    required this.onPickReturn,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMMM yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Step indicator ──────────────────
          Text(
            'Trip Details',
            style: TextStyle(
              fontFamily: 'Gloock',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tell us about your dream trip',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          // ── Destination ────────────────────
          TextFormField(
            controller: destinationController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Destination',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 20),

          // ── Dates (side by side) ───────────
          Row(
            children: [
              // Departure
              Expanded(
                child: GestureDetector(
                  onTap: onPickDeparture,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Departure',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            'assets/icons/calendar.svg',
                            width: 10,
                            height: 10,
                            colorFilter: const ColorFilter.mode(
                              AppTheme.primaryColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        hintText: 'Start',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                      controller: TextEditingController(
                        text: departureDate != null
                            ? dateFormat.format(departureDate!)
                            : '',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Return
              Expanded(
                child: GestureDetector(
                  onTap: onPickReturn,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Return',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            'assets/icons/calendar.svg',
                            width: 10,
                            height: 10 ,
                            colorFilter: const ColorFilter.mode(
                              AppTheme.primaryColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        hintText: 'End',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                      controller: TextEditingController(
                        text: returnDate != null
                            ? dateFormat.format(returnDate!)
                            : '',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Budget ──────────────────────────
          TextFormField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Budget',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  'assets/icons/budget.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppTheme.primaryColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              prefixText: 'Rp ',
              prefixStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ── Submit Button ───────────────────
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: AppTheme.primaryButtonStyle,
              child: const Text(
                'Generate \u2728',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
