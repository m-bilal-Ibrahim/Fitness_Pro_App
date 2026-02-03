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

  // --- Step 2 & 3 Controllers ---
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _step2Key = GlobalKey<FormState>();

  String _selectedRole = 'member';
  final _gymNameCtrl = TextEditingController();
  final _gymAddressCtrl = TextEditingController();
  final _step3Key = GlobalKey<FormState>();

  // --- Navigation Logic ---
  Future<void> _nextPage() async {
    if (_currentStep == 0) {
      if (!_step1Key.currentState!.validate()) return;
      // ... (Add your existing email check logic here if needed)
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
    // ... (Your submission logic)
    await Future.delayed(const Duration(seconds: 2)); // Placeholder
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("CREATE ACCOUNT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: neonGreen, size: 18),
        leading: _currentStep > 0 ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prevPage) : null,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_currentStep + 1) / 3, color: neonGreen, backgroundColor: Colors.grey.shade900, minHeight: 2),
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
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 35,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextPage,
                style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
                child: _isLoading
                    ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : Text(_currentStep == 2 ? "COMPLETE REGISTRATION" : "NEXT STEP", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 14)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- STEP 1: SCROLLABLE & ALIGNED ---
  Widget _buildStep1PersonalInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Personal Details", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _input("Full Name", _fullNameCtrl, required: true, regex: RegExp(r"^[a-zA-Z\s]+$"), errorMsg: "Letters only"),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _input("Age", _ageCtrl, required: true, number: true)),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: _phoneInput()), // Phone Input handles its own height
              ],
            ),

            _input("Email", _emailCtrl, required: true, isEmail: true),
            _input("Profile Pic URL (Optional)", _profilePicCtrl),

            const Divider(color: Colors.white24, height: 40),

            const Text("Address", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            _input("Street Address", _addressCtrl, required: true, minLength: 5),

            Row(children: [
              Expanded(child: _input("City", _cityCtrl, required: true)),
              const SizedBox(width: 10),
              Expanded(child: _input("State", _stateCtrl, required: true)),
            ]),

            Row(children: [
              Expanded(child: _input("Country", _countryCtrl, required: true)),
              const SizedBox(width: 10),
              Expanded(child: _input("Postal Code", _postalCtrl, number: true)),
            ]),
          ],
        ),
      ),
    );
  }

  // --- ALIGNED PHONE INPUT ---
  Widget _phoneInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Match spacing of _input
      height: 50, // Fixed height for alignment
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children to fill height
        children: [
          // 1. Dropdown Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountryCode,
                dropdownColor: Colors.grey.shade900,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                items: _countryCodes.map((c) {
                  // Show simplified code to save space
                  return DropdownMenuItem(value: c, child: Text(c.split(' ')[0] + c.split(' ')[1]));
                }).toList(),
                onChanged: (v) => setState(() => _selectedCountryCode = v!),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 2. Text Field
          Expanded(
            child: TextFormField(
              controller: _contactCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              // Remove vertical padding to let Center align it
              decoration: InputDecoration(
                hintText: "Phone",
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade900,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16), // Horizontal only
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: neonGreen)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Password() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Form(
        key: _step2Key,
        child: Column(
          children: [
            const Icon(Icons.lock_person, size: 28, color: neonGreen), // Smaller Icon
            const SizedBox(height: 10), // Tighter spacing
            _input("Create Password", _passCtrl, isPassword: true),
            _input("Confirm Password", _confirmPassCtrl, isPassword: true, validator: (v) => v != _passCtrl.text ? "Passwords do not match" : null),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3RoleAndFinish() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Form(
        key: _step3Key,
        child: Column(
          children: [
            const Text("Select Role", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10), // Reduced spacing
            Row(children: [
              Expanded(child: _roleCard("Member", Icons.person, _selectedRole == 'member')),
              const SizedBox(width: 8), // Tighter gap
              Expanded(child: _roleCard("Owner", Icons.business, _selectedRole == 'owner')),
            ]),
            if (_selectedRole == 'owner') ...[
              const SizedBox(height: 12), // Reduced spacing
              _input("Gym Name", _gymNameCtrl, required: true, minLength: 3),
              _input("Gym Address", _gymAddressCtrl, required: true, minLength: 5),
            ]
          ],
        ),
      ),
    );
  }

// Updated Role Card to be much smaller/flatter
  Widget _roleCard(String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = title == "Member" ? 'member' : 'owner'),
      child: Container(
        height: 70, // Fixed small height
        decoration: BoxDecoration(
          color: isSelected ? neonGreen : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? neonGreen : Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: isSelected ? Colors.black : Colors.white), // Smaller icon
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)), // Smaller text
          ],
        ),
      ),
    );
  }

  // --- REFINED INPUT WIDGET ---
  Widget _input(String label, TextEditingController ctrl, {
    bool required = false,
    bool number = false,
    bool isEmail = false,
    bool isPassword = false,
    int minLength = 0,
    RegExp? regex,
    String? errorMsg,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SizedBox(
        height: 50, // Fixed comfortable height (not too big, not too small)
        child: TextFormField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          obscureText: isPassword,
          keyboardType: number ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
          inputFormatters: number ? [FilteringTextInputFormatter.digitsOnly] : [],
          validator: validator ?? (v) {
            // NOTE: Validation messages might overlay or shift layout with fixed height.
            // For a truly clean fixed-height look, usually validation is handled differently,
            // but this is standard. If error appears, it might expand the height slightly.
            if (required && (v == null || v.trim().isEmpty)) return null;
            return null;
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
            floatingLabelStyle: const TextStyle(color: neonGreen),
            filled: true,
            fillColor: Colors.grey.shade900,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), // Vertically centered
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: neonGreen)),
            errorStyle: const TextStyle(height: 0, fontSize: 0), // Hide default error text to keep layout compact
          ),
        ),
      ),
    );
  }
}