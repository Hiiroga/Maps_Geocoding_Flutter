import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maps & Place Assignment',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _runAllLocationTasks();
  }

  Future<void> _runAllLocationTasks() async {
    await _getCurrentLocation();
    await _geocodeAddress();
    await _reverseGeocode();
  }

  Future<void> _getCurrentLocation() async {
    print('─────────────────────────────────────');
    print('[1] GET CURRENT LOCATION');
    print('─────────────────────────────────────');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('[ERROR] Location service tidak aktif. Aktifkan GPS terlebih dahulu.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('[ERROR] Permission lokasi ditolak oleh pengguna.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('[ERROR] Permission lokasi ditolak secara permanen. Buka Settings untuk mengaktifkannya.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      print('[RESULT] Latitude  : ${position.latitude}');
      print('[RESULT] Longitude : ${position.longitude}');
    } catch (e) {
      print('[ERROR] Gagal mendapatkan lokasi: $e');
    }
  }

  Future<void> _geocodeAddress() async {
    print('─────────────────────────────────────');
    print('[2] GEOCODING - ALAMAT KE KOORDINAT');
    print('─────────────────────────────────────');

    if (kIsWeb) {
      print('[SKIP] Geocoding tidak didukung di platform Web. Jalankan di Android/iOS.');
      return;
    }

    const String alamatKampus =
        'Telkom University, Jl. Telekomunikasi No. 1, Terusan Buah Batu, Bandung, Jawa Barat, Indonesia';

    print('[INFO] Alamat : $alamatKampus');

    try {
      List<Location> locations = await locationFromAddress(alamatKampus);
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        print('[RESULT] Latitude  : ${loc.latitude}');
        print('[RESULT] Longitude : ${loc.longitude}');
      } else {
        print('[ERROR] Tidak ada hasil ditemukan untuk alamat tersebut.');
      }
    } catch (e) {
      print('[ERROR] Gagal melakukan geocoding: $e');
    }
  }

  Future<void> _reverseGeocode() async {
    print('─────────────────────────────────────');
    print('[3] REVERSE GEOCODING - KOORDINAT KE ALAMAT');
    print('─────────────────────────────────────');

    if (kIsWeb) {
      print('[SKIP] Reverse Geocoding tidak didukung di platform Web. Jalankan di Android/iOS.');
      print('─────────────────────────────────────');
      print('[DONE] Semua tugas selesai.');
      print('─────────────────────────────────────');
      return;
    }

    const double latitude = 52.2165157;
    const double longitude = 6.9437819;

    print('[INFO] Latitude  : $latitude');
    print('[INFO] Longitude : $longitude');

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        print('[RESULT] Jalan   : ${place.street}');
        print('[RESULT] Kota    : ${place.locality}');
        print('[RESULT] Negara  : ${place.country}');
      } else {
        print('[ERROR] Tidak ada placemark ditemukan untuk koordinat tersebut.');
      }
    } catch (e) {
      print('[ERROR] Gagal melakukan reverse geocoding: $e');
    }

    print('─────────────────────────────────────');
    print('[DONE] Semua tugas selesai.');
    print('─────────────────────────────────────');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Maps & Place Assignment'),
      ),
      body: const Center(
        child: Text(
          'Maps & Place Assignment',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
