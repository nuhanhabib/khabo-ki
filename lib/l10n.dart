/// Minimal English / Bangla strings. Keys missing in Bangla fall back to English.
class L10n {
  const L10n(this.bangla);
  final bool bangla;

  static const _en = {
    'slogan': 'Eat like a Boss,\nnot like a Victim.',
    'greeting': 'What are you eating today?',
    'tagline': 'Your AI-powered pocket food detective',
    'scan': 'Scan Food',
    'camera': 'Take photo',
    'gallery': 'Choose from gallery',
    'recent': 'Recent scans',
    'seeAll': 'See all',
    'noScans': 'No scans yet — scan your first food!',
    'history': 'Scan History',
    'search': 'Search your scans…',
    'noMatch': 'No scans match your search.',
    'analyzing': 'Checking your food…',
    'analyzingSub':
        'Analyzing image and checking freshness, safety and nutrition.',
    'result': 'Scan Result',
    'detected': 'Detected items',
    'safety': 'Safety score',
    'risks': 'Spoilage & safety risks',
    'noRisks': 'No major risk found.',
    'nutrition': 'Nutrition',
    'perServing': '(per serving, approx.)',
    'portion': 'Portion estimate',
    'budget': 'Budget tip',
    'fresh': 'Fresh',
    'okay': 'Okay',
    'spoiled': 'Likely spoiled',
    'freshDesc': 'Good quality and safe to eat.',
    'okayDesc': 'Looks okay. Check smell and texture before eating.',
    'spoiledDesc': 'Signs of spoilage. Better not to eat it.',
    'disclaimer':
        'Based on a photo only. Cannot detect bacteria, chemicals or formalin.',
    'retry': 'Retry',
    'tryAgain': 'Try again',
    'notFoodTitle': "That doesn't look like food",
    'notFood': "We couldn't find any food in the photo. Please try a photo of a meal or an ingredient (e.g. fish, rice, vegetables, fruits).",
    'noInternetTitle': 'No internet connection',
    'noInternet': "It seems you're offline. Check your internet connection and try again.",
    'rateLimitedTitle': 'Too many scans',
    'rateLimited': "You've made many checks. Try again in a minute.",
    'failedTitle': 'Something went wrong',
    'failed': 'Could not analyze right now. Please try again.',
    'tooLarge': 'The photo is too large. Please try another photo.',
    'notConfigured': 'App is not configured. Please update the app.',
    'clear': 'Clear history',
    'error': 'Could not open the image. Please try again.',
  };

  static const _bn = {
    'slogan': 'বসের মতো খান,\nভুক্তভোগীর মতো নয়।',
    'greeting': 'আজ কী খাচ্ছেন?',
    'tagline': 'আপনার AI-পাওয়ার্ড পকেট ফুড ডিটেকটিভ',
    'scan': 'খাবার স্ক্যান করুন',
    'camera': 'ছবি তুলুন',
    'gallery': 'গ্যালারি থেকে নিন',
    'recent': 'সাম্প্রতিক স্ক্যান',
    'seeAll': 'সব দেখুন',
    'noScans': 'এখনও কোনো স্ক্যান নেই — আপনার প্রথম খাবার স্ক্যান করুন!',
    'history': 'স্ক্যানের ইতিহাস',
    'search': 'স্ক্যান খুঁজুন…',
    'noMatch': 'কোনো স্ক্যান মেলেনি।',
    'analyzing': 'আপনার খাবার পরীক্ষা করা হচ্ছে…',
    'analyzingSub':
        'ছবি বিশ্লেষণ করে তাজা অবস্থা, নিরাপত্তা ও পুষ্টি দেখা হচ্ছে।',
    'result': 'স্ক্যানের ফলাফল',
    'detected': 'শনাক্ত খাবার',
    'safety': 'নিরাপত্তা স্কোর',
    'risks': 'নষ্ট হওয়ার ও নিরাপত্তা ঝুঁকি',
    'noRisks': 'এখনই কোনো বড় ঝুঁকি নেই।',
    'nutrition': 'পুষ্টিগুণ',
    'perServing': '(প্রতি পরিবেশন, আনুমানিক)',
    'portion': 'পরিমাণের হিসাব',
    'budget': 'বাজেট টিপ',
    'fresh': 'তাজা',
    'okay': 'মোটামুটি',
    'spoiled': 'সম্ভবত নষ্ট',
    'freshDesc': 'নিরাপদ এবং ভালো মানের খাদ্য।',
    'okayDesc': 'মোটামুটি ভালো। খাওয়ার আগে গন্ধ ও অবস্থা দেখে নিন।',
    'spoiledDesc': 'নষ্ট হওয়ার লক্ষণ আছে। না খাওয়াই ভালো।',
    'disclaimer': 'শুধু ছবির ভিত্তিতে বিশ্লেষণ। ব্যাকটেরিয়া, রাসায়নিক বা ফরমালিন শনাক্ত করতে পারে না।',
    'retry': 'আবার চেষ্টা',
    'tryAgain': 'আবার চেষ্টা করুন',
    'notFoodTitle': 'এটি খাবার মনে হচ্ছে না',
    'notFood': 'ছবিতে কোনো খাবার পাওয়া যায়নি। খাবার বা উপকরণের ছবি দিন (যেমন মাছ, ভাত, সবজি, ফল)।',
    'noInternetTitle': 'ইন্টারনেট সংযোগ নেই',
    'noInternet':
        'মনে হচ্ছে আপনি অফলাইনে আছেন। ইন্টারনেট সংযোগ দেখে আবার চেষ্টা করুন।',
    'rateLimitedTitle': 'অনেক বেশি স্ক্যান',
    'rateLimited':
        'আপনি অনেকবার পরীক্ষা করেছেন। এক মিনিট পরে আবার চেষ্টা করুন।',
    'failedTitle': 'কিছু একটা সমস্যা হয়েছে',
    'failed': 'এখন বিশ্লেষণ করা যাচ্ছে না। আবার চেষ্টা করুন।',
    'tooLarge': 'ছবিটি অনেক বড়। অন্য ছবি দিয়ে চেষ্টা করুন।',
    'notConfigured': 'অ্যাপটি ঠিকমতো সেট করা নেই। অ্যাপ আপডেট করুন।',
    'clear': 'ইতিহাস মুছুন',
    'error': 'ছবিটি খোলা যায়নি। আবার চেষ্টা করুন।',
  };

  static const _monthsEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _monthsBn = [
    'জানু',
    'ফেব্রু',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টে',
    'অক্টো',
    'নভে',
    'ডিসে',
  ];
  static const _bnDigits = '০১২৩৪৫৬৭৮৯';

  String t(String key) => (bangla ? _bn[key] : null) ?? _en[key] ?? key;

  /// "Jan 20, 2026" or "২০ জানু ২০২৬".
  String date(DateTime d) {
    if (!bangla) return '${_monthsEn[d.month - 1]} ${d.day}, ${d.year}';
    String bn(int n) =>
        n.toString().split('').map((c) => _bnDigits[int.parse(c)]).join();
    return '${bn(d.day)} ${_monthsBn[d.month - 1]} ${bn(d.year)}';
  }
}
