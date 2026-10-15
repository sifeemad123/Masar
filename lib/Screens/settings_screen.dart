import 'dart:math';

import 'package:flutter/material.dart';
import 'package:masar/Screens/about_screen.dart';
import 'package:masar/Screens/onboarding_screens.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/AppColors.dart';
class Quote {
  final String text;
  final String author;
  final String? category;

  const Quote({required this.text, required this.author, this.category});
}


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  static void confirmation({
    required BuildContext context,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  color: AppColors.overlay,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 50,
                    color: AppColors.textPrimary,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    " تأكيد ",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Provider.of<UserDataProvider>(context , listen: false).deleteAllData();
                        Dialogs.success(context: context, message: "تم حذف جميع البيانات بنجاح");
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnboardingScreens()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.overlay,
                      ),
                      child: Text(
                        "تأكيد",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.overlay,
                      ),
                      child: Text(
                        "إغلاق",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _card({Widget? child, Color? color, required double height}) {
    Color color2 = color ?? AppColors.surface;
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color2,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    const List<Quote> motivationalQuotes =  [
      Quote(
        text: 'مش لازم تعرف الطريق كله، كفاية تعرف الخطوة الجاية.',
        author: 'مجهول',
        category: 'الحياة',
      ),
      Quote(
        text: 'الوقت مش بيحل كل حاجة، بس بيكشف حاجات كتير.',
        author: 'مجهول',
        category: 'الوقت',
      ),
      Quote(
        text: 'اللي مستني الظروف تبقى مثالية، غالبًا هيفضل مستني.',
        author: 'مجهول',
        category: 'الواقع',
      ),
      Quote(
        text: 'مش كل تأخير معناه إنك ماشي غلط.',
        author: 'مجهول',
        category: 'الصبر',
      ),
      Quote(
        text: 'أوقات كتير البداية الصغيرة أهم من الخطة الكبيرة.',
        author: 'مجهول',
        category: 'البداية',
      ),
      Quote(
        text: 'الفرق بين اللي بيتمنى واللي بيوصل، خطوة اتاخدت.',
        author: 'مجهول',
        category: 'الطموح',
      ),
      Quote(
        text: 'مشكلتك مش دايمًا في قلة الوقت، ساعات في كثرة اللي بتأجله.',
        author: 'مجهول',
        category: 'الوقت',
      ),
      Quote(
        text: 'اللي بيخاف من الغلط، بيضيّع فرص كتير من غير ما يجرب.',
        author: 'مجهول',
        category: 'الخوف',
      ),
      Quote(
        text: 'مش كل خسارة نهاية، بعض الخساير بتغير اتجاهك بس.',
        author: 'مجهول',
        category: 'الفشل',
      ),
      Quote(
        text: 'في فرق بين إنك ترتاح، وإنك تستسلم.',
        author: 'مجهول',
        category: 'الصمود',
      ),
      Quote(
        text: 'النجاح مش دايمًا صوت عالي، ساعات بيكون مجرد إنك كملت.',
        author: 'مجهول',
        category: 'النجاح',
      ),
      Quote(
        text: 'اللي عايز يغيّر حياته، لازم يقبل يغيّر عاداته.',
        author: 'مجهول',
        category: 'التغيير',
      ),
      Quote(
        text: 'مش كل رأي يستحق إنك تغير نفسك عشانه.',
        author: 'مجهول',
        category: 'الناس',
      ),
      Quote(
        text: 'كبرك الحقيقي بيبان في الحاجات اللي بطلت ترد عليها.',
        author: 'مجهول',
        category: 'النضج',
      ),
      Quote(
        text: 'أصعب قرار أوقات بيكون إنك تبدأ.',
        author: 'مجهول',
        category: 'الشجاعة',
      ),
      Quote(
        text: 'اللي يعرف قيمته، مش محتاج يثبتها لكل الناس.',
        author: 'مجهول',
        category: 'الثقة',
      ),
      Quote(
        text: 'الطريق الطويل بيتقطع بنفس طريقة الطريق القصير: خطوة ورا خطوة.',
        author: 'مجهول',
        category: 'الصبر',
      ),
      Quote(
        text: 'مش لازم تبقى جاهز بالكامل عشان تبدأ.',
        author: 'مجهول',
        category: 'البداية',
      ),
      Quote(
        text: 'أوقات التغيير اللي بتقاومه هو نفسه اللي محتاجه.',
        author: 'مجهول',
        category: 'التغيير',
      ),
      Quote(
        text: 'التركيز إنك تعرف إيه يستاهل وقتك وإيه لأ.',
        author: 'مجهول',
        category: 'التركيز',
      ),
      Quote(
        text: 'مش كل باب اتقفل كان لازم تفتحه تاني.',
        author: 'مجهول',
        category: 'الاختيار',
      ),
      Quote(
        text: 'الندم على اللي فات مش هيغيره، بس ممكن يضيّع اللي جاي.',
        author: 'مجهول',
        category: 'الماضي',
      ),
      Quote(
        text: 'الفرصة اللي مستنيها ممكن تكون في الحاجة اللي بتخاف تبدأها.',
        author: 'مجهول',
        category: 'الخوف',
      ),
      Quote(
        text: 'مش كل شخص بيبعد عنك خسارة.',
        author: 'مجهول',
        category: 'الناس',
      ),
      Quote(
        text: 'أوقات السكوت مش ضعف، ده اختيار إنك ما تستهلكش نفسك.',
        author: 'مجهول',
        category: 'النضج',
      ),
      Quote(
        text: 'اللي بيحاول كل يوم، حتى لو قليل، بيتغير مع الوقت.',
        author: 'مجهول',
        category: 'الاستمرارية',
      ),
      Quote(
        text: 'مش محتاج تكون أسرع واحد، محتاج متقفش.',
        author: 'مجهول',
        category: 'الاستمرارية',
      ),
      Quote(
        text: 'الطموح من غير فعل مجرد فكرة حلوة.',
        author: 'مجهول',
        category: 'الطموح',
      ),
      Quote(
        text: 'كل مرة بتختار فيها الصح رغم صعوبته، أنت بتقوى.',
        author: 'مجهول',
        category: 'الشجاعة',
      ),
      Quote(
        text: 'اللي بيتعلم من غلطه، مكسبه أكبر من خسارته.',
        author: 'مجهول',
        category: 'التجربة',
      ),
      Quote(
        text: 'مش كل حاجة محتاجة رد، ومش كل حد محتاج تفسير.',
        author: 'مجهول',
        category: 'النضج',
      ),
      Quote(
        text: 'لما تبطل تقارن بدايتك بمنتصف طريق غيرك، هتعرف تكمل.',
        author: 'مجهول',
        category: 'المقارنة',
      ),
      Quote(
        text: 'الراحة مهمة، بس الراحة الدائمة بتخليك تنسى أنت كنت رايح فين.',
        author: 'مجهول',
        category: 'الانضباط',
      ),
      Quote(
        text: 'اللي بيبدأ النهارده متأخر عن غيره، أحسن من اللي لسه مستني.',
        author: 'مجهول',
        category: 'البداية',
      ),
      Quote(
        text: 'مش كل حاجة تستاهل إنك تحارب عشانها.',
        author: 'مجهول',
        category: 'الاختيار',
      ),
      Quote(
        text: 'أوقات أكبر تقدم بتحققه هو إنك تبطل ترجع لورا.',
        author: 'مجهول',
        category: 'التقدم',
      ),
      Quote(
        text: 'العقل الهادي بيشوف حلول مش باينة وسط الزحمة.',
        author: 'مجهول',
        category: 'العقل',
      ),
      Quote(
        text: 'لو كل خطوة محتاجة ضمان، عمرك ما هتمشي.',
        author: 'مجهول',
        category: 'المخاطرة',
      ),
      Quote(
        text: 'مش كل حاجة بتخسرها كانت مناسبة ليك من البداية.',
        author: 'مجهول',
        category: 'الخسارة',
      ),
      Quote(
        text: 'اللي بيتغير جواك أهم من اللي بيتغير حواليك.',
        author: 'مجهول',
        category: 'النمو',
      ),
      Quote(
        text: 'مفيش نسخة مثالية منك مستنياك، في نسخة أحسن بتبنيها.',
        author: 'مجهول',
        category: 'النمو',
      ),
      Quote(
        text: 'أوقات لازم تمشي لوحدك عشان تعرف أنت رايح فين.',
        author: 'مجهول',
        category: 'الاستقلال',
      ),
      Quote(
        text: 'اللي عايز نتيجة مختلفة، لازم يعمل حاجة مختلفة.',
        author: 'مجهول',
        category: 'التغيير',
      ),
      Quote(
        text: 'القرار الصح مش دايمًا بيكون القرار المريح.',
        author: 'مجهول',
        category: 'الاختيار',
      ),
      Quote(
        text: 'ممكن تكون قريب جدًا من هدفك وإنت فاكر إنك بعيد.',
        author: 'مجهول',
        category: 'الأمل',
      ),
      Quote(
        text: 'الوقت اللي بتضيعه في إثبات نفسك، ممكن تستخدمه في بنائها.',
        author: 'مجهول',
        category: 'التركيز',
      ),
      Quote(
        text: 'مش لازم الناس تفهم طريقك عشان يكون صح بالنسبالك.',
        author: 'مجهول',
        category: 'الاختيار',
      ),
      Quote(
        text: 'الفشل معلومة، مش حكم نهائي.',
        author: 'مجهول',
        category: 'الفشل',
      ),
      Quote(
        text: 'كل تجربة صعبة بتسيب وراها نسخة أهدى وأوعى منك.',
        author: 'مجهول',
        category: 'التجربة',
      ),
      Quote(
        text: 'اللي بيستنى الحماس عشان يبدأ، ممكن يستنى كتير.',
        author: 'مجهول',
        category: 'الانضباط',
      ),
      Quote(
        text: 'الانضباط إنك تعمل اللي عليك حتى لما مزاجك يقول لأ.',
        author: 'مجهول',
        category: 'الانضباط',
      ),
      Quote(
        text: 'مش كل يوم لازم يكون عظيم، المهم إنك متسيبش الرحلة.',
        author: 'مجهول',
        category: 'الاستمرارية',
      ),
      Quote(
        text: 'اللي فات خبرة، مش عنوان حياتك.',
        author: 'مجهول',
        category: 'الماضي',
      ),
      Quote(
        text: 'بعض النهايات بتفتح مساحة لحاجات أحسن.',
        author: 'مجهول',
        category: 'البدايات',
      ),
      Quote(
        text: 'لما تعرف إيه اللي مش عايزه، بتكون قربت من اللي عايزه.',
        author: 'مجهول',
        category: 'الاختيار',
      ),
      Quote(
        text: 'مش كل تأخير ضياع، ساعات بيكون تجهيز.',
        author: 'مجهول',
        category: 'الصبر',
      ),
      Quote(
        text: 'أقوى قرار ممكن تاخده إنك تختار نفسك من غير ما تظلم غيرك.',
        author: 'مجهول',
        category: 'الثقة',
      ),
      Quote(
        text: 'الناس بتشوف النتيجة، وإنت الوحيد اللي عارف ثمنها.',
        author: 'مجهول',
        category: 'النجاح',
      ),
      Quote(
        text: 'مش كل هدوء فراغ، ساعات الهدوء بيكون ترتيب.',
        author: 'مجهول',
        category: 'العقل',
      ),
      Quote(
        text: 'اللي بيخاف يبدأ صغير، هيفضل بعيد عن الكبير.',
        author: 'مجهول',
        category: 'الطموح',
      ),
      Quote(
        text: 'مفيش مشكلة في إنك تغير رأيك لما تتغير معلوماتك.',
        author: 'مجهول',
        category: 'العقل',
      ),
      Quote(
        text: 'القوة مش إنك متقعش، القوة إنك تعرف تقوم.',
        author: 'مجهول',
        category: 'الصمود',
      ),
      Quote(
        text: 'أوقات لازم تخسر نسخة قديمة منك عشان تكسب الجديدة.',
        author: 'مجهول',
        category: 'التغيير',
      ),
      Quote(
        text: 'الهدف الكبير بيتعامل معاه كأنه مجموعة أهداف صغيرة.',
        author: 'مجهول',
        category: 'الطموح',
      ),
      Quote(
        text: 'لو فضلت تبص وراك، مش هتشوف الطريق اللي قدامك.',
        author: 'مجهول',
        category: 'الماضي',
      ),
      Quote(
        text: 'مش كل نقد هجوم، ومش كل مدح حقيقة.',
        author: 'مجهول',
        category: 'الوعي',
      ),
      Quote(
        text: 'اللي يعرف أولوياته، بيقول لأ من غير إحساس بالذنب.',
        author: 'مجهول',
        category: 'التركيز',
      ),
      Quote(
        text: 'الوقت اللي بيروح مش بيرجع، بس اللي جاي لسه في إيدك.',
        author: 'مجهول',
        category: 'الوقت',
      ),
      Quote(
        text: 'أكبر عدو للتقدم هو إنك تفضل مستني اللحظة المثالية.',
        author: 'مجهول',
        category: 'التقدم',
      ),
      Quote(
        text: 'مش لازم تثبت إنك أقوى، كفاية تعرف إمتى تكمل وإمتى تبعد.',
        author: 'مجهول',
        category: 'الحكمة',
      ),
      Quote(
        text: 'اللي بيتعلم يسمع نفسه، بيقل احتياجه لرأي كل الناس.',
        author: 'مجهول',
        category: 'الوعي',
      ),
      Quote(
        text: 'أوقات الطريق الغلط بيعلمك شكل الطريق الصح.',
        author: 'مجهول',
        category: 'التجربة',
      ),
      Quote(
        text: 'مش كل فرصة تستاهل وقتك، حتى لو شكلها مغري.',
        author: 'مجهول',
        category: 'الاختيار',
      ),
      Quote(
        text: 'النجاح اللي مبني على الاستمرار أهدى من النجاح اللي مبني على الحظ.',
        author: 'مجهول',
        category: 'النجاح',
      ),
      Quote(
        text: 'اللي بيتحكم في وقته، بيملك جزء كبير من حياته.',
        author: 'مجهول',
        category: 'الوقت',
      ),
      Quote(
        text: 'لو عرفت إنت ليه بدأت، هتعرف تكمل وقت التعب.',
        author: 'مجهول',
        category: 'الاستمرارية',
      ),
      Quote(
        text: 'مش كل مرة تسكت فيها تبقى ضعيف، ومش كل مرة تتكلم فيها تبقى قوي.',
        author: 'مجهول',
        category: 'الحكمة',
      ),
      Quote(
        text: 'التغيير الحقيقي بيبدأ من قرار محدش شايفه غيرك.',
        author: 'مجهول',
        category: 'التغيير',
      ),
      Quote(
        text: 'اللي بيقيس نفسه بالناس، عمره ما هيشوف تقدمه بوضوح.',
        author: 'مجهول',
        category: 'المقارنة',
      ),
      Quote(
        text: 'مش لازم تكسب كل مرة، المهم تعرف تتعلم كل مرة.',
        author: 'مجهول',
        category: 'التجربة',
      ),
      Quote(
        text: 'أوقات أكبر شجاعة إنك تعترف إنك محتاج تبدأ من جديد.',
        author: 'مجهول',
        category: 'الشجاعة',
      ),
      Quote(
        text: 'اللي بيحاول يرضي الكل، غالبًا بينسى نفسه.',
        author: 'مجهول',
        category: 'الناس',
      ),
      Quote(
        text: 'الهدوء مش معناه إن مفيش مشاكل، معناه إنك مش سايبها تسوقك.',
        author: 'مجهول',
        category: 'العقل',
      ),
      Quote(
        text: 'كل عادة صغيرة بتبني شكل كبير من حياتك.',
        author: 'مجهول',
        category: 'العادات',
      ),
      Quote(
        text: 'مش كل حاجة تستحق طاقتك لمجرد إنها بتستفزك.',
        author: 'مجهول',
        category: 'التركيز',
      ),
      Quote(
        text: 'أوقات أقصر طريق للراحة هو إنك تواجه الحاجة اللي مأجّلها.',
        author: 'مجهول',
        category: 'الشجاعة',
      ),
      Quote(
        text: 'اللي بيهرب من كل وجع، بيفوّت على نفسه دروس كتير.',
        author: 'مجهول',
        category: 'التجربة',
      ),
      Quote(
        text: 'الطريق مش بيطلب منك تكون كامل، بيطلب منك تكون مستمر.',
        author: 'مجهول',
        category: 'الاستمرارية',
      ),
      Quote(
        text: 'أنت مش متأخر، أنت في مرحلة مختلفة.',
        author: 'مجهول',
        category: 'المقارنة',
      ),
      Quote(
        text: 'لما تبطل تخاف من البداية، حاجات كتير بتبقى ممكنة.',
        author: 'مجهول',
        category: 'البداية',
      ),
      Quote(
        text: 'مش كل حاجة ضاعت منك كانت خسارة، بعضها كان عبء.',
        author: 'مجهول',
        category: 'الخسارة',
      ),
      Quote(
        text: 'الطموح محتاج نفس طويل أكتر ما محتاج بداية قوية.',
        author: 'مجهول',
        category: 'الطموح',
      ),
      Quote(
        text: 'القرار اللي بتأجله، لسه بيستهلك منك طاقة.',
        author: 'مجهول',
        category: 'الاختيار',
      ),
      Quote(
        text: 'لو مفيش تقدم، راجع الطريقة قبل ما تحكم على نفسك.',
        author: 'مجهول',
        category: 'التطور',
      ),
      Quote(
        text: 'مش كل سقوط محتاج تفسير، بعضه محتاج تقوم وبس.',
        author: 'مجهول',
        category: 'الصمود',
      ),
      Quote(
        text: 'اللي يعرف قيمته، مش بيبيع راحته عشان تصفيق.',
        author: 'مجهول',
        category: 'الثقة',
      ),
      Quote(
        text: 'أوقات تغيير المكان أسهل من محاولة تغيير كل اللي حواليك.',
        author: 'مجهول',
        category: 'التغيير',
      ),
      Quote(
        text: 'العبرة مش بعدد المرات اللي بدأت فيها، لكن بعدد المرات اللي كملت.',
        author: 'مجهول',
        category: 'الاستمرارية',
      ),
      Quote(
        text: 'مفيش قرار بلا ثمن، اختار الثمن اللي تقدر تعيش معاه.',
        author: 'مجهول',
        category: 'الاختيار',
      ),
      Quote(
        text: 'اللي بيدور على معنى في كل حاجة، بيتعب أقل من اللي بيدور على الكمال.',
        author: 'مجهول',
        category: 'الحياة',
      ),
      Quote(
        text: 'أحيانًا محتاج تبطّل تجري عشان تعرف أنت رايح فين.',
        author: 'مجهول',
        category: 'التأمل',
      ),
      Quote(
        text: 'اللي بتزرعه في وقت محدش شايفك فيه، بيظهر لما الكل يشوفك.',
        author: 'مجهول',
        category: 'العمل',
      ),
      Quote(
        text: 'الفرق بين يوم عادي ويوم مختلف ممكن يكون قرار واحد.',
        author: 'مجهول',
        category: 'القرار',
      ),
      Quote(
        text: 'مش كل حلم لازم يتحقق بنفس الصورة اللي بدأ بيها.',
        author: 'مجهول',
        category: 'الأحلام',
      ),
      Quote(
        text: 'كل مرة تختار فيها تكمل، أنت بتدي لنفسك فرصة جديدة.',
        author: 'مجهول',
        category: 'الأمل',
      ),
      Quote(
        text: 'مش لازم تكون أقوى من كل حاجة، بس متخليش كل حاجة أقوى منك.',
        author: 'مجهول',
        category: 'الصمود',
      ),
      Quote(
        text: 'الناس ممكن تنسى كلامك، بس هتفتكر الطريقة اللي خليتهم يحسوا بيها.',
        author: 'مجهول',
        category: 'الناس',
      ),
      Quote(
        text: 'النجاح مش محطة، كل ما توصل بتكتشف طريق جديد.',
        author: 'مجهول',
        category: 'النجاح',
      ),
      Quote(
        text: 'لما تتعلم تقول لأ، هتبدأ تعرف تقول آه للحاجات المهمة.',
        author: 'مجهول',
        category: 'الاختيار',
      ),
      Quote(
        text: 'أغلب الحواجز اللي بنخاف منها بتكبر في دماغنا قبل ما نواجهها.',
        author: 'مجهول',
        category: 'الخوف',
      ),
      Quote(
        text: 'مش لازم كل يوم تنتصر، كفاية إنك متسيبش نفسك.',
        author: 'مجهول',
        category: 'الصمود',
      ),
      Quote(
        text: 'اللي بيحترم وقته، بيتعلم يحترم نفسه.',
        author: 'مجهول',
        category: 'الوقت',
      ),
      Quote(
        text: 'الحياة مش بتوعدك إنها هتكون سهلة، بس بتديك فرصة تتعلم.',
        author: 'مجهول',
        category: 'الحياة',
      ),
      Quote(
          text: 'مش كل حاجة لازم تحصل دلوقتي عشان تكون في وقتها.',
          author: 'مجهول',
          category: 'الوقت',
        ),
        Quote(
          text: 'أوقات القرار الصعب بيكون أبسط من الاستمرار في حاجة غلط.',
          author: 'مجهول',
          category: 'الاختيار',
        ),
        Quote(
          text: 'اللي بيهرب من البداية عشان خايف يفشل، بيخسر قبل ما يلعب.',
          author: 'مجهول',
          category: 'الخوف',
        ),
        Quote(
          text: 'مش مهم الناس شايفة سرعتك قد إيه، المهم إنك عارف اتجاهك.',
          author: 'مجهول',
          category: 'الطموح',
        ),
        Quote(
          text: 'في حاجات مبتتصلحش بالوقت، بتتصلح بقرار.',
          author: 'مجهول',
          category: 'القرار',
        ),
        Quote(
          text: 'كل مرة بتختار فيها الأسهل، اسأل نفسك لو ده فعلًا اللي يناسبك.',
          author: 'مجهول',
          category: 'الاختيار',
        ),
        Quote(
          text: 'اللي اتعلمته من الأيام الصعبة، محدش يقدر ياخده منك.',
          author: 'مجهول',
          category: 'التجربة',
        ),
        Quote(
          text: 'مش لازم تفهم كل حاجة دلوقتي، بعض الإجابات بتيجي مع الطريق.',
          author: 'مجهول',
          category: 'الحياة',
        ),
        Quote(
          text: 'الهدوء اللي بعد الفوضى بيخليك تشوف حاجات مكنتش شايفها.',
          author: 'مجهول',
          category: 'التأمل',
        ),
        Quote(
          text: 'اللي بيبني نفسه في السر، مش بيحتاج يشرح نفسه في العلن.',
          author: 'مجهول',
          category: 'العمل',
        ),
        Quote(
          text: 'مش كل حد سابقك أحسن منك، يمكن بس بدأ قبلك.',
          author: 'مجهول',
          category: 'المقارنة',
        ),
        Quote(
          text: 'الفرق الحقيقي بيظهر لما الحماس يختفي وتفضل مكمل.',
          author: 'مجهول',
          category: 'الانضباط',
        ),
        Quote(
          text: 'لو كل مرة اتكسرت فيها وقفت، مكنتش هتعرف قوتك.',
          author: 'مجهول',
          category: 'الصمود',
        ),
        Quote(
          text: 'مش كل فرصة ضاعت كانت فرصتك أصلًا.',
          author: 'مجهول',
          category: 'الفرص',
        ),
        Quote(
          text: 'أوقات لازم تخسر وقت عشان تكسب وعي.',
          author: 'مجهول',
          category: 'التجربة',
        ),
        Quote(
          text: 'اللي بيحاول يبقى نسخة من غيره، بينسى يبني نسخته هو.',
          author: 'مجهول',
          category: 'الهوية',
        ),
        Quote(
          text: 'النجاح الحقيقي إنك متبقاش محتاج تصفق لنفسك عشان تكمل.',
          author: 'مجهول',
          category: 'النجاح',
        ),
        Quote(
          text: 'ممكن تغير خطتك من غير ما تتخلى عن هدفك.',
          author: 'مجهول',
          category: 'المرونة',
        ),
        Quote(
          text: 'اللي مش بيتعلم من غلطه، غالبًا بيكرر نفس الدرس.',
          author: 'مجهول',
          category: 'الفشل',
        ),
        Quote(
          text: 'أوقات كلمة لأ بتحمي سنين من حياتك.',
          author: 'مجهول',
          category: 'الاختيار',
        ),
        Quote(
          text: 'الطريق اللي مفيهوش تحدي، غالبًا مش هيغيرك.',
          author: 'مجهول',
          category: 'التطور',
        ),
        Quote(
          text: 'مش لازم كل الناس تصدق في حلمك عشان تبدأه.',
          author: 'مجهول',
          category: 'الأحلام',
        ),
        Quote(
          text: 'كل مرة بتأجل فيها قرار مهم، القرار بيفضل عايش في دماغك.',
          author: 'مجهول',
          category: 'القرار',
        ),
        Quote(
          text: 'الراحة بعد التعب ليها طعم مختلف.',
          author: 'مجهول',
          category: 'العمل',
        ),
        Quote(
          text: 'اللي بيبص للنتيجة بس، عمره ما هيفهم قيمة الرحلة.',
          author: 'مجهول',
          category: 'الرحلة',
        ),
        Quote(
          text: 'مش كل شخص فهمك غلط محتاج تقنعه إنك صح.',
          author: 'مجهول',
          category: 'الناس',
        ),
        Quote(
          text: 'أوقات البعد بيخليك تشوف الصورة كاملة.',
          author: 'مجهول',
          category: 'التأمل',
        ),
        Quote(
          text: 'أنت مش محتاج بداية عظيمة، محتاج بداية حقيقية.',
          author: 'مجهول',
          category: 'البداية',
        ),
        Quote(
          text: 'اللي بيحترم أحلامه، بيحترم الوقت اللي بيحطّه فيها.',
          author: 'مجهول',
          category: 'الأحلام',
        ),
        Quote(
          text: 'مش كل تعب معناه إنك غلط، ساعات معناه إنك بتتقدم.',
          author: 'مجهول',
          category: 'التقدم',
        ),
        Quote(
          text: 'اللي بيخليك تكمل مش دايمًا الأمل، ساعات بيكون العناد الجميل.',
          author: 'مجهول',
          category: 'الصمود',
        ),
        Quote(
          text: 'مفيش حد بيكبر من غير ما يعدي بفترة يحس فيها إنه مش فاهم حاجة.',
          author: 'مجهول',
          category: 'النمو',
        ),
        Quote(
          text: 'لو هدفك مهم، هتلاقي له مكان وسط زحمة يومك.',
          author: 'مجهول',
          category: 'التركيز',
        ),
        Quote(
          text: 'مش كل اللي بيروح من حياتك محتاج ترجعه.',
          author: 'مجهول',
          category: 'الماضي',
        ),
        Quote(
          text: 'أوقات أحسن إجابة على الاستفزاز هي إنك تكمل يومك.',
          author: 'مجهول',
          category: 'النضج',
        ),
        Quote(
          text: 'اللي بيستثمر في نفسه، عمره ما بيطلع خسران.',
          author: 'مجهول',
          category: 'النمو',
        ),
        Quote(
          text: 'مش كل طريق قصير هيوصلك أسرع.',
          author: 'مجهول',
          category: 'الحكمة',
        ),
        Quote(
          text: 'الفرق بين الحلم والخطة إن الخطة ليها موعد.',
          author: 'مجهول',
          category: 'الطموح',
        ),
        Quote(
          text: 'لو مش عاجبك مكانك، أول سؤال تسأله: إيه الخطوة اللي أقدر أعملها؟',
          author: 'مجهول',
          category: 'التغيير',
        ),
        Quote(
          text: 'مش كل خسارة محتاجة حزن طويل، بعضها محتاج فهم.',
          author: 'مجهول',
          category: 'الخسارة',
        ),
        Quote(
          text: 'اللي بيعرف إمتى ينسحب، مش بالضرورة يكون خسران.',
          author: 'مجهول',
          category: 'الحكمة',
        ),
        Quote(
          text: 'أكبر تطور ممكن يحصل إنك تبقى أهدى من نفسك القديمة.',
          author: 'مجهول',
          category: 'النضج',
        ),
        Quote(
          text: 'مش لازم ترد على كل حاجة بتحصل حواليك.',
          author: 'مجهول',
          category: 'الهدوء',
        ),
        Quote(
          text: 'اللي بيدور على المثالية، ممكن يفوّت عليه الشيء الكويس.',
          author: 'مجهول',
          category: 'الواقع',
        ),
        Quote(
          text: 'أوقات النجاح يبدأ من إنك تبطل تعمل حاجة بتأذي مستقبلك.',
          author: 'مجهول',
          category: 'التغيير',
        ),
        Quote(
          text: 'القرار الصح ممكن يخوفك، بس الغلط أوقات بيخوف أكتر بعدين.',
          author: 'مجهول',
          category: 'الشجاعة',
        ),
        Quote(
          text: 'كل عادة بتكررها النهارده بتشارك في تشكيل بكرة.',
          author: 'مجهول',
          category: 'العادات',
        ),
        Quote(
          text: 'اللي بيحافظ على تركيزه، بيكسب وقت أكتر من اللي بيجري أسرع.',
          author: 'مجهول',
          category: 'التركيز',
        ),
        Quote(
          text: 'مش كل حاجة محتاجة سرعة، بعض الحاجات محتاجة دقة.',
          author: 'مجهول',
          category: 'الحكمة',
        ),
        Quote(
          text: 'لما تتصالح مع إنك مش هتعجب الكل، هتعيش أخف.',
          author: 'مجهول',
          category: 'الحرية',
        ),
        Quote(
          text: 'اللي بيتعلم يفرق بين المهم والعاجل، حياته بتتغير.',
          author: 'مجهول',
          category: 'الأولوية',
        ),
        Quote(
          text: 'مش لازم كل خطوة تبقى واضحة عشان تاخدها.',
          author: 'مجهول',
          category: 'الشجاعة',
        ),
        Quote(
          text: 'أوقات البداية الجديدة بتحتاج شجاعة أكتر من البداية الأولى.',
          author: 'مجهول',
          category: 'البدايات',
        ),
        Quote(
          text: 'اللي بيقيس قيمته برأي الناس، بيسلمهم مفتاح مزاجه.',
          author: 'مجهول',
          category: 'الثقة',
        ),
        Quote(
          text: 'مش كل تأخير عقاب، ومش كل سرعة نجاح.',
          author: 'مجهول',
          category: 'الوقت',
        ),
        Quote(
          text: 'الحاجة اللي بتخاف منها ممكن تكون هي الباب اللي مستنيه.',
          author: 'مجهول',
          category: 'الخوف',
        ),
        Quote(
          text: 'مش لازم تبقى أقوى من المشكلة، كفاية تبقى أذكى في التعامل معاها.',
          author: 'مجهول',
          category: 'الحكمة',
        ),
        Quote(
          text: 'اللي يعرف هدفه، بيقدر يتحمل تفاصيل الطريق.',
          author: 'مجهول',
          category: 'الطموح',
        ),
        Quote(
          text: 'بعض الناس درس، وبعض الناس راحة، والقليل منهم الاتنين.',
          author: 'مجهول',
          category: 'الناس',
        ),
        Quote(
          text: 'مش كل علاقة لازم تكمل عشان تكون كان ليها معنى.',
          author: 'مجهول',
          category: 'العلاقات',
        ),
        Quote(
          text: 'الوقت بيكشف معدن الناس أكتر من الكلام.',
          author: 'مجهول',
          category: 'الناس',
        ),
        Quote(
          text: 'لما تبطل تجري ورا كل حاجة، هتعرف إيه اللي يستاهل.',
          author: 'مجهول',
          category: 'التركيز',
        ),
        Quote(
          text: 'مش كل فرصة محتاجة إجابة فورية.',
          author: 'مجهول',
          category: 'الاختيار',
        ),
        Quote(
          text: 'اللي بيشتغل على نفسه، مش بيحتاج يقارن نفسه بحد.',
          author: 'مجهول',
          category: 'النمو',
        ),
        Quote(
          text: 'أوقات أكتر حاجة محتاج تتعلمها هي إنك تستنى.',
          author: 'مجهول',
          category: 'الصبر',
        ),
        Quote(
          text: 'مش كل حاجة بتوجعك لازم تفضل شايلها.',
          author: 'مجهول',
          category: 'التعافي',
        ),
        Quote(
          text: 'اللي حصل حصل، لكن تفسيرك ليه لسه في إيدك.',
          author: 'مجهول',
          category: 'الماضي',
        ),
        Quote(
          text: 'أوقات أنت مش محتاج حل جديد، محتاج تبطل المشكلة القديمة.',
          author: 'مجهول',
          category: 'التغيير',
        ),
        Quote(
          text: 'كل مرة بتختار فيها الانضباط بدل المزاج، أنت بتقرب.',
          author: 'مجهول',
          category: 'الانضباط',
        ),
        Quote(
          text: 'مش كل يوم هتكون في أفضل حال، وده مش معناه إنك واقف.',
          author: 'مجهول',
          category: 'الحياة',
        ),
        Quote(
          text: 'اللي بيتقبل إنه مش عارف كل حاجة، بيتعلم أسرع.',
          author: 'مجهول',
          category: 'التعلم',
        ),
        Quote(
          text: 'الغلط اللي فهمته، أحسن من الصح اللي محصلتش منه حاجة.',
          author: 'مجهول',
          category: 'التجربة',
        ),
        Quote(
          text: 'مش لازم تستنى الإذن عشان تبدأ حاجة أنت مؤمن بيها.',
          author: 'مجهول',
          category: 'الاستقلال',
        ),
        Quote(
          text: 'اللي بيفضل مكانه خوفًا من الخسارة، خسر وقت بالفعل.',
          author: 'مجهول',
          category: 'الخوف',
        ),
        Quote(
          text: 'النجاح ساعات بيبدأ من كلمة واحدة: كفاية.',
          author: 'مجهول',
          category: 'القرار',
        ),
        Quote(
          text: 'مش كل صوت عالي عنده حاجة مهمة يقولها.',
          author: 'مجهول',
          category: 'الوعي',
        ),
        Quote(
          text: 'لما تعرف قيمتك، مش كل باب مقفول هيزعلك.',
          author: 'مجهول',
          category: 'الثقة',
        ),
        Quote(
          text: 'اللي بيبني على أساس ثابت، مش بيخاف من السرعة.',
          author: 'مجهول',
          category: 'النجاح',
        ),
        Quote(
          text: 'كل مرحلة ليها نسخة مختلفة منك، متستعجلش اللي بعدها.',
          author: 'مجهول',
          category: 'النمو',
        ),
        Quote(
          text: 'مش كل حلم محتاج جمهور، بعض الأحلام محتاجة شغل.',
          author: 'مجهول',
          category: 'الأحلام',
        ),
        Quote(
          text: 'اللي بيختار راحته طول الوقت، ممكن يخسر مستقبله بهدوء.',
          author: 'مجهول',
          category: 'الانضباط',
        ),
        Quote(
          text: 'مفيش تغيير حقيقي من غير حاجة قديمة تسيب مكانها.',
          author: 'مجهول',
          category: 'التغيير',
        ),
        Quote(
          text: 'اللي بيحترم نفسه، بيعرف إمتى يبعد.',
          author: 'مجهول',
          category: 'الكرامة',
        ),
        Quote(
          text: 'مش كل صمت رضا، ومش كل كلام اعتراض.',
          author: 'مجهول',
          category: 'الفهم',
        ),
        Quote(
          text: 'أوقات الحل إنك تغير السؤال.',
          author: 'مجهول',
          category: 'التفكير',
        ),
        Quote(
          text: 'لو فضلت مستني ثقة كاملة، عمرك ما هتاخد أول خطوة.',
          author: 'مجهول',
          category: 'الشجاعة',
        ),
        Quote(
          text: 'الثقة بتتبني من الوعود اللي بتوفيها لنفسك.',
          author: 'مجهول',
          category: 'الثقة',
        ),
        Quote(
          text: 'اللي بتعمله كل يوم أهم من اللي بتعمله مرة كل فترة.',
          author: 'مجهول',
          category: 'العادات',
        ),
        Quote(
          text: 'مش كل ضغط محتاج هروب، بعضه محتاج تنظيم.',
          author: 'مجهول',
          category: 'التوازن',
        ),
        Quote(
          text: 'أوقات أبسط قرار بيحل مشكلة معقدة.',
          author: 'مجهول',
          category: 'الحكمة',
        ),
        Quote(
          text: 'اللي يعرف يركز على حاجة واحدة، بيعمل فيها فرق.',
          author: 'مجهول',
          category: 'التركيز',
        ),
        Quote(
          text: 'مش مهم تبدأ منين، المهم متفضلش مكانك.',
          author: 'مجهول',
          category: 'البداية',
        ),
        Quote(
          text: 'كل يوم بتأجل فيه نفسك، بتدفع تمنه بعدين.',
          author: 'مجهول',
          category: 'الوقت',
        ),
        Quote(
          text: 'اللي فات مش محتاج منك تعيش فيه، محتاج تتعلم منه.',
          author: 'مجهول',
          category: 'الماضي',
        ),
        Quote(
          text: 'ممكن تكون مشيت كتير ولسه مش وصلت، وده طبيعي.',
          author: 'مجهول',
          category: 'الصبر',
        ),
        Quote(
          text: 'الناس هتتكلم في كل الأحوال، اختار الحاجة اللي تستاهل كلامهم.',
          author: 'مجهول',
          category: 'الناس',
        ),
        Quote(
          text: 'أوقات أقوى رد هو إن حياتك تكمل من غير ما تتأثر.',
          author: 'مجهول',
          category: 'النضج',
        ),
        Quote(
          text: 'مش كل باب مفتوح فرصة، ومش كل باب مقفول نهاية.',
          author: 'مجهول',
          category: 'الفرص',
        ),
        Quote(
          text: 'الطموح من غير صبر بيتحول لضغط.',
          author: 'مجهول',
          category: 'الطموح',
        ),
        Quote(
          text: 'كل مرة بتواجه حاجة بدل ما تهرب منها، بتصغر في عينك.',
          author: 'مجهول',
          category: 'الشجاعة',
        ),
        Quote(
          text: 'مش لازم تعرف النهاية عشان تستمتع بالخطوة.',
          author: 'مجهول',
          category: 'الرحلة',
        ),
        Quote(
          text: 'اللي بيحافظ على مبادئه وقت الضغط، يعرف نفسه أكتر.',
          author: 'مجهول',
          category: 'المبادئ',
        ),
        Quote(
          text: 'أوقات الخطة الأفضل هي إنك تبدأ وبعدين تعدل.',
          author: 'مجهول',
          category: 'البداية',
        ),
        Quote(
          text: 'مش كل حاجة اتكسرت لازم ترجع زي الأول.',
          author: 'مجهول',
          category: 'التغيير',
        ),
        Quote(
          text: 'اللي بيستنى تقدير الناس، ممكن ينسى يقدّر نفسه.',
          author: 'مجهول',
          category: 'الثقة',
        ),
        Quote(
          text: 'المستقبل مش مضمون، وده سبب كفاية إنك تبدأ.',
          author: 'مجهول',
          category: 'الأمل',
        ),
        Quote(
          text: 'مش كل يوم محتاج إنجاز كبير، بعض الأيام محتاجة بس تعدي بسلام.',
          author: 'مجهول',
          category: 'التوازن',
        ),
        Quote(
          text: 'اللي بيقارن نفسه بأمس، عنده فرصة يشوف تقدمه بوضوح.',
          author: 'مجهول',
          category: 'التطور',
        ),
        Quote(
          text: 'لو حاجة مهمة بالنسبالك، متخليش يوم وحش يقرر مصيرها.',
          author: 'مجهول',
          category: 'الاستمرارية',
        ),
        Quote(
          text: 'أوقات التخلي عن حاجة هو أول خطوة ناحية نفسك.',
          author: 'مجهول',
          category: 'الحرية',
        ),
        Quote(
          text: 'مش كل حاجة تستحق تفسير، وبعض النهايات بتشرح نفسها.',
          author: 'مجهول',
          category: 'الحكمة',
        ),
        Quote(
          text: 'اللي بيقبل إنه يبدأ من الصفر، عمره ما بيخاف من النهاية.',
          author: 'مجهول',
          category: 'البدايات',
        ),
        Quote(
          text: 'العلم مش بكثرة اللي تعرفه، لكن بقدرتك تعمل بيه.',
          author: 'الإمام الشافعي',
          category: 'العلم',
        ),
        Quote(
          text: 'كل ما اتعلمت أكتر، اكتشفت قد إيه لسه محتاج تتعلم.',
          author: 'الإمام الشافعي',
          category: 'التواضع',
        ),
        Quote(
          text: 'العقل اللي بيسأل، أقرب للحقيقة من العقل اللي فاكر إنه عارف كل حاجة.',
          author: 'الإمام الشافعي',
          category: 'العقل',
        ),
        Quote(
          text: 'الوقت أغلى من إنك تضيعه في حاجة ملهاش قيمة.',
          author: 'الإمام الشافعي',
          category: 'الوقت',
        ),
        Quote(
          text: 'الأخلاق مش كلام يتقال، الأخلاق حاجة بتبان وقت الاختبار.',
          author: 'الإمام الشافعي',
          category: 'الأخلاق',
        ),
        Quote(
          text: 'الاختلاف في الرأي مش لازم يفسد الاحترام.',
          author: 'الإمام الشافعي',
          category: 'الاختلاف',
        ),
        Quote(
          text: 'اللي يعرف قدر نفسه، مش محتاج يقلل من غيره.',
          author: 'الإمام علي بن أبي طالب',
          category: 'الحكمة',
        ),
        Quote(
          text: 'العلم من غير عمل يفضل معرفة ناقصة.',
          author: 'الإمام علي بن أبي طالب',
          category: 'العلم',
        ),
        Quote(
          text: 'أقوى الناس مش اللي يغلب غيره، لكن اللي يقدر يتحكم في نفسه.',
          author: 'الإمام علي بن أبي طالب',
          category: 'القوة',
        ),
        Quote(
          text: 'كلامك بيمثل عقلك، فاختار كلامك قبل ما تختاره الناس عنك.',
          author: 'الإمام علي بن أبي طالب',
          category: 'الكلام',
        ),
        Quote(
          text: 'الإنسان بيتعرف في وقت الشدة أكتر من وقت الراحة.',
          author: 'الإمام علي بن أبي طالب',
          category: 'الشدة',
        ),
        Quote(
          text: 'الناس أعداء اللي يجهلوه، فافهم قبل ما تحكم.',
          author: 'الإمام علي بن أبي طالب',
          category: 'الفهم',
        ),
        Quote(
          text: 'التواضع مش ضعف، التواضع إنك تعرف إن عندك دايمًا حاجة تتعلمها.',
          author: 'الحسن البصري',
          category: 'التواضع',
        ),
        Quote(
          text: 'الدنيا فرصة للعمل، مش مكان للركون.',
          author: 'الحسن البصري',
          category: 'العمل',
        ),
        Quote(
          text: 'راجع نفسك قبل ما تراجع غيرك.',
          author: 'الحسن البصري',
          category: 'النفس',
        ),
        Quote(
          text: 'الإنسان العاقل بيتعلم من أيامه قبل ما يلومها.',
          author: 'الحسن البصري',
          category: 'التجربة',
        ),
        Quote(
          text: 'القلب اللي متعلق بالمظاهر بيفوّت عليه المعنى.',
          author: 'الحسن البصري',
          category: 'الحياة',
        ),
        Quote(
          text: 'الزهد مش إنك تسيب الدنيا، لكن إن الدنيا متبقاش مالكة قلبك.',
          author: 'الحسن البصري',
          category: 'الحياة',
        ),
        Quote(
          text: 'الصبر مش انتظار ساكت، الصبر استمرار رغم صعوبة الطريق.',
          author: 'عمر بن الخطاب',
          category: 'الصبر',
        ),
        Quote(
          text: 'حاسب نفسك قبل ما تتحاسب.',
          author: 'عمر بن الخطاب',
          category: 'النفس',
        ),
        Quote(
          text: 'العدل أساس إن الناس تثق في اللي بيحكم بينهم.',
          author: 'عمر بن الخطاب',
          category: 'العدل',
        ),
        Quote(
          text: 'القوة من غير عدل تتحول لظلم.',
          author: 'عمر بن الخطاب',
          category: 'العدل',
        ),
        Quote(
          text: 'الإنسان بيتغير لما يعترف إنه محتاج يتغير.',
          author: 'عمر بن الخطاب',
          category: 'التغيير',
        ),
        Quote(
          text: 'اسأل قبل ما تحكم، وافهم قبل ما تتكلم.',
          author: 'عمر بن الخطاب',
          category: 'الفهم',
        ),
        Quote(
          text: 'النية الصادقة بتدي للعمل قيمة أكبر من شكله.',
          author: 'عمر بن الخطاب',
          category: 'النية',
        ),
        Quote(
          text: 'الصدق ممكن يكون صعب في البداية، لكنه أوضح طريق في النهاية.',
          author: 'أبو بكر الصديق',
          category: 'الصدق',
        ),
        Quote(
          text: 'الرحمة مش تنازل عن القوة، الرحمة دليل على ضبطها.',
          author: 'أبو بكر الصديق',
          category: 'الرحمة',
        ),
        Quote(
          text: 'المسؤولية تبدأ لما تبطل تدور على مين تلومه.',
          author: 'أبو بكر الصديق',
          category: 'المسؤولية',
        ),
        Quote(
          text: 'الحق مش بيتحدد بعدد اللي واقفين معاه.',
          author: 'أبو بكر الصديق',
          category: 'الحق',
        ),
        Quote(
          text: 'الثبات وقت التغيير من أصعب أشكال القوة.',
          author: 'أبو بكر الصديق',
          category: 'الثبات',
        ),
        Quote(
          text: 'الإنسان الكريم يفضل كريم حتى لما يقدر ينتقم.',
          author: 'عثمان بن عفان',
          category: 'الأخلاق',
        ),
        Quote(
          text: 'الحياء مش خوف، لكنه احترام للنفس وللناس.',
          author: 'عثمان بن عفان',
          category: 'الأخلاق',
        ),
        Quote(
          text: 'القرآن مش مجرد كلام يتقرأ، لكنه معنى يتعاش.',
          author: 'عثمان بن عفان',
          category: 'الإيمان',
        ),
        Quote(
          text: 'الخير اللي تعمله في هدوء ممكن يعيش أطول من الكلام عنه.',
          author: 'عثمان بن عفان',
          category: 'العمل',
        ),
        Quote(
          text: 'الصبر بيخلي الإنسان يشوف النهاية من غير ما يستعجلها.',
          author: 'الإمام أحمد بن حنبل',
          category: 'الصبر',
        ),
        Quote(
          text: 'الثبات على المبدأ بيظهر لما المبدأ يبقى مكلف.',
          author: 'الإمام أحمد بن حنبل',
          category: 'الثبات',
        ),
        Quote(
          text: 'العلم الحقيقي بيخليك أكثر تواضعًا، مش أكثر غرورًا.',
          author: 'الإمام أحمد بن حنبل',
          category: 'العلم',
        ),
        Quote(
          text: 'الحق مش محتاج تزويق عشان يبقى حق.',
          author: 'الإمام أحمد بن حنبل',
          category: 'الحق',
        ),
        Quote(
          text: 'التعلم رحلة عمر، مش مرحلة وتنتهي.',
          author: 'الإمام البخاري',
          category: 'العلم',
        ),
        Quote(
          text: 'الدقة في نقل المعرفة جزء من الأمانة.',
          author: 'الإمام البخاري',
          category: 'الأمانة',
        ),
        Quote(
          text: 'المعلومة اللي مش متأكد منها، الأفضل متحولهاش لحقيقة.',
          author: 'الإمام البخاري',
          category: 'المعرفة',
        ),
        Quote(
          text: 'الاجتهاد في طلب العلم محتاج صبر أكتر من الذكاء.',
          author: 'الإمام البخاري',
          category: 'التعلم',
        ),
        Quote(
          text: 'العلم من غير أمانة ممكن يبقى عبء بدل ما يكون نفع.',
          author: 'الإمام مسلم',
          category: 'الأمانة',
        ),
        Quote(
          text: 'الحقيقة تستحق إنك تتأكد منها قبل ما تنقلها.',
          author: 'الإمام مسلم',
          category: 'الحقيقة',
        ),
        Quote(
          text: 'الاختلاف في التفاصيل لا يلغي قيمة البحث عن الحقيقة.',
          author: 'الإمام مسلم',
          category: 'البحث',
        ),
        Quote(
          text: 'المعرفة مسؤولية قبل ما تكون ميزة.',
          author: 'الإمام مسلم',
          category: 'المعرفة',
        ),
        Quote(
          text: 'النية بتفرق بين فعل شكله واحد ومعناه مختلف.',
          author: 'الإمام النووي',
          category: 'النية',
        ),
        Quote(
          text: 'القليل المستمر أبقى من الكثير المنقطع.',
          author: 'الإمام النووي',
          category: 'الاستمرارية',
        ),
        Quote(
          text: 'العلم محتاج إخلاص زي ما محتاج ذكاء.',
          author: 'الإمام النووي',
          category: 'العلم',
        ),
        Quote(
          text: 'الوقت رأس مال الإنسان الحقيقي.',
          author: 'الإمام النووي',
          category: 'الوقت',
        ),
        Quote(
          text: 'من عرف نفسه عرف حدودها، وعرف فين يحتاج يتعلم.',
          author: 'ابن تيمية',
          category: 'النفس',
        ),
        Quote(
          text: 'الحرية الحقيقية مش إنك تعمل كل اللي نفسك فيه.',
          author: 'ابن تيمية',
          category: 'الحرية',
        ),
        Quote(
          text: 'الصبر على الحق أصعب من معرفته.',
          author: 'ابن تيمية',
          category: 'الصبر',
        ),
        Quote(
          text: 'العقل السليم بيبحث عن الدليل قبل الحكم.',
          author: 'ابن تيمية',
          category: 'العقل',
        ),
        Quote(
          text: 'الإنسان محتاج يراجع نفسه زي ما بيراجع أفكاره.',
          author: 'ابن تيمية',
          category: 'المراجعة',
        ),
        Quote(
          text: 'الاختلاف لا يمنع إنك تتعامل بعدل.',
          author: 'ابن تيمية',
          category: 'العدل',
        ),
        Quote(
          text: 'التاريخ مش مجرد حكايات، التاريخ تجارب بشرية.',
          author: 'ابن خلدون',
          category: 'التاريخ',
        ),
        Quote(
          text: 'الخبر محتاج عقل يفهمه قبل ما يصدقه.',
          author: 'ابن خلدون',
          category: 'التفكير',
        ),
        Quote(
          text: 'العمران بيتغير لما تتغير عادات الناس.',
          author: 'ابن خلدون',
          category: 'المجتمع',
        ),
        Quote(
          text: 'التعليم الحقيقي مش حشو معلومات، لكنه بناء قدرة على الفهم.',
          author: 'ابن خلدون',
          category: 'التعليم',
        ),
        Quote(
          text: 'الدول والمجتمعات لها دورات من القوة والضعف.',
          author: 'ابن خلدون',
          category: 'التاريخ',
        ),
        Quote(
          text: 'الإنسان ابن بيئته، لكنه يقدر يشارك في تغييرها.',
          author: 'ابن خلدون',
          category: 'المجتمع',
        ),
        Quote(
          text: 'العادة لما تتكرر، ممكن تتحول لحاجة الناس تفتكرها طبيعية.',
          author: 'ابن خلدون',
          category: 'العادات',
        ),
        Quote(
          text: 'العلم محتاج نظر في الواقع، مش حفظ للكلام بس.',
          author: 'ابن خلدون',
          category: 'العلم',
        ),
        Quote(
          text: 'اللغة وسيلة للفهم، وكل ما دقت زاد وضوح المعنى.',
          author: 'ابن خلدون',
          category: 'اللغة',
        ),
        Quote(
          text: 'الإنسان اجتماعي بطبيعته، وقوته في تعاونه مع غيره.',
          author: 'ابن خلدون',
          category: 'المجتمع',
        ),
        Quote(
          text: 'الاختلاف بين الناس جزء من طبيعة العمران.',
          author: 'ابن خلدون',
          category: 'الناس',
        ),
        Quote(
          text: 'الفكر اللي مبيختبرش نفسه ممكن يتحول لعادات.',
          author: 'أبو حامد الغزالي',
          category: 'الفكر',
        ),
        Quote(
          text: 'العلم من غير تهذيب للنفس ممكن يزيد الغرور.',
          author: 'أبو حامد الغزالي',
          category: 'الأخلاق',
        ),
        Quote(
          text: 'معرفة النفس بداية لفهم حاجات كتير حواليك.',
          author: 'أبو حامد الغزالي',
          category: 'النفس',
        ),
        Quote(
          text: 'مش كل اللي يلمع في العقل حقيقة، لازم تختبره.',
          author: 'أبو حامد الغزالي',
          category: 'التفكير',
        ),
        Quote(
          text: 'القناعة مش معناها إنك تبطل تطمح.',
          author: 'أبو حامد الغزالي',
          category: 'القناعة',
        ),
        Quote(
          text: 'القلب والعقل محتاجين توازن عشان الإنسان يستقيم.',
          author: 'أبو حامد الغزالي',
          category: 'التوازن',
        ),
        Quote(
          text: 'البحث عن الحقيقة محتاج شجاعة تقبل إنك ممكن تكون غلط.',
          author: 'أبو حامد الغزالي',
          category: 'الحقيقة',
        ),
        Quote(
          text: 'الحكمة إنك تعرف إمتى تتكلم وإمتى تسكت.',
          author: 'جلال الدين الرومي',
          category: 'الحكمة',
        ),
        Quote(
          text: 'اللي بتبحث عنه برا، ممكن تكتشف جزء منه جواك.',
          author: 'جلال الدين الرومي',
          category: 'النفس',
        ),
        Quote(
          text: 'الألم ممكن يفتح باب لفهم جديد.',
          author: 'جلال الدين الرومي',
          category: 'التجربة',
        ),
        Quote(
          text: 'القلب اللي بيتعلم من التجربة مش هو نفس القلب اللي بدأها.',
          author: 'جلال الدين الرومي',
          category: 'النمو',
        ),
        Quote(
          text: 'الطريق بيتغير، لكن البحث عن المعنى هو اللي بيكمل.',
          author: 'جلال الدين الرومي',
          category: 'الحياة',
        ),
        Quote(
          text: 'الحب الحقيقي يبدأ من الرحمة والفهم.',
          author: 'جلال الدين الرومي',
          category: 'الرحمة',
        ),
        Quote(
          text: 'الصمت أوقات بيقول حاجة الكلام مش قادر يقولها.',
          author: 'جلال الدين الرومي',
          category: 'الصمت',
        ),
        Quote(
          text: 'الإنسان بيتغير لما تتغير نظرته لنفسه.',
          author: 'جلال الدين الرومي',
          category: 'التغيير',
        ),
        Quote(
          text: 'العمل الصغير بإخلاص ممكن يبقى أعظم من عمل كبير بلا معنى.',
          author: 'ابن القيم',
          category: 'العمل',
        ),
        Quote(
          text: 'القلب محتاج رعاية زي ما العقل محتاج معرفة.',
          author: 'ابن القيم',
          category: 'النفس',
        ),
        Quote(
          text: 'العادة تبدأ صغيرة، وبعدها ممكن تتحول لطبع.',
          author: 'ابن القيم',
          category: 'العادات',
        ),
        Quote(
          text: 'الصبر مش غياب الألم، لكنه القدرة على الاستمرار رغم الألم.',
          author: 'ابن القيم',
          category: 'الصبر',
        ),
        Quote(
          text: 'الإنسان بيقوى لما يعرف نفسه ويضبطها.',
          author: 'ابن القيم',
          category: 'النفس',
        ),
        Quote(
          text: 'الوقت اللي يضيع مش بيرجع، فاختار فين تحطه.',
          author: 'ابن القيم',
          category: 'الوقت',
        ),
        Quote(
          text: 'النية هي البوصلة اللي بتحدد قيمة الطريق.',
          author: 'ابن القيم',
          category: 'النية',
        ),
        Quote(
          text: 'العلم اللي يغير سلوكك أهم من العلم اللي يزود كلامك.',
          author: 'ابن القيم',
          category: 'العلم',
        ),
        Quote(
          text: 'التجربة بتعلم الإنسان حاجات الكتب أوقات مبتوصلهاش.',
          author: 'ابن بطوطة',
          category: 'التجربة',
        ),
        Quote(
          text: 'السفر بيغير نظرتك لما كنت فاكره ثابت.',
          author: 'ابن بطوطة',
          category: 'السفر',
        ),
        Quote(
          text: 'كل مكان له قصة، وكل شعب له طريقته في الحياة.',
          author: 'ابن بطوطة',
          category: 'التاريخ',
        ),
        Quote(
          text: 'المعرفة مش مكان واحد، المعرفة في كل تجربة.',
          author: 'ابن بطوطة',
          category: 'المعرفة',
        ),
        Quote(
          text: 'الطريق الطويل بيكشف الإنسان لنفسه.',
          author: 'ابن بطوطة',
          category: 'الرحلة',
        ),
        Quote(
          text: 'العالم أوسع من الصورة اللي شايفها من مكانك.',
          author: 'ابن بطوطة',
          category: 'الحياة',
        ),

        // =========================
        // أعلام مصر والتاريخ المصري
        // =========================

        Quote(
          text: 'المصري القديم ترك أثره لأنه آمن إن العمل يعيش أطول من صاحبه.',
          author: 'مستوحاة من الحضارة المصرية القديمة',
          category: 'الأثر',
        ),
        Quote(
          text: 'اللي يبني حاجة للسنين، لازم يفكر أبعد من يومه.',
          author: 'مستوحاة من الحضارة المصرية القديمة',
          category: 'البناء',
        ),
        Quote(
          text: 'الحضارات بتفضل عايشة لما تسيب علم وفن وأثر.',
          author: 'مستوحاة من الحضارة المصرية القديمة',
          category: 'الحضارة',
        ),
        Quote(
          text: 'المعرفة كانت جزء من قوة مصر القديمة.',
          author: 'مستوحاة من الحضارة المصرية القديمة',
          category: 'المعرفة',
        ),
        Quote(
          text: 'اللي يعرف قيمة تاريخه، بيبقى أقدر يبني مستقبله.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التاريخ',
        ),
        Quote(
          text: 'الأثر الحقيقي مش في عمر صاحبه، لكن في عمر اللي سابه وراه.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الأثر',
        ),
        Quote(
          text: 'العلم والفن والعمارة كلهم طرق الإنسان بيحكي بيها عن نفسه.',
          author: 'مستوحاة من الحضارة المصرية',
          category: 'الحضارة',
        ),
        Quote(
          text: 'الحضارة مش مباني بس، الحضارة طريقة تفكير.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الحضارة',
        ),
        Quote(
          text: 'اللي بيبني للمستقبل، لازم يحترم اللي اتبنى قبله.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التاريخ',
        ),
        Quote(
          text: 'التاريخ المصري طويل لأنه عرف يتغير من غير ما يفقد جذوره.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التغيير',
        ),

        Quote(
          text: 'العلم كان دايمًا واحد من أهم أسباب تقدم الحضارات.',
          author: 'أحمد زويل',
          category: 'العلم',
        ),
        Quote(
          text: 'الطريق للإنجاز محتاج شغف ومعرفة وصبر.',
          author: 'أحمد زويل',
          category: 'النجاح',
        ),
        Quote(
          text: 'المستقبل بيتبني بالعلم مش بالتمني.',
          author: 'أحمد زويل',
          category: 'المستقبل',
        ),
        Quote(
          text: 'لما تجمع بين الخيال والعلم، ممكن تشوف احتمالات جديدة.',
          author: 'أحمد زويل',
          category: 'الإبداع',
        ),
        Quote(
          text: 'الفضول العلمي هو بداية أسئلة كتير مهمة.',
          author: 'أحمد زويل',
          category: 'الفضول',
        ),
        Quote(
          text: 'العلم قيمة أكبر لما يتحول لنفع للناس.',
          author: 'أحمد زويل',
          category: 'العلم',
        ),
        Quote(
          text: 'الإنجاز الحقيقي محتاج سنين من العمل، مش لحظة واحدة.',
          author: 'أحمد زويل',
          category: 'العمل',
        ),
        Quote(
          text: 'الفشل في تجربة مش معناه فشل الفكرة كلها.',
          author: 'أحمد زويل',
          category: 'الفشل',
        ),
        Quote(
          text: 'المعرفة بتوسع حدود اللي ممكن تتخيله.',
          author: 'أحمد زويل',
          category: 'المعرفة',
        ),
        Quote(
          text: 'الإنسان بيكبر لما يفضل عنده أسئلة.',
          author: 'أحمد زويل',
          category: 'التعلم',
        ),

        Quote(
          text: 'الجهل مش نقص معلومات بس، أوقات بيكون رفض للتفكير.',
          author: 'طه حسين',
          category: 'التفكير',
        ),
        Quote(
          text: 'التعليم وسيلة إن الإنسان يوسع اختياراته في الحياة.',
          author: 'طه حسين',
          category: 'التعليم',
        ),
        Quote(
          text: 'العقل محتاج حرية عشان يقدر يسأل بصدق.',
          author: 'طه حسين',
          category: 'الفكر',
        ),
        Quote(
          text: 'الشك في الفكرة ممكن يكون بداية الوصول للحقيقة.',
          author: 'طه حسين',
          category: 'الحقيقة',
        ),
        Quote(
          text: 'الثقافة مش حفظ كتب، الثقافة طريقة تشوف بيها العالم.',
          author: 'طه حسين',
          category: 'الثقافة',
        ),
        Quote(
          text: 'المجتمع اللي يهمل التعليم بيأجل مستقبله.',
          author: 'طه حسين',
          category: 'التعليم',
        ),
        Quote(
          text: 'الاختلاف الفكري جزء من حياة العقل.',
          author: 'طه حسين',
          category: 'الفكر',
        ),
        Quote(
          text: 'المعرفة بتدي الإنسان قدرة أكبر على الاختيار.',
          author: 'طه حسين',
          category: 'المعرفة',
        ),
        Quote(
          text: 'التراث قيمته في إننا نفهمه، مش بس نقدسه أو نرفضه.',
          author: 'طه حسين',
          category: 'التراث',
        ),
        Quote(
          text: 'السؤال الصعب أحيانًا أهم من الإجابة السهلة.',
          author: 'طه حسين',
          category: 'التفكير',
        ),

        Quote(
          text: 'الحياة عند نجيب محفوظ كانت دايمًا مليانة شخصيات وتجارب متناقضة.',
          author: 'نجيب محفوظ',
          category: 'الحياة',
        ),
        Quote(
          text: 'الإنسان بيتشكل من اختياراته ومن الظروف اللي بيعيشها.',
          author: 'نجيب محفوظ',
          category: 'الاختيار',
        ),
        Quote(
          text: 'التغيير في حياة الإنسان ممكن يبدأ من تفصيلة صغيرة.',
          author: 'نجيب محفوظ',
          category: 'التغيير',
        ),
        Quote(
          text: 'الناس مش أبيض وأسود، وكل شخصية وراها حكاية.',
          author: 'نجيب محفوظ',
          category: 'الناس',
        ),
        Quote(
          text: 'المدينة بتكشف الإنسان زي ما الإنسان بيكشف المدينة.',
          author: 'نجيب محفوظ',
          category: 'المجتمع',
        ),
        Quote(
          text: 'الزمن بيغير الناس، لكن بعض الذكريات بتفضل.',
          author: 'نجيب محفوظ',
          category: 'الزمن',
        ),
        Quote(
          text: 'الإنسان ممكن يعيش صراع كبير بين اللي يتمناه واللي يقدر عليه.',
          author: 'نجيب محفوظ',
          category: 'الحياة',
        ),
        Quote(
          text: 'الضعف والقوة ممكن يعيشوا جوه نفس الشخص.',
          author: 'نجيب محفوظ',
          category: 'النفس',
        ),
        Quote(
          text: 'التاريخ مش بعيد عن الإنسان، التاريخ موجود في اختياراته.',
          author: 'نجيب محفوظ',
          category: 'التاريخ',
        ),
        Quote(
          text: 'كل شخصية لها زاوية مختلفة للحقيقة.',
          author: 'نجيب محفوظ',
          category: 'الحقيقة',
        ),

        Quote(
          text: 'العقل اللي بيتعود يسأل، صعب يرجع يرضى بالإجابات الجاهزة.',
          author: 'عباس محمود العقاد',
          category: 'العقل',
        ),
        Quote(
          text: 'القراءة بتفتح للإنسان عوالم أكتر من عمره.',
          author: 'عباس محمود العقاد',
          category: 'القراءة',
        ),
        Quote(
          text: 'قوة الشخصية بتظهر لما الإنسان يقدر يفكر بنفسه.',
          author: 'عباس محمود العقاد',
          category: 'الشخصية',
        ),
        Quote(
          text: 'الفكرة القوية مش محتاجة ضجيج عشان يكون ليها أثر.',
          author: 'عباس محمود العقاد',
          category: 'الفكر',
        ),
        Quote(
          text: 'المعرفة من غير تفكير ممكن تتحول لحفظ فقط.',
          author: 'عباس محمود العقاد',
          category: 'المعرفة',
        ),
        Quote(
          text: 'الإنسان بيصنع شخصيته من عاداته ومواقفه.',
          author: 'عباس محمود العقاد',
          category: 'الشخصية',
        ),
        Quote(
          text: 'القراءة مش هروب من الواقع، ممكن تكون طريقة لفهمه.',
          author: 'عباس محمود العقاد',
          category: 'القراءة',
        ),
        Quote(
          text: 'الاستقلال في التفكير مسؤولية قبل ما يكون حرية.',
          author: 'عباس محمود العقاد',
          category: 'الحرية',
        ),
        Quote(
          text: 'الإنسان اللي يعرف قيمة عقله مش بيسلمه لأي فكرة.',
          author: 'عباس محمود العقاد',
          category: 'العقل',
        ),
        Quote(
          text: 'الفكر محتاج شجاعة زي ما محتاج معرفة.',
          author: 'عباس محمود العقاد',
          category: 'الشجاعة',
        ),

        Quote(
          text: 'المستقبل مش هدية، المستقبل نتيجة لاختيارات الحاضر.',
          author: 'مصطفى محمود',
          category: 'المستقبل',
        ),
        Quote(
          text: 'رحلة الإنسان للمعنى أهم من جمع الإجابات السريعة.',
          author: 'مصطفى محمود',
          category: 'المعنى',
        ),
        Quote(
          text: 'العلم بيكشف لنا العالم، والتأمل بيخلينا نسأل عن معناه.',
          author: 'مصطفى محمود',
          category: 'العلم',
        ),
        Quote(
          text: 'الإنسان ممكن يملك حاجات كتير ولسه يدور على معنى.',
          author: 'مصطفى محمود',
          category: 'الحياة',
        ),
        Quote(
          text: 'السؤال الصادق أحيانًا بداية رحلة طويلة.',
          author: 'مصطفى محمود',
          category: 'التفكير',
        ),
        Quote(
          text: 'العقل محتاج تواضع عشان يعرف حدوده.',
          author: 'مصطفى محمود',
          category: 'التواضع',
        ),
        Quote(
          text: 'الإيمان عند الإنسان مش مجرد معرفة، لكنه تجربة داخلية.',
          author: 'مصطفى محمود',
          category: 'الإيمان',
        ),
        Quote(
          text: 'الإنسان بيتغير لما تتغير نظرته لنفسه وللعالم.',
          author: 'مصطفى محمود',
          category: 'التغيير',
        ),
        Quote(
          text: 'الحياة مليانة أسئلة، ومش لازم كل سؤال له إجابة فورية.',
          author: 'مصطفى محمود',
          category: 'الحياة',
        ),
        Quote(
          text: 'البحث المستمر أحسن من الاطمئنان لإجابة ناقصة.',
          author: 'مصطفى محمود',
          category: 'المعرفة',
        ),

        Quote(
          text: 'مصر كانت دايمًا مساحة للتنوع والتفاعل بين أفكار وثقافات مختلفة.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الحضارة',
        ),
        Quote(
          text: 'التاريخ المصري اتبنى على طبقات كتير، وكل طبقة سابت أثر.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التاريخ',
        ),
        Quote(
          text: 'اللي يقرأ تاريخ مصر كويس يعرف إن التغيير جزء من طبيعتها.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التغيير',
        ),
        Quote(
          text: 'النيل كان دايمًا أكتر من نهر؛ كان جزء من حياة المصريين.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'مصر',
        ),
        Quote(
          text: 'الحضارة المصرية علمتنا إن الاستمرار محتاج تنظيم وصبر.',
          author: 'مستوحاة من الحضارة المصرية القديمة',
          category: 'الاستمرارية',
        ),
        Quote(
          text: 'الآثار بتفضل تتكلم حتى بعد ما أصحابها يمشوا.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الأثر',
        ),
        Quote(
          text: 'الزمن بيغير شكل الحضارات، لكن آثارها بتفضل شاهدة.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الزمن',
        ),
        Quote(
          text: 'التاريخ مش بس انتصارات، التاريخ كمان أخطاء بنتعلم منها.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التاريخ',
        ),
        Quote(
          text: 'كل جيل بيضيف صفحة جديدة في قصة المكان.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الأجيال',
        ),
        Quote(
          text: 'الحضارة اللي تعرف تتعلم من ماضيها عندها فرصة تبني أحسن.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التعلم',
        ),

        Quote(
          text: 'العمل اللي فيه معنى بيعيش أطول من صاحبه.',
          author: 'مستوحاة من تراث مصر الثقافي',
          category: 'الأثر',
        ),
        Quote(
          text: 'الفن مش رفاهية، الفن طريقة الإنسان يحفظ بيها ذاكرته.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الفن',
        ),
        Quote(
          text: 'الكتاب ممكن يحفظ زمن كامل من الضياع.',
          author: 'مستوحاة من التراث المصري',
          category: 'القراءة',
        ),
        Quote(
          text: 'اللغة بتشيل ذاكرة أجيال كاملة.',
          author: 'مستوحاة من التراث المصري',
          category: 'اللغة',
        ),
        Quote(
          text: 'التعليم هو الطريقة اللي كل جيل بيسلم بيها خبرته للي بعده.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التعليم',
        ),
        Quote(
          text: 'المعرفة لما تنتقل بين الأجيال بتكبر بدل ما تنتهي.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'المعرفة',
        ),
        Quote(
          text: 'اللي يحافظ على تراثه مش بيرجع للماضي، بيحافظ على ذاكرته.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التراث',
        ),
        Quote(
          text: 'التاريخ بيكبر لما يتحول من ذكرى إلى درس.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التاريخ',
        ),
        Quote(
          text: 'كل حضارة عظيمة وراها ناس اشتغلوا قبل ما الناس تعرف أسماءهم.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'العمل',
        ),
        Quote(
          text: 'الأثر الحقيقي مش لازم يحمل اسم صاحبه عشان يفضل موجود.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الأثر',
        ),

        Quote(
          text: 'الإنسان المصري عرف عبر تاريخه إن النهوض محتاج مشاركة أكتر من فرد.',
          author: 'مستوحاة من التاريخ المصري الحديث',
          category: 'المجتمع',
        ),
        Quote(
          text: 'الأوطان بتكبر لما العلم والعمل يبقوا جزء من ثقافتها.',
          author: 'مستوحاة من التاريخ المصري الحديث',
          category: 'العمل',
        ),
        Quote(
          text: 'التقدم مش لحظة، التقدم سلسلة محاولات.',
          author: 'مستوحاة من التاريخ المصري الحديث',
          category: 'التقدم',
        ),
        Quote(
          text: 'كل جيل عنده تحدياته، لكن عليه كمان مسؤولية تجاه اللي بعده.',
          author: 'مستوحاة من التاريخ المصري الحديث',
          category: 'المسؤولية',
        ),
        Quote(
          text: 'البلد مش مجرد مكان، البلد ذاكرة وناس ومستقبل.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الوطن',
        ),
        Quote(
          text: 'الاختلاف في المجتمع ممكن يبقى مصدر قوة لما يتحول لحوار.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الاختلاف',
        ),
        Quote(
          text: 'التاريخ يعلمنا إن مفيش مرحلة بتفضل ثابتة للأبد.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التغيير',
        ),
        Quote(
          text: 'الإنجاز اللي يخدم ناس أكتر، أثره بيكون أوسع.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'العمل',
        ),
        Quote(
          text: 'المعرفة اللي بتوصل للناس بتتحول من إنجاز فردي لأثر عام.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'المعرفة',
        ),
        Quote(
          text: 'مصر اتغيرت كتير، وده جزء من قصتها مش خروج عنها.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التغيير',
        ),

        Quote(
          text: 'الإنسان اللي يعرف جذوره مش لازم يعيش فيها، لكنه يقدر يفهم نفسه أكتر.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الهوية',
        ),
        Quote(
          text: 'الماضي مش مكان نعيش فيه، لكنه مصدر نتعلم منه.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الماضي',
        ),
        Quote(
          text: 'كل حضارة بتسيب أسئلة للأجيال اللي بعدها.',
          author: 'مستوحاة من الحضارة المصرية',
          category: 'التاريخ',
        ),
        Quote(
          text: 'العلم والفن بيخلوا الإنسان يتجاوز حدود عمره.',
          author: 'مستوحاة من الحضارة المصرية',
          category: 'الأثر',
        ),
        Quote(
          text: 'الإنجاز الحقيقي هو اللي يفضل نافع بعد ما صاحبه يختفي.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الأثر',
        ),
        Quote(
          text: 'الزمن مش بيحفظ كل حاجة، بيحفظ اللي كان له أثر.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الأثر',
        ),
        Quote(
          text: 'التاريخ بيتكتب بأفعال الناس أكتر من كلامهم.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التاريخ',
        ),
        Quote(
          text: 'اللي عايز يسيب أثر، يبدأ بحاجة يقدر يعملها النهارده.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'العمل',
        ),
        Quote(
          text: 'الحضارة مش نتيجة شخص واحد، لكنها نتيجة أجيال.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'الحضارة',
        ),
        Quote(
          text: 'أهم حاجة في التاريخ مش مين كان موجود، لكن إيه اللي اتعلمناه.',
          author: 'مستوحاة من التاريخ المصري',
          category: 'التعلم',
        ),
    ];
    final quote = motivationalQuotes[random.nextInt(motivationalQuotes.length)];


    final userName = Provider.of<UserDataProvider>(context).userName;
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 10,
                  ),
                  child: Text(
                    "الاعدادات",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      Transform.translate(
                        offset: Offset(-3, -5),
                        child: Transform.rotate(
                          angle: -0.030,
                          child: _card(color: AppColors.surfaceAlt, height: 150),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(5, 0),
                        child: Transform.rotate(
                          angle: 0.030,
                          child: _card(color: AppColors.surfaceAlt, height: 150),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          spacing: 20,
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: CircleAvatar(
                                backgroundColor: AppColors.surfaceAlt,
                                child: Text(
                                  userName[0],
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    final _formKey = GlobalKey<FormState>();
                                    final _nameController = TextEditingController(
                                      text: userName,
                                    );
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: AppColors.surface,
                                          title: Text(
                                            "تعديل الاسم",
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          icon: Stack(
                                            children: [
                                              Transform.translate(
                                                offset: Offset(-3, -5),
                                                child: Transform.rotate(
                                                  angle: -0.030,
                                                  child: _card(color: AppColors.surfaceAlt, height: 60),
                                                ),
                                              ),
                                              Transform.translate(
                                                offset: Offset(5, 0),
                                                child: Transform.rotate(
                                                  angle: 0.030,
                                                  child: _card(color: AppColors.surfaceAlt, height: 60),
                                                ),
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: Icon(
                                                      Icons.person_3_outlined,
                                                      color: AppColors.accentLight,
                                                      size: 35,
                                                    ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: Form(
                                            key: _formKey,
                                            child: TextFormField(
                                              controller: _nameController,
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                              ),
                                              decoration: InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(
                                                    5,
                                                  ),
                                                  borderSide: BorderSide(
                                                    color: AppColors.border,
                                                    width: 1,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(
                                                    5,
                                                  ),
                                                  borderSide: BorderSide(
                                                    color: AppColors.border,
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return "من فضلك أدخل اسمك";
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  Navigator.pop(context);
                                                  Provider.of<UserDataProvider>(
                                                    context,
                                                    listen: false,
                                                  ).editUserName(
                                                    userName: _nameController.text
                                                        .trim(),
                                                    context: context,
                                                  );
                                                } else {
                                                  Dialogs.failed(
                                                    context: context,
                                                    message:
                                                    "لأ يمكنك ترك الاسم فارغ",
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.accent,
                                              ),
                                              child: Text(
                                                "تعديل",
                                                style: TextStyle(
                                                  color: AppColors.onAccent,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.accent,
                                              ),
                                              child: Text(
                                                "اغلاق",
                                                style: TextStyle(
                                                  color: AppColors.onAccent,
                                                ),
                                              ),
                                            ),
                                          ],
                                          actionsAlignment: MainAxisAlignment.center,
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    "تعديل الاسم",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(
                            color: AppColors.border,
                            width: 1
                        ),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      spacing: 15,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bookmark_outline,
                                  color: AppColors.textPrimary,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: () async {
                                    final text = '”${quote.text}“\n\n— ${quote.author}\nمن تطبيق مسار';

                                    await SharePlus.instance.share(
                                      ShareParams(
                                        text: text,
                                        subject: "تطبيق مسار"
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.share_outlined,
                                    color: AppColors.textPrimary,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),

                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(7),
                              child: Row(
                                spacing: 10,
                                children: [
                                  Icon(
                                    Icons.menu_book_outlined,
                                    color: AppColors.surface,
                                  ),
                                  Text(
                                    quote.category!,
                                    style: TextStyle(
                                      color: AppColors.surface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '”',
                                  style: TextStyle(
                                    fontSize: 64,
                                    color: Color(0xFFB5D7D5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(quote.text, style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 40,
                                fontWeight: FontWeight.bold
                            ), textAlign: TextAlign.center,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  '“',
                                  style: TextStyle(
                                    fontSize: 64,
                                    color: Color(0xFFB5D7D5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.20),
                          child: Divider(
                            color: AppColors.divider,
                          ),
                        ),
                        Text(quote.author, style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold
                        ),)
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    spacing: 40,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen()));
                        },
                        child: Stack(
                          children: [
                            Transform.translate(
                              offset: Offset(-3, -5),
                              child: Transform.rotate(
                                angle: -0.030,
                                child: _card(color: AppColors.surfaceAlt, height: 70),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(5, 0),
                              child: Transform.rotate(
                                angle: 0.030,
                                child: _card(color: AppColors.surfaceAlt, height: 70),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    spacing: 20,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppColors.textPrimary,
                                      ),
                                      Text(
                                        "عن التطبيق",
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          confirmation(context: context, message: "هل تريد حذف جميع بياناتك بالفعل؟");
                        },
                        child: Stack(
                          children: [
                            Transform.translate(
                              offset: Offset(-3, -5),
                              child: Transform.rotate(
                                angle: -0.030,
                                child: _card(color: AppColors.danger, height: 70),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(5, 0),
                              child: Transform.rotate(
                                angle: 0.030,
                                child: _card(color: AppColors.danger, height: 70),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.danger, width: 1),
                              ),
                              child: Row(
                                spacing: 20,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_outline, color: AppColors.danger),
                                  Text(
                                    "حذف جميع البيانات",
                                    style: TextStyle(
                                      color: AppColors.danger,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
