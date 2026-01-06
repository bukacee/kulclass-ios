import 'package:get/get.dart';
import 'package:shortie/custom/custom_fetch_user_coin.dart';
import 'package:shortie/pages/my_wallet_page/api/fetch_coin_history_api.dart';
import 'package:shortie/pages/my_wallet_page/model/fetch_coin_history_model.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';

class MyWalletController extends GetxController {
  bool isLoading = false;
  List<Data> coinHistory = [];
  FetchCoinHistoryModel? fetchCoinHistoryModel;

  String startDate = "All";
  String endDate = "All"; // This is Send on Api....

  String rangeDate = "All"; // This is Show on UI....

  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<void> init() async {
    onGetCoinHistory();
    Utils.showLog("My Wallet Page Controller Initialize Success");
    CustomFetchUserCoin.init();
  }

  Future<void> onGetCoinHistory() async {
    isLoading = true;
    coinHistory.clear();
    update(["onGetCoinHistory"]);
    fetchCoinHistoryModel =
        await FetchCoinHistoryApi.callApi(loginUserId: Database.loginUserId, startDate: startDate, endDate: endDate);

    if (fetchCoinHistoryModel?.data != null) {
      coinHistory.clear();
      coinHistory.addAll(fetchCoinHistoryModel?.data ?? []);
      isLoading = false;
      update(["onGetCoinHistory"]);
    }
  }

  Future<void> onChangeDate({required String startDate, required String endDate, required String rangeDate}) async {
    this.startDate = startDate;
    this.endDate = endDate;
    this.rangeDate = rangeDate;
    update(["onChangeDate"]);
  }
}
