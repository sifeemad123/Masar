
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:masar/Screens/about_screen.dart';
import 'package:masar/Screens/onboarding_screens.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/providers/user_data_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notifications_service.dart';

class MotivationMessage {
  final String text;
  final String category;

  const MotivationMessage({
    required this.text,
    required this.category,
  });
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;
  late final Animation<double> _backgroundAnimation;
  bool _motivationEnabled = false;
  bool _motivationLoading = true;

  int _messageIndex = 0;
  static const List<MotivationMessage> _messages = [
    // ==================== البداية ====================
    MotivationMessage(
      text: 'مش لازم تكون عارف كل خطوات الطريق، كفاية تبدأ بالخطوة اللي قدامك.',
      category: 'البداية',
    ),
    MotivationMessage(
      text: 'أصعب جزء في أي مهمة غالبًا هو إنك تبدأ، متديش البداية أكبر من حجمها.',
      category: 'البداية',
    ),
    MotivationMessage(
      text: 'ابدأ حتى لو بخمس دقايق، المهم تكسر حاجز التأجيل.',
      category: 'البداية',
    ),
    MotivationMessage(
      text: 'كل حاجة كبيرة بدأت بقرار صغير إن حد يحاول.',
      category: 'البداية',
    ),
    MotivationMessage(
      text: 'متستناش إحساس الحماس، ساعات الحماس بييجي بعد ما تبدأ.',
      category: 'البداية',
    ),
    MotivationMessage(
      text: 'النهارده مش محتاج بداية مثالية، محتاج بداية حقيقية.',
      category: 'البداية',
    ),
    MotivationMessage(
      text: 'لو مش عارف تبدأ منين، ابدأ بأبسط حاجة تقدر تعملها.',
      category: 'البداية',
    ),
    MotivationMessage(
      text: 'متخليش التفكير في حجم المهمة يمنعك من أول خطوة.',
      category: 'البداية',
    ),
    MotivationMessage(
      text: 'كل تأجيل بيخلي البداية أتقل، فابدأ وخفف الحمل عن نفسك.',
      category: 'البداية',
    ),
    MotivationMessage(
      text: 'الوقت المناسب مش دايمًا بيظهر، أحيانًا أنت اللي بتصنعه لما تبدأ.',
      category: 'البداية',
    ),

    // ==================== الاستمرارية ====================
    MotivationMessage(
      text: 'مش كل يوم هتكون في أفضل حالاتك، لكن تقدر تحافظ على خطوة صغيرة.',
      category: 'الاستمرارية',
    ),
    MotivationMessage(
      text: 'اللي بيكمل بخطوات بسيطة بيوصل أبعد من اللي بيبدأ بحماس ويتوقف.',
      category: 'الاستمرارية',
    ),
    MotivationMessage(
      text: 'الاستمرار مش معناه إنك متتعبش، معناه إنك تعرف ترجع تاني.',
      category: 'الاستمرارية',
    ),
    MotivationMessage(
      text: 'متستهونش بتأثير الحاجات الصغيرة لما تكررها كل يوم.',
      category: 'الاستمرارية',
    ),
    MotivationMessage(
      text: 'حتى في الأيام الهادية، حاول تعمل حاجة تحافظ بيها على تقدمك.',
      category: 'الاستمرارية',
    ),
    MotivationMessage(
      text: 'مش مهم تكون سريع، المهم متفضلش واقف في مكانك.',
      category: 'الاستمرارية',
    ),
    MotivationMessage(
      text: 'النتائج الكبيرة غالبًا بتكون مجموع محاولات صغيرة محدش لاحظها.',
      category: 'الاستمرارية',
    ),
    MotivationMessage(
      text: 'لما تفقد الحماس، افتكر إنك بدأت لهدف يستحق الاستمرار.',
      category: 'الاستمرارية',
    ),
    MotivationMessage(
      text: 'العادة اللي بتحافظ عليها النهارده ممكن تغير شكل حياتك بعد فترة.',
      category: 'الاستمرارية',
    ),
    MotivationMessage(
      text: 'كل مرة بترجع فيها لطريقك بعد انقطاع، بتثبت إنك لسه مكمل.',
      category: 'الاستمرارية',
    ),

    // ==================== الانضباط ====================
    MotivationMessage(
      text: 'الانضباط إنك تلتزم باللي قررته حتى لما مزاجك يقترح عليك التأجيل.',
      category: 'الانضباط',
    ),
    MotivationMessage(
      text: 'متخليش رغبتك اللحظية تتحكم في قرارات هتأثر على مستقبلك.',
      category: 'الانضباط',
    ),
    MotivationMessage(
      text: 'كل مرة بتختار فيها الالتزام بدل التأجيل، بتقوي نفسك.',
      category: 'الانضباط',
    ),
    MotivationMessage(
      text: 'خلي قراراتك مبنية على أهدافك، مش على إحساسك في اللحظة.',
      category: 'الانضباط',
    ),
    MotivationMessage(
      text: 'الانضباط الحقيقي بيظهر في الأيام اللي مفيهاش حماس.',
      category: 'الانضباط',
    ),
    MotivationMessage(
      text: 'متوعدش نفسك بحاجات كتير، لكن نفّذ اللي وعدت نفسك بيه.',
      category: 'الانضباط',
    ),
    MotivationMessage(
      text: 'الالتزام مش عقاب، ده احترام للوقت والأهداف اللي اخترتها.',
      category: 'الانضباط',
    ),
    MotivationMessage(
      text: 'خلي عندك نظام يساعدك، بدل ما تعتمد على قوة إرادتك طول الوقت.',
      category: 'الانضباط',
    ),
    MotivationMessage(
      text: 'الشخص المنضبط مش شخص عمره ما بيتكاسل، لكنه بيعرف يرجع لمساره.',
      category: 'الانضباط',
    ),
    MotivationMessage(
      text: 'اختار الصح حتى لو الأسهل متاح قدامك.',
      category: 'الانضباط',
    ),

    // ==================== التركيز ====================
    MotivationMessage(
      text: 'لما تركز في حاجة واحدة، بتديها فرصة حقيقية إنها تخلص.',
      category: 'التركيز',
    ),
    MotivationMessage(
      text: 'مش كل حاجة بتطلب انتباهك تستحق تاخد من وقتك.',
      category: 'التركيز',
    ),
    MotivationMessage(
      text: 'اقفل المشتتات شوية، وادي هدفك فرصة ياخد اهتمامك.',
      category: 'التركيز',
    ),
    MotivationMessage(
      text: 'كل دقيقة تركيز حقيقي بتفرق في جودة اللي بتعمله.',
      category: 'التركيز',
    ),
    MotivationMessage(
      text: 'متسمحش لحاجات صغيرة تقاطع مهمة كبيرة.',
      category: 'التركيز',
    ),
    MotivationMessage(
      text: 'لو عقلك سرح، رجّعه بهدوء للمهمة اللي بين إيديك.',
      category: 'التركيز',
    ),
    MotivationMessage(
      text: 'حدد أولويتك قبل ما تبدأ يومك، عشان متتسحبش في كل اتجاه.',
      category: 'التركيز',
    ),
    MotivationMessage(
      text: 'التركيز مش إنك متشوفش المشتتات، التركيز إنك تعرف تتجاوزها.',
      category: 'التركيز',
    ),
    MotivationMessage(
      text: 'خلي انتباهك للحاجة اللي تقدر تغيرها دلوقتي.',
      category: 'التركيز',
    ),
    MotivationMessage(
      text: 'مهمة واحدة بتركيز أحسن من خمس مهام بنص انتباه.',
      category: 'التركيز',
    ),

    // ==================== الطموح ====================
    MotivationMessage(
      text: 'خلي عندك حلم يستاهل إنك تشتغل عشانه حتى في الأيام العادية.',
      category: 'الطموح',
    ),
    MotivationMessage(
      text: 'المستقبل اللي بتتمناه محتاج منك قرارات مختلفة في الحاضر.',
      category: 'الطموح',
    ),
    MotivationMessage(
      text: 'متخليش صعوبة الوصول تقلل من قيمة اللي بتحاول توصله.',
      category: 'الطموح',
    ),
    MotivationMessage(
      text: 'خلي طموحك واضح، وخطواتك اليومية أقرب ما تكون ليه.',
      category: 'الطموح',
    ),
    MotivationMessage(
      text: 'الأحلام مش بتتحقق بالتفكير فيها بس، محتاجة سعي مستمر.',
      category: 'الطموح',
    ),
    MotivationMessage(
      text: 'اشتغل النهارده على حاجة نفسك تشكر نفسك عليها بعد سنين.',
      category: 'الطموح',
    ),
    MotivationMessage(
      text: 'متصغرش حلمك عشان الطريق ليه طويل.',
      category: 'الطموح',
    ),
    MotivationMessage(
      text: 'كل مهارة بتتعلمها النهارده بتوسع اختياراتك في المستقبل.',
      category: 'الطموح',
    ),
    MotivationMessage(
      text: 'خلي طموحك أكبر من خوفك من المحاولة.',
      category: 'الطموح',
    ),
    MotivationMessage(
      text: 'مش مطلوب منك توصل بسرعة، المطلوب متنساش أنت رايح فين.',
      category: 'الطموح',
    ),

    // ==================== التخطيط ====================
    MotivationMessage(
      text: 'خطة واضحة وبسيطة أحسن من أفكار كتير من غير تنفيذ.',
      category: 'التخطيط',
    ),
    MotivationMessage(
      text: 'قسم أهدافك الكبيرة لمهام صغيرة تعرف تبدأ فيها بسهولة.',
      category: 'التخطيط',
    ),
    MotivationMessage(
      text: 'قبل ما تبدأ يومك، حدد أهم ثلاث حاجات محتاج تنجزها.',
      category: 'التخطيط',
    ),
    MotivationMessage(
      text: 'خلي خطتك واقعية وتناسب وقتك وطاقتك.',
      category: 'التخطيط',
    ),
    MotivationMessage(
      text: 'التخطيط الجيد بيوفر عليك حيرة كتير أثناء التنفيذ.',
      category: 'التخطيط',
    ),
    MotivationMessage(
      text: 'متخططش لكل دقيقة، سيب مساحة للحاجات غير المتوقعة.',
      category: 'التخطيط',
    ),
    MotivationMessage(
      text: 'اكتب اللي محتاج تعمله، عشان متفضلش شايله كله في دماغك.',
      category: 'التخطيط',
    ),
    MotivationMessage(
      text: 'راجع خطتك باستمرار، وعدّلها لما تكتشف طريقة أفضل.',
      category: 'التخطيط',
    ),
    MotivationMessage(
      text: 'ابدأ بتحديد المطلوب، وبعدها حدد الوقت المناسب لتنفيذه.',
      category: 'التخطيط',
    ),
    MotivationMessage(
      text: 'الخطة مش قيود، دي وسيلة تخليك تتحرك بوضوح.',
      category: 'التخطيط',
    ),

    // ==================== الوقت ====================
    MotivationMessage(
      text: 'وقتك جزء من عمرك، فاختار بعناية هتستثمره في إيه.',
      category: 'الوقت',
    ),
    MotivationMessage(
      text: 'متسيبش يومك يعدي من غير ما تعمل حاجة ليها معنى.',
      category: 'الوقت',
    ),
    MotivationMessage(
      text: 'الوقت اللي بتضيعه مش دايمًا هتقدر تعوضه، فاستغله بوعي.',
      category: 'الوقت',
    ),
    MotivationMessage(
      text: 'مش لازم تكون مشغول طول الوقت عشان تكون بتنجز.',
      category: 'الوقت',
    ),
    MotivationMessage(
      text: 'خلي لكل حاجة وقتها، ومتديش حاجة أكتر من حقها.',
      category: 'الوقت',
    ),
    MotivationMessage(
      text: 'ابدأ المهمة في وقتها بدل ما تفضل تفكر فيها طول اليوم.',
      category: 'الوقت',
    ),
    MotivationMessage(
      text: 'احسب وقتك على أساس أولوياتك، مش على أساس اللي بيشغلك.',
      category: 'الوقت',
    ),
    MotivationMessage(
      text: 'ساعة مستغلة بوعي ممكن تكون أثمن من يوم كامل مشتت.',
      category: 'الوقت',
    ),
    MotivationMessage(
      text: 'متأجلش لآخر اليوم حاجة تقدر تخلصها دلوقتي.',
      category: 'الوقت',
    ),
    MotivationMessage(
      text: 'كل يوم بيعدي هو فرصة مش هتتكرر بنفس التفاصيل.',
      category: 'الوقت',
    ),

    // ==================== الأولويات ====================
    MotivationMessage(
      text: 'مش كل حاجة مهمة لازم تتعمل دلوقتي، اعرف ترتب أولوياتك.',
      category: 'الأولويات',
    ),
    MotivationMessage(
      text: 'ابدأ بالحاجة اللي تأثيرها أكبر على أهدافك.',
      category: 'الأولويات',
    ),
    MotivationMessage(
      text: 'قول لأ للحاجات اللي بتاخد وقتك من غير ما تضيف لحياتك.',
      category: 'الأولويات',
    ),
    MotivationMessage(
      text: 'مش معنى إن عندك مهام كتير إنك لازم تعملها كلها مرة واحدة.',
      category: 'الأولويات',
    ),
    MotivationMessage(
      text: 'اعرف إيه اللي مينفعش يتأجل، وابدأ بيه.',
      category: 'الأولويات',
    ),
    MotivationMessage(
      text: 'اختيارك للحاجة المهمة أحيانًا أهم من سرعة تنفيذك.',
      category: 'الأولويات',
    ),
    MotivationMessage(
      text: 'متخليش المهام السهلة تسرق وقت المهام الأهم.',
      category: 'الأولويات',
    ),
    MotivationMessage(
      text: 'خلي أهدافك هي اللي تحدد أولوياتك، مش ضغوط اللحظة.',
      category: 'الأولويات',
    ),
    MotivationMessage(
      text: 'كل حاجة ليها مكان في حياتك، بس مش كل حاجة ليها نفس الأولوية.',
      category: 'الأولويات',
    ),
    MotivationMessage(
      text: 'اختار اللي يستحق وقتك قبل ما تكتشف إن وقتك خلص.',
      category: 'الأولويات',
    ),

    // ==================== التوازن ====================
    MotivationMessage(
      text: 'النجاح مش إنك تهمل كل حاجة عشان تنجز حاجة واحدة.',
      category: 'التوازن',
    ),
    MotivationMessage(
      text: 'ادي لشغلك ومذاكرتك وراحتك كل واحد حقه.',
      category: 'التوازن',
    ),
    MotivationMessage(
      text: 'التوازن إنك تعرف إمتى تشتغل وإمتى تحتاج تهدى.',
      category: 'التوازن',
    ),
    MotivationMessage(
      text: 'خلي في يومك مساحة لحاجات بتحبها، مش بس الحاجات المطلوبة منك.',
      category: 'التوازن',
    ),
    MotivationMessage(
      text: 'متخليش هدف واحد ياخد منك القدرة إنك تستمتع بباقي حياتك.',
      category: 'التوازن',
    ),
    MotivationMessage(
      text: 'الراحة مش عدو الإنجاز، دي جزء من إنك تقدر تستمر.',
      category: 'التوازن',
    ),
    MotivationMessage(
      text: 'اهتم بصحتك وعلاقاتك زي ما بتهتم بمستقبلك.',
      category: 'التوازن',
    ),
    MotivationMessage(
      text: 'مش كل وقت فاضي لازم يتحول لمهمة جديدة.',
      category: 'التوازن',
    ),
    MotivationMessage(
      text: 'خلي طموحك يمشي جنب راحتك، مش على حسابها.',
      category: 'التوازن',
    ),
    MotivationMessage(
      text: 'الحياة مش قائمة مهام وبس، افتكر تعيشها كمان.',
      category: 'التوازن',
    ),

    // ==================== التقدم ====================
    MotivationMessage(
      text: 'حتى لو التقدم مش واضح، ده مش معناه إنه مش موجود.',
      category: 'التقدم',
    ),
    MotivationMessage(
      text: 'احتفل بالخطوات الصغيرة، لأنها اللي بتكون الطريق الطويل.',
      category: 'التقدم',
    ),
    MotivationMessage(
      text: 'مش لازم كل يوم تحقق إنجاز كبير، المهم متفقدش اتجاهك.',
      category: 'التقدم',
    ),
    MotivationMessage(
      text: 'بص على المسافة اللي قطعتها، مش بس المسافة اللي لسه فاضلة.',
      category: 'التقدم',
    ),
    MotivationMessage(
      text: 'كل مهمة بتخلصها هي دليل إنك قادر تحول خطتك لفعل.',
      category: 'التقدم',
    ),
    MotivationMessage(
      text: 'التقدم الحقيقي ساعات بيكون في إنك بقيت أهدى وأوعى في قراراتك.',
      category: 'التقدم',
    ),
    MotivationMessage(
      text: 'خلي هدفك إنك تتحسن باستمرار، مش إنك تبقى كامل.',
      category: 'التقدم',
    ),
    MotivationMessage(
      text: 'كل يوم بتتعلم فيه حاجة جديدة هو يوم مضاف لرصيد خبرتك.',
      category: 'التقدم',
    ),
    MotivationMessage(
      text: 'قيس نجاح يومك بمدى اقترابه من أهدافك، مش بعدد ساعاته.',
      category: 'التقدم',
    ),
    MotivationMessage(
      text: 'التغيير الحقيقي بيبان لما تبص ورا وتلاحظ إنك اتغيرت.',
      category: 'التقدم',
    ),

    // ==================== التطور ====================
    MotivationMessage(
      text: 'استثمر في نفسك، لأن المهارات اللي بتكتسبها بتفضل معاك.',
      category: 'التطور',
    ),
    MotivationMessage(
      text: 'كل تجربة جديدة فرصة تفهم نفسك والعالم بشكل أفضل.',
      category: 'التطور',
    ),
    MotivationMessage(
      text: 'متخافش تتعلم حاجة من الصفر، كل خبير كان مبتدئ.',
      category: 'التطور',
    ),
    MotivationMessage(
      text: 'خلي عندك فضول تتعلم أكتر حتى بعد ما تحقق هدفك.',
      category: 'التطور',
    ),
    MotivationMessage(
      text: 'التطور مش محتاج قفزة كبيرة، محتاج رغبة مستمرة في التحسن.',
      category: 'التطور',
    ),
    MotivationMessage(
      text: 'اسأل واتعلم وجرب، متخليش خوفك من الغلط يوقفك.',
      category: 'التطور',
    ),
    MotivationMessage(
      text: 'كل مهارة بتطورها بتقربك من نسخة أقوى منك.',
      category: 'التطور',
    ),
    MotivationMessage(
      text: 'خليك دايمًا مستعد تغير طريقتك لما تلاقي طريقة أفضل.',
      category: 'التطور',
    ),
    MotivationMessage(
      text: 'التعلم الحقيقي بيبدأ لما تحول المعلومة لتطبيق.',
      category: 'التطور',
    ),
    MotivationMessage(
      text: 'متقفش عند اللي تعرفه، دايمًا فيه مساحة لحاجة جديدة.',
      category: 'التطور',
    ),

    // ==================== التعلم ====================
    MotivationMessage(
      text: 'كل سؤال بتسأله النهارده ممكن يوفر عليك حيرة بكرة.',
      category: 'التعلم',
    ),
    MotivationMessage(
      text: 'مش عيب متعرفش، العيب إنك ترفض تتعلم.',
      category: 'التعلم',
    ),
    MotivationMessage(
      text: 'افهم الفكرة كويس قبل ما تستعجل تحفظ تفاصيلها.',
      category: 'التعلم',
    ),
    MotivationMessage(
      text: 'كل معلومة جديدة بتربطها باللي تعرفه بتزود فهمك.',
      category: 'التعلم',
    ),
    MotivationMessage(
      text: 'التعلم رحلة مستمرة، ومفيش حد خلص يعرف كل حاجة.',
      category: 'التعلم',
    ),
    MotivationMessage(
      text: 'جرب تطبق اللي اتعلمته، لأن المعرفة بتقوى بالممارسة.',
      category: 'التعلم',
    ),
    MotivationMessage(
      text: 'لما تواجه حاجة صعبة، قسمها لأجزاء وافهم كل جزء لوحده.',
      category: 'التعلم',
    ),
    MotivationMessage(
      text: 'راجع اللي اتعلمته من وقت للتاني عشان يفضل ثابت في ذهنك.',
      category: 'التعلم',
    ),
    MotivationMessage(
      text: 'خلي هدفك من التعلم إنك تفهم، مش بس تخلص المحتوى.',
      category: 'التعلم',
    ),
    MotivationMessage(
      text: 'كل مرة بتتعلم فيها حاجة بنفسك، بتوسع حدود قدراتك.',
      category: 'التعلم',
    ),

    // ==================== المذاكرة ====================
    MotivationMessage(
      text: 'كل صفحة بتذاكرها النهارده بتقربك من النتيجة اللي بتتمناها.',
      category: 'المذاكرة',
    ),
    MotivationMessage(
      text: 'متبصش على المنهج كله مرة واحدة، ركز في الجزء اللي قدامك.',
      category: 'المذاكرة',
    ),
    MotivationMessage(
      text: 'ساعة مذاكرة بتركيز أحسن من ساعات طويلة وسط المشتتات.',
      category: 'المذاكرة',
    ),
    MotivationMessage(
      text: 'لو درس صعب عليك، اديله وقت أكتر بدل ما تحكم على نفسك.',
      category: 'المذاكرة',
    ),
    MotivationMessage(
      text: 'حل الأسئلة بنفسك، لأن الفهم بيظهر وقت التطبيق.',
      category: 'المذاكرة',
    ),
    MotivationMessage(
      text: 'متأجلش مراجعة اللي ذاكرته، التثبيت محتاج متابعة.',
      category: 'المذاكرة',
    ),
    MotivationMessage(
      text: 'كل جلسة مذاكرة مركزة بتضيف لحصيلة تعبك.',
      category: 'المذاكرة',
    ),
    MotivationMessage(
      text: 'ابدأ بالمادة اللي محتاجة منك مجهود أكبر، وسيب السهل لوقته.',
      category: 'المذاكرة',
    ),
    MotivationMessage(
      text: 'الدرجة نتيجة، لكن الفهم الحقيقي مكسب هيفضل معاك.',
      category: 'المذاكرة',
    ),
    MotivationMessage(
      text: 'خلي مذاكرتك منظمة، وافتكر إن الراحة بتساعدك تستوعب.',
      category: 'المذاكرة',
    ),

    // ==================== الثقة ====================
    MotivationMessage(
      text: 'ثق إنك تقدر تتعلم وتتطور حتى لو مش شايف النتيجة دلوقتي.',
      category: 'الثقة',
    ),
    MotivationMessage(
      text: 'متخليش رأي حد يحدد أنت تقدر توصل لفين.',
      category: 'الثقة',
    ),
    MotivationMessage(
      text: 'كل مرة بتوفي فيها بوعدك لنفسك بتزود ثقتك فيها.',
      category: 'الثقة',
    ),
    MotivationMessage(
      text: 'افتكر المواقف اللي قدرت تتجاوزها قبل ما تشك في قدراتك.',
      category: 'الثقة',
    ),
    MotivationMessage(
      text: 'مش لازم تكون الأفضل من البداية عشان تثق في قدرتك على النجاح.',
      category: 'الثقة',
    ),
    MotivationMessage(
      text: 'خلي ثقتك مبنية على محاولاتك وتعلمك، مش على كلام الناس.',
      category: 'الثقة',
    ),
    MotivationMessage(
      text: 'متقللش من نفسك لمجرد إنك لسه في أول الطريق.',
      category: 'الثقة',
    ),
    MotivationMessage(
      text: 'أنت قادر تبدأ من جديد وتختار طريقة أفضل.',
      category: 'الثقة',
    ),
    MotivationMessage(
      text: 'اعترف بنقاط قوتك واشتغل على الحاجات اللي محتاجة تتحسن.',
      category: 'الثقة',
    ),
    MotivationMessage(
      text: 'خلي تقدمك هو اللي يبني ثقتك، مش انتظارك للكمال.',
      category: 'الثقة',
    ),

    // ==================== الصبر ====================
    MotivationMessage(
      text: 'مش كل حاجة بتتزرع النهارده لازم تثمر بكرة.',
      category: 'الصبر',
    ),
    MotivationMessage(
      text: 'ادي لكل هدف الوقت اللي يستحقه، ومتستعجلش النتيجة.',
      category: 'الصبر',
    ),
    MotivationMessage(
      text: 'الصبر إنك تفضل تعمل اللي عليك حتى لو النتيجة اتأخرت.',
      category: 'الصبر',
    ),
    MotivationMessage(
      text: 'مش كل تأخير معناه إنك فشلت، ساعات الطريق بياخد وقت أطول.',
      category: 'الصبر',
    ),
    MotivationMessage(
      text: 'اتعلم تستمتع برحلة التطور، مش بس بلحظة الوصول.',
      category: 'الصبر',
    ),
    MotivationMessage(
      text: 'متستعجلش على نفسك، كل مرحلة ليها وقتها ودروسها.',
      category: 'الصبر',
    ),
    MotivationMessage(
      text: 'النتائج المستدامة محتاجة وقت ومجهود متراكم.',
      category: 'الصبر',
    ),
    MotivationMessage(
      text: 'لما متلاقيش نتيجة فورية، افتكر إن البناء بياخد وقت.',
      category: 'الصبر',
    ),
    MotivationMessage(
      text: 'اصبر على التعلم والتجربة، فالمهارة مش بتتكون في يوم.',
      category: 'الصبر',
    ),
    MotivationMessage(
      text: 'خلي صبرك أكبر من استعجالك، وسعيك مستمر.',
      category: 'الصبر',
    ),

    // ==================== العادات ====================
    MotivationMessage(
      text: 'العادة الصغيرة اللي بتحافظ عليها النهارده ممكن تعمل فرق كبير بعدين.',
      category: 'العادات',
    ),
    MotivationMessage(
      text: 'متبدأش بعادات كتير مرة واحدة، اختار عادة وابنِ عليها.',
      category: 'العادات',
    ),
    MotivationMessage(
      text: 'خلي العادة سهلة في بدايتها عشان تقدر تحافظ عليها.',
      category: 'العادات',
    ),
    MotivationMessage(
      text: 'كل مرة تكرر فيها عادة كويسة بتخليها أسهل مع الوقت.',
      category: 'العادات',
    ),
    MotivationMessage(
      text: 'العادة مش محتاجة مجهود ضخم كل يوم، محتاجة تكرار واعي.',
      category: 'العادات',
    ),
    MotivationMessage(
      text: 'اختار عادات تخدم أهدافك وتناسب حياتك.',
      category: 'العادات',
    ),
    MotivationMessage(
      text: 'متخليش يوم واحد من غير عادة يخليك تسيبها تمامًا.',
      category: 'العادات',
    ),
    MotivationMessage(
      text: 'راقب عاداتك، لأن تكرارها بيحدد جزء كبير من شكل يومك.',
      category: 'العادات',
    ),
    MotivationMessage(
      text: 'ابدأ بعادة بسيطة تقدر تعملها حتى في الأيام المزدحمة.',
      category: 'العادات',
    ),
    MotivationMessage(
      text: 'العادات الجيدة بتخلي القرارات الصح أسهل مع الوقت.',
      category: 'العادات',
    ),

    // ==================== الصعوبات ====================
    MotivationMessage(
      text: 'اليوم الصعب مش دليل إن رحلتك كلها صعبة.',
      category: 'الصعوبات',
    ),
    MotivationMessage(
      text: 'لما تواجه مشكلة، دور على الحل بدل ما تفضل واقف عندها.',
      category: 'الصعوبات',
    ),
    MotivationMessage(
      text: 'الغلط مش نهاية المحاولة، ده فرصة تفهم إيه اللي محتاج يتغير.',
      category: 'الصعوبات',
    ),
    MotivationMessage(
      text: 'خد من التجربة درس، ومتخليش التجربة توقفك.',
      category: 'الصعوبات',
    ),
    MotivationMessage(
      text: 'مش لازم كل حاجة تمشي حسب خطتك عشان تقدر تنجح.',
      category: 'الصعوبات',
    ),
    MotivationMessage(
      text: 'لما تتعطل، راجع خطواتك وشوف إيه اللي ممكن تحسنه.',
      category: 'الصعوبات',
    ),
    MotivationMessage(
      text: 'التحديات جزء من أي طريق له قيمة.',
      category: 'الصعوبات',
    ),
    MotivationMessage(
      text: 'متخليش خطأ مؤقت يتحول لسبب إنك توقف المحاولة.',
      category: 'الصعوبات',
    ),
    MotivationMessage(
      text: 'واجه اللي تقدر عليه النهارده، وسيب الباقي لوقته.',
      category: 'الصعوبات',
    ),
    MotivationMessage(
      text: 'كل مشكلة بتتعامل معاها بتضيف لخبرتك طريقة جديدة للتفكير.',
      category: 'الصعوبات',
    ),

    // ==================== الراحة ====================
    MotivationMessage(
      text: 'من حقك ترتاح، ومش لازم تحس بالذنب عشان بتاخد وقت لنفسك.',
      category: 'الراحة',
    ),
    MotivationMessage(
      text: 'لما تحس إن طاقتك قلت، خد استراحة وارجع بهدوء.',
      category: 'الراحة',
    ),
    MotivationMessage(
      text: 'الراحة المنظمة بتساعدك تحافظ على تركيزك لفترة أطول.',
      category: 'الراحة',
    ),
    MotivationMessage(
      text: 'مش كل لحظة لازم تكون منتجة، المهم تحافظ على توازنك.',
      category: 'الراحة',
    ),
    MotivationMessage(
      text: 'اهتم بنومك، لأن جسمك وعقلك محتاجين وقت للتعافي.',
      category: 'الراحة',
    ),
    MotivationMessage(
      text: 'خد استراحة حقيقية بعيد عن الحاجات اللي بتزود تشتتك.',
      category: 'الراحة',
    ),
    MotivationMessage(
      text: 'متخلطش بين الاجتهاد وإنك تضغط على نفسك من غير حساب.',
      category: 'الراحة',
    ),
    MotivationMessage(
      text: 'أحيانًا أفضل قرار تاخده هو إنك تهدى وتعيد ترتيب أفكارك.',
      category: 'الراحة',
    ),
    MotivationMessage(
      text: 'الاهتمام بنفسك مش رفاهية، ده جزء من قدرتك على الاستمرار.',
      category: 'الراحة',
    ),
    MotivationMessage(
      text: 'خلي راحتك وسيلة لاستعادة طاقتك، مش هروب دائم من مسؤولياتك.',
      category: 'الراحة',
    ),

    // ==================== الإيجابية ====================
    MotivationMessage(
      text: 'دور على الحاجة الكويسة اللي حصلت النهارده حتى لو كانت بسيطة.',
      category: 'الإيجابية',
    ),
    MotivationMessage(
      text: 'مش كل حاجة تحت سيطرتك، لكن طريقة تعاملك معاها في إيدك.',
      category: 'الإيجابية',
    ),
    MotivationMessage(
      text: 'ابدأ يومك بتوقع الخير، واشتغل بالأسباب.',
      category: 'الإيجابية',
    ),
    MotivationMessage(
      text: 'خلي عندك أمل في اللي جاي، ومجهود في اللي بتعمله دلوقتي.',
      category: 'الإيجابية',
    ),
    MotivationMessage(
      text: 'ركز على الفرص الموجودة بدل ما تنشغل بالحاجات اللي فاتتك.',
      category: 'الإيجابية',
    ),
    MotivationMessage(
      text: 'التفاؤل مش تجاهل للصعوبات، لكنه إيمان إن فيه حلول ممكنة.',
      category: 'الإيجابية',
    ),
    MotivationMessage(
      text: 'افتكر إن يومك ممكن يتحسن بخطوة واحدة مختلفة.',
      category: 'الإيجابية',
    ),
    MotivationMessage(
      text: 'خلي نظرتك لنفسك ولحياتك فيها رحمة وأمل.',
      category: 'الإيجابية',
    ),
    MotivationMessage(
      text: 'متسمحش للحظة سيئة تحكم على يومك كله.',
      category: 'الإيجابية',
    ),
    MotivationMessage(
      text: 'ابدأ من المتاح، وكن ممتن للي عندك، واسعى للي بتتمناه.',
      category: 'الإيجابية',
    ),

    // ==================== المسؤولية ====================
    MotivationMessage(
      text: 'خد مسؤولية قراراتك، لأن التغيير بيبدأ لما تبطل تستنى غيرك يبدأه.',
      category: 'المسؤولية',
    ),
    MotivationMessage(
      text: 'متستناش حد يفكرك بأهدافك كل يوم، خليها مسؤوليتك.',
      category: 'المسؤولية',
    ),
    MotivationMessage(
      text: 'كل قرار صغير بتاخده النهارده ليه تأثير على يومك.',
      category: 'المسؤولية',
    ),
    MotivationMessage(
      text: 'لو قصرت، اعترف بالتقصير واتعلم منه بدل ما تبرره.',
      category: 'المسؤولية',
    ),
    MotivationMessage(
      text: 'خلي كلامك مع نفسك مبني على وعود تقدر تنفذها.',
      category: 'المسؤولية',
    ),
    MotivationMessage(
      text: 'متلومش الظروف على كل حاجة، شوف إيه اللي تقدر تغيره.',
      category: 'المسؤولية',
    ),
    MotivationMessage(
      text: 'مسؤوليتك تجاه مستقبلك بتبدأ من اختياراتك اليومية.',
      category: 'المسؤولية',
    ),
    MotivationMessage(
      text: 'خليك واضح مع نفسك في اللي عايز تحققه واللي محتاج تعمله.',
      category: 'المسؤولية',
    ),
    MotivationMessage(
      text: 'تحمل نتيجة اختياراتك، واستخدمها عشان تختار بشكل أفضل المرة الجاية.',
      category: 'المسؤولية',
    ),
    MotivationMessage(
      text: 'متستناش الظروف تتغير بالكامل، ابدأ بتغيير اللي في إيدك.',
      category: 'المسؤولية',
    ),

    // ==================== الرضا والامتنان ====================
    MotivationMessage(
      text: 'قدّر اللي وصلتله، وفي نفس الوقت متوقفش سعيك للي نفسك فيه.',
      category: 'الامتنان',
    ),
    MotivationMessage(
      text: 'الامتنان بيخليك تشوف النعم اللي ممكن تكون اتعودت عليها.',
      category: 'الامتنان',
    ),
    MotivationMessage(
      text: 'اشكر ربنا على خطواتك الصغيرة قبل ما تستنى الإنجازات الكبيرة.',
      category: 'الامتنان',
    ),
    MotivationMessage(
      text: 'خليك راضي عن رزقك، وطموحك مستمر في السعي.',
      category: 'الامتنان',
    ),
    MotivationMessage(
      text: 'افتكر إن فيه حاجات كتير في حياتك تستحق إنك تحمد ربنا عليها.',
      category: 'الامتنان',
    ),
    MotivationMessage(
      text: 'متخليش انشغالك باللي ناقصك ينسيك قيمة اللي عندك.',
      category: 'الامتنان',
    ),
    MotivationMessage(
      text: 'كل يوم جديد نعمة وفرصة إنك تعمل حاجة مفيدة.',
      category: 'الامتنان',
    ),
    MotivationMessage(
      text: 'خلي قلبك شاكر، وخطواتك مستمرة.',
      category: 'الامتنان',
    ),
    MotivationMessage(
      text: 'الرضا مش معناه توقف الطموح، معناه تسعى بقلب مطمئن.',
      category: 'الامتنان',
    ),
    MotivationMessage(
      text: 'احمد ربنا على اللي عندك، واسأله التوفيق في اللي بتسعى له.',
      category: 'الامتنان',
    ),

    // ==================== الإيمان ====================
    MotivationMessage(
      text: 'اسعى وخد بالأسباب، وتوكل على ربنا في كل خطوة.',
      category: 'الإيمان',
    ),
    MotivationMessage(
      text: 'ابدأ يومك بذكر ربنا، وخلي نيتك في كل عمل خير.',
      category: 'الإيمان',
    ),
    MotivationMessage(
      text: 'مهما كان هدفك كبير، افتكر إن التوفيق من ربنا.',
      category: 'الإيمان',
    ),
    MotivationMessage(
      text: 'خلي علاقتك بربنا من أولوياتك، مش حاجة بتأجلها لوقت الفراغ.',
      category: 'الإيمان',
    ),
    MotivationMessage(
      text: 'استعن بربنا في سعيك، ومتنساش إن الدعاء والعمل بيكملوا بعض.',
      category: 'الإيمان',
    ),
    MotivationMessage(
      text: 'لو قصرت في حق ربنا، ارجع واستغفر وابدأ من جديد.',
      category: 'الإيمان',
    ),
    MotivationMessage(
      text: 'خلي نجاحك في الدنيا مرتبط بإنك تسعى لرضا ربنا.',
      category: 'الإيمان',
    ),
    MotivationMessage(
      text: 'متنساش نصيب قلبك من العبادة وسط انشغالك بأهدافك.',
      category: 'الإيمان',
    ),
    MotivationMessage(
      text: 'توكل على الله، واعمل اللي عليك، ومتعلقش قلبك بالنتيجة وحدها.',
      category: 'الإيمان',
    ),
    MotivationMessage(
      text: 'اطلب من ربنا العون والتوفيق، وابدأ يومك بنية صالحة.',
      category: 'الإيمان',
    ),
  ];

