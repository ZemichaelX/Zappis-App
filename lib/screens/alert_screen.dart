import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';
import '../models/alert.dart';
import 'package:intl/intl.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AlertProvider>().fetchAlerts();
            },
          ),
        ],
      ),
      body: Consumer<AlertProvider>(
        builder: (context, alertProvider, child) {
          if (alertProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (alertProvider.alerts.isEmpty) {
            return const Center(
              child: Text('No alerts available'),
            );
          }

          return ListView.builder(
            itemCount: alertProvider.alerts.length,
            itemBuilder: (context, index) {
              final alert = alertProvider.alerts[index];
              return _buildAlertCard(context, alert);
            },
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Alert alert) {
    final dateFormat = DateFormat('MMM d, y HH:mm');
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildAlertIcon(alert.type),
        title: Text(
          alert.stationName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(alert.createdAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alert.isRead)
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  context.read<AlertProvider>().markAlertAsRead(alert.id);
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context.read<AlertProvider>().deleteAlert(alert.id);
              },
            ),
          ],
        ),
        onTap: () {
          // Navigate to station details or handle alert tap
        },
      ),
    );
  }

  Widget _buildAlertIcon(String type) {
    IconData iconData;
    Color color;

    switch (type.toLowerCase()) {
      case 'availability':
        iconData = Icons.power;
        color = Colors.green;
        break;
      case 'price':
        iconData = Icons.attach_money;
        color = Colors.blue;
        break;
      case 'maintenance':
        iconData = Icons.build;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.info;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color),
    );
  }
}
