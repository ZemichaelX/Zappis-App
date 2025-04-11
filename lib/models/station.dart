import 'package:flutter/material.dart';
import 'package:zappis/models/charger.dart';
import 'package:zappis/models/service.dart';

class Station {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double price; // Birr per kWh
  final int availableSpots;
  final int totalSpots;
  final List<Charger> chargers;
  final List<Service> services;
  final String description;
  final String phone;
  final String? email;
  final bool isFavorite;
  final double distance; // in km

  Station({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.availableSpots,
    required this.totalSpots,
    required this.chargers,
    required this.services,
    required this.description,
    required this.phone,
    this.email,
    this.isFavorite = false,
    this.distance = 0.0,
  });

  // Create a copy of the station with updated properties
  Station copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? price,
    int? availableSpots,
    int? totalSpots,
    List<Charger>? chargers,
    List<Service>? services,
    String? description,
    String? phone,
    String? email,
    bool? isFavorite,
    double? distance,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      price: price ?? this.price,
      availableSpots: availableSpots ?? this.availableSpots,
      totalSpots: totalSpots ?? this.totalSpots,
      chargers: chargers ?? this.chargers,
      services: services ?? this.services,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isFavorite: isFavorite ?? this.isFavorite,
      distance: distance ?? this.distance,
    );
  }

  // Sample data for testing
  static List<Station> getSampleStations() {
    return [
      Station(
        id: '1',
        name: 'Meskel Square Charging Hub',
        address: 'Meskel Square, Addis Ababa',
        latitude: 9.0105,
        longitude: 38.7612,
        price: 8.5,
        availableSpots: 3,
        totalSpots: 6,
        chargers: [
          Charger(
            id: '1',
            type: 'CCS',
            power: 50.0,
            isAvailable: true,
          ),
          Charger(
            id: '2',
            type: 'CHAdeMO',
            power: 50.0,
            isAvailable: true,
          ),
          Charger(
            id: '3',
            type: 'Type 2',
            power: 22.0,
            isAvailable: true,
          ),
          Charger(
            id: '4',
            type: 'CCS',
            power: 50.0,
            isAvailable: false,
          ),
          Charger(
            id: '5',
            type: 'Type 2',
            power: 22.0,
            isAvailable: false,
          ),
          Charger(
            id: '6',
            type: 'Type 2',
            power: 11.0,
            isAvailable: false,
          ),
        ],
        services: [
          const Service(
            id: '1',
            name: 'Coffee Shop',
            description:
                'Enjoy a cup of Ethiopian coffee while your car charges',
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
        ],
        description:
            'Habesha EV\'s flagship charging station located at the heart of Addis Ababa. Features multiple fast chargers and amenities.',
        phone: '+251 911 234 567',
        email: 'meskel@habeshaev.com',
        isFavorite: true,
        distance: 1.2,
      ),
      Station(
        id: '2',
        name: 'Bole Charging Station',
        address: 'Bole Road, Addis Ababa',
        latitude: 8.9806,
        longitude: 38.7578,
        price: 9.0,
        availableSpots: 2,
        totalSpots: 4,
        chargers: [
          Charger(
            id: '7',
            type: 'CCS',
            power: 50.0,
            isAvailable: true,
          ),
          Charger(
            id: '8',
            type: 'CHAdeMO',
            power: 50.0,
            isAvailable: true,
          ),
          Charger(
            id: '9',
            type: 'Type 2',
            power: 22.0,
            isAvailable: false,
          ),
          Charger(
            id: '10',
            type: 'Type 2',
            power: 11.0,
            isAvailable: false,
          ),
        ],
        services: [
          const Service(
            id: '1',
            name: 'Coffee Shop',
            description:
                'Enjoy a cup of Ethiopian coffee while your car charges',
            icon: Icons.coffee,
            color: Colors.brown,
          ),
          const Service(
            id: '4',
            name: 'Wi-Fi Hotspot',
            description: 'Stay connected with free Wi-Fi',
            icon: Icons.wifi,
            color: Colors.green,
          ),
        ],
        description:
            'Conveniently located on Bole Road, this station offers fast charging for all electric vehicles.',
        phone: '+251 911 987 654',
        email: 'bole@habeshaev.com',
        isFavorite: false,
        distance: 3.5,
      ),
      Station(
        id: '3',
        name: 'Piassa EV Station',
        address: 'Piassa, Addis Ababa',
        latitude: 9.0356,
        longitude: 38.7468,
        price: 8.0,
        availableSpots: 0,
        totalSpots: 2,
        chargers: [
          Charger(
            id: '11',
            type: 'CCS',
            power: 50.0,
            isAvailable: false,
          ),
          Charger(
            id: '12',
            type: 'Type 2',
            power: 22.0,
            isAvailable: false,
          ),
        ],
        services: [
          const Service(
            id: '3',
            name: 'Convenience Store',
            description: 'Shop for snacks and essentials',
            icon: Icons.shopping_basket,
            color: Colors.orange,
          ),
        ],
        description:
            'A small but efficient charging station in the historic Piassa area.',
        phone: '+251 911 123 456',
        isFavorite: false,
        distance: 5.8,
      ),
      Station(
        id: '4',
        name: 'Megenagna Charging Hub',
        address: 'Megenagna, Addis Ababa',
        latitude: 9.0201,
        longitude: 38.8013,
        price: 8.5,
        availableSpots: 4,
        totalSpots: 8,
        chargers: [
          Charger(
            id: '13',
            type: 'CCS',
            power: 150.0,
            isAvailable: true,
          ),
          Charger(
            id: '14',
            type: 'CCS',
            power: 150.0,
            isAvailable: true,
          ),
          Charger(
            id: '15',
            type: 'CHAdeMO',
            power: 50.0,
            isAvailable: true,
          ),
          Charger(
            id: '16',
            type: 'Type 2',
            power: 22.0,
            isAvailable: true,
          ),
          Charger(
            id: '17',
            type: 'Type 2',
            power: 22.0,
            isAvailable: false,
          ),
          Charger(
            id: '18',
            type: 'Type 2',
            power: 22.0,
            isAvailable: false,
          ),
          Charger(
            id: '19',
            type: 'Type 2',
            power: 11.0,
            isAvailable: false,
          ),
          Charger(
            id: '20',
            type: 'Type 2',
            power: 11.0,
            isAvailable: false,
          ),
        ],
        services: [
          const Service(
            id: '1',
            name: 'Coffee Shop',
            description:
                'Enjoy a cup of Ethiopian coffee while your car charges',
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
            name: 'Wi-Fi Hotspot',
            description: 'Stay connected with free Wi-Fi',
            icon: Icons.wifi,
            color: Colors.green,
          ),
          const Service(
            id: '5',
            name: 'Restrooms',
            description: 'Clean restroom facilities',
            icon: Icons.wc,
            color: Colors.purple,
          ),
        ],
        description:
            'Our largest charging hub with ultra-fast chargers and comprehensive amenities.',
        phone: '+251 911 345 678',
        email: 'megenagna@habeshaev.com',
        isFavorite: false,
        distance: 7.2,
      ),
      Station(
        id: '5',
        name: 'Sarbet EV Station',
        address: 'Sarbet, Addis Ababa',
        latitude: 8.9945,
        longitude: 38.7382,
        price: 8.0,
        availableSpots: 1,
        totalSpots: 3,
        chargers: [
          Charger(
            id: '21',
            type: 'CCS',
            power: 50.0,
            isAvailable: true,
          ),
          Charger(
            id: '22',
            type: 'CHAdeMO',
            power: 50.0,
            isAvailable: false,
          ),
          Charger(
            id: '23',
            type: 'Type 2',
            power: 22.0,
            isAvailable: false,
          ),
        ],
        services: [
          const Service(
            id: '3',
            name: 'Convenience Store',
            description: 'Shop for snacks and essentials',
            icon: Icons.shopping_basket,
            color: Colors.orange,
          ),
          const Service(
            id: '4',
            name: 'Wi-Fi Hotspot',
            description: 'Stay connected with free Wi-Fi',
            icon: Icons.wifi,
            color: Colors.green,
          ),
        ],
        description:
            'A convenient charging station in the Sarbet area with essential amenities.',
        phone: '+251 911 567 890',
        isFavorite: false,
        distance: 4.3,
      ),
    ];
  }
}
