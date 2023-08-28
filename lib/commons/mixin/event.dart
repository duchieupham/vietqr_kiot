import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class ChangeNavi {
  final bool isNavi;

  ChangeNavi(this.isNavi);
}

class ChangeBottomBarEvent {
  final int page;

  ChangeBottomBarEvent(this.page);
}

class GetListBankScreen {
  GetListBankScreen();
}

class ReloadWallet {
  ReloadWallet();
}
