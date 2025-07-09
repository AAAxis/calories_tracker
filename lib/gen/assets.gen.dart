/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/dashboard.svg
  String get dashboard => 'assets/icons/dashboard.svg';

  /// File path: assets/icons/fridge.svg
  String get fridge => 'assets/icons/fridge.svg';

  /// File path: assets/icons/premium.png
  AssetGenImage get premium => const AssetGenImage('assets/icons/premium.png');

  /// File path: assets/icons/scan.svg
  String get scan => 'assets/icons/scan.svg';

  /// File path: assets/icons/stats.png
  AssetGenImage get statsPng => const AssetGenImage('assets/icons/stats.png');

  /// File path: assets/icons/stats.svg
  String get statsSvg => 'assets/icons/stats.svg';

  /// List of all assets
  List<dynamic> get values => [
    dashboard,
    fridge,
    premium,
    scan,
    statsPng,
    statsSvg,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/burger.jpg
  AssetGenImage get burger => const AssetGenImage('assets/images/burger.jpg');

  /// File path: assets/images/pizza.jpg
  AssetGenImage get pizza => const AssetGenImage('assets/images/pizza.jpg');

  /// File path: assets/images/profile.png
  AssetGenImage get profile => const AssetGenImage('assets/images/profile.png');

  /// File path: assets/images/white_sauce_pasta.png
  AssetGenImage get whiteSaucePasta =>
      const AssetGenImage('assets/images/white_sauce_pasta.png');

  /// List of all assets
  List<AssetGenImage> get values => [burger, pizza, profile, whiteSaucePasta];
}

class Assets {
  const Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
