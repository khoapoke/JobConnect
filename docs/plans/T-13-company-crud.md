# T-13: Company CRUD + Logo Upload — Implementation Plan

> Generated from grill session (Q1–Q11). All decisions locked.
> Dependency: Auth (Phase 1) complete.

---

## Summary of Grilled Decisions

| # | Decision | Choice |
|---|----------|--------|
| Q1 | Feature folder | `features/recruiter/` — Company is 1:1 owned sub-entity |
| Q2 | Company lifecycle | Lazy creation, soft gate on job posting (T-14) |
| Q3 | `size` field | `CompanySize` enum in `core/constants/`, 6 brackets, DB CHECK |
| Q4 | `province` field | Dropdown with 34 provinces (post-2025), `ProvincePickerSheet` |
| Q5 | Logo upload ordering | INSERT company first → upload logo → UPDATE `logo_url` |
| Q6 | Navigation | Role-aware `RecruiterShell` (4 tabs), NOW not deferred |
| Q7 | Entity design | Split: `Company` (read) + `CompanyUpdate` (write) |
| Q8 | Form validation | Only `name` required; reusable `Validators.text()` / `.longText()` |
| Q9 | LogoPicker | Clone of `AvatarPicker`, rounded rectangle, `Icons.business` |
| Q10 | UNIQUE violation | Error mapper catches `23505`, auto-invalidates provider |
| Q11 | Serialization | Single `toJson()` with null-skipping for both CREATE and UPDATE |

---

## File Manifest

### New files to create

```
lib/
├── core/
│   └── constants/
│       ├── company_sizes.dart              ← CompanySize enum
│       └── vietnam_provinces.dart          ← VietnamProvinces.all (34)
├── features/
│   └── recruiter/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── company_datasource.dart
│       │   ├── mappers/
│       │   │   └── recruiter_error_mapper.dart
│       │   ├── models/
│       │   │   └── company_model.dart      ← Freezed
│       │   └── repositories/
│       │       └── company_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── company.dart
│       │   │   └── company_update.dart
│       │   ├── repositories/
│       │   │   └── company_repository.dart
│       │   └── usecases/
│       │       └── upload_logo_usecase.dart
│       └── presentation/
│           ├── pages/
│           │   ├── company_profile_page.dart
│           │   └── edit_company_page.dart
│           ├── providers/
│           │   └── company_provider.dart
│           └── widgets/
│               └── logo_picker.dart
└── shared/
    └── widgets/
        ├── province_picker_sheet.dart      ← NEW shared widget
        └── recruiter_shell.dart            ← NEW shell widget
```

### Files to modify

| File | Change |
|------|--------|
| `core/utils/validators.dart` | Add `Validators.text()` and `Validators.longText()` |
| `core/constants/app_strings.dart` | Add company-related strings |
| `core/router/app_router.dart` | Add RecruiterShell, recruiter routes |
| `features/profile/presentation/pages/profile_page.dart` | Add "Hồ sơ công ty" button (role-gated) |

### New migration

```
supabase/migrations/20260518000000_company_size_check.sql
```

---

## Step-by-Step Implementation Order

### Step 1: DB Migration — CompanySize CHECK constraint

```sql
-- supabase/migrations/20260518000000_company_size_check.sql
ALTER TABLE companies
  ADD CONSTRAINT companies_size_check
  CHECK (size IS NULL OR size IN (
    '1-10', '11-50', '51-200',
    '201-500', '501-1000', '1000+'
  ));
```

Run on Supabase Dashboard before Flutter implementation.

---

### Step 2: Core Constants

#### `core/constants/company_sizes.dart`

```dart
/// Company headcount brackets.
///
/// Stored as [value] in `companies.size` (DB).
/// Displayed as [displayLabel] in UI.
enum CompanySize {
  tiny('1-10', '1–10 nhân viên'),
  small('11-50', '11–50 nhân viên'),
  medium('51-200', '51–200 nhân viên'),
  large('201-500', '201–500 nhân viên'),
  enterprise('501-1000', '501–1000 nhân viên'),
  corporation('1000+', 'Trên 1000 nhân viên');

  const CompanySize(this.value, this.displayLabel);
  final String value;        // stored in DB
  final String displayLabel; // shown in UI

  static CompanySize? fromValue(String? value) =>
      CompanySize.values.where((e) => e.value == value).firstOrNull;
}
```

#### `core/constants/vietnam_provinces.dart`

