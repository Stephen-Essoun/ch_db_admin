import 'dart:io';

import 'package:ch_db_admin/src/events/domain/entities/event.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddEventView extends StatefulWidget {
  const AddEventView({super.key, this.event});
  final Event? event;

  @override
  State<AddEventView> createState() => _AddEventViewState();
}

class _AddEventViewState extends State<AddEventView> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController dateController;

  File? eventImage;

  // Pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        eventImage = File(pickedFile.path);
      });
    }
  }

  // Form submission logic
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Collect data
      final title = titleController.text;
      final description = descriptionController.text;
      final location = locationController.text;
      final date = DateTime.parse(dateController.text);
      String imageUrl = widget.event?.imageUrl ?? '';

      // Handle image upload
      if (eventImage != null && !eventImage!.path.contains('https://')) {
        // Upload image logic (placeholder for your implementation)
        imageUrl = await uploadImage(eventImage!);
      }

      // Create or update the event
      final newEvent = Event(
        id: widget.event?.id ?? UniqueKey().toString(),
        title: title,
        description: description,
        imageUrl: imageUrl,
        date: date,
        location: location,
        organizerId: 'exampleOrganizerId', // Replace with actual organizer logic
      );

      if (widget.event != null) {
        // Update event logic (placeholder for your implementation)
        await updateEvent(newEvent);
      } else {
        // Add event logic (placeholder for your implementation)
        await addEvent(newEvent);
      }

      // Notify user and go back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.event != null ? 'Event updated!' : 'Event added!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event?.title);
    descriptionController = TextEditingController(text: widget.event?.description);
    locationController = TextEditingController(text: widget.event?.location);
    dateController = TextEditingController(
      text: widget.event?.date.toIso8601String().split('T')[0],
    );
    if (widget.event != null) {
      eventImage = widget.event!.imageUrl.contains('https://')
          ? File(widget.event!.imageUrl)
          : null;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Edit Event' : 'Add Event'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextFormField(
                controller: titleController,
                labelText: 'Title',
                hintText: 'Enter event title',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: descriptionController,
                labelText: 'Description',
                hintText: 'Enter event description',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: locationController,
                labelText: 'Location',
                hintText: 'Enter event location',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: dateController,
                labelText: 'Date (YYYY-MM-DD)',
                hintText: 'Enter event date',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  try {
                    DateTime.parse(value);
                  } catch (_) {
                    return 'Invalid date format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Event Image'),
                  ),
                  const SizedBox(width: 16),
                  if (eventImage != null)
                    Image.file(
                      eventImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  if (widget.event?.imageUrl.contains('https://') == true)
                    Image.network(
                      widget.event!.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.event != null ? 'Save Changes' : 'Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> uploadImage(File image) async {
    // Replace this with your image upload logic
    return 'https://example.com/uploaded_image.png';
  }

  Future<void> addEvent(Event event) async {
    // Replace with logic to add the event to your database
    print('Adding event: ${event.title}');
  }

  Future<void> updateEvent(Event event) async {
    // Replace with logic to update the event in your database
    print('Updating event: ${event.title}');
  }
}

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final int maxLines;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }
}

