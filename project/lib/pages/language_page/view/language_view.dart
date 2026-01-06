import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/localization/localizations_delegate.dart';
import 'package:shortie/pages/language_page/controller/language_controller.dart';
import 'package:shortie/ui/simple_app_bar_ui.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/pages/language_page/widget/language_widget.dart';
import 'package:shortie/utils/enums.dart';

class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.white,
        shadowColor: AppColor.black.withOpacity(0.4),
        surfaceTintColor: AppColor.transparent,
        flexibleSpace: SimpleAppBarUi(title: EnumLocal.txtLanguages.name.tr),
      ),
      body: SingleChildScrollView(
        child: GetBuilder<LanguageController>(
          id: "onChangeLanguage",
          builder: (controller) => Column(
            children: [
              for (int i = 0; i < languages.length; i++)
                ItemsView(
                  icon: controller.countryFlags[i],
                  title: languages[i].language,
                  isSelected: languages[i] == controller.languageModel,
                  callback: () => controller.onChangeLanguage(languages[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