```dart
/// Official 34 provinces of Vietnam (post-2025 merger).
///
/// Full official names — "Thành phố Hồ Chí Minh" not "HCM".
/// Used by: T-13 (Company), T-14 (Job Location), T-16 (Search filter).
class VietnamProvinces {
  const VietnamProvinces._();

  static const List<String> all = [
    'Thành phố Hà Nội',
    'Thành phố Hồ Chí Minh',
    'Thành phố Hải Phòng',
    'Thành phố Đà Nẵng',
    'Thành phố Huế',
    'Thành phố Cần Thơ',
    'An Giang',
    'Bắc Ninh',
    'Cà Mau',
    'Cao Bằng',
    'Đắk Lắk',
    'Điện Biên',
    'Đồng Nai',
    'Đồng Tháp',
    'Gia Lai',
    'Hà Tĩnh',
    'Hưng Yên',
    'Khánh Hòa',
    'Lai Châu',
    'Lạng Sơn',
    'Lào Cai',
    'Lâm Đồng',
    'Nghệ An',
    'Ninh Bình',
    'Phú Thọ',
    'Quảng Ninh',
    'Quảng Ngãi',
    'Quảng Trị',
    'Sơn La',
    'Tây Ninh',
    'Thái Nguyên',
    'Thanh Hóa',
    'Tuyên Quang',
    'Vĩnh Long',
  ]; // 34 provinces — official list post-2025 merger
}
```

---

### Step 3: Validators — Add reusable methods

Add to `core/utils/validators.dart`:

```dart
/// Generic text field: required, min/max length.
/// Reusable for any named text field.
static String? text(String? value, String fieldName,
    {int min = 2, int max = 100}) {
  final req = required(value, fieldName);
  if (req != null) return req;
  final trimmed = value!.trim();
  if (trimmed.length < min) {
    return '$fieldName phải có ít nhất $min ký tự';
  }
  if (trimmed.length > max) {
    return '$fieldName không được quá $max ký tự';
  }
  return null;
}

/// Optional long text field: validates max length only when provided.
/// Reusable for descriptions, bios, etc.
static String? longText(String? value, String fieldName,
    {int max = 1000}) {
  if (value == null || value.trim().isEmpty) return null;
  if (value.trim().length > max) {
    return '$fieldName không được quá $max ký tự';
  }
  return null;
}
```

---

### Step 4: AppStrings — Add company strings

Add to `core/constants/app_strings.dart`:

```dart
// T-13: Company
static const companyEmptyTitle = 'Thiết lập hồ sơ công ty';
static const companyEmptySubtitle =
    'Tạo hồ sơ công ty để bắt đầu đăng tin tuyển dụng';
static const createCompany = 'Tạo hồ sơ công ty';
static const editCompany = 'Chỉnh sửa hồ sơ công ty';
static const companyName = 'Tên công ty';
static const companyDescription = 'Mô tả công ty';
static const companyWebsite = 'Website';
static const companySize = 'Quy mô công ty';
static const companyProvince = 'Tỉnh / Thành phố';
static const companyCreated = 'Tạo hồ sơ công ty thành công';
static const companyUpdated = 'Cập nhật hồ sơ công ty thành công';
static const changeLogo = 'Thay đổi logo công ty';
static const companyLogoPlaceholder = 'Logo công ty';
static const companyProfile = 'Hồ sơ công ty';

// T-13: Recruiter shell tabs
static const recruiterHome = 'Trang chủ';
static const myPosts = 'Tin của tôi';
```

---

### Step 5: Domain Layer

#### `domain/entities/company.dart`

```dart
/// Company entity for read operations.
class Company {
  const Company({
    required this.id,
    required this.recruiterId,
    required this.name,
    this.logoUrl,
    this.description,
    this.website,
    this.size,
    this.province,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String recruiterId;
  final String name;
  final String? logoUrl;      // relative Storage path
  final String? description;
  final String? website;
  final String? size;         // CompanySize.value string
  final String? province;     // VietnamProvinces entry
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### `domain/entities/company_update.dart`

```dart
/// Plain data class for company write operations.
///
/// All fields nullable — updates can be partial.
/// Only non-null fields are sent to the API (null-skipping toJson).
class CompanyUpdate {
  const CompanyUpdate({
    this.name,
    this.description,
    this.website,
    this.size,
    this.province,
  });

  final String? name;
  final String? description;
  final String? website;
  final String? size;         // CompanySize.value string
  final String? province;     // VietnamProvinces.all entry

  CompanyUpdate copyWith({
    String? name,
    String? description,
    String? website,
    String? size,
    String? province,
  }) => CompanyUpdate(
    name: name ?? this.name,
    description: description ?? this.description,
    website: website ?? this.website,
    size: size ?? this.size,
    province: province ?? this.province,
  );

