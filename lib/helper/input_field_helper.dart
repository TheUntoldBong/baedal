import 'package:stackfood_multivendor/common/enums/custom_input_field_type.dart';

class InputFieldHelper {

  static CustomInputFieldType getCustomInputFieldType(String? type){
    if(type == 'name'){
      return CustomInputFieldType.number;
    }
    else if(type == 'phone'){
      return CustomInputFieldType.phone;
    }
    else if(type == 'email'){
      return CustomInputFieldType.email;
    }
    else if(type == 'check_box'){
      return CustomInputFieldType.checkBox;
    }
    else if(type == 'file'){
      return CustomInputFieldType.file;
    }
    else if(type == 'date'){
      return CustomInputFieldType.date;
    }
    else{
      return CustomInputFieldType.text;
    }
  }

}
