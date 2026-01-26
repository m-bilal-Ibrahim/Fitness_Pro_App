import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/data/user_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../gyms/presentation/gym_controller.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const Color neonGreen = Color(0xFFD0FD3E);
  bool _isLoading = false;

  // --- Step 1 Controllers ---
  final _fullNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _profilePicCtrl = TextEditingController();
  final _step1Key = GlobalKey<FormState>();

  // --- Country Code Selection ---
  String _selectedCountryCode = '🇵🇰 PK (+92)';

  final List<String> _countryCodes = [
    '🇦🇫 AF (+93)', '🇦🇱 AL (+355)', '🇩🇿 DZ (+213)', '🇦🇸 AS (+1684)', '🇦🇩 AD (+376)',
    '🇦🇴 AO (+244)', '🇦🇮 AI (+1264)', '🇦🇶 AQ (+672)', '🇦🇬 AG (+1268)', '🇦🇷 AR (+54)',
    '🇦🇲 AM (+374)', '🇦🇼 AW (+297)', '🇦🇺 AU (+61)', '🇦🇹 AT (+43)', '🇦🇿 AZ (+994)',
    '🇧🇸 BS (+1242)', '🇧🇭 BH (+973)', '🇧🇩 BD (+880)', '🇧🇧 BB (+1246)', '🇧🇾 BY (+375)',
    '🇧🇪 BE (+32)', '🇧🇿 BZ (+501)', '🇧🇯 BJ (+229)', '🇧🇲 BM (+1441)', '🇧🇹 BT (+975)',
    '🇧🇴 BO (+591)', '🇧🇦 BA (+387)', '🇧🇼 BW (+267)', '🇧🇷 BR (+55)', '🇻🇬 VG (+1284)',
    '🇧🇳 BN (+673)', '🇧🇬 BG (+359)', '🇧🇫 BF (+226)', '🇲🇲 MM (+95)', '🇧🇮 BI (+257)',
    '🇰🇭 KH (+855)', '🇨🇲 CM (+237)', '🇨🇦 CA (+1)', '🇨🇻 CV (+238)', '🇰🇾 KY (+1345)',
    '🇨🇫 CF (+236)', '🇹🇩 TD (+235)', '🇨🇱 CL (+56)', '🇨🇳 CN (+86)', '🇨🇴 CO (+57)',
    '🇰🇲 KM (+269)', '🇨🇬 CG (+242)', '🇨🇷 CR (+506)', '🇭🇷 HR (+385)', '🇨🇺 CU (+53)',
    '🇨🇾 CY (+357)', '🇨🇿 CZ (+420)', '🇩🇰 DK (+45)', '🇩🇯 DJ (+253)', '🇩🇴 DO (+1809)',
    '🇪🇨 EC (+593)', '🇪🇬 EG (+20)', '🇸🇻 SV (+503)', '🇪🇪 EE (+372)', '🇪🇹 ET (+251)',
    '🇫🇮 FI (+358)', '🇫🇷 FR (+33)', '🇩🇪 DE (+49)', '🇬🇭 GH (+233)', '🇬🇷 GR (+30)',
    '🇬🇱 GL (+299)', '🇬🇩 GD (+1473)', '🇬🇵 GP (+590)', '🇬🇺 GU (+1671)', '🇬🇹 GT (+502)',
    '🇬🇳 GN (+224)', '🇬🇼 GW (+245)', '🇬🇾 GY (+592)', '🇭🇹 HT (+509)', '🇭🇳 HN (+504)',
    '🇭🇰 HK (+852)', '🇭🇺 HU (+36)', '🇮🇸 IS (+354)', '🇮🇳 IN (+91)', '🇮🇩 ID (+62)',
    '🇮🇷 IR (+98)', '🇮🇶 IQ (+964)', '🇮🇪 IE (+353)', '🇮🇱 IL (+972)', '🇮🇹 IT (+39)',
    '🇯🇲 JM (+1876)', '🇯🇵 JP (+81)', '🇯🇴 JO (+962)', '🇰🇿 KZ (+7)', '🇰🇪 KE (+254)',
    '🇰🇮 KI (+686)', '🇰🇵 KP (+850)', '🇰🇷 KR (+82)', '🇰🇼 KW (+965)', '🇰🇬 KG (+996)',
    '🇱🇦 LA (+856)', '🇱🇻 LV (+371)', '🇱🇧 LB (+961)', '🇱🇸 LS (+266)', '🇱🇷 LR (+231)',
    '🇱🇾 LY (+218)', '🇱🇮 LI (+423)', '🇱🇹 LT (+370)', '🇱🇺 LU (+352)', '🇲🇴 MO (+853)',
    '🇲🇰 MK (+389)', '🇲🇬 MG (+261)', '🇲🇼 MW (+265)', '🇲🇾 MY (+60)', '🇲🇻 MV (+960)',
    '🇲🇱 ML (+223)', '🇲🇹 MT (+356)', '🇲🇭 MH (+692)', '🇲🇶 MQ (+596)', '🇲🇷 MR (+222)',
    '🇲🇺 MU (+230)', 'YT YT (+262)', '🇲🇽 MX (+52)', '🇫🇲 FM (+691)', '🇲🇩 MD (+373)',
    '🇲🇨 MC (+377)', '🇲🇳 MN (+976)', '🇲🇪 ME (+382)', '🇲🇸 MS (+1664)', '🇲🇦 MA (+212)',
    '🇲🇿 MZ (+258)', '🇲🇲 MM (+95)', '🇳🇦 NA (+264)', '🇳🇷 NR (+674)', '🇳🇵 NP (+977)',
    '🇳🇱 NL (+31)', '🇳🇨 NC (+687)', '🇳🇿 NZ (+64)', '🇳🇮 NI (+505)', '🇳🇪 NE (+227)',
    '🇳🇬 NG (+234)', '🇳🇺 NU (+683)', '🇳🇫 NF (+672)', '🇲🇵 MP (+1670)', '🇳🇴 NO (+47)',
    '🇴🇲 OM (+968)', '🇵🇰 PK (+92)', '🇵🇼 PW (+680)', '🇵🇸 PS (+970)', '🇵🇦 PA (+507)',
    '🇵🇬 PG (+675)', '🇵🇾 PY (+595)', '🇵🇪 PE (+51)', '🇵🇭 PH (+63)', '🇵🇳 PN (+870)',
    '🇵🇱 PL (+48)', '🇵🇹 PT (+351)', '🇵🇷 PR (+1)', '🇶🇦 QA (+974)', '🇷🇪 RE (+262)',
    '🇷🇴 RO (+40)', '🇷🇺 RU (+7)', '🇷🇼 RW (+250)', '🇧🇱 BL (+590)', '🇸🇭 SH (+290)',
    '🇰🇳 KN (+1869)', '🇱🇨 LC (+1758)', '🇲🇫 MF (+590)', '🇵🇲 PM (+508)', '🇻🇨 VC (+1784)',
    '🇼🇸 WS (+685)', '🇸🇲 SM (+378)', '🇸🇹 ST (+239)', '🇸🇦 SA (+966)', '🇸🇳 SN (+221)',
    '🇷🇸 RS (+381)', '🇸🇨 SC (+248)', '🇸🇱 SL (+232)', '🇸🇬 SG (+65)', '🇸🇽 SX (+1721)',
    '🇸🇰 SK (+421)', '🇸🇮 SI (+386)', '🇸🇧 SB (+677)', '🇸🇴 SO (+252)', '🇿🇦 ZA (+27)',
    '🇬🇸 GS (+500)', '🇸🇸 SS (+211)', '🇪🇸 ES (+34)', '🇱🇰 LK (+94)', '🇸🇩 SD (+249)',
    '🇸🇷 SR (+597)', '🇸🇯 SJ (+47)', '🇸🇿 SZ (+268)', '🇸🇪 SE (+46)', '🇨🇭 CH (+41)',
    '🇸🇾 SY (+963)', '🇹🇼 TW (+886)', '🇹🇯 TJ (+992)', '🇹🇿 TZ (+255)', '🇹🇭 TH (+66)',
    '🇹🇱 TL (+670)', '🇹🇬 TG (+228)', '🇹🇰 TK (+690)', '🇹🇴 TO (+676)', '🇹🇹 TT (+1868)',
    '🇹🇳 TN (+216)', '🇹🇷 TR (+90)', '🇹🇲 TM (+993)', '🇹🇨 TC (+1649)', '🇹🇻 TV (+688)',
    '🇺🇬 UG (+256)', '🇺🇦 UA (+380)', '🇦🇪 AE (+971)', '🇬🇧 GB (+44)', '🇺🇸 US (+1)',
    '🇺🇾 UY (+598)', '🇺🇿 UZ (+998)', '🇻🇺 VU (+678)', '🇻🇪 VE (+58)', '🇻🇳 VN (+84)',
    '🇻🇬 VG (+1284)', '🇻🇮 VI (+1340)', '🇼🇫 WF (+681)', '🇪🇭 EH (+212)', '🇾🇪 YE (+967)',
    '🇿🇲 ZM (+260)', '🇿🇼 ZW (+263)'
  ];

  // --- Step 2 Controllers ---
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _step2Key = GlobalKey<FormState>();

  // --- Step 3 Controllers ---
  String _selectedRole = 'member';
  final _gymNameCtrl = TextEditingController();
  final _gymAddressCtrl = TextEditingController();
  final _step3Key = GlobalKey<FormState>();

  // --- Validation Logic ---
  Future<void> _nextPage() async {
    if (_currentStep == 0) {
      if (!_step1Key.currentState!.validate()) return;

      setState(() => _isLoading = true);
      try {
        final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(_emailCtrl.text.trim());
        if (methods.isNotEmpty) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email already registered. Please Login.")));
          setState(() => _isLoading = false);
          return;
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Network Error: $e")));
        setState(() => _isLoading = false);
        return;
      }
      setState(() => _isLoading = false);
    }

    if (_currentStep == 1 && !_step2Key.currentState!.validate()) return;
    if (_currentStep == 2 && _selectedRole == 'owner' && !_step3Key.currentState!.validate()) return;

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _submitRegistration();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);
    try {
      final authCtrl = ref.read(authControllerProvider);

      final cred = await authCtrl.register(email: _emailCtrl.text.trim(), password: _passCtrl.text.trim());

      if (cred != null) {
        await authCtrl.sendVerification();

        // Parse country code: "🇵🇰 PK (+92)" -> "+92"
        final rawCode = _selectedCountryCode.split('(').last.replaceAll(')', '');
        final fullPhoneNumber = "$rawCode${_contactCtrl.text.trim()}";

        final newUser = UserModel(
          uid: cred.uid,
          email: _emailCtrl.text.trim(),
          role: _selectedRole,
          createdAt: DateTime.now(),
          fullName: _fullNameCtrl.text.trim(),
          age: _ageCtrl.text.trim(),
          contact: fullPhoneNumber,
          address: _addressCtrl.text.trim(),
          state: _stateCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          country: _countryCtrl.text.trim(),
          postalCode: _postalCtrl.text.trim(),
          profilePic: _profilePicCtrl.text.trim(),
        );
        await ref.read(userRepositoryProvider).saveUserData(newUser);

        if (_selectedRole == 'owner') {
          await ref.read(gymControllerProvider).createOrUpdateGym(
            name: _gymNameCtrl.text.trim(),
            address: _gymAddressCtrl.text.trim(),
            description: "My First Gym Branch",
            status: "open",
            openTime: "06:00",
            closeTime: "22:00",
            slotCapacity: 50,
            priceSilver: 20, priceGold: 50, pricePlatinum: 400, trainerFee: 15,
            images: [],
            overrideOwnerId: cred.uid,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created! Verify your email.")));
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("CREATE ACCOUNT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: neonGreen),
        leading: _currentStep > 0 ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prevPage) : null,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_currentStep + 1) / 3, color: neonGreen, backgroundColor: Colors.grey.shade900),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1PersonalInfo(),
                _buildStep2Password(),
                _buildStep3RoleAndFinish(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextPage,
                style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black))
                    : Text(_currentStep == 2 ? "COMPLETE REGISTRATION" : "NEXT STEP", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- STEP 1 UI ---
  Widget _buildStep1PersonalInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Personal Details", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _input("Full Name", _fullNameCtrl, required: true, regex: RegExp(r"^[a-zA-Z\s]+$"), errorMsg: "Only letters allowed"),
            Row(children: [
              Expanded(child: _input("Age", _ageCtrl, required: true, number: true, validator: (v) {
                int? age = int.tryParse(v ?? "");
                if(age == null || age < 12 || age > 200) return "12-200 only";
                return null;
              })),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _phoneInput()),
            ]),
            _input("Email", _emailCtrl, required: true, isEmail: true),
            _input("Profile Pic URL (Optional)", _profilePicCtrl),
            const Divider(color: Colors.white24, height: 40),
            const Text("Address", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _input("Street Address", _addressCtrl, required: true, minLength: 5),
            Row(children: [
              Expanded(child: _input("City", _cityCtrl, required: true, regex: RegExp(r"^[a-zA-Z\s]+$"))),
              const SizedBox(width: 10),
              Expanded(child: _input("State", _stateCtrl, required: true, regex: RegExp(r"^[a-zA-Z\s]+$"))),
            ]),
            Row(children: [
              Expanded(child: _input("Country", _countryCtrl, required: true, regex: RegExp(r"^[a-zA-Z\s]+$"))),
              const SizedBox(width: 10),
              Expanded(child: _input("Postal Code", _postalCtrl, number: true)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _phoneInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountryCode,
                dropdownColor: Colors.grey.shade900,
                style: const TextStyle(color: Colors.white),
                // Show the FULL string (Flag + Short + Code)
                items: _countryCodes.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: const TextStyle(fontSize: 14))
                )).toList(),
                onChanged: (v) => setState(() => _selectedCountryCode = v!),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _contactCtrl,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              validator: (v) => (v == null || v.length != 10) ? "10 digits required" : null,
              decoration: _dec("Phone", null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Password() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step2Key,
        child: Column(
          children: [
            const Text("Security Setup", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextFormField(
              controller: _passCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _dec("Create Password", Icons.lock),
              validator: (v) {
                if (v == null || v.isEmpty) return "Required";
                String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                if (!RegExp(pattern).hasMatch(v)) return "Must be 8+ chars (Upper, Lower, Digit, Special)";
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _confirmPassCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _dec("Confirm Password", Icons.lock_outline),
              validator: (v) => v != _passCtrl.text ? "Passwords do not match" : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3RoleAndFinish() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step3Key,
        child: Column(
          children: [
            const Text("Select Role", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Row(children: [
              Expanded(child: _roleCard("Member", Icons.person, _selectedRole == 'member')),
              const SizedBox(width: 15),
              Expanded(child: _roleCard("Gym Owner", Icons.business, _selectedRole == 'owner')),
            ]),
            if (_selectedRole == 'owner') ...[
              const SizedBox(height: 40),
              _input("Gym Name", _gymNameCtrl, required: true, minLength: 3),
              _input("Gym Address", _gymAddressCtrl, required: true, minLength: 5),
            ]
          ],
        ),
      ),
    );
  }

  Widget _roleCard(String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = title == "Member" ? 'member' : 'owner'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: isSelected ? neonGreen : Colors.grey.shade900, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? neonGreen : Colors.white24)),
        child: Column(children: [Icon(icon, size: 40, color: isSelected ? Colors.black : Colors.white), const SizedBox(height: 10), Text(title, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl, {
    bool required = false,
    bool number = false,
    bool isEmail = false,
    int minLength = 0,
    RegExp? regex,
    String? errorMsg,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        keyboardType: number ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        inputFormatters: number ? [FilteringTextInputFormatter.digitsOnly] : [],
        validator: validator ?? (v) {
          if (required && (v == null || v.trim().isEmpty)) return "$label is required";
          if (minLength > 0 && v!.length < minLength) return "Min $minLength chars required";
          if (isEmail) {
            final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
            if (!emailRegex.hasMatch(v!)) return "Invalid Email";
          }
          if (regex != null && !regex.hasMatch(v!)) return errorMsg ?? "Invalid format";
          return null;
        },
        decoration: _dec(label, null),
      ),
    );
  }

  InputDecoration _dec(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
      filled: true,
      fillColor: Colors.grey.shade900,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: neonGreen)),
    );
  }
}