import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/marketer/controller/marketer_mark_visit_controller.dart';

class MarketerMarkVisitScreen extends StatefulWidget {
  const MarketerMarkVisitScreen({super.key});

  @override
  State<MarketerMarkVisitScreen> createState() =>
      _MarketerMarkVisitScreenState();
}

class _MarketerMarkVisitScreenState extends State<MarketerMarkVisitScreen> {
  final FocusNode _storeContactFocusNode = FocusNode();
  final FocusNode _farmContactFocusNode = FocusNode();
  final LayerLink _storeLayerLink = LayerLink();
  final LayerLink _farmLayerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String? _selectedStoreSize;

  @override
  void initState() {
    super.initState();
    _storeContactFocusNode.addListener(_onFocusChange);
    _farmContactFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _storeContactFocusNode.removeListener(_onFocusChange);
    _farmContactFocusNode.removeListener(_onFocusChange);
    _storeContactFocusNode.dispose();
    _farmContactFocusNode.dispose();
    _hideSuggestionsOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    final controller = Get.find<MarketerMarkVisitController>();
    if (_farmContactFocusNode.hasFocus) {
      final text = controller.farmMobileNumberController.text;
      if (text.isNotEmpty) {
        controller.filterContacts(text);
        if (controller.filteredContacts.isNotEmpty) {
          _showSuggestionsOverlay(
            context,
            _farmLayerLink,
            controller.farmMobileNumberController,
            controller.farmCustomerNameController,
            _farmContactFocusNode,
            controller.filteredContacts,
          );
        }
      }
    } else if (_storeContactFocusNode.hasFocus) {
      final text = controller.storeContactNumberController.text;
      if (text.isNotEmpty) {
        controller.filterContacts(text);
        if (controller.filteredContacts.isNotEmpty) {
          _showSuggestionsOverlay(
            context,
            _storeLayerLink,
            controller.storeContactNumberController,
            controller.storeOwnerNameController,
            _storeContactFocusNode,
            controller.filteredContacts,
          );
        }
      }
    } else {
      _hideSuggestionsOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketerMarkVisitController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: const Text(
          'Create Visit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildCreateTab(context, controller),
    );
  }

  Widget _buildCreateTab(
    BuildContext context,
    MarketerMarkVisitController controller,
  ) {
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
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      final isFarmSelected = controller.selectedType.value == 'FARM_VISIT';

      return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Switcher between Farm Visit and Store Visit
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.selectedType.value = 'FARM_VISIT',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              isFarmSelected
                                  ? Colors.green.shade600
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.agriculture_rounded,
                              color:
                                  isFarmSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Farm Visit",
                              style: TextStyle(
                                color:
                                    isFarmSelected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          () =>
                              controller.selectedType.value = 'CUSTOMER_VISIT',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              !isFarmSelected
                                  ? Colors.green.shade600
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              color:
                                  !isFarmSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Store Visit",
                              style: TextStyle(
                                color:
                                    !isFarmSelected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form Fields Container (Optional fields, no Asterisks)
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
                  if (isFarmSelected) ...[
                    // Farm Fields
                    const Text(
                      "Customer Name",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller.farmCustomerNameController,
                      "e.g. Ramdas Patil",
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CompositedTransformTarget(
                      link: _farmLayerLink,
                      child: TextField(
                        controller: controller.farmMobileNumberController,
                        focusNode: _farmContactFocusNode,
                        keyboardType: TextInputType.phone,
                        onChanged: (val) {
                          controller.filterContacts(val);
                          if (controller.filteredContacts.isNotEmpty) {
                            _showSuggestionsOverlay(
                              context,
                              _farmLayerLink,
                              controller.farmMobileNumberController,
                              controller.farmCustomerNameController,
                              _farmContactFocusNode,
                              controller.filteredContacts,
                            );
                          } else {
                            _hideSuggestionsOverlay();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "e.g. 9876543210",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(
                            Icons.phone_android_rounded,
                            color: Colors.grey.shade400,
                            size: 22,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
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
                            borderSide: BorderSide(
                              color: Colors.green.shade500,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Crop Name",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller.farmCropNameController,
                      "e.g. Tomato",
                      icon: Icons.grass_rounded,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Variety",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller.farmVarietyController,
                      "e.g. Abhinav",
                      icon: Icons.category_rounded,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Plot Age",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller.farmPlotAgeController,
                      "e.g. 45 Days",
                      icon: Icons.calendar_today_rounded,
                    ),
                  ] else ...[
                    // Store Fields
                    const Text(
                      "Owner/Manager Name",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller.storeOwnerNameController,
                      "e.g. Suresh Kumar",
                      icon: Icons.store_mall_directory_rounded,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Contact Number",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CompositedTransformTarget(
                      link: _storeLayerLink,
                      child: TextField(
                        controller: controller.storeContactNumberController,
                        focusNode: _storeContactFocusNode,
                        keyboardType: TextInputType.phone,
                        onChanged: (val) {
                          controller.filterContacts(val);
                          if (controller.filteredContacts.isNotEmpty) {
                            _showSuggestionsOverlay(
                              context,
                              _storeLayerLink,
                              controller.storeContactNumberController,
                              controller.storeOwnerNameController,
                              _storeContactFocusNode,
                              controller.filteredContacts,
                            );
                          } else {
                            _hideSuggestionsOverlay();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "e.g. 9876543210",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(
                            Icons.phone_rounded,
                            color: Colors.grey.shade400,
                            size: 22,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
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
                            borderSide: BorderSide(
                              color: Colors.green.shade500,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Size/Category of Store",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedStoreSize,
                      hint: Text(
                        "Select Store Size/Category",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.storefront_rounded,
                          color: Colors.grey.shade400,
                          size: 22,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                          borderSide: BorderSide(
                            color: Colors.green.shade500,
                            width: 2,
                          ),
                        ),
                      ),
                      items:
                          [
                            'Small',
                            'Medium',
                            'Large',
                            'Agency',
                            'Distributor',
                            'Holsaler',
                            'Other',
                          ].map((String val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(val),
                            );
                          }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          _selectedStoreSize = newVal;
                          if (newVal != 'Other' && newVal != null) {
                            controller.storeSizeController.text = newVal;
                          } else {
                            controller.storeSizeController.text = '';
                          }
                        });
                      },
                    ),
                    if (_selectedStoreSize == 'Other') ...[
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller.storeSizeController,
                        "Enter store details",
                        icon: Icons.square_foot_rounded,
                      ),
                    ],
                  ],
                  const SizedBox(height: 20),

                  const Text(
                    "Remarks",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller.remarksController,
                    "Enter visit description...",
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await controller.submitVisit();
                  if (success) {
                    _showSuccessAnimation(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.green.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Submit Visit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
        prefixIcon:
            icon != null
                ? Icon(icon, color: Colors.grey.shade400, size: 22)
                : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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

  void _showSuggestionsOverlay(
    BuildContext context,
    LayerLink layerLink,
    TextEditingController textController,
    TextEditingController nameController,
    FocusNode focusNode,
    List<dynamic> contacts,
  ) {
    _hideSuggestionsOverlay();

    if (contacts.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            width: MediaQuery.of(context).size.width - 88,
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 58),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() {
                    final contactsList = contacts;
                    if (contactsList.isEmpty) return const SizedBox.shrink();
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: contactsList.length,
                      itemBuilder: (context, index) {
                        final contact = contactsList[index];
                        final phone =
                            contact.phones.isNotEmpty
                                ? contact.phones.first.number
                                : '';
                        return ListTile(
                          title: Text(
                            contact.displayName ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(phone),
                          leading: const Icon(
                            Icons.contact_phone,
                            color: Colors.green,
                          ),
                          onTap: () {
                            textController.text = phone.replaceAll(
                              RegExp(r'\D'),
                              '',
                            );
                            nameController.text = contact.displayName ?? '';
                            _hideSuggestionsOverlay();
                            focusNode.unfocus();
                          },
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestionsOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _showSuccessAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const _SuccessCelebrationDialog();
      },
    );
  }
}

class _SuccessCelebrationDialog extends StatefulWidget {
  const _SuccessCelebrationDialog();

  @override
  State<_SuccessCelebrationDialog> createState() =>
      _SuccessCelebrationDialogState();
}

class _SuccessCelebrationDialogState extends State<_SuccessCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_animController);

    _rotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _animController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        Get.back();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green.shade600,
                          size: 70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Visit Marked!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Target progress updated",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
