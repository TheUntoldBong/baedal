import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/prediction_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class LocationSearchDialog extends StatefulWidget {
  final GoogleMapController? mapController;
  final Widget? child;
  final String? pickedLocation;
  final Function(Position)? callBack;
  final bool fromAddress;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final Widget? leading;
  final bool fullWidthBar;
  final Function(PredictionModel suggestion)? onSelected;
  const LocationSearchDialog({super.key,
    required this.mapController, this.child, this.pickedLocation, this.callBack, this.fromAddress = false,
    this.onOpen, this.onClose, this.leading, this.fullWidthBar = false, this.onSelected,
  });

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final SearchController controller = SearchController();
  bool _isOpen = false;
  String? _searchingWithQuery;
  late Iterable<Widget> _lastOptions = <Widget>[];
  List<PredictionModel> _predictionList = [];
  List<String> _predictList = <String>[];

  @override
  void initState() {
    super.initState();

    controller.text = widget.pickedLocation ?? '';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(controller.isAttached && !controller.isOpen) {
      controller.text = widget.pickedLocation ?? '';
    }
    return GetBuilder<LocationController>(
      builder: (lController) {
        return SearchAnchor(
          searchController: controller,
          viewSurfaceTintColor: context.surfaceContainer,
          isFullScreen: false,
          viewLeading: IconButton(onPressed: () => controller.closeView(''), icon: const Icon(Icons.arrow_back)),
          viewTrailing: [
            IconButton(
              onPressed: () {
                if(controller.text.isNotEmpty) {
                  controller.text = '';
                } else {
                  controller.closeView('');
                }
              },
              icon: const Icon(Icons.clear),
            ),
          ],
          viewConstraints: const BoxConstraints(minHeight: 100 , maxHeight: 300),
          viewOnOpen: () {
            setState(() => _isOpen = true);
            widget.onOpen?.call();
          },
          viewOnClose: () {
            setState(() => _isOpen = false);
            widget.onClose?.call();
          },

          builder: (BuildContext context, SearchController controller) {
            final Widget pill = widget.child ?? Container(
              height: 50, width: 500,
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                border: Border.all(color: context.outline),
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
              child: Row(children: [

                Icon(Icons.location_on_outlined, size: 20),
                const SizedBox(width: Dimensions.paddingSmall),

                Expanded(child: Text(
                  controller.text.isNotEmpty ? controller.text : 'search_location'.tr,
                  style: context.body.defaultSize.regular.overrideWith(color: controller.text.isEmpty ? context.textBaseMedium : context.textBaseDefault),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                )),

                Icon(Icons.search, color: context.iconBaseMedium),
              ]),
            );

            if (!widget.fullWidthBar) {
              return pill;
            }

            return Row(children: [

              if (widget.leading != null)
                ClipRect(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isOpen ? const SizedBox.shrink() : Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSmall),
                      child: widget.leading!,
                    ),
                  ),
                ),

              Expanded(child: pill),
            ]);
          },
          suggestionsBuilder: (BuildContext context, SearchController controller) async {
            _searchingWithQuery = controller.text;
            final List<String> options = (await _search(_searchingWithQuery!, lController)).toList();
            if (_searchingWithQuery != controller.text) {
              return _lastOptions;
            }

            _lastOptions = List<ListTile>.generate(options.length, (int index) {
              final String location = options[index];
              return ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(location, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () async {
                  if (_predictionList.isEmpty) {
                    controller.closeView('');
                    return;
                  }
                  final int selectedIndex = _predictList.indexOf(location);
                  if (selectedIndex < 0 || selectedIndex >= _predictionList.length) {
                    controller.closeView('');
                    return;
                  }
                  final PredictionModel suggestion = _predictionList[selectedIndex];
                  if (widget.onSelected != null) {
                    widget.onSelected!(suggestion);
                  } else {
                    Position position = await Get.find<LocationController>().setLocation(suggestion.placeId!, suggestion.description, widget.mapController);
                    if (widget.fromAddress) {
                      widget.callBack?.call(position);
                    }
                  }
                  controller.closeView(location);
                },
              );
            });

            return _lastOptions;
          });
      }
    );

  }

  Future<Iterable<String>> _search(String query, LocationController locationController) async {
    _predictionList = await locationController.searchLocation(query);

    if (query == '') {
      return const Iterable<String>.empty();
    }
    _predictList = [];
    for (var prediction in _predictionList) {
      _predictList.add(prediction.description!);
    }
    if(_predictList.isEmpty) {
      _predictList.add('no_address_found'.tr);
    }
    return _predictList;
  }
}