  /// Converts non-null fields to a JSON map for Supabase.
  /// Null fields are skipped — prevents overwriting existing DB values.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (website != null) map['website'] = website;
    if (size != null) map['size'] = size;
    if (province != null) map['province'] = province;
    return map;
  }
}
```

#### `domain/repositories/company_repository.dart`

```dart
abstract class CompanyRepository {
  /// Fetch the Recruiter's company. Returns null if not created yet.
  Future<Either<Failure, Company?>> getCompanyByRecruiterId(
    String recruiterId);

  /// Create a new company. Returns the generated company ID.
  Future<Either<Failure, String>> createCompany(CompanyUpdate update);

  /// Update an existing company's text fields.
  Future<Either<Failure, void>> updateCompany(
    String companyId, CompanyUpdate update);

  /// Upload logo to Storage and update companies.logo_url.
  /// Flow: delete existing → upload new → UPDATE logo_url.
  Future<Either<Failure, String>> uploadLogo(
    String companyId, Uint8List bytes, String ext);
}
```

#### `domain/usecases/upload_logo_usecase.dart`

```dart
/// Uploads a company logo with the delete-then-upload flow.
///
/// Returns the relative storage path on success
/// (e.g. `logos/{companyId}/logo.jpg`).
/// Same pattern as UploadAvatarUseCase.
class UploadLogoUseCase {
  const UploadLogoUseCase(this._repository);

  final CompanyRepository _repository;

