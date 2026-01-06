import 'package:flutter/material.dart';
import 'package:shortie/utils/constant.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';

Future<Locale> getLocale() async {
  String languageCode = Database.selectedLanguage;
  String countryCode = Database.selectedCountryCode;

  Utils.showLog("Selected Language => $languageCode >>> $countryCode");
  return _locale(languageCode, countryCode);
}

Locale _locale(String languageCode, String countryCode) {
  return languageCode.isNotEmpty
      ? Locale(languageCode, countryCode)
      : const Locale(AppConstant.languageEn, AppConstant.countryCodeEn);
}
