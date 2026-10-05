import 'package:stackfood_multivendor/features/language/domain/models/language_model.dart';
import 'package:flutter/material.dart';


abstract class LanguageServiceInterface {
  bool setLTR(Locale locale);
  void updateHeader(Locale locale);
  Locale getLocaleFromSharedPref();
  int setSelectedLanguageIndex(List<LanguageModel> languages, Locale locale);
  void saveLanguage(Locale locale);
  Locale getCacheLocaleFromSharedPref();
  void saveCacheLanguage(Locale locale);
}