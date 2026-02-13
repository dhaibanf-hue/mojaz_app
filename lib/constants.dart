import 'package:flutter/material.dart';
import 'models/book.dart';
import 'models/author.dart';

class AppColors {
  // Brand Colors
  static const Color primaryBg = Color(0xFF0F3D3E);
  static const Color darkBg = Color(0xFF0A2627);
  static const Color logo = Color(0xFFFFFFFF);
  static const Color primaryButton = Color(0xFFFF6D00);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF00BFA5);
  
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF5F5F5);
  static const Color secondaryText = Color(0xFF757575);
  static const Color success = Color(0xFF28A745);
  static const Color gold = Color(0xFFFFD700);
  static const Color aiChatBubble = Color(0xFFE3F2FD);
}

final List<Author> dummyAuthors = [
  Author(id: 'a1', name: 'تشارلز دويج', avatar: 'https://picsum.photos/seed/a1/100/100', bio: 'صحفي ومؤلف أمريكي حائز على جوائز.'),
  Author(id: 'a2', name: 'روبرت كيوساكي', avatar: 'https://picsum.photos/seed/a2/100/100', bio: 'مستثمر ورجل أعمال ومؤلف كتب التمويل الشخصي.'),
  Author(id: 'a3', name: 'دانييل جولمان', avatar: 'https://picsum.photos/seed/a3/100/100', bio: 'عالم نفس وصحفي علمي معروف بكتبه عن الذكاء العاطفي.'),
  Author(id: 'a4', name: 'ستيفن كوفي', avatar: 'https://picsum.photos/seed/a4/100/100', bio: 'كاتب ومستشار إداري وأكاديمي أمريكي.'),
];

final List<Book> dummyBooks = [
  Book(
    id: '1',
    title: 'قوة العادات',
    author: 'تشارلز دويج',
    cover: 'https://picsum.photos/seed/habit/400/600',
    rating: 4.8,
    category: 'تطوير ذات',
    pageCount: 371,
    description: 'يستعرض هذا الكتاب كيف تتشكل العادات وكيف يمكننا تغييرها لتحسين حياتنا الشخصية والعملية من خلال فهم الحلقة العصبية المكونة من الإشارة والروتين والمكافأة.',
    targetAudience: 'الأشخاص الراغبين في تحسين إنتاجيتهم، وبناء عادات صحية جديدة، أو كسر الأنماط السلبية في حياتهم اليومية والمهنية.',
    isPremium: false,
    audioUrl: 'https://drive.google.com/uc?export=download&id=10SKrc85ZzgvoYLrCgyTbCoLFYNRx6prK',
  ),
  Book(
    id: '2',
    title: 'الأب الغني والأب الفقير',
    author: 'روبرت كيوساكي',
    cover: 'https://picsum.photos/seed/money/400/600',
    rating: 4.9,
    category: 'إدارة أعمال',
    pageCount: 336,
    description: 'كتاب كلاسيكي في التمويل الشخصي يشرح الفرق بين الأصول والالتزامات وأهمية الذكاء المالي في تحقيق الثراء والاستقلال المادي.',
    targetAudience: 'الشباب المبتدئين في عالم الاستثمار، وكل من يسعى لتحقيق الاستقلال المالي وفهم أسرار إدارة الأموال بعيداً عن الوظيفة التقليدية.',
    isPremium: true,
    audioUrl: 'https://cdn.pixabay.com/audio/2022/03/10/audio_c8c8a73456.mp3',
  ),
  Book(
    id: '3',
    title: 'الذكاء العاطفي',
    author: 'دانييل جولمان',
    cover: 'https://picsum.photos/seed/eq/400/600',
    rating: 4.7,
    category: 'علم نفس',
    pageCount: 352,
    description: 'لماذا يمكن أن يكون الذكاء العاطفي أكثر أهمية من الذكاء العقلي في النجاح المهني والعلاقات الإنسانية.',
    targetAudience: 'القادة، المديرين، والمعلمين، وأي شخص يرغب في تحسين تواصله مع الآخرين وفهم مشاعره والتحكم في انفعالاته بشكل إيجابي.',
    isPremium: false,
    audioUrl: 'https://cdn.pixabay.com/audio/2022/03/10/audio_c8c8a73456.mp3',
  ),
  Book(
    id: '4',
    title: 'العادات السبع',
    author: 'ستيفن كوفي',
    cover: 'https://picsum.photos/seed/seven/400/600',
    rating: 4.8,
    category: 'تطوير ذات',
    pageCount: 381,
    description: 'من أكثر الكتب مبيعاً في العالم، يشرح المبادئ الأساسية للفعالية الشخصية والاعتماد المتبادل لتحقيق النجاح المستدام.',
    targetAudience: 'الأفراد الطموحين الذين يسعون للتميز القيادي، والطلاب، وكل من يبحث عن منهجية متكاملة لترتيب أولويات حياته.',
    isPremium: false,
    audioUrl: 'https://cdn.pixabay.com/audio/2022/03/10/audio_c8c8a73456.mp3',
  ),
  Book(
    id: '5',
    title: 'مقدمة ابن خلدون',
    author: 'ابن خلدون',
    cover: 'https://picsum.photos/seed/history/400/600',
    rating: 5.0,
    category: 'تاريخ',
    pageCount: 1200,
    description: 'عمل موسوعي يتناول العمران البشري والاجتماع الإنساني وأسباب نهوض الأمم وسقوطها.',
    targetAudience: 'عشاق التاريخ والاجتماع، والباحثين في العلوم السياسية، وكل من يريد فهم الجذور العميقة لحركة المجتمعات البشرية.',
    isPremium: true,
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  ),
];
