/// Minimal English / Bangla strings. Keys missing in Bangla fall back to English.
class L10n {
  const L10n(this.bangla);
  final bool bangla;

  static const _en = {
    'tagline': 'Your AI-powered pocket food detective',
    'scan': 'Scan Food',
    'camera': 'Take a photo',
    'gallery': 'Choose from gallery',
    'recent': 'Recent scans',
    'noScans': 'No scans yet. Scan your first food!',
    'history': 'History',
    'analyzing': 'Checking your food…',
    'result': 'Scan result',
    'detected': 'Detected',
    'freshness': 'Freshness',
    'safety': 'Safety score',
    'risks': 'Spoilage & safety risks',
    'nutrition': 'Nutrition',
    'portion': 'Portion estimate',
    'budget': 'Budget tip',
    'fresh': 'Fresh',
    'checkFirst': 'Check before eating',
    'spoiled': 'Likely spoiled',
    'disclaimer':
        'Based on a photo only. It cannot detect bacteria, chemicals or formalin. When in doubt, throw it out.',
    'notFood': "This doesn't look like food. Please try another photo.",
    'noInternet': 'No internet connection. Please check and try again.',
    'rateLimited': 'Too many scans. Please wait a minute.',
    'tooLarge': 'The photo is too large. Please try again.',
    'notConfigured': 'App is not configured. Please update the app.',
    'failed': 'Could not analyze right now. Please try again.',
    'clear': 'Clear history',
    'error': 'Could not open the image. Please try again.',
  };

  static const _bn = {
    'tagline': 'আপনার পকেটের AI খাদ্য গোয়েন্দা',
    'scan': 'খাবার স্ক্যান করুন',
    'camera': 'ছবি তুলুন',
    'gallery': 'গ্যালারি থেকে নিন',
    'recent': 'সাম্প্রতিক স্ক্যান',
    'noScans': 'এখনো কোনো স্ক্যান নেই। প্রথম খাবারটি স্ক্যান করুন!',
    'history': 'ইতিহাস',
    'analyzing': 'আপনার খাবার পরীক্ষা করা হচ্ছে…',
    'result': 'স্ক্যানের ফলাফল',
    'detected': 'শনাক্ত হয়েছে',
    'freshness': 'তাজা অবস্থা',
    'safety': 'নিরাপত্তা স্কোর',
    'risks': 'নষ্ট হওয়া ও নিরাপত্তা ঝুঁকি',
    'nutrition': 'পুষ্টিগুণ',
    'portion': 'পরিমাণের অনুমান',
    'budget': 'বাজেট টিপস',
    'fresh': 'তাজা',
    'checkFirst': 'খাওয়ার আগে দেখে নিন',
    'spoiled': 'সম্ভবত নষ্ট',
    'disclaimer':
        'শুধু ছবির ভিত্তিতে। এটি জীবাণু, রাসায়নিক বা ফরমালিন শনাক্ত করতে পারে না। সন্দেহ হলে খাবেন না।',
    'notFood': 'এটি খাবার মনে হচ্ছে না। অন্য ছবি দিয়ে চেষ্টা করুন।',
    'noInternet': 'ইন্টারনেট সংযোগ নেই। দেখে আবার চেষ্টা করুন।',
    'rateLimited': 'অনেক বেশি স্ক্যান হয়েছে। এক মিনিট অপেক্ষা করুন।',
    'tooLarge': 'ছবিটি অনেক বড়। আবার চেষ্টা করুন।',
    'notConfigured': 'অ্যাপটি ঠিকমতো সেট করা নেই। অ্যাপ আপডেট করুন।',
    'failed': 'এখন বিশ্লেষণ করা যাচ্ছে না। আবার চেষ্টা করুন।',
    'clear': 'ইতিহাস মুছুন',
    'error': 'ছবিটি খোলা যায়নি। আবার চেষ্টা করুন।',
  };

  String t(String key) => (bangla ? _bn[key] : null) ?? _en[key] ?? key;
}
