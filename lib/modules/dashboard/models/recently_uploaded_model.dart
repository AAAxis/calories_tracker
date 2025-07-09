class RecentlyUploadedModel {
  final String image;
  final String title;
  final String time;
  final String overalAllCalorie;
  final String proteinCalorie;
  final String fatsCalorie;
  final String carbsCalorie;

  RecentlyUploadedModel({
    required this.image,
    required this.title,
    required this.time,
    required this.overalAllCalorie,
    required this.proteinCalorie,
    required this.fatsCalorie,
    required this.carbsCalorie,
  });
}

List<RecentlyUploadedModel> recentlyUploadedList = [
  RecentlyUploadedModel(
    image: 'assets/images/burger.jpg',
    title: 'Burger',
    time: '14:53 PM',
    overalAllCalorie: '157 kCal',
    proteinCalorie: '56g',
    fatsCalorie: '84g',
    carbsCalorie: '85g',
  ),
  RecentlyUploadedModel(
    image: 'assets/images/pizza.jpg',
    title: 'Pizza',
    time: '20:25 PM',
    overalAllCalorie: '365 kCal',
    proteinCalorie: '39g',
    fatsCalorie: '45g',
    carbsCalorie: '40g',
  ),
  RecentlyUploadedModel(
    image: 'assets/images/white_sauce_pasta.png',
    title: 'White Sauce Pasta',
    time: '10:20 PM',
    overalAllCalorie: '358 kCal',
    proteinCalorie: '80g',
    fatsCalorie: '120g',
    carbsCalorie: '35g',
  ),
];
