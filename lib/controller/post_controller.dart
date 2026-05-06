import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rajeali_app/core/constant/app_routes.dart';
import 'package:rajeali_app/core/services/api_service.dart';
import 'package:rajeali_app/data/model/category_model.dart';
import 'package:rajeali_app/data/model/found_item_model.dart';
import 'package:rajeali_app/data/model/lost_item_model.dart';
import 'package:rajeali_app/data/repository/app_repository.dart';

class PostController extends GetxController {
  PostController({required AppRepository repo, required ApiService api})
    : _repo = repo,
      _api = api;

  final AppRepository _repo;
  final ApiService _api;

  // ── Categories ──
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool categoriesLoading = false.obs;

  // ── Lost items ──
  final RxList<LostItemModel> lostItems = <LostItemModel>[].obs;
  final RxBool lostLoading = false.obs;

  // ── Found items ──
  final RxList<FoundItemModel> foundItems = <FoundItemModel>[].obs;
  final RxBool foundLoading = false.obs;

  // ── Matches ──
  final RxList<FoundItemModel> lostMatches = <FoundItemModel>[].obs;
  final RxList<LostItemModel> foundSearchResults = <LostItemModel>[].obs;

  // ── Form controllers — Report Lost ──
  final TextEditingController lostTitleCtrl = TextEditingController();
  final TextEditingController lostDescCtrl = TextEditingController();
  final TextEditingController lostLocationCtrl = TextEditingController();
  final TextEditingController lostLatCtrl = TextEditingController();
  final TextEditingController lostLngCtrl = TextEditingController();
  final Rxn<CategoryModel> lostCategory = Rxn<CategoryModel>();
  final Rxn<DateTime> lostDate = Rxn<DateTime>();
  final Rxn<XFile> lostImage = Rxn<XFile>();

  // ── Form controllers — Report Found ──
  final TextEditingController foundTitleCtrl = TextEditingController();
  final TextEditingController foundDescCtrl = TextEditingController();
  final TextEditingController foundLocationCtrl = TextEditingController();
  final TextEditingController foundLatCtrl = TextEditingController();
  final TextEditingController foundLngCtrl = TextEditingController();
  final TextEditingController foundFinderNameCtrl = TextEditingController();
  final Rxn<CategoryModel> foundCategory = Rxn<CategoryModel>();
  final Rxn<DateTime> foundDate = Rxn<DateTime>();
  final Rxn<XFile> foundImage = Rxn<XFile>();

  // ── Search / filter ──
  final RxString searchQuery = ''.obs;
  final Rxn<int> filterCategoryId = Rxn<int>();
  final RxString filterType = 'all'.obs;

  // ── General ──
  final RxString error = ''.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadAllData() async {
    await Future.wait(<Future<void>>[
      fetchCategories(),
      fetchLostItems(),
      fetchFoundItems(),
    ]);
  }

  // ═══════════════════════════════════════
  //  CATEGORIES
  // ═══════════════════════════════════════
  Future<void> fetchCategories() async {
    categoriesLoading.value = true;
    try {
      categories.assignAll(await _repo.getCategories());
    } on DioException catch (e) {
      _showError(_api.extractError(e));
    } catch (e) {
      debugPrint('fetchCategories error: $e');
    }
    categoriesLoading.value = false;
  }

  // ═══════════════════════════════════════
  //  LOST ITEMS
  // ═══════════════════════════════════════
  Future<void> fetchLostItems({int? categoryId}) async {
    lostLoading.value = true;
    try {
      lostItems.assignAll(await _repo.getLostItems(categoryId: categoryId));
    } on DioException catch (e) {
      _showError(_api.extractError(e));
    } catch (e) {
      debugPrint('fetchLostItems error: $e');
    }
    lostLoading.value = false;
  }

