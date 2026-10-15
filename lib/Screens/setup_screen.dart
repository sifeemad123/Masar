import 'package:flutter/material.dart';
import 'package:masar/Screens/home_screen.dart';
import 'package:masar/Screens/main_screen.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  //  Tajawal , ElMessiri
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(75),
                    ),
                    child: Icon(
                      Icons.water_drop,
                      size: 50,
                      color: AppColors.accent,
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    "مسار",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 35),
                  Form(
                    key: _formKey,
                    child: Column(
                      spacing: 20,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "اسمك إيه؟",
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          controller: _nameController,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),
                            hintText: "الاسم",
                            labelText: 'ادخل اسمك',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            labelStyle: TextStyle(
                              color: AppColors.textDisabled,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (  value == null || value.isEmpty) {
                              return "الاسم مطلوب من فضلك أدخل اسمك";
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.all(30),
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () async {
                                final pref =
                                    await SharedPreferences.getInstance();
                                if (_formKey.currentState!.validate()) {
                                  pref.setBool('isFirstTime', false);
                                  pref.setString('userName', _nameController.text);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MainScreen(),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                "يلا نبدأ",
                                style: TextStyle(
                                  color: AppColors.onAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
