// lib/utils/app_constants.dart

/// Central constants for unit types, designations, districts, and police stations in Admin Console.
class AppConstants {
  AppConstants._();

  static const List<String> unitTypes = [
    'Commissionerate Police',
    'Rural Police',
  ];

  static const List<String> commissionerateDesignations = [
    'PC',
    'NPC',
    'HC',
    'ASI',
    'PSI',
    'API',
    'PI',
    'Sr. PI',
    'ACP',
    'DCP',
    'Addl. CP',
    'JT. CP',
    'CP',
  ];

  static const List<String> ruralDesignations = [
    'PC',
    'NPC',
    'HC',
    'ASI',
    'PSI',
    'API',
    'PI',
    'Sr. PI',
    'Dy. SP',
    'ASP',
    'Addl. SP',
    'SP',
  ];

  static const List<String> allDesignations = [
    'PC',
    'NPC',
    'HC',
    'ASI',
    'PSI',
    'API',
    'PI',
    'Sr. PI',
    'ACP',
    'DCP',
    'Addl. CP',
    'JT. CP',
    'CP',
    'Dy. SP',
    'ASP',
    'Addl. SP',
    'SP',
  ];

  /// Returns designation options for a given unit type.
  static List<String> getDesignationsForUnitType(String? unitType) {
    if (unitType == 'Commissionerate Police' || unitType == 'Commissionerate') {
      return commissionerateDesignations;
    } else if (unitType == 'Rural Police' || unitType == 'Superintendent of Police') {
      return ruralDesignations;
    }
    return allDesignations;
  }

  /// Returns implied unit type if designation is rank-locked to CP or SP levels.
  static String? getImpliedUnitType(String? designation) {
    if (designation == null) return null;
    const cpRanks = ['ACP', 'DCP', 'Addl. CP', 'JT. CP', 'CP'];
    const spRanks = ['Dy. SP', 'ASP', 'Addl. SP', 'SP'];
    if (cpRanks.contains(designation)) return 'Commissionerate Police';
    if (spRanks.contains(designation)) return 'Rural Police';
    return null;
  }

  static const Map<String, List<String>> districtsByUnitType = {
    'Commissionerate Police': [
      'Mumbai City',
      'Thane City',
      'Pune City',
      'Nagpur City',
      'Pimpri Chinchwad',
      'Navi Mumbai',
      'Mira Bhayandar Vasai Virar',
      'Nashik City',
      'Chhatrapati Sambhajinagar City',
      'Solapur City',
      'Amravati City',
    ],
    'Rural Police': [
      'Thane Rural',
      'Pune Rural',
      'Nagpur Rural',
      'Nashik Rural',
      'Raigad',
      'Palghar',
      'Satara',
      'Sangli',
      'Solapur Rural',
      'Kolhapur',
      'Ahmednagar',
      'Aurangabad Rural',
      'Amravati Rural',
      'Nanded',
      'Jalgaon',
      'Latur',
      'Ratnagiri',
      'Sindhudurg',
    ],
  };

  /// Returns list of districts/cities for the given unit type.
  static List<String> getDistrictsForUnitType(String? unitType) {
    if (unitType == 'Commissionerate Police' || unitType == 'Commissionerate') {
      return districtsByUnitType['Commissionerate Police']!;
    } else if (unitType == 'Rural Police' || unitType == 'Superintendent of Police') {
      return districtsByUnitType['Rural Police']!;
    }
    return [
      ...districtsByUnitType['Commissionerate Police']!,
      ...districtsByUnitType['Rural Police']!,
    ];
  }

