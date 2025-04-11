import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zappis/providers/alert_provider.dart';
import 'package:zappis/models/alert.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize alerts when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().fetchAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Alerts'),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No alerts available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: alertProvider.alerts.length,
            itemBuilder: (context, index) {
              final alert = alertProvider.alerts[index];
              return _buildAlertCard(context, alert, alertProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(
      BuildContext context, Alert alert, AlertProvider alertProvider) {
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
                  alertProvider.markAlertAsRead(alert.id);
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                alertProvider.deleteAlert(alert.id);
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
