import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:deepar_flutter_plus/deepar_flutter_plus.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:auralive/custom/custom_thumbnail.dart';
import 'package:auralive/custom/custom_video_time.dart';
import 'package:auralive/ui/loading_ui.dart';
import 'package:auralive/pages/create_reels_page/api/fetch_all_sound_api.dart';
import 'package:auralive/pages/create_reels_page/api/fetch_favorite_sound_api.dart';
import 'package:auralive/pages/create_reels_page/api/search_sound_api.dart';
import 'package:auralive/pages/create_reels_page/model/fetch_all_sound_model.dart';
import 'package:auralive/pages/create_reels_page/model/fetch_favorite_sound_model.dart';
import 'package:auralive/pages/create_reels_page/model/search_sound_model.dart';
import 'package:auralive/routes/app_routes.dart';
import 'package:auralive/utils/asset.dart';
import 'package:auralive/utils/database.dart';
import 'package:auralive/utils/enums.dart';
import 'package:auralive/utils/utils.dart';

class CreateReelsController extends GetxController {
  // >>>>> >>>>> >>>>> Main Variable <<<<< <<<<< <<<<<

  // ✅ FIX 1: FORCE DISABLE EFFECTS
  final bool isUseEffects = false; 

  bool isFlashOn = false;

  int countTime = 0;
  Timer? timer;
  int selectedDuration = 5;
  final List<int> recordingDurations = [5, 10, 15, 30];

  double? videoTime;
  String? videoImage;

  String isRecording = "stop"; // Recording Types => [start,pause,stop]
  
  // ✅ FIX 2: Add Error State Variables
  bool isCameraError = false; 
  String errorMessage = "";

  // >>>>> >>>>> >>>>> Camera Controller <<<<< <<<<< <<<<<

  CameraController? cameraController;
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;

  // >>>>> >>>>> >>>>> Camera Controller <<<<< <<<<< <<<<<

  DeepArControllerPlus deepArController = DeepArControllerPlus();

  // (Keeping these lists to prevent compile errors, but they are unused now)
  final List effectsCollection = [];
  final List<String> effectImages = [];
  final List<String> effectNames = [];
  final List effectsImageCollection = [];

  bool isShowEffects = false;
  int selectedEffectIndex = 0;
  bool isInitializeEffect = false;
  bool isFrontCamera = false;

  // >>>>> >>>>> >>>>> Initialize Method <<<<< <<<<< <<<<<

  @override
  void onInit() {
    Utils.showLog("Argument => ${Get.arguments}");

    if (Get.arguments != null) {
      selectedSound = Get.arguments;
      initAudio(selectedSound?["link"] ?? "");
    }
    
    // Slight delay to ensure GetX is fully ready before asking permission
    Future.delayed(const Duration(milliseconds: 500), () {
      onGetPermission();
    });
    
    super.onInit();
  }

  @override
  void onClose() {
    onDisposeCamera();
    super.onClose();
  }

  Future<void> onGetPermission() async {
    isCameraError = false;
    update(["onInitializeCamera"]);

    // Request permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.photos, 
    ].request();

    bool cameraGranted = statuses[Permission.camera]!.isGranted;
    bool micGranted = statuses[Permission.microphone]!.isGranted;

