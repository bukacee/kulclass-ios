// FILE: lib/pages/create_reels_page/view/create_reels_view.dart

import 'package:camera/camera.dart';
import 'package:deepar_flutter_plus/deepar_flutter_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Your Controller
import 'package:auralive/pages/create_reels_page/controller/create_reels_controller.dart';
// Your Widgets
import 'package:auralive/pages/create_reels_page/widget/create_reels_widget.dart';

import 'package:auralive/ui/loading_ui.dart';
import 'package:auralive/utils/asset.dart';
import 'package:auralive/utils/color.dart';
import 'package:auralive/utils/enums.dart';

class CreateReelsView extends GetView<CreateReelsController> {
  const CreateReelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GetBuilder<CreateReelsController>(
          id: "onInitializeCamera",
          builder: (logic) {
            return Stack(
              children: [
                _buildCameraPreview(logic),
                Positioned(
                  top: 10, left: 15, right: 15,
                  child: _buildTopBar(context, logic),
                ),
                Positioned(
                  top: 100, right: 15,
                  child: _buildRightSideTools(logic),
                ),
                Positioned(
                  bottom: 20, left: 0, right: 0,
                  child: _buildBottomControls(context, logic),
                ),
                if (logic.cameraController == null && !logic.isInitializeEffect)
                  const Center(child: LoadingUi()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraPreview(CreateReelsController logic) {
    if (logic.isUseEffects) {
      return GetBuilder<CreateReelsController>(
        id: "onInitializeEffect",
        builder: (logic) {
          if (logic.isInitializeEffect) {
            // *** FIX 1: Use DeepArPreviewPlus ***
            return DeepArPreviewPlus(logic.deepArController);
          } else {
            return Container(color: Colors.black);
          }
        },
      );
    } else {
      if (logic.cameraController != null && logic.cameraController!.value.isInitialized) {
        return SizedBox.expand(child: CameraPreview(logic.cameraController!));
      } else {
        return Container(color: Colors.black);
      }
    }
  }

  Widget _buildTopBar(BuildContext context, CreateReelsController logic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.3)),
            child: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
        ),
        GestureDetector(
          onTap: () => AddMusicBottomSheet.show(context: context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.music_note, color: Colors.white, size: 18),
                const SizedBox(width: 5),
                GetBuilder<CreateReelsController>(
                  id: "onChangeSound",
                  builder: (logic) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(
                        logic.selectedSound != null ? logic.selectedSound!['name'] : EnumLocal.txtAddMusic.name.tr,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        GetBuilder<CreateReelsController>(
          id: "onSwitchFlash", 
          builder: (logic) {
            return GestureDetector(
              onTap: logic.isUseEffects ? logic.onSwitchEffectFlash : logic.onSwitchFlash,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.3)),
                child: Icon(
                  logic.isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white, size: 24,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRightSideTools(CreateReelsController logic) {
    return Column(
      children: [
        _buildSideToolItem(
          icon: Icons.flip_camera_ios_outlined, label: "Flip",
          onTap: logic.isUseEffects ? logic.onSwitchEffectCamera : logic.onSwitchCamera,
        ),
        const SizedBox(height: 20),
        if (logic.isUseEffects) ...[
          _buildSideToolItem(
            icon: Icons.face, label: "Effects",
            onTap: logic.onToggleEffect,
          ),
          const SizedBox(height: 20),
        ],
        GetBuilder<CreateReelsController>(
          id: "onChangeRecordingDuration",
          builder: (logic) {
            return GestureDetector(
              onTap: () {
                int currentIndex = logic.recordingDurations.indexOf(logic.selectedDuration);
                int nextIndex = (currentIndex + 1) % logic.recordingDurations.length;
                logic.onChangeRecordingDuration(nextIndex);
              },
              child: Column(
                children: [
                  Container(
                    height: 35, width: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Text("${logic.selectedDuration}s", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text("Timer", style: TextStyle(color: Colors.white, fontSize: 10))
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSideToolItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, CreateReelsController logic) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GetBuilder<CreateReelsController>(
          id: "onChangeTimer",
          builder: (logic) {
             if (logic.countTime > 0) {
               return Container(
                 margin: const EdgeInsets.only(bottom: 10),
                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                 decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
                 child: Text("00:${logic.countTime.toString().padLeft(2, '0')}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
               );
             }
             return const SizedBox.shrink();
          },
        ),
        GetBuilder<CreateReelsController>(
          id: "onToggleEffect",
          builder: (logic) {
            if (!logic.isShowEffects || !logic.isUseEffects) return const SizedBox.shrink();
            return Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 15),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: logic.effectsCollection.length,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemBuilder: (context, index) {
                  bool isSelected = logic.selectedEffectIndex == index;
                  return GestureDetector(
                    onTap: () => index == 0 ? logic.onClearEffect(index) : logic.onChangeEffect(index),
                    child: Container(
                      width: 70, margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Container(
                            height: 60, width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: AppColor.primary, width: 2) : null,
                              image: index == 0 ? null : DecorationImage(image: AssetImage(logic.effectImages[index]), fit: BoxFit.cover),
                            ),
                            child: index == 0 ? const Center(child: Icon(Icons.block, color: Colors.white)) : null,
                          ),
                          const SizedBox(height: 5),
                          Text(logic.effectNames[index], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isSelected ? AppColor.primary : Colors.white, fontSize: 10))
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 40, child: Icon(Icons.photo_library, color: Colors.white)),
              GestureDetector(
                onTap: logic.onClickRecordingButton,
                onLongPressStart: logic.isUseEffects ? logic.onLongPressStart : null,
                onLongPressEnd: logic.isUseEffects ? logic.onLongPressEnd : null,
                child: GetBuilder<CreateReelsController>(
                  id: "onChangeRecordingEvent",
                  builder: (logic) {
                    bool isRecording = logic.isRecording == "start";
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: isRecording ? 85 : 70, width: isRecording ? 85 : 70,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), color: Colors.transparent),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: isRecording ? 30 : 55, width: isRecording ? 30 : 55,
                          decoration: BoxDecoration(color: AppColor.primary, borderRadius: BorderRadius.circular(isRecording ? 5 : 100)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              GestureDetector(
                onTap: logic.onClickPreviewButton,
                child: SizedBox(
                  width: 40, 
                  child: GetBuilder<CreateReelsController>(
                    id: "onChangeRecordingEvent",
                    builder: (logic) {
                       if (logic.isRecording == "pause" || (logic.isRecording == "stop" && logic.countTime > 0)) {
                         return Container(height: 35, width: 35, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.black, size: 20));
                       }
                       return const SizedBox.shrink();
                    },
                  )
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}