  MotivationMessage get _currentMessage => _messages[_messageIndex];

  Future<void> _loadMotivationPreference() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _motivationEnabled =
          prefs.getBool('motivationRemindersEnabled') ?? false;
      _motivationLoading = false;
    });
  }

  Future<void> _toggleMotivation(bool value) async {
    if (_motivationLoading) return;

    setState(() {
      _motivationEnabled = value;
      _motivationLoading = true;
    });

    try {
      await NotificationsService()
          .setMotivationalRemindersEnabled(value);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _motivationEnabled = !value;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حصلت مشكلة أثناء تحديث إعدادات التذكير'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _motivationLoading = false;
        });
      }
    }
  }

  Widget _motivationSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: _motivationEnabled
              ? AppColors.accent.withOpacity(0.35)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.accent,
            size: 25,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رسائل مسار التحفيزية',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'تذكيرات بسيطة تساعدك تحافظ على استمراريتك',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (_motivationLoading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch.adaptive(
              value: _motivationEnabled,
              activeTrackColor: AppColors.accent,
              onChanged: _toggleMotivation,
            ),
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();

    _messageIndex = Random().nextInt(_messages.length);

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    );

    _loadMotivationPreference();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _changeMessage() {
    if (_messages.length <= 1) return;

    int nextIndex;

    do {
      nextIndex = Random().nextInt(_messages.length);
    } while (nextIndex == _messageIndex);

    setState(() => _messageIndex = nextIndex);
  }

  Future<void> _shareMessage() async {
    final message =
        '“${_currentMessage.text}”\n\nرسالة تحفيزية من تطبيق مسار';

    await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'رسالة من مسار',
      ),
    );
  }

  void _openAbout() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, secondaryAnimation) =>
        const AboutScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.035, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _editName() async {
    final userDataProvider = context.read<UserDataProvider>();
    final currentName = userDataProvider.userName;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _EditNameDialog(
          initialName: currentName,
          onSave: (newName) {
            if (!mounted) return;

            userDataProvider.editUserName(
              userName: newName,
              context: this.context,
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    await Dialogs.confirm(
      context: context,
      title: 'حذف جميع البيانات؟',
      message:
      'سيتم حذف بياناتك المحفوظة في التطبيق، ولا يمكن التراجع عن هذا الإجراء.',
      confirmText: 'حذف البيانات',
      cancelText: 'إلغاء',
      danger: true,
      onConfirm: () {
        if (!mounted) return;

        context.read<UserDataProvider>().deleteAllData();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 450),
              pageBuilder: (_, animation, secondaryAnimation) =>
              const OnboardingScreens(),
              transitionsBuilder: (_, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                  child: child,
                );
              },
            ),
                (route) => false,
          );
        });
      },
    );
  }

  Widget _animatedSection({
    required int index,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('settings_section_$index'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + (index * 90)),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 21,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(String userName) {
    final displayName =
    userName.trim().isEmpty ? 'مستخدم مسار' : userName.trim();

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.accent,
                  AppColors.secondaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(21),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.20),
                  blurRadius: 13,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              displayName.characters.first,
              style: const TextStyle(
                color: AppColors.onAccent,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'حسابك الشخصي',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                InkWell(
                  onTap: _editName,
                  borderRadius: BorderRadius.circular(9),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'تعديل الاسم',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.accent,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _motivationCard() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        final animationValue = _backgroundAnimation.value;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.lerp(
                  AppColors.accent,
                  AppColors.secondaryDark,
                  animationValue * 0.18,
                )!,
                Color.lerp(
                  AppColors.accentDark,
                  AppColors.secondaryDark,
                  animationValue,
                )!,
              ],
            ),
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.20),
                blurRadius: 25,
                offset: const Offset(0, 11),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(21),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: AppColors.onAccent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.onAccent.withOpacity(0.12),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.onAccent,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رسالة من مسار',
                        style: TextStyle(
                          color: AppColors.onAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'كلمة صغيرة ليومك',
                        style: TextStyle(
                          color: AppColors.onAccent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _motivationIconButton(
                  icon: Icons.share_outlined,
                  tooltip: 'مشاركة الرسالة',
                  onTap: _shareMessage,
                ),
              ],
            ),
            const SizedBox(height: 23),
            Row(
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  color: AppColors.secondaryLight,
                  size: 27,
                ),
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _currentMessage.category,
                    key: ValueKey(_currentMessage.category),
                    style: const TextStyle(
                      color: AppColors.secondaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.10),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                _currentMessage.text,
                key: ValueKey(_messageIndex),
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: AppColors.onAccent,
                  fontSize: 19,
                  height: 1.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 21),
            Container(
              height: 1,
              color: AppColors.onAccent.withOpacity(0.18),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.secondaryLight,
                  size: 18,
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'خطوتك الجاية تبدأ منك',
                    style: TextStyle(
                      color: AppColors.onAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _changeMessage,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.onAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    'رسالة أخرى',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _motivationIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.onAccent.withOpacity(0.13),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              color: AppColors.onAccent,
              size: 19,
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool isDanger = false,
  }) {
    final color = iconColor ?? AppColors.accent;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.08),
        highlightColor: color.withOpacity(0.035),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDanger
                  ? AppColors.danger.withOpacity(0.20)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textMuted,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.water_drop_outlined,
            color: AppColors.secondaryDark,
            size: 21,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'مسار — خطوة كل يوم',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'نظّم يومك، وقرّب خطوتك من هدفك',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<UserDataProvider>().userName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 23, 20, 35),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _animatedSection(
                        index: 0,
                        child: _sectionHeader(
                          title: 'الإعدادات',
                          subtitle: 'إدارة حسابك وتخصيص تجربتك في مسار',
                        ),
                      ),
                      const SizedBox(height: 25),

                      _animatedSection(
                        index: 1,
                        child: _profileCard(userName),
                      ),
                      const SizedBox(height: 25),

                      _animatedSection(
                        index: 2,
                        child: _motivationCard(),
                      ),
                      const SizedBox(height: 18),

                      _animatedSection(
                        index: 3,
                        child: _motivationSettingsCard(),
                      ),
                      const SizedBox(height: 31),

                      _animatedSection(
                        index: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(
                              'عام',
                              subtitle: 'معلومات عن التطبيق',
                            ),
                            _settingsTile(
                              icon: Icons.info_outline_rounded,
                              title: 'عن التطبيق',
                              subtitle: 'اعرف أكتر عن مسار وفكرته',
                              onTap: _openAbout,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),

                      _animatedSection(
                        index: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(
                              'إدارة البيانات',
                              subtitle: 'التحكم في بياناتك المحفوظة',
                            ),
                            _settingsTile(
                              icon: Icons.delete_outline_rounded,
                              title: 'حذف جميع البيانات',
                              subtitle: 'حذف بياناتك المحفوظة من التطبيق',
                              iconColor: AppColors.danger,
                              isDanger: true,
                              onTap: _confirmDelete,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      _animatedSection(
                        index: 5,
                        child: _footer(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Edit Name Dialog
// ============================================================

class _EditNameDialog extends StatefulWidget {
  final String initialName;
  final ValueChanged<String> onSave;

  const _EditNameDialog({
    required this.initialName,
    required this.onSave,
  });

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.initialName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final newName = _controller.text.trim();

    Navigator.of(context).pop();
    widget.onSave(newName);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(27),
        side: BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.accent,
                          AppColors.secondaryDark,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.onAccent,
                      size: 29,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'تعديل الاسم',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'اكتب الاسم اللي تحب يظهر في حسابك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 23),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  maxLength: 30,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اسمك',
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.accent,
                      size: 21,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    counterStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.danger,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.danger,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الاسم مينفعش يكون فاضي';
                    }

                    if (value.trim().length < 2) {
                      return 'اكتب اسم مكوّن من حرفين على الأقل';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                          minimumSize: const Size(0, 49),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.onAccent,
                          elevation: 0,
                          minimumSize: const Size(0, 49),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'حفظ التعديل',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
