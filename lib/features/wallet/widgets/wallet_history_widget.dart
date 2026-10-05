import 'package:stackfood_multivendor/features/wallet/domain/models/wallet_filter_body_model.dart';
import 'package:stackfood_multivendor/features/wallet/controllers/wallet_controller.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/history_cart_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WalletHistoryWidget extends StatefulWidget {
  const WalletHistoryWidget({super.key});

  @override
  State<WalletHistoryWidget> createState() => _WalletHistoryWidgetState();
}

class _WalletHistoryWidgetState extends State<WalletHistoryWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(
      builder: (walletController) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.only(top: Dimensions.paddingExtraLarge),
            child: Text('wallet_history'.tr, style: context.heading.large.strong),
          ),
          const SizedBox(height: Dimensions.paddingDefault),

          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: walletController.walletFilterList.length,
              separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingLarge),
              itemBuilder: (context, index) {
                WalletFilterBodyModel filter = walletController.walletFilterList[index];
                bool isSelected = filter.value == walletController.type;

                return Builder(
                  builder: (itemContext) {
                    return InkWell(
                      onTap: () {
                        walletController.setWalletFilerType(filter.value!);
                        walletController.getWalletTransactionList('1', false, walletController.type);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if(itemContext.mounted) {
                            Scrollable.ensureVisible(
                              itemContext,
                              alignment: 0.5,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        });
                      },
                      child: IntrinsicWidth(
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Text(
                            filter.title!.tr,
                            style: isSelected
                                ? context.subHeading.defaultSize.strong.overrideWith(color: context.textBaseDefault)
                                : context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                          ),
                          const SizedBox(height: 6),

                          Container(height: 2, color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color : Colors.transparent),
                        ]),
                      ),
                    );
                  }
                );
              },
            ),
          ),
          const SizedBox(height: Dimensions.paddingSmall),

          walletController.transactionList != null ? walletController.transactionList!.isNotEmpty ? GridView.builder(
            key: UniqueKey(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 50,
              mainAxisSpacing: 0.01,
              childAspectRatio: 4.45,
              crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 1,
            ),
            physics:  const NeverScrollableScrollPhysics(),
            shrinkWrap:  true,
            itemCount: walletController.transactionList!.length ,
            padding: EdgeInsets.only(top: 15),
            itemBuilder: (context, index) {
              return HistoryCartWidget(index: index, data: walletController.transactionList);
            },
          ) : NoDataScreen(title: 'no_transaction_yet'.tr, isEmptyTransaction: true) : WalletShimmer(walletController: walletController),

          walletController.isLoading ? const Center(child: Padding(
            padding: EdgeInsets.all(Dimensions.paddingSmall),
            child: CircularProgressIndicator(),
          )) : const SizedBox(),


        ]);
      }
    );
  }
}


class WalletShimmer extends StatelessWidget {
  final WalletController walletController;
  const WalletShimmer({super.key, required this.walletController});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: 0.01,
        childAspectRatio: 4.1,
        crossAxisCount: 1,
      ),
      physics:  const NeverScrollableScrollPhysics(),
      shrinkWrap:  true,
      itemCount: 10,
      padding: EdgeInsets.only(top: 25),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: walletController.transactionList == null,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                ],
              ),
              Padding(padding: const EdgeInsets.only(top: Dimensions.paddingLarge), child: Divider(color: context.surfaceContainerLow)),
            ],
            ),
          ),
        );
      },
    );
  }
}