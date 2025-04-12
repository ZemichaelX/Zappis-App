import 'package:flutter/material.dart';
import 'package:zappis/models/charger.dart';
import 'package:zappis/models/station.dart';
import 'package:zappis/widgets/bottom_sheets/create_alert_bottom_sheet.dart';

class ChargerCard extends StatelessWidget {
  final Charger charger;
  final VoidCallback onTap;
  final String? displayType;
  final Station station;

  const ChargerCard({
    super.key,
    required this.charger,
    required this.onTap,
    required this.station,
    this.displayType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: charger.isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: charger.isAvailable
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.ev_station,
                  color: charger.isAvailable
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayType ?? '${charger.type} - ${charger.power} kW',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      charger.isAvailable ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        color: charger.isAvailable ? Colors.green : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: charger.isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      charger.isAvailable ? 'Available' : 'In Use',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!charger.isAvailable) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_alert),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        CreateAlertBottomSheet.show(context, station, charger);
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
