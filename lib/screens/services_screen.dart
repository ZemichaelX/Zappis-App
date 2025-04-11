import 'package:flutter/material.dart';
import 'package:zappis/models/service.dart';
import 'package:zappis/widgets/service_card.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample services data
    final services = [
      const Service(
        id: '1',
        name: 'Coffee Shop',
        description: 'Enjoy a cup of Ethiopian coffee while your car charges',
        icon: Icons.coffee,
        color: Colors.brown,
      ),
      const Service(
        id: '2',
        name: 'Car Wash',
        description: 'Get your car cleaned while charging',
        icon: Icons.local_car_wash,
        color: Colors.blue,
      ),
      const Service(
        id: '3',
        name: 'Convenience Store',
        description: 'Shop for snacks and essentials',
        icon: Icons.shopping_basket,
        color: Colors.orange,
      ),
      const Service(
        id: '4',
        name: 'Tire Pressure Check',
        description: 'Ensure your tires are properly inflated',
        icon: Icons.tire_repair,
        color: Colors.grey,
      ),
      const Service(
        id: '5',
        name: 'Wi-Fi Hotspot',
        description: 'Stay connected with free Wi-Fi',
        icon: Icons.wifi,
        color: Colors.green,
      ),
      const Service(
        id: '6',
        name: 'Restrooms',
        description: 'Clean restroom facilities',
        icon: Icons.wc,
        color: Colors.purple,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Services'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available services at our charging stations',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return ServiceCard(
                  service: services[index],
                  onTap: () {
                    // Show service details
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) =>
                          _ServiceDetailsBottomSheet(service: services[index]),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceDetailsBottomSheet extends StatelessWidget {
  final Service service;

  const _ServiceDetailsBottomSheet({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: service.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  service.icon,
                  color: service.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            service.description,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Available at these stations:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.location_on),
            title: Text('Meskel Square Charging Hub'),
            subtitle: Text('Meskel Square, Addis Ababa'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.location_on),
            title: Text('Bole Charging Station'),
            subtitle: Text('Bole Road, Addis Ababa'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