  static const Map<String, List<String>> stationsByDistrict = {
    'Mumbai City': ['Colaba PS', 'Marine Drive PS', 'Azad Maidan PS', 'Malabar Hill PS', 'Worli PS', 'Bandra PS', 'Andheri PS', 'Kurla PS'],
    'Thane City': ['Thane Nagar PS', 'Naupada PS', 'Kopri PS', 'Wagle Estate PS', 'Vartak Nagar PS', 'Kalyan PS', 'Dombivli PS'],
    'Pune City': ['Shivajinagar PS', 'Deccan Gymkhana PS', 'Kothrud PS', 'Hadapsar PS', 'Koregaon Park PS', 'Cantonment PS', 'Viman Nagar PS'],
    'Nagpur City': ['Sitabuldi PS', 'Sadar PS', 'Dhantoli PS', 'Ambazari PS', 'Gittikhadan PS', 'Lakadganj PS'],
    'Pimpri Chinchwad': ['Pimpri PS', 'Chinchwad PS', 'Nigdi PS', 'Bhosari PS', 'Wakad PS', 'Hinjawadi PS'],
    'Navi Mumbai': ['Vashi PS', 'Nerul PS', 'Belapur PS', 'Kharghar PS', 'Panvel PS', 'Rabale PS'],
    'Mira Bhayandar Vasai Virar': ['Mira Road PS', 'Bhayandar PS', 'Vasai PS', 'Nallasopara PS', 'Virar PS', 'Manickpur PS'],
    'Nashik City': ['Bhadrakali PS', 'Panchavati PS', 'Sarkarwada PS', 'Gangapur PS', 'Ambad PS', 'Indiranagar PS'],
    'Chhatrapati Sambhajinagar City': ['City Chowk PS', 'Kranti Chowk PS', 'Jawaharnagar PS', 'Cidco PS', 'Mukundwadi PS'],
    'Solapur City': ['Faujdar Chawda PS', 'Jodi Basaveshwar PS', 'Sadar Bazar PS', 'Vijapur Naka PS', 'MIDC PS'],
    'Amravati City': ['Kotwali PS', 'Rajapeth PS', 'Frezerpura PS', 'Badnera PS', 'Gadge Nagar PS'],
    'Thane Rural': ['Bhayander Rural PS', 'Ganeshpuri PS', 'Kashimira PS', 'Murbad PS', 'Shahapur PS', 'Tokawade PS'],
    'Pune Rural': ['Baramati City PS', 'Bhor PS', 'Daund PS', 'Haveli PS', 'Lonavala City PS', 'Manchar PS', 'Shirur PS'],
    'Nagpur Rural': ['Kamptee PS', 'Hingna PS', 'Kalmeshwar PS', 'Umred PS', 'Ramtek PS', 'Katol PS'],
    'Nashik Rural': ['Chandwad PS', 'Igatpuri PS', 'Malegaon City PS', 'Niphad PS', 'Sinnar PS', 'Yeola PS'],
    'Raigad': ['Alibag PS', 'Karjat PS', 'Mahad PS', 'Mangaon PS', 'Murud PS', 'Pen PS', 'Roha PS'],
    'Palghar': ['Boisar PS', 'Dahanu PS', 'Kasa PS', 'Palghar PS', 'Talasari PS', 'Vikramgad PS'],
    'Satara': ['Satara City PS', 'Karad City PS', 'Phaltan City PS', 'Wai PS', 'Mahabaleshwar PS', 'Koregaon PS'],
    'Sangli': ['Sangli City PS', 'Miraj City PS', 'Vita PS', 'Islampur PS', 'Tasgaon PS', 'Palus PS'],
    'Solapur Rural': ['Barshi City PS', 'Karmala PS', 'Kurduwadi PS', 'Pandharpur City PS', 'Sangola PS', 'Akkalkot PS'],
    'Kolhapur': ['Juna Rajwada PS', 'Laxmipuri PS', 'Shahupuri PS', 'Ichalkaranji PS', 'Gargoti PS', 'Kagal PS', 'Gadhinklaj PS'],
    'Ahmednagar': ['Kotwali PS', 'Topkhana PS', 'Camp PS', 'Shirdi PS', 'Sangamner City PS', 'Shrirampur City PS'],
    'Aurangabad Rural': ['Gangapur PS', 'Kannad PS', 'Paithan PS', 'Sillod PS', 'Vaijapur PS'],
    'Amravati Rural': ['Achalpur PS', 'Anjangaon Surji PS', 'Chandur Bazar PS', 'Dhamangaon Railway PS', 'Morshi PS', 'Paratwada PS'],
    'Nanded': ['Itwara PS', 'Vazirabad PS', 'Shivajinagar PS', 'Degloor PS', 'Kandhar PS', 'Kinwat PS', 'Mukhed PS'],
    'Jalgaon': ['Jalgaon City PS', 'Ramanand Nagar PS', 'Zilla Peth PS', 'Bhusawal City PS', 'Chalisgaon City PS', 'Amalner PS'],
    'Latur': ['Gandhi Chowk PS', 'Shivajinagar PS', 'MIDC Latur PS', 'Ausa PS', 'Ahmedpur PS', 'Udgir City PS'],
    'Ratnagiri': ['Ratnagiri City PS', 'Chiplun PS', 'Dabhol PS', 'Guhagar PS', 'Khed PS', 'Rajapur PS'],
    'Sindhudurg': ['Kudal PS', 'Kankavli PS', 'Sawantwadi PS', 'Malvan PS', 'Vengurla PS', 'Devgad PS'],
  };

  /// Returns list of police station names for a given district.
  static List<String> getStationsForDistrict(String? district) {
    if (district == null || district.isEmpty) return const [];
    final stations = stationsByDistrict[district];
    if (stations != null && stations.isNotEmpty) {
      return stations;
    }
    return [
      '$district Central PS',
      '$district North PS',
      '$district South PS',
      '$district Town PS',
    ];
  }
}