    if (cameraGranted && micGranted) {
       // ✅ ALWAYS GO TO STANDARD CAMERA
       onInitializeCamera();
    } else {
      isCameraError = true;
      errorMessage = "Permissions denied";
      update(["onInitializeCamera"]);
      
      Utils.showToast("Camera and Microphone permissions are required.");
      if (statuses[Permission.camera]!.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  // >>>>> >>>>> >>>>> Camera Controller Method <<<<< <<<<< <<<<<

  Future<void> onInitializeCamera() async {
    isCameraError = false; 
    errorMessage = "";

    try {
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        Utils.showLog("No cameras found on device!");
        isCameraError = true;
        errorMessage = "No Camera Found";
        update(["onInitializeCamera"]); // Update UI to stop spinner
        return;
      }

      // ✅ FIX 3: Safely find the Back Camera first
      CameraDescription camera;
      try {
        camera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
      } catch (e) {
        camera = cameras.first;
      }

      cameraController = CameraController(
        camera, 
        ResolutionPreset.high, // Use High for Reels
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg, 
      );

      await cameraController?.initialize();
      
      update(["onInitializeCamera"]); // ✅ Success: Stop Spinner, Show Camera
      
    } catch (e) {
      Utils.showLog("Error initializing camera: $e");
      isCameraError = true; 
      errorMessage = e.toString();
      update(["onInitializeCamera"]); // ✅ Error: Stop Spinner, Show Retry
      Utils.showToast("Failed to start camera");
    }
  }

  Future<void> onDisposeCamera() async {
    cameraController?.dispose();
    cameraController = null;
    cameraController?.removeListener(cameraControllerListener);
    Utils.showLog("Camera Controller Dispose Success");
  }

  Future<void> cameraControllerListener() async {
    Utils.showLog("Change Camera Event => ${cameraController?.value}");
  }

  Future<void> onSwitchFlash() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      if (isFlashOn) {
        isFlashOn = false;
        await cameraController?.setFlashMode(FlashMode.off);
      } else {
        isFlashOn = true;
        await cameraController?.setFlashMode(FlashMode.torch);
      }
      update(["onSwitchFlash"]);
    }
  }

  Future<void> onSwitchCamera() async {
    Utils.showLog("Switch Normal Camera Method Calling....");

    if (isRecording == "stop") {
      Get.dialog(barrierDismissible: false, const LoadingUi()); // Start Loading...
      
      // Toggle Lens Direction
      cameraLensDirection = cameraLensDirection == CameraLensDirection.back ? CameraLensDirection.front : CameraLensDirection.back;
      
      try {
        final cameras = await availableCameras();
        final camera = cameras.firstWhere(
            (c) => c.lensDirection == cameraLensDirection,
            orElse: () => cameras.first
        );
        
        cameraController = CameraController(camera, ResolutionPreset.high);
        await cameraController!.initialize();
        
        update(["onInitializeCamera"]);
      } catch(e) {
        Utils.showLog("Switch Camera Failed: $e");
      }
      
      Get.back(); // Stop Loading...
    } else {
      Utils.showLog("Please Try After Complete Video Recording...");
    }
  }

  Future<void> onStartRecording() async {
    try {
      if (cameraController != null && cameraController!.value.isInitialized) {
        Get.dialog(barrierDismissible: false, const LoadingUi()); // Start Loading...
        onRestartAudio();
        await cameraController!.startVideoRecording();
        Get.back(); // Stop Loading...
        if (cameraController!.value.isRecordingVideo) {
          onChangeRecordingEvent("start");
          Utils.showLog("Video Recording Starting....");
        }
      }
    } catch (e) {
      onPauseAudio();
      onChangeRecordingEvent("stop");
      Utils.showLog("Recording Starting Error => $e");
    }
  }

  Future<void> onPauseRecording() async {
    try {
      if (cameraController != null && cameraController!.value.isInitialized) {
        Get.dialog(barrierDismissible: false, const LoadingUi()); // Start Loading...
        onPauseAudio();
        await cameraController!.pauseVideoRecording();
        Get.back(); // Stop Loading...
        if (cameraController!.value.isRecordingPaused) {
          onChangeRecordingEvent("pause");
          Utils.showLog("Video Recording Pausing....");
        }
      }
    } catch (e) {
      onChangeRecordingEvent("stop");
      Utils.showLog("Recording Pausing Error => $e");
    }
  }

  Future<void> onResumeRecording() async {
    try {
      if (cameraController != null && cameraController!.value.isInitialized) {
        Get.dialog(barrierDismissible: false, const LoadingUi()); // Start Loading...
        onResumeAudio();
        await cameraController!.resumeVideoRecording();
        Get.back(); // Stop Loading...
        if (cameraController!.value.isRecordingPaused) {
          onChangeRecordingEvent("start");
          Utils.showLog("Video Recording Resume....");
        }
      }
    } catch (e) {
      onPauseAudio();
      onChangeRecordingEvent("stop");
      Utils.showLog("Video Recording Resume Error => $e");
    }
  }

  Future<String?> onStopRecording() async {
    XFile? videoUrl;
    if (Get.currentRoute == AppRoutes.createReelsPage) {
      try {
        if (isFlashOn) {
          onSwitchFlash(); // Turn off flash if on
        }
        Get.dialog(barrierDismissible: false, const LoadingUi()); // Start Loading...
        onPauseAudio();
        
        videoUrl = await cameraController!.stopVideoRecording();
        
        Get.back(); // Stop Loading...
        onChangeRecordingEvent("stop");
        Utils.showLog("Recording Video Path => ${videoUrl.path}");
        return videoUrl.path;
      } catch (e) {
        onChangeRecordingEvent("stop");
        Utils.showLog("Recording Stop Failed !! => $e");
        Get.back(); // Ensure loading closes on error
        return null;
      }
    } else {
      onChangeRecordingEvent("stop");
      Utils.showLog("User Back To Create Reels Page....");
      return null;
    }
  }

  Future<void> onClickRecordingButton() async {
    if (isRecording == "stop") {
      onChangeRecordingEvent("start");
      onChangeTimer();
      onStartRecording();
    } else if (isRecording == "start") {
      onChangeRecordingEvent("pause");
      onChangeTimer();
      onPauseRecording();
    } else if (isRecording == "pause") {
      onChangeRecordingEvent("start");
      onChangeTimer();
      onResumeRecording();
    }
  }

  // >>>>> >>>>> >>>>> Effect Methods (STUBBED OUT) <<<<< <<<<< <<<<<
  // These are intentionally empty or unused since isUseEffects = false.
  Future<void> onInitializeEffect() async {}
  Future<void> onDisposeEffect() async {}
  Future<void> onSwitchEffectFlash() async {}
  Future<void> onSwitchEffectCamera() async {}
  Future<void> onToggleEffect() async {}
  Future<void> onChangeEffect(int index) async {}
  Future<void> onClearEffect(int index) async {}
  Future<void> onStartEffectRecording() async {}
  Future<String?> onStopEffectRecording() async { return null; }
  Future<void> onLongPressStart(LongPressStartDetails details) async {
     // Forward to standard recording for long press support
     onChangeRecordingEvent("start");
     onChangeTimer();
     onStartRecording();
  }
  Future<void> onLongPressEnd(LongPressEndDetails details) async {
     // Forward to standard recording stop
     onChangeRecordingEvent("stop");
     onChangeTimer(); // This will trigger the stop logic inside the timer or manually below
     final videoPath = await onStopRecording();
     if (videoPath != null) {
       onPreviewVideo(videoPath);
     }
  }

  //  >>>>> >>>>> >>>>>  Video Duration Method <<<<< <<<<< <<<<<

  Future<void> onChangeTimer() async {
    if (isRecording == "start") {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) async {
          if (isRecording == "start" && countTime <= selectedDuration) {
            countTime++;
            update(["onChangeTimer", "onChangeRecordingEvent"]);
            if (countTime >= selectedDuration) { // Changed to >= for safety
              {
                countTime = 0;
                timer.cancel();
                onChangeRecordingEvent("stop");
                // ✅ Always use standard stop recording since effects are disabled
                final videoPath = await onStopRecording();
                if (videoPath != null) {
                  onPreviewVideo(videoPath);
                }
              }
            }
          }
        },
      );
    } else if (isRecording == "pause") {
      timer?.cancel();
      update(["onChangeTimer", "onChangeRecordingEvent"]);
    } else {
      countTime = 0;
      timer?.cancel();
      onChangeRecordingEvent("stop");
      update(["onChangeTimer", "onChangeRecordingEvent"]);
    }
  }

  Future<void> onChangeRecordingDuration(int index) async {
    selectedDuration = recordingDurations[index];
    update(["onChangeRecordingDuration"]);
  }

  Future<void> onChangeRecordingEvent(String type) async {
    isRecording = type;
    update(["onChangeRecordingEvent"]);
  }

  //  >>>>> >>>>> >>>>>  Preview Video Method <<<<< <<<<< <<<<<

  Future<String?> onRemoveAudio(String videoPath) async {
    final String videoWithoutAudioPath = '${(await getTemporaryDirectory()).path}/RM_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final ffmpegRemoveAudioCommand = '-i $videoPath -c copy -an $videoWithoutAudioPath';
    // final sessionRemoveAudio = await FFmpegKit.executeAsync(ffmpegRemoveAudioCommand);
    // final returnCodeRemoveAudio = await sessionRemoveAudio.getReturnCode();
    Utils.showLog("Remove Audio Path => $videoWithoutAudioPath");
    return videoWithoutAudioPath;
  }

  Future<String?> onMergeAudioWithVideo(String videoPath, String audioPath) async {
    final String path = '${(await getTemporaryDirectory()).path}/FV_${DateTime.now().millisecondsSinceEpoch}.mp4';

    videoTime = (await CustomVideoTime.onGet(videoPath) ?? 0).toDouble();
    final soundTime = (await onGetSoundTime(audioPath) ?? 0);

    if (soundTime != 0 && videoTime != null && videoTime != 0) {
      Utils.showLog("Audio Time => $soundTime Video Time => $videoTime");

      final minTime = (videoTime! < soundTime) ? videoTime : soundTime;

      // ✅ Robust FFMPEG Command
      final command = '-i "$videoPath" -i "$audioPath" -t $minTime -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 "$path"';

      final sessionRemoveAudio = await FFmpegKit.executeAsync(command);
      final returnCodeRemoveAudio = await sessionRemoveAudio.getReturnCode();
      Utils.showLog("Return Code => $returnCodeRemoveAudio");

      Utils.showLog("Merge Video Path => $path");
      return path;
    } else {
      return null;
    }
  }

  Future<void> onClickPreviewButton() async {
    // Manually stop and preview
    Get.dialog(barrierDismissible: false, const LoadingUi()); 
    onChangeRecordingEvent("stop");
    
    // Cancel timer manually if running
    timer?.cancel();
    countTime = 0;
    
    final videoPath = await onStopRecording();
    Get.back(); 
    
    if (videoPath != null) {
      onPreviewVideo(videoPath);
    }
  }

  Future<void> onPreviewVideo(String videoPath) async {
    Get.dialog(barrierDismissible: false, const LoadingUi()); // Start Loading...
    
    videoImage = await CustomThumbnail.onGet(videoPath);
    
    if (selectedSound != null) {
      Utils.showLog("Removing Audio From Video...");
      Utils.showToast(EnumLocal.txtPleaseWaitSomeTime.name.tr);
      
      Utils.showLog("SONG => ${selectedSound}");

      final mergeVideoPath = await onMergeAudioWithVideo(videoPath, selectedSound?["link"]);
      await 5.seconds.delay(); // Give FFMPEG a moment
      Get.back(); // Stop Loading...

      if (mergeVideoPath != null && videoTime != null && videoImage != null) {
        Utils.showLog("Video Path => ${mergeVideoPath}");
        
        Get.offAndToNamed(
          AppRoutes.previewCreatedReelsPage,
          arguments: {
            "video": mergeVideoPath,
            "image": videoImage,
            "time": videoTime?.toInt(),
            "songId": selectedSound?["id"] ?? "",
          },
        );
      } else {
        Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
      }
    } else {
      videoTime = (await CustomVideoTime.onGet(videoPath) ?? 0).toDouble();
      Get.back(); // Stop Loading...

      if (videoTime != null && videoImage != null) {
        Utils.showLog("Video Path => ${videoPath}");
        
        Get.offAndToNamed(
          AppRoutes.previewCreatedReelsPage,
          arguments: {
            "video": videoPath,
            "image": videoImage,
            "time": videoTime?.toInt(),
            "songId": "",
          },
        );
      } else {
        Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
      }
    }
  }

  //  >>>>> >>>>> >>>>>  Music Bottom Sheet <<<<< <<<<< <<<<<

  AudioPlayer _audioPlayer = AudioPlayer();
  Map? selectedSound;
  int selectedTabIndex = 0;
  TextEditingController searchController = TextEditingController();
  final List soundTabPages = [const DiscoverTabUi(), const FavouriteTabUi()];

  bool isLoadingSound = true;
  List<AllSongs> mainSoundCollection = [];
  FetchAllSoundModel? fetchAllSoundModel;

  bool isLoadingFavoriteSound = true;
  List<FavoriteSongs> favoriteSoundCollection = [];
  FetchFavoriteSoundModel? fetchFavoriteSoundModel;
  ScrollController favoriteSoundController = ScrollController();

  bool isSearching = false;
  SearchSoundModel? searchSoundModel;
  List<SearchData> searchSounds = [];
  bool isSearchLoading = false;

  Future<void> onChangeTabBar(int index) async {
    selectedTabIndex = index;
    if (index == 0) {
      initAllSound();
    } else if (index == 1) {
      initFavoriteSound();
    }
    update(["onChangeTabBar"]);
  }

  void onChangeSearchEvent() {
    if (searchController.text.trim().isEmpty) {
      isSearching = false;
      update(["onChangeSearchEvent"]);
    } else if (searchController.text.trim().length == 1) {
      isSearching = true;
      update(["onChangeSearchEvent"]);
    }
  }

  Future<void> onSearchSound() async {
    onChangeSearchEvent();
    if (searchController.text.trim().isNotEmpty) {
      Utils.showLog("Search Sound Method Calling...");

      isSearchLoading = true;
      update(["onSearchSound"]);

      searchSoundModel = await SearchSoundApi.callApi(loginUserId: Database.loginUserId, searchText: searchController.text);

      if (searchSoundModel?.searchData != null) {
        searchSounds.clear();
        searchSounds.addAll(searchSoundModel?.searchData ?? []);
        isSearchLoading = false;
        update(["onSearchSound"]);
      }
    }
  }

  Future<void> initAllSound() async {
    mainSoundCollection.clear();
    onGetAllSound();
  }

  Future<void> onGetAllSound() async {
    if (mainSoundCollection.isEmpty) {
      isLoadingSound = true;
      update(["onGetAllSound"]);
    }

    fetchAllSoundModel = null;
    fetchAllSoundModel = await FetchAllSoundApi.callApi(loginUserId: Database.loginUserId);

    if (fetchAllSoundModel?.songs != null) {
      isLoadingSound = false;
      mainSoundCollection.addAll(fetchAllSoundModel?.songs ?? []);
      Utils.showLog("All Sound Length => ${mainSoundCollection.length}");
    }
    update(["onGetAllSound"]);
  }

  Future<void> initFavoriteSound() async {
    favoriteSoundCollection.clear();
    FetchFavoriteSoundApi.startPagination = 0;
    onGetFavoriteSound();
  }

  Future<void> onGetFavoriteSound() async {
    if (favoriteSoundCollection.isEmpty) {
      isLoadingFavoriteSound = true;
      update(["onGetFavoriteSound"]);
    }

    fetchFavoriteSoundModel = null;
    fetchFavoriteSoundModel = await FetchFavoriteSoundApi.callApi(loginUserId: Database.loginUserId);

    if (fetchFavoriteSoundModel?.songs != null) {
      isLoadingFavoriteSound = false;
      favoriteSoundCollection.addAll(fetchFavoriteSoundModel?.songs ?? []);
      Utils.showLog("Favorite Sound Length => ${favoriteSoundCollection.length}");
    }
    update(["onGetFavoriteSound"]);
  }

  Future<void> onChangeSound(Map sound) async {
    if (selectedSound?["id"] == sound["id"]) {
      selectedSound = null;
    } else {
      selectedSound = {
        "id": sound["id"],
        "name": sound["name"],
        "image": sound["image"],
        "link": sound["link"],
      };
      initAudio(sound["link"]);
    }
    update(["onChangeSound"]);
    Utils.showLog("--------------- ${selectedSound}");
  }

  Future<double?> onGetSoundTime(String audioPath) async {
    await _audioPlayer.setSourceUrl(audioPath);
    Duration? audioDuration = await _audioPlayer.getDuration();
    final audioTime = audioDuration?.inSeconds.toDouble();
    Utils.showLog("Selected Audio Time => $audioTime");
    return audioTime;
  }

  // >>>>> >>>>> >>>>> Play Sound Variable <<<<< <<<<< <<<<<

  AudioPlayer audioPlayer = AudioPlayer();

  void initAudio(String audio) async {
    try {
      await audioPlayer.setSource(UrlSource(audio));
    } catch (e) {
      Utils.showLog("Audio Play Failed !! => $e");
    }
  }

  void onResumeAudio() {
    if (selectedSound != null) {
      try {
        audioPlayer.resume();
      } catch (e) {
        Utils.showLog("Audio Resume Error => $e");
      }
    }
  }

  void onRestartAudio() {
    Utils.showLog("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    if (selectedSound != null) {
      try {
        audioPlayer.seek(Duration(milliseconds: 0));
        audioPlayer.resume();
      } catch (e) {
        Utils.showLog("Audio Restart Error => $e");
      }
    }
  }

  void onPauseAudio() {
    if (selectedSound != null) {
      try {
        audioPlayer.pause();
      } catch (e) {
        Utils.showLog("Audio Pause Error => $e");
      }
    }
  }
}
