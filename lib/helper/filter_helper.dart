
class FilterHelper {

  static String foodType(bool veg, bool nonVeg) {
      if(veg && nonVeg){
        return '';
      }
      else if(veg) {
        return 'veg';
      } else if(nonVeg) {
        return 'non_veg';
      } else {
        return '';
      }
  }

  static String getSortTypeFromIndex(int sortBy, {required bool isRestaurant}) {
    if (isRestaurant) {
      switch (sortBy) {
        case 1:
          return 'a_to_z';
        case 2:
          return 'z_to_a';
        case 3 :
          return 'distance';
        case 4:
          return 'fast_delivery';
        default:
          return '';
      }
    } else {
      switch (sortBy) {
        case 1:
          return 'a_to_z';
        case 2:
          return 'z_to_a';
        case 3:
          return 'price_low_to_high';
        case 4:
          return 'price_high_to_low';
        default:
          return '';
      }
    }
  }


}