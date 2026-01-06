import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortie/custom/custom_image_picker.dart';
import 'package:shortie/custom/custom_multi_image_picker.dart';
import 'package:shortie/pages/preview_hash_tag_page/api/create_hash_tag_api.dart';
import 'package:shortie/pages/preview_hash_tag_page/api/fetch_hash_tag_api.dart';
import 'package:shortie/pages/preview_hash_tag_page/model/create_hash_tag_model.dart';
import 'package:shortie/pages/preview_hash_tag_page/model/fetch_hash_tag_model.dart';
import 'package:shortie/pages/upload_post_page/api/upload_post_api.dart';
import 'package:shortie/pages/upload_post_page/model/upload_post_model.dart';
import 'package:shortie/ui/image_picker_bottom_sheet_ui.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/internet_connection.dart';
import 'package:shortie/utils/utils.dart';

class UploadPostController extends GetxController {
  List<String> selectedImages = [];
  UploadPostModel? uploadPostModel;

  bool isLoadingHashTag = false;
  List<HashTagData> hastTagCollection = [];
  List<HashTagData> filterHashtag = [];

  RxBool isShowHashTag = false.obs;
  List<String> userInputHashtag = [];

  FetchHashTagModel? fetchHashTagModel;
  CreateHashTagModel? createHashTagModel;

  TextEditingController captionController = TextEditingController();
  TextEditingController hashTagController = TextEditingController();

  @override
  void onInit() {
    init();
    super.onInit();

    Utils.showLog("Upload Post Controller Initialized...");
  }

  Future<void> init() async {
    Utils.showLog("Selected Images Length => ${Get.arguments["images"].length}");

    if (Get.arguments["images"] != null) {
      selectedImages.addAll(Get.arguments["images"]);
    }
    onGetHashTag();
    createHashTagModel = null;
  }

  void onSelectHashtag(int index) {
    String text = captionController.text;
    List<String> words = text.split(' ');
    words.removeLast();
    captionController.text = words.join(' ');
    captionController.text = captionController.text + ' ' + ("#${filterHashtag[index].hashTag} ");
    captionController.selection = TextSelection.fromPosition(TextPosition(offset: captionController.text.length));
    isShowHashTag.value = false;
    update(["onChangeHashtag"]);
  }