  Future<Either<Failure, String>> call(
    String companyId, Uint8List bytes, String ext,
  ) async {
    return _repository.uploadLogo(companyId, bytes, ext);
  }
}
```

---

### Step 6: Data Layer

#### `data/models/company_model.dart` (Freezed)

```dart
@freezed
class CompanyModel with _$CompanyModel {
  const factory CompanyModel({
    required String id,
    @JsonKey(name: 'recruiter_id') required String recruiterId,
    required String name,
    @JsonKey(name: 'logo_url') String? logoUrl,
    String? description,
    String? website,
    String? size,
    String? province,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CompanyModel;

  factory CompanyModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyModelFromJson(json);
}

// Extension for model → entity conversion
extension CompanyModelX on CompanyModel {
  Company toEntity() => Company(
    id: id,
    recruiterId: recruiterId,
    name: name,
    logoUrl: logoUrl,
    description: description,
    website: website,
    size: size,
    province: province,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
```

#### `data/mappers/recruiter_error_mapper.dart`

```dart
class RecruiterErrorMapper {
  const RecruiterErrorMapper._();

  static Failure fromPostgrest(PostgrestException e) {
    return switch (e.code) {
      '23505' => DatabaseFailure(
          message: 'Bạn đã có hồ sơ công ty. '
              'Vui lòng làm mới trang.',
          code: e.code,
        ),
      '23503' => DatabaseFailure(
          message: 'Dữ liệu liên quan không tồn tại.',
          code: e.code,
        ),
      '42501' => DatabaseFailure(
          message: 'Bạn không có quyền thực hiện '
              'thao tác này.',
          code: e.code,
        ),
      _ => DatabaseFailure(
          message: AppStrings.errorGeneral,
          code: e.code,
        ),
    };
  }

  static Failure fromStorage(StorageException e) =>
      StorageFailure(message: e.message);

  static Failure fromUnknown(Object e, StackTrace st) =>
      NetworkFailure(
        message: AppStrings.errorGeneral,
        stackTrace: st,
      );
}
```

#### `data/datasources/company_datasource.dart`

Key methods and Supabase patterns:

| Method | Supabase call | Returns |
|--------|--------------|---------|
| `getCompanyByRecruiterId(rid)` | `.from('companies').select().eq('recruiter_id', rid).maybeSingle()` | `Either<Failure, Company?>` |
| `createCompany(update)` | `.from('companies').insert({recruiter_id: uid, ...update.toJson()}).select('id').single()` | `Either<Failure, String>` |
| `updateCompany(cid, update)` | `.from('companies').update(update.toJson()).eq('id', cid).select()` + empty check | `Either<Failure, void>` |
| `uploadLogo(cid, bytes, ext)` | Delete existing `logos/{cid}/` → `uploadBinary` → `UPDATE logo_url` | `Either<Failure, String>` |

> [!IMPORTANT]
> **PostgREST silent UPDATE rule**: `updateCompany` chains `.select()` and checks `result.isEmpty`.
> Empty result = 0 rows affected = likely RLS block → return `DatabaseFailure`.

> [!IMPORTANT]
> **Logo Storage**: bucket = `public-assets`, path = `logos/{companyId}/logo.{ext}`.
> Delete-then-upload flow: list existing files in `logos/{companyId}/`, remove all, then upload new.

#### `data/repositories/company_repository_impl.dart`

Thin pass-through to datasource (same pattern as `ProfileRepositoryImpl`).

---

### Step 7: Presentation — Providers

#### `presentation/providers/company_provider.dart`

```dart
// Repository provider
@riverpod
CompanyRepository companyRepository(CompanyRepositoryRef ref) {
  final supabase = Supabase.instance.client;
  return CompanyRepositoryImpl(CompanyDatasourceImpl(supabase));
}

// Central company provider — nullable (null = not created yet)
@riverpod
Future<Company?> currentCompany(CurrentCompanyRef ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return null;
  if (auth.role != UserRole.recruiter) return null;

  final result = await ref.watch(companyRepositoryProvider)
      .getCompanyByRecruiterId(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (company) => company, // nullable — null = not created yet
  );
}
```

---

### Step 8: Shared Widgets

#### `shared/widgets/province_picker_sheet.dart`

- Bottom sheet with `backgroundColor: AppColors.surfaceVariant`
- Search `TextField` at top — case-insensitive `contains` matching
- `ListView.builder` of matching provinces from `VietnamProvinces.all`
- Each item is `ListTile` → tap returns selected `String` via `Navigator.pop()`
- Accepts optional `selectedProvince` param to highlight current selection
- Reused by: T-13 (Company), T-14 (Job Location), T-16 (Search filter)

#### `shared/widgets/recruiter_shell.dart`

- 4 tabs: Trang chủ · Tin của tôi · Tin nhắn · Hồ sơ
- Icons: `Icons.home` · `Icons.article` · `Icons.message` · `Icons.person`
- Uses `navigationShell.goBranch()` same as existing Seeker shell
- Same `BottomNavigationBar` styling

---

### Step 9: Presentation — Pages

#### `CompanyProfilePage`

Two states based on `currentCompanyProvider`:

**Empty state** (`company == null`):
- Centered column layout
- `Icons.business` large placeholder (48sp, `AppColors.textSecondary`)
- `AppStrings.companyEmptyTitle` as headline
- `AppStrings.companyEmptySubtitle` as body
- Single teal `FilledButton`: `AppStrings.createCompany`
- `onPressed: () => context.push('/recruiter/company/edit')`

**Data state** (`company != null`):
- Logo at top (rounded rectangle via `ClipRRect`, 100×100)
  - Uses `StorageUtils.publicUrl(company.logoUrl!)` if logo exists
  - `Icons.business` placeholder if no logo
- Company name (headline style)
- Description, website (as tappable link), size (`CompanySize.fromValue(company.size)?.displayLabel`), province
- Container + InkWell cards (no shadows, per DESIGN.md)
- "Chỉnh sửa" `OutlinedButton` → `context.push('/recruiter/company/edit')`

#### `EditCompanyPage`

- `ConsumerStatefulWidget` with `TextEditingController`s
- Reads `currentCompanyProvider` ONCE in `initState()` for initial values
- `_isCreating` flag: `company == null` means CREATE, else UPDATE
- Form field order:
  1. `LogoPicker` (centered, with current logo path)
  2. Company name `TextFormField` (required: `Validators.text(v, AppStrings.companyName)`)
  3. Description `TextFormField` multiline, 5 lines (`Validators.longText(v, AppStrings.companyDescription)`)
  4. Website `TextFormField` (`Validators.url()`)
  5. Size `DropdownButtonFormField<CompanySize>` (nullable, hint text)
  6. Province — read-only `TextFormField` with `onTap` → `ProvincePickerSheet`
- AppBar title: `AppStrings.createCompany` or `AppStrings.editCompany`
- Save button: teal `FilledButton`, disabled while `_isSaving`
- Input decoration: same `_inputDecoration()` helper as `EditProfilePage`

**CREATE flow** (`_handleSave`):
1. Validate form
2. Build `CompanyUpdate` from controllers
3. `repository.createCompany(update)` → get `companyId`
4. If logo picked → `UploadLogoUseCase(repo).call(companyId, bytes, ext)`
5. `ref.invalidate(currentCompanyProvider)`
6. SnackBar: `AppStrings.companyCreated` → `context.pop()`

**EDIT flow** (`_handleSave`):
1. Validate form
2. Build `CompanyUpdate` from controllers
3. `repository.updateCompany(companyId, update)`
4. If logo changed → `UploadLogoUseCase(repo).call(companyId, bytes, ext)`
5. `ref.invalidate(currentCompanyProvider)`
6. SnackBar: `AppStrings.companyUpdated` → `context.pop()`

**Error handling:**
- `23505` on CREATE → SnackBar + `ref.invalidate(currentCompanyProvider)` (self-heal)
- Other failures → SnackBar with `failure.message`
- Logo upload failure during CREATE → SnackBar only, company saved (no rollback)

---

### Step 10: Router Changes

Update `app_router.dart`:

```dart
// In StatefulShellRoute builder:
final role = _resolveRole(ref);
return switch (role) {
  UserRole.seeker    => SeekerShell(navigationShell: navigationShell),
  UserRole.recruiter => RecruiterShell(navigationShell: navigationShell),
  // TODO(T-33): Replace with AdminShell when admin feature is built.
  // Admin borrows SeekerShell temporarily — cannot use PlaceholderPage
  // here because StatefulShellRoute builder expects a shell widget.
  UserRole.admin     => SeekerShell(navigationShell: navigationShell),
};
```

**Recruiter branches** (new `StatefulShellRoute`):

| Tab | Path | Page |
|-----|------|------|
| Trang chủ | `/recruiter/home` | `PlaceholderPage` (for now) |
| Tin của tôi | `/recruiter/posts` | `PlaceholderPage` (T-15) |
| Tin nhắn | `/recruiter/conversations` | `PlaceholderPage` (T-28) |
| Hồ sơ | `/recruiter/profile` | `ProfilePage` (shared) |

**Push routes** (outside shell):

| Path | Page |
|------|------|
| `/recruiter/company` | `CompanyProfilePage` |
| `/recruiter/company/edit` | `EditCompanyPage` |
| `/recruiter/profile/edit` | `EditProfilePage` (shared) |

---

### Step 11: ProfilePage Modification

Add role-gated "Hồ sơ công ty" section for Recruiter:

```dart
// After existing profile content, check role:
if (auth.role == UserRole.recruiter) ...[
  const SizedBox(height: 16),
  _buildCompanyLink(context),
]

Widget _buildCompanyLink(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/recruiter/company'),
      child: /* Icon: Icons.business + AppStrings.companyProfile + chevron */,
    ),
  );
}
```

---

### Step 12: LogoPicker Widget

`features/recruiter/presentation/widgets/logo_picker.dart`

- Rounded rectangle container ~100×100
- `Icons.business` placeholder (when no logo)
- Camera overlay icon (centered or bottom-right)
- Same compression: `maxWidth: 512, maxHeight: 512, imageQuality: 80`
- Bottom sheet picker: `AppColors.surfaceVariant`, gallery + camera
- Callback: `onImagePicked(Uint8List bytes, String ext)`
- Displays current logo via `CachedNetworkImage(StorageUtils.publicUrl(path))`
- Does NOT modify or import `AvatarPicker`

---

## Checklist

- [ ] Run migration `20260518000000_company_size_check.sql`
- [ ] Create `core/constants/company_sizes.dart`
- [ ] Create `core/constants/vietnam_provinces.dart`
- [ ] Add `Validators.text()` and `Validators.longText()` to `core/utils/validators.dart`
- [ ] Add AppStrings (company + recruiter shell) to `core/constants/app_strings.dart`
- [ ] Create `domain/entities/company.dart`
- [ ] Create `domain/entities/company_update.dart`
- [ ] Create `domain/repositories/company_repository.dart`
- [ ] Create `domain/usecases/upload_logo_usecase.dart`
- [ ] Create `data/models/company_model.dart` + run `build_runner`
- [ ] Create `data/mappers/recruiter_error_mapper.dart`
- [ ] Create `data/datasources/company_datasource.dart`
- [ ] Create `data/repositories/company_repository_impl.dart`
- [ ] Create `presentation/providers/company_provider.dart` + run `build_runner`
- [ ] Create `shared/widgets/province_picker_sheet.dart`
- [ ] Create `shared/widgets/recruiter_shell.dart`
- [ ] Create `presentation/widgets/logo_picker.dart`
- [ ] Create `presentation/pages/company_profile_page.dart`
- [ ] Create `presentation/pages/edit_company_page.dart`
- [ ] Update `app_router.dart` — role-aware shell + recruiter routes
- [ ] Update `ProfilePage` — add "Hồ sơ công ty" button (role-gated)
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Run `flutter analyze` — zero warnings
- [ ] Manual test: CREATE company → logo upload → EDIT → verify
- [ ] Commit: `feat(recruiter): T-13 company CRUD + logo upload`
