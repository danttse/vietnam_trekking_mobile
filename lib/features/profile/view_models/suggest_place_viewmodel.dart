import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SuggestPlaceViewModel extends ChangeNotifier {
  final TextEditingController placeNameController = TextEditingController();
  final TextEditingController gpsController = TextEditingController();
  final TextEditingController altitudeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String _selectedProvince = 'Gia Lai';
  String _selectedDifficulty = 'Khó';
  bool _isLoading = false;

  final List<String> _provinces = [];
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  List <File> get selectedImages => _selectedImages; 

  final List<String> _difficulties = ['Dễ','Trung bình','Khó','Cực khó',];

  String get selectedProvince => _selectedProvince;
  String get selectedDifficulty => _selectedDifficulty;
  List<String> get provinces => _provinces;
  List<String> get difficulties => _difficulties;
  bool get isLoading => _isLoading;

  void setProvince(String? value) {
    if (value != null && value != _selectedProvince) {
      _selectedProvince = value;
      notifyListeners();
    }
  }

  void setDifficulty(String? value) {
    if (value != null && value != _selectedDifficulty) {
      _selectedDifficulty = value;
      notifyListeners();
    }
  }

  void getCurrentLocation() {
    gpsController.text = '14° N, 108° E';
    notifyListeners();
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery,imageQuality: 80);
    if (pickedFile!=null) {
      _selectedImages.add(File(pickedFile.path));
    }
    notifyListeners();
  }
  Future<void> pickMultiImages() async {
    final List<XFile> pickedFiles= await _picker.pickMultiImage(imageQuality: 80);
    if (pickedFiles!=null) {
      _selectedImages.addAll(pickedFiles.map((x)=>File(x.path)));
      notifyListeners();
    }
  }
  void removeImage(int index) {
    if (index>=0 &&index<_selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> submit() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    placeNameController.dispose();
    gpsController.dispose();
    altitudeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
