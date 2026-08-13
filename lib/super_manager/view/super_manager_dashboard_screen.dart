import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/models/user_model.dart';
import 'package:partener_app/super_manager/controller/super_manager_dashboard_controller.dart';
import 'package:partener_app/super_manager/view/super_manager_employee_list_screen.dart';
import 'package:partener_app/managers/view/manager_employee_details_screen.dart';

class SuperManagerDashboardScreen extends StatelessWidget {
  const SuperManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SuperManagerDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Super Manager Panel',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.purple.shade700),
              onPressed: () => controller.fetchAllData(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final isFirstLoad = controller.isLoading.value &&
              controller.managers.isEmpty &&
              controller.employees.isEmpty;

          if (isFirstLoad) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.managers.isEmpty &&
              controller.employees.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchAllData,
            color: Colors.purple.shade700,
            child: Column(
              children: [
                // Summary Panel Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade800, Colors.purple.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.shade200.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "${controller.managers.length}",
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text("Total Managers", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        Container(width: 1, height: 40, color: Colors.white24),
                        Column(
                          children: [
                            Text(
                              "${controller.employees.length}",
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text("Total Marketers", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: controller.currentTab.value == 0
                          ? "Search managers by name, ID, phone..."
                          : "Search marketers by name, ID, manager...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                controller.searchQuery.value = '';
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.purple.shade300, width: 1.5),
                      ),
                    ),
                  ),
                ),

                // Custom Tab Bar Pills
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controller.currentTab.value = 0;
                            controller.searchQuery.value = '';
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: controller.currentTab.value == 0
                                  ? Colors.purple.shade600
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: controller.currentTab.value == 0
                                    ? Colors.purple.shade600
                                    : Colors.grey.shade300,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Managers (${controller.filteredManagers.length})",
                              style: TextStyle(
                                color: controller.currentTab.value == 0 ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controller.currentTab.value = 1;
                            controller.searchQuery.value = '';
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: controller.currentTab.value == 1
                                  ? Colors.purple.shade600
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: controller.currentTab.value == 1
                                    ? Colors.purple.shade600
                                    : Colors.grey.shade300,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Marketers (${controller.filteredEmployees.length})",
                              style: TextStyle(
                                color: controller.currentTab.value == 1 ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Content List
                Expanded(
                  child: controller.currentTab.value == 0
                      ? _buildManagersTab(context, controller)
                      : _buildEmployeesTab(context, controller),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildManagersTab(BuildContext context, SuperManagerDashboardController controller) {
    final list = controller.filteredManagers;
    if (list.isEmpty) {
      return _buildEmptyState("No managers found matching your search.");
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _ManagerCard(manager: list[index]);
      },
    );
  }

  Widget _buildEmployeesTab(BuildContext context, SuperManagerDashboardController controller) {
    final list = controller.filteredEmployees;
    if (list.isEmpty) {
      return _buildEmptyState("No marketers found matching your search.");
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final employee = list[index];
        final managerName = controller.employeeManagers[employee.id] ?? "Loading...";
        return _EmployeeCard(
          employee: employee,
          managerName: managerName,
          onReassign: () => _showReassignBottomSheet(context, employee, controller),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _showReassignBottomSheet(BuildContext context, UserModel employee, SuperManagerDashboardController controller) {
    final searchQuery = ''.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F7F1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Reassign Manager for:",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    employee.name ?? "Marketer",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (val) => searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: "Search managers...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Obx(() {
                      final query = searchQuery.value.toLowerCase();
                      final filteredList = controller.managers.where((m) {
                        return (m.name ?? '').toLowerCase().contains(query) ||
                            (m.mobileNo ?? '').toLowerCase().contains(query);
                      }).toList();

                      if (filteredList.isEmpty) {
                        return const Center(child: Text("No managers found."));
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final manager = filteredList[index];
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            borderOnForeground: false,
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.purple.shade50,
                                backgroundImage: (manager.image != null && manager.image!.isNotEmpty)
                                    ? NetworkImage(manager.image!)
                                    : null,
                                child: (manager.image == null || manager.image!.isEmpty)
                                    ? Icon(Icons.person, color: Colors.purple.shade400)
                                    : null,
                              ),
                              title: Text(manager.name ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("ID: ${manager.id ?? 'N/A'} | ${manager.mobileNo ?? ''}"),
                              trailing: Icon(Icons.chevron_right, color: Colors.purple.shade400),
                              onTap: () async {
                                if (employee.id != null && manager.id != null) {
                                  Get.back();
                                  await controller.reassignEmployeeManager(employee.id!, manager.id!);
                                }
                              },
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ManagerCard extends StatelessWidget {
  final UserModel manager;
  const _ManagerCard({required this.manager});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(() => SuperManagerEmployeeListScreen(manager: manager));
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.purple.shade50,
                  backgroundImage: (manager.image != null && manager.image!.isNotEmpty)
                      ? NetworkImage(manager.image!)
                      : null,
                  child: (manager.image == null || manager.image!.isEmpty)
                      ? Icon(Icons.person, size: 28, color: Colors.purple.shade400)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(manager.name ?? "Unknown", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("ID: ${manager.id ?? 'N/A'}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text(manager.mobileNo ?? "No Phone", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final UserModel employee;
  final String managerName;
  final VoidCallback onReassign;

  const _EmployeeCard({
    required this.employee,
    required this.managerName,
    required this.onReassign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(() => ManagerEmployeeDetailsScreen(employee: employee));
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: (employee.image != null && employee.image!.isNotEmpty)
                      ? NetworkImage(employee.image!)
                      : null,
                  child: (employee.image == null || employee.image!.isEmpty)
                      ? Icon(Icons.person, size: 28, color: Colors.blue.shade400)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(employee.name ?? "Unknown", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("ID: ${employee.id ?? 'N/A'}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text(employee.mobileNo ?? "No Phone", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: managerName == "No Manager" ? Colors.red.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Manager: $managerName",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: managerName == "No Manager" ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.swap_horiz_rounded, color: Colors.purple.shade600),
                  onPressed: onReassign,
                  tooltip: "Change Manager",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
