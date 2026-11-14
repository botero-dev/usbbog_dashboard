import 'package:flutter_test/flutter_test.dart';
import 'package:usbbog_dashboard/modules/photos/services/immich_service.dart';
import 'package:usbbog_dashboard/modules/photos/view_models/album_picker_view_model.dart';

import '../../support/fake_immich.dart';

AlbumPickerViewModel buildViewModel({int status = 200}) {
  return AlbumPickerViewModel(
    ImmichService(
      baseUrl: 'https://demo.immich.app',
      apiKey: 'test-key',
      client: fakeImmich(status: status),
    ),
  );
}

void main() {
  test('hides albums without assets', () async {
    final viewModel = buildViewModel();

    await viewModel.load();

    expect(viewModel.albums.map((a) => a.name), ['Birthday', 'Holiday']);
    expect(viewModel.albums.any((a) => a.name == 'Empty Album'), isFalse);
    viewModel.dispose();
  });

  test('exposes the failure message and no albums', () async {
    final viewModel = buildViewModel(status: 401);

    await viewModel.load();

    expect(viewModel.albums, isEmpty);
    expect(viewModel.error, contains('clave de API'));
    viewModel.dispose();
  });
}
