import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/marketer/controller/marketer_mark_visit_controller.dart';
import 'package:partener_app/marketer/view/marketer_update_visit_screen.dart';

class MarketerMarkVisitScreen extends StatelessWidget {
  const MarketerMarkVisitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketerMarkVisitController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F1),
        appBar: AppBar(
          title: const Text('Visits', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.green.shade800,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                unselectedLabelColor: Colors.white,
                tabs: const [
                  Tab(text: "Create Visit"),
                  Tab(text: "My Visits"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildCreateTab(context, controller),
            _buildHistoryTab(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(MarketerMarkVisitController controller) {
    return Obx(() {
      if (controller.isFetching.value && controller.visits.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Colors.green));
      }
      
      if (controller.visits.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(Icons.history_rounded, size: 64, color: Colors.green.shade300),
              ),
              const SizedBox(height: 24),
              Text(
                'No visits found.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new visit to see it here.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchVisits,
        color: Colors.green,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: controller.visits.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final visit = controller.visits[index];
            final payload = visit['payload'] ?? {};
            
            String title = visit['type'] ?? 'Unknown Type';
            IconData iconData = Icons.location_on_rounded;
            Color iconColor = Colors.green.shade600;
            
            if (title == 'FARM_VISIT') {
              title = payload['farm_name'] != null ? "Farm: ${payload['farm_name']}" : "Farm Visit";
              iconData = Icons.agriculture_rounded;
              iconColor = Colors.orange.shade600;
            } else if (title == 'CUSTOMER_VISIT') {
              title = payload['customer_name'] != null ? "Customer: ${payload['customer_name']}" : "Customer Visit";
              iconData = Icons.storefront_rounded;
              iconColor = Colors.blue.shade600;
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Get.to(() => MarketerUpdateVisitScreen(visit: visit));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(iconData, color: iconColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                visit['remarks'] ?? 'No remarks',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit_rounded, color: Colors.green.shade600, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCreateTab(BuildContext context, MarketerMarkVisitController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.green),
              const SizedBox(height: 24),
              Text(
                'Saving visit details...',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container for form
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Visit Type",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedType.value,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.green.shade700),
                        style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                        items: [
                          DropdownMenuItem(
                            value: 'FARM_VISIT',
                            child: Row(
                              children: [
                                Icon(Icons.agriculture_rounded, color: Colors.orange.shade600, size: 22),
                                const SizedBox(width: 12),
                                const Text('Farm Visit'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'CUSTOMER_VISIT',
                            child: Row(
                              children: [
                                Icon(Icons.storefront_rounded, color: Colors.blue.shade600, size: 22),
                                const SizedBox(width: 12),
                                const Text('Customer Visit'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) controller.selectedType.value = val;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Remarks *",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller.remarksController,
                    "Enter visit remarks...",
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  
                  const Divider(),
                  const SizedBox(height: 24),

                  // Dynamic Fields
                  if (controller.selectedType.value == 'FARM_VISIT') ...[
                    const Text("Farm Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
                    const SizedBox(height: 10),
                    _buildTextField(controller.farmNameController, "e.g. Green Farm", icon: Icons.landscape_rounded),
                    const SizedBox(height: 24),

                    const Text("Crops", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
                    const SizedBox(height: 10),
                    _buildTextField(controller.cropsController, "e.g. Wheat, Rice", icon: Icons.grass_rounded),
                  ] else ...[
                    const Text("Customer Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
                    const SizedBox(height: 10),
                    _buildTextField(controller.customerNameController, "e.g. Rahul", icon: Icons.person_rounded),
                    const SizedBox(height: 24),

                    const Text("Amount", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller.amountController,
                      "e.g. 1000",
                      icon: Icons.currency_rupee_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Photos Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.photo_library_rounded, size: 20, color: Colors.black87),
                      const SizedBox(width: 8),
                      const Text(
                        "Attach Photos",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                      ),
                      const Spacer(),
                      if (controller.selectedImages.isNotEmpty)
                        Text(
                          "${controller.selectedImages.length} attached",
                          style: TextStyle(color: Colors.green.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ...controller.selectedImages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(file, width: 85, height: 85, fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: -6,
                              right: -6,
                              child: GestureDetector(
                                onTap: () => controller.removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      
                      // Add Image Button
                      GestureDetector(
                        onTap: () {
                          _showImagePickerOptions(context, controller);
                        },
                        child: Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300, width: 1.5, style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded, color: Colors.green.shade600, size: 28),
                              const SizedBox(height: 4),
                              Text("Add", style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.remarksController.text.trim().isEmpty) {
                    Get.snackbar(
                      'Required',
                      'Please enter remarks',
                      backgroundColor: Colors.orange.shade100,
                      colorText: Colors.orange.shade900,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                    return;
                  }
                  controller.submitVisit();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.green.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 22),
                    SizedBox(width: 8),
                    Text('Submit Visit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey.shade400, size: 22) : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade500, width: 2),
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, MarketerMarkVisitController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Attach Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt_rounded, color: Colors.blue.shade600),
                    ),
                    title: const Text('Take a photo', style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      Get.back();
                      controller.captureImage();
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.purple.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.photo_library_rounded, color: Colors.purple.shade600),
                    ),
                    title: const Text('Choose from gallery', style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      Get.back();
                      controller.pickImages();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
