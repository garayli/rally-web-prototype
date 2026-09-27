// Profile choice lists shared by the signup wizard and EditProfileScreen, so
// both write identical values to profiles.sports / skill_level /
// available_days / time_prefs.

/// (emoji, value, subtitle)
const sportOptions = [
  ('🎾', 'Tenis', 'Tekler & çiftler'),
  ('🏓', 'Padel', 'Raket sporu'),
  ('🏸', 'Badminton', 'İç mekan & açık alan'),
  ('🔲', 'Squash', 'Kort sporu'),
];

/// (emoji, value, subtitle)
const skillOptions = [
  ('🟢', 'Başlangıç', '1 yıldan az — temelleri öğreniyor'),
  ('🟡', 'Orta Seviye', '1–4 yıl — rahatça ralli yapıyor'),
  ('🟠', 'İleri Seviye', 'Rekabetçi — güçlü genel oyun'),
  ('🔴', 'Uzman', 'Turnuva seviyesi — en iyi oyun'),
];

const dayOptions = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

/// (emoji, value, time range)
const timeOptions = [
  ('🌅', 'Sabah', '06:00–12:00'),
  ('☀️', 'Öğleden Sonra', '12:00–18:00'),
  ('🌙', 'Akşam', '18:00–23:00'),
];

/// Starting NTRP for each self-reported skill level, so Player.skillLabel
/// stays consistent with the level the user picked.
const ntrpBySkillLevel = {
  'Başlangıç': 2.0,
  'Orta Seviye': 3.5,
  'İleri Seviye': 4.5,
  'Uzman': 5.5,
};
