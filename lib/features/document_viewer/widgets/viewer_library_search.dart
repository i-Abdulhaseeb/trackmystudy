import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../file_manager/controllers/file_manager_controller.dart';
import '../../file_manager/models/app_file_model.dart';

class ViewerLibrarySearch extends StatefulWidget {
  const ViewerLibrarySearch({super.key});

  @override
  State<ViewerLibrarySearch> createState() => _ViewerLibrarySearchState();
}

class _ViewerLibrarySearchState extends State<ViewerLibrarySearch> {
  String query = '';

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Search library'),
    content: SizedBox(
      width: 600,
      height: 420,
      child: Column(
        children: [
          TextField(
            autofocus: true,
            onChanged: (value) =>
                setState(() => query = value.toLowerCase().trim()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Document or course…',
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              final files = Get.find<FileManagerController>().files
                  .where(
                    (file) => '${file.name} ${file.course}'
                        .toLowerCase()
                        .contains(query),
                  )
                  .toList();
              if (files.isEmpty) {
                return const Center(child: Text('No documents found.'));
              }
              return ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return ListTile(
                    leading: Icon(
                      file.extension == 'PDF'
                          ? Icons.picture_as_pdf_outlined
                          : Icons.description_outlined,
                    ),
                    title: Text(file.name),
                    subtitle: Text(file.course),
                    onTap: () => Navigator.pop<AppFileModel>(context, file),
                  );
                },
              );
            }),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  );
}
