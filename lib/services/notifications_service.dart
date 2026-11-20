
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:masar/models/habits_model.dart';
import 'package:masar/models/tasks_model.dart';
import 'package:masar/Screens/alarm_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {

  final FlutterLocalNotificationsPlugin plugin =
  FlutterLocalNotificationsPlugin();

  static const int _habitIdOffset = 1000000;
  static const int _taskSnoozeOffset = 2000000;
  static const int _habitSnoozeOffset = 3000000;
  static const int _motivationOffset = 4000000;

  static int deadlineId(int key) => key * 2;
  static int startId(int key) => key * 2 + 1;

  static int habitId(int key) => _habitIdOffset + key;
  static int taskSnoozeId(int key) => _taskSnoozeOffset + key;
  static int habitSnoozeId(int key) => _habitSnoozeOffset + key;

  static const String _taskChannelId = 'tasks_channel_v3';
  static const String _habitChannelId = 'habits_alarm_channel_v4';
  static const String _motivationChannelId = 'motivation_channel_v1';

  static const String _taskDone = 'task_done';
  static const String _taskNotDone = 'task_not_done';
  static const String _taskSnooze = 'task_snooze';

  static const String _habitDone = 'habit_done';
  static const String _habitSnooze = 'habit_snooze';

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static int? pendingHabitAlarmKey;

  static bool _alarmOpening = false;

  static void openHabitAlarm(int habitKey) {
    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      pendingHabitAlarmKey = habitKey;
      return;
    }

    if (_alarmOpening) return;

    pendingHabitAlarmKey = null;
    _alarmOpening = true;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => AlarmScreen(habitKey: habitKey),
      ),
    ).then((_) {
      _alarmOpening = false;
    });
  }

  static void openPendingAlarm() {
    final key = pendingHabitAlarmKey;

    if (key != null) {
      openHabitAlarm(key);
    }
  }

  static const List<String> _motivationalMessages = [
    // ===== البداية والاستمرارية =====
    'خطوة صغيرة النهارده ممكن تعمل فرق كبير بكرة.',
    'مش لازم تكون مستعد 100% عشان تبدأ.\nابدأ، والاستعداد هييجي في الطريق.',
    'ابدأ بالخطوة اللي قدامك، وسيب الباقي على وقته.',
    'كل إنجاز كبير كان في يوم من الأيام مجرد بداية صغيرة.',
    'مش مهم سرعتك قد إيه، المهم إنك لسه بتتحرك.',
    'كل يوم جديد فرصة إنك تكون أحسن من امبارح.',
    'الطريق الطويل بيتقطع بخطوات صغيرة وثابتة.',
    'ابدأ حتى لو مش حاسس بالحماس.\nالالتزام مش محتاج مزاج.',
    'النهارده فرصة جديدة متضيعهاش في انتظار بكرة.',
    'أهم خطوة في أي رحلة هي إنك تقرر تبدأ.',
    'مش مطلوب منك تعمل كل حاجة النهارده.\nمطلوب منك تعمل اللي تقدر عليه.',
    'الاستمرارية بتعمل حاجات الحماس عمره ما يقدر يعملها.',
    'كل مرة بترجع فيها بعد ما تتوقف، أنت بتتعلم الاستمرار.',
    'متستناش الظروف المثالية.\nابدأ بالظروف اللي عندك.',
    'خلي كل يوم فيه حاجة واحدة على الأقل تقربك من هدفك.',
    'التغيير مش بيحصل في يوم وليلة، لكنه بيبدأ بقرار.',
    'الخطوات الهادية والثابتة بتوصل لبعيد.',
    'مش لازم تشوف النتيجة دلوقتي عشان تكون بتتقدم.',
    'ابدأ صغير، استمر، وسيب النتائج تتكلم.',
    'كل بداية جديدة فرصة تكتب بيها حكاية مختلفة.',

    // ===== الانضباط والالتزام =====
    'الانضباط إنك تعمل الصح حتى لما مش تكون حابب تعمله.',
    'خليك ملتزم بوعدك لنفسك.\nده أهم وعد ممكن تحافظ عليه.',
    'كل مرة بتلتزم فيها، بتقرب من الشخص اللي عايز تكونه.',
    'متخليش مزاجك يتحكم في مستقبلك.',
    'النجاح مش قرار بتاخده مرة.\nالنجاح مجموعة قرارات بتكررها كل يوم.',
    'الانضباط النهارده هو الحرية اللي هتشكر نفسك عليها بكرة.',
    'اعمل اللي عليك حتى لو محدش شايف مجهودك.',
    'خلي أفعالك تثبت لنفسك إنك شخص يعتمد عليه.',
    'مش كل يوم هيكون سهل، بس كل يوم تقدر تختار تكمل.',
    'التزامك في الأيام الصعبة هو اللي بيصنع الفرق.',
    'متحطش أهداف أكبر من استعدادك للالتزام بيها.',
    'خليك ثابت على مبادئك حتى لو الحماس اختفى.',
    'الإنجاز الحقيقي إنك تقدر تعتمد على نفسك.',
    'كل عادة كويسة بتبنيها هي استثمار في مستقبلك.',
    'متفاوضش مع التسويف كل ما يطلب منك تأجل.',
    'خلي الالتزام أسلوب حياة، مش مجرد تحدي مؤقت.',
    'الشخص اللي عايز تبقى عليه محتاج منك قرارات النهارده.',
    'الفرق بين اللي بيحلم واللي بيوصل هو الاستمرار في التنفيذ.',
    'احترم وقتك، لأنه جزء من عمرك مش هيرجع.',
    'خليك الشخص اللي بيكمل اللي بدأه.',

    // ===== المذاكرة والتعلم =====
    'كل معلومة بتتعلمها النهارده ممكن تفتحلك باب بكرة.',
    'ساعة تركيز حقيقي أحسن من ساعات كتير من غير هدف.',
    'متستصغرش صفحة بتذاكرها.\nكل صفحة بتقربك من هدفك.',
    'مستقبلك بيتبني في اللحظات اللي بتختار فيها تتعلم.',
    'مش لازم تفهم كل حاجة من أول مرة.\nالمهم متستسلمش للمعلومة.',
    'كل سؤال بتحاول تحله بيقوي طريقة تفكيرك.',
    'الغلط في المذاكرة مش فشل.\nده جزء من طريق الفهم.',
    'ركز في اللي بتذاكره دلوقتي، مش في اللي لسه وراك.',
    'النجاح الدراسي محتاج صبر وتنظيم واستمرارية.',
    'كل دقيقة بتستثمرها في التعلم ليها قيمة.',
    'متقارنش مستواك بحد.\nقارن فهمك النهارده بفهمك امبارح.',
    'المذاكرة مش سباق سرعة، هي رحلة فهم وتراكم.',
    'لما تتعب من المذاكرة، افتكر أنت بدأت ليه.',
    'كل مسألة بتحلها بتزود ثقتك في قدراتك.',
    'المعلومة اللي بتفهمها النهارده بتفضل معاك أكتر.',
    'خد استراحة لما تحتاج، وارجع كمل من غير تأنيب.',
    'مش مطلوب تحفظ كل حاجة بسرعة.\nالمهم تفهم وتعرف تطبق.',
    'خلي فضولك أكبر من خوفك من المواد الصعبة.',
    'كل مجهود بتبذله في تعليم نفسك مش بيضيع.',
    'الوقت اللي بتقضيه في تطوير عقلك من أفضل استثماراتك.',

    // ===== التركيز ومقاومة المشتتات =====
    'خد دقيقة وارجع ركز على اللي مهم بالنسبالك.',
    'مش كل حاجة تستحق انتباهك.\nاختار بعناية إيه اللي ياخد من وقتك.',
    'اقفل باب المشتتات وافتح باب الإنجاز.',
    'كل مرة بتقاوم فيها التشتت، بتقوي قدرتك على التركيز.',
    'متديش حاجة مؤقتة فرصة تسرق منك هدف طويل المدى.',
    'ركز على مهمة واحدة، واديها حقها من وقتك.',
    'وقتك أغلى من إنك تسيبه يضيع من غير ما تحس.',
    'مش لازم ترد على كل حاجة فورًا.\nفي حاجات تقدر تستنى.',
    'اختار هدفك قبل ما تختار تفتح موبايلك.',
    'التركيز مش إنك تعمل حاجات كتير.\nالتركيز إنك تعمل الحاجة الصح.',
    'كل دقيقة بتضيعها في التشتت بتبعدك عن اللي عايز تحققه.',
    'متسمحش للضوضاء اللي حواليك تغطي على صوت أهدافك.',
    'حافظ على انتباهك، لأنه من أغلى مواردك.',
    'ابدأ المهمة قبل ما عقلك يلاقي ألف سبب لتأجيلها.',
    'خلي أولويتك واضحة، والباقي هيبقى أسهل.',
    'مش كل إشعار محتاج منك استجابة.',
    'لما تلاقي نفسك مشتت، ارجع بهدوء من غير ما تلوم نفسك.',
    'احمي وقتك من الحاجات اللي مش بتضيف لحياتك.',
    'الهدوء والتركيز ممكن ينجزوا أكتر من العجلة.',
    'اختار إنك تكون حاضر في يومك بدل ما يومك يعدي منك.',

    // ===== الطموح وتحقيق الأحلام =====
    'حلمك يستاهل إنك تتعب عشانه كل يوم.',
    'متخليش صعوبة الطريق تنسيك جمال الهدف.',
    'المستقبل اللي بتحلم بيه محتاج شغل منك في الحاضر.',
    'خلي طموحك أكبر من خوفك من الفشل.',
    'كل يوم بتشتغل فيه على نفسك هو استثمار في حلمك.',
    'مش لازم الناس كلها تفهم حلمك.\nالمهم إنك تكون فاهمه ومستعد تسعى له.',
    'أهدافك الكبيرة محتاجة صبر أكبر من استعجالك.',
    'خلي عندك سبب يخليك تقوم كل يوم وتحاول من جديد.',
    'النجاح مش صدفة، النجاح نتيجة اختيارات ومجهود متراكم.',
    'أنت مش بعيد عن هدفك زي ما ممكن تتخيل.',
    'متقللش من قيمة نفسك بسبب إنك لسه موصلتش.',
    'كل إنجاز صغير هو دليل إنك قادر تكمل.',
    'ابني مستقبلك بدل ما تفضل مستني الظروف تبنيهولك.',
    'اللي بتزرعه في نفسك النهارده هتحصد نتيجته مع الوقت.',
    'خليك طموح، بس افتكر إن الطموح محتاج خطة وتنفيذ.',
    'متخليش خوفك من البداية يمنعك من الوصول للنهاية.',
    'خلي أحلامك سبب للسعي، مش مجرد أفكار في دماغك.',
    'الطريق لهدفك يستحق إنك تدي له وقتك واهتمامك.',
    'كل يوم بتطور فيه نفسك هو خطوة ناحية حياة أفضل.',
    'أنت مسؤول عن السعي، والنتائج ليها وقتها.',

    // ===== الصبر والتعامل مع الصعوبات =====
    'مش كل يوم صعب معناه إنك ماشي في الطريق الغلط.',
    'الصبر مش انتظار النتيجة، الصبر إنك تفضل تسعى لحد ما توصل.',
    'لو وقعت في يوم، متخليش ده يمنعك تبدأ تاني.',
    'الأيام الصعبة مش دايمًا بتفضل صعبة.',
    'اتعلم من اللي فات، وركز في اللي تقدر تعمله دلوقتي.',
    'متخليش غلطة واحدة تنسيك كل المرات اللي نجحت فيها.',
    'كل تحدي بيكشفلك جانب جديد من قدراتك.',
    'مش لازم تكون قوي طول الوقت.\nبس حاول متفقدش رغبتك في المحاولة.',
    'خد وقتك في التعلم، ومتستعجلش على نفسك.',
    'التقدم البطيء أفضل من الوقوف في مكانك.',
    'النتائج محتاجة وقت، زي ما الزرع محتاج وقت عشان يثمر.',
    'لما الطريق يصعب، افتكر السبب اللي خلاك تبدأ.',
    'الفشل تجربة بتعلمك إزاي تحاول بطريقة أفضل.',
    'متقيسش نجاحك بيوم واحد مش على مزاجك.',
    'كل عقبة بتعدي منها بتسيب عندك خبرة جديدة.',
    'سامح نفسك على التقصير، بس متستسلمش ليه.',
    'مش مطلوب منك تكون مثالي عشان تكون ناجح.',
    'خلي عندك مرونة تغير خطتك، مش هدفك.',
    'أحيانًا التقدم الحقيقي بيكون إنك متستسلمش.',
    'اصبر على نفسك، أنت لسه في مرحلة البناء.',

    // ===== تقدير الذات والثقة بالنفس =====
    'افتخر بمجهودك حتى لو النتيجة لسه موصلتش.',
    'قيمتك مش مرتبطة بعدد المهام اللي خلصتها النهارده.',
    'أنت بتتعلم وبتتغير، وده في حد ذاته تقدم.',
    'متقللش من إنجازاتك لمجرد إنها صغيرة في نظرك.',
    'ثق في قدرتك على التعلم والتطور.',
    'أنت مش مطالب تثبت نفسك لكل الناس.',
    'خلي هدفك إنك تبقى أفضل من نسختك السابقة.',
    'اتكلم مع نفسك بنفس الرحمة اللي بتعامل بيها غيرك.',
    'كل مرة بتختار فيها الصح، أنت بتبني ثقتك بنفسك.',
    'متخليش مقارنة نفسك بغيرك تنسيك رحلتك الخاصة.',
    'أنت تستحق تدي لنفسك فرصة حقيقية للنجاح.',
    'اعترف بتقدمك، حتى لو لسه قدامك طريق طويل.',
    'خليك فخور إنك بتحاول رغم كل التحديات.',
    'متربطش ثقتك بنفسك بيوم ناجح أو يوم صعب.',
    'كل مهارة جديدة بتتعلمها بتفتحلك إمكانيات جديدة.',
    'احترم رحلتك ومتستعجلش نتائجها.',
    'أنت مش نسخة من حد، وليك طريقك الخاص.',
    'خلي إنجازاتك تتكلم بدل ما تستنى تقدير الآخرين.',
    'ابدأ بالإمكانيات اللي عندك، وطورها مع الوقت.',
    'افتكر دايمًا إنك قادر تتعلم حاجة جديدة وتتحسن.',

    // ===== إدارة الوقت وتنظيم اليوم =====
    'خطط ليومك قبل ما اليوم يخططلك.',
    'كل مهمة بتخلصها بتخفف الحمل اللي على بالك.',
    'رتب أولوياتك، مش كل المهام ليها نفس الأهمية.',
    'ساعة من التنظيم ممكن توفر عليك ساعات من العشوائية.',
    'ابدأ بأهم مهمة بدل ما تبدأ بأسهل حاجة كل مرة.',
    'اليوم المنظم بيسيب مساحة للإنجاز والراحة مع بعض.',
    'متملأش جدولك بمهام أكتر من وقتك وطاقتك.',
    'خلي عندك خطة واضحة، حتى لو بسيطة.',
    'الوقت مش بيستنى حد، فاستثمره في اللي يستاهل.',
    'كل يوم بيعدي مش بيرجع.\nخليه يضيف لحياتك حاجة.',
    'قسم المهام الكبيرة لخطوات صغيرة تقدر تنفذها.',
    'متخليش كثرة المهام تمنعك من تنفيذ أول مهمة.',
    'خطط بذكاء، ونفذ بهدوء، وراجع تقدمك باستمرار.',
    'الإنجاز مش معناه إنك مشغول طول اليوم.',
    'سيب مساحة في يومك للراحة والطوارئ.',
    'مش كل يوم لازم يكون مليان مهام عشان يكون ناجح.',
    'استخدم وقتك بوعي، مش بضغط.',
    'لما ترتب يومك، بتدي لكل حاجة حقها.',
    'ابدأ يومك بهدف واضح وأنهه بتقييم بسيط.',
    'الوقت اللي بتخصصه لهدفك النهارده هو اللي بيصنع بكرة.',

    // ===== الراحة والتوازن =====
    'الراحة مش عكس الإنجاز.\nالراحة جزء من الاستمرارية.',
    'خد نفس عميق، وارجع كمل لما تكون مستعد.',
    'مش لازم تضغط على نفسك كل لحظة عشان تتقدم.',
    'اهتم بنفسك زي ما بتهتم بأهدافك.',
    'النوم الكويس والراحة بيساعدوك تكمل بشكل أفضل.',
    'متجلدش نفسك على يوم محتاج فيه تهدى.',
    'التوازن أهم من إنك تنجز على حساب كل حاجة تانية.',
    'خد استراحة من غير إحساس بالذنب، وبعدها ارجع لهدفك.',
    'مش كل توقف معناه تراجع.\nأحيانًا التوقف بيديك طاقة تكمل.',
    'اتعلم تفرق بين الكسل الحقيقي والإرهاق.',
    'حافظ على طاقتك عشان تقدر تستمر.',
    'الإنجاز الحقيقي إنك تقدر تكمل على المدى الطويل.',
    'عامل نفسك بصبر، زي ما بتتعامل مع أي حد بيتعلم.',
    'يوم هادي ومنظم ممكن يكون أفضل من يوم مزدحم.',
    'مش لازم تكسب كل معركة في نفس اليوم.',

    // ===== رسائل قصيرة وقوية =====
    'قوم وابدأ، لسه عندك فرصة.',
    'أفعالك النهارده هي بداية مستقبلك.',
    'خليك ثابت، حتى لو الطريق طويل.',
    'متأجلش حياتك لبكرة.',
    'كل محاولة ليها قيمة.',
    'ابدأ دلوقتي، مش بعد شوية.',
    'أنت بتبني حاجة أكبر من إنجاز يوم واحد.',
    'خلي هدفك دايمًا قدام عينك.',
    'الفرصة اللي في إيدك هي النهارده.',
    'متستسلمش لمجرد إن البداية صعبة.',
    'الإنجاز محتاج فعل، مش نية بس.',
    'خلي يومك شاهد على محاولتك.',
    'أحسن وقت تبدأ فيه هو الوقت اللي أنت فيه.',
    'متسيبش يومك يعدي من غير خطوة.',
    'كل يوم فرصة جديدة للتغيير.',
    'اللي بتعمله النهارده مهم.',
    'خليك أقوى من رغبتك في التأجيل.',
    'حافظ على وعدك لنفسك.',
    'الاستمرار هو سر الرحلة.',
    'لسه تقدر تعمل حاجة كويسة النهارده.',

    // ===== المعنى والنية والتطوير =====
    'خلي نيتك طيبة وسعيك صادق.',
    'اسعى بجد، وسيب النتائج على ربنا.',
    'ابدأ يومك بنية كويسة وخطوة مفيدة.',
    'مش كل نجاح بيتقاس بالأرقام.\nفي نجاح اسمه إنك بقيت أحسن.',
    'خلي نجاحك سبب إنك تنفع نفسك واللي حواليك.',
    'الوقت نعمة، فحاول تستخدمه في اللي يرضي ربنا.',
    'كل عمل صغير بنية صادقة ليه قيمة.',
    'متنساش تشكر ربنا على كل خطوة قدرت تحققها.',
    'خلي السعي مستمر، وخلي قلبك مطمئن.',
    'التطور الحقيقي مش بس في اللي بتعرف تعمله، لكن كمان في اللي بتبقى عليه.',
    'النية بداية الطريق، والعمل هو اللي بيكمله.',
    'خلي عندك هدف تعيش عشانه، ومبدأ متتنازلش عنه.',
    'مش لازم كل الناس تشوف تعبك عشان يكون ليه معنى.',
    'اشتغل على نفسك في هدوء، وسيب الأيام تظهر النتيجة.',
    'كل يوم بتختار فيه الخير لنفسك هو يوم يستحق التقدير.',
  ];

  bool _initialized = false;

  static const AndroidNotificationAction _taskDoneAction =
  AndroidNotificationAction(
    _taskDone,
    'خلصت المهمة',
    showsUserInterface: false,
  );

  static const AndroidNotificationAction _taskNotDoneAction =
  AndroidNotificationAction(
    _taskNotDone,
    'لسه مخلصتش',
    showsUserInterface: false,
  );

  static const AndroidNotificationAction _taskSnoozeAction =
  AndroidNotificationAction(
    _taskSnooze,
    'ذكرني بعد 5 دقايق',
    showsUserInterface: false,
  );

  static const AndroidNotificationAction _habitDoneAction =
  AndroidNotificationAction(
    _habitDone,
    'أنجزت العادة',
    showsUserInterface: false,
  );

  static const AndroidNotificationAction _habitSnoozeAction =
  AndroidNotificationAction(
    _habitSnooze,
    'بعد 5 دقايق',
    showsUserInterface: false,
  );

  static const AndroidNotificationDetails _taskDetails =
  AndroidNotificationDetails(
    _taskChannelId,
    'تذكيرات المهام',
    channelDescription: 'تذكيرات بداية وانتهاء المهام',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    actions: [
      _taskDoneAction,
      _taskNotDoneAction,
      _taskSnoozeAction,
    ],
  );

  static const AndroidNotificationDetails _habitDetails =
  AndroidNotificationDetails(
    _habitChannelId,
    'منبهات العادات',
    channelDescription: 'منبهات العادات اليومية',
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    enableVibration: true,
    category: AndroidNotificationCategory.alarm,
    fullScreenIntent: true,
    actions: [
      _habitDoneAction,
      _habitSnoozeAction,
    ],
  );

  static const AndroidNotificationDetails _motivationDetails =
  AndroidNotificationDetails(
    _motivationChannelId,
    'رسائل مسار التحفيزية',
    channelDescription: 'رسائل خفيفة لتشجيعك على الاستمرار',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    playSound: false,
    enableVibration: false,
  );


  Future<void> _resetHabitIfNeeded(HabitsModel habit) async {
    final lastCompleted = habit.lastCompletedDate;

    if (lastCompleted == null) return;

    final now = DateTime.now();

    final today = DateTime.utc(
      now.year,
      now.month,
      now.day,
    );

    final lastDay = DateTime.utc(
      lastCompleted.year,
      lastCompleted.month,
      lastCompleted.day,
    );

    final daysPassed = today.difference(lastDay).inDays;

    bool changed = false;

    if (daysPassed >= 1 && habit.habitCompleted) {
      habit.habitCompleted = false;
      changed = true;
    }

    if (daysPassed >= 2 && habit.streakCount != 0) {
      habit.streakCount = 0;
      changed = true;
    }

    if (changed) {
      await habit.save();
    }
  }


  Future<void> _initializeTimezone() async {
    tz_data.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(
        tz.getLocation(timezoneInfo.identifier),
      );
    } catch (_) {
    }
  }

  Future<void> initNotification() async {
    if (_initialized) return;

    WidgetsFlutterBinding.ensureInitialized();

    await _initializeTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
      notificationTapBackground,
    );

    // لا نوقف التطبيق لو المستخدم رفض إحدى الصلاحيات.
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    try {
      await androidPlugin?.requestNotificationsPermission();
    } catch (_) {}

    try {
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (_) {}

    try {
      await androidPlugin?.requestFullScreenIntentPermission();
    } catch (_) {}

    _initialized = true;

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('motivationRemindersEnabled') ?? false) {
      await scheduleMotivationalReminders();
    }

    // معرفة هل التطبيق اتفتح من إشعار عادة.
    final launchDetails =
    await plugin.getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final response = launchDetails?.notificationResponse;

      if (response != null && response.actionId == null) {
        _handleHabitPayload(response.payload);
      }
    }
  }

  static void _handleHabitPayload(String? payload) {
    if (payload == null) return;

    final parts = payload.split(':');

    if (parts.length != 2 || parts[0] != 'habit') return;

    final key = int.tryParse(parts[1]);

    if (key != null) {
      pendingHabitAlarmKey = key;
      openPendingAlarm();
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.actionId != null) {
      unawaited(_handleAction(response));
      return;
    }

    _handleHabitPayload(response.payload);
  }

  Future<void> completeHabitFromAlarm(int habitKey) async {
    await _ensureInitialized();
    await _handleHabitAction(habitKey, _habitDone);
  }

  Future<void> snoozeHabitFromAlarm(int habitKey) async {
    await _ensureInitialized();
    await _handleHabitAction(habitKey, _habitSnooze);
  }

  // ========================= TASK NOTIFICATIONS =========================

  Future<void> deadLineScheduleTaskNotification({
    required int taskKey,
    required String taskName,
    required DateTime taskDate,
  }) async {
    await _ensureInitialized();

    final scheduledDate = tz.TZDateTime.from(taskDate, tz.local);

    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await plugin.zonedSchedule(
      id: deadlineId(taskKey),
      title: 'حان وقت مراجعة مهمتك',
      body: 'لسه قدامك مهمة "$taskName". تقدر تبدأ دلوقتي.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: _taskDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'task:$taskKey',
    );
  }

  Future<void> startDateScheduleTaskNotification({
    required int taskKey,
    required String taskName,
    required DateTime startDate,
  }) async {
    await _ensureInitialized();

    final scheduledDate = tz.TZDateTime.from(startDate, tz.local);

    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await plugin.zonedSchedule(
      id: startId(taskKey),
      title: 'وقت البداية',
      body: 'جهّز نفسك وابدأ "$taskName".',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: _taskDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'task:$taskKey',
    );
  }

  Future<void> cancelTaskNotification(int taskKey) async {
    await plugin.cancel(id: deadlineId(taskKey));
    await plugin.cancel(id: startId(taskKey));
    await plugin.cancel(id: taskSnoozeId(taskKey));
  }

  Future<void> _scheduleTaskSnooze(int taskKey) async {
    await _ensureInitialized();

    final scheduledDate = tz.TZDateTime.now(tz.local).add(
      const Duration(minutes: 5),
    );

    await plugin.zonedSchedule(
      id: taskSnoozeId(taskKey),
      title: 'رجعنا نفكرك بمهمتك',
      body: 'خد الخطوة اللي كنت مأجلها وابدأ بهدوء.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: _taskDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'task:$taskKey',
    );
  }

  // ========================= HABIT NOTIFICATIONS =========================

  Future<void> scheduleHabitAlarm({
    required int habitKey,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    await _ensureInitialized();

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('Invalid habit alarm time');
    }

    final now = tz.TZDateTime.now(tz.local);

    var firstRing = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!firstRing.isAfter(now)) {
      firstRing = firstRing.add(const Duration(days: 1));
    }

    await plugin.zonedSchedule(
      id: habitId(habitKey),
      title: 'وقت عادتك',
      body: 'خصص وقتك لـ "$habitName". كل خطوة صغيرة بتفرق.',
      scheduledDate: firstRing,
      notificationDetails: const NotificationDetails(
        android: _habitDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'habit:$habitKey',
    );
  }

  Future<void> cancelHabitAlarm(int habitKey) async {
    await plugin.cancel(id: habitId(habitKey));
    await plugin.cancel(id: habitSnoozeId(habitKey));
  }

  Future<void> _scheduleHabitSnooze(int habitKey) async {
    await _ensureInitialized();

    final scheduledDate = tz.TZDateTime.now(tz.local).add(
      const Duration(minutes: 5),
    );

    await plugin.zonedSchedule(
      id: habitSnoozeId(habitKey),
      title: 'تذكير بعادتك',
      body: 'عدّى وقت التأجيل! ارجع كمل عادتك.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: _habitDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'habit:$habitKey',
    );
  }

  // ========================= MOTIVATIONAL NOTIFICATIONS =========================

  Future<void> setMotivationalRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('motivationRemindersEnabled', enabled);

    if (enabled) {
      await scheduleMotivationalReminders();
    } else {
      await cancelMotivationalReminders();
    }
  }

  Future<void> scheduleMotivationalReminders() async {
    await _ensureInitialized();

    const hours = [1, 3, 5, 7, 10, 12, 15, 17, 20, 22, 24];

    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < hours.length; i++) {
      final hour = hours[i];

      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
      );

      if (!scheduledDate.isAfter(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await plugin.zonedSchedule(
        id: _motivationOffset + i,
        title: 'رسالة من مسار',
        body: _motivationalMessages[
        i % _motivationalMessages.length],
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: _motivationDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelMotivationalReminders() async {
    for (int i = 0; i < 5; i++) {
      await plugin.cancel(id: _motivationOffset + i);
    }
  }

  // ========================= ACTION HANDLING =========================

  Future<void> _handleAction(NotificationResponse response) async {
    final action = response.actionId;
    final payload = response.payload ?? '';
    final parts = payload.split(':');

    if (parts.length != 2) return;

    final type = parts[0];
    final key = int.tryParse(parts[1]);

    if (key == null) return;

    if (type == 'task') {
      await _handleTaskAction(key, action);
    } else if (type == 'habit') {
      await _handleHabitAction(key, action);
    }
  }

  Future<void> _handleTaskAction(int key, String? action) async {
    if (!Hive.isBoxOpen('tasksBox')) return;

    final box = Hive.box<TasksModel>('tasksBox');
    final task = box.get(key);

    if (task == null) return;

    switch (action) {
      case _taskDone:
        if (!task.completed) {
          task.completed = true;
          await task.save();
        }

        await cancelTaskNotification(key);
        break;

      case _taskNotDone:
      // المهمة تظل غير مكتملة.
        break;

      case _taskSnooze:
        await _scheduleTaskSnooze(key);
        break;
    }
  }

  Future<void> _handleHabitAction(int key, String? action) async {
    if (!Hive.isBoxOpen('habitsBox')) return;

    final box = Hive.box<HabitsModel>('habitsBox');
    final habit = box.get(key);

    if (habit == null) return;
    await _resetHabitIfNeeded(habit);

    switch (action) {
      case _habitDone:
        if (!habit.habitCompleted) {
          habit
            ..habitCompleted = true
            ..streakCount += 1
            ..lastCompletedDate = DateTime.now();

          await habit.save();
        }

        // مهم: لا نلغي المنبه اليومي المتكرر عند إنجاز عادة اليوم.
        await plugin.cancel(id: habitSnoozeId(key));
        break;

      case _habitSnooze:
        await _scheduleHabitSnooze(key);
        break;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initNotification();
    }
  }

  Future<void> cancelAllNotifications() async {
    await _ensureInitialized();
    await plugin.cancelAll();
  }
}

// ========================= BACKGROUND CALLBACK =========================

@pragma('vm:entry-point')
Future<void> notificationTapBackground(
    NotificationResponse response,
    ) async {
  WidgetsFlutterBinding.ensureInitialized();

  tz_data.initializeTimeZones();

  try {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(timezoneInfo.identifier),
    );
  } catch (_) {}

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(TasksModelAdapter().typeId)) {
    Hive.registerAdapter(TasksModelAdapter());
  }

  if (!Hive.isAdapterRegistered(HabitsModelAdapter().typeId)) {
    Hive.registerAdapter(HabitsModelAdapter());
  }

  if (!Hive.isBoxOpen('tasksBox')) {
    await Hive.openBox<TasksModel>('tasksBox');
  }

  if (!Hive.isBoxOpen('habitsBox')) {
    await Hive.openBox<HabitsModel>('habitsBox');
  }

  final service = NotificationsService();

  const androidSettings = AndroidInitializationSettings(
    '@mipmap/launcher_icon',
  );

  const settings = InitializationSettings(
    android: androidSettings,
  );

  await service.plugin.initialize(
    settings: settings,
  );

  // منع إعادة طلب صلاحيات النظام من الـ Background Isolate.
  service._initialized = true;

  await service._handleAction(response);
}