  Future<bool> createLostItem() async {
    error.value = '';
    final String title = lostTitleCtrl.text.trim();
    final String desc = lostDescCtrl.text.trim();
    final String loc = lostLocationCtrl.text.trim();
    final CategoryModel? cat = lostCategory.value;
    final DateTime? date = lostDate.value;

    if (title.length < 3) {
      error.value = 'العنوان يجب أن لا يقل عن 3 أحرف';
      return false;
    }
    if (cat == null) {
      error.value = 'اختر نوع الغرض';
      return false;
    }
    if (desc.length < 10) {
      error.value = 'الوصف يجب أن لا يقل عن 10 أحرف';
      return false;
    }
    if (loc.isEmpty) {
      error.value = 'الموقع مطلوب';
      return false;
    }
    if (date == null) {
      error.value = 'التاريخ مطلوب';
      return false;
    }

    isSubmitting.value = true;
    try {
      final LostItemModel newItem = await _repo.createLostItem(
        categoryId: cat.id,
        itemName: title,
        description: desc,
        mapLocation: loc,
        lostTime:
            '${date.year}-${_pad(date.month)}-${_pad(date.day)} ${_pad(date.hour)}:${_pad(date.minute)}:00',
        imagePath: lostImage.value?.path,
      );
      debugPrint('🆕 Lost item created with ID: ${newItem.id}');
      _clearLostForm();
      await fetchLostItems();

      // ✅ صاحب المفقود — يدور على match ولو لاقى يوديه للتحقق
      await _checkMatchesAfterPost(newItem.id, isLost: true);
      return true;
    } on DioException catch (e) {
      error.value = _api.extractError(e);
      return false;
    } catch (e) {
      error.value = 'حدث خطأ غير متوقع';
      debugPrint('createLostItem error: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<List<FoundItemModel>> getMatchesForLost(int lostId) async {
    try {
      final List<FoundItemModel> matches = await _repo.getLostItemMatches(
        lostId,
      );
      lostMatches.assignAll(matches);
      return matches;
    } on DioException catch (e) {
      _showError(_api.extractError(e));
      return <FoundItemModel>[];
    }
  }

  // ═══════════════════════════════════════
  //  FOUND ITEMS
  // ═══════════════════════════════════════
  Future<void> fetchFoundItems({int? categoryId}) async {
    foundLoading.value = true;
    try {
      foundItems.assignAll(await _repo.getFoundItems(categoryId: categoryId));
    } on DioException catch (e) {
      _showError(_api.extractError(e));
    } catch (e) {
      debugPrint('fetchFoundItems error: $e');
    }
    foundLoading.value = false;
  }

  Future<bool> createFoundItem() async {
    error.value = '';
    final String title = foundTitleCtrl.text.trim();
    final String desc = foundDescCtrl.text.trim();
    final String loc = foundLocationCtrl.text.trim();
    final String finder = foundFinderNameCtrl.text.trim();
    final CategoryModel? cat = foundCategory.value;
    final DateTime? date = foundDate.value;

    if (title.length < 3) {
      error.value = 'العنوان يجب أن لا يقل عن 3 أحرف';
      return false;
    }
    if (cat == null) {
      error.value = 'اختر نوع الغرض';
      return false;
    }
    if (loc.isEmpty) {
      error.value = 'الموقع مطلوب';
      return false;
    }
    if (date == null) {
      error.value = 'التاريخ مطلوب';
      return false;
    }

    isSubmitting.value = true;
    try {
      final FoundItemModel newItem = await _repo.createFoundItem(
        categoryId: cat.id,
        finderName: finder.isEmpty ? title : finder,
        description: desc.isEmpty ? title : desc,
        mapLocation: loc,
        foundTime:
            '${date.year}-${_pad(date.month)}-${_pad(date.day)} ${_pad(date.hour)}:${_pad(date.minute)}:00',
        imagePath: foundImage.value?.path,
      );
      debugPrint('🆕 Found item created with ID: ${newItem.id}');
      _clearFoundForm();
      await fetchFoundItems();

      // ✅ الواجد — بس يعرض dialog "تم النشر، انتظر صاحب الغرض"
      // لا يوديه لشاشة التحقق لأنه هو مش المطلوب منه يجاوب أسئلة
      await _notifyFounderAfterPost(newItem.id);
      return true;
    } on DioException catch (e) {
      error.value = _api.extractError(e);
      return false;
    } catch (e) {
      error.value = 'حدث خطأ غير متوقع';
      debugPrint('createFoundItem error: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<List<LostItemModel>> searchLostForFound(int foundId) async {
    try {
      final List<LostItemModel> results = await _repo.searchLostForFound(
        foundId,
      );
      foundSearchResults.assignAll(results);
      return results;
    } on DioException catch (e) {
      _showError(_api.extractError(e));
      return <LostItemModel>[];
    }
  }

  // ═══════════════════════════════════════
  //  AUTO MATCH AFTER POST
  // ═══════════════════════════════════════

  /// صاحب المفقود — يدور على match ولو لاقى يوديه للتحقق
  Future<void> _checkMatchesAfterPost(
    int itemId, {
    required bool isLost,
  }) async {
    try {
      debugPrint('🔍 Checking matches for item ID: $itemId, isLost: $isLost');
      if (isLost) {
        final List<FoundItemModel> matches = await getMatchesForLost(itemId);
        debugPrint('✅ Matches found: ${matches.length}');
        if (matches.isNotEmpty) {
          await Future<void>.delayed(const Duration(milliseconds: 800));
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLostMatchDialog(matches.length, itemId: itemId);
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Match error: $e');
    }
  }

  /// الواجد — بس يعلمه إن بلاغه اتنشر وفي أشخاص ممكن يتواصلوا معه
  Future<void> _notifyFounderAfterPost(int itemId) async {
    try {
      final List<LostItemModel> results = await searchLostForFound(itemId);
      debugPrint('✅ Lost items found for match: ${results.length}');
      await Future<void>.delayed(const Duration(milliseconds: 800));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (results.isNotEmpty) {
          // في أشخاص فاقدين نفس الغرض — أعلم الواجد
          _showFounderNotifyDialog(results.length);
        }
        // لو ما في matches — ما يطلع أي dialog، البلاغ اتنشر بهدوء
      });
    } catch (e) {
      debugPrint('❌ Founder notify error: $e');
    }
  }

  /// Dialog لصاحب المفقود — يوديه للتحقق
  void _showLostMatchDialog(int count, {required int itemId}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: Color(0xFF43A047),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'وجدنا تطابق! 🎉',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'يوجد $count ${count == 1 ? 'غرض مشابه' : 'أغراض مشابهة'} لبلاغك\nأجب على أسئلة التحقق لإثبات ملكيتك',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF757575),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('لاحقاً'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        // ✅ صاحب المفقود يجاوب أسئلة الـ found item
                        Get.toNamed(
                          AppRoutes.verification,
                          arguments: lostMatches.first, // FoundItemModel
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 46),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'التحقق الآن',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Dialog للواجد — فقط إعلام، بدون توجيه للتحقق
  void _showFounderNotifyDialog(int count) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFF1976D2),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'تم نشر بلاغك! 📢',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'يوجد $count ${count == 1 ? 'شخص يبحث' : 'أشخاص يبحثون'} عن غرض مشابه\nسيتواصلون معك قريباً للتحقق من ملكيتهم',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF757575),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'حسناً، سأنتظر',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // ═══════════════════════════════════════
  //  IMAGE PICKER
  // ═══════════════════════════════════════
  Future<void> pickImage({required bool isLost}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (image != null) {
      if (isLost) {
        lostImage.value = image;
      } else {
        foundImage.value = image;
      }
    }
  }

  // ═══════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════
  void _clearLostForm() {
    lostTitleCtrl.clear();
    lostDescCtrl.clear();
    lostLocationCtrl.clear();
    lostLatCtrl.clear();
    lostLngCtrl.clear();
    lostCategory.value = null;
    lostDate.value = null;
    lostImage.value = null;
  }

  void _clearFoundForm() {
    foundTitleCtrl.clear();
    foundDescCtrl.clear();
    foundLocationCtrl.clear();
    foundLatCtrl.clear();
    foundLngCtrl.clear();
    foundFinderNameCtrl.clear();
    foundCategory.value = null;
    foundDate.value = null;
    foundImage.value = null;
  }

  void _showError(String msg) {
    Get.snackbar('خطأ', msg, snackPosition: SnackPosition.BOTTOM);
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  void onClose() {
    lostTitleCtrl.dispose();
    lostDescCtrl.dispose();
    lostLocationCtrl.dispose();
    lostLatCtrl.dispose();
    lostLngCtrl.dispose();
    foundTitleCtrl.dispose();
    foundDescCtrl.dispose();
    foundLocationCtrl.dispose();
    foundLatCtrl.dispose();
    foundLngCtrl.dispose();
    foundFinderNameCtrl.dispose();
    super.onClose();
  }
}