  void onChangeHashtag() async {
    String text = captionController.text;

    List<String> words = text.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].length > 1 && // condition 1: word length not 1
          words[i].indexOf('#') == words[i].lastIndexOf('#')) {
        // condition 2: word uses # only one time
        if (words[i].endsWith('#')) {
          words[i] = words[i].replaceFirst('#', ' #');
        }
      }
    }
    captionController.text = words.join(' ');
    captionController.selection = TextSelection.fromPosition(
      TextPosition(offset: captionController.text.length),
    );

    String updatedText = captionController.text;
    List<String> parts = updatedText.split(' ');

    // if (words.last[words.last.length - 1] == "#") {
    //   words.last[words.last.length - 1]
    // }

    // List<String> words = text.split(RegExp(r'(\s|(?=#))'));

    await 10.milliseconds.delay();

    final caption = parts.where((element) => !element.startsWith('#')).join(' ');
    userInputHashtag = parts.where((element) => element.startsWith('#')).toList();

    final lastWord = parts.last;

    Utils.showLog("Caption => ${caption}");
    Utils.showLog("Last Word => ${lastWord}");

    if (lastWord.startsWith("#")) {
      Utils.showLog("----------------------");

      final searchHashtag = lastWord.substring(1);
      filterHashtag = hastTagCollection.where((element) => (element.hashTag?.toLowerCase() ?? "").contains(searchHashtag.toLowerCase())).toList();
      isShowHashTag.value = true;
      update(["onGetHashTag"]);
    } else {
      filterHashtag.clear();
      isShowHashTag.value = false;
    }
    update(["onChangeHashtag"]);
  }

  void onToggleHashTag(bool value) {
    isShowHashTag.value = value;
  }

  Future<void> onGetHashTag() async {
    isLoadingHashTag = true;
    update(["onGetHashTag"]);
    fetchHashTagModel = await FetchHashTagApi.callApi(hashTag: "");

    if (fetchHashTagModel?.data != null) {
      hastTagCollection.clear();

      hastTagCollection.addAll(fetchHashTagModel?.data ?? []);

      Utils.showLog("Hast Tag Collection Length => ${hastTagCollection.length}");
    }
    isLoadingHashTag = false;
    update(["onGetHashTag"]);
  }

  void onSelectNewImage(BuildContext context) async {
    await ImagePickerBottomSheetUi.show(
      context: context,
      onClickGallery: () async {
        final List<String> images = await CustomMultiImagePicker.pickImage();

        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++) {
            if (selectedImages.length < 5) {
              selectedImages.add(images[i]);
            } else {
              break;
            }
          }
          update(["onChangeImages"]);
        }
      },
      onClickCamera: () async {
        final String? imagePath = await CustomImagePicker.pickImage(ImageSource.camera);
        if (imagePath != null) {
          selectedImages.add(imagePath);
          update(["onChangeImages"]);
        }
      },
    );
  }

  void onCancelImage(int index) {
    selectedImages.removeAt(index);
    update(["onChangeImages"]);
  }

  Future<void> onUploadPost() async {
    if (selectedImages.isEmpty) {
      Utils.showToast(EnumLocal.txtPleaseSelectPost.name.tr);
    } else {
      Utils.showLog(EnumLocal.txtPostUploading.name.tr);
      if (InternetConnection.isConnect.value) {
        Get.dialog(PopScope(canPop: false, child: const LoadingUi()), barrierDismissible: false); // Start Loading...

        List<String> hashTagIds = [];

        for (int index = 0; index < userInputHashtag.length; index++) {
          final hashTag = userInputHashtag[index];

          Utils.showLog("----------${hashTag}");

          if (hashTag != "" && hashTag.startsWith("#")) {
            final searchHashtag = userInputHashtag[index].substring(1);
            createHashTagModel = null;

            final List<HashTagData> selectedHashTag = hastTagCollection.where((element) => (element.hashTag?.toLowerCase() ?? "") == searchHashtag.toLowerCase()).toList();

            Utils.showLog("**** ${selectedHashTag}");

            if (selectedHashTag.isNotEmpty) {
              hashTagIds.add(selectedHashTag[0].id ?? "");
              Utils.showLog("Already Available HashTag => ${selectedHashTag[0].hashTag} ");
            } else {
              Utils.showLog("New Create HashTag => ${userInputHashtag[index].substring(1)} ");
              createHashTagModel = await CreateHashTagApi.callApi(hashTag: userInputHashtag[index].substring(1));

              if (createHashTagModel?.data?.id != null) {
                hashTagIds.add(createHashTagModel?.data?.id ?? "");
              }
            }
          }
        }

        Utils.showLog("Hast Tag Id => $hashTagIds");

        uploadPostModel = await UploadPostApi.callApi(
          loginUserId: Database.loginUserId,
          hashTag: hashTagIds.map((e) => "$e").join(',').toString(),
          caption: captionController.text.trim(),
          postImages: selectedImages,
        );

        if (uploadPostModel?.status == true && uploadPostModel?.post?.id != null) {
          Utils.showToast(EnumLocal.txtPostUploadSuccessfully.name.tr);
          Get.close(2);
        } else {
          Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        }
        Get.back(); // Stop Loading...
      } else {
        Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
        Utils.showLog("Internet Connection Lost !!");
      }
    }
  }
}

