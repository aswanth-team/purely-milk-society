import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PostAnnouncementPage extends StatefulWidget {
  @override
  _PostAnnouncementPageState createState() => _PostAnnouncementPageState();
}

class _PostAnnouncementPageState extends State<PostAnnouncementPage> {
  final List<XFile?> _images = [null, null, null];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/dsdvk2lms/image/upload';
  final String uploadPreset = 'milk project';

  bool _isUploading = false;
  Map<String, dynamic>? existingAnnouncement;

  @override
  void initState() {
    super.initState();
    _fetchExistingAnnouncement();
  }

  Future<void> _fetchExistingAnnouncement() async {
    final doc = await _firestore.collection('announcements').doc('main').get();
    if (doc.exists) {
      setState(() {
        existingAnnouncement = doc.data();
      });
    }
  }

  // Function to pick an image
  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _images[index] = pickedFile;
    });
  }

  // Function to upload an image to Cloudinary
  Future<String?> _uploadImageToCloudinary(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: file.name),
        );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return json['secure_url'];
      } else {
        throw Exception('Failed to upload image: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Function to submit the announcement
  Future<void> _submitAnnouncement() async {
    if (_images.every((image) => image == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Delete existing announcement if any
      await _firestore.collection('announcements').doc('main').delete();

      // Upload images to Cloudinary
      final imageUrls = <String>[];
      for (var image in _images) {
        if (image != null) {
          final imageUrl = await _uploadImageToCloudinary(image);
          if (imageUrl != null) {
            imageUrls.add(imageUrl);
          }
        }
      }

      // Save uploaded image URLs to Firestore
      await _firestore.collection('announcements').doc('main').set({
        'image_urls': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the images
      setState(() {
        for (int i = 0; i < _images.length; i++) {
          _images[i] = null;
        }
        existingAnnouncement = {
          'image_urls': imageUrls,
          'timestamp': DateTime.now(),
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement posted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post announcement: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Delete the existing announcement
  Future<void> _deleteExistingAnnouncement() async {
    try {
      await _firestore.collection('announcements').doc('main').delete();
      setState(() {
        existingAnnouncement = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Existing announcement deleted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete announcement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post Announcement',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (existingAnnouncement != null) ...[
              const Text('Existing Announcement:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Column(
                children: (existingAnnouncement!['image_urls'] as List<dynamic>)
                    .map((url) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(url),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isUploading ? null : _deleteExistingAnnouncement,
                child: const Text('Delete Existing Announcement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
              const Divider(height: 30),
            ],
            Text('Upload Images (Max 3):',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                return GestureDetector(
                  onTap: () => _pickImage(index),
                  child: Stack(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          image: _images[index] != null
                              ? DecorationImage(
                                  image: FileImage(File(_images[index]!.path)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _images[index] == null
                            ? const Icon(Icons.add_a_photo, size: 30)
                            : null,
                      ),
                      if (_images[index] != null)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() {
                              _images[index] = null;
                            }),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading || existingAnnouncement != null
                    ? null
                    : _submitAnnouncement,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Post Announcement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