// >>>>>>>>>>>>>>>>>>>>>>>> Old Hashtag Function <<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//   if (selectedHashTag[index].id == null && selectedHashTag[index].hashTag != null && selectedHashTag[index].hashTag != "") {
//     createHashTagModel = await CreateHashTagApi.callApi(hashTag: selectedHashTag[index].hashTag ?? "");
//     if (createHashTagModel?.data?.id != null) {
//       hashTagIds.add(createHashTagModel?.data?.id ?? "");
//     }
//   } else {
//     hashTagIds.add(selectedHashTag[index].id ?? "");
//   }
// }
//
// Future<void> onChangeHashTag() async {
//   Utils.showLog("Typing => ${hashTagController.text}");
//
//   if (hashTagController.text.trim().isNotEmpty) {
//     Utils.showLog("Typing => ${Get.currentRoute}");
//
//     if (Get.currentRoute == "/upload_post_page") {
//       Get.to(PreviewHashTagListUi());
//     }
//
//     if (hashTagController.text.endsWith(" ")) {
//       if (hastTagCollection.isNotEmpty) {
//         final userHashTag = hashTagController.text.trim().toLowerCase();
//         final apiHashTag = hastTagCollection[0].hashTag?.toLowerCase();
//         if (userHashTag == apiHashTag) {
//           onSelectHastTag(0);
//         } else {
//           selectedHashTag.add(HashTagData(hashTag: hashTagController.text.trim()));
//           update(["onSelectHastTag"]);
//           onCloseHashTagPage();
//           Utils.showLog("Create New HashTag Success");
//         }
//       } else {
//         selectedHashTag.add(HashTagData(hashTag: hashTagController.text.trim()));
//         update(["onSelectHastTag"]);
//         onCloseHashTagPage();
//         Utils.showLog("Create New HashTag Success");
//       }
//     } else {
//       await onGetHashTag();
//     }
//   } else if (hashTagController.text.isEmpty) {
//     await onGetHashTag();
//   }
// }
//
// void onSelectHastTag(int index) {
//   selectedHashTag.add(hastTagCollection[index]);
//   update(["onSelectHastTag"]);
//   // onCloseHashTagPage();
// }
//
// void onCloseHashTagPage() async {
//   hashTagController.clear();
//   FocusManager.instance.primaryFocus?.unfocus();
//   if (Get.currentRoute == "/PreviewHashTagListUi") {
//     Get.back();
//     await 200.milliseconds.delay();
//     FocusManager.instance.primaryFocus?.unfocus();
//   }
// }
//
// void onCancelHashTag(int index) {
//   selectedHashTag.removeAt(index);
//   update(["onSelectHastTag"]);
// }
//

//
// void onSubmitHashTag() {
//   if (hashTagController.text.trim().isNotEmpty && hastTagCollection.isNotEmpty) {
//     final userHashTag = hashTagController.text.trim().toLowerCase();
//     final apiHashTag = hastTagCollection[0].hashTag?.toLowerCase();
//     if (userHashTag == apiHashTag) {
//       onSelectHastTag(0);
//     } else {
//       selectedHashTag.add(HashTagData(hashTag: hashTagController.text.trim()));
//       update(["onSelectHastTag"]);
//       onCloseHashTagPage();
//       Utils.showLog("Create New HashTag Success");
//     }
//   } else if (hashTagController.text.trim().isNotEmpty && hastTagCollection.isEmpty) {
//     selectedHashTag.add(HashTagData(hashTag: hashTagController.text.trim()));
//     update(["onSelectHastTag"]);
//     onCloseHashTagPage();
//     Utils.showLog("Create New HashTag Success");
//   }
// }

//---------------------------------------------------------
// if (selectedHashTag.contains(hastTagCollection[index])) {
//   selectedHashTag.remove(hastTagCollection[index]);
//   update(["onSelectHastTag"]);
// } else {
//
// }

//  Future<void> onToggleHashTag(bool value) async {
//     isShowHashTag = value;
//     update(["onToggleHashTag"]);
//
//     if (value) {
//       onGetHashTag();
//       FocusManager.instance.primaryFocus?.unfocus();
//       Get.to(PreviewHashTagListUi());
//     }
//   }

// Future<void> onCreateHashTag() async {
//   FocusManager.instance.primaryFocus?.unfocus();
//
//   Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
//
//   createHashTagModel = await CreateHashTagApi.callApi(hashTag: hashTagController.text.trim());
//   if (createHashTagModel?.data?.id != null) {
//     Utils.showLog("Create Hast Tag Success ${createHashTagModel?.data?.id}");
//
//     selectedHashTag.add(
//       HashTagData(
//         id: createHashTagModel?.data?.id,
//         hashTag: createHashTagModel?.data?.hashTag,
//       ),
//     );
//     update(["onSelectHastTag"]);
//
//     hashTagController.clear();
//   }
//   Get.back(); // Stop Loading...
// }